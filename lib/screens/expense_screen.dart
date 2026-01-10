import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../theme/theme.dart';
import '../providers/providers.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'subscription_screen.dart';
import 'habit_calculator_screen.dart';

class ExpenseScreen extends StatefulWidget {
  final UserProfile userProfile;
  final ExchangeRates? exchangeRates;
  final bool isLoadingRates;
  final bool hasRateError;
  final VoidCallback? onRetryRates;
  final VoidCallback? onStreakUpdated;

  const ExpenseScreen({
    super.key,
    required this.userProfile,
    this.exchangeRates,
    this.isLoadingRates = false,
    this.hasRateError = false,
    this.onRetryRates,
    this.onStreakUpdated,
  });

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _descriptionController = TextEditingController();
  final _calculationService = CalculationService();
  final _insightService = InsightService();
  final _receiptScanner = ReceiptScannerService();
  final _messagesService = MessagesService();
  final _notificationService = NotificationService();
  final _subscriptionService = SubscriptionService();
  final _subCategoryService = SubCategoryService();

  late UserProfile _userProfile;
  DateTime _selectedDate = DateTime.now(); // Time-Travel için tam tarih
  String? _selectedCategory; // Default null - kullanıcı seçmeli
  final _subCategoryController = TextEditingController();
  final _subCategoryFocusNode = FocusNode();
  bool _showSubCategorySuggestions = false;
  SubCategorySuggestions? _subCategorySuggestions;
  ExpenseResult? _result;
  String? _categoryInsight;
  String? _emotionalMessage;
  Expense? _pendingExpense;
  bool _isScanning = false;
  bool _showSwipeHint = false;
  int? _editingIndex;
  final _streakWidgetKey = GlobalKey<StreakWidgetState>();
  int _upcomingSubscriptionCount = 0;

  // Smart Match & Attention Animasyonları
  late AnimationController _smartMatchAnimController;
  late AnimationController _attentionAnimController;
  late Animation<double> _smartMatchScale;
  late Animation<double> _attentionPulse;
  bool _smartMatchActive = false;
  bool _categoryValidationError = false;
  bool _userManuallySelectedCategory = false;

  // İptal ve motivasyon mesajı için
  bool _cancelledFromDecision = false;
  double? _cancelledAmount;
  double? _cancelledHoursRequired;

  // Wealth Coach: Smart Choice
  double? _smartChoiceSavedFrom;

  // Time-Travel tarih sabitleri
  DateTime get _today => DateTime.now();
  DateTime get _yesterday => _today.subtract(const Duration(days: 1));
  DateTime get _twoDaysAgo => _today.subtract(const Duration(days: 2));

  /// Sadece yıl/ay/gün karşılaştır (saat/dakika ignore)
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Hangi quick-select chip seçili?
  /// null = bugün (veya özel tarih - takvimle seçilmiş)
  /// 'yesterday' = dün
  /// 'twoDaysAgo' = 2 gün önce
  /// 'custom' = takvimden seçilmiş özel tarih
  String? get _selectedDateChip {
    if (_isSameDay(_selectedDate, _today)) return null;
    if (_isSameDay(_selectedDate, _yesterday)) return 'yesterday';
    if (_isSameDay(_selectedDate, _twoDaysAgo)) return 'twoDaysAgo';
    return 'custom';
  }

  // Provider getter
  FinanceProvider get _financeProvider => context.read<FinanceProvider>();

  static const _keySwipeHintShown = 'swipe_hint_shown';

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// Ay isimleri - localization ile
  List<String> _getMonthNames(AppLocalizations l10n) => [
    l10n.monthJanuary, l10n.monthFebruary, l10n.monthMarch, l10n.monthApril,
    l10n.monthMay, l10n.monthJune, l10n.monthJuly, l10n.monthAugust,
    l10n.monthSeptember, l10n.monthOctober, l10n.monthNovember, l10n.monthDecember
  ];

