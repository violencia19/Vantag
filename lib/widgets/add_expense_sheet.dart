import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'multi_currency_pro_sheet.dart';
import 'expense_form_chips.dart';
import '../screens/voice_input_screen.dart';

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
  final _receiptScannerService = ReceiptScannerService();

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

  // Receipt scanning state
  bool _isScanning = false;

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
      CurvedAnimation(
        parent: _smartMatchAnimController,
        curve: Curves.easeOutBack,
      ),
    );

    _attentionAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _attentionPulse = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _attentionAnimController,
        curve: Curves.easeInOut,
      ),
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

    // Get income currency from user profile (default TRY)
    final userProfile = financeProvider.userProfile;
    final incomeCurrencyCode = userProfile?.incomeSources.isNotEmpty == true
        ? userProfile!.incomeSources.first.currencyCode
        : 'TRY';
    _incomeCurrency = getCurrencyByCode(incomeCurrencyCode);

    // Default expense currency is income currency
    _expenseCurrency = _incomeCurrency;
  }

  /// Pre-fill form if editing an existing expense
  void _initEditMode() {
    final expense = widget.existingExpense;
    if (expense == null) return;

    // Pre-fill amount (use original amount if available, otherwise converted amount)
    final displayAmount = expense.originalAmount ?? expense.amount;
    _amountController.text = formatTurkishCurrency(
      displayAmount,
      decimalDigits: 2,
    );

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
        _cashPriceController.text = formatTurkishCurrency(
          expense.cashPrice!,
          decimalDigits: 2,
        );
      }
      if (expense.installmentTotal != null) {
        _installmentTotalController.text = formatTurkishCurrency(
          expense.installmentTotal!,
          decimalDigits: 2,
        );
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
    // Receipt scanner
    _receiptScannerService.dispose();
    super.dispose();
  }

  /// Scan receipt using camera or gallery
  Future<void> _scanReceipt({bool fromCamera = true}) async {
    final l10n = AppLocalizations.of(context);

    setState(() => _isScanning = true);

    try {
      // Pick image
      final imageFile = await _receiptScannerService.pickImage(
        fromCamera: fromCamera,
      );

      if (imageFile == null) {
        setState(() => _isScanning = false);
        return;
      }

      // Extract data from receipt
      final result = await _receiptScannerService.extractFromReceipt(imageFile);

      if (!mounted) return;

      if (result.hasAmount) {
        // Auto-fill amount
        _amountController.text = formatTurkishCurrency(
          result.amount!,
          decimalDigits: 2,
        );
        _onAmountChanged(_amountController.text);

        // Auto-fill description with merchant if available
        if (result.merchant != null && _descriptionController.text.isEmpty) {
          _descriptionController.text = result.merchant!;
        }

        // Auto-select detected currency if valid
        if (result.currency != null &&
            _availableCurrencies.contains(result.currency)) {
          setState(() {
            _expenseCurrency = getCurrencyByCode(result.currency!);
          });
        }

        haptics.success();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.receiptScanned),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.appColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noAmountFound),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.appColors.warning,
          ),
        );
      }
    } catch (e) {
      debugPrint('[AddExpenseSheet] Scan error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.scanError),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.appColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  /// Show options for camera vs gallery
  void _showScanOptions() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      backgroundColor: context.appColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
              Text(
                l10n.scanReceipt,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.camera,
                    color: context.appColors.primary,
                  ),
                ),
                title: Text(
                  l10n.takePhoto,
                  style: TextStyle(color: context.appColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _scanReceipt(fromCamera: true);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.appColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.image,
                    color: context.appColors.secondary,
                  ),
                ),
                title: Text(
                  l10n.chooseFromGallery,
                  style: TextStyle(color: context.appColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _scanReceipt(fromCamera: false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadSubCategorySuggestions() async {
    if (_selectedCategory == null) {
      if (mounted) setState(() => _subCategorySuggestions = null);
      return;
    }
    final suggestions = await _subCategoryService.getSuggestions(
      _selectedCategory!,
    );
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
      barrierColor: Colors.black.withOpacity(0.85),
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: l10n.selectExpenseDate,
      cancelText: l10n.cancel,
      confirmText: l10n.select,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.appColors.primary,
              onPrimary: context.appColors.background,
              surface: context.appColors.surface,
              onSurface: context.appColors.textPrimary,
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
        backgroundColor: context.appColors.error,
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
    final result = incomeTryRate > 0 ? amountInTry / incomeTryRate : amount;

    // Debug logging for currency conversion
    debugPrint('💱 [AddExpense] _convertToIncomeCurrency:');
    debugPrint('   Input: $amount ${from.code} → ${_incomeCurrency.code}');
    debugPrint('   Rates: USD/TRY=$usdTry, EUR/TRY=$eurTry');
    debugPrint('   fromRate=${getTryValue(from.code)}, toRate=$incomeTryRate');
    debugPrint('   amountInTRY=$amountInTry, result=$result');

    return result;
  }

  Future<void> _calculate() async {
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
    final amountInIncomeCurrency = _convertToIncomeCurrency(
      amountForCalculation,
      _expenseCurrency,
    );
    final isDifferentCurrency = _expenseCurrency != _incomeCurrency;

    // Taksit bilgilerini de currency'e çevir
    final cashPriceConverted = cashPrice != null
        ? _convertToIncomeCurrency(cashPrice, _expenseCurrency)
        : null;
    final installmentTotalConverted = installmentTotal != null
        ? _convertToIncomeCurrency(installmentTotal, _expenseCurrency)
        : null;

    final financeProvider = context.read<FinanceProvider>();
    final userProfile =
        financeProvider.userProfile ??
        UserProfile(incomeSources: [], dailyHours: 8, workDaysPerWeek: 5);

    final result = _calculationService.calculateExpense(
      userProfile: userProfile,
      expenseAmount: amountInIncomeCurrency,
      month: _selectedDate.month,
      year: _selectedDate.year,
    );

    // Determine record type with new fixed thresholds
    RecordType recordType;
    if (Expense.needsSimulationDialog(amountInIncomeCurrency)) {
      // Middle range (250k-750k): ask user
      final isSimulation = await _showLargeAmountDialog();
      if (!mounted) return;
      recordType = isSimulation ? RecordType.simulation : RecordType.real;
    } else {
      // Auto-determine based on fixed thresholds
      recordType = Expense.detectRecordType(
        amountInIncomeCurrency,
        result.hoursRequired,
      );
    }

    final rawSubCat = _subCategoryController.text.trim();
    final normalizedSubCat = rawSubCat.isEmpty
        ? null
        : SubCategoryService.normalize(rawSubCat);

    final isSmartChoice =
        _smartChoiceSavedFrom != null &&
        _smartChoiceSavedFrom! > amountInIncomeCurrency;

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
      installmentStartDate: _expenseType == ExpenseType.installment
          ? _selectedDate
          : null,
    );

    final categoryInsight = _insightService.getCategoryInsight(
      context,
      financeProvider.expenses,
      _selectedCategory!,
      _selectedDate.month,
      _selectedDate.year,
    );

    // Duygusal mesaj (zorunlu gider değilse)
    String? emotionalMessage;
    if (!_isMandatory) {
      emotionalMessage = _messagesService.getCalculationMessage(
        context,
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

    final message = _messagesService.getMessageForDecision(
      context,
      decisionType,
    );

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

  Future<void> _onDecision(
    ExpenseDecision decision, {
    bool force = false,
  }) async {
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

    // "Vazgeçtim" (no) decision - ADD to expense list with decision=no for stats tracking
    // This allows DecisionStats to calculate totalSaved correctly
    // Vazgeçtim = User PASSED on the purchase = Money saved = Tracked in noTotal
    if (decision == ExpenseDecision.no && !isSimulation) {
      // Add to expense list with decision=no for Total Saved stats
      final expenseWithDecision = _pendingExpense!.copyWith(
        decision: ExpenseDecision.no,
        decisionDate: DateTime.now(),
      );
      await financeProvider.addExpense(expenseWithDecision);

      // Calculate hours for display
      final userProfile = financeProvider.userProfile;
      final hoursRequired = userProfile != null && userProfile.hourlyRate > 0
          ? amount / userProfile.hourlyRate
          : 0.0;

      // Play victory sound and show celebration
      soundService.playVictory();
      victoryManager.showVictoryAnimation(
        context,
        amount: amount,
        hours: hoursRequired,
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

      // Show celebration snackbar with motivational message
      final l10n = AppLocalizations.of(context);
      final message = _messagesService.getMessageForSavings(l10n);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(PhosphorIconsFill.star, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.appColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        widget.onExpenseAdded?.call();
        Navigator.pop(context);
      }
      return;
    }

    // For "yes" and "thinking" decisions - save the expense
    final expenseWithDecision = _pendingExpense!.copyWith(
      decision: decision,
      decisionDate: DateTime.now(),
    );

    await financeProvider.addExpense(expenseWithDecision);

    // Schedule 72h reminder for "thinking" decisions
    if (decision == ExpenseDecision.thinking && !isSimulation) {
      final currencyProvider = context.read<CurrencyProvider>();
      // Generate unique ID from expense properties
      final expenseKey =
          '${expenseWithDecision.date.millisecondsSinceEpoch}_${expenseWithDecision.amount.toInt()}';
      await NotificationService().scheduleThinkingReminder(
        expenseId: expenseKey,
        amount: amount,
        description:
            expenseWithDecision.subCategory ?? expenseWithDecision.category,
        currencySymbol: currencyProvider.currency.symbol,
      );
    }

    if (!isSimulation && subCategory != null && subCategory.isNotEmpty) {
      await _subCategoryService.addRecentSubCategory(category, subCategory);
    }

    if (!mounted) return;

    // Budget warning check (only for actual purchases)
    if (decision == ExpenseDecision.yes && !isSimulation) {
      await _checkBudgetWarning(expenseWithDecision, financeProvider.expenses);

      // Debt warning - show if pool has debt
      final savingsPoolProvider = context.read<SavingsPoolProvider>();
      if (savingsPoolProvider.hasDebt && mounted) {
        final l10n = AppLocalizations.of(context);
        final currencyProvider = context.read<CurrencyProvider>();
        final debtAmount = savingsPoolProvider.shadowDebt;
        final symbol = currencyProvider.currency.symbol;

        // Show debt warning after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      PhosphorIconsFill.warning,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.debtWarningOnPurchase(
                          '$symbol${debtAmount.toStringAsFixed(0)}',
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                backgroundColor: context.appColors.warning,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        });
      }
    }

    // Smart Choice savings (when user bought but spent less than intended)
    // Example: Intended to spend 520₺, actually spent 500₺ = 20₺ savings
    if (decision == ExpenseDecision.yes &&
        expenseWithDecision.isSmartChoice &&
        expenseWithDecision.savedAmount > 0 &&
        !isSimulation) {
      final savingsPoolProvider = context.read<SavingsPoolProvider>();
      await savingsPoolProvider.addSavings(expenseWithDecision.savedAmount);
      debugPrint(
        '💰 [AddExpenseSheet] Smart Choice savings added: ${expenseWithDecision.savedAmount}',
      );
    }

    final l10n = AppLocalizations.of(context);
    final message = isSimulation
        ? l10n.simulationSaved
        : _messagesService.getMessageForSpending(l10n);

    // Play success sound for expense confirmation (yes/thinking decisions)
    if (!isSimulation && decision != ExpenseDecision.no) {
      soundService.playSuccess();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              decision == ExpenseDecision.thinking
                  ? PhosphorIconsFill.clock
                  : PhosphorIconsFill.checkCircle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: decision == ExpenseDecision.thinking
            ? context.appColors.warning
            : context.appColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Check if we should show voice tip (after 2nd expense)
    if (!isSimulation) {
      await _checkVoiceTip();
    }

    widget.onExpenseAdded?.call();
    if (mounted) Navigator.pop(context);
  }

  /// Check if voice tip should be shown (after 2nd expense)
  Future<void> _checkVoiceTip() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenVoiceTip = prefs.getBool('hasSeenVoiceTip') ?? false;
    final expenseCount = prefs.getInt('expenseCount') ?? 0;

    // Increment expense count
    await prefs.setInt('expenseCount', expenseCount + 1);

    // Show tip after 2nd expense (count is now 2 after increment)
    if (!hasSeenVoiceTip && expenseCount + 1 >= 2) {
      await prefs.setBool('hasSeenVoiceTip', true);

      // Show with slight delay to let snackbar appear first
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showVoiceTipDialog();
          }
        });
      }
    }
  }

  /// Show voice tip dialog
  void _showVoiceTipDialog() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          PhosphorIconsFill.microphone,
          size: 48,
          color: context.appColors.primary,
        ),
        title: Text(
          l10n.didYouKnow,
          style: TextStyle(color: context.appColors.textPrimary),
        ),
        content: Text(
          l10n.voiceTipMessage,
          style: TextStyle(color: context.appColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.gotIt,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VoiceInputScreen()),
              );
            },
            child: Text(l10n.tryNow),
          ),
        ],
      ),
    );
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

  /// Show dialog to ask user if large amount (250k-750k) is real or simulation
  Future<bool> _showLargeAmountDialog() async {
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              PhosphorIconsFill.currencyCircleDollar,
              color: context.appColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.largeAmountTitle,
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
          l10n.largeAmountMessage,
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          // Real expense button
          TextButton(
            onPressed: () => Navigator.pop(context, false), // false = real
            child: Text(
              l10n.realExpenseButton,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          // Simulation button
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // true = simulation
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.simulationButton),
          ),
        ],
      ),
    );

    return result ?? false; // Default to real expense if dialog dismissed
  }

  Future<bool> _showDuplicateWarningDialog(DuplicateMatch match) async {
    final l10n = AppLocalizations.of(context);
    final timeAgoText = _formatTimeAgo(match.timeSinceEntry, l10n);
    final amountStr = match.expense.amount.toStringAsFixed(0);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(PhosphorIconsFill.warning, color: Colors.amber, size: 24),
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
          '${l10n.duplicateExpenseDetails(amountStr, ExpenseCategory.getLocalizedName(match.expense.category, l10n))}\n'
          '($timeAgoText)\n\n'
          '${l10n.addAnyway}',
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.no,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primary,
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

  /// Check if expense affects budget and show warning
  Future<void> _checkBudgetWarning(
    Expense expense,
    List<Expense> allExpenses,
  ) async {
    final budgetProvider = context.read<CategoryBudgetProvider>();
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.read<CurrencyProvider>();

    // Update provider with latest expenses
    await budgetProvider.updateExpenses(allExpenses);

    // Check budget impact
    final budgetCheck = await budgetProvider.checkExpenseImpact(
      expense.category,
      expense.amount,
    );

    if (!budgetCheck.hasBudget || !mounted) return;

    final convertedAmount = currencyProvider.convertFromTRY(
      budgetCheck.amountOver,
    );

    if (budgetCheck.wouldExceed) {
      // Show over budget warning
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(PhosphorIconsFill.warning, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.budgetExceededMessage(
                    ExpenseCategory.getLocalizedName(expense.category, l10n),
                    '${currencyProvider.symbol}${formatTurkishCurrency(convertedAmount, decimalDigits: 0)}',
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: context.appColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: l10n.viewAll,
            textColor: Colors.white,
            onPressed: () {
              // Navigate to budget screen or show budget sheet
            },
          ),
        ),
      );
    } else if (budgetCheck.wouldBeNearLimit) {
      // Show near limit warning
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                PhosphorIconsFill.warningCircle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.budgetNearLimitMessage(
                    budgetCheck.percentAfter.toStringAsFixed(0),
                    ExpenseCategory.getLocalizedName(expense.category, l10n),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: context.appColors.warning,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
                color: context.appColors.gradientMid,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: context.appColors.cardBorder,
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
                        color: context.appColors.textTertiary.withValues(
                          alpha: 0.5,
                        ),
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
                              widget.isEditMode
                                  ? l10n.editExpense
                                  : l10n.newExpense,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: context.appColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  PhosphorIconsDuotone.calendar,
                                  size: 14,
                                  color: context.appColors.textTertiary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDisplayDate(_selectedDate, l10n),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: context.appColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          tooltip: l10n.accessibilityCloseSheet,
                          icon: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: context.appColors.surfaceLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              PhosphorIconsDuotone.x,
                              size: 20,
                              color: context.appColors.textSecondary,
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
        ExpenseDateChip(
          label: l10n.yesterday,
          isSelected: _selectedDateChip == 'yesterday',
          onTap: _selectYesterday,
        ),
        const SizedBox(width: 8),
        ExpenseDateChip(
          label: l10n.twoDaysAgo,
          isSelected: _selectedDateChip == 'twoDaysAgo',
          onTap: _selectTwoDaysAgo,
        ),
        const SizedBox(width: 8),
        ExpenseDateChip(
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
              style: TextStyle(
                fontSize: 12,
                color: context.appColors.primary,
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: context.appColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Column(
        children: [
          // Top row: Amount input (full width)
          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [TurkishCurrencyInputFormatter()],
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0,00',
              hintStyle: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: context.appColors.textTertiary.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: _onAmountChanged,
          ),
          const SizedBox(height: 12),
          // Bottom row: Currency selector (left) + Scan/Voice buttons (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Currency dropdown (left)
              _buildCurrencyDropdown(),
              // Scan + Voice buttons (right)
              Row(
                children: [
                  _buildScanButton(l10n),
                  const SizedBox(width: 8),
                  _buildVoiceButton(l10n),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Voice input button
  Widget _buildVoiceButton(AppLocalizations l10n) {
    return Semantics(
      label: l10n.voiceInput,
      button: true,
      child: GestureDetector(
        onTap: _openVoiceInput,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.appColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.appColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            PhosphorIconsFill.microphone,
            size: 22,
            color: context.appColors.primary,
          ),
        ),
      ),
    );
  }

  /// Open voice input screen and handle result
  Future<void> _openVoiceInput() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const VoiceInputScreen(returnResult: true),
      ),
    );

    if (result != null && mounted) {
      // Auto-fill from voice result
      if (result['amount'] != null) {
        _amountController.text = formatTurkishCurrency(
          (result['amount'] as num).toDouble(),
          decimalDigits: 2,
        );
        _onAmountChanged(_amountController.text);
      }
      if (result['description'] != null &&
          (result['description'] as String).isNotEmpty) {
        _descriptionController.text = result['description'] as String;
      }
      if (result['category'] != null) {
        setState(() {
          _selectedCategory = result['category'] as String;
        });
      }
    }
  }

  /// Receipt scan button
  Widget _buildScanButton(AppLocalizations l10n) {
    return Semantics(
      label: l10n.scanReceipt,
      button: true,
      child: GestureDetector(
        onTap: _isScanning ? null : _showScanOptions,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.appColors.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.appColors.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: _isScanning
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.appColors.secondary,
                    ),
                  ),
                )
              : Icon(
                  PhosphorIconsDuotone.camera,
                  size: 22,
                  color: context.appColors.secondary,
                ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    final isPro = context.watch<ProProvider>().isPro;

    // FREE users see locked currency display
    if (!isPro) {
      return GestureDetector(
        onTap: () => MultiCurrencyProSheet.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.appColors.textTertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.appColors.textTertiary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                CurrencyHelper.getDisplay(_expenseCurrency.code),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textTertiary,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                PhosphorIconsRegular.lock,
                size: 14,
                color: context.appColors.textTertiary,
              ),
            ],
          ),
        ),
      );
    }

    // PRO users get full dropdown
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.appColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.appColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _expenseCurrency.code,
          icon: Icon(
            PhosphorIconsFill.caretDown,
            size: 16,
            color: context.appColors.primary,
          ),
          dropdownColor: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.appColors.primary,
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
                      ? context.appColors.primary
                      : context.appColors.textPrimary,
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
      style: TextStyle(color: context.appColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: l10n.descriptionLabel,
        labelStyle: TextStyle(
          color: context.appColors.textSecondary,
          fontSize: 14,
        ),
        hintText: l10n.descriptionHint,
        hintStyle: TextStyle(
          color: context.appColors.textTertiary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: context.appColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
          borderSide: BorderSide(color: context.appColors.primary, width: 1.5),
        ),
        suffixIcon: _smartMatchActive
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  PhosphorIconsDuotone.sparkle,
                  size: 18,
                  color: context.appColors.success,
                ),
              )
            : null,
      ),
      onChanged: _onDescriptionChanged,
    );
  }

  Widget _buildCategoryDropdown(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _smartMatchAnimController,
        _attentionAnimController,
      ]),
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
                        color: context.appColors.success.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : _categoryValidationError
                  ? [
                      BoxShadow(
                        color: context.appColors.error.withValues(alpha: 0.3),
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
                    style: TextStyle(
                      color: context.appColors.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                  items: ExpenseCategory.all.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        ExpenseCategory.getLocalizedName(category, l10n),
                      ),
                    );
                  }).toList(),
                  onChanged: _onCategoryManuallySelected,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    labelStyle: TextStyle(
                      color: _categoryValidationError
                          ? context.appColors.error
                          : context.appColors.textSecondary,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: context.appColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _categoryValidationError
                            ? context.appColors.error
                            : context.appColors.cardBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _categoryValidationError
                            ? context.appColors.error
                            : (_smartMatchActive
                                  ? context.appColors.success
                                  : context.appColors.cardBorder),
                        width: _smartMatchActive || _categoryValidationError
                            ? 1.5
                            : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: context.appColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  dropdownColor: context.appColors.surface,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                if (_categoryValidationError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      l10n.pleaseSelectCategory,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.error,
                      ),
                    ),
                  ),
                if (_smartMatchActive && _selectedCategory != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsDuotone.sparkle,
                          size: 14,
                          color: context.appColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.autoSelected(
                            ExpenseCategory.getLocalizedName(
                              _selectedCategory!,
                              l10n,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.success,
                          ),
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
          style: TextStyle(color: context.appColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.subCategoryOptional,
            hintStyle: TextStyle(
              color: context.appColors.textTertiary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: context.appColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
                color: context.appColors.primary,
                width: 1.5,
              ),
            ),
            suffixIcon: _subCategoryController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(PhosphorIconsDuotone.x, size: 18),
                    color: context.appColors.textTertiary,
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
        if (_showSubCategorySuggestions &&
            _subCategorySuggestions != null &&
            !_subCategorySuggestions!.isEmpty)
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
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: suggestions.recent.map((subCat) {
                return ExpenseSubCategoryChip(
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
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: suggestions.fixed.map((subCat) {
                return ExpenseSubCategoryChip(
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
              color: context.appColors.primary.withValues(alpha: 0.3),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isMandatory
                ? context.appColors.info.withValues(alpha: 0.5)
                : context.appColors.cardBorder,
          ),
        ),
        child: SwitchListTile(
          title: Text(
            'Zorunlu Gider',
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontWeight: _isMandatory ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            'Kira, fatura, kredi ödemesi gibi sabit giderler',
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 12,
            ),
          ),
          secondary: Icon(
            _isMandatory
                ? PhosphorIconsFill.lockKey
                : PhosphorIconsDuotone.lockKeyOpen,
            color: _isMandatory
                ? context.appColors.info
                : context.appColors.textTertiary,
          ),
          value: _isMandatory,
          onChanged: (value) => setState(() => _isMandatory = value),
          activeTrackColor: context.appColors.info,
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
          child: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _expenseType == ExpenseType.installment
                        ? context.appColors.warning.withValues(alpha: 0.5)
                        : context.appColors.cardBorder,
                  ),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Taksitli Alım',
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontWeight: _expenseType == ExpenseType.installment
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    'Kredi kartı veya mağaza taksiti',
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  secondary: Icon(
                    PhosphorIconsDuotone.creditCard,
                    color: _expenseType == ExpenseType.installment
                        ? context.appColors.warning
                        : context.appColors.textTertiary,
                  ),
                  value: _expenseType == ExpenseType.installment,
                  onChanged: (value) {
                    setState(() {
                      _expenseType = value
                          ? ExpenseType.installment
                          : ExpenseType.single;
                      _showInstallmentDetails = value;
                      // Auto-copy amount to installment total when toggle is enabled
                      if (value &&
                          _installmentTotalController.text.isEmpty &&
                          _amountController.text.isNotEmpty) {
                        _installmentTotalController.text =
                            _amountController.text;
                      }
                    });
                  },
                  activeTrackColor: context.appColors.warning,
                ),
              );
            },
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
        color: context.appColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.appColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                PhosphorIconsDuotone.info,
                color: context.appColors.warning,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Taksit Bilgileri',
                style: TextStyle(
                  color: context.appColors.warning,
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
            style: TextStyle(color: context.appColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Peşin Fiyat',
              labelStyle: TextStyle(color: context.appColors.textSecondary),
              hintText: 'Ürünün peşin fiyatı',
              hintStyle: TextStyle(color: context.appColors.textTertiary),
              prefixText: '${_expenseCurrency.symbol} ',
              prefixStyle: TextStyle(color: context.appColors.textPrimary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.appColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.appColors.warning),
              ),
              filled: true,
              fillColor: context.appColors.surface,
            ),
            onChanged: (_) => _updateInstallmentSummary(),
          ),
          const SizedBox(height: 12),

          // Taksit sayısı
          DropdownButtonFormField<int>(
            value: int.tryParse(_installmentCountController.text),
            dropdownColor: context.appColors.cardBackground,
            style: TextStyle(color: context.appColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Taksit Sayısı',
              labelStyle: TextStyle(color: context.appColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.appColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.appColors.warning),
              ),
              filled: true,
              fillColor: context.appColors.surface,
            ),
            items: [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 18, 24, 36]
                .map(
                  (n) => DropdownMenuItem(value: n, child: Text('$n taksit')),
                )
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
            style: TextStyle(color: context.appColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Taksitli Toplam Fiyat',
              labelStyle: TextStyle(color: context.appColors.textSecondary),
              hintText: 'Vade farkı dahil toplam',
              hintStyle: TextStyle(color: context.appColors.textTertiary),
              prefixText: '${_expenseCurrency.symbol} ',
              prefixStyle: TextStyle(color: context.appColors.textPrimary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.appColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.appColors.warning),
              ),
              filled: true,
              fillColor: context.appColors.surface,
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
    final installmentTotal = parseTurkishCurrency(
      _installmentTotalController.text,
    );
    final installmentCount = int.tryParse(_installmentCountController.text);

    // Hesaplama yapılamıyorsa boş döndür
    if (cashPrice == null ||
        installmentTotal == null ||
        installmentCount == null) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAKSİT ÖZETİ',
            style: TextStyle(
              color: context.appColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          _summaryRow(
            'Aylık taksit:',
            '${_expenseCurrency.symbol}${formatTurkishCurrency(monthlyPayment, decimalDigits: 0)}',
          ),
          _summaryRow('Taksit sayısı:', '$installmentCount ay'),
          Divider(color: context.appColors.cardBorder, height: 16),
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
                color: context.appColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsFill.warning,
                    color: context.appColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Peşin alsaydın ${interestHours.toStringAsFixed(0)} saat kazanırdın!',
                      style: TextStyle(
                        color: context.appColors.error,
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
              color: context.appColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight
                  ? context.appColors.warning
                  : context.appColors.textPrimary,
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
              color: context.appColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.appColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsDuotone.info,
                  color: context.appColors.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Zorunlu gider olarak kaydedilecek',
                    style: TextStyle(
                      color: context.appColors.info,
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
                  colors: [
                    context.appColors.info,
                    context.appColors.info.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.info.withValues(alpha: 0.3),
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
              style: TextStyle(color: context.appColors.textSecondary),
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
          backgroundColor: context.appColors.success,
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
      await _subCategoryService.addRecentSubCategory(
        _selectedCategory!,
        subCategory,
      );
    }

    // Callback ve kapat
    widget.onExpenseAdded?.call();

    if (mounted) {
      soundService.playSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Zorunlu gider kaydedildi'),
          backgroundColor: context.appColors.info,
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
          amountCurrencyCode: _incomeCurrency.code,
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
                foregroundColor: context.appColors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
                    color: context.appColors.primary.withValues(alpha: 0.3),
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
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
        ],
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
    barrierColor: Colors.black.withOpacity(0.85),
    builder: (context) => AddExpenseSheet(
      exchangeRates: exchangeRates,
      onExpenseAdded: onExpenseAdded,
      existingExpense: existingExpense,
      onExpenseUpdated: onExpenseUpdated,
    ),
  );
}
