import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../providers/providers.dart';
import '../utils/currency_utils.dart';
import '../utils/currency_helper.dart';
import '../utils/duplicate_checker.dart';
import 'turkish_currency_input.dart';
import 'result_card.dart';
import 'decision_buttons.dart';
import 'smart_choice_toggle.dart';
import 'redirect_savings_sheet.dart';

/// Full Expense Entry Bottom Sheet
/// Contains: Date chips, Amount, Description (Smart Match), Category, Subcategory, Calculate button
/// Shows Result Card and Decision Buttons after calculation
class AddExpenseSheet extends StatefulWidget {
  final ExchangeRates? exchangeRates;
  final VoidCallback? onExpenseAdded;
  final Expense? existingExpense;
  final Function(Expense)? onExpenseUpdated;

  const AddExpenseSheet({
    super.key,
    this.exchangeRates,
    this.onExpenseAdded,
    this.existingExpense,
    this.onExpenseUpdated,
  });

  bool get isEditMode => existingExpense != null;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _subCategoryFocusNode = FocusNode();

  final _calculationService = CalculationService();
  final _insightService = InsightService();
  final _messagesService = MessagesService();
  final _subCategoryService = SubCategoryService();

  // State
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  SubCategorySuggestions? _subCategorySuggestions;
  bool _showSubCategorySuggestions = false;
  ExpenseResult? _result;
  String? _categoryInsight;
  String? _emotionalMessage;
  Expense? _pendingExpense;

  // Currency state
  late Currency _expenseCurrency;
  late Currency _incomeCurrency;
  late Currency _displayCurrency;

  // Smart Match & Animations
  late AnimationController _smartMatchAnimController;
  late AnimationController _attentionAnimController;
  late Animation<double> _smartMatchScale;
  late Animation<double> _attentionPulse;
  bool _smartMatchActive = false;
  bool _categoryValidationError = false;
  bool _userManuallySelectedCategory = false;

  // Wealth Coach: Smart Choice
  double? _smartChoiceSavedFrom;

  // Gider tipi ve taksit bilgileri
  ExpenseType _expenseType = ExpenseType.single;
  bool _isMandatory = false;
  bool _showInstallmentDetails = false;

  // Taksit inputları için controller'lar
  final _installmentCountController = TextEditingController();
  final _cashPriceController = TextEditingController();
  final _installmentTotalController = TextEditingController();

  // Date helpers
  DateTime get _today => DateTime.now();
  DateTime get _yesterday => _today.subtract(const Duration(days: 1));
  DateTime get _twoDaysAgo => _today.subtract(const Duration(days: 2));

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String? get _selectedDateChip {
    if (_isSameDay(_selectedDate, _today)) return null;
    if (_isSameDay(_selectedDate, _yesterday)) return 'yesterday';
    if (_isSameDay(_selectedDate, _twoDaysAgo)) return 'twoDaysAgo';
    return 'custom';
  }

  // Available currencies for expense entry
  static const List<String> _availableCurrencies = ['TRY', 'USD', 'EUR', 'GBP'];