  /// Selamlama mesajı
  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  /// Header aksiyon butonu - Premium Glassmorphism style
  Widget _buildHeaderAction({
    required IconData icon,
    int? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 20, color: AppColors.textSecondary),
                if (badge != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Takvim ile tarih seç
  Future<void> _showCalendarDatePicker() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDatePicker(
      context: context,
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

  /// Quick date selection: Dün
  void _selectYesterday() {
    setState(() {
      _selectedDate = _yesterday;
      _result = null;
      _pendingExpense = null;
    });
  }

  /// Quick date selection: 2 Gün Önce
  void _selectTwoDaysAgo() {
    setState(() {
      _selectedDate = _twoDaysAgo;
      _result = null;
      _pendingExpense = null;
    });
  }

  /// Quick date selection: Bugün
  void _selectToday() {
    setState(() {
      _selectedDate = _today;
      _result = null;
      _pendingExpense = null;
    });
  }

  /// Tarih gösterim formatı
  String _formatDisplayDate(DateTime date, AppLocalizations l10n) {
    if (_isSameDay(date, _today)) return l10n.today;
    if (_isSameDay(date, _yesterday)) return l10n.yesterday;
    if (_isSameDay(date, _twoDaysAgo)) return l10n.twoDaysAgo;
    final monthNames = _getMonthNames(l10n);
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _userProfile = widget.userProfile;
    _checkSwipeHint();
    _loadUpcomingSubscriptions();
    _loadSubCategorySuggestions();

    // CategoryLearningService'i başlat
    CategoryLearningService.initialize();

    // Smart match animasyonu (kategori seçildiğinde)
    _smartMatchAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _smartMatchScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _smartMatchAnimController, curve: Curves.easeOutBack),
    );

    // Attention (pulse) animasyonu (kategori seçilmemiş uyarısı)
    _attentionAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _attentionPulse = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _attentionAnimController, curve: Curves.easeInOut),
    );

