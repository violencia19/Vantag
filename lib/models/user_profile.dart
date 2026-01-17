import 'income_source.dart';

class UserProfile {
  final List<IncomeSource> incomeSources;
  final double dailyHours;
  final int workDaysPerWeek;

  // Bütçe ayarları
  final double? monthlyBudget;        // Kullanıcının belirlediği harcama limiti
  final double? monthlySavingsGoal;   // Aylık tasarruf hedefi

  const UserProfile({
    this.incomeSources = const [],
    this.dailyHours = 8,
    this.workDaysPerWeek = 5,
    this.monthlyBudget,
    this.monthlySavingsGoal,
  });

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

  UserProfile copyWith({
    List<IncomeSource>? incomeSources,
    double? dailyHours,
    int? workDaysPerWeek,
    double? monthlyBudget,
    double? monthlySavingsGoal,
  }) {
    return UserProfile(
      incomeSources: incomeSources ?? this.incomeSources,
      dailyHours: dailyHours ?? this.dailyHours,
      workDaysPerWeek: workDaysPerWeek ?? this.workDaysPerWeek,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      monthlySavingsGoal: monthlySavingsGoal ?? this.monthlySavingsGoal,
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
    final salarySource = IncomeSource.salary(amount: monthlyIncome);
    return UserProfile(
      incomeSources: [salarySource],
      dailyHours: dailyHours,
      workDaysPerWeek: workDaysPerWeek,
    );
  }
}
