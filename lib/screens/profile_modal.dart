import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../providers/pro_provider.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../theme/theme.dart';

import '../utils/currency_utils.dart';
import 'onboarding_screen.dart';
import 'income_wizard_screen.dart';

/// Profile Modal - Shows user profile information
/// Displayed when user taps on avatar in header
class ProfileModal extends StatefulWidget {
  const ProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => const ProfileModal(),
    );
  }

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  final _profileService = ProfileService();
  final _imagePicker = ImagePicker();
  String? _localPhotoPath;
  bool _isPhotoLoading = false;
  bool _isLinkingGoogle = false;
  bool _isLinkingApple = false;

  @override
  void initState() {
    super.initState();
    _loadLocalPhoto();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().refreshAchievements(context);
    });
  }

  Future<void> _loadLocalPhoto() async {
    final path = await _profileService.getProfilePhotoPath();
    if (mounted) {
      setState(() => _localPhotoPath = path);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isPhotoLoading = true);

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() => _isPhotoLoading = false);
        return;
      }

      final savedPath = await _profileService.saveProfilePhoto(
        File(pickedFile.path),
      );

      if (mounted) {
        setState(() {
          _localPhotoPath = savedPath;
          _isPhotoLoading = false;
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPhotoLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).photoSelectError),
            backgroundColor: context.vantColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto() async {
    await _profileService.deleteProfilePhoto();
    if (mounted) {
      setState(() => _localPhotoPath = null);
      HapticFeedback.mediumImpact();
    }
  }

  void _showPhotoOptions(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: Colors.transparent,
      builder: (context) => _PhotoOptionsSheet(
        localPhotoPath: _localPhotoPath,
        onCameraTap: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGalleryTap: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
        onDeleteTap: () {
          Navigator.pop(context);
          _deletePhoto();
        },
        l10n: l10n,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authService = AuthService();
    final financeProvider = context.watch<FinanceProvider>();
    final proProvider = context.watch<ProProvider>();
    final isPro = proProvider.isPro;

    // Calculate saved time (total spent / hourly rate)
    final userProfile = financeProvider.userProfile;
    final totalSaved = financeProvider.stats.savedAmount;
    final hourlyRate = userProfile != null && userProfile.dailyHours > 0
        ? userProfile.monthlyIncome /
              (userProfile.dailyHours * userProfile.workDaysPerWeek * 4)
        : 0.0;
    final savedHours = hourlyRate > 0 ? totalSaved / hourlyRate : 0.0;

    // Get membership days (from first expense or 0)
    final expenses = financeProvider.realExpenses;
    final firstExpenseDate = expenses.isNotEmpty
        ? expenses.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b)
        : DateTime.now();
    final memberDays = DateTime.now().difference(firstExpenseDate).inDays;

    // Get badges count - count unlocked achievements
    final badgesEarned = financeProvider.achievements
        .where((a) => a.isUnlocked)
        .length;

    // Stack with opaque background to ensure proper dark overlay
    return Stack(
      children: [
        // Opaque background layer - tapping dismisses modal
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black.withValues(alpha: 0.85)),
          ),
        ),
        // The actual draggable sheet
        DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: context.vantColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: context.vantColors.cardBorder,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: context.vantColors.textTertiary.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Avatar + Name + Email
                          _buildProfileHeader(
                            context,
                            authService,
                            isPro,
                            l10n,
                          ),

                          const SizedBox(height: 20),

                          // Action Buttons Row (Photo, Salary, Add Income)
                          _buildActionButtonsRow(
                            context,
                            l10n,
                            financeProvider,
                          ),

                          const SizedBox(height: 24),

                          // Saved Time Counter
                          _buildSavedTimeCard(context, savedHours, l10n),

                          const SizedBox(height: 24),

                          // Stats Row
                          _buildStatsRow(
                            context,
                            memberDays,
                            badgesEarned,
                            l10n,
                          ),

                          const SizedBox(height: 24),

                          // Google Connection Status
                          _buildGoogleStatus(context, authService, l10n),

                          const SizedBox(height: 12),

                          // Apple Connection Status
                          _buildAppleStatus(context, authService, l10n),

                          const SizedBox(height: 32),

                          // Sign Out Button
                          _buildSignOutButton(context, authService, l10n),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AuthService authService,
    bool isPro,
    AppLocalizations l10n,
  ) {
    final user = authService.currentUser;
    final googlePhotoUrl = user?.photoURL;
    final displayName = user?.displayName ?? l10n.profile;
    final email = user?.email ?? '';

    return Column(
      children: [
        // Avatar - Tappable for photo change
        GestureDetector(
          onTap: () => _showPhotoOptions(l10n),
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.vantColors.primary.withValues(alpha: 0.3),
                      context.vantColors.secondary.withValues(alpha: 0.3),
                    ],
                  ),
                  border: Border.all(
                    color: isPro
                        ? VantColors.medalGold
                        : context.vantColors.primary,
                    width: isPro ? 3 : 2,
                  ),
                  boxShadow: isPro
                      ? [
                          BoxShadow(
                            color: VantColors.medalGold.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: ClipOval(
                  child: _isPhotoLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.vantColors.primary,
                            ),
                          ),
                        )
                      : _localPhotoPath != null
                      ? Image.file(
                          File(_localPhotoPath!),
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildAvatarContent(googlePhotoUrl),
                        )
                      : _buildAvatarContent(googlePhotoUrl),
                ),
              ),
              // Camera edit indicator
              Positioned(
                bottom: 0,
                right: isPro ? 30 : 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.vantColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.vantColors.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.camera,
                    size: 14,
                    color: context.vantColors.background,
                  ),
                ),
              ),
              // Pro Badge
              if (isPro)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [VantColors.medalGold, VantColors.orange],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: VantColors.medalGold.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: context.vantColors.background,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Name
        Text(
          displayName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: context.vantColors.textPrimary,
          ),
        ),

        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: context.vantColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarContent(String? googlePhotoUrl) {
    if (googlePhotoUrl != null) {
      return Image.network(
        googlePhotoUrl,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        cacheWidth: 200,
        cacheHeight: 200,
        errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      color: context.vantColors.surfaceLight,
      child: Icon(
        CupertinoIcons.person,
        size: 50,
        color: context.vantColors.textTertiary,
      ),
    );
  }

  Widget _buildActionButtonsRow(
    BuildContext context,
    AppLocalizations l10n,
    FinanceProvider financeProvider,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        // Photo Button
        _buildActionButton(
          icon: CupertinoIcons.camera,
          label: l10n.changePhoto,
          onTap: () => _showPhotoOptions(l10n),
        ),
        // Salary Button
        _buildActionButton(
          icon: CupertinoIcons.money_dollar_circle,
          label: l10n.editSalary,
          onTap: () => _showEditSalarySheet(context, l10n, financeProvider),
        ),
        // Work Hours Button
        _buildActionButton(
          icon: CupertinoIcons.clock,
          label: l10n.editWorkHours,
          onTap: () => _showEditWorkHoursSheet(context, l10n, financeProvider),
        ),
        // Add Income Button
        _buildActionButton(
          icon: CupertinoIcons.plus_circle,
          label: l10n.addIncome,
          onTap: () => _navigateToAddIncome(context, financeProvider),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.vantColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.vantColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: context.vantColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.vantColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSalarySheet(
    BuildContext context,
    AppLocalizations l10n,
    FinanceProvider financeProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditSalarySheet(
        financeProvider: financeProvider,
        l10n: l10n,
        onSaved: () {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _showEditWorkHoursSheet(
    BuildContext context,
    AppLocalizations l10n,
    FinanceProvider financeProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditWorkHoursSheet(
        financeProvider: financeProvider,
        l10n: l10n,
        onSaved: () {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _navigateToAddIncome(
    BuildContext context,
    FinanceProvider financeProvider,
  ) {
    Navigator.pop(context); // Close modal first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomeWizardScreen(
          existingProfile: financeProvider.userProfile,
          existingSources: financeProvider.incomeSources,
          isEditing: true,
          skipToAdditional: true,
        ),
      ),
    );
  }

  Widget _buildSavedTimeCard(
    BuildContext context,
    double savedHours,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.vantColors.primary.withValues(alpha: 0.25),
            context.vantColors.secondary.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.vantColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.clock,
            size: 32,
            color: context.vantColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileSavedTime,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.vantColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.profileHours(savedHours.toStringAsFixed(1)),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: context.vantColors.textPrimary,
              letterSpacing: -1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    int memberDays,
    int badgesEarned,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: CupertinoIcons.calendar_badge_plus,
            label: l10n.profileMemberSince,
            value: l10n.profileDays(memberDays > 0 ? memberDays : 1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: CupertinoIcons.rosette,
            label: l10n.profileBadgesEarned,
            value: badgesEarned.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.vantColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.vantColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: context.vantColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.vantColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.vantColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleStatus(
    BuildContext context,
    AuthService authService,
    AppLocalizations l10n,
  ) {
    final isLinked = authService.isLinkedWithGoogle;

    return Container(
      decoration: BoxDecoration(
        color: context.vantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [VantShadows.subtle],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLinked || _isLinkingGoogle
              ? null
              : () => _linkGoogleAccount(authService, l10n),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Google Logo Container - Revolut style
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _isLinkingGoogle
                      ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                context.vantColors.primary,
                              ),
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4285F4),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.vantColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLinked
                            ? l10n.profileGoogleConnected
                            : l10n.dataNotBackedUp,
                        style: TextStyle(
                          fontSize: 13,
                          color: isLinked
                              ? context.vantColors.success
                              : context.vantColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status / Action Button
                if (_isLinkingGoogle)
                  Text(
                    l10n.linking,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.vantColors.textTertiary,
                    ),
                  )
                else if (isLinked)
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    size: 22,
                    color: context.vantColors.success,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.vantColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.linkWithGoogle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _linkGoogleAccount(
    AuthService authService,
    AppLocalizations l10n,
  ) async {
    setState(() => _isLinkingGoogle = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await authService.signInWithGoogle();

      if (!mounted) return;

      if (result.success) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.googleLinkedSuccess)),
              ],
            ),
            backgroundColor: context.vantColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
        // Refresh UI to show linked status
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(result.errorMessage ?? l10n.googleLinkFailed),
                ),
              ],
            ),
            backgroundColor: context.vantColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.googleLinkFailed),
            backgroundColor: context.vantColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLinkingGoogle = false);
      }
    }
  }

  Widget _buildAppleStatus(
    BuildContext context,
    AuthService authService,
    AppLocalizations l10n,
  ) {
    final isLinked = authService.isLinkedWithApple;

    return Container(
      decoration: BoxDecoration(
        color: context.vantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [VantShadows.subtle],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLinked || _isLinkingApple
              ? null
              : () => _linkAppleAccount(authService, l10n),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Apple Logo Container - Revolut style
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _isLinkingApple
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.apple,
                            size: 26,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apple',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: context.vantColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isLinked
                                ? l10n.profileAppleConnected
                                : l10n.profileAppleNotConnected,
                            style: TextStyle(
                              fontSize: 13,
                              color: isLinked
                                  ? context.vantColors.success
                                  : context.vantColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status / Action Button - Revolut style
                    if (_isLinkingApple)
                      Text(
                        l10n.linking,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.vantColors.textTertiary,
                        ),
                      )
                    else if (isLinked)
                      Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        size: 22,
                        color: context.vantColors.success,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.linkWithApple,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _linkAppleAccount(
    AuthService authService,
    AppLocalizations l10n,
  ) async {
    setState(() => _isLinkingApple = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await authService.signInWithApple();

      if (!mounted) return;

      if (result.success) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.appleLinkedSuccess)),
              ],
            ),
            backgroundColor: context.vantColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
        // Refresh UI to show linked status
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(result.errorMessage ?? l10n.appleLinkFailed),
                ),
              ],
            ),
            backgroundColor: context.vantColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appleLinkFailed),
            backgroundColor: context.vantColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLinkingApple = false);
      }
    }
  }

  Widget _buildSignOutButton(
    BuildContext context,
    AuthService authService,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmSignOut(context, authService, l10n),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: context.vantColors.error.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          CupertinoIcons.square_arrow_right,
          size: 20,
          color: context.vantColors.error,
        ),
        label: Text(
          l10n.profileSignOut,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.vantColors.error,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    AuthService authService,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => AlertDialog(
        backgroundColor: context.vantColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.profileSignOut,
          style: TextStyle(
            color: context.vantColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.profileSignOutConfirm,
          style: TextStyle(color: context.vantColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.vantColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.vantColors.error,
              foregroundColor: context.vantColors.textPrimary,
            ),
            child: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.heavyImpact();
      await authService.signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
      }
    }
  }
}

