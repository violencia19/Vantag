import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../providers/finance_provider.dart';
import '../providers/locale_provider.dart';
import '../services/achievements_service.dart';
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
  int _easterEggTaps = 0;

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

  void _showLanguageSelector() {
    final localeProvider = context.read<LocaleProvider>();
    final currentLocale = Localizations.localeOf(context);

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildLanguageOption(
                context: context,
                localeProvider: localeProvider,
                locale: const Locale('tr'),
                name: 'Türkçe',
                flag: '🇹🇷',
                isSelected: currentLocale.languageCode == 'tr',
              ),
              _buildLanguageOption(
                context: context,
                localeProvider: localeProvider,
                locale: const Locale('en'),
                name: 'English',
                flag: '🇺🇸',
                isSelected: currentLocale.languageCode == 'en',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required LocaleProvider localeProvider,
    required Locale locale,
    required String name,
    required String flag,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(PhosphorIconsDuotone.checkCircle, color: AppColors.primary)
          : null,
      onTap: () async {
        Navigator.pop(context);
        await localeProvider.setLocale(locale);
        HapticFeedback.lightImpact();
      },
    );
  }

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
            Expanded(
              child: Text(
                l10n.resetDataTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
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
      final provider = context.read<FinanceProvider>();
      await provider.resetAllData();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  void _onVersionTap() {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _easterEggTaps++);
    HapticFeedback.lightImpact();

    if (_easterEggTaps == 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.easterEgg5Left),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (_easterEggTaps == 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.easterEggAlmost),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (_easterEggTaps >= 10) {
      _unlockCuriousCatAchievement();
    }
  }

  Future<void> _unlockCuriousCatAchievement() async {
    final l10n = AppLocalizations.of(context)!;
    final achievementsService = AchievementsService();

    // Unlock the achievement
    await achievementsService.unlockManualAchievement('curious_cat');

    if (!mounted) return;

    // Reset counter
    setState(() => _easterEggTaps = 0);

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Show achievement unlocked dialog
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.3),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIconsDuotone.smileyWink,
                  size: 40,
                  color: AppColors.warning,
                  duotoneSecondaryColor: AppColors.warning.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.achievementUnlocked,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.curiousCatTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.curiousCatDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.great),
              ),
            ),
          ],
        ),
      ),
    );
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HEADER SECTION ====================
            _buildHeaderSection(l10n),

            const SizedBox(height: 32),

            // ==================== SETTINGS SECTION ====================
            _buildSectionTitle(l10n.settings),
            const SizedBox(height: 12),
            _buildSettingsSection(l10n),

            const SizedBox(height: 24),

            // ==================== ABOUT SECTION ====================
            _buildSectionTitle(l10n.about),
            const SizedBox(height: 12),
            _buildAboutSection(l10n),

            const SizedBox(height: 24),

            // ==================== DANGER ZONE ====================
            _buildSectionTitle(l10n.dangerZone, isDestructive: true),
            const SizedBox(height: 12),
            _buildDangerSection(l10n),

            // Extra space for nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER SECTION ====================
  Widget _buildHeaderSection(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Profile photo
        const ProfilePhotoWidget(size: 100),
        const SizedBox(height: 8),
        Text(
          l10n.tapToAddPhoto,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 20),

        // Info cards in 2x2 grid
        Row(
          children: [
            Expanded(
              child: _buildCompactInfoCard(
                icon: PhosphorIconsDuotone.wallet,
                title: l10n.monthlyIncome,
                value: formatTurkishCurrency(_userProfile.monthlyIncome, decimalDigits: 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactInfoCard(
                icon: PhosphorIconsDuotone.clock,
                title: l10n.dailyWork,
                value: '${_userProfile.dailyHours.toStringAsFixed(0)} ${l10n.hours}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCompactInfoCard(
                icon: PhosphorIconsDuotone.calendarBlank,
                title: l10n.weeklyWorkingDays,
                value: '${_userProfile.workDaysPerWeek} ${l10n.days}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactInfoCard(
                icon: PhosphorIconsDuotone.trendUp,
                title: l10n.hourlyEarnings,
                value: '${formatTurkishCurrency(_calculateHourlyWage(), decimalDigits: 2)}/sa',
                highlight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Single Edit Profile button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _editProfile,
            icon: Icon(PhosphorIconsDuotone.pencilSimple, size: 18),
            label: Text(l10n.editProfile),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SETTINGS SECTION ====================
  Widget _buildSettingsSection(AppLocalizations l10n) {
    // Watch locale provider for reactive updates
    final localeProvider = context.watch<LocaleProvider>();
    final currentLangCode = localeProvider.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final currentLangName = currentLangCode == 'tr' ? 'Türkçe' : 'English';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: PhosphorIconsDuotone.bell,
            iconColor: const Color(0xFF3498DB),
            title: l10n.notificationSettings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: PhosphorIconsDuotone.compass,
            iconColor: const Color(0xFF9B59B6),
            title: l10n.repeatTour,
            onTap: () async {
              await TourService.resetTour();
              if (mounted && widget.onStartTour != null) {
                widget.onStartTour!();
              }
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: PhosphorIconsDuotone.globe,
            iconColor: const Color(0xFF2ECC71),
            title: l10n.language,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLangName,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  PhosphorIconsDuotone.caretRight,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            showArrow: false,
            onTap: _showLanguageSelector,
          ),
        ],
      ),
    );
  }

  // ==================== ABOUT SECTION ====================
  Widget _buildAboutSection(AppLocalizations l10n) {
    // Use provider locale or fall back to system locale
    final localeProvider = context.watch<LocaleProvider>();
    final langCode = localeProvider.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final isTurkish = langCode == 'tr';
    final privacyUrl = isTurkish
        ? 'https://violencia19.github.io/Vantag/privacy-tr'
        : 'https://violencia19.github.io/Vantag/privacy-en';
    final termsUrl = isTurkish
        ? 'https://violencia19.github.io/Vantag/terms-tr'
        : 'https://violencia19.github.io/Vantag/terms-en';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: PhosphorIconsDuotone.shieldCheck,
            iconColor: const Color(0xFF1ABC9C),
            title: l10n.privacyPolicy,
            onTap: () => launchUrl(Uri.parse(privacyUrl)),
          ),
          _buildDivider(),
          _buildListTile(
            icon: PhosphorIconsDuotone.fileText,
            iconColor: const Color(0xFFF39C12),
            title: l10n.termsOfService,
            onTap: () => launchUrl(Uri.parse(termsUrl)),
          ),
          _buildDivider(),
          _buildListTile(
            icon: PhosphorIconsDuotone.info,
            iconColor: const Color(0xFF95A5A6),
            title: l10n.appVersion,
            trailing: Text(
              '1.0.0',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            showArrow: false,
            onTap: _onVersionTap,
          ),
        ],
      ),
    );
  }

  // ==================== DANGER ZONE ====================
  Widget _buildDangerSection(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: _buildListTile(
        icon: PhosphorIconsDuotone.trash,
        iconColor: AppColors.error,
        title: l10n.resetDataDebug,
        titleColor: AppColors.error,
        showArrow: false,
        onTap: _resetAllData,
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildSectionTitle(String title, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: isDestructive ? AppColors.error : AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildCompactInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: highlight ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    Widget? trailing,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? AppColors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing,
              if (showArrow && trailing == null)
                Icon(
                  PhosphorIconsDuotone.caretRight,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: AppColors.cardBorder,
      ),
    );
  }
}
