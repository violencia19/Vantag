import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../providers/finance_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/pro_provider.dart';
import '../services/achievements_service.dart';
import '../services/tour_service.dart';
import '../services/export_service.dart';
import '../services/import_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'user_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'onboarding_screen.dart';
import 'paywall_screen.dart';

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
  Timer? _easterEggTimer;
  bool _isExporting = false;
  bool _isImporting = false;

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

  @override
  void dispose() {
    _easterEggTimer?.cancel();
    super.dispose();
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
    final monthlyHours =
        _userProfile.dailyHours * _userProfile.workDaysPerWeek * 4;
    if (monthlyHours <= 0) return 0;
    return _userProfile.monthlyIncome / monthlyHours;
  }

  Future<void> _exportToExcel() async {
    final l10n = AppLocalizations.of(context);
    final proProvider = context.read<ProProvider>();

    // Pro kontrolü
    if (!proProvider.isPro) {
      _showProPaywall(l10n);
      return;
    }

    setState(() => _isExporting = true);

    try {
      final exportService = ExportService();
      final file = await exportService.exportToExcel(context);

      if (file != null && mounted) {
        await exportService.shareExcel(file);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportSuccess),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.appColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.exportError}: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.appColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showProPaywall(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.appColors.primary.withValues(alpha: 0.2),
                      context.appColors.secondary.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsDuotone.crown,
                  size: 48,
                  color: context.appColors.warning,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.proFeatureExport,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.upgradeForExport,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaywallScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.primary,
                    foregroundColor: context.appColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.upgradeToPro),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: context.appColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _importFromCSV() async {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.importError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.appColors.error,
        ),
      );
      return;
    }

    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isImporting = true);

      final file = File(result.files.single.path!);
      final importService = ImportService();
      final importResult = await importService.importCSV(file, user.uid);

      if (!mounted) return;

      // Show import summary
      _showImportSummary(l10n, importResult, user.uid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.importError}: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.appColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _showImportSummary(
    AppLocalizations l10n,
    ImportResult result,
    String userId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: context.appColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Text(
                l10n.importSummary,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImportStat(
                    icon: PhosphorIconsDuotone.checkCircle,
                    color: context.appColors.success,
                    count: result.recognized.length,
                    label: l10n.autoMatched,
                  ),
                  _buildImportStat(
                    icon: PhosphorIconsDuotone.warningCircle,
                    color: context.appColors.warning,
                    count: result.needsReviewCount,
                    label: l10n.needsReview,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Errors (if any)
              if (result.errors.isNotEmpty) ...[
                Text(
                  '${result.errors.length} errors during import',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.error,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                children: [
                  // Close button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: context.appColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.close,
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // Review button (if there are pending items)
                  if (result.needsReviewCount > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Open review sheet
                          final allPending = [
                            ...result.suggestions,
                            ...result.pending,
                          ];
                          PendingReviewSheet.show(
                            context,
                            expenses: allPending,
                            userId: userId,
                          );
                        },
                        icon: PhosphorIcon(
                          PhosphorIconsRegular.magnifyingGlass,
                          size: 18,
                        ),
                        label: Text(l10n.startReview),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.primary,
                          foregroundColor: context.appColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportStat({
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(child: PhosphorIcon(icon, size: 28, color: color)),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showLanguageSelector() {
    final localeProvider = context.read<LocaleProvider>();
    final currentLocale = Localizations.localeOf(context);

    showModalBottomSheet(
      context: context,
      barrierColor: context.appColors.background.withValues(alpha: 0.95),
      backgroundColor: context.appColors.surface,
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
                  color: context.appColors.textTertiary,
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
          color: context.appColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(
              PhosphorIconsDuotone.checkCircle,
              color: context.appColors.primary,
            )
          : null,
      onTap: () async {
        Navigator.pop(context);
        await localeProvider.setLocale(locale);
        HapticFeedback.lightImpact();
      },
    );
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final confirmWord = l10n.deleteAccountConfirmWord;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: context.appColors.background.withValues(alpha: 0.95),
      barrierDismissible: false,
      builder: (context) =>
          _DeleteAccountDialog(confirmWord: confirmWord, l10n: l10n),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.heavyImpact();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: context.appColors.background.withValues(alpha: 0.95),
        builder: (ctx) => Center(
          child: CircularProgressIndicator(color: ctx.appColors.primary),
        ),
      );

      try {
        // 1. Delete Firebase account (also deletes Firestore data)
        final authService = AuthService();
        final result = await authService.deleteAccount();

        if (!result.success) {
          if (mounted) {
            Navigator.pop(context); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.errorMessage ?? l10n.deleteAccountError),
                backgroundColor: context.appColors.error,
              ),
            );
          }
          return;
        }

        // 2. Clear SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // 3. Reset local provider data
        if (mounted) {
          final provider = context.read<FinanceProvider>();
          await provider.resetAllData();
        }

        if (!mounted) return;

        // Close loading dialog and navigate
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteAccountSuccess),
            backgroundColor: context.appColors.success,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.deleteAccountError),
              backgroundColor: context.appColors.error,
            ),
          );
        }
      }
    }
  }

  void _onVersionTap() {
    HapticFeedback.lightImpact();

    // Cancel existing timer and start a new one
    _easterEggTimer?.cancel();
    _easterEggTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _easterEggTaps = 0);
    });

    setState(() => _easterEggTaps++);

    // Unlock achievement at 5 taps
    if (_easterEggTaps >= 5) {
      _easterEggTimer?.cancel();
      _unlockCuriousCatAchievement();
    }
  }

  Future<void> _unlockCuriousCatAchievement() async {
    final l10n = AppLocalizations.of(context);
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
      barrierColor: context.appColors.background.withValues(alpha: 0.95),
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.surface,
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
                    context.appColors.warning.withValues(alpha: 0.3),
                    context.appColors.primary.withValues(alpha: 0.3),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.warning.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIconsDuotone.smileyWink,
                  size: 40,
                  color: context.appColors.warning,
                  duotoneSecondaryColor: context.appColors.warning.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.achievementUnlocked,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.curiousCatTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.curiousCatDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.primary,
                  foregroundColor: context.appColors.textPrimary,
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          l10n.profile,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
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
          style: TextStyle(fontSize: 12, color: context.appColors.textTertiary),
        ),
        const SizedBox(height: 20),

        // Info cards in 2x2 grid
        Row(
          children: [
            Expanded(
              child: _buildCompactInfoCard(
                icon: PhosphorIconsDuotone.wallet,
                title: l10n.monthlyIncome,
                value: formatTurkishCurrency(
                  _userProfile.monthlyIncome,
                  decimalDigits: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactInfoCard(
                icon: PhosphorIconsDuotone.clock,
                title: l10n.dailyWork,
                value:
                    '${_userProfile.dailyHours.toStringAsFixed(0)} ${l10n.hours}',
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
                value:
                    '${formatTurkishCurrency(_calculateHourlyWage(), decimalDigits: 2)}/${l10n.hourAbbreviation}',
                highlight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Quick action buttons row
        Row(
          children: [
            // Edit Photo button
            Expanded(
              child: _buildQuickActionButton(
                icon: PhosphorIconsDuotone.camera,
                label: l10n.changePhoto,
                onTap: () => _showPhotoOptions(l10n),
              ),
            ),
            const SizedBox(width: 12),
            // Edit Income button
            Expanded(
              child: _buildQuickActionButton(
                icon: PhosphorIconsDuotone.wallet,
                label: l10n.editIncome,
                onTap: _editProfile,
              ),
            ),
            const SizedBox(width: 12),
            // Add Income Source button
            Expanded(
              child: _buildQuickActionButton(
                icon: PhosphorIconsDuotone.plusCircle,
                label: l10n.addIncome,
                onTap: _editProfile,
                highlight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: highlight
              ? context.appColors.primary.withValues(alpha: 0.15)
              : context.appColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlight
                ? context.appColors.primary.withValues(alpha: 0.3)
                : context.appColors.cardBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: highlight
                  ? context.appColors.primary
                  : context.appColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: highlight
                    ? context.appColors.primary
                    : context.appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  PhosphorIconsDuotone.camera,
                  color: context.appColors.primary,
                ),
                title: Text(l10n.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  // ProfilePhotoWidget handles photo capture
                },
              ),
              ListTile(
                leading: Icon(
                  PhosphorIconsDuotone.image,
                  color: context.appColors.primary,
                ),
                title: Text(l10n.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  // ProfilePhotoWidget handles photo selection
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SETTINGS SECTION ====================
  Widget _buildSettingsSection(AppLocalizations l10n) {
    // Watch locale provider for reactive updates
    final localeProvider = context.watch<LocaleProvider>();
    final currentLangCode =
        localeProvider.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final currentLangName = currentLangCode == 'tr' ? 'Türkçe' : 'English';

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.cardBorder),
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
            ),
            showArrow: false,
            onTap: _showLanguageSelector,
          ),
          _buildDivider(),
          _buildCurrencyTile(l10n),
          _buildDivider(),
          _buildExportTile(l10n),
          _buildDivider(),
          _buildImportTile(l10n),
        ],
      ),
    );
  }

  Widget _buildCurrencyTile(AppLocalizations l10n) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final currency = currencyProvider.currency;

    return _buildListTile(
      icon: PhosphorIconsDuotone.currencyCircleDollar,
      iconColor: const Color(0xFFE67E22),
      title: l10n.currency,
      trailing: Row(
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
      ),
      showArrow: false,
      onTap: () => showCurrencySelector(context),
    );
  }

  Widget _buildExportTile(AppLocalizations l10n) {
    final proProvider = context.watch<ProProvider>();
    final isPro = proProvider.isPro;

    return _buildListTile(
      icon: PhosphorIconsDuotone.fileXls,
      iconColor: const Color(0xFF27AE60),
      title: l10n.exportToExcel,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExporting)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.appColors.primary,
              ),
            )
          else if (!isPro)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.appColors.primary.withValues(alpha: 0.2),
                    context.appColors.secondary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.primary,
                ),
              ),
            )
          else
            Icon(
              PhosphorIconsDuotone.caretRight,
              size: 18,
              color: context.appColors.textTertiary,
            ),
        ],
      ),
      showArrow: false,
      onTap: _isExporting ? null : _exportToExcel,
    );
  }

  Widget _buildImportTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.downloadSimple,
      iconColor: const Color(0xFF3498DB),
      title: l10n.importStatement,
      trailing: _isImporting
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.appColors.primary,
              ),
            )
          : Icon(
              PhosphorIconsDuotone.caretRight,
              size: 18,
              color: context.appColors.textTertiary,
            ),
      showArrow: false,
      onTap: _isImporting ? null : _importFromCSV,
    );
  }

  // ==================== ABOUT SECTION ====================
  Widget _buildAboutSection(AppLocalizations l10n) {
    // Use provider locale or fall back to system locale
    final localeProvider = context.watch<LocaleProvider>();
    final langCode =
        localeProvider.locale?.languageCode ??
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
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.cardBorder),
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
                color: context.appColors.textSecondary,
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
        color: context.appColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.appColors.error.withValues(alpha: 0.4),
        ),
      ),
      child: _buildListTile(
        icon: PhosphorIconsDuotone.userMinus,
        iconColor: context.appColors.error,
        title: l10n.deleteAccount,
        titleColor: context.appColors.error,
        showArrow: false,
        onTap: _deleteAccount,
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
          color: isDestructive
              ? context.appColors.error
              : context.appColors.textTertiary,
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
            ? context.appColors.primary.withValues(alpha: 0.1)
            : context.appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? context.appColors.primary.withValues(alpha: 0.3)
              : context.appColors.cardBorder,
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
                color: highlight
                    ? context.appColors.primary
                    : context.appColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appColors.textTertiary,
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
              color: highlight
                  ? context.appColors.primary
                  : context.appColors.textPrimary,
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
                    color: titleColor ?? context.appColors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing,
              if (showArrow && trailing == null)
                Icon(
                  PhosphorIconsDuotone.caretRight,
                  size: 18,
                  color: context.appColors.textTertiary,
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
      child: Divider(height: 1, color: context.appColors.cardBorder),
    );
  }
}

/// Delete Account Confirmation Dialog
class _DeleteAccountDialog extends StatefulWidget {
  final String confirmWord;
  final AppLocalizations l10n;

  const _DeleteAccountDialog({required this.confirmWord, required this.l10n});

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
      backgroundColor: context.appColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.appColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              PhosphorIconsDuotone.warning,
              color: context.appColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            l10n.deleteAccountWarningTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Warning Message
          Text(
            l10n.deleteAccountWarningMessage,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Confirmation TextField
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: l10n.deleteAccountConfirmPlaceholder,
              hintStyle: TextStyle(
                color: context.appColors.textTertiary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: context.appColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.appColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.appColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: context.appColors.error,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Hint text
          Text(
            '"${widget.confirmWord}"',
            style: TextStyle(
              fontSize: 12,
              color: context.appColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
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
                      color: context.appColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isConfirmed
                      ? () => Navigator.pop(context, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.error,
                    foregroundColor: context.appColors.textPrimary,
                    disabledBackgroundColor: context.appColors.error.withValues(
                      alpha: 0.3,
                    ),
                    disabledForegroundColor: context.appColors.textPrimary.withValues(
                      alpha: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.deleteAccountButton,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
