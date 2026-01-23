import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Source of a savings transaction
enum TransactionSource {
  manual, // User manually added savings
  pool, // Transferred from savings pool
  expenseCancelled; // Redirected from a cancelled expense (Vazgeçtim)

  String get labelTr {
    switch (this) {
      case TransactionSource.manual:
        return 'Manuel Ekleme';
      case TransactionSource.pool:
        return 'Havuzdan Transfer';
      case TransactionSource.expenseCancelled:
        return 'Vazgeçilen Harcama';
    }
  }

  String get labelEn {
    switch (this) {
      case TransactionSource.manual:
        return 'Manual Entry';
      case TransactionSource.pool:
        return 'Pool Transfer';
      case TransactionSource.expenseCancelled:
        return 'Cancelled Expense';
    }
  }
}

/// A transaction record for adding/removing savings from a pursuit
class PursuitTransaction {
  final String id;
  final String pursuitId;
  final double amount;
  final String currency;
  final TransactionSource source;
  final String? note;
  final DateTime createdAt;

  const PursuitTransaction({
    required this.id,
    required this.pursuitId,
    required this.amount,
    required this.currency,
    required this.source,
    this.note,
    required this.createdAt,
  });

  /// Factory to create a new transaction with UUID
  factory PursuitTransaction.create({
    required String pursuitId,
    required double amount,
    required String currency,
    required TransactionSource source,
    String? note,
  }) {
    return PursuitTransaction(
      id: const Uuid().v4(),
      pursuitId: pursuitId,
      amount: amount,
      currency: currency,
      source: source,
      note: note,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pursuitId': pursuitId,
    'amount': amount,
    'currency': currency,
    'source': source.name,
    if (note != null) 'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PursuitTransaction.fromJson(Map<String, dynamic> json) {
    return PursuitTransaction(
      id: json['id'] as String,
      pursuitId: json['pursuitId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      source: TransactionSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => TransactionSource.manual,
      ),
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  static String encodeList(List<PursuitTransaction> transactions) =>
      jsonEncode(transactions.map((t) => t.toJson()).toList());

  static List<PursuitTransaction> decodeList(String json) =>
      (jsonDecode(json) as List)
          .map((e) => PursuitTransaction.fromJson(e))
          .toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PursuitTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PursuitTransaction(id: $id, pursuitId: $pursuitId, amount: $amount)';
}
