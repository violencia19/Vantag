import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/services.dart';

class FinanceProvider extends ChangeNotifier {
  final ExpenseHistoryService _expenseService = ExpenseHistoryService();
  final StreakService _streakService = StreakService();
  final AchievementsService _achievementsService = AchievementsService();
  final ProfileService _profileService = ProfileService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  final CalculationService _calculationService = CalculationService();

  static const _keyAutoRecordedDate = 'auto_recorded_subscriptions_date';

  // State
  List<Expense> _expenses = [];
  DecisionStats _stats = const DecisionStats();
  StreakData _streakData = const StreakData(currentStreak: 0, longestStreak: 0);
  List<Achievement> _achievements = [];
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isInitialized = false;

  // Widget sync parameters (cached for auto-sync after expense changes)
  String _widgetCurrencySymbol = '₺';
  String _widgetLocale = 'tr';
  String? _widgetPursuitName;
  double? _widgetPursuitProgress;
  double? _widgetPursuitTarget;

  // Getters - Genel
  UserProfile? get userProfile => _userProfile;
  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Expense> get realExpenses => _expenses.where((e) => e.isReal).toList();
  DecisionStats get stats => _stats;
  StreakData get streakData => _streakData;
  List<Achievement> get achievements => List.unmodifiable(_achievements);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Getters - Gelir (82.500 Fix Burada)
  List<IncomeSource> get incomeSources => _userProfile?.incomeSources ?? [];
  double get totalMonthlyIncome => _userProfile?.monthlyIncome ?? 0;
  int get incomeSourceCount => _userProfile?.incomeSourceCount ?? 0;

  // Getters - Salary & Balance
  int? get salaryDay => _userProfile?.salaryDay;
  double? get currentBalance => _userProfile?.currentBalance;
  bool get hasBalanceTracking => _userProfile?.currentBalance != null;

  // Getters - Abonelikler (AI Context için)
  Future<List<Subscription>> getSubscriptions() async {
    return await _subscriptionService.getSubscriptions();
  }

  Future<List<Subscription>> getActiveSubscriptions() async {
    return await _subscriptionService.getActiveSubscriptions();
  }

  // Başlatma
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([_loadExpenses(), _loadStreakData(), _loadProfile()]);
      _isInitialized = true;

      // Otomatik abonelik kayıtlarını işle
      await _processAutoSubscriptionRecords();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Bugün yenilenen ve autoRecord=true olan abonelikleri otomatik harcama olarak kaydet
  Future<void> _processAutoSubscriptionRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';

      // Bugün zaten işlenmiş mi kontrol et
      final lastProcessedDate = prefs.getString(_keyAutoRecordedDate);
      if (lastProcessedDate == todayKey) return;

      // Bugün yenilenecek ve autoRecord açık olan abonelikleri getir
      final todayRenewals = await _subscriptionService
          .getAutoRecordSubscriptionsForToday();
      if (todayRenewals.isEmpty) {
        await prefs.setString(_keyAutoRecordedDate, todayKey);
        return;
      }

      // Her abonelik için harcama oluştur
      for (final sub in todayRenewals) {
        // Hesaplama yap
        final result = _calculationService.calculateExpense(
          userProfile:
              _userProfile ??
              UserProfile(incomeSources: [], dailyHours: 8, workDaysPerWeek: 5),
          expenseAmount: sub.amount,
          month: today.month,
          year: today.year,
        );

        final expense = Expense(
          amount: sub.amount,
          category: 'Abonelik',
          subCategory: sub.name,
          date: today,
          hoursRequired: result.hoursRequired,
          daysRequired: result.daysRequired,
          decision: ExpenseDecision.yes,
          decisionDate: today,
          recordType: RecordType.real,
        );

        await addExpense(expense);
      }

