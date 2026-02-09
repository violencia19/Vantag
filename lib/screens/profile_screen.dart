import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../services/statement_parse_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../providers/finance_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/pro_provider.dart';
import '../providers/pursuit_provider.dart';
import '../services/achievements_service.dart';
import '../services/tour_service.dart';
import '../services/export_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'user_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'splash_screen.dart';
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
            backgroundColor: context.vantColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.exportError}: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.vantColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showProPaywall(AppLocalizations l10n, {String feature = 'export'}) {
    final title = feature == 'import'
        ? l10n.importPremiumOnly
        : l10n.proFeatureExport;
    final subtitle = feature == 'import'
        ? l10n.upgradeForImport
        : l10n.upgradeForExport;

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.vantColors.cardBackground,
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
                      context.vantColors.primary.withValues(alpha: 0.2),
                      context.vantColors.primaryLight.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.star_fill,
                  size: 48,
                  color: context.vantColors.warning,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.vantColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: context.vantColors.textSecondary,
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
                    backgroundColor: context.vantColors.primary,
                    foregroundColor: context.vantColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                  style: TextStyle(color: context.vantColors.textSecondary),
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
    final proProvider = context.read<ProProvider>();

    // Premium check for import
    if (!proProvider.isPro) {
      _showProPaywall(l10n, feature: 'import');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.importError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.vantColors.error,
        ),
      );
      return;
    }

    try {
      // Pick PDF or CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isImporting = true);

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final isPDF = fileName.toLowerCase().endsWith('.pdf');

      // Use AI-powered statement parser for both PDF and CSV
      final parseService = StatementParseService();
      final parseResult = await parseService.parseFile(file);

      if (!mounted) return;

      if (parseResult.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(parseResult.error!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.vantColors.error,
          ),
        );
        return;
      }

      if (parseResult.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importNoTransactions),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.vantColors.warning,
          ),
        );
        return;
      }

      // Show AI parse result
      _showAIParseResult(l10n, parseResult, isPDF);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.importError}: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.vantColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _showAIParseResult(
    AppLocalizations l10n,
    StatementParseResult result,
    bool isPDF,
  ) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.vantColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final selectedItems = ValueNotifier<Set<int>>(
          Set.from(List.generate(result.transactions.length, (i) => i)),
        );
        final isSaving = ValueNotifier<bool>(false);

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SafeArea(
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                    color: context.vantColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPDF
                                ? CupertinoIcons.doc_fill
                                : CupertinoIcons.doc_text_fill,
                            color: context.vantColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.importAIParsed,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: context.vantColors.textPrimary,
                                  ),
                                ),
                                if (result.bankName != null)
                                  Text(
                                    result.bankName!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.vantColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.vantColors.success.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${result.transactions.length} ${l10n.transactions}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.vantColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Select all / none
                      ValueListenableBuilder<Set<int>>(
                        valueListenable: selectedItems,
                        builder: (context, selected, _) => Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                selectedItems.value = Set.from(
                                  List.generate(
                                    result.transactions.length,
                                    (i) => i,
                                  ),
                                );
                              },
                              child: Text(l10n.selectAll),
                            ),
                            TextButton(
                              onPressed: () {
                                selectedItems.value = {};
                              },
                              child: Text(l10n.selectNone),
                            ),
                            const Spacer(),
                            Text(
                              '${selected.length} ${l10n.selected}',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.vantColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(color: context.vantColors.cardBorder),

                // Transaction list
                Expanded(
                  child: ValueListenableBuilder<Set<int>>(
                    valueListenable: selectedItems,
                    builder: (context, selected, _) => ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: result.transactions.length,
                      itemBuilder: (context, index) {
                        final t = result.transactions[index];
                        final isSelected = selected.contains(index);

                        return InkWell(
                          onTap: () {
                            final newSet = Set<int>.from(selected);
                            if (isSelected) {
                              newSet.remove(index);
                            } else {
                              newSet.add(index);
                            }
                            selectedItems.value = newSet;
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.vantColors.primary.withValues(
                                      alpha: 0.1,
                                    )
                                  : context.vantColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? context.vantColors.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Checkbox
                                Icon(
                                  isSelected
                                      ? CupertinoIcons.checkmark_circle_fill
                                      : CupertinoIcons.circle,
                                  color: isSelected
                                      ? context.vantColors.primary
                                      : context.vantColors.textTertiary,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.merchant ?? t.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: context.vantColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            t.category,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context
                                                  .vantColors
                                                  .textSecondary,
                                            ),
                                          ),
                                          Text(
                                            ' • ',
                                            style: TextStyle(
                                              color: context
                                                  .vantColors
                                                  .textTertiary,
                                            ),
                                          ),
                                          Text(
                                            '${t.date.day}/${t.date.month}/${t.date.year}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context
                                                  .vantColors
                                                  .textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Amount
                                Text(
                                  context.read<CurrencyProvider>().formatWithDecimals(t.amount),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: context.vantColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Save button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ValueListenableBuilder<Set<int>>(
                    valueListenable: selectedItems,
                    builder: (context, selected, _) =>
                        ValueListenableBuilder<bool>(
                          valueListenable: isSaving,
                          builder: (context, saving, _) => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: selected.isEmpty || saving
                                  ? null
                                  : () async {
                                      isSaving.value = true;
                                      await _saveAIParsedExpenses(
                                        result.transactions,
                                        selected,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.importSuccess(
                                                selected.length,
                                              ),
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor:
                                                context.vantColors.success,
                                          ),
                                        );
                                      }
                                    },
                              icon: saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      CupertinoIcons.floppy_disk,
                                      size: 20,
                                    ),
                              label: Text(
                                saving
                                    ? l10n.saving
                                    : l10n.importSelected(selected.length),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.vantColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAIParsedExpenses(
    List<ParsedTransaction> transactions,
    Set<int> selectedIndices,
  ) async {
    final financeProvider = context.read<FinanceProvider>();
    final profile = financeProvider.userProfile;

    if (profile == null) return;

    final hourlyRate = profile.hourlyRate;

    for (final index in selectedIndices) {
      final t = transactions[index];

      final hoursRequired = hourlyRate > 0 ? t.amount / hourlyRate : 0.0;
      final daysRequired = hoursRequired / profile.dailyHours;

      final expense = Expense(
        amount: t.amount,
        category: t.category,
        subCategory: t.merchant ?? t.description,
        date: t.date,
        hoursRequired: hoursRequired,
        daysRequired: daysRequired,
        decision: ExpenseDecision.yes,
      );

      await financeProvider.addExpense(expense);
    }
  }

  void _showLanguageSelector() {
    final localeProvider = context.read<LocaleProvider>();
    final currentLocale = Localizations.localeOf(context);

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.vantColors.surface,
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
                  color: context.vantColors.textTertiary,
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
          color: context.vantColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: context.vantColors.primary,
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
      barrierColor: Colors.black.withValues(alpha: 0.85),
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
        barrierColor: Colors.black.withValues(alpha: 0.85),
        builder: (ctx) => Center(
          child: CircularProgressIndicator(color: ctx.vantColors.primary),
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
                backgroundColor: context.vantColors.error,
              ),
            );
          }
          return;
        }

        // 2. Clear ALL local state
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // 3. Reset all providers
        if (mounted) {
          await context.read<FinanceProvider>().resetAllData();
          await context.read<PursuitProvider>().resetAllData();
        }

        if (!mounted) return;

        // Close loading dialog
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteAccountSuccess),
            backgroundColor: context.vantColors.success,
          ),
        );

        // Navigate to splash — same entry point as fresh install
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const VantagSplashScreen()),
          (route) => false,
        );
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.deleteAccountError),
              backgroundColor: context.vantColors.error,
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
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => AlertDialog(
        backgroundColor: context.vantColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                    context.vantColors.warning.withValues(alpha: 0.3),
                    context.vantColors.primary.withValues(alpha: 0.3),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.vantColors.warning.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.smiley,
                  size: 40,
                  color: context.vantColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.achievementUnlocked,
              style: TextStyle(
                fontSize: 14,
                color: context.vantColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.curiousCatTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.vantColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.curiousCatDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.vantColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.vantColors.primary,
                  foregroundColor: context.vantColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
      backgroundColor: context.vantColors.background,
      appBar: AppBar(
        backgroundColor: context.vantColors.background,
        title: Text(
          l10n.profile,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: context.vantColors.textPrimary,
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
          style: TextStyle(fontSize: 12, color: context.vantColors.textTertiary),
        ),
        const SizedBox(height: 20),

        // Info cards in 2x2 grid
        Row(
          children: [
            Expanded(
              child: _buildCompactInfoCard(
                icon: CupertinoIcons.creditcard_fill,
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
                icon: CupertinoIcons.clock_fill,
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
                icon: CupertinoIcons.calendar,
                title: l10n.weeklyWorkingDays,
                value: '${_userProfile.workDaysPerWeek} ${l10n.days}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactInfoCard(
                icon: CupertinoIcons.arrow_up_right,
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
                icon: CupertinoIcons.camera_fill,
                label: l10n.changePhoto,
                onTap: () => _showPhotoOptions(l10n),
              ),
            ),
            const SizedBox(width: 12),
            // Edit Income button
            Expanded(
              child: _buildQuickActionButton(
                icon: CupertinoIcons.creditcard_fill,
                label: l10n.editIncome,
                onTap: _editProfile,
              ),
            ),
            const SizedBox(width: 12),
            // Add Income Source button
            Expanded(
              child: _buildQuickActionButton(
                icon: CupertinoIcons.plus_circle_fill,
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
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: VGlassStyledContainer(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          borderRadius: 16,
          glowColor: highlight ? context.vantColors.primary : null,
          glowIntensity: highlight ? 0.15 : 0.0,
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: highlight
                    ? context.vantColors.primary
                    : context.vantColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: highlight
                      ? context.vantColors.primary
                      : context.vantColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.vantColors.cardBackground,
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
                  CupertinoIcons.camera_fill,
                  color: context.vantColors.primary,
                ),
                title: Text(l10n.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  // ProfilePhotoWidget handles photo capture
                },
              ),
              ListTile(
                leading: Icon(
                  CupertinoIcons.photo_fill,
                  color: context.vantColors.primary,
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

    return VGlassStyledContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Column(
        children: [
          _buildListTile(
            icon: CupertinoIcons.bell_fill,
            iconColor: VantColors.categoryEntertainment,
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
            icon: CupertinoIcons.compass_fill,
            iconColor: VantColors.categoryShopping,
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
            icon: CupertinoIcons.globe,
            iconColor: VantColors.categoryHealth,
            title: l10n.language,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLangName,
                  style: TextStyle(
                    color: context.vantColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: context.vantColors.textTertiary,
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
      icon: CupertinoIcons.money_dollar_circle_fill,
      iconColor: VantColors.achievementStreak,
      title: l10n.currency,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currency.flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            currency.code,
            style: TextStyle(
              color: context.vantColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            CupertinoIcons.chevron_right,
            size: 18,
            color: context.vantColors.textTertiary,
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
      icon: CupertinoIcons.doc_chart_fill,
      iconColor: VantColors.premiumGreen,
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
                color: context.vantColors.primary,
              ),
            )
          else if (!isPro)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.vantColors.primary.withValues(alpha: 0.2),
                    context.vantColors.primaryLight.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.vantColors.primary,
                ),
              ),
            )
          else
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: context.vantColors.textTertiary,
            ),
        ],
      ),
      showArrow: false,
      onTap: _isExporting ? null : _exportToExcel,
    );
  }

  Widget _buildImportTile(AppLocalizations l10n) {
    final proProvider = context.watch<ProProvider>();
    final isPro = proProvider.isPro;

    return _buildListTile(
      icon: CupertinoIcons.arrow_down_circle_fill,
      iconColor: VantColors.categoryEntertainment,
      title: l10n.importStatement,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isImporting)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.vantColors.primary,
              ),
            )
          else if (!isPro)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.vantColors.primary.withValues(alpha: 0.2),
                    context.vantColors.primaryLight.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.vantColors.primary,
                ),
              ),
            )
          else
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: context.vantColors.textTertiary,
            ),
        ],
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

    return VGlassStyledContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Column(
        children: [
          _buildListTile(
            icon: CupertinoIcons.shield_fill,
            iconColor: VantColors.primary,
            title: l10n.privacyPolicy,
            onTap: () => launchUrl(Uri.parse(privacyUrl)),
          ),
          _buildDivider(),
          _buildListTile(
            icon: CupertinoIcons.doc_text_fill,
            iconColor: VantColors.categoryEducation,
            title: l10n.termsOfService,
            onTap: () => launchUrl(Uri.parse(termsUrl)),
          ),
          _buildDivider(),
          _buildListTile(
            icon: CupertinoIcons.info_circle_fill,
            iconColor: VantColors.categoryOther,
            title: l10n.appVersion,
            trailing: Text(
              '1.0.0',
              style: TextStyle(
                color: context.vantColors.textSecondary,
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
    return VGlassStyledContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      glowColor: context.vantColors.error,
      glowIntensity: 0.15,
      child: _buildListTile(
        icon: CupertinoIcons.person_badge_minus_fill,
        iconColor: context.vantColors.error,
        title: l10n.deleteAccount,
        titleColor: context.vantColors.error,
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
          letterSpacing: 1.0,
          color: isDestructive
              ? context.vantColors.error
              : context.vantColors.textTertiary,
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
    return VGlassStyledContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      glowColor: highlight ? context.vantColors.primary : null,
      glowIntensity: highlight ? 0.15 : 0.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: highlight
                    ? context.vantColors.primary
                    : context.vantColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.vantColors.textTertiary,
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
                  ? context.vantColors.primary
                  : context.vantColors.textPrimary,
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
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel ?? title,
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
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
                      color: titleColor ?? context.vantColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
                if (showArrow && trailing == null)
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 18,
                    color: context.vantColors.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: context.vantColors.cardBorder),
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
      backgroundColor: context.vantColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.vantColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: context.vantColors.error,
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
              color: context.vantColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Warning Message
          Text(
            l10n.deleteAccountWarningMessage,
            style: TextStyle(
              fontSize: 14,
              color: context.vantColors.textSecondary,
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
                color: context.vantColors.textTertiary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: context.vantColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.vantColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.vantColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: context.vantColors.error,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              color: context.vantColors.textPrimary,
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
              color: context.vantColors.textTertiary,
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: context.vantColors.textSecondary,
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
                    backgroundColor: context.vantColors.error,
                    foregroundColor: context.vantColors.textPrimary,
                    disabledBackgroundColor: context.vantColors.error.withValues(
                      alpha: 0.3,
                    ),
                    disabledForegroundColor: context.vantColors.textPrimary
                        .withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
