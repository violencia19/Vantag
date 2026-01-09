// Viral Alışkanlık Hesaplayıcı
// Kullanıcının alışkanlıkları için yılda kaç gün çalıştığını hesaplar

class HabitCategory {
  final String name;
  final String emoji;

  const HabitCategory(this.name, this.emoji);
}

const List<HabitCategory> defaultHabitCategories = [
  HabitCategory('Kahve', '☕'),
  HabitCategory('Sigara', '🚬'),
  HabitCategory('Dışarıda Yemek', '🍔'),
  HabitCategory('Oyun/Eğlence', '🎮'),
  HabitCategory('Kıyafet', '👕'),
  HabitCategory('Taksi/Uber', '🚗'),
];

class HabitResult {
  final double yearlyAmount;
  final int yearlyDays;
  final int monthlyDays;
  final int monthlyExtraHours;
  final double monthlyAmount;

  const HabitResult({
    required this.yearlyAmount,
    required this.yearlyDays,
    required this.monthlyDays,
    required this.monthlyExtraHours,
    required this.monthlyAmount,
  });
}

class HabitCalculator {
  static const Map<String, int> frequencyMultipliers = {
    'Günde 1': 365,
    'Günde 2': 730,
    '2 günde 1': 182,
    'Haftada 1': 52,
    'Haftada 2-3': 130,
    'Ayda birkaç': 24,
  };

  static const List<String> frequencies = [
    'Günde 1',
    'Günde 2',
    '2 günde 1',
    'Haftada 1',
    'Haftada 2-3',
    'Ayda birkaç',
  ];

  /// Alışkanlık maliyetini hesapla
  /// [price] - Bir seferinde harcanan tutar (TL)
  /// [frequency] - Sıklık (frequencyMultipliers key'lerinden biri)
  /// [monthlyIncome] - Aylık gelir (TL)
  static HabitResult calculate({
    required double price,
    required String frequency,
    required double monthlyIncome,
  }) {
    final multiplier = frequencyMultipliers[frequency] ?? 365;
    final yearlyAmount = price * multiplier;
    final hourlyWage = monthlyIncome / 176; // aylık 176 saat (22 gün x 8 saat)
    final yearlyHours = yearlyAmount / hourlyWage;
    final yearlyDays = (yearlyHours / 8).round();

    final monthlyHours = yearlyHours / 12;
    final monthlyDays = (monthlyHours / 8).floor();
    final monthlyExtraHours = (monthlyHours % 8).round();
    final monthlyAmount = yearlyAmount / 12;

    return HabitResult(
      yearlyAmount: yearlyAmount,
      yearlyDays: yearlyDays,
      monthlyDays: monthlyDays,
      monthlyExtraHours: monthlyExtraHours,
      monthlyAmount: monthlyAmount,
    );
  }
}
