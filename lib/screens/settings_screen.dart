import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/pro_provider.dart';
import '../providers/finance_provider.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../services/purchase_service.dart';
import '../services/notification_service.dart';
import '../services/achievements_service.dart';
import '../theme/theme.dart';
import '../widgets/currency_selector.dart';
import 'paywall_screen.dart';
import 'onboarding_screen.dart';

/// Settings Screen - Replaces Profile in bottom nav
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExporting = false;
  bool _isRestoring = false;
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _remindersEnabled = value);

    if (!value) {
      await NotificationService().cancelAll();
    }

    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proProvider = context.watch<ProProvider>();
    final isPro = proProvider.isPro;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Text(
                  l10n.navSettings,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Growth Section (Invite Friends)
            SliverToBoxAdapter(
              child: _buildGrowthSection(l10n),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // General Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.settingsGeneral,
                children: [
                  _buildCurrencyTile(l10n),
                  _buildDivider(),
                  _buildLanguageTile(l10n),
                  _buildDivider(),
                  _buildThemeTile(l10n),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Notifications Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.settingsNotifications,
                children: [
                  _buildRemindersTile(l10n),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Pro & Purchases Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.settingsProPurchases,
                children: [
                  _buildProTile(l10n, isPro),
                  _buildDivider(),
                  _buildRestorePurchasesTile(l10n),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Data & Privacy Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.settingsDataPrivacy,
                children: [
                  _buildExportTile(l10n, isPro),
                  _buildDivider(),
                  _buildPrivacyPolicyTile(l10n),
                  _buildDivider(),
                  _buildDeleteAccountTile(l10n),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // About Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.settingsAbout,
                children: [
                  _buildVersionTile(l10n),
                  _buildDivider(),
                  _buildContactUsTile(l10n),
                ],
              ),
            ),

            // Debug Section (only in debug mode)
            if (kDebugMode) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _buildDangerZoneSection(l10n),
              ),
            ],

            // Bottom padding for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _shareApp,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  PhosphorIconsDuotone.gift,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsInviteFriends,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.settingsGrowth,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIconsDuotone.caretRight,
                size: 20,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareApp() {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    Share.share(
      '${l10n.settingsInviteMessage}\nhttps://play.google.com/store/apps/details?id=com.vantag.app',
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(children: children),
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
      child: Divider(height: 1, color: AppColors.cardBorder),
    );
  }

  Widget _buildCurrencyTile(AppLocalizations l10n) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final currency = currencyProvider.currency;

    return _buildListTile(
      icon: PhosphorIconsDuotone.currencyCircleDollar,
      iconColor: const Color(0xFFE67E22),
      title: l10n.settingsCurrency,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currency.flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            currency.code,
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
      onTap: () => showCurrencySelector(context),
    );
  }

  Widget _buildLanguageTile(AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLang = localeProvider.locale?.languageCode ?? 'tr';
    final langName = currentLang == 'tr' ? 'Türkçe' : 'English';

    return _buildListTile(
      icon: PhosphorIconsDuotone.translate,
      iconColor: const Color(0xFF3498DB),
      title: l10n.settingsLanguage,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            langName,
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
      onTap: () => _showLanguageSelector(localeProvider, l10n),
    );
  }

  void _showLanguageSelector(LocaleProvider localeProvider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Text('🇹🇷', style: TextStyle(fontSize: 24)),
              title: const Text('Türkçe'),
              trailing: localeProvider.locale?.languageCode == 'tr'
                  ? Icon(PhosphorIconsDuotone.checkCircle, color: AppColors.primary)
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('tr'));
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: localeProvider.locale?.languageCode == 'en'
                  ? Icon(PhosphorIconsDuotone.checkCircle, color: AppColors.primary)
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.moon,
      iconColor: const Color(0xFF9B59B6),
      title: l10n.settingsTheme,
      trailing: Text(
        l10n.settingsThemeDark,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      showArrow: false,
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('More themes coming soon!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.surfaceLight,
          ),
        );
      },
    );
  }

  Widget _buildRemindersTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.bellRinging,
      iconColor: const Color(0xFFF39C12),
      title: l10n.settingsReminders,
      trailing: Switch.adaptive(
        value: _remindersEnabled,
        onChanged: _toggleReminders,
        activeColor: AppColors.primary,
      ),
      showArrow: false,
    );
  }

  Widget _buildProTile(AppLocalizations l10n, bool isPro) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.lightning,
      iconColor: isPro ? const Color(0xFFFFD700) : AppColors.textTertiary,
      title: l10n.settingsVantagPro,
      trailing: isPro
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            )
          : Icon(
              PhosphorIconsDuotone.caretRight,
              size: 18,
              color: AppColors.textTertiary,
            ),
      showArrow: false,
      onTap: () {
        if (isPro) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.proMemberToast),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaywallScreen()),
          );
        }
      },
    );
  }

  Widget _buildRestorePurchasesTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.arrowCounterClockwise,
      iconColor: const Color(0xFF1ABC9C),
      title: l10n.settingsRestorePurchases,
      trailing: _isRestoring
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      showArrow: !_isRestoring,
      onTap: _isRestoring ? null : _restorePurchases,
    );
  }

  Future<void> _restorePurchases() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isRestoring = true);

    try {
      final result = await PurchaseService().restorePurchases();
      final restored = result.isPro ?? false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored ? l10n.settingsRestoreSuccess : l10n.settingsRestoreNone,
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: restored ? AppColors.success : AppColors.surfaceLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  Widget _buildExportTile(AppLocalizations l10n, bool isPro) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.fileXls,
      iconColor: const Color(0xFF27AE60),
      title: l10n.settingsExportData,
      trailing: _isExporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : !isPro
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.secondary.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : null,
      showArrow: !_isExporting && isPro,
      onTap: _isExporting ? null : () => _exportData(isPro),
    );
  }

  Future<void> _exportData(bool isPro) async {
    if (!isPro) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final exportService = ExportService();
      await exportService.exportToExcel(context);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Widget _buildPrivacyPolicyTile(AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final langCode = localeProvider.locale?.languageCode ?? 'tr';
    final privacyUrl = langCode == 'tr'
        ? 'https://violencia19.github.io/Vantag/privacy-tr'
        : 'https://violencia19.github.io/Vantag/privacy-en';

    return _buildListTile(
      icon: PhosphorIconsDuotone.shieldCheck,
      iconColor: const Color(0xFF3498DB),
      title: l10n.settingsPrivacyPolicy,
      onTap: () => launchUrl(Uri.parse(privacyUrl)),
    );
  }

  Widget _buildDeleteAccountTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.userMinus,
      iconColor: AppColors.error,
      title: l10n.deleteAccount,
      titleColor: AppColors.error,
      showArrow: false,
      onTap: () => _deleteAccount(l10n),
    );
  }

  Future<void> _deleteAccount(AppLocalizations l10n) async {
    final confirmWord = l10n.deleteAccountConfirmWord;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      barrierDismissible: false,
      builder: (context) => _DeleteAccountDialog(
        confirmWord: confirmWord,
        l10n: l10n,
      ),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.heavyImpact();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      try {
        final authService = AuthService();
        final result = await authService.deleteAccount();

        if (!result.success) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.errorMessage ?? l10n.deleteAccountError),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (mounted) {
          final provider = context.read<FinanceProvider>();
          await provider.resetAllData();
        }

        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteAccountSuccess),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.deleteAccountError),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildVersionTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.info,
      iconColor: const Color(0xFF95A5A6),
      title: l10n.settingsVersion,
      trailing: Text(
        '1.0.0',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      showArrow: false,
    );
  }

  Widget _buildContactUsTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.envelope,
      iconColor: const Color(0xFFE74C3C),
      title: l10n.settingsContactUs,
      onTap: () => launchUrl(Uri.parse('mailto:support@vantag.app')),
    );
  }

  // ========== DANGER ZONE (DEBUG ONLY) ==========

  Widget _buildDangerZoneSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                const Icon(
                  PhosphorIconsBold.warning,
                  size: 14,
                  color: Colors.amber,
                ),
                const SizedBox(width: 6),
                Text(
                  'DANGER ZONE (DEBUG)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.amber.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                _buildDangerTile(
                  icon: PhosphorIconsBold.trophy,
                  iconColor: Colors.amber,
                  title: '🏆 Tüm Başarıları Aç',
                  subtitle: 'Test için tüm 57 başarıyı anında açar',
                  onTap: () => _showUnlockAllAchievementsDialog(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Colors.amber.withValues(alpha: 0.2)),
                ),
                _buildDangerTile(
                  icon: PhosphorIconsBold.trash,
                  iconColor: Colors.red,
                  title: '🗑️ Başarıları Sıfırla',
                  subtitle: 'Tüm başarı ilerlemesini siler',
                  onTap: () => _showResetAchievementsDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIconsBold.caretRight,
                size: 18,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnlockAllAchievementsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.amber, width: 1),
        ),
        title: const Row(
          children: [
            Icon(PhosphorIconsBold.warning, color: Colors.amber),
            SizedBox(width: 12),
            Text(
              'Debug Mode',
              style: TextStyle(color: Colors.amber),
            ),
          ],
        ),
        content: const Text(
          'Tüm 57 başarı anında açılacak. Bu işlem geri alınamaz.\n\nDevam etmek istiyor musun?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _unlockAllAchievements(context);
            },
            child: const Text('Tümünü Aç'),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockAllAchievements(BuildContext parentContext) async {
    // Navigator referansını önceden al
    final navigator = Navigator.of(parentContext);

    // Loading göster
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      const keyPrefix = 'achievement_unlocked_';

      // Tüm achievement ID'leri (57 adet)
      final allAchievementIds = [
        // STREAK (10)
        'streak_b1', 'streak_b2', 'streak_b3',
        'streak_s1', 'streak_s2', 'streak_s3',
        'streak_g1', 'streak_g2', 'streak_g3',
        'streak_p',
        // SAVINGS (12)
        'savings_b1', 'savings_b2', 'savings_b3',
        'savings_s1', 'savings_s2', 'savings_s3',
        'savings_g1', 'savings_g2', 'savings_g3',
        'savings_p1', 'savings_p2', 'savings_p3',
        // DECISION (10)
        'decision_b1', 'decision_b2', 'decision_b3',
        'decision_s1', 'decision_s2', 'decision_s3',
        'decision_g1', 'decision_g2', 'decision_g3',
        'decision_p',
        // RECORD (10)
        'record_b1', 'record_b2', 'record_b3',
        'record_s1', 'record_s2', 'record_s3',
        'record_g1', 'record_g2', 'record_g3',
        'record_p',
        // HIDDEN (15)
        'hidden_night', 'hidden_early', 'hidden_weekend', 'hidden_first_scan',
        'curious_cat', 'hidden_balanced_week', 'hidden_all_categories',
        'hidden_gold_equiv', 'hidden_usd_equiv', 'hidden_subscriptions',
        'hidden_no_spend_month', 'hidden_gold_kg', 'hidden_usd_10k',
        'hidden_anniversary', 'hidden_early_adopter', 'hidden_ultimate',
        'hidden_collector',
      ];

      int successCount = 0;
      int alreadyUnlocked = 0;
      final now = DateTime.now().toIso8601String();

      for (final achievementId in allAchievementIds) {
        final key = '$keyPrefix$achievementId';
        final existing = prefs.getString(key);

        if (existing == null) {
          await prefs.setString(key, now);
          successCount++;
        } else {
          alreadyUnlocked++;
        }
      }

      if (!mounted) return;
      navigator.pop(); // Loading'i kapat

      // Sonuç göster
      if (mounted) {
        _showResultDialog(
          parentContext,
          successCount: successCount,
          alreadyUnlocked: alreadyUnlocked,
          total: allAchievementIds.length,
        );
      }
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      if (mounted) {
        _showDebugSnackBar(parentContext, 'Hata: $e', isError: true);
      }
    }
  }

  void _showResultDialog(
    BuildContext context, {
    required int successCount,
    required int alreadyUnlocked,
    required int total,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.green, width: 1),
        ),
        title: const Row(
          children: [
            Icon(PhosphorIconsBold.checkCircle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text(
              'Tamamlandı!',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _resultRow('🏆 Toplam Başarı', '$total'),
            const SizedBox(height: 8),
            _resultRow('✅ Yeni Açılan', '$successCount', Colors.green),
            const SizedBox(height: 8),
            _resultRow('🔓 Zaten Açık', '$alreadyUnlocked', Colors.amber),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Harika! 🎉'),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  void _showResetAchievementsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.red, width: 1),
        ),
        title: const Row(
          children: [
            Icon(PhosphorIconsBold.warning, color: Colors.red),
            SizedBox(width: 12),
            Text(
              'Dikkat!',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: const Text(
          'Tüm başarı ilerlemen silinecek.\n\nBu işlem geri alınamaz!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllAchievements(context);
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllAchievements(BuildContext parentContext) async {
    final navigator = Navigator.of(parentContext);

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(color: Colors.red),
      ),
    );

    try {
      final achievementsService = AchievementsService();
      await achievementsService.resetAllAchievements();

      if (!mounted) return;
      navigator.pop();
      if (mounted) {
        _showDebugSnackBar(parentContext, 'Tüm başarılar sıfırlandı!');
      }
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      if (mounted) {
        _showDebugSnackBar(parentContext, 'Hata: $e', isError: true);
      }
    }
  }

  void _showDebugSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

/// Delete Account Confirmation Dialog
class _DeleteAccountDialog extends StatefulWidget {
  final String confirmWord;
  final AppLocalizations l10n;

  const _DeleteAccountDialog({
    required this.confirmWord,
    required this.l10n,
  });

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _textController = TextEditingController();
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_checkConfirmation);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _checkConfirmation() {
    final isConfirmed = _textController.text.trim() == widget.confirmWord;
    if (isConfirmed != _isConfirmed) {
      setState(() => _isConfirmed = isConfirmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              PhosphorIconsDuotone.warning,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.deleteAccountWarningTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.deleteAccountWarningMessage,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: l10n.deleteAccountConfirmPlaceholder,
              hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.error, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '"${widget.confirmWord}"',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isConfirmed ? () => Navigator.pop(context, true) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.error.withValues(alpha: 0.3),
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.deleteAccountButton,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