  @override
  void initState() {
    super.initState();
    CategoryLearningService.initialize();
    _initCurrencies();
    _initEditMode();

    _smartMatchAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _smartMatchScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _smartMatchAnimController, curve: Curves.easeOutBack),
    );

    _attentionAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _attentionPulse = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _attentionAnimController, curve: Curves.easeInOut),
    );

    _subCategoryFocusNode.addListener(() {
      if (_subCategoryFocusNode.hasFocus) {
        setState(() => _showSubCategorySuggestions = true);
      }
    });

    _loadSubCategorySuggestions();
  }

  void _initCurrencies() {
    final financeProvider = context.read<FinanceProvider>();
    final currencyProvider = context.read<CurrencyProvider>();

    // Get income currency from user profile (default TRY)
    final userProfile = financeProvider.userProfile;
    final incomeCurrencyCode = userProfile?.incomeSources.isNotEmpty == true
        ? userProfile!.incomeSources.first.currencyCode
        : 'TRY';
    _incomeCurrency = getCurrencyByCode(incomeCurrencyCode);

    // Get display currency from provider
    _displayCurrency = currencyProvider.currency;

    // Default expense currency is income currency
    _expenseCurrency = _incomeCurrency;
  }

  /// Pre-fill form if editing an existing expense
  void _initEditMode() {
    final expense = widget.existingExpense;
    if (expense == null) return;

    // Pre-fill amount (use original amount if available, otherwise converted amount)
    final displayAmount = expense.originalAmount ?? expense.amount;
    _amountController.text = formatTurkishCurrency(displayAmount, decimalDigits: 2);

    // Pre-fill category
    _selectedCategory = expense.category;
    _userManuallySelectedCategory = true;

    // Pre-fill description/subcategory
    if (expense.subCategory != null && expense.subCategory!.isNotEmpty) {
      _subCategoryController.text = expense.subCategory!;
    }

    // Pre-fill currency
    if (expense.originalCurrency != null) {
      _expenseCurrency = getCurrencyByCode(expense.originalCurrency!);
    }

    // Pre-fill date
    _selectedDate = expense.date;

    // Pre-fill expense type and mandatory status
    _expenseType = expense.type;
    _isMandatory = expense.isMandatory;

    // Pre-fill installment details if applicable
    if (expense.type == ExpenseType.installment) {
      _showInstallmentDetails = true;
      if (expense.installmentCount != null) {
        _installmentCountController.text = expense.installmentCount.toString();
      }
      if (expense.cashPrice != null) {
        _cashPriceController.text = formatTurkishCurrency(expense.cashPrice!, decimalDigits: 2);
      }
      if (expense.installmentTotal != null) {
        _installmentTotalController.text = formatTurkishCurrency(expense.installmentTotal!, decimalDigits: 2);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _subCategoryController.dispose();
    _subCategoryFocusNode.dispose();
    _smartMatchAnimController.dispose();
    _attentionAnimController.dispose();
    // Taksit controller'ları
    _installmentCountController.dispose();
    _cashPriceController.dispose();
    _installmentTotalController.dispose();
    super.dispose();
  }

  Future<void> _loadSubCategorySuggestions() async {
    if (_selectedCategory == null) {
      if (mounted) setState(() => _subCategorySuggestions = null);
      return;
    }
    final suggestions = await _subCategoryService.getSuggestions(_selectedCategory!);
    if (mounted) setState(() => _subCategorySuggestions = suggestions);
  }

  void _onDescriptionChanged(String text) {
    if (_userManuallySelectedCategory) return;

    final predicted = CategoryLearningService.predictCategory(text);
    if (predicted != null && ExpenseCategory.all.contains(predicted)) {
      setState(() {
        _selectedCategory = predicted;
        _smartMatchActive = true;
        _categoryValidationError = false;
      });

      _smartMatchAnimController.forward().then((_) {
        _smartMatchAnimController.reverse();
      });

      _loadSubCategorySuggestions();
    }
  }

  void _onCategoryManuallySelected(String? category) {
    if (category == null) return;

    setState(() {
      _selectedCategory = category;
      _userManuallySelectedCategory = true;
      _categoryValidationError = false;
      _smartMatchActive = false;
    });

    _attentionAnimController.stop();
    _attentionAnimController.reset();
    _loadSubCategorySuggestions();

    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) {
      CategoryLearningService.learn(description, category);
    }
  }

  void _onAmountChanged(String text) {
    final amount = parseTurkishCurrency(text);
    final hasValidAmount = amount != null && amount > 0;

    if (hasValidAmount && _selectedCategory == null) {
      _attentionAnimController.repeat(reverse: true);
    } else {
      _attentionAnimController.stop();
      _attentionAnimController.reset();
    }
  }

  void _selectSubCategory(String subCategory) {
    _subCategoryController.text = subCategory;
    setState(() => _showSubCategorySuggestions = false);
    _subCategoryFocusNode.unfocus();
  }

  void _selectYesterday() {
    setState(() {
      _selectedDate = _yesterday;
      _result = null;
      _pendingExpense = null;
    });
  }

  void _selectTwoDaysAgo() {
    setState(() {
      _selectedDate = _twoDaysAgo;
      _result = null;
      _pendingExpense = null;
    });
  }

  void _selectToday() {
    setState(() {
      _selectedDate = _today;
      _result = null;
      _pendingExpense = null;
    });
  }

  Future<void> _showCalendarDatePicker() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showDatePicker(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: l10n.selectExpenseDate,
      cancelText: l10n.cancel,
      confirmText: l10n.select,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _result = null;
        _pendingExpense = null;
      });
    }
  }

  String _formatDisplayDate(DateTime date, AppLocalizations l10n) {
    if (_isSameDay(date, _today)) return l10n.today;
    if (_isSameDay(date, _yesterday)) return l10n.yesterday;
    if (_isSameDay(date, _twoDaysAgo)) return l10n.twoDaysAgo;
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Convert amount from one currency to income currency using exchange rates
  double _convertToIncomeCurrency(double amount, Currency from) {
    if (from == _incomeCurrency) return amount;

    final rates = widget.exchangeRates;
    if (rates == null) return amount; // No rates, return as-is

    final usdTry = rates.usdRate;
    final eurTry = rates.eurRate;
    final gbpTry = usdTry * 1.27; // Approximate
    final sarTry = usdTry / 3.75; // SAR pegged to USD

    // TRY value of each currency
    double getTryValue(String code) {
      switch (code) {
        case 'TRY':
          return 1.0;
        case 'USD':
          return usdTry;
        case 'EUR':
          return eurTry;
        case 'GBP':
          return gbpTry;
        case 'SAR':
          return sarTry;
        default:
          return 1.0;
      }
    }

    // Convert: from -> TRY -> incomeCurrency
    final amountInTry = amount * getTryValue(from.code);
    final incomeTryRate = getTryValue(_incomeCurrency.code);
    return incomeTryRate > 0 ? amountInTry / incomeTryRate : amount;
  }

  void _calculate() {
    final l10n = AppLocalizations.of(context);
    final enteredAmount = parseTurkishCurrency(_amountController.text);

    if (enteredAmount == null) {
      _showError(l10n.validationEnterAmount);
      return;
    }

    if (enteredAmount <= 0) {
      _showError(l10n.validationAmountPositive);
      return;
    }

    if (enteredAmount > 100000000) {
      _showError(l10n.validationAmountTooHigh);
      return;
    }

    if (_selectedCategory == null) {
      setState(() => _categoryValidationError = true);
      _showError(l10n.pleaseSelectCategory);
      _attentionAnimController.repeat(reverse: true);
      return;
    }

    // Taksit bilgilerini parse et
    int? installmentCount;
    double? cashPrice;
    double? installmentTotal;

    // Taksit validasyonu
    if (_expenseType == ExpenseType.installment) {
      installmentCount = int.tryParse(_installmentCountController.text);
      cashPrice = parseTurkishCurrency(_cashPriceController.text);
      installmentTotal = parseTurkishCurrency(_installmentTotalController.text);

      if (installmentCount == null || installmentCount <= 0) {
        _showError('Lütfen taksit sayısını seçin');
        return;
      }

      if (installmentTotal == null || installmentTotal <= 0) {
        _showError('Lütfen taksitli toplam fiyatı girin');
        return;
      }
    }

    // Hesaplama için kullanılacak tutar
    // Taksitli ise aylık taksit tutarını kullan (bu ayki harcama olarak)
    double amountForCalculation = enteredAmount;
    if (_expenseType == ExpenseType.installment &&
        installmentCount != null &&
        installmentCount > 0 &&
        installmentTotal != null) {
      amountForCalculation = installmentTotal / installmentCount;
    }

    // Convert to income currency if different
    final amountInIncomeCurrency = _convertToIncomeCurrency(amountForCalculation, _expenseCurrency);
    final isDifferentCurrency = _expenseCurrency != _incomeCurrency;

    // Taksit bilgilerini de currency'e çevir
    final cashPriceConverted = cashPrice != null
        ? _convertToIncomeCurrency(cashPrice, _expenseCurrency)
        : null;
    final installmentTotalConverted = installmentTotal != null
        ? _convertToIncomeCurrency(installmentTotal, _expenseCurrency)
        : null;

    final financeProvider = context.read<FinanceProvider>();
    final userProfile = financeProvider.userProfile ??
        UserProfile(incomeSources: [], dailyHours: 8, workDaysPerWeek: 5);

    final result = _calculationService.calculateExpense(
      userProfile: userProfile,
      expenseAmount: amountInIncomeCurrency,
      month: _selectedDate.month,
      year: _selectedDate.year,
    );

    final recordType = Expense.detectRecordType(amountInIncomeCurrency, result.hoursRequired);

    final rawSubCat = _subCategoryController.text.trim();
    final normalizedSubCat = rawSubCat.isEmpty
        ? null
        : SubCategoryService.normalize(rawSubCat);

    final isSmartChoice = _smartChoiceSavedFrom != null && _smartChoiceSavedFrom! > amountInIncomeCurrency;

    final expense = Expense(
      amount: amountInIncomeCurrency,
      category: _selectedCategory!,
      subCategory: normalizedSubCat,
      date: _selectedDate,
      hoursRequired: result.hoursRequired,
      daysRequired: result.daysRequired,
      recordType: recordType,
      savedFrom: _smartChoiceSavedFrom,
      isSmartChoice: isSmartChoice,
      originalAmount: isDifferentCurrency ? enteredAmount : null,
      originalCurrency: isDifferentCurrency ? _expenseCurrency.code : null,
      // Yeni fieldlar
      type: _expenseType,
      isMandatory: _isMandatory,
      installmentCount: installmentCount,
      currentInstallment: installmentCount != null ? 1 : null,
      cashPrice: cashPriceConverted,
      installmentTotal: installmentTotalConverted,
      installmentStartDate: _expenseType == ExpenseType.installment ? _selectedDate : null,
    );

    final categoryInsight = _insightService.getCategoryInsight(
      financeProvider.expenses,
      _selectedCategory!,
      _selectedDate.month,
      _selectedDate.year,
    );

    // Duygusal mesaj (zorunlu gider değilse)
    String? emotionalMessage;
    if (!_isMandatory) {
      emotionalMessage = _messagesService.getCalculationMessage(
        result.hoursRequired,
        enteredAmount,
      );
    }

    setState(() {
      _result = result;
      _pendingExpense = expense;
      _categoryInsight = categoryInsight;
      _emotionalMessage = emotionalMessage;
    });
  }

  String _getEmotionalMessage(ExpenseDecision decision, double amount) {
    final decisionType = switch (decision) {
      ExpenseDecision.yes => DecisionType.yes,
      ExpenseDecision.no => DecisionType.no,
      ExpenseDecision.thinking => DecisionType.thinking,
    };

    final message = _messagesService.getMessageForDecision(decisionType);

    if (decision == ExpenseDecision.no) {
      final rates = widget.exchangeRates;
      if (rates != null && rates.goldRate > 0) {
        final goldGrams = amount / rates.goldRate;
        return '$message (${goldGrams.toStringAsFixed(1)}g altın)';
      }
      final currencyProvider = context.read<CurrencyProvider>();
      return '$message (${formatTurkishCurrency(amount, decimalDigits: 2)} ${currencyProvider.code})';
    }

    return message;
  }

  Future<void> _onDecision(ExpenseDecision decision, {bool force = false}) async {
    if (_pendingExpense == null) return;

    final amount = _pendingExpense!.amount;
    final isSimulation = _pendingExpense!.isSimulation;
    final category = _pendingExpense!.category;
    final subCategory = _pendingExpense!.subCategory;

    final financeProvider = context.read<FinanceProvider>();

    // Duplicate kontrolü (force değilse ve simülasyon değilse)
    if (!force && !isSimulation) {
      final duplicates = DuplicateChecker.findDuplicates(
        expenses: financeProvider.expenses,
        amount: amount,
        category: category,
        date: _selectedDate,
      );

      if (duplicates.isNotEmpty) {
        final match = duplicates.first;
        final shouldContinue = await _showDuplicateWarningDialog(match);
        if (!shouldContinue) return;
      }
    }

    final expenseWithDecision = _pendingExpense!.copyWith(
      decision: decision,
      decisionDate: DateTime.now(),
    );

    await financeProvider.addExpense(expenseWithDecision);

    if (!isSimulation && subCategory != null && subCategory.isNotEmpty) {
      await _subCategoryService.addRecentSubCategory(category, subCategory);
    }

    if (!mounted) return;

    // Victory celebration for "passed" decision
    if (decision == ExpenseDecision.no && !isSimulation) {
      final freedomHours = expenseWithDecision.hoursRequired;
      victoryManager.showVictoryAnimation(
        context,
        amount: amount,
        hours: freedomHours,
      );

      // Add to savings pool automatically
      final savingsPoolProvider = context.read<SavingsPoolProvider>();
      await savingsPoolProvider.addSavings(amount);

      // Show redirect savings option if user has active pursuits
      final pursuitProvider = context.read<PursuitProvider>();
      if (pursuitProvider.activePursuits.isNotEmpty) {
        // Close current sheet first
        if (mounted) Navigator.pop(context);
        widget.onExpenseAdded?.call();

        // Show redirect savings sheet after a short delay
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          final currencyProvider = context.read<CurrencyProvider>();
          await showRedirectSavingsSheet(
            context,
            amount: amount,
            currency: currencyProvider.code,
          );
        }
        return;
      }
    }

    final message = isSimulation
        ? AppLocalizations.of(context).simulationSaved
        : _getEmotionalMessage(decision, amount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    widget.onExpenseAdded?.call();
    if (mounted) Navigator.pop(context);
  }

  String _formatTimeAgo(Duration diff, AppLocalizations l10n) {
    if (diff.inMinutes < 1) {
      return l10n.timeAgoNow;
    } else if (diff.inMinutes < 60) {
      return l10n.timeAgoMinutes(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.timeAgoHours(diff.inHours);
    } else {
      return l10n.timeAgoDays(diff.inDays);
    }
  }

  Future<bool> _showDuplicateWarningDialog(DuplicateMatch match) async {
    final l10n = AppLocalizations.of(context);
    final timeAgoText = _formatTimeAgo(match.timeSinceEntry, l10n);
    final amountStr = match.expense.amount.toStringAsFixed(0);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              PhosphorIconsFill.warning,
              color: Colors.amber,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.warning,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '${l10n.duplicateExpenseWarning}:\n\n'
          '${l10n.duplicateExpenseDetails(amountStr, match.expense.category)}\n'
          '($timeAgoText)\n\n'
          '${l10n.addAnyway}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.no,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _cancelDecision() {
    setState(() {
      _result = null;
      _pendingExpense = null;
      _categoryInsight = null;
      _emotionalMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gradientMid,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isEditMode ? l10n.editExpense : l10n.newExpense,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  PhosphorIconsDuotone.calendar,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDisplayDate(_selectedDate, l10n),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              PhosphorIconsDuotone.x,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: _result == null
                          ? _buildForm(l10n)
                          : _buildResultSection(l10n),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date chips
        _buildDateChips(l10n),

        const SizedBox(height: 20),

        // Amount input
        _buildAmountInput(l10n),

        const SizedBox(height: 16),

        // Smart Choice Toggle
        SmartChoiceToggle(
          selectedCategory: _selectedCategory,
          currentAmount: parseTurkishCurrency(_amountController.text) ?? 0,
          onSavedFromChanged: (value) {
            setState(() => _smartChoiceSavedFrom = value);
          },
          isEnabled: _pendingExpense == null,
        ),

        const SizedBox(height: 8),

        // Zorunlu gider toggle
        _buildMandatoryToggle(),

        // Taksit bölümü
        _buildInstallmentSection(),

        const SizedBox(height: 16),

        // Description (Smart Match)
        _buildDescriptionInput(l10n),

        const SizedBox(height: 16),

        // Category
        _buildCategoryDropdown(l10n),

        const SizedBox(height: 16),

        // Subcategory
        _buildSubCategorySection(l10n),

        const SizedBox(height: 24),

        // Calculate button
        _buildCalculateButton(l10n),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDateChips(AppLocalizations l10n) {
    return Row(
      children: [
        _DateChip(
          label: l10n.yesterday,
          isSelected: _selectedDateChip == 'yesterday',
          onTap: _selectYesterday,
        ),
        const SizedBox(width: 8),
        _DateChip(
          label: l10n.twoDaysAgo,
          isSelected: _selectedDateChip == 'twoDaysAgo',
          onTap: _selectTwoDaysAgo,
        ),
        const SizedBox(width: 8),
        _DateChip(
          icon: PhosphorIconsDuotone.calendar,
          label: _selectedDateChip == 'custom'
              ? '${_selectedDate.day}/${_selectedDate.month}'
              : null,
          isSelected: _selectedDateChip == 'custom',
          onTap: _showCalendarDatePicker,
        ),
        if (_selectedDateChip != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: _selectToday,
            child: Text(
              l10n.today,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmountInput(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Amount row with currency dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Currency dropdown
              _buildCurrencyDropdown(),
              const SizedBox(width: 8),
              // Amount input
              Expanded(
                child: TextField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [TurkishCurrencyInputFormatter()],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0,00',
                    hintStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: _onAmountChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _expenseCurrency.code,
          icon: Icon(
            PhosphorIconsFill.caretDown,
            size: 16,
            color: AppColors.primary,
          ),
          dropdownColor: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          items: _availableCurrencies.map((code) {
            return DropdownMenuItem<String>(
              value: code,
              child: Text(
                CurrencyHelper.getDisplay(code),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: _expenseCurrency.code == code
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: _expenseCurrency.code == code
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: (code) {
            if (code != null) {
              HapticFeedback.selectionClick();
              setState(() => _expenseCurrency = getCurrencyByCode(code));
            }
          },
        ),
      ),
    );
  }

  Widget _buildDescriptionInput(AppLocalizations l10n) {
    return TextField(
      controller: _descriptionController,
      keyboardType: TextInputType.text,
      enableSuggestions: true,
      autocorrect: false,
      enableIMEPersonalizedLearning: true,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: l10n.descriptionLabel,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintText: l10n.descriptionHint,
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: _smartMatchActive
            ? const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  PhosphorIconsDuotone.sparkle,
                  size: 18,
                  color: AppColors.success,
                ),
              )
            : null,
      ),
      onChanged: _onDescriptionChanged,
    );
  }

  Widget _buildCategoryDropdown(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: Listenable.merge([_smartMatchAnimController, _attentionAnimController]),
      builder: (context, child) {
        final scale = _smartMatchActive
            ? _smartMatchScale.value
            : (_categoryValidationError ? _attentionPulse.value : 1.0);
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: _smartMatchActive
                  ? [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : _categoryValidationError
                      ? [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: Text(
                    l10n.selectCategory,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                  items: ExpenseCategory.all.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(ExpenseCategory.getLocalizedName(category, l10n)),
                    );
                  }).toList(),
                  onChanged: _onCategoryManuallySelected,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    labelStyle: TextStyle(
                      color: _categoryValidationError
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _categoryValidationError ? AppColors.error : AppColors.cardBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _categoryValidationError
                            ? AppColors.error
                            : (_smartMatchActive ? AppColors.success : AppColors.cardBorder),
                        width: _smartMatchActive || _categoryValidationError ? 1.5 : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                if (_categoryValidationError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      l10n.pleaseSelectCategory,
                      style: const TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                if (_smartMatchActive && _selectedCategory != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Row(
                      children: [
                        const Icon(PhosphorIconsDuotone.sparkle, size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          l10n.autoSelected(_selectedCategory!),
                          style: const TextStyle(fontSize: 12, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubCategorySection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _subCategoryController,
          focusNode: _subCategoryFocusNode,
          keyboardType: TextInputType.text,
          enableSuggestions: true,
          autocorrect: false,
          enableIMEPersonalizedLearning: true,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.subCategoryOptional,
            hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: _subCategoryController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(PhosphorIconsDuotone.x, size: 18),
                    color: AppColors.textTertiary,
                    onPressed: () {
                      _subCategoryController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
          onTap: () => setState(() => _showSubCategorySuggestions = true),
        ),
        if (_showSubCategorySuggestions && _subCategorySuggestions != null && !_subCategorySuggestions!.isEmpty)
          _buildSubCategoryChips(l10n),
      ],
    );
  }

  Widget _buildSubCategoryChips(AppLocalizations l10n) {
    final suggestions = _subCategorySuggestions!;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (suggestions.hasRecent) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                l10n.recentlyUsed,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: suggestions.recent.map((subCat) {
                return _SubCategoryChip(
                  label: subCat,
                  isRecent: true,
                  onTap: () => _selectSubCategory(subCat),
                );
              }).toList(),
            ),
            if (suggestions.hasFixed) const SizedBox(height: 12),
          ],
          if (suggestions.hasFixed) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                l10n.suggestions,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: suggestions.fixed.map((subCat) {
                return _SubCategoryChip(
                  label: subCat,
                  isRecent: false,
                  onTap: () => _selectSubCategory(subCat),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalculateButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primaryButton,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _calculate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(PhosphorIconsDuotone.calculator, size: 22),
              const SizedBox(width: 10),
              Text(
                l10n.calculate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Zorunlu gider toggle widget'ı
  Widget _buildMandatoryToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isMandatory
                ? AppColors.info.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: SwitchListTile(
          title: Text(
            'Zorunlu Gider',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: _isMandatory ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            'Kira, fatura, kredi ödemesi gibi sabit giderler',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          secondary: Icon(
            _isMandatory
                ? PhosphorIconsFill.lockKey
                : PhosphorIconsDuotone.lockKeyOpen,
            color: _isMandatory ? AppColors.info : AppColors.textTertiary,
          ),
          value: _isMandatory,
          onChanged: (value) => setState(() => _isMandatory = value),
          activeTrackColor: AppColors.info,
        ),
      ),
    );
  }

  /// Taksit bölümü widget'ı
  Widget _buildInstallmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Taksitli mi toggle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _expenseType == ExpenseType.installment
                    ? AppColors.warning.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: SwitchListTile(
              title: Text(
                'Taksitli Alım',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: _expenseType == ExpenseType.installment
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                'Kredi kartı veya mağaza taksiti',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              secondary: Icon(
                PhosphorIconsDuotone.creditCard,
                color: _expenseType == ExpenseType.installment
                    ? AppColors.warning
                    : AppColors.textTertiary,
              ),
              value: _expenseType == ExpenseType.installment,
              onChanged: (value) {
                setState(() {
                  _expenseType =
                      value ? ExpenseType.installment : ExpenseType.single;
                  _showInstallmentDetails = value;
                  // Auto-copy amount to installment total when toggle is enabled
                  if (value && _installmentTotalController.text.isEmpty && _amountController.text.isNotEmpty) {
                    _installmentTotalController.text = _amountController.text;
                  }
                });
              },
              activeTrackColor: AppColors.warning,
            ),
          ),
        ),

        // Taksit detayları (animasyonlu açılır)
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildInstallmentDetails(),
          crossFadeState: _showInstallmentDetails
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  /// Taksit detayları formu
  Widget _buildInstallmentDetails() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(PhosphorIconsDuotone.info, color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                'Taksit Bilgileri',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Peşin fiyat
          TextField(
            controller: _cashPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [TurkishCurrencyInputFormatter()],
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Peşin Fiyat',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: 'Ürünün peşin fiyatı',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              prefixText: '${_expenseCurrency.symbol} ',
              prefixStyle: const TextStyle(color: AppColors.textPrimary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.warning),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onChanged: (_) => _updateInstallmentSummary(),
          ),
          const SizedBox(height: 12),

          // Taksit sayısı
          DropdownButtonFormField<int>(
            value: int.tryParse(_installmentCountController.text),
            dropdownColor: AppColors.cardBackground,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Taksit Sayısı',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.warning),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            items: [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 18, 24, 36]
                .map((n) => DropdownMenuItem(
                      value: n,
                      child: Text('$n taksit'),
                    ))
                .toList(),
            onChanged: (value) {
              _installmentCountController.text = value?.toString() ?? '';
              _updateInstallmentSummary();
            },
          ),
          const SizedBox(height: 12),

          // Taksitli toplam fiyat
          TextField(
            controller: _installmentTotalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [TurkishCurrencyInputFormatter()],
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Taksitli Toplam Fiyat',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: 'Vade farkı dahil toplam',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              prefixText: '${_expenseCurrency.symbol} ',
              prefixStyle: const TextStyle(color: AppColors.textPrimary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.warning),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onChanged: (_) => _updateInstallmentSummary(),
          ),

          // Özet kartı
          _buildInstallmentSummary(),
        ],
      ),
    );
  }

  /// Taksit özet kartı
  Widget _buildInstallmentSummary() {
    final cashPrice = parseTurkishCurrency(_cashPriceController.text);
    final installmentTotal = parseTurkishCurrency(_installmentTotalController.text);
    final installmentCount = int.tryParse(_installmentCountController.text);

    // Hesaplama yapılamıyorsa boş döndür
    if (cashPrice == null || installmentTotal == null || installmentCount == null) {
      return const SizedBox.shrink();
    }
    if (cashPrice <= 0 || installmentTotal <= 0 || installmentCount <= 0) {
      return const SizedBox.shrink();
    }

    final interestAmount = installmentTotal - cashPrice;
    final interestRate = (interestAmount / cashPrice) * 100;
    final monthlyPayment = installmentTotal / installmentCount;

    // Saatlik ücret hesabı
    final financeProvider = context.read<FinanceProvider>();
    final hourlyRate = financeProvider.hourlyRate;
    final interestHours = hourlyRate > 0 ? interestAmount / hourlyRate : 0.0;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAKSİT ÖZETİ',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          _summaryRow(
              'Aylık taksit:',
              '${_expenseCurrency.symbol}${formatTurkishCurrency(monthlyPayment, decimalDigits: 0)}'),
          _summaryRow('Taksit sayısı:', '$installmentCount ay'),
          Divider(color: AppColors.cardBorder, height: 16),
          _summaryRow(
            'Vade farkı:',
            '${_expenseCurrency.symbol}${formatTurkishCurrency(interestAmount, decimalDigits: 0)} (%${interestRate.toStringAsFixed(1)})',
            isHighlight: true,
          ),
          if (hourlyRate > 0)
            _summaryRow(
              'Vade farkı saat olarak:',
              '${interestHours.toStringAsFixed(1)} saat',
              isHighlight: true,
            ),

          // Uyarı mesajı
          if (interestAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsFill.warning, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Peşin alsaydın ${interestHours.toStringAsFixed(0)} saat kazanırdın!',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? AppColors.warning : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _updateInstallmentSummary() {
    setState(() {});
  }

  /// Zorunlu gider için sadece Kaydet butonu
  Widget _buildMandatorySaveButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Bilgi mesajı
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsDuotone.info, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Zorunlu gider olarak kaydedilecek',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Kaydet butonu
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.info, AppColors.info.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.info.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _saveMandatoryExpense,
                icon: Icon(PhosphorIconsDuotone.check, size: 20),
                label: const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // İptal butonu
          TextButton(
            onPressed: _cancelDecision,
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  /// Update existing expense (edit mode)
  Future<void> _updateExpense() async {
    if (_pendingExpense == null || widget.existingExpense == null) return;

    // Create updated expense keeping the original decision
    final updatedExpense = _pendingExpense!.copyWith(
      decision: widget.existingExpense!.decision,
      decisionDate: widget.existingExpense!.decisionDate,
    );

    // Call the update callback
    widget.onExpenseUpdated?.call(updatedExpense);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.updateExpense),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  /// Zorunlu gideri kaydet (otomatik "yes" kararı ile)
  Future<void> _saveMandatoryExpense() async {
    if (_pendingExpense == null) return;

    // Zorunlu gider için otomatik olarak "yes" kararı ile kaydet
    final expense = _pendingExpense!.copyWith(
      decision: ExpenseDecision.yes,
      decisionDate: DateTime.now(),
    );

    final financeProvider = context.read<FinanceProvider>();
    await financeProvider.addExpense(expense);

    // Alt kategori kaydet (varsa)
    final subCategory = _subCategoryController.text.trim();
    if (subCategory.isNotEmpty && _selectedCategory != null) {
      await _subCategoryService.addRecentSubCategory(_selectedCategory!, subCategory);
    }

    // Callback ve kapat
    widget.onExpenseAdded?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Zorunlu gider kaydedildi'),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildResultSection(AppLocalizations l10n) {
    return Column(
      children: [
        // Result Card
        ResultCard(
          result: _result!,
          categoryInsight: _isMandatory ? null : _categoryInsight,
          emotionalMessage: _emotionalMessage,
          amount: _pendingExpense?.amount,
          exchangeRates: widget.exchangeRates,
        ),

        const SizedBox(height: 20),

        // Edit mode: show update button
        if (widget.isEditMode)
          _buildUpdateButton(l10n)
        // Zorunlu gider ise sadece Kaydet butonu, değilse karar butonları
        else if (_isMandatory)
          _buildMandatorySaveButton(l10n)
        else ...[
          // Decision Buttons
          DecisionButtons(onDecision: _onDecision),

          const SizedBox(height: 16),

          // Cancel Button
          Center(
            child: TextButton(
              onPressed: _cancelDecision,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  /// Update button for edit mode
  Widget _buildUpdateButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Update button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.primaryButton,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _updateExpense,
                icon: Icon(PhosphorIconsDuotone.pencilSimple, size: 20),
                label: Text(l10n.updateExpense),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Cancel button
          TextButton(
            onPressed: _cancelDecision,
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Date chip widget
class _DateChip extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: label != null ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primaryButton : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            if (icon != null && label != null) const SizedBox(width: 6),
            if (label != null)
              Text(
                label!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Subcategory chip widget
class _SubCategoryChip extends StatelessWidget {
  final String label;
  final bool isRecent;
  final VoidCallback onTap;

  const _SubCategoryChip({
    required this.label,
    required this.isRecent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isRecent
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecent
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRecent)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  PhosphorIconsDuotone.clockCounterClockwise,
                  size: 12,
                  color: AppColors.primary,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isRecent ? FontWeight.w500 : FontWeight.w400,
                color: isRecent ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show the AddExpenseSheet
void showAddExpenseSheet(
  BuildContext context, {
  ExchangeRates? exchangeRates,
  VoidCallback? onExpenseAdded,
  Expense? existingExpense,
  Function(Expense)? onExpenseUpdated,
}) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.95),
    builder: (context) => AddExpenseSheet(
      exchangeRates: exchangeRates,
      onExpenseAdded: onExpenseAdded,
      existingExpense: existingExpense,
      onExpenseUpdated: onExpenseUpdated,
    ),
  );
}
