// Viral Alışkanlık Hesaplayıcı
// Kullanıcının alışkanlıkları için yılda kaç gün çalıştığını hesaplar

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:vantag/theme/app_theme.dart';

class HabitCategory {
  final String key; // Localization key
  final String name; // Display name (localized)
  final IconData icon;
  final Color color;

  const HabitCategory(this.key, this.name, this.icon, this.color);
}

/// Category definitions with icons and colors (key-based)
class HabitCategoryDef {
  final String key;
  final IconData icon;
  final Color color;

  const HabitCategoryDef(this.key, this.icon, this.color);
}

const List<HabitCategoryDef> _habitCategoryDefs = [
  HabitCategoryDef('coffee', PhosphorIconsFill.coffee, AppColors.coffeeColor),
  HabitCategoryDef(
    'smoking',
    PhosphorIconsFill.cigarette,
    AppColors.smokingGray,
  ),
  HabitCategoryDef(
    'eatingOut',
    PhosphorIconsFill.hamburger,
    AppColors.categoryFood,
  ),
  HabitCategoryDef(
    'gaming',
    PhosphorIconsFill.gameController,
    AppColors.categoryBills,
  ),
  HabitCategoryDef(
    'clothing',
    PhosphorIconsFill.tShirt,
    AppColors.categoryShopping,
  ),
  HabitCategoryDef('taxi', PhosphorIconsFill.car, AppColors.secondary),
];

/// Get localized category name from key
String getLocalizedHabitCategory(String key, AppLocalizations l10n) {
  switch (key) {
    case 'coffee':
      return l10n.habitCatCoffee;
    case 'smoking':
      return l10n.habitCatSmoking;
    case 'eatingOut':
      return l10n.habitCatEatingOut;
    case 'gaming':
      return l10n.habitCatGaming;
    case 'clothing':
      return l10n.habitCatClothing;
    case 'taxi':
      return l10n.habitCatTaxi;
    default:
      return key;
  }
}

/// Get localized habit categories list (call with l10n context)
List<HabitCategory> getLocalizedHabitCategories(AppLocalizations l10n) {
  return _habitCategoryDefs
      .map(
        (def) => HabitCategory(
          def.key,
          getLocalizedHabitCategory(def.key, l10n),
          def.icon,
          def.color,
        ),
      )
      .toList();
}

/// Legacy: for backward compatibility (returns Turkish names)
const List<HabitCategory> defaultHabitCategories = [
  HabitCategory(
    'coffee',
    'Kahve',
    PhosphorIconsFill.coffee,
    AppColors.coffeeColor,
  ),
  HabitCategory(
    'smoking',
    'Sigara',
    PhosphorIconsFill.cigarette,
    AppColors.smokingGray,
  ),
  HabitCategory(
    'eatingOut',
    'Dışarıda Yemek',
    PhosphorIconsFill.hamburger,
    AppColors.categoryFood,
  ),
  HabitCategory(
    'gaming',
    'Oyun/Eğlence',
    PhosphorIconsFill.gameController,
    AppColors.categoryBills,
  ),
  HabitCategory(
    'clothing',
    'Kıyafet',
    PhosphorIconsFill.tShirt,
    AppColors.categoryShopping,
  ),
  HabitCategory(
    'taxi',
    'Taksi/Uber',
    PhosphorIconsFill.car,
    AppColors.secondary,
  ),
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
  /// Frequency keys with their multipliers
  static const Map<String, int> frequencyMultipliers = {
    'onceDaily': 365,
    'twiceDaily': 730,
    'everyTwoDays': 182,
    'onceWeekly': 52,
    'twoThreeWeekly': 130,
    'fewMonthly': 24,
  };

  /// Frequency keys (use getLocalizedFrequencies for display)
  static const List<String> frequencyKeys = [
    'onceDaily',
    'twiceDaily',
    'everyTwoDays',
    'onceWeekly',
    'twoThreeWeekly',
    'fewMonthly',
  ];

  /// Get localized frequency name from key
  static String getLocalizedFrequency(String key, AppLocalizations l10n) {
    switch (key) {
      case 'onceDaily':
        return l10n.freqOnceDaily;
      case 'twiceDaily':
        return l10n.freqTwiceDaily;
      case 'everyTwoDays':
        return l10n.freqEveryTwoDays;
      case 'onceWeekly':
        return l10n.freqOnceWeekly;
      case 'twoThreeWeekly':
        return l10n.freqTwoThreeWeekly;
      case 'fewMonthly':
        return l10n.freqFewMonthly;
      default:
        return key;
    }
  }

  /// Get list of localized frequency strings
  static List<String> getLocalizedFrequencies(AppLocalizations l10n) {
    return frequencyKeys
        .map((key) => getLocalizedFrequency(key, l10n))
        .toList();
  }

  /// Legacy: for backward compatibility (Turkish names)
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
