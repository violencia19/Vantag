import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Gelir kategorileri
enum IncomeCategory {
  salary,
  freelance,
  rental,
  passive,
  other;

  String get label {
    switch (this) {
      case IncomeCategory.salary:
        return 'Maaş';
      case IncomeCategory.freelance:
        return 'Freelance';
      case IncomeCategory.rental:
        return 'Kira Geliri';
      case IncomeCategory.passive:
        return 'Pasif Gelir';
      case IncomeCategory.other:
        return 'Diğer';
    }
  }

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
        return const Color(0xFF6C63FF);
      case IncomeCategory.freelance:
        return const Color(0xFF4ECDC4);
      case IncomeCategory.rental:
        return const Color(0xFFF39C12);
      case IncomeCategory.passive:
        return const Color(0xFF2ECC71);
      case IncomeCategory.other:
        return const Color(0xFF95A5A6);
    }
  }

  String get description {
    switch (this) {
      case IncomeCategory.salary:
        return 'Aylık düzenli maaş';
      case IncomeCategory.freelance:
        return 'Serbest çalışma gelirleri';
      case IncomeCategory.rental:
        return 'Ev, araba vb. kira gelirleri';
      case IncomeCategory.passive:
        return 'Yatırım, temettü, faiz vb.';
      case IncomeCategory.other:
        return 'Diğer gelir kaynakları';
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
  final double amount;
  final String currencyCode; // Para birimi kodu (TRY, USD, EUR, etc.)
  final IncomeCategory category;
  final DateTime createdAt;
  final bool isPrimary; // Ana gelir mi?

  const IncomeSource({
    required this.id,
    required this.title,
    required this.amount,
    this.currencyCode = 'TRY',
    required this.category,
    required this.createdAt,
    this.isPrimary = false,
  });

  /// Benzersiz ID oluştur
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Ana maaş için factory
  factory IncomeSource.salary({
    required double amount,
    String? title,
    String currencyCode = 'TRY',
  }) {
    return IncomeSource(
      id: generateId(),
      title: title ?? 'Ana Maaş',
      amount: amount,
      currencyCode: currencyCode,
      category: IncomeCategory.salary,
      createdAt: DateTime.now(),
      isPrimary: true,
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
  }) {
    return IncomeSource(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isPrimary: isPrimary ?? this.isPrimary,
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
    };
  }

  factory IncomeSource.fromJson(Map<String, dynamic> json) {
    return IncomeSource(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String? ?? 'TRY',
      category: IncomeCategory.fromString(json['category'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  static String encodeList(List<IncomeSource> sources) {
    return jsonEncode(sources.map((s) => s.toJson()).toList());
  }

  static List<IncomeSource> decodeList(String json) {
    final list = jsonDecode(json) as List;
    return list.map((item) => IncomeSource.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  String toString() => 'IncomeSource(title: $title, amount: $amount, category: ${category.label})';
}
