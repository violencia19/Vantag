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
    if (_expenses.length > ExpenseHistoryService.maxLocalExpenses) {
      _expenses = _expenses.take(ExpenseHistoryService.maxLocalExpenses).toList();
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

  /// Para birimi değiştiğinde tüm gelir kaynaklarını yeni para birimine convert et
  /// [convertedSources] - CurrencyProvider.convertIncomeSources() ile convert edilmiş liste
  Future<void> updateIncomeSourcesWithConversion(List<IncomeSource> convertedSources) async {
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(
      incomeSources: convertedSources,
    );

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

  Future<void> updateWorkSchedule({double? dailyHours, int? workDaysPerWeek}) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(dailyHours: dailyHours, workDaysPerWeek: workDaysPerWeek);
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

  /// Saatlik ücret (fallback ile)
  double get hourlyRate {
    if (_userProfile == null) return 0;
    final rate = _userProfile!.hourlyRate;
    if (rate <= 0) {
      // Fallback: aylık gelir / 160 saat
      return _userProfile!.monthlyIncome / 160;
    }
    return rate;
  }

  // ============================================
  // HARCAMA FİLTRELERİ VE HESAPLAMALAR
  // ============================================

  /// Bu ayki harcamalar
  List<Expense> get currentMonthExpenses {
    final now = DateTime.now();
    return _expenses.where((e) =>
      e.date.year == now.year &&
      e.date.month == now.month
    ).toList();
  }

  /// Aktif taksitler listesi
  List<Expense> get activeInstallments {
    return _expenses.where((e) =>
      e.type == ExpenseType.installment &&
      !e.isInstallmentCompleted
    ).toList();
  }

  /// Bu ayki zorunlu giderler toplamı
  double get mandatoryExpensesTotal {
    return currentMonthExpenses
      .where((e) => e.isMandatory)
      .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Bu ayki isteğe bağlı giderler toplamı
  double get discretionaryExpensesTotal {
    return currentMonthExpenses
      .where((e) => !e.isMandatory)
      .fold(0.0, (sum, e) => sum + e.amount);
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

  // ============================================
  // PRO FEATURES: ARŞİVLENMİŞ VERİLER
  // ============================================

  /// Firestore'daki toplam expense sayısını getir
  Future<int> getTotalExpenseCount() async {
    return await _expenseService.getTotalExpenseCount();
  }

  /// Firestore'dan arşivlenmiş expense'leri getir (Pro kullanıcılar için)
  Future<List<Expense>> fetchArchivedExpenses({int offset = 0, int limit = 50}) async {
    return await _expenseService.fetchArchivedExpenses(offset: offset, limit: limit);
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
    final categories = ['Yiyecek', 'Dijital', 'Ulaşım', 'Giyim', 'Eğlence', 'Sağlık'];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < count; i++) {
      final amount = ((random + i * 137) % 900) + 100.0; // 100-1000 arası
      final categoryIndex = (random + i) % categories.length;
      final daysAgo = i;

      final result = _calculationService.calculateExpense(
        userProfile: _userProfile ?? UserProfile(
          incomeSources: [],
          dailyHours: 8,
          workDaysPerWeek: 5,
        ),
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