    // Alt kategori focus listener
    _subCategoryFocusNode.addListener(() {
      if (_subCategoryFocusNode.hasFocus) {
        setState(() => _showSubCategorySuggestions = true);
      }
    });
  }

  Future<void> _loadUpcomingSubscriptions() async {
    final upcoming = await _subscriptionService.getUpcomingSubscriptions(withinDays: 3);
    if (mounted) {
      setState(() => _upcomingSubscriptionCount = upcoming.length);
    }
  }

  void _showSubscriptionSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    ).then((_) => _loadUpcomingSubscriptions());
  }

  void _openHabitCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HabitCalculatorScreen()),
    );
  }

  Widget _buildHabitCalculatorBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _openHabitCalculator,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text(
                '⚡',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.habitQuestion,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.calculateAndShock,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: Colors.white.withValues(alpha: 0.8),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkSwipeHint() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_keySwipeHintShown) ?? false;
    if (!shown) {
      setState(() => _showSwipeHint = true);
      await prefs.setBool(_keySwipeHintShown, true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _descriptionController.dispose();
    _subCategoryController.dispose();
    _subCategoryFocusNode.dispose();
    _receiptScanner.dispose();
    _smartMatchAnimController.dispose();
    _attentionAnimController.dispose();
    super.dispose();
  }

  /// Alt kategori önerilerini yükle
  Future<void> _loadSubCategorySuggestions() async {
    // Kategori seçilmediyse öneri gösterme
    if (_selectedCategory == null) {
      if (mounted) {
        setState(() => _subCategorySuggestions = null);
      }
      return;
    }
    final suggestions = await _subCategoryService.getSuggestions(_selectedCategory!);
    if (mounted) {
      setState(() => _subCategorySuggestions = suggestions);
    }
  }

  /// Açıklama değiştiğinde smart match yap
  void _onDescriptionChanged(String text) {
    // Kullanıcı manuel seçtiyse smart match yapma
    if (_userManuallySelectedCategory) return;

    final predicted = CategoryLearningService.predictCategory(text);
    if (predicted != null && ExpenseCategory.all.contains(predicted)) {
      setState(() {
        _selectedCategory = predicted;
        _smartMatchActive = true;
        _categoryValidationError = false;
      });

      // Smart match animasyonu
      _smartMatchAnimController.forward().then((_) {
        _smartMatchAnimController.reverse();
      });

      // Alt kategori önerilerini güncelle
      _loadSubCategorySuggestions();
    }
  }

  /// Kategori manuel seçildiğinde
  void _onCategoryManuallySelected(String? category) {
    if (category == null) return;

    setState(() {
      _selectedCategory = category;
      _userManuallySelectedCategory = true;
      _categoryValidationError = false;
      _smartMatchActive = false;
    });

    // Animasyon durdur
    _attentionAnimController.stop();
    _attentionAnimController.reset();

    // Alt kategori önerilerini güncelle
    _loadSubCategorySuggestions();

    // Kullanıcının seçimini öğren (açıklama varsa)
    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) {
      CategoryLearningService.learn(description, category);
    }
  }

  /// Tutar değiştiğinde attention animasyonunu kontrol et
  void _onAmountChanged(String text) {
    final amount = parseTurkishCurrency(text);
    final hasValidAmount = amount != null && amount > 0;

    if (hasValidAmount && _selectedCategory == null) {
      // Tutar var ama kategori yok - attention başlat
      _attentionAnimController.repeat(reverse: true);
    } else {
      // Kategori seçilmiş veya tutar yok - attention durdur
      _attentionAnimController.stop();
      _attentionAnimController.reset();
    }
  }

  Future<void> _scanReceipt(bool fromCamera) async {
    setState(() => _isScanning = true);

    try {
      final imageFile = await _receiptScanner.pickImage(fromCamera: fromCamera);
      if (imageFile == null) {
        setState(() => _isScanning = false);
        return;
      }

      final amount = await _receiptScanner.extractTotalFromReceipt(imageFile);

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      if (amount != null) {
        // Türkçe para formatına çevir
        _controller.text = formatTurkishCurrency(amount);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.amountFound(formatTurkishCurrency(amount))),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.amountNotFound),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.scanError),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Column(
                    children: [
                      _buildScanOption(
                        icon: LucideIcons.camera,
                        label: l10n.cameraCapture,
                        onTap: () {
                          Navigator.pop(context);
                          _scanReceipt(true);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildScanOption(
                        icon: LucideIcons.image,
                        label: l10n.selectFromGallery,
                        onTap: () {
                          Navigator.pop(context);
                          _scanReceipt(false);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Alt kategori chip önerilerini oluştur
  Widget _buildSubCategoryChips() {
    final suggestions = _subCategorySuggestions;
    if (suggestions == null || suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Son kullanılanlar (varsa)
          if (suggestions.hasRecent) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                AppLocalizations.of(context)!.recentlyUsed,
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
            if (suggestions.hasFixed)
              const SizedBox(height: 12),
          ],
          // Sabit öneriler (varsa)
          if (suggestions.hasFixed) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                AppLocalizations.of(context)!.suggestions,
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

  /// Chip'e basınca alt kategori seç
  void _selectSubCategory(String subCategory) {
    _subCategoryController.text = subCategory;
    setState(() {
      _showSubCategorySuggestions = false;
    });
    _subCategoryFocusNode.unfocus();
  }

  Future<void> _updateDecision(int index, ExpenseDecision newDecision) async {
    final expenses = _financeProvider.expenses;
    if (index < 0 || index >= expenses.length) return;

    final expense = expenses[index];
    await _financeProvider.updateDecision(index, newDecision);

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final message = switch (newDecision) {
      ExpenseDecision.yes => l10n.decisionUpdatedBought,
      ExpenseDecision.no => l10n.decisionSaved(formatTurkishCurrency(expense.amount, decimalDigits: 2)),
      ExpenseDecision.thinking => l10n.keepThinking,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _editExpense(int index) {
    final expenses = _financeProvider.expenses;
    if (index < 0 || index >= expenses.length) return;

    final expense = expenses[index];
    // Türkçe para formatına çevir (1234.50 → 1.234,50)
    _controller.text = formatTurkishCurrency(expense.amount);
    setState(() {
      _selectedCategory = expense.category;
      _selectedDate = expense.date;
      _editingIndex = index;
    });
  }

  Future<void> _saveEdit() async {
    if (_editingIndex == null) return;

    final expenses = _financeProvider.expenses;
    if (_editingIndex! < 0 || _editingIndex! >= expenses.length) return;

    final l10n = AppLocalizations.of(context)!;

    // Türkçe para formatını parse et
    final amount = parseTurkishCurrency(_controller.text);

    // Validasyon
    if (amount == null) {
      _showError(l10n.validationEnterAmount);
      return;
    }

    if (amount <= 0) {
      _showError(l10n.validationAmountPositive);
      return;
    }

    if (amount > 100000000) {
      _showError(l10n.validationAmountTooHigh);
      return;
    }

    // Kategori validasyonu
    if (_selectedCategory == null) {
      setState(() => _categoryValidationError = true);
      _showError(l10n.pleaseSelectCategory);
      _attentionAnimController.repeat(reverse: true);
      return;
    }

    final oldExpense = expenses[_editingIndex!];
    final result = _calculationService.calculateExpense(
      userProfile: _userProfile,
      expenseAmount: amount,
      month: _selectedDate.month,
      year: _selectedDate.year,
    );

    final updated = Expense(
      amount: amount,
      category: _selectedCategory!,
      date: _selectedDate,
      hoursRequired: result.hoursRequired,
      daysRequired: result.daysRequired,
      decision: oldExpense.decision,
      decisionDate: oldExpense.decisionDate,
    );

    await _financeProvider.updateExpense(_editingIndex!, updated);

    _cancelEdit();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.expenseUpdated)),
    );
  }

  void _cancelEdit() {
    _controller.clear();
    _descriptionController.clear();
    _subCategoryController.clear();
    setState(() {
      _editingIndex = null;
      _selectedCategory = null;
      _selectedDate = DateTime.now();
      _showSubCategorySuggestions = false;
      _userManuallySelectedCategory = false;
      _smartMatchActive = false;
      _categoryValidationError = false;
      _smartChoiceSavedFrom = null; // Wealth Coach
    });
    _attentionAnimController.stop();
    _attentionAnimController.reset();
    _loadSubCategorySuggestions();
  }

  void _calculate() {
    final l10n = AppLocalizations.of(context)!;

    // Türkçe para formatını parse et (1.234,50 → 1234.50)
    final amount = parseTurkishCurrency(_controller.text);

    // Validasyon
    if (amount == null) {
      _showError(l10n.validationEnterAmount);
      return;
    }

    if (amount <= 0) {
      _showError(l10n.validationAmountPositive);
      return;
    }

    if (amount > 100000000) {
      _showError(l10n.validationAmountTooHigh);
      return;
    }

    // Kategori validasyonu
    if (_selectedCategory == null) {
      setState(() => _categoryValidationError = true);
      _showError(l10n.pleaseSelectCategory);
      // Attention animasyonunu başlat
      _attentionAnimController.repeat(reverse: true);
      return;
    }

    final result = _calculationService.calculateExpense(
      userProfile: _userProfile,
      expenseAmount: amount,
      month: _selectedDate.month,
      year: _selectedDate.year,
    );

    // Simülasyon tespiti
    final recordType = Expense.detectRecordType(amount, result.hoursRequired);

    // Alt kategori - normalize et, boş ise null
    final rawSubCat = _subCategoryController.text.trim();
    final normalizedSubCat = rawSubCat.isEmpty
        ? null
        : SubCategoryService.normalize(rawSubCat);

    // Wealth Coach: Smart Choice değerlerini belirle
    final isSmartChoice = _smartChoiceSavedFrom != null && _smartChoiceSavedFrom! > amount;

    final expense = Expense(
      amount: amount,
      category: _selectedCategory!,
      subCategory: normalizedSubCat,
      date: _selectedDate,
      hoursRequired: result.hoursRequired,
      daysRequired: result.daysRequired,
      recordType: recordType,
      // Wealth Coach: Smart Choice
      savedFrom: _smartChoiceSavedFrom,
      isSmartChoice: isSmartChoice,
    );

    final categoryInsight = _insightService.getCategoryInsight(
      _financeProvider.expenses,
      _selectedCategory!,
      _selectedDate.month,
      _selectedDate.year,
    );

    final emotionalMessage = _messagesService.getCalculationMessage(
      result.hoursRequired,
      amount,
    );

    setState(() {
      _result = result;
      _pendingExpense = expense;
      _categoryInsight = categoryInsight;
      _emotionalMessage = emotionalMessage;
      // Hesapla'ya basıldığında iptal durumunu sıfırla
      _cancelledFromDecision = false;
      _cancelledAmount = null;
      _cancelledHoursRequired = null;
    });
  }

  String _getEmotionalMessage(ExpenseDecision decision, double amount) {
    final decisionType = switch (decision) {
      ExpenseDecision.yes => DecisionType.yes,
      ExpenseDecision.no => DecisionType.no,
      ExpenseDecision.thinking => DecisionType.thinking,
    };

    // MessagesService'den mesaj al
    final message = _messagesService.getMessageForDecision(decisionType);

    // Vazgeçtim için kurtarılan tutarı ekle
    if (decision == ExpenseDecision.no) {
      final rates = widget.exchangeRates;
      if (rates != null && rates.goldRate > 0) {
        final goldGrams = amount / rates.goldRate;
        return '$message (${goldGrams.toStringAsFixed(1)}g altın)';
      }
      return '$message (${formatTurkishCurrency(amount, decimalDigits: 2)} TL)';
    }

    return message;
  }

  Future<void> _onDecision(ExpenseDecision decision) async {
    if (_pendingExpense == null) return;

    final amount = _pendingExpense!.amount;
    final isSimulation = _pendingExpense!.isSimulation;
    final category = _pendingExpense!.category;
    final subCategory = _pendingExpense!.subCategory;
    final expenseWithDecision = _pendingExpense!.copyWith(
      decision: decision,
      decisionDate: DateTime.now(),
    );

    // Önce UI'ı temizle
    setState(() {
      _result = null;
      _pendingExpense = null;
      _categoryInsight = null;
      _emotionalMessage = null;
      _showSubCategorySuggestions = false;
      _selectedCategory = null;
      _selectedDate = DateTime.now();
      _userManuallySelectedCategory = false;
      _smartMatchActive = false;
      _categoryValidationError = false;
      _smartChoiceSavedFrom = null; // Wealth Coach
    });
    _controller.clear();
    _descriptionController.clear();
    _subCategoryController.clear();
    _attentionAnimController.stop();
    _attentionAnimController.reset();

    // Harcamayı Provider üzerinden kaydet (otomatik notifyListeners)
    await _financeProvider.addExpense(expenseWithDecision);

    // Gerçek kayıtlar için alt kategoriyi son kullanılanlara ekle
    if (!isSimulation && subCategory != null && subCategory.isNotEmpty) {
      await _subCategoryService.addRecentSubCategory(category, subCategory);
      // Önerileri güncelle
      _loadSubCategorySuggestions();
    }

    // Simülasyonlar streak ve bildirimleri etkilemez
    if (!isSimulation) {
      // Streak widget'ı yenile
      _streakWidgetKey.currentState?.refresh();
      widget.onStreakUpdated?.call();

      // Streak hatırlatmasını iptal et (bugün giriş yapıldı)
      await _notificationService.cancelStreakReminder();

      // Karara göre bildirim planla
      final streakData = _financeProvider.streakData;
      if (decision == ExpenseDecision.yes) {
        // Gecikmiş farkındalık bildirimi
        await _notificationService.scheduleDelayedAwareness(
          amount: amount,
          currentStreak: streakData.currentStreak,
        );
      } else if (decision == ExpenseDecision.no) {
        // Vazgeçmeyi güçlendirme bildirimi
        await _notificationService.scheduleReinforceDecision();
      }
    }

    if (!mounted) return;

    // İrade Zaferi kutlaması - Vazgeçtim kararında confetti göster
    if (decision == ExpenseDecision.no && !isSimulation) {
      final freedomHours = expenseWithDecision.hoursRequired;
      victoryManager.showVictoryAnimation(
        context,
        amount: amount,
        hours: freedomHours,
      );
    }

    // Simülasyon için özel mesaj
    if (isSimulation) {
      _showSimulationMessage();
    } else {
      final message = _getEmotionalMessage(decision, amount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Karar ekranından İptal - giriş ekranına dön, verileri koru
  void _cancelDecision() {
    if (_pendingExpense == null) return;

    // İptal bilgilerini sakla (motivasyon mesajı için)
    _cancelledFromDecision = true;
    _cancelledAmount = _pendingExpense!.amount;
    _cancelledHoursRequired = _pendingExpense!.hoursRequired;

    // Sadece sonuç ve pending expense'i temizle, form verilerini koru
    setState(() {
      _result = null;
      _pendingExpense = null;
      _categoryInsight = null;
      _emotionalMessage = null;
    });
  }

  /// Formu tamamen temizle (yeni harcama için veya iptal sonrası çıkış)
  void _clearFormCompletely() {
    // Eğer karar ekranından iptal edildiyse ve şimdi formu temizliyorsak
    // motivasyon mesajı göster
    if (_cancelledFromDecision && _cancelledAmount != null && _cancelledHoursRequired != null) {
      final l10n = AppLocalizations.of(context)!;
      final hours = _cancelledHoursRequired!;
      final hoursText = hours < 1
          ? l10n.minutesRequired((hours * 60).round())
          : l10n.hoursRequired(hours.toStringAsFixed(1));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🎉 '),
              Expanded(
                child: Text(
                  l10n.freedomCloser(hoursText),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }

    // Tüm state'i sıfırla
    _controller.clear();
    _descriptionController.clear();
    _subCategoryController.clear();
    setState(() {
      _result = null;
      _pendingExpense = null;
      _categoryInsight = null;
      _emotionalMessage = null;
      _selectedCategory = null;
      _selectedDate = DateTime.now();
      _userManuallySelectedCategory = false;
      _smartMatchActive = false;
      _categoryValidationError = false;
      _showSubCategorySuggestions = false;
      _cancelledFromDecision = false;
      _cancelledAmount = null;
      _cancelledHoursRequired = null;
      _smartChoiceSavedFrom = null; // Wealth Coach
    });
    _attentionAnimController.stop();
    _attentionAnimController.reset();
    _loadSubCategorySuggestions();
  }

  void _showSimulationMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    LucideIcons.brain,
                    size: 32,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.simulationSaved,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.simulationDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.info,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.simulationInfo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.understood,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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

  Future<void> _deleteExpense(int index) async {
    await _financeProvider.deleteExpense(index);
  }

  @override
  Widget build(BuildContext context) {
    // Provider'dan reaktif olarak veri al
    final financeProvider = context.watch<FinanceProvider>();
    final expenses = financeProvider.expenses;
    final stats = financeProvider.stats;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.background,
        ),
        child: SafeArea(
        bottom: false, // Nav bar için
        child: CustomScrollView(
          slivers: [
            // Premium Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Başlık
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(l10n),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.financialStatus,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Aksiyonlar
                    Row(
                      children: [
                        // Abonelik takvimi
                        Showcase(
                          key: TourKeys.subscriptionButton,
                          title: l10n.subscriptions,
                          description: l10n.subscriptionsDescription,
                          titleTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          descTextStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          tooltipBackgroundColor: AppColors.surface,
                          targetBorderRadius: BorderRadius.circular(14),
                          child: _buildHeaderAction(
                            icon: LucideIcons.calendar,
                            badge: _upcomingSubscriptionCount > 0 ? _upcomingSubscriptionCount : null,
                            onTap: _showSubscriptionSheet,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Streak
                        Showcase(
                          key: TourKeys.streakWidget,
                          title: l10n.streakTracking,
                          description: l10n.streakTrackingDescription,
                          titleTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          descTextStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          tooltipBackgroundColor: AppColors.surface,
                          targetBorderRadius: BorderRadius.circular(14),
                          child: StreakWidget(key: _streakWidgetKey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Yaklaşan Abonelik Yenileme Uyarısı
            SliverToBoxAdapter(
              child: RenewalWarningBanner(
                withinHours: 48,
                onTap: _showSubscriptionSheet,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Viral: Alışkanlık Hesaplayıcı Banner
            SliverToBoxAdapter(
              child: _buildHabitCalculatorBanner(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Financial Snapshot Card
            SliverToBoxAdapter(
              child: Showcase(
                key: TourKeys.financialSnapshot,
                title: l10n.financialSummary,
                description: l10n.financialSummaryDescription,
                titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
                descTextStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                tooltipBackgroundColor: AppColors.surface,
                targetBorderRadius: BorderRadius.circular(20),
                child: FinancialSnapshotCard(
                  totalIncome: financeProvider.totalMonthlyIncome,
                  totalSpent: stats.yesTotal,
                  savedAmount: stats.totalSaved, // Wealth Coach: totalSaved kullan
                  savedCount: stats.noCount + stats.smartChoiceCount,
                  incomeSourceCount: financeProvider.incomeSourceCount,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Kur widget'ı - kompakt
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Showcase(
                  key: TourKeys.currencyRates,
                  title: l10n.currencyRates,
                  description: l10n.currencyRatesDescription,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  descTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  tooltipBackgroundColor: AppColors.surface,
                  targetBorderRadius: BorderRadius.circular(16),
                  child: CurrencyRateWidget(
                    rates: widget.exchangeRates,
                    isLoading: widget.isLoadingRates,
                    hasError: widget.hasRateError,
                    onRetry: widget.onRetryRates,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Harcama Giriş Formu - Başlık
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryButton,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.newExpense,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Tarih göstergesi - Premium
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDisplayDate(_selectedDate, l10n),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Time-Travel: Hızlı tarih seçimi chip'leri
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Showcase(
                  key: TourKeys.dateChips,
                  title: l10n.pastDateSelection,
                  description: l10n.pastDateSelectionDescription,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  descTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  tooltipBackgroundColor: AppColors.surface,
                  targetBorderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      // Dün chip
                      _DateChip(
                        label: l10n.yesterday,
                        isSelected: _selectedDateChip == 'yesterday',
                        onTap: _selectYesterday,
                      ),
                      const SizedBox(width: 8),
                      // 2 Gün Önce chip
                      _DateChip(
                        label: l10n.twoDaysAgo,
                        isSelected: _selectedDateChip == 'twoDaysAgo',
                        onTap: _selectTwoDaysAgo,
                      ),
                      const SizedBox(width: 8),
                      // Takvim chip
                      _DateChip(
                        icon: LucideIcons.calendar,
                        label: _selectedDateChip == 'custom'
                            ? '${_selectedDate.day}/${_selectedDate.month}'
                            : null,
                        isSelected: _selectedDateChip == 'custom',
                        onTap: _showCalendarDatePicker,
                      ),
                      // Bugün seçiliyse hiçbir chip vurgulu değil
                      // Bugüne dönmek için tarih göstergesine tıklanabilir
                      if (_selectedDateChip != null) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: _selectToday,
                          child: Text(
                            l10n.today,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 1. Tutar alanı (en üstte)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Showcase(
                  key: TourKeys.amountField,
                  title: l10n.amountEntry,
                  description: l10n.amountEntryDescription,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  descTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  tooltipBackgroundColor: AppColors.surface,
                  targetBorderRadius: BorderRadius.circular(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: LabeledTextField(
                          controller: _controller,
                          label: l10n.amountTL,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          hint: '0,00',
                          inputFormatters: [
                            TurkishCurrencyInputFormatter(),
                          ],
                          onChanged: _onAmountChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Fiş tarama butonu
                      _isScanning
                          ? Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: IconButton(
                                onPressed: _showScanOptions,
                                icon: const Icon(LucideIcons.receipt, size: 22),
                                color: AppColors.textSecondary,
                                tooltip: l10n.scanReceipt,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Wealth Coach: Smart Choice Toggle
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SmartChoiceToggle(
                  selectedCategory: _selectedCategory,
                  currentAmount: parseTurkishCurrency(_controller.text) ?? 0,
                  onSavedFromChanged: (value) {
                    setState(() {
                      _smartChoiceSavedFrom = value;
                    });
                  },
                  isEnabled: _pendingExpense == null && _editingIndex == null,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 2. Açıklama alanı (ortada - Smart Match için)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Showcase(
                  key: TourKeys.descriptionField,
                  title: l10n.smartMatching,
                  description: l10n.smartMatchingDescription,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  descTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  tooltipBackgroundColor: AppColors.surface,
                  targetBorderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: _descriptionController,
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
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
                                LucideIcons.sparkles,
                                size: 18,
                                color: AppColors.success,
                              ),
                            )
                          : null,
                    ),
                    onChanged: _onDescriptionChanged,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 3. Kategori seçimi (en altta) - Animasyonlu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Showcase(
                  key: TourKeys.categoryField,
                  title: l10n.categorySelection,
                  description: l10n.categorySelectionDescription,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  descTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  tooltipBackgroundColor: AppColors.surface,
                  targetBorderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBuilder(
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
                            child: DropdownButtonFormField<String>(
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
                                  child: Text(category),
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
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _categoryValidationError
                                        ? AppColors.error
                                        : AppColors.cardBorder,
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
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              dropdownColor: AppColors.surface,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                      // Validation error message
                      if (_categoryValidationError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            l10n.pleaseSelectCategory,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      // Smart match indicator
                      if (_smartMatchActive && _selectedCategory != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                size: 14,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.autoSelected(_selectedCategory!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Alt kategori input (opsiyonel) + chip önerileri
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input alanı
                    TextField(
                      controller: _subCategoryController,
                      focusNode: _subCategoryFocusNode,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.subCategoryOptional,
                        hintStyle: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
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
                                icon: const Icon(LucideIcons.x, size: 18),
                                color: AppColors.textTertiary,
                                onPressed: () {
                                  _subCategoryController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                      onTap: () {
                        setState(() => _showSubCategorySuggestions = true);
                      },
                    ),
                    // Chip önerileri (focus olduğunda göster)
                    if (_showSubCategorySuggestions && _subCategorySuggestions != null && !_subCategorySuggestions!.isEmpty)
                      _buildSubCategoryChips(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Hesapla/Güncelle butonu (sadece pending yoksa göster)
            if (_pendingExpense == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: _editingIndex != null
                        ? Row(
                            children: [
                              Expanded(
                                child: AIGradientButton(
                                  text: l10n.update,
                                  onPressed: _saveEdit,
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: _cancelEdit,
                                style: TextButton.styleFrom(
                                  foregroundColor: AIFinanceTheme.textSecondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                                child: Text(l10n.cancel),
                              ),
                            ],
                          )
                        : _cancelledFromDecision
                            // İptal sonrası: Hesapla + Vazgeç butonları
                            ? Row(
                                children: [
                                  Expanded(
                                    child: AIGradientButton(
                                      text: l10n.calculate,
                                      onPressed: _calculate,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: _clearFormCompletely,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AIFinanceTheme.textSecondary,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    ),
                                    child: Text(l10n.giveUp),
                                  ),
                                ],
                              )
                            // Normal: Sadece Hesapla butonu
                            : AIGradientButton(
                                text: l10n.calculate,
                                onPressed: _calculate,
                              ),
                  ),
                ),
              ),

            // Sonuç ve karar butonları
            if (_result != null && _pendingExpense != null) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ResultCard(
                    result: _result!,
                    categoryInsight: _categoryInsight,
                    emotionalMessage: _emotionalMessage,
                    amount: _pendingExpense?.amount,
                    exchangeRates: widget.exchangeRates,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DecisionButtons(onDecision: _onDecision),
                ),
              ),
              // İptal butonu - karar ekranından geri dön
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
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
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Geçmiş başlığı
            if (expenses.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        l10n.expenseHistory,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          l10n.recordCount(expenses.length),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Harcama listesi
            expenses.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AIFinanceTheme.cardBackground,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AIFinanceTheme.cardBorder),
                                ),
                                child: Icon(
                                  LucideIcons.receipt,
                                  size: 32,
                                  color: AIFinanceTheme.iconColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.noExpenses,
                            style: AIFinanceTheme.body.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noExpensesHint,
                            style: AIFinanceTheme.label,
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ExpenseHistoryCard(
                            expense: expenses[index],
                            onDelete: () => _deleteExpense(index),
                            onEdit: () => _editExpense(index),
                            onDecisionUpdate: (decision) => _updateDecision(index, decision),
                            showHint: _showSwipeHint && index == 0,
                          )
                              .animate()
                              .fadeIn(
                                duration: 300.ms,
                                delay: (index * 100).ms,
                              )
                              .slideX(
                                begin: 0.2,
                                end: 0,
                                duration: 300.ms,
                                delay: (index * 100).ms,
                                curve: Curves.easeOutCubic,
                              );
                        },
                        childCount: expenses.length,
                      ),
                    ),
                  ),

            // Alt boşluk (bottom navigation için)
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      ),
    );
  }
}

/// Alt kategori chip widget'ı - Premium style
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
              ? AppColors.primary.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecent
                ? AppColors.primary.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
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
                  LucideIcons.history,
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

/// Time-Travel tarih seçimi chip widget'ı - Premium style
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
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
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
            if (icon != null && label != null)
              const SizedBox(width: 6),
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
