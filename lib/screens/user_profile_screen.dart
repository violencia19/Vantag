import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../models/currency.dart';
import '../services/services.dart';
import '../services/referral_service.dart';
import '../services/deep_link_service.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../widgets/currency_selector.dart';
import '../theme/theme.dart';
import 'income_wizard_screen.dart';
import 'onboarding_try_screen.dart';
import 'paywall_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final UserProfile? existingProfile;

  const UserProfileScreen({super.key, this.existingProfile});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _incomeController = TextEditingController();
  final _dailyHoursController = TextEditingController();
  final _budgetController = TextEditingController();
  final _savingsGoalController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _profileService = ProfileService();
  final _authService = AuthService();
  final _referralService = ReferralService();
  int _workDaysPerWeek = 6;
  bool _isSaving = false;
  bool _isLinkingGoogle = false;
  List<IncomeSource> _incomeSources = [];
  bool _hasPrefilledReferral = false;

  bool get _isEditMode => widget.existingProfile != null;
  bool get _hasIncomeSources => _incomeSources.isNotEmpty;
  double get _totalIncome =>
      _incomeSources.fold<double>(0, (sum, s) => sum + s.amount);

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.appColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.appColors.success,
      ),
    );
  }

  /// Google hesabını bağla
  Future<void> _linkWithGoogle() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLinkingGoogle = true);

    try {
      final result = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (result.success) {
        HapticFeedback.mediumImpact();
        _showSuccess(l10n.googleLinkedSuccess);

        // Refresh Pro status after Google Sign-In (links RevenueCat + checks promo)
        if (mounted) {
          await context.read<ProProvider>().onUserLogin();
        }

        setState(() {}); // UI'ı yenile
      } else {
        _showError(result.errorMessage ?? l10n.error);
      }
    } catch (e) {
      if (mounted) {
        _showError('${l10n.error}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLinkingGoogle = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _incomeSources = List.from(widget.existingProfile!.incomeSources);
      _dailyHoursController.text = widget.existingProfile!.dailyHours
          .toString();
      _workDaysPerWeek = widget.existingProfile!.workDaysPerWeek;

      // Eğer varolan gelirler varsa, toplam geliri göster
      if (_incomeSources.isNotEmpty) {
        _incomeController.text = formatTurkishCurrency(
          widget.existingProfile!.monthlyIncome,
          decimalDigits: 0,
          showDecimals: false,
        );
      }

      // Bütçe değerlerini doldur
      if (widget.existingProfile!.monthlyBudget != null) {
        _budgetController.text = formatTurkishCurrency(
          widget.existingProfile!.monthlyBudget!,
          decimalDigits: 0,
          showDecimals: false,
        );
      }
      if (widget.existingProfile!.monthlySavingsGoal != null) {
        _savingsGoalController.text = formatTurkishCurrency(
          widget.existingProfile!.monthlySavingsGoal!,
          decimalDigits: 0,
          showDecimals: false,
        );
      }
    } else {
      // New user - check for pending referral code from deep link
      _checkPendingReferralCode();
      // Set default currency based on locale
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setDefaultCurrencyFromLocale();
      });
    }
  }

  /// Set default currency based on device locale
  void _setDefaultCurrencyFromLocale() {
    final locale = Localizations.localeOf(context);
    final currencyProvider = context.read<CurrencyProvider>();

    // Map locale to currency code
    String currencyCode;
    switch (locale.countryCode?.toUpperCase() ??
        locale.languageCode.toUpperCase()) {
      case 'TR':
        currencyCode = 'TRY';
        break;
      case 'US':
        currencyCode = 'USD';
        break;
      case 'GB':
      case 'UK':
        currencyCode = 'GBP';
        break;
      case 'SA':
      case 'AE': // UAE also uses similar currency
        currencyCode = 'SAR';
        break;
      case 'DE':
      case 'FR':
      case 'IT':
      case 'ES':
      case 'NL':
      case 'BE':
      case 'AT':
      case 'PT':
      case 'GR':
      case 'IE':
      case 'FI':
        currencyCode = 'EUR';
        break;
      default:
        // Default to TRY for Turkish language, USD otherwise
        currencyCode = locale.languageCode == 'tr' ? 'TRY' : 'USD';
    }

    // Find the currency and set it
    final targetCurrency = supportedCurrencies.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => supportedCurrencies.first, // Fallback to TRY
    );

    // Only set if different from current
    if (currencyProvider.currency.code != targetCurrency.code) {
      currencyProvider.setCurrency(targetCurrency);
    }
  }

  Future<void> _checkPendingReferralCode() async {
    final pendingCode = await DeepLinkService.getPendingReferralCode();
    if (pendingCode != null && pendingCode.isNotEmpty && mounted) {
      setState(() {
        _referralCodeController.text = pendingCode;
        _hasPrefilledReferral = true;
      });
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _dailyHoursController.dispose();
    _budgetController.dispose();
    _savingsGoalController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  /// Gelir wizard'ını aç
  Future<void> _openIncomeWizard() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            IncomeWizardScreen(existingSources: _incomeSources),
      ),
    );

    // Wizard kapandıktan sonra Provider'dan güncel veriyi al
    if (mounted) {
      final provider = context.read<FinanceProvider>();
      final profile = provider.userProfile;
      if (profile != null) {
        setState(() {
          _incomeSources = profile.incomeSources;
          _incomeController.text = formatTurkishCurrency(
            _totalIncome,
            decimalDigits: 0,
            showDecimals: false,
          );
        });
        HapticFeedback.lightImpact();
      }
    }
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context);
    final dailyHours = double.tryParse(_dailyHoursController.text);

    // Gelir kontrolü
    if (_incomeSources.isEmpty) {
      // Eğer manuel gelir girilmişse onu kullan
      final manualIncome = parseAmount(_incomeController.text);
      if (manualIncome == null || manualIncome <= 0) {
        _showError(l10n.error);
        return;
      }
      // Manuel geliri primary income olarak ekle
      _incomeSources = [
        IncomeSource.salary(amount: manualIncome, title: l10n.mainSalary),
      ];
    }

    // Çalışma saati validasyonu
    if (dailyHours == null || dailyHours <= 0) {
      _showError(l10n.error);
      return;
    }

    if (dailyHours > 24) {
      _showError(l10n.error);
      return;
    }

    if (dailyHours > 16) {
      _showError(l10n.error);
      return;
    }

    // Yeni kullanıcı için Google bağlantı popup'ı göster
    if (!_isEditMode && !_authService.isLinkedWithGoogle) {
      final shouldLink = await _showGoogleLinkDialog(l10n);
      if (shouldLink == true) {
        await _linkWithGoogle();
      }
    }

    if (!mounted) return;

    setState(() => _isSaving = true);

    // Bütçe değerlerini parse et
    final budget = parseTurkishCurrency(_budgetController.text);
    final savingsGoal = parseTurkishCurrency(_savingsGoalController.text);

    final profile = UserProfile(
      incomeSources: _incomeSources,
      dailyHours: dailyHours,
      workDaysPerWeek: _workDaysPerWeek,
      monthlyBudget: budget,
      monthlySavingsGoal: savingsGoal,
    );

    await _profileService.saveProfile(profile);

    if (!mounted) return;

    // FinanceProvider'ı güncelle
    final financeProvider = context.read<FinanceProvider>();
    financeProvider.setUserProfile(profile);

    // Apply referral code if provided (new users only)
    if (!_isEditMode) {
      final referralCode = _referralCodeController.text.trim().toUpperCase();
      if (referralCode.isNotEmpty) {
        final result = await _referralService.applyReferralCode(referralCode);
        if (result.success && mounted) {
          // Clear the pending referral code
          await DeepLinkService.clearPendingReferralCode();
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.welcomeReferred),
              backgroundColor: context.appColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    HapticFeedback.mediumImpact();

    if (_isEditMode) {
      Navigator.pop(context, profile);
    } else {
      // Go to "Aha Moment" try screen before main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingTryScreen()),
      );
    }
  }

  /// Google bağlantı dialog'unu göster
  Future<bool?> _showGoogleLinkDialog(AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.appColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                PhosphorIconsDuotone.link,
                color: context.appColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.linkWithGoogleTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.linkWithGoogleDescription,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.textPrimary,
                  foregroundColor: context.appColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  elevation: 0,
                ),
                icon: Image.network(
                  'https://www.google.com/favicon.ico',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    PhosphorIconsDuotone.globe,
                    size: 20,
                    color: Colors.blue,
                  ),
                ),
                label: Text(
                  l10n.linkWithGoogle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                l10n.skipForNow,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
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
      appBar: _isEditMode
          ? AppBar(
              backgroundColor: context.appColors.background,
              leading: IconButton(
                icon: Icon(
                  PhosphorIconsDuotone.arrowLeft,
                  color: context.appColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                l10n.editProfile,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isEditMode) ...[
                  const SizedBox(height: 48),
                  // Welcome header
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      PhosphorIconsDuotone.user,
                      size: 32,
                      color: context.appColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.welcome,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.welcomeSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.appColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Currency Selection Section (for new users)
                  _buildCurrencySection(l10n),
                  const SizedBox(height: 32),
                ] else ...[
                  const SizedBox(height: 24),
                ],

                // Gelir Bölümü
                _buildIncomeSection(l10n),
                const SizedBox(height: 32),

                // Çalışma Saati
                LabeledTextField(
                  controller: _dailyHoursController,
                  label: l10n.dailyWorkHours,
                  keyboardType: TextInputType.number,
                  hint: '8',
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      l10n.hours,
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Çalışma Günü
                Text(
                  l10n.weeklyWorkDays,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Work days selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.appColors.cardBorder),
                  ),
                  child: Row(
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final isSelected = _workDaysPerWeek == day;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _workDaysPerWeek = day),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.appColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$day',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? context.appColors.background
                                    : context.appColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.workingDaysPerWeek(_workDaysPerWeek),
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColors.textTertiary,
                  ),
                ),

                const SizedBox(height: 32),

                // Ek Gelir Bölümü
                _buildAdditionalIncomeSection(l10n),

                const SizedBox(height: 32),

                // Bütçe Ayarları Bölümü
                _buildBudgetSection(l10n),

                // Referral Code Section (only for new users)
                if (!_isEditMode) ...[
                  const SizedBox(height: 32),
                  _buildReferralCodeSection(l10n),
                ],

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.primary,
                      foregroundColor: context.appColors.background,
                      disabledBackgroundColor: context.appColors.primary
                          .withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.appColors.background,
                              ),
                            ),
                          )
                        : Text(
                            _isEditMode ? l10n.save : l10n.getStarted,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ek Gelir bölümü
  Widget _buildAdditionalIncomeSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.additionalIncomeQuestion,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              // 1. Önce mevcut maaş değerini al
              final currentSalary = parseAmount(_incomeController.text);

              // 2. Eğer maaş girilmişse ve henüz _incomeSources'ta yoksa, ekle
              if (currentSalary != null && currentSalary > 0) {
                final hasPrimary = _incomeSources.any((s) => s.isPrimary);
                if (!hasPrimary) {
                  // Yeni maaş ekle
                  _incomeSources.insert(
                    0,
                    IncomeSource.salary(
                      amount: currentSalary,
                      title: l10n.mainSalary,
                    ),
                  );
                } else {
                  // Mevcut primary income'u güncelle
                  final primaryIndex = _incomeSources.indexWhere(
                    (s) => s.isPrimary,
                  );
                  if (primaryIndex >= 0) {
                    _incomeSources[primaryIndex] = _incomeSources[primaryIndex]
                        .copyWith(amount: currentSalary);
                  }
                }
              }

              // 3. Sonra IncomeWizardScreen'e git
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IncomeWizardScreen(
                    existingSources: _incomeSources,
                    skipToAdditional: true,
                  ),
                ),
              );

              // Wizard kapandıktan sonra Provider'dan güncel veriyi al
              if (mounted) {
                final provider = context.read<FinanceProvider>();
                final profile = provider.userProfile;
                if (profile != null) {
                  setState(() {
                    _incomeSources = profile.incomeSources;
                    _incomeController.text = formatTurkishCurrency(
                      _totalIncome,
                      decimalDigits: 0,
                      showDecimals: false,
                    );
                  });
                  HapticFeedback.lightImpact();
                }
              }
            },
            icon: Icon(PhosphorIconsDuotone.plusCircle, size: 20),
            label: Text(l10n.addAdditionalIncome),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.appColors.primary,
              side: BorderSide(
                color: context.appColors.primary.withValues(alpha: 0.5),
              ),
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

  /// Bütçe Ayarları bölümü
  Widget _buildBudgetSection(AppLocalizations l10n) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        Row(
          children: [
            Icon(
              PhosphorIconsDuotone.chartPieSlice,
              color: context.appColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.budgetSettings,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.budgetSettingsHint,
          style: TextStyle(color: context.appColors.textTertiary, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Aylık bütçe
        Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.appColors.cardBorder),
          ),
          child: TextField(
            controller: _budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [TurkishCurrencyInputFormatter()],
            style: TextStyle(
              fontSize: 16,
              color: context.appColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: l10n.monthlySpendingLimit,
              labelStyle: TextStyle(color: context.appColors.textSecondary),
              hintText: '30.000',
              hintStyle: TextStyle(
                color: context.appColors.textTertiary.withValues(alpha: 0.5),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  PhosphorIconsDuotone.wallet,
                  color: context.appColors.secondary,
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixText: currencyProvider.code,
              suffixStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.appColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.monthlySpendingLimitHint,
          style: TextStyle(color: context.appColors.textTertiary, fontSize: 12),
        ),

        const SizedBox(height: 16),

        // Tasarruf hedefi
        Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.appColors.cardBorder),
          ),
          child: TextField(
            controller: _savingsGoalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [TurkishCurrencyInputFormatter()],
            style: TextStyle(
              fontSize: 16,
              color: context.appColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: l10n.monthlySavingsGoal,
              labelStyle: TextStyle(color: context.appColors.textSecondary),
              hintText: '5.000',
              hintStyle: TextStyle(
                color: context.appColors.textTertiary.withValues(alpha: 0.5),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  PhosphorIconsDuotone.piggyBank,
                  color: context.appColors.success,
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixText: currencyProvider.code,
              suffixStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.appColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.monthlySavingsGoalHint,
          style: TextStyle(color: context.appColors.textTertiary, fontSize: 12),
        ),

        // Bilgi kartı
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.appColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.appColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                PhosphorIconsDuotone.lightbulb,
                color: context.appColors.info,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.budgetInfoMessage,
                  style: TextStyle(color: context.appColors.info, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Referral code input section (for new users)
  Widget _buildReferralCodeSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.haveReferralCode,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hasPrefilledReferral
                  ? context.appColors.success.withValues(alpha: 0.5)
                  : context.appColors.cardBorder,
            ),
          ),
          child: TextField(
            controller: _referralCodeController,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: context.appColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: l10n.referralCodePlaceholder,
              hintStyle: TextStyle(
                color: context.appColors.textSecondary.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  PhosphorIconsDuotone.gift,
                  color: _hasPrefilledReferral
                      ? context.appColors.success
                      : context.appColors.secondary,
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: _hasPrefilledReferral
                  ? Icon(
                      PhosphorIconsBold.checkCircle,
                      color: context.appColors.success,
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.referralCodeHint,
          style: TextStyle(color: context.appColors.textTertiary, fontSize: 12),
        ),
      ],
    );
  }

  /// Show onboarding currency selector (all currencies available, no restrictions)
  void _showOnboardingCurrencySelector() {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.read<CurrencyProvider>();

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.appColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.selectCurrency,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
              // Note about currency lock
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.appColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIconsDuotone.info,
                        size: 16,
                        color: context.appColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.currencyLockNote,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Currency options - ALL available during onboarding
              ...supportedCurrencies.map((currency) {
                final isSelected =
                    currencyProvider.currency.code == currency.code;

                return ListTile(
                  leading: Text(
                    currency.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Row(
                    children: [
                      Text(
                        currency.code,
                        style: TextStyle(
                          color: context.appColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currency.symbol,
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    currency.name,
                    style: TextStyle(
                      color: context.appColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          PhosphorIconsDuotone.checkCircle,
                          color: context.appColors.primary,
                        )
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await currencyProvider.setCurrency(currency);
                    HapticFeedback.lightImpact();
                    setState(() {});
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Currency selection section for new users
  Widget _buildCurrencySection(AppLocalizations l10n) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final currentCurrency = currencyProvider.currency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectCurrency,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showOnboardingCurrencySelector,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appColors.cardBorder),
            ),
            child: Row(
              children: [
                Text(
                  currentCurrency.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            currentCurrency.code,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentCurrency.symbol,
                            style: TextStyle(
                              fontSize: 16,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentCurrency.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIconsDuotone.caretDown,
                  size: 20,
                  color: context.appColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        // Note about currency lock (shown during onboarding)
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              PhosphorIconsDuotone.info,
              size: 14,
              color: context.appColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.currencyLockNote,
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Gelir bölümü widget'ı
  Widget _buildIncomeSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.incomeInfo,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Eğer gelir kaynakları varsa, özet göster
        if (_hasIncomeSources) ...[
          _buildIncomeSourcesSummary(l10n),
        ] else ...[
          // Basit gelir girişi
          _buildSimpleIncomeInput(),
        ],
      ],
    );
  }

  /// Basit gelir girişi (wizard kullanılmadıysa)
  Widget _buildSimpleIncomeInput() {
    final currencyProvider = context.watch<CurrencyProvider>();
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: TextField(
        controller: _incomeController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [TurkishCurrencyInputFormatter()],
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: context.appColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '25.000',
          hintStyle: TextStyle(
            color: context.appColors.textSecondary.withValues(alpha: 0.5),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              PhosphorIconsDuotone.wallet,
              color: context.appColors.primary,
              size: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixText: currencyProvider.code,
          suffixStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  /// Gelir kaynakları özeti
  Widget _buildIncomeSourcesSummary(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _openIncomeWizard,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.appColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            // Toplam
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.appColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        PhosphorIconsDuotone.wallet,
                        color: context.appColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.totalIncome,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${formatTurkishCurrency(_totalIncome, decimalDigits: 0, showDecimals: false)} TL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.incomeSources(_incomeSources.length),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            // Kaynak listesi (kısa özet)
            if (_incomeSources.length <= 3) ...[
              const SizedBox(height: 16),
              Divider(height: 1, color: context.appColors.cardBorder),
              const SizedBox(height: 12),
              ...(_incomeSources.map(
                (source) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        source.category.icon,
                        size: 18,
                        color: source.category.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          source.title,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.appColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${formatTurkishCurrency(source.amount, decimalDigits: 0, showDecimals: false)} TL',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
