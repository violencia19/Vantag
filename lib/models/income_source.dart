import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:vantag/theme/app_theme.dart';

/// Gelir kategorileri
enum IncomeCategory {
  salary,
  freelance,
  rental,
  passive,
  other;

  /// Internal label for debugging/logging only - use getLocalizedLabel for UI
  String get label => name;

  IconData get icon {
    switch (this) {
      case IncomeCategory.salary:
        return PhosphorIconsFill.briefcase;
      case IncomeCategory.freelance:
        return PhosphorIconsFill.laptop;
      case IncomeCategory.rental:
        return PhosphorIconsFill.house;
      case IncomeCategory.passive:
        return PhosphorIconsFill.chartLineUp;
      case IncomeCategory.other:
        return PhosphorIconsFill.coins;
    }
  }

  Color get color {
    switch (this) {
      case IncomeCategory.salary:
        return AppColors.incomeSalary;
      case IncomeCategory.freelance:
        return AppColors.incomeRental;
      case IncomeCategory.rental:
        return AppColors.incomeSideJob;
      case IncomeCategory.passive:
        return AppColors.incomeOther;
      case IncomeCategory.other:
        return AppColors.incomeDefault;
    }
  }

  /// Get localized label for UI display
  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case IncomeCategory.salary:
        return l10n.incomeCategorySalary;
      case IncomeCategory.freelance:
        return l10n.incomeCategoryFreelance;
      case IncomeCategory.rental:
        return l10n.incomeCategoryRental;
      case IncomeCategory.passive:
        return l10n.incomeCategoryPassive;
      case IncomeCategory.other:
        return l10n.incomeCategoryOther;
    }
  }

  /// Get localized description for UI display
  String getLocalizedDescription(AppLocalizations l10n) {
    switch (this) {
      case IncomeCategory.salary:
        return l10n.incomeCategorySalaryDesc;
      case IncomeCategory.freelance:
        return l10n.incomeCategoryFreelanceDesc;
      case IncomeCategory.rental:
        return l10n.incomeCategoryRentalDesc;
      case IncomeCategory.passive:
        return l10n.incomeCategoryPassiveDesc;
      case IncomeCategory.other:
        return l10n.incomeCategoryOtherDesc;
    }
  }

  static IncomeCategory fromString(String value) {
    return IncomeCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => IncomeCategory.other,
    );
  }
}

/// Gelir kaynağı modeli
class IncomeSource {
  final String id;
  final String title;
  final double amount; // Gösterilen tutar (display currency'de)
  final String
  currencyCode; // Gösterilen para birimi kodu (TRY, USD, EUR, etc.)
  final IncomeCategory category;
  final DateTime createdAt;
  final bool isPrimary; // Ana gelir mi?

  // Orijinal değerler (para birimi değişse bile bunlar sabit kalır)
  final double originalAmount; // İlk girilen tutar
  final String originalCurrencyCode; // İlk girilen para birimi

  const IncomeSource({
    required this.id,
    required this.title,
    required this.amount,
    this.currencyCode = 'TRY',
    required this.category,
    required this.createdAt,
    this.isPrimary = false,
    double? originalAmount,
    String? originalCurrencyCode,
  }) : originalAmount = originalAmount ?? amount,
       originalCurrencyCode = originalCurrencyCode ?? currencyCode;

  /// Benzersiz ID oluştur
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Ana maaş için factory
  /// [title] should be localized using l10n.mainSalary
  factory IncomeSource.salary({
    required double amount,
    required String title,
    String currencyCode = 'TRY',
  }) {
    return IncomeSource(
      id: generateId(),
      title: title,
      amount: amount,
      currencyCode: currencyCode,
      category: IncomeCategory.salary,
      createdAt: DateTime.now(),
      isPrimary: true,
      originalAmount: amount,
      originalCurrencyCode: currencyCode,
    );
  }

  /// Ek gelir için factory
  factory IncomeSource.additional({
    required String title,
    required double amount,
    required IncomeCategory category,
    String currencyCode = 'TRY',
  }) {
    return IncomeSource(
      id: generateId(),
      title: title,
      amount: amount,
      currencyCode: currencyCode,
      category: category,
      createdAt: DateTime.now(),
      isPrimary: false,
      originalAmount: amount,
      originalCurrencyCode: currencyCode,
    );
  }

  IncomeSource copyWith({
    String? id,
    String? title,
    double? amount,
    String? currencyCode,
    IncomeCategory? category,
    DateTime? createdAt,
    bool? isPrimary,
    double? originalAmount,
    String? originalCurrencyCode,
  }) {
    return IncomeSource(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isPrimary: isPrimary ?? this.isPrimary,
      originalAmount: originalAmount ?? this.originalAmount,
      originalCurrencyCode: originalCurrencyCode ?? this.originalCurrencyCode,
    );
  }

  /// Para birimi değiştirildiğinde convert edilmiş kopya oluştur
  /// Orijinal değerler korunur, sadece amount ve currencyCode değişir
  IncomeSource convertedTo({
    required double newAmount,
    required String newCurrencyCode,
  }) {
    return IncomeSource(
      id: id,
      title: title,
      amount: newAmount,
      currencyCode: newCurrencyCode,
      category: category,
      createdAt: createdAt,
      isPrimary: isPrimary,
      originalAmount: originalAmount, // Orijinal değişmez!
      originalCurrencyCode: originalCurrencyCode, // Orijinal değişmez!
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'currencyCode': currencyCode,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'isPrimary': isPrimary,
      'originalAmount': originalAmount,
      'originalCurrencyCode': originalCurrencyCode,
    };
  }

  factory IncomeSource.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num).toDouble();
    final currencyCode = json['currencyCode'] as String? ?? 'TRY';

    return IncomeSource(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: amount,
      currencyCode: currencyCode,
      category: IncomeCategory.fromString(json['category'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPrimary: json['isPrimary'] as bool? ?? false,
      // Eski veriler için fallback: mevcut değerleri orijinal olarak kullan
      originalAmount: (json['originalAmount'] as num?)?.toDouble() ?? amount,
      originalCurrencyCode:
          json['originalCurrencyCode'] as String? ?? currencyCode,
    );
  }

  static String encodeList(List<IncomeSource> sources) {
    return jsonEncode(sources.map((s) => s.toJson()).toList());
  }

  static List<IncomeSource> decodeList(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((item) => IncomeSource.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() =>
      'IncomeSource(title: $title, amount: $amount, category: ${category.label})';
}
