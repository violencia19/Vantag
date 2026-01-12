import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const int _maxCachedExpenses = 100;

  // State
  List<Expense> _expenses = [];
  DecisionStats _stats = const DecisionStats();
  StreakData _streakData = const StreakData(currentStreak: 0, longestStreak: 0);
  List<Achievement> _achievements = [];
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isInitialized = false;

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

  // Başlatma
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        _loadExpenses(),
        _loadStreakData(),
        _loadAchievements(),
        _loadProfile(),
      ]);
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
      final todayRenewals = await _subscriptionService.getAutoRecordSubscriptionsForToday();
      if (todayRenewals.isEmpty) {
        await prefs.setString(_keyAutoRecordedDate, todayKey);
        return;
      }

      // Her abonelik için harcama oluştur
      for (final sub in todayRenewals) {
        // Hesaplama yap
        final result = _calculationService.calculateExpense(
          userProfile: _userProfile ?? UserProfile(
            incomeSources: [],
            dailyHours: 8,
            workDaysPerWeek: 5,
          ),
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

  void _calculateStats() {
    _stats = DecisionStats.fromExpenses(realExpenses);
  }

  // ============================================
  // HARCAMA (EXPENSE) İŞLEMLERİ (Geri Getirilenler)
  // ============================================

  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);

    // Enforce cache limit - keep only the most recent expenses in memory
    if (_expenses.length > _maxCachedExpenses) {
      _expenses = _expenses.take(_maxCachedExpenses).toList();
    }

    _calculateStats();
    notifyListeners();
    await _expenseService.addExpense(expense);
    if (expense.isReal) await _updateStreakAfterEntry();
  }

  Future<void> updateExpense(int index, Expense expense) async {
    if (index < 0 || index >= _expenses.length) return;
    _expenses[index] = expense;
    _calculateStats();
    notifyListeners();
    await _expenseService.updateExpense(index, expense);
  }

  Future<void> deleteExpense(int index) async {
    if (index < 0 || index >= _expenses.length) return;
    _expenses.removeAt(index);
    _calculateStats();
    notifyListeners();
    await _expenseService.deleteExpense(index);
  }

  Future<void> updateDecision(int index, ExpenseDecision decision) async {
    if (index < 0 || index >= _expenses.length) return;
    final updated = _expenses[index].copyWith(decision: decision, decisionDate: DateTime.now());
    await updateExpense(index, updated);
  }

  /// Alias for updateDecision - for backwards compatibility
  Future<void> updateExpenseDecision(int index, ExpenseDecision decision) async {
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
    final updatedProfile = (_userProfile ?? UserProfile(dailyHours: 8, workDaysPerWeek: 5))
        .copyWith(incomeSources: List<IncomeSource>.from(sources));

    _userProfile = updatedProfile;
    _calculateStats();
    notifyListeners();
    await _profileService.saveProfile(updatedProfile);
  }

  Future<void> updateWorkSchedule({double? dailyHours, int? workDaysPerWeek}) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(dailyHours: dailyHours, workDaysPerWeek: workDaysPerWeek);
    notifyListeners();
    await _profileService.saveProfile(_userProfile!);
  }

  // ============================================
  // DİĞER SERVİSLER
  // ============================================
  Future<void> _updateStreakAfterEntry() async {
    await _streakService.recordEntry();
    _streakData = await _streakService.getStreakData();
    notifyListeners();
  }

  Future<void> _loadStreakData() async => _streakData = await _streakService.getStreakData();
  Future<void> _loadAchievements() async => _achievements = await _achievementsService.getAchievements();

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
}