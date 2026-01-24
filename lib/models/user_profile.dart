import 'dart:math';
import 'income_source.dart';

class UserProfile {
  final List<IncomeSource> incomeSources;
  final double dailyHours;
  final int workDaysPerWeek;

  // Bütçe ayarları
  final double? monthlyBudget; // Kullanıcının belirlediği harcama limiti
  final double? monthlySavingsGoal; // Aylık tasarruf hedefi

  // Referral system
  final String? referralCode; // User's unique referral code (VANTAG-XXXXX)
  final String? referredBy; // Code used when signing up (if any)
  final int referralCount; // How many people used their code

  // Salary & Balance Management
  final int? salaryDay; // Day of month salary is received (1-31)
  final double? currentBalance; // Current bank balance
  final DateTime?
  lastSalaryConfirmedDate; // Last time user confirmed salary received

  // Base currency (locked for FREE users, from first salary entry)
  final String? baseCurrency; // TRY, USD, EUR, etc.

  const UserProfile({
    this.incomeSources = const [],
    this.dailyHours = 8,
    this.workDaysPerWeek = 5,
    this.monthlyBudget,
    this.monthlySavingsGoal,
    this.referralCode,
    this.referredBy,
    this.referralCount = 0,
    this.salaryDay,
    this.currentBalance,
    this.lastSalaryConfirmedDate,
    this.baseCurrency,
  });

  /// Generate a unique referral code (VANTAG-XXXXX)
  /// Uses characters that are not easily confused (no 0,O,1,I,L)
  static String generateReferralCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final code = List.generate(
      5,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'VANTAG-$code';
  }

  /// Toplam aylık gelir (tüm kaynakların toplamı)
  double get monthlyIncome {
    if (incomeSources.isEmpty) return 0;
    return incomeSources.fold<double>(0, (sum, source) => sum + source.amount);
  }

  /// Ana maaş (primary income)
  double get primaryIncome {
    final primary = incomeSources.where((s) => s.isPrimary).toList();
    if (primary.isEmpty) return 0;
    return primary.fold<double>(0, (sum, s) => sum + s.amount);
  }

  /// Ek gelirler toplamı
  double get additionalIncome {
    final additional = incomeSources.where((s) => !s.isPrimary).toList();
    if (additional.isEmpty) return 0;
    return additional.fold<double>(0, (sum, s) => sum + s.amount);
  }

  /// Ek gelir kaynakları
  List<IncomeSource> get additionalSources {
    return incomeSources.where((s) => !s.isPrimary).toList();
  }

  /// Ana gelir kaynağı
  IncomeSource? get primarySource {
    try {
      return incomeSources.firstWhere((s) => s.isPrimary);
    } catch (_) {
      return incomeSources.isNotEmpty ? incomeSources.first : null;
    }
  }

  /// Gelir kaynağı sayısı
  int get incomeSourceCount => incomeSources.length;

  /// Birden fazla gelir kaynağı var mı?
  bool get hasMultipleIncomeSources => incomeSources.length > 1;

  /// Aylık toplam çalışma saati (ortalama 4 hafta)
  double get monthlyWorkHours {
    return dailyHours * workDaysPerWeek * 4;
  }

  /// Saatlik ücret
  double get hourlyRate {
    if (monthlyWorkHours <= 0) return 0;
    return monthlyIncome / monthlyWorkHours;
  }

  /// Harcanabilir bütçe (bütçe - tasarruf hedefi)
  double get availableBudget {
    final budget = monthlyBudget ?? monthlyIncome;
    final savings = monthlySavingsGoal ?? 0;
    return budget - savings;
  }

  /// Bugün maaş günü mü?
  bool get isPayday {
    if (salaryDay == null) return false;
    final today = DateTime.now();
    return today.day == salaryDay;
  }

  /// Maaş bu ay onaylandı mı?
  bool get isSalaryConfirmedThisMonth {
    if (lastSalaryConfirmedDate == null) return false;
    final now = DateTime.now();
    return lastSalaryConfirmedDate!.year == now.year &&
        lastSalaryConfirmedDate!.month == now.month;
  }

  /// Maaş günü geçti mi (bu ay)?
  bool get hasPaydayPassedThisMonth {
    if (salaryDay == null) return false;
    final now = DateTime.now();
    return now.day > salaryDay!;
  }

  /// Sonraki maaş gününe kaç gün kaldı?
  int get daysUntilPayday {
    if (salaryDay == null) return -1;
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, salaryDay!);

    if (now.day < salaryDay!) {
      // Bu ayın maaş günü henüz gelmedi
      return thisMonth.difference(now).inDays;
    } else {
      // Gelecek ayın maaş günü
      final nextMonth = DateTime(now.year, now.month + 1, salaryDay!);
      return nextMonth.difference(now).inDays;
    }
  }

  UserProfile copyWith({
    List<IncomeSource>? incomeSources,
    double? dailyHours,
    int? workDaysPerWeek,
    double? monthlyBudget,
    double? monthlySavingsGoal,
    String? referralCode,
    String? referredBy,
    int? referralCount,
    int? salaryDay,
    double? currentBalance,
    DateTime? lastSalaryConfirmedDate,
    String? baseCurrency,
  }) {
    return UserProfile(
      incomeSources: incomeSources ?? this.incomeSources,
      dailyHours: dailyHours ?? this.dailyHours,
      workDaysPerWeek: workDaysPerWeek ?? this.workDaysPerWeek,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      monthlySavingsGoal: monthlySavingsGoal ?? this.monthlySavingsGoal,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      referralCount: referralCount ?? this.referralCount,
      salaryDay: salaryDay ?? this.salaryDay,
      currentBalance: currentBalance ?? this.currentBalance,
      lastSalaryConfirmedDate:
          lastSalaryConfirmedDate ?? this.lastSalaryConfirmedDate,
      baseCurrency: baseCurrency ?? this.baseCurrency,
    );
  }

  /// Gelir kaynağı ekle
  UserProfile addIncomeSource(IncomeSource source) {
    return copyWith(incomeSources: [...incomeSources, source]);
  }

  /// Gelir kaynağı güncelle
  UserProfile updateIncomeSource(String id, IncomeSource updatedSource) {
    final newList = incomeSources.map((s) {
      return s.id == id ? updatedSource : s;
    }).toList();
    return copyWith(incomeSources: newList);
  }

  /// Gelir kaynağı sil
  UserProfile removeIncomeSource(String id) {
    return copyWith(
      incomeSources: incomeSources.where((s) => s.id != id).toList(),
    );
  }

  /// Legacy constructor - eski monthlyIncome parametresi için
  factory UserProfile.legacy({
    required double monthlyIncome,
    required double dailyHours,
    required int workDaysPerWeek,
  }) {
    // Eski format: tek maaş kaynağı oluştur
    final salarySource = IncomeSource.salary(
      amount: monthlyIncome,
      title: 'Main Salary',
    );
    return UserProfile(
      incomeSources: [salarySource],
      dailyHours: dailyHours,
      workDaysPerWeek: workDaysPerWeek,
    );
  }
}
