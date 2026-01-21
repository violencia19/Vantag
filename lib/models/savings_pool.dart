import 'package:cloud_firestore/cloud_firestore.dart';

/// Tasarruf Havuzu - Kullanıcının vazgeçtiği paraları ve hayallere ayırdığı tutarları takip eder
class SavingsPool {
  /// Toplam tasarruf (vazgeçilen paralar)
  final double totalSaved;

  /// Hayallere ayrılan tutar
  final double allocatedToDreams;

  /// Gölge borç - havuz eksiye düşerse
  final double shadowDebt;

  /// Bu ay joker kullanıldı mı
  final bool jokerUsedThisMonth;

  /// Joker reset tarihi (ay başı)
  final DateTime jokerResetDate;

  /// Son güncelleme tarihi
  final DateTime lastUpdated;

  const SavingsPool({
    this.totalSaved = 0,
    this.allocatedToDreams = 0,
    this.shadowDebt = 0,
    this.jokerUsedThisMonth = false,
    required this.jokerResetDate,
    required this.lastUpdated,
  });

  /// Kullanılabilir tutar (hayallere ayrılmamış)
  double get available => totalSaved - allocatedToDreams - shadowDebt;

  /// Havuz eksiye düşmüş mü
  bool get hasDebt => shadowDebt > 0;

  /// Joker kullanılabilir mi
  bool get canUseJoker => !jokerUsedThisMonth;

  /// Boş havuz oluştur
  factory SavingsPool.empty() {
    final now = DateTime.now();
    return SavingsPool(
      totalSaved: 0,
      allocatedToDreams: 0,
      shadowDebt: 0,
      jokerUsedThisMonth: false,
      jokerResetDate: DateTime(now.year, now.month, 1),
      lastUpdated: now,
    );
  }

  /// Firestore'dan oluştur
  factory SavingsPool.fromFirestore(Map<String, dynamic> data) {
    return SavingsPool(
      totalSaved: (data['totalSaved'] as num?)?.toDouble() ?? 0,
      allocatedToDreams: (data['allocatedToDreams'] as num?)?.toDouble() ?? 0,
      shadowDebt: (data['shadowDebt'] as num?)?.toDouble() ?? 0,
      jokerUsedThisMonth: data['jokerUsedThisMonth'] as bool? ?? false,
      jokerResetDate: (data['jokerResetDate'] as Timestamp?)?.toDate() ??
          DateTime(DateTime.now().year, DateTime.now().month, 1),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore'a kaydet
  Map<String, dynamic> toFirestore() {
    return {
      'totalSaved': totalSaved,
      'allocatedToDreams': allocatedToDreams,
      'shadowDebt': shadowDebt,
      'jokerUsedThisMonth': jokerUsedThisMonth,
      'jokerResetDate': Timestamp.fromDate(jokerResetDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Kopyala ve güncelle
  SavingsPool copyWith({
    double? totalSaved,
    double? allocatedToDreams,
    double? shadowDebt,
    bool? jokerUsedThisMonth,
    DateTime? jokerResetDate,
    DateTime? lastUpdated,
  }) {
    return SavingsPool(
      totalSaved: totalSaved ?? this.totalSaved,
      allocatedToDreams: allocatedToDreams ?? this.allocatedToDreams,
      shadowDebt: shadowDebt ?? this.shadowDebt,
      jokerUsedThisMonth: jokerUsedThisMonth ?? this.jokerUsedThisMonth,
      jokerResetDate: jokerResetDate ?? this.jokerResetDate,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'SavingsPool(total: $totalSaved, allocated: $allocatedToDreams, available: $available, debt: $shadowDebt, joker: $jokerUsedThisMonth)';
  }
}

/// Bütçe kaydırma kaynakları
enum BudgetShiftSource {
  food,
  entertainment,
  clothing,
  transport,
  shopping,
  health,
  education,
  extraIncome,
  joker,
}

extension BudgetShiftSourceExtension on BudgetShiftSource {
  String get labelTR {
    switch (this) {
      case BudgetShiftSource.food:
        return 'Yemek bütçemden';
      case BudgetShiftSource.entertainment:
        return 'Eğlence bütçemden';
      case BudgetShiftSource.clothing:
        return 'Giyim bütçemden';
      case BudgetShiftSource.transport:
        return 'Ulaşım bütçemden';
      case BudgetShiftSource.shopping:
        return 'Alışveriş bütçemden';
      case BudgetShiftSource.health:
        return 'Sağlık bütçemden';
      case BudgetShiftSource.education:
        return 'Eğitim bütçemden';
      case BudgetShiftSource.extraIncome:
        return 'Ekstra gelir elde ettim';
      case BudgetShiftSource.joker:
        return 'Joker Kullan (ayda 1)';
    }
  }

  String get labelEN {
    switch (this) {
      case BudgetShiftSource.food:
        return 'From my food budget';
      case BudgetShiftSource.entertainment:
        return 'From my entertainment budget';
      case BudgetShiftSource.clothing:
        return 'From my clothing budget';
      case BudgetShiftSource.transport:
        return 'From my transport budget';
      case BudgetShiftSource.shopping:
        return 'From my shopping budget';
      case BudgetShiftSource.health:
        return 'From my health budget';
      case BudgetShiftSource.education:
        return 'From my education budget';
      case BudgetShiftSource.extraIncome:
        return 'I earned extra income';
      case BudgetShiftSource.joker:
        return 'Use Joker (1/month)';
    }
  }

  String get emoji {
    switch (this) {
      case BudgetShiftSource.food:
        return '🍔';
      case BudgetShiftSource.entertainment:
        return '🎬';
      case BudgetShiftSource.clothing:
        return '👕';
      case BudgetShiftSource.transport:
        return '🚗';
      case BudgetShiftSource.shopping:
        return '🛒';
      case BudgetShiftSource.health:
        return '💊';
      case BudgetShiftSource.education:
        return '📚';
      case BudgetShiftSource.extraIncome:
        return '💰';
      case BudgetShiftSource.joker:
        return '🃏';
    }
  }

  /// Expense kategorisi karşılığı
  String? get expenseCategory {
    switch (this) {
      case BudgetShiftSource.food:
        return 'Yemek';
      case BudgetShiftSource.entertainment:
        return 'Eğlence';
      case BudgetShiftSource.clothing:
        return 'Giyim';
      case BudgetShiftSource.transport:
        return 'Ulaşım';
      case BudgetShiftSource.shopping:
        return 'Alışveriş';
      case BudgetShiftSource.health:
        return 'Sağlık';
      case BudgetShiftSource.education:
        return 'Eğitim';
      case BudgetShiftSource.extraIncome:
      case BudgetShiftSource.joker:
        return null;
    }
  }
}
