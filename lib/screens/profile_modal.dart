import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../providers/pro_provider.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../theme/theme.dart';
import '../theme/app_theme.dart';
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
            backgroundColor: context.appColors.error,
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
    final expenses = financeProvider.expenses;
    final firstExpenseDate = expenses.isNotEmpty
        ? expenses.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b)
        : DateTime.now();
    final memberDays = DateTime.now().difference(firstExpenseDate).inDays;

    // Get badges count - count unlocked achievements
    final badgesEarned = financeProvider.achievements
        .where((a) => a.isUnlocked)
        .length;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: context.appColors.cardBorder,
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
                  color: context.appColors.textTertiary.withValues(alpha: 0.3),
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
                      _buildProfileHeader(context, authService, isPro, l10n),

                      const SizedBox(height: 20),

                      // Action Buttons Row (Photo, Salary, Add Income)
                      _buildActionButtonsRow(context, l10n, financeProvider),

                      const SizedBox(height: 24),

                      // Saved Time Counter
                      _buildSavedTimeCard(context, savedHours, l10n),

                      const SizedBox(height: 24),

                      // Stats Row
                      _buildStatsRow(context, memberDays, badgesEarned, l10n),

                      const SizedBox(height: 24),

                      // Google Connection Status
                      _buildGoogleStatus(context, authService, l10n),

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
                      context.appColors.primary.withValues(alpha: 0.3),
                      context.appColors.secondary.withValues(alpha: 0.3),
                    ],
                  ),
                  border: Border.all(
                    color: isPro
                        ? AppColors.medalGold
                        : context.appColors.primary,
                    width: isPro ? 3 : 2,
                  ),
                  boxShadow: isPro
                      ? [
                          BoxShadow(
                            color: AppColors.medalGold.withValues(alpha: 0.4),
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
                              context.appColors.primary,
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
                    color: context.appColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.appColors.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.camera,
                    size: 14,
                    color: context.appColors.background,
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
                        colors: [AppColors.medalGold, AppColors.orange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.medalGold.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: context.appColors.background,
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
            color: context.appColors.textPrimary,
          ),
        ),

        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
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
        errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      color: context.appColors.surfaceLight,
      child: Icon(
        PhosphorIconsDuotone.user,
        size: 50,
        color: context.appColors.textTertiary,
      ),
    );
  }

  Widget _buildActionButtonsRow(
    BuildContext context,
    AppLocalizations l10n,
    FinanceProvider financeProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Photo Button
        _buildActionButton(
          icon: PhosphorIconsDuotone.camera,
          label: l10n.changePhoto,
          onTap: () => _showPhotoOptions(l10n),
        ),
        const SizedBox(width: 12),
        // Salary Button
        _buildActionButton(
          icon: PhosphorIconsDuotone.money,
          label: l10n.editSalary,
          onTap: () => _showEditSalarySheet(context, l10n, financeProvider),
        ),
        const SizedBox(width: 12),
        // Add Income Button
        _buildActionButton(
          icon: PhosphorIconsDuotone.plusCircle,
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
          color: context.appColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.appColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: context.appColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.appColors.textPrimary,
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
            context.appColors.primary.withValues(alpha: 0.25),
            context.appColors.secondary.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.appColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            PhosphorIconsDuotone.clock,
            size: 32,
            color: context.appColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileSavedTime,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.profileHours(savedHours.toStringAsFixed(1)),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: context.appColors.textPrimary,
              letterSpacing: -1,
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
            icon: PhosphorIconsDuotone.calendarCheck,
            label: l10n.profileMemberSince,
            value: l10n.profileDays(memberDays > 0 ? memberDays : 1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: PhosphorIconsDuotone.trophy,
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
        color: context.appColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: context.appColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.appColors.textSecondary,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLinked
                  ? context.appColors.success.withValues(alpha: 0.15)
                  : context.appColors.textTertiary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLinked
                  ? PhosphorIconsDuotone.googleLogo
                  : PhosphorIconsDuotone.link,
              size: 20,
              color: isLinked
                  ? context.appColors.success
                  : context.appColors.textTertiary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isLinked
                  ? l10n.profileGoogleConnected
                  : l10n.profileGoogleNotConnected,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isLinked
                    ? context.appColors.success
                    : context.appColors.textSecondary,
              ),
            ),
          ),
          Icon(
            isLinked
                ? PhosphorIconsDuotone.checkCircle
                : PhosphorIconsDuotone.xCircle,
            size: 20,
            color: isLinked
                ? context.appColors.success
                : context.appColors.textTertiary,
          ),
        ],
      ),
    );
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
            color: context.appColors.error.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(
          PhosphorIconsDuotone.signOut,
          size: 20,
          color: context.appColors.error,
        ),
        label: Text(
          l10n.profileSignOut,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.appColors.error,
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
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.profileSignOut,
          style: TextStyle(
            color: context.appColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.profileSignOutConfirm,
          style: TextStyle(color: context.appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.error,
              foregroundColor: context.appColors.textPrimary,
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
        color: context.appColors.surface,
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
                  color: context.appColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.changePhoto,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildOption(
                context: context,
                icon: PhosphorIconsDuotone.camera,
                label: l10n.takePhoto,
                onTap: onCameraTap,
              ),
              const SizedBox(height: 12),
              _buildOption(
                context: context,
                icon: PhosphorIconsDuotone.image,
                label: l10n.selectFromGallery,
                onTap: onGalleryTap,
              ),
              if (localPhotoPath != null) ...[
                const SizedBox(height: 12),
                _buildOption(
                  context: context,
                  icon: PhosphorIconsDuotone.trash,
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDestructive
                ? context.appColors.error.withValues(alpha: 0.1)
                : context.appColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? context.appColors.error
                    : context.appColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? context.appColors.error
                      : context.appColors.textPrimary,
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
            backgroundColor: context.appColors.success,
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
            backgroundColor: context.appColors.error,
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
        color: context.appColors.surface,
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
                        color: context.appColors.textTertiary.withValues(
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
                          color: context.appColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          PhosphorIconsDuotone.money,
                          color: context.appColors.primary,
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
                                color: context.appColors.textPrimary,
                              ),
                            ),
                            Text(
                              l10n.editSalarySubtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.appColors.textSecondary,
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
                      color: context.appColors.textSecondary,
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
                      color: context.appColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: context.appColors.surfaceLight,
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
                        color: context.appColors.textSecondary,
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
                            ? context.appColors.primary
                            : context.appColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _canSave && !_isLoading
                            ? [
                                BoxShadow(
                                  color: context.appColors.primary
                                      .withValues(alpha: 0.3),
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
                                    context.appColors.background,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIconsBold.check,
                                  size: 20,
                                  color: _canSave
                                      ? context.appColors.background
                                      : context.appColors.textTertiary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.save,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _canSave
                                        ? context.appColors.background
                                        : context.appColors.textTertiary,
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
