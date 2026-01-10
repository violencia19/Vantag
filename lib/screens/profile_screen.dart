import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../providers/finance_provider.dart';
import '../services/tour_service.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'user_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onProfileUpdated;
  final VoidCallback? onStartTour;

  const ProfileScreen({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
    this.onStartTour,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = widget.userProfile;
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProfile != widget.userProfile) {
      _userProfile = widget.userProfile;
    }
  }

  Future<void> _editProfile() async {
    final updatedProfile = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(existingProfile: _userProfile),
      ),
    );

    if (updatedProfile != null) {
      setState(() => _userProfile = updatedProfile);
      widget.onProfileUpdated(updatedProfile);
    }
  }

  double _calculateHourlyWage() {
    final monthlyHours = _userProfile.dailyHours * _userProfile.workDaysPerWeek * 4;
    if (monthlyHours <= 0) return 0;
    return _userProfile.monthlyIncome / monthlyHours;
  }

  /// Reset all app data (DEBUG)
  Future<void> _resetAllData() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(PhosphorIconsDuotone.warningCircle, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            Text(
              l10n.resetDataTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.resetDataMessage,
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.heavyImpact();

      // Reset all data (both disk and memory)
      final provider = context.read<FinanceProvider>();
      await provider.resetAllData();

      if (!mounted) return;

      // Navigate back to onboarding
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          l10n.profile,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(PhosphorIconsDuotone.pencilSimple, size: 22),
              color: AppColors.textSecondary,
              tooltip: l10n.edit,
              onPressed: _editProfile,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile photo
            const ProfilePhotoWidget(size: 120),
            const SizedBox(height: 8),
            Text(
              l10n.tapToAddPhoto,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),

            // Info cards
            _buildInfoCard(
              icon: PhosphorIconsDuotone.creditCard,
              title: l10n.monthlyIncome,
              value: '${formatTurkishCurrency(_userProfile.monthlyIncome, decimalDigits: 2)} TL',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: PhosphorIconsDuotone.clock,
              title: l10n.dailyWork,
              value: '${_userProfile.dailyHours.toStringAsFixed(0)} ${l10n.hours}',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: PhosphorIconsDuotone.calendar,
              title: l10n.weeklyWorkingDays,
              value: '${_userProfile.workDaysPerWeek} ${l10n.days}',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: PhosphorIconsDuotone.trendUp,
              title: l10n.hourlyEarnings,
              value: '${formatTurkishCurrency(_calculateHourlyWage(), decimalDigits: 2)} TL/${l10n.hours}',
              highlight: true,
            ),

            const SizedBox(height: 32),

            // Edit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _editProfile,
                icon: Icon(PhosphorIconsDuotone.pencilSimple, size: 20),
                label: Text(l10n.editProfile),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Notification settings button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                },
                icon: Icon(PhosphorIconsDuotone.bell, size: 20),
                label: Text(l10n.notificationSettings),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // App tour button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await TourService.resetTour();
                  if (mounted && widget.onStartTour != null) {
                    widget.onStartTour!();
                  }
                },
                icon: Icon(PhosphorIconsDuotone.compass, size: 20),
                label: Text(l10n.repeatTour),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Privacy Policy button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('https://violencia19.github.io/Vantag/privacy-tr')),
                icon: Icon(PhosphorIconsDuotone.shield, size: 20),
                label: const Text('Gizlilik Politikası'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Terms of Service button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('https://violencia19.github.io/Vantag/terms-tr')),
                icon: Icon(PhosphorIconsDuotone.fileText, size: 20),
                label: const Text('Kullanım Şartları'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // DEBUG: Data reset button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _resetAllData,
                icon: Icon(PhosphorIconsDuotone.trash, size: 20),
                label: Text(l10n.resetDataDebug),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
            // Extra space for nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: highlight
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 22,
              color: highlight ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: highlight ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
