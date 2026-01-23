import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';

/// One-time income types
enum IncomeType {
  salary, // Regular monthly salary
  bonus, // Work bonus
  gift, // Gift money
  refund, // Refund/cashback
  freelance, // Freelance work
  rental, // Rental income
  investment, // Investment returns
  other; // Other income

  IconData get icon {
    switch (this) {
      case IncomeType.salary:
        return PhosphorIconsFill.briefcase;
      case IncomeType.bonus:
        return PhosphorIconsFill.trophy;
      case IncomeType.gift:
        return PhosphorIconsFill.gift;
      case IncomeType.refund:
        return PhosphorIconsFill.arrowUUpLeft;
      case IncomeType.freelance:
        return PhosphorIconsFill.laptop;
      case IncomeType.rental:
        return PhosphorIconsFill.house;
      case IncomeType.investment:
        return PhosphorIconsFill.chartLineUp;
      case IncomeType.other:
        return PhosphorIconsFill.coins;
    }
  }

  Color get color {
    switch (this) {
      case IncomeType.salary:
        return const Color(0xFF6C63FF);
      case IncomeType.bonus:
        return const Color(0xFFFFD700);
      case IncomeType.gift:
        return const Color(0xFFE91E63);
      case IncomeType.refund:
        return const Color(0xFF4CAF50);
      case IncomeType.freelance:
        return const Color(0xFF4ECDC4);
      case IncomeType.rental:
        return const Color(0xFFF39C12);
      case IncomeType.investment:
        return const Color(0xFF2ECC71);
      case IncomeType.other:
        return const Color(0xFF95A5A6);
    }
  }

  /// Get localized label for UI display
  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case IncomeType.salary:
        return l10n.incomeTypeSalary;
      case IncomeType.bonus:
        return l10n.incomeTypeBonus;
      case IncomeType.gift:
        return l10n.incomeTypeGift;
      case IncomeType.refund:
        return l10n.incomeTypeRefund;
      case IncomeType.freelance:
        return l10n.incomeTypeFreelance;
      case IncomeType.rental:
        return l10n.incomeTypeRental;
      case IncomeType.investment:
        return l10n.incomeTypeInvestment;
      case IncomeType.other:
        return l10n.incomeTypeOther;
    }
  }

  static IncomeType fromString(String value) {
    return IncomeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => IncomeType.other,
    );
  }
}

/// One-time income model for tracking bonus, gift, refund, etc.
class Income {
  final String id;
  final String title;
  final double amount;
  final String currencyCode;
  final IncomeType type;
  final DateTime date;
  final String? notes;
  final bool isRecurring;

  const Income({
    required this.id,
    required this.title,
    required this.amount,
    this.currencyCode = 'TRY',
    required this.type,
    required this.date,
    this.notes,
    this.isRecurring = false,
  });

  /// Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Factory for salary income (monthly)
  factory Income.salary({
    required double amount,
    required String title,
    String currencyCode = 'TRY',
    DateTime? date,
  }) {
    return Income(
      id: generateId(),
      title: title,
      amount: amount,
      currencyCode: currencyCode,
      type: IncomeType.salary,
      date: date ?? DateTime.now(),
      isRecurring: true,
    );
  }

  /// Factory for bonus income
  factory Income.bonus({
    required double amount,
    required String title,
    String currencyCode = 'TRY',
    String? notes,
  }) {
    return Income(
      id: generateId(),
      title: title,
      amount: amount,
      currencyCode: currencyCode,
      type: IncomeType.bonus,
      date: DateTime.now(),
      notes: notes,
    );
  }

  /// Factory for gift income
  factory Income.gift({
    required double amount,
    String? title,
    String currencyCode = 'TRY',
    String? notes,
  }) {
    return Income(
      id: generateId(),
      title: title ?? 'Gift',
      amount: amount,
      currencyCode: currencyCode,
      type: IncomeType.gift,
      date: DateTime.now(),
      notes: notes,
    );
  }

  /// Factory for refund income
  factory Income.refund({
    required double amount,
    required String title,
    String currencyCode = 'TRY',
    String? notes,
  }) {
    return Income(
      id: generateId(),
      title: title,
      amount: amount,
      currencyCode: currencyCode,
      type: IncomeType.refund,
      date: DateTime.now(),
      notes: notes,
    );
  }

  Income copyWith({
    String? id,
    String? title,
    double? amount,
    String? currencyCode,
    IncomeType? type,
    DateTime? date,
    String? notes,
    bool? isRecurring,
  }) {
    return Income(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      type: type ?? this.type,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'currencyCode': currencyCode,
      'type': type.name,
      'date': date.toIso8601String(),
      'notes': notes,
      'isRecurring': isRecurring,
    };
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String? ?? 'TRY',
      type: IncomeType.fromString(json['type'] as String),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
    );
  }

  static String encodeList(List<Income> incomes) {
    return jsonEncode(incomes.map((i) => i.toJson()).toList());
  }

  static List<Income> decodeList(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((item) => Income.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() =>
      'Income(title: $title, amount: $amount, type: ${type.name})';
}
