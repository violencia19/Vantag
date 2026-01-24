import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/simple_mode_service.dart';
import '../../theme/theme.dart';
import '../../widgets/currency_selector.dart';

/// Simple Mode - Settings Screen (minimal)
class SimpleSettingsScreen extends StatefulWidget {
  const SimpleSettingsScreen({super.key});

  @override
  State<SimpleSettingsScreen> createState() => _SimpleSettingsScreenState();
}

class _SimpleSettingsScreenState extends State<SimpleSettingsScreen> {
  bool _simpleModeEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await simpleModeService.initialize();
    setState(() {
      _simpleModeEnabled = simpleModeService.isEnabled;
    });
  }

  Future<void> _toggleSimpleMode(bool value) async {
    await simpleModeService.setEnabled(value);
    setState(() => _simpleModeEnabled = value);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.simpleSettings,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),

            // Settings List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Currency
                  _buildSettingTile(
                    icon: PhosphorIconsDuotone.currencyCircleDollar,
                    iconColor: AppColors.achievementStreak,
                    title: l10n.settingsCurrency,
                    trailing: _buildCurrencyTrailing(),
                    onTap: () => showCurrencySelector(context),
                  ),

                  const SizedBox(height: 8),

                  // Language
                  _buildSettingTile(
                    icon: PhosphorIconsDuotone.translate,
                    iconColor: AppColors.categoryEntertainment,
                    title: l10n.settingsLanguage,
                    trailing: _buildLanguageTrailing(),
                    onTap: () => _showLanguageSelector(),
                  ),

                  const SizedBox(height: 8),

                  // Theme
                  _buildSettingTile(
                    icon: PhosphorIconsDuotone.moon,
                    iconColor: AppColors.categoryShopping,
                    title: l10n.settingsTheme,
                    trailing: _buildThemeTrailing(),
                    onTap: () => _showThemeSelector(),
                  ),

                  const SizedBox(height: 24),

                  // Simple Mode Toggle
                  _buildSettingTile(
                    icon: PhosphorIconsDuotone.leaf,
                    iconColor: AppColors.premiumGreen,
                    title: l10n.simpleMode,
                    subtitle: l10n.simpleModeDescription,
                    trailing: Switch.adaptive(
                      value: _simpleModeEnabled,
                      onChanged: _toggleSimpleMode,
                      activeTrackColor: context.appColors.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info text
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l10n.simpleModeHint,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.appColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
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
                          fontWeight: FontWeight.w500,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyTrailing() {
    final currencyProvider = context.watch<CurrencyProvider>();
    final currency = currencyProvider.currency;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(currency.flag, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          currency.code,
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          PhosphorIconsDuotone.caretRight,
          size: 18,
          color: context.appColors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildLanguageTrailing() {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLang = localeProvider.locale?.languageCode ?? 'tr';
    final langName = currentLang == 'tr' ? 'Turkce' : 'English';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          langName,
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          PhosphorIconsDuotone.caretRight,
          size: 18,
          color: context.appColors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildThemeTrailing() {
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);

    String themeName;
    switch (themeProvider.themeMode) {
      case AppThemeMode.dark:
        themeName = l10n.settingsThemeDark;
        break;
      case AppThemeMode.light:
        themeName = l10n.settingsThemeLight;
        break;
      case AppThemeMode.system:
        themeName = l10n.settingsThemeSystem;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          themeName,
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          PhosphorIconsDuotone.caretRight,
          size: 18,
          color: context.appColors.textTertiary,
        ),
      ],
    );
  }

  void _showLanguageSelector() {
    final localeProvider = context.read<LocaleProvider>();

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.appColors.surface,
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
                color: context.appColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Text('🇹🇷', style: TextStyle(fontSize: 24)),
              title: const Text('Turkce'),
              trailing: localeProvider.locale?.languageCode == 'tr'
                  ? Icon(
                      PhosphorIconsDuotone.checkCircle,
                      color: context.appColors.primary,
                    )
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
                  ? Icon(
                      PhosphorIconsDuotone.checkCircle,
                      color: context.appColors.primary,
                    )
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

  void _showThemeSelector() {
    final themeProvider = context.read<ThemeProvider>();
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.appColors.surface,
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
                color: context.appColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                PhosphorIconsDuotone.moon,
                color: context.appColors.textPrimary,
              ),
              title: Text(l10n.settingsThemeDark),
              trailing: themeProvider.themeMode == AppThemeMode.dark
                  ? Icon(
                      PhosphorIconsDuotone.checkCircle,
                      color: context.appColors.primary,
                    )
                  : null,
              onTap: () {
                themeProvider.setThemeMode(AppThemeMode.dark);
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            ListTile(
              leading: Icon(
                PhosphorIconsDuotone.sun,
                color: context.appColors.textPrimary,
              ),
              title: Text(l10n.settingsThemeLight),
              trailing: themeProvider.themeMode == AppThemeMode.light
                  ? Icon(
                      PhosphorIconsDuotone.checkCircle,
                      color: context.appColors.primary,
                    )
                  : null,
              onTap: () {
                themeProvider.setThemeMode(AppThemeMode.light);
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            ListTile(
              leading: Icon(
                PhosphorIconsDuotone.deviceMobile,
                color: context.appColors.textPrimary,
              ),
              title: Text(l10n.settingsThemeSystem),
              trailing: themeProvider.themeMode == AppThemeMode.system
                  ? Icon(
                      PhosphorIconsDuotone.checkCircle,
                      color: context.appColors.primary,
                    )
                  : null,
              onTap: () {
                themeProvider.setThemeMode(AppThemeMode.system);
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
}
