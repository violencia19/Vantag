import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../providers/pro_provider.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';
import 'onboarding_screen.dart';

/// Profile Modal - Shows user profile information
/// Displayed when user taps on avatar in header
class ProfileModal extends StatefulWidget {
  const ProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.appColors.background.withValues(alpha: 0.9),
      builder: (context) => const ProfileModal(),
    );
  }

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().refreshAchievements(context);
    });
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

                      const SizedBox(height: 32),

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
    final photoUrl = user?.photoURL;
    final displayName = user?.displayName ?? l10n.profile;
    final email = user?.email ?? '';

    return Column(
      children: [
        // Avatar
        Stack(
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
                      ? const Color(0xFFFFD700)
                      : context.appColors.primary,
                  width: isPro ? 3 : 2,
                ),
                boxShadow: isPro
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultAvatar(),
                      )
                    : _defaultAvatar(),
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
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.5),
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
      barrierColor: context.appColors.background.withValues(alpha: 0.9),
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