      // İşlenen tarihi kaydet
      await prefs.setString(_keyAutoRecordedDate, todayKey);
    } catch (e) {
      // Hata sessizce geçilir
    }
  }

  Future<void> _loadProfile() async {
    _userProfile = await _profileService.getProfile();
  }

  Future<void> _loadExpenses() async {
    _expenses = await _expenseService.getAllExpenses();
    _calculateStats();
  }

  /// Refresh expenses from storage (e.g., after simulation cleanup)
  Future<void> refresh() async {
    await _loadExpenses();
    notifyListeners();
  }

  void _calculateStats() {
    _stats = DecisionStats.fromExpenses(realExpenses);
  }

  // ============================================
  // HARCAMA (EXPENSE) İŞLEMLERİ (Geri Getirilenler)
  // ============================================

  Future<void> addExpense(Expense expense) async {
    // Check if this is the first expense (before adding)
    final isFirstExpense = _expenses.isEmpty;

    _expenses.insert(0, expense);

    // Enforce cache limit - keep only the most recent expenses in memory
    if (_expenses.length > ExpenseHistoryService.maxLocalExpenses) {
      _expenses = _expenses
          .take(ExpenseHistoryService.maxLocalExpenses)
          .toList();
    }

    _calculateStats();
    notifyListeners();
    await _expenseService.addExpense(expense);
    if (expense.isReal) await _updateStreakAfterEntry();

    // Sync widget data after expense is added
    await _autoSyncWidget();

    // First expense celebration and referral reward
    if (isFirstExpense && expense.isReal) {
      _handleFirstExpense(expense);
    }
  }

  /// Handle first expense - schedule celebration notification and reward referrer
  Future<void> _handleFirstExpense(Expense expense) async {
    try {
      // Schedule first expense celebration notification
      final savedHours = expense.hoursRequired.toStringAsFixed(1);
      await NotificationService().scheduleFirstExpenseCelebration(
        savedHours: savedHours,
      );
      debugPrint('[FinanceProvider] First expense celebration scheduled');

      // Reward referrer if this user was referred
      await ReferralService().rewardReferrerOnFirstExpense(
        FirebaseAuth.instance.currentUser?.uid ?? '',
      );
    } catch (e) {
      debugPrint('[FinanceProvider] Error handling first expense: $e');
    }
  }

  Future<void> updateExpense(int index, Expense expense) async {
    if (index < 0 || index >= _expenses.length) return;
    _expenses[index] = expense;
    _calculateStats();
    notifyListeners();
    await _expenseService.updateExpense(index, expense);
    await _autoSyncWidget();
  }

  Future<void> deleteExpense(int index) async {
    if (index < 0 || index >= _expenses.length) return;
    _expenses.removeAt(index);
    _calculateStats();
    notifyListeners();
    await _expenseService.deleteExpense(index);
    await _autoSyncWidget();
  }

  Future<void> updateDecision(int index, ExpenseDecision decision) async {
    if (index < 0 || index >= _expenses.length) return;
    final updated = _expenses[index].copyWith(
      decision: decision,
      decisionDate: DateTime.now(),
    );
    await updateExpense(index, updated);
  }

  /// Alias for updateDecision - for backwards compatibility
  Future<void> updateExpenseDecision(
    int index,
    ExpenseDecision decision,
  ) async {
    await updateDecision(index, decision);
  }

  // ============================================
  // GELİR (INCOME) İŞLEMLERİ - STRICT FIX
  // ============================================

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    _calculateStats();
    notifyListeners();
  }

  Future<void> setIncomeSources(List<IncomeSource> sources) async {
    final updatedProfile =
        (_userProfile ?? UserProfile(dailyHours: 8, workDaysPerWeek: 5))
            .copyWith(incomeSources: List<IncomeSource>.from(sources));

    _userProfile = updatedProfile;
    _calculateStats();
    notifyListeners();
    await _profileService.saveProfile(updatedProfile);
  }

  /// Para birimi değiştiğinde tüm gelir kaynaklarını yeni para birimine convert et
  /// [convertedSources] - CurrencyProvider.convertIncomeSources() ile convert edilmiş liste
  Future<void> updateIncomeSourcesWithConversion(
    List<IncomeSource> convertedSources,
  ) async {
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(incomeSources: convertedSources);

    _calculateStats();
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);
  }

  /// Gelir kaynağının orijinal tutarını güncelle (maaş zammı vb.)
  /// Bu işlem hem mevcut hem orijinal değerleri günceller
  Future<void> updateIncomeSourceAmount({
    required String sourceId,
    required double newAmount,
    required String currencyCode,
  }) async {
    if (_userProfile == null) return;

    final sources = _userProfile!.incomeSources.map((source) {
      if (source.id == sourceId) {
        // Hem amount hem originalAmount güncellenir
        return source.copyWith(
          amount: newAmount,
          currencyCode: currencyCode,
          originalAmount: newAmount,
          originalCurrencyCode: currencyCode,
        );
      }
      return source;
    }).toList();

    await setIncomeSources(sources);
  }

  Future<void> updateWorkSchedule({
    double? dailyHours,
    int? workDaysPerWeek,
  }) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(
      dailyHours: dailyHours,
      workDaysPerWeek: workDaysPerWeek,
    );
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);
  }

  /// Set base currency (locked for FREE users)
  /// Should only be set once from first salary entry
  Future<void> setBaseCurrency(String currencyCode) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(baseCurrency: currencyCode);
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);
  }

  // ============================================
  // BÜTÇE VE TASARRUF HEDEFLERI
  // ============================================

  /// Aylık bütçe güncelle
  Future<void> updateMonthlyBudget(double? budget) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(monthlyBudget: budget);
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);
  }

  /// Tasarruf hedefi güncelle
  Future<void> updateSavingsGoal(double? goal) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(monthlySavingsGoal: goal);
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);
  }

  // ============================================
  // MAAŞ GÜNÜ VE BAKİYE YÖNETİMİ
  // ============================================

  /// Maaş gününü güncelle (1-31)
  Future<void> updateSalaryDay(int? day) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(salaryDay: day);
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);

    // Schedule payday notification
    if (day != null) {
      await NotificationService().schedulePaydayNotification(salaryDay: day);
    } else {
      await NotificationService().cancelPaydayNotification();
    }
  }

  /// Güncel bakiyeyi güncelle
  Future<void> updateCurrentBalance(double? balance) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(currentBalance: balance);
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);
  }

  /// Bakiyeden harcama düş
  Future<void> deductFromBalance(double amount) async {
    if (_userProfile == null) return;

    final currentBalance = _userProfile!.currentBalance ?? 0;
    final newBalance = currentBalance - amount;

    _userProfile = _userProfile!.copyWith(currentBalance: newBalance);
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);
  }

  /// Bakiyeye gelir ekle
  Future<void> addToBalance(double amount) async {
    if (_userProfile == null) return;

    final currentBalance = _userProfile!.currentBalance ?? 0;
    final newBalance = currentBalance + amount;

    _userProfile = _userProfile!.copyWith(currentBalance: newBalance);
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);
  }

  /// Maaş alındığını onayla
  Future<void> confirmSalaryReceived({double? newBalance}) async {
    if (_userProfile == null) return;

    final balance =
        newBalance ??
        ((_userProfile!.currentBalance ?? 0) + _userProfile!.monthlyIncome);

    _userProfile = _userProfile!.copyWith(
      lastSalaryConfirmedDate: DateTime.now(),
      currentBalance: balance,
    );
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);
  }

  /// Bugün maaş günü mü ve henüz onaylanmamış mı kontrol et
  bool get shouldShowPaydayDialog {
    if (_userProfile == null) return false;
    return _userProfile!.isPayday && !_userProfile!.isSalaryConfirmedThisMonth;
  }

  /// Maaşa kaç gün kaldı
  int get daysUntilPayday => _userProfile?.daysUntilPayday ?? -1;

  /// Saatlik ücret (fallback ile) — always returns > 0 to prevent division-by-zero
  double get hourlyRate {
    if (_userProfile == null) return 1.0;
    final rate = _userProfile!.hourlyRate;
    if (rate <= 0) {
      // Fallback: aylık gelir / 160 saat, minimum 1.0 to avoid divide-by-zero
      final fallback = _userProfile!.monthlyIncome / 160;
      return fallback > 0 ? fallback : 1.0;
    }
    return rate;
  }

  // ============================================
  // HARCAMA FİLTRELERİ VE HESAPLAMALAR
  // ============================================

  /// Bu ayki harcamalar
  List<Expense> get currentMonthExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
  }

  /// Aktif taksitler listesi
  List<Expense> get activeInstallments {
    return _expenses
        .where(
          (e) => e.type == ExpenseType.installment && !e.isInstallmentCompleted,
        )
        .toList();
  }

  /// Bu ayki zorunlu giderler toplamı
  /// NOT: "Vazgeçtim" (decision=no) harcamalar hariç
  double get mandatoryExpensesTotal {
    return currentMonthExpenses
        .where((e) => e.isMandatory && e.decision != ExpenseDecision.no)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Bu ayki isteğe bağlı giderler toplamı
  /// NOT: "Vazgeçtim" (decision=no) harcamalar hariç - bunlar gerçek harcama değil
  double get discretionaryExpensesTotal {
    return currentMonthExpenses
        .where((e) => !e.isMandatory && e.decision != ExpenseDecision.no)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // ============================================
  // HOME SCREEN WIDGET SYNC
  // ============================================

  /// Sync data to home screen widgets
  /// Call this after expenses change, or on app launch
  Future<void> syncWidgetData({
    required String currencySymbol,
    required String locale,
    String? pursuitName,
    double? pursuitProgress,
    double? pursuitTarget,
  }) async {
    try {
      // Calculate today's spending
      final todayData = getTodaySpendingData();

      // Calculate spending level
      final spendingLevel = WidgetService.calculateSpendingLevel(
        todaySpending: todayData.amount,
        dailyAverage: dailyAverageSpending,
      );

      // Update widget
      await widgetService.updateWidgetData(
        todayHours: todayData.hours,
        todayMinutes: todayData.minutes,
        todayAmount: todayData.amount,
        currencySymbol: currencySymbol,
        spendingLevel: spendingLevel,
        pursuitName: pursuitName,
        pursuitProgress: pursuitProgress,
        pursuitTarget: pursuitTarget,
        locale: locale,
      );
    } catch (e) {
      debugPrint('[FinanceProvider] Widget sync error: $e');
    }
  }

  /// Set widget sync parameters (call from main_screen on init and when params change)
  void setWidgetParams({
    required String currencySymbol,
    required String locale,
    String? pursuitName,
    double? pursuitProgress,
    double? pursuitTarget,
  }) {
    _widgetCurrencySymbol = currencySymbol;
    _widgetLocale = locale;
    _widgetPursuitName = pursuitName;
    _widgetPursuitProgress = pursuitProgress;
    _widgetPursuitTarget = pursuitTarget;
  }

  /// Auto-sync widget using cached parameters (called after expense changes)
  Future<void> _autoSyncWidget() async {
    try {
      debugPrint('[FinanceProvider] _autoSyncWidget called - currency: $_widgetCurrencySymbol, locale: $_widgetLocale');
      final todayData = getTodaySpendingData();
      debugPrint('[FinanceProvider] Today data: ${todayData.hours}h ${todayData.minutes}m, ${todayData.amount} TL');
      await syncWidgetData(
        currencySymbol: _widgetCurrencySymbol,
        locale: _widgetLocale,
        pursuitName: _widgetPursuitName,
        pursuitProgress: _widgetPursuitProgress,
        pursuitTarget: _widgetPursuitTarget,
      );
      debugPrint('[FinanceProvider] Widget sync completed');
    } catch (e) {
      debugPrint('[FinanceProvider] Auto widget sync error: $e');
    }
  }

  /// Get today's spending data for widgets
  TodaySpendingData getTodaySpendingData() {
    final now = DateTime.now();
    final todayExpenses = _expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day &&
              e.decision == ExpenseDecision.yes,
        )
        .toList();

    final totalAmount = todayExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalHoursDecimal = todayExpenses.fold(
      0.0,
      (sum, e) => sum + e.hoursRequired,
    );

    // Convert decimal hours to hours and minutes
    final hours = totalHoursDecimal.floor().toDouble();
    final minutes = ((totalHoursDecimal - hours) * 60).round();

    return TodaySpendingData(
      amount: totalAmount,
      hours: hours,
      minutes: minutes,
      expenseCount: todayExpenses.length,
    );
  }

  /// Calculate daily average spending (last 30 days)
  double get dailyAverageSpending {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentExpenses = _expenses
        .where(
          (e) =>
              e.date.isAfter(thirtyDaysAgo) &&
              e.decision == ExpenseDecision.yes,
        )
        .toList();

    if (recentExpenses.isEmpty) return 0;

    final totalAmount = recentExpenses.fold(0.0, (sum, e) => sum + e.amount);
    return totalAmount / 30;
  }

  // ============================================
  // DİĞER SERVİSLER
  // ============================================
  Future<void> _updateStreakAfterEntry() async {
    await _streakService.recordEntry();
    _streakData = await _streakService.getStreakData();
    notifyListeners();
  }

  Future<void> _loadStreakData() async =>
      _streakData = await _streakService.getStreakData();

  /// Refresh achievements with localized titles (requires BuildContext)
  Future<void> refreshAchievements(BuildContext context) async {
    _achievements = await _achievementsService.getAchievements(context);
    notifyListeners();
  }

  // ============================================
  // TAM SIFIRLAMA (WIPE)
  // ============================================

  /// Tüm verileri sıfırla - hem disk hem memory
  Future<void> resetAllData() async {
    // 1. Disk'teki tüm verileri sil
    await _profileService.resetAllData();

    // 2. Memory'deki tüm state'i sıfırla
    _expenses = [];
    _stats = const DecisionStats();
    _streakData = const StreakData(currentStreak: 0, longestStreak: 0);
    _achievements = [];
    _userProfile = null;
    _isLoading = false;
    _isInitialized = false;

    notifyListeners();
  }

  // ============================================
  // PRO FEATURES: ARŞİVLENMİŞ VERİLER
  // ============================================

  /// Firestore'daki toplam expense sayısını getir
  Future<int> getTotalExpenseCount() async {
    return await _expenseService.getTotalExpenseCount();
  }

  /// Firestore'dan arşivlenmiş expense'leri getir (Pro kullanıcılar için)
  Future<List<Expense>> fetchArchivedExpenses({
    int offset = 0,
    int limit = 50,
  }) async {
    return await _expenseService.fetchArchivedExpenses(
      offset: offset,
      limit: limit,
    );
  }

  /// Firestore'dan TÜM expense'leri getir (Pro export için)
  Future<List<Expense>> fetchAllExpensesFromFirestore() async {
    return await _expenseService.fetchAllExpensesFromFirestore();
  }

  // ============================================
  // DEBUG: TEST METODLARI
  // ============================================

  /// Debug: Toplu test expense'leri ekle
  Future<void> addTestExpenses(int count) async {
    final categories = [
      'Yiyecek',
      'Dijital',
      'Ulaşım',
      'Giyim',
      'Eğlence',
      'Sağlık',
    ];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < count; i++) {
      final amount = ((random + i * 137) % 900) + 100.0; // 100-1000 arası
      final categoryIndex = (random + i) % categories.length;
      final daysAgo = i;

      final result = _calculationService.calculateExpense(
        userProfile:
            _userProfile ??
            UserProfile(incomeSources: [], dailyHours: 8, workDaysPerWeek: 5),
        expenseAmount: amount,
        month: DateTime.now().month,
        year: DateTime.now().year,
      );

      final expense = Expense(
        amount: amount,
        category: categories[categoryIndex],
        date: DateTime.now().subtract(Duration(days: daysAgo)),
        hoursRequired: result.hoursRequired,
        daysRequired: result.daysRequired,
        decision: ExpenseDecision.yes,
        decisionDate: DateTime.now(),
        recordType: RecordType.simulation,
      );

      await addExpense(expense);
    }
  }
}

/// Data class for today's spending information
class TodaySpendingData {
  final double amount;
  final double hours;
  final int minutes;
  final int expenseCount;

  const TodaySpendingData({
    required this.amount,
    required this.hours,
    required this.minutes,
    required this.expenseCount,
  });

  /// Total time in decimal hours
  double get totalHours => hours + (minutes / 60);

  /// Formatted time string (e.g., "2h 45m")
  String formattedTime(String hourAbbrev, String minAbbrev) {
    return '${hours.toInt()}$hourAbbrev $minutes$minAbbrev';
  }
}
