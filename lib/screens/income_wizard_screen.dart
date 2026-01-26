import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';
import '../widgets/multi_currency_pro_sheet.dart';

/// Step-by-step income entry wizard
/// Premium UX with multiple income source support
class IncomeWizardScreen extends StatefulWidget {
  final UserProfile? existingProfile;
  final List<IncomeSource>? existingSources;
  final bool isEditing;

  /// If true, skips salary step and goes directly to additional income form
  final bool skipToAdditional;

  const IncomeWizardScreen({
    super.key,
    this.existingProfile,
    this.existingSources,
    this.isEditing = false,
    this.skipToAdditional = false,
  });

  @override
  State<IncomeWizardScreen> createState() => _IncomeWizardScreenState();
}

class _IncomeWizardScreenState extends State<IncomeWizardScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _salaryController = TextEditingController();
  final _additionalAmountController = TextEditingController();
  final _additionalTitleController = TextEditingController();
  final _hoursController = TextEditingController();
  final _pageController = PageController();

  // State
  int _currentStep = 0;
  List<IncomeSource> _incomeSources = [];
  IncomeCategory? _selectedCategory;
  double _dailyHours = 8.0;
  int _workDaysPerWeek = 5;
  bool _isLoading = false;

  // Currency selection - primary and additional
  String _primaryCurrencyCode = 'TRY';
  String _additionalCurrencyCode = 'TRY';

  // Animation
  late AnimationController _fadeController;

  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider'a erişim için didChangeDependencies kullan (sadece 1 kez)
    if (!_isDataLoaded) {
      _isDataLoaded = true;
      _loadExistingData();

      // skipToAdditional true ise, direkt ek gelir adımına atla
      if (widget.skipToAdditional) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _currentStep = 2);
            _pageController.jumpToPage(2);
          }
        });
      }
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeController.forward();
  }

  void _loadExistingData() {
    // Auto-detect currency from device locale
    final systemLocale = PlatformDispatcher.instance.locale;
    final defaultCurrency = getDefaultCurrencyForLocale(
      systemLocale.languageCode,
    );
    _primaryCurrencyCode = defaultCurrency.code;
    _additionalCurrencyCode = defaultCurrency.code;

    // Provider'dan güncel veriyi al (en güvenilir kaynak)
    final provider = context.read<FinanceProvider>();
    final providerProfile = provider.userProfile;

    if (providerProfile != null && providerProfile.incomeSources.isNotEmpty) {
      // Provider'da veri var - onu kullan
      _incomeSources = List.from(providerProfile.incomeSources);
      _dailyHours = providerProfile.dailyHours;
      _workDaysPerWeek = providerProfile.workDaysPerWeek;
      _hoursController.text = _dailyHours.toStringAsFixed(0);

      // Ana maaşı bul
      final primary = providerProfile.primarySource;
      if (primary != null) {
        _salaryController.text = formatTurkishCurrency(
          primary.amount,
          decimalDigits: 0,
          showDecimals: false,
        );
        // Load existing currency from primary income
        _primaryCurrencyCode = primary.currencyCode;
        _additionalCurrencyCode = primary.currencyCode;
      }
    }
    // Fallback: widget parametrelerini kontrol et
    else if (widget.existingSources != null &&
        widget.existingSources!.isNotEmpty) {
      _incomeSources = List.from(widget.existingSources!);

      // Ana maaşı bul
      final primary = _incomeSources.where((s) => s.isPrimary).firstOrNull;
      if (primary != null) {
        _salaryController.text = formatTurkishCurrency(
          primary.amount,
          decimalDigits: 0,
          showDecimals: false,
        );
        _primaryCurrencyCode = primary.currencyCode;
        _additionalCurrencyCode = primary.currencyCode;
      }
    } else if (widget.existingProfile != null) {
      final profile = widget.existingProfile!;
      _incomeSources = List.from(profile.incomeSources);
      _dailyHours = profile.dailyHours;
      _workDaysPerWeek = profile.workDaysPerWeek;
      _hoursController.text = _dailyHours.toStringAsFixed(0);

      // Ana maaşı bul
      final primary = profile.primarySource;
      if (primary != null) {
        _salaryController.text = formatTurkishCurrency(
          primary.amount,
          decimalDigits: 0,
          showDecimals: false,
        );
        _primaryCurrencyCode = primary.currencyCode;
        _additionalCurrencyCode = primary.currencyCode;
      }
    } else {
      _hoursController.text = '8';
    }
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _additionalAmountController.dispose();
    _additionalTitleController.dispose();
    _hoursController.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _saveSalary() async {
    final l10n = AppLocalizations.of(context);
    final amount = parseAmount(_salaryController.text);
    if (amount == null || amount <= 0) {
      _showError(l10n.pleaseEnterValidSalary);
      return;
    }

    // Mevcut primary income'u güncelle veya yeni oluştur
    final existingPrimaryIndex = _incomeSources.indexWhere((s) => s.isPrimary);

    if (existingPrimaryIndex >= 0) {
      _incomeSources[existingPrimaryIndex] =
          _incomeSources[existingPrimaryIndex].copyWith(
            amount: amount,
            currencyCode: _primaryCurrencyCode,
          );
    } else {
      _incomeSources.insert(
        0,
        IncomeSource.salary(
          amount: amount,
          title: l10n.mainSalary,
          currencyCode: _primaryCurrencyCode,
        ),
      );
    }

    // Set additional income default currency to primary currency
    _additionalCurrencyCode = _primaryCurrencyCode;

    HapticFeedback.lightImpact();
    _nextStep();
  }

  void _addAdditionalIncome() {
    final l10n = AppLocalizations.of(context);
    final amount = parseAmount(_additionalAmountController.text);
    final title = _additionalTitleController.text.trim();

    if (amount == null || amount <= 0) {
      _showError(l10n.pleaseEnterValidIncomeAmount);
      return;
    }

    if (_selectedCategory == null) {
      _showError(l10n.pleaseSelectCategory);
      return;
    }

    final source = IncomeSource.additional(
      title: title.isEmpty ? _selectedCategory!.getLocalizedLabel(l10n) : title,
      amount: amount,
      category: _selectedCategory!,
      currencyCode: _additionalCurrencyCode,
    );

    setState(() {
      _incomeSources.add(source);
      _additionalAmountController.clear();
      _additionalTitleController.clear();
      _selectedCategory = null;
      // Reset additional currency to primary for next entry
      _additionalCurrencyCode = _primaryCurrencyCode;
    });

    HapticFeedback.mediumImpact();
  }

  void _removeIncome(String id) {
    setState(() {
      _incomeSources.removeWhere((s) => s.id == id);
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _complete() async {
    final l10n = AppLocalizations.of(context);
    // Double-tap protection
    if (_isLoading) return;

    // Get work hours
    final hours = double.tryParse(_hoursController.text) ?? 8.0;

    if (_incomeSources.isEmpty) {
      _showError(l10n.atLeastOneIncomeRequired);
      return;
    }

    setState(() => _isLoading = true);

    // Capture context before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<FinanceProvider>();

    try {
      // Save income sources (auto persists)
      await provider.setIncomeSources(_incomeSources);

      // Save work hours (auto persists)
      await provider.updateWorkSchedule(
        dailyHours: hours,
        workDaysPerWeek: _workDaysPerWeek,
      );

      // Save base currency from primary income (for FREE user currency lock)
      final primarySource = _incomeSources
          .where((s) => s.isPrimary)
          .firstOrNull;
      if (primarySource != null && provider.userProfile?.baseCurrency == null) {
        await provider.setBaseCurrency(primarySource.currencyCode);
      }

      // Mounted check after async
      if (!mounted) return;

      HapticFeedback.heavyImpact();

      // Success message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                PhosphorIconsDuotone.checkCircle,
                color: context.appColors.textPrimary,
              ),
              const SizedBox(width: 12),
              Text(widget.isEditing ? l10n.incomesUpdated : l10n.incomesSaved),
            ],
          ),
          backgroundColor: context.appColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigator - data already saved in Provider, just go back
      navigator.pop();
    } catch (e) {
      // Show error only if there's a real error
      if (mounted) {
        _showError(l10n.saveError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.appColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Currency selector widget - reusable for primary and additional income
  /// [isAdditionalIncome] - if true, FREE users see lock icon
  Widget _buildCurrencySelector({
    required String currencyCode,
    required Function(String) onChanged,
    bool isAdditionalIncome = false,
  }) {
    final currency = getCurrencyByCode(currencyCode);
    final l10n = AppLocalizations.of(context);
    final isPro = context.watch<ProProvider>().isPro;

    // FREE users can't change currency for additional income
    final isLocked = isAdditionalIncome && !isPro;

    return Semantics(
      button: true,
      label: l10n.selectCurrency,
      child: GestureDetector(
        onTap: () {
          if (isLocked) {
            MultiCurrencyProSheet.show(context);
          } else {
            _showCurrencyPicker(currencyCode, onChanged);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLocked
                  ? context.appColors.textTertiary.withValues(alpha: 0.3)
                  : context.appColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(currency.flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                '${currency.code} - ${currency.name}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isLocked
                      ? context.appColors.textTertiary
                      : context.appColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isLocked) ...[
                Icon(
                  PhosphorIconsRegular.lock,
                  size: 18,
                  color: context.appColors.textTertiary,
                ),
              ] else ...[
                Text(
                  l10n.change,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.appColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  PhosphorIconsDuotone.caretRight,
                  size: 18,
                  color: context.appColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show currency picker bottom sheet
  void _showCurrencyPicker(String currentCode, Function(String) onChanged) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                decoration: BoxDecoration(
                  color: context.appColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                l10n.selectCurrency,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Currency list
              ...supportedCurrencies.map((currency) {
                final isSelected = currency.code == currentCode;
                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: '${currency.name} ${currency.code}',
                  child: GestureDetector(
                    onTap: () {
                      onChanged(currency.code);
                      Navigator.pop(context);
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.appColors.primary.withValues(alpha: 0.1)
                            : context.appColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? context.appColors.primary
                              : context.appColors.cardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            currency.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currency.code,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? context.appColors.primary
                                        : context.appColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  currency.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.appColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            currency.symbol,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? context.appColors.primary
                                  : context.appColors.textSecondary,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(
                              PhosphorIconsDuotone.checkCircle,
                              size: 22,
                              color: context.appColors.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),
            ],
          ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsDuotone.x),
          tooltip: l10n.close,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? l10n.editIncomes : l10n.addIncome,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1_Salary(),
                _buildStep2_AskMore(),
                _buildStep3_AddMore(),
                _buildStep4_Summary(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? context.appColors.primary
                          : context.appColors.surfaceLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 3) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ============================================
  // STEP 1: Primary Salary
  // ============================================
  Widget _buildStep1_Salary() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.appColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💼', style: TextStyle(fontSize: 40)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Center(
            child: Text(
              l10n.whatIsYourSalary,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              l10n.enterNetAmount,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Amount input
          TextField(
            controller: _salaryController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [TurkishCurrencyInputFormatter()],
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: context.appColors.primary,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: context.appColors.textTertiary.withValues(alpha: 0.5),
              ),
              suffixText: getCurrencyByCode(_primaryCurrencyCode).code,
              suffixStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.appColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: context.appColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Currency selector
          _buildCurrencySelector(
            currencyCode: _primaryCurrencyCode,
            onChanged: (code) {
              setState(() => _primaryCurrencyCode = code);
            },
          ),

          const SizedBox(height: 24),

          // Work hours
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyWork,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _hoursController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: InputDecoration(
                          hintText: '8',
                          suffixText: l10n.hours,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: context.appColors.cardBorder,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _workDaysPerWeek,
                            isExpanded: true,
                            items: [5, 6, 7].map((days) {
                              return DropdownMenuItem(
                                value: days,
                                child: Text('$days ${l10n.daysPerWeek}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _workDaysPerWeek = value ?? 5);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Continue button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveSalary,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primary,
                foregroundColor: context.appColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.continueButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STEP 2: Additional Income Question
  // ============================================
  Widget _buildStep2_AskMore() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.appColors.success.withValues(alpha: 0.2),
                  context.appColors.primary.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💰', style: TextStyle(fontSize: 48)),
            ),
          ),

          const SizedBox(height: 32),

          Text(
            l10n.doYouHaveOtherIncome,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            l10n.otherIncomeDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: context.appColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 48),

          // Yes button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primary,
                foregroundColor: context.appColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIconsDuotone.plusCircle, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    l10n.yesAddIncome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // No button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              onPressed: () {
                // Skip to summary
                setState(() => _currentStep = 3);
                _pageController.animateToPage(
                  3,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.appColors.cardBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.noOnlySalary,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STEP 3: Add Additional Income
  // ============================================
  Widget _buildStep3_AddMore() {
    final l10n = AppLocalizations.of(context);
    final additionalSources = _incomeSources
        .where((s) => !s.isPrimary)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addAdditionalIncome,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // Category selection
          Text(
            l10n.incomeType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: IncomeCategory.values
                .where((c) => c != IncomeCategory.salary)
                .map((category) {
                  final isSelected = _selectedCategory == category;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: category.getLocalizedLabel(l10n),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = category);
                        HapticFeedback.selectionClick();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.appColors.primary.withValues(alpha: 0.1)
                              : context.appColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? context.appColors.primary
                                : context.appColors.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: 22,
                              color: isSelected
                                  ? category.color
                                  : context.appColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.getLocalizedLabel(l10n),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? context.appColors.primary
                                    : context.appColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          ),

          const SizedBox(height: 24),

          // Title (optional)
          TextField(
            controller: _additionalTitleController,
            keyboardType: TextInputType.text,
            enableSuggestions: true,
            autocorrect: false,
            enableIMEPersonalizedLearning: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.descriptionOptional,
              hintText:
                  _selectedCategory?.getLocalizedLabel(l10n) ??
                  l10n.descriptionOptionalHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Amount
          TextField(
            controller: _additionalAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [TurkishCurrencyInputFormatter()],
            decoration: InputDecoration(
              labelText: l10n.monthlyAmount,
              hintText: '0',
              suffixText: getCurrencyByCode(_additionalCurrencyCode).code,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Currency selector for additional income (locked for FREE users)
          _buildCurrencySelector(
            currencyCode: _additionalCurrencyCode,
            onChanged: (code) {
              setState(() => _additionalCurrencyCode = code);
            },
            isAdditionalIncome: true,
          ),

          const SizedBox(height: 16),

          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addAdditionalIncome,
              icon: Icon(PhosphorIconsDuotone.plus),
              label: Text(l10n.addIncome),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.success,
                foregroundColor: context.appColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Added incomes list
          if (additionalSources.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              l10n.addedIncomes,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...additionalSources.map((source) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.appColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      source.category.icon,
                      size: 26,
                      color: source.category.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          Text(
                            source.category.getLocalizedLabel(l10n),
                            style: TextStyle(
                              fontSize: 12,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${formatTurkishCurrency(source.amount, decimalDigits: 0, showDecimals: false)} ${getCurrencyByCode(source.currencyCode).symbol}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(PhosphorIconsDuotone.x, size: 20),
                      tooltip: l10n.delete,
                      color: context.appColors.error,
                      onPressed: () => _removeIncome(source.id),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 32),

          // Continue button - auto add if form has data
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // If form has filled data, add first
                final hasAmount =
                    parseAmount(_additionalAmountController.text) != null &&
                    parseAmount(_additionalAmountController.text)! > 0;
                final hasCategory = _selectedCategory != null;

                if (hasAmount && hasCategory) {
                  // Form filled, add first then continue
                  _addAdditionalIncome();
                }
                _nextStep();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primary,
                foregroundColor: context.appColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.continueButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Back button
          Center(
            child: TextButton(
              onPressed: _previousStep,
              child: Text(l10n.goBack),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STEP 4: Summary
  // ============================================
  Widget _buildStep4_Summary() {
    final l10n = AppLocalizations.of(context);
    final total = _incomeSources.fold<double>(0, (sum, s) => sum + s.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.appColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsDuotone.checkCircle,
              size: 48,
              color: context.appColors.success,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            l10n.incomeSummary,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),

          const SizedBox(height: 32),

          // Total card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.appColors.primary,
                  context.appColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: context.appColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  l10n.totalMonthlyIncome,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatTurkishCurrency(total, decimalDigits: 0, showDecimals: false)} ${getCurrencyByCode(_primaryCurrencyCode).symbol}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.incomeSourceCount(_incomeSources.length),
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Income breakdown
          ...List.generate(_incomeSources.length, (index) {
            final source = _incomeSources[index];
            final percentage = total > 0 ? (source.amount / total * 100) : 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.appColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: source.isPrimary
                          ? context.appColors.primary.withValues(alpha: 0.1)
                          : context.appColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        source.category.icon,
                        size: 24,
                        color: source.category.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        Text(
                          source.category.getLocalizedLabel(l10n),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${formatTurkishCurrency(source.amount, decimalDigits: 0, showDecimals: false)} ${getCurrencyByCode(source.currencyCode).symbol}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      Text(
                        '%${percentage.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),

          // Complete button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _complete,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.success,
                foregroundColor: context.appColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.appColors.textPrimary,
                      ),
                    )
                  : Text(
                      l10n.complete,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Edit button
          TextButton(
            onPressed: () {
              setState(() => _currentStep = 2);
              _pageController.animateToPage(
                2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            },
            child: Text(l10n.editMyIncomes),
          ),
        ],
      ),
    );
  }
}
