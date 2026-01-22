import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/models/pursuit_transaction.dart';

void main() {
  group('PursuitTransaction', () {
    group('constructor', () {
      test('creates transaction with required parameters', () {
        final transaction = PursuitTransaction(
          id: 'tx_1',
          pursuitId: 'pursuit_1',
          amount: 1000,
          currency: 'TRY',
          source: TransactionSource.manual,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(transaction.id, 'tx_1');
        expect(transaction.pursuitId, 'pursuit_1');
        expect(transaction.amount, 1000);
        expect(transaction.currency, 'TRY');
        expect(transaction.source, TransactionSource.manual);
        expect(transaction.note, isNull);
      });

      test('creates transaction with all parameters', () {
        final transaction = PursuitTransaction(
          id: 'tx_1',
          pursuitId: 'pursuit_1',
          amount: 500,
          currency: 'USD',
          source: TransactionSource.pool,
          note: 'Monthly transfer',
          createdAt: DateTime(2024, 1, 15),
        );

        expect(transaction.note, 'Monthly transfer');
        expect(transaction.source, TransactionSource.pool);
      });
    });

    group('factory create', () {
      test('creates transaction with UUID', () {
        final transaction = PursuitTransaction.create(
          pursuitId: 'pursuit_1',
          amount: 1000,
          currency: 'TRY',
          source: TransactionSource.manual,
        );

        expect(transaction.id, isNotEmpty);
        expect(transaction.pursuitId, 'pursuit_1');
        expect(transaction.amount, 1000);
        expect(transaction.createdAt, isNotNull);
      });

      test('creates transaction with note', () {
        final transaction = PursuitTransaction.create(
          pursuitId: 'pursuit_1',
          amount: 500,
          currency: 'TRY',
          source: TransactionSource.expenseCancelled,
          note: 'Vazgeçilen harcama: Kahve',
        );

        expect(transaction.note, 'Vazgeçilen harcama: Kahve');
        expect(transaction.source, TransactionSource.expenseCancelled);
      });
    });

    group('JSON serialization', () {
      test('toJson and fromJson round trip', () {
        final original = PursuitTransaction(
          id: 'tx_1',
          pursuitId: 'pursuit_1',
          amount: 1500.50,
          currency: 'TRY',
          source: TransactionSource.pool,
          note: 'Test note',
          createdAt: DateTime(2024, 1, 15, 10, 30),
        );

        final json = original.toJson();
        final restored = PursuitTransaction.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.pursuitId, original.pursuitId);
        expect(restored.amount, original.amount);
        expect(restored.currency, original.currency);
        expect(restored.source, original.source);
        expect(restored.note, original.note);
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'id': 'tx_1',
          'pursuitId': 'pursuit_1',
          'amount': 1000,
          'source': 'manual',
        };

        final transaction = PursuitTransaction.fromJson(json);
        expect(transaction.currency, 'TRY');
        expect(transaction.note, isNull);
        expect(transaction.source, TransactionSource.manual);
      });

      test('fromJson handles unknown source', () {
        final json = {
          'id': 'tx_1',
          'pursuitId': 'pursuit_1',
          'amount': 1000,
          'source': 'unknown_source',
        };

        final transaction = PursuitTransaction.fromJson(json);
        expect(transaction.source, TransactionSource.manual);
      });

      test('encodeList and decodeList round trip', () {
        final transactions = [
          PursuitTransaction.create(
            pursuitId: 'p1',
            amount: 1000,
            currency: 'TRY',
            source: TransactionSource.manual,
          ),
          PursuitTransaction.create(
            pursuitId: 'p1',
            amount: 500,
            currency: 'TRY',
            source: TransactionSource.pool,
          ),
        ];

        final encoded = PursuitTransaction.encodeList(transactions);
        final decoded = PursuitTransaction.decodeList(encoded);

        expect(decoded.length, 2);
        expect(decoded[0].amount, 1000);
        expect(decoded[1].amount, 500);
      });
    });

    group('equality', () {
      test('two transactions with same id are equal', () {
        final t1 = PursuitTransaction(
          id: 'same_id',
          pursuitId: 'p1',
          amount: 1000,
          currency: 'TRY',
          source: TransactionSource.manual,
          createdAt: DateTime.now(),
        );

        final t2 = PursuitTransaction(
          id: 'same_id',
          pursuitId: 'p2',
          amount: 2000,
          currency: 'USD',
          source: TransactionSource.pool,
          createdAt: DateTime.now(),
        );

        expect(t1, equals(t2));
        expect(t1.hashCode, equals(t2.hashCode));
      });
    });

    group('toString', () {
      test('returns readable string', () {
        final transaction = PursuitTransaction(
          id: 'tx_123',
          pursuitId: 'pursuit_456',
          amount: 1000,
          currency: 'TRY',
          source: TransactionSource.manual,
          createdAt: DateTime.now(),
        );

        expect(
          transaction.toString(),
          'PursuitTransaction(id: tx_123, pursuitId: pursuit_456, amount: 1000.0)',
        );
      });
    });
  });

  group('TransactionSource', () {
    test('labelTr returns correct Turkish text', () {
      expect(TransactionSource.manual.labelTr, 'Manuel Ekleme');
      expect(TransactionSource.pool.labelTr, 'Havuzdan Transfer');
      expect(TransactionSource.expenseCancelled.labelTr, 'Vazgeçilen Harcama');
    });

    test('labelEn returns correct English text', () {
      expect(TransactionSource.manual.labelEn, 'Manual Entry');
      expect(TransactionSource.pool.labelEn, 'Pool Transfer');
      expect(TransactionSource.expenseCancelled.labelEn, 'Cancelled Expense');
    });

    test('values contains all expected sources', () {
      expect(TransactionSource.values, contains(TransactionSource.manual));
      expect(TransactionSource.values, contains(TransactionSource.pool));
      expect(TransactionSource.values, contains(TransactionSource.expenseCancelled));
      expect(TransactionSource.values.length, 3);
    });
  });
}