// ============================================================================
// PHOTO OPTIONS SHEET
// ============================================================================

class _PhotoOptionsSheet extends StatelessWidget {
  final String? localPhotoPath;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onDeleteTap;
  final AppLocalizations l10n;

  const _PhotoOptionsSheet({
    required this.localPhotoPath,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onDeleteTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.vantColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.vantColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.changePhoto,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildOption(
                context: context,
                icon: CupertinoIcons.camera,
                label: l10n.takePhoto,
                onTap: onCameraTap,
              ),
              const SizedBox(height: 12),
              _buildOption(
                context: context,
                icon: CupertinoIcons.photo,
                label: l10n.selectFromGallery,
                onTap: onGalleryTap,
              ),
              if (localPhotoPath != null) ...[
                const SizedBox(height: 12),
                _buildOption(
                  context: context,
                  icon: CupertinoIcons.trash,
                  label: l10n.removePhoto,
                  onTap: onDeleteTap,
                  isDestructive: true,
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDestructive
                ? context.vantColors.error.withValues(alpha: 0.1)
                : context.vantColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? context.vantColors.error
                    : context.vantColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? context.vantColors.error
                      : context.vantColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EDIT SALARY SHEET
// ============================================================================

class _EditSalarySheet extends StatefulWidget {
  final FinanceProvider financeProvider;
  final AppLocalizations l10n;
  final VoidCallback onSaved;

  const _EditSalarySheet({
    required this.financeProvider,
    required this.l10n,
    required this.onSaved,
  });

  @override
  State<_EditSalarySheet> createState() => _EditSalarySheetState();
}

class _EditSalarySheetState extends State<_EditSalarySheet> {
  final _amountController = TextEditingController();
  final _profileService = ProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current salary
    final primarySource = widget.financeProvider.userProfile?.primarySource;
    if (primarySource != null) {
      _amountController.text = formatTurkishCurrency(primarySource.amount);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount {
    final text = _amountController.text.trim();
    if (text.isEmpty) return null;
    return parseTurkishCurrency(text);
  }

  bool get _canSave => _amount != null && _amount! > 0;

  Future<void> _saveSalary() async {
    if (!_canSave || _isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final profile = widget.financeProvider.userProfile;
      if (profile == null) return;

      final primarySource = profile.primarySource;
      if (primarySource == null) return;

      // Update primary source amount
      final updatedSource = primarySource.copyWith(amount: _amount!);
      final updatedProfile = await _profileService.updateIncomeSource(
        primarySource.id,
        updatedSource,
      );

      if (updatedProfile != null && mounted) {
        widget.financeProvider.setUserProfile(updatedProfile);
        widget.onSaved();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l10n.incomesUpdated),
            backgroundColor: context.vantColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: context.vantColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final primarySource = widget.financeProvider.userProfile?.primarySource;
    final currencySymbol = primarySource?.currencyCode == 'TRY' ? '₺' : '\$';

    return Container(
      decoration: BoxDecoration(
        color: context.vantColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.vantColors.textTertiary.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.vantColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          CupertinoIcons.money_dollar_circle,
                          color: context.vantColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.editSalary,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: context.vantColors.textPrimary,
                              ),
                            ),
                            Text(
                              l10n.editSalarySubtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.vantColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Amount Input
                  Text(
                    l10n.monthlyIncome,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.vantColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [TurkishCurrencyInputFormatter()],
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: context.vantColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: context.vantColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: context.vantColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      prefixText: '$currencySymbol ',
                      prefixStyle: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  GestureDetector(
                    onTap: _canSave && !_isLoading ? _saveSalary : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _canSave && !_isLoading
                            ? context.vantColors.primary
                            : context.vantColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _canSave && !_isLoading
                            ? [
                                BoxShadow(
                                  color: context.vantColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: _isLoading
                          ? Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    context.vantColors.background,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark,
                                  size: 20,
                                  color: _canSave
                                      ? context.vantColors.background
                                      : context.vantColors.textTertiary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.save,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _canSave
                                        ? context.vantColors.background
                                        : context.vantColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EDIT WORK HOURS SHEET
// ============================================================================

class _EditWorkHoursSheet extends StatefulWidget {
  final FinanceProvider financeProvider;
  final AppLocalizations l10n;
  final VoidCallback onSaved;

  const _EditWorkHoursSheet({
    required this.financeProvider,
    required this.l10n,
    required this.onSaved,
  });

  @override
  State<_EditWorkHoursSheet> createState() => _EditWorkHoursSheetState();
}

class _EditWorkHoursSheetState extends State<_EditWorkHoursSheet> {
  final _profileService = ProfileService();
  late double _selectedHours;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.financeProvider.userProfile?.dailyHours ?? 8;
  }

  Future<void> _saveWorkHours() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final profile = widget.financeProvider.userProfile;
      if (profile == null) return;

      final updatedProfile = profile.copyWith(dailyHours: _selectedHours);
      await _profileService.saveProfile(updatedProfile);

      if (mounted) {
        widget.financeProvider.setUserProfile(updatedProfile);
        widget.onSaved();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l10n.workHoursUpdated),
            backgroundColor: context.vantColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: context.vantColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.vantColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.vantColors.textTertiary.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.vantColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          CupertinoIcons.clock,
                          color: context.vantColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.editWorkHours,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: context.vantColors.textPrimary,
                              ),
                            ),
                            Text(
                              l10n.editWorkHoursSubtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.vantColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Hours Display
                  Center(
                    child: Text(
                      l10n.hoursPerDay(_selectedHours.toStringAsFixed(1)),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: context.vantColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: context.vantColors.primary,
                      inactiveTrackColor: context.vantColors.surfaceLight,
                      thumbColor: context.vantColors.primary,
                      overlayColor: context.vantColors.primary.withValues(alpha: 0.2),
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                    ),
                    child: Slider(
                      value: _selectedHours,
                      min: 1,
                      max: 16,
                      divisions: 30,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedHours = value);
                      },
                    ),
                  ),

                  // Quick select buttons
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [4.0, 6.0, 8.0, 10.0, 12.0].map((hours) {
                      final isSelected = _selectedHours == hours;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedHours = hours);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.vantColors.primary
                                : context.vantColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? context.vantColors.primary
                                  : context.vantColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            '${hours.toInt()}h',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? context.vantColors.background
                                  : context.vantColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  GestureDetector(
                    onTap: _isLoading ? null : _saveWorkHours,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: context.vantColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: context.vantColors.primary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    context.vantColors.background,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark,
                                  size: 20,
                                  color: context.vantColors.background,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.save,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: context.vantColors.background,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
