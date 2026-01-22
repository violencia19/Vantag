import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/services/pursuit_service.dart';
import 'package:vantag/models/pursuit.dart';
import 'package:vantag/models/pursuit_transaction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PursuitService', () {
    late PursuitService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = PursuitService();
    });

    Pursuit createTestPursuit({
      String? id,
      String name = 'Test Pursuit',
      double targetAmount = 10000,
      double savedAmount = 0,
      bool isArchived = false,
      DateTime? completedAt,
    }) {
      return Pursuit(
        id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        targetAmount: targetAmount,
        currency: 'TRY',
        savedAmount: savedAmount,
        emoji: '📱',
        category: PursuitCategory.tech,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isArchived: isArchived,
        completedAt: completedAt,
        sortOrder: DateTime.now().millisecondsSinceEpoch,
      );
    }

    group('getAllPursuits', () {
      test('returns empty list when no pursuits', () async {
        final pursuits = await service.getAllPursuits();
        expect(pursuits, isEmpty);
      });
    });

    group('createPursuit', () {
      test('creates pursuit successfully', () async {
        final pursuit = createTestPursuit(name: 'iPhone 15');
        await service.createPursuit(pursuit);

        final pursuits = await service.getAllPursuits();
        expect(pursuits.length, 1);
        expect(pursuits.first.name, 'iPhone 15');
      });

      test('creates multiple pursuits', () async {
        await service.createPursuit(createTestPursuit(name: 'iPhone'));
        await service.createPursuit(createTestPursuit(name: 'MacBook'));
        await service.createPursuit(createTestPursuit(name: 'iPad'));

        final pursuits = await service.getAllPursuits();
        expect(pursuits.length, 3);
      });
    });

    group('getActivePursuits', () {
      test('returns only active pursuits', () async {
        await service.createPursuit(createTestPursuit(name: 'Active1'));
        await service.createPursuit(createTestPursuit(name: 'Active2'));
        await service.createPursuit(createTestPursuit(name: 'Archived', isArchived: true));
        await service.createPursuit(createTestPursuit(name: 'Completed', completedAt: DateTime.now()));

        final active = await service.getActivePursuits();
        expect(active.length, 2);
        expect(active.every((p) => !p.isArchived && !p.isCompleted), true);
      });
    });

    group('getCompletedPursuits', () {
      test('returns only completed pursuits', () async {
        await service.createPursuit(createTestPursuit(name: 'Active'));
        await service.createPursuit(createTestPursuit(name: 'Completed1', completedAt: DateTime.now()));
        await service.createPursuit(createTestPursuit(name: 'Completed2', completedAt: DateTime.now()));

        final completed = await service.getCompletedPursuits();
        expect(completed.length, 2);
        expect(completed.every((p) => p.isCompleted), true);
      });
    });

    group('getPursuitById', () {
      test('returns pursuit by ID', () async {
        final pursuit = createTestPursuit(id: 'pursuit_123', name: 'Find Me');
        await service.createPursuit(pursuit);

        final found = await service.getPursuitById('pursuit_123');
        expect(found, isNotNull);
        expect(found!.name, 'Find Me');
      });

      test('returns null for non-existent ID', () async {
        await service.createPursuit(createTestPursuit());

        final found = await service.getPursuitById('non_existent');
        expect(found, isNull);
      });
    });

    group('updatePursuit', () {
      test('updates pursuit successfully', () async {
        final pursuit = createTestPursuit(id: 'pursuit_1', name: 'Original');
        await service.createPursuit(pursuit);

        final updated = pursuit.copyWith(name: 'Updated');
        await service.updatePursuit(updated);

        final found = await service.getPursuitById('pursuit_1');
        expect(found!.name, 'Updated');
      });
    });

    group('addSavings', () {
      test('adds savings to pursuit', () async {
        final pursuit = createTestPursuit(id: 'pursuit_1', savedAmount: 0);
        await service.createPursuit(pursuit);

        await service.addSavings('pursuit_1', 1000, TransactionSource.manual);

        final found = await service.getPursuitById('pursuit_1');
        expect(found!.savedAmount, 1000);
      });

      test('accumulates savings', () async {
        final pursuit = createTestPursuit(id: 'pursuit_1', savedAmount: 0);
        await service.createPursuit(pursuit);

        await service.addSavings('pursuit_1', 1000, TransactionSource.manual);
        await service.addSavings('pursuit_1', 500, TransactionSource.pool);
        await service.addSavings('pursuit_1', 250, TransactionSource.expenseCancelled);

        final found = await service.getPursuitById('pursuit_1');
        expect(found!.savedAmount, 1750);
      });

      test('creates transaction record', () async {
        final pursuit = createTestPursuit(id: 'pursuit_1');
        await service.createPursuit(pursuit);

        await service.addSavings('pursuit_1', 1000, TransactionSource.manual, note: 'Test');

        final transactions = await service.getTransactions('pursuit_1');
        expect(transactions.length, 1);
        expect(transactions.first.amount, 1000);
        expect(transactions.first.source, TransactionSource.manual);
      });
    });

    group('completePursuit', () {
      test('marks pursuit as completed', () async {
        final pursuit = createTestPursuit(id: 'pursuit_1');
        await service.createPursuit(pursuit);

        await service.completePursuit('pursuit_1');

        final found = await service.getPursuitById('pursuit_1');
        expect(found!.isCompleted, true);
        expect(found.completedAt, isNotNull);
      });
    });

    group('archivePursuit', () {
      test('archives pursuit', () async {
        final pursuit = createTestPursuit(id: 'pursuit_1');
        await service.createPursuit(pursuit);

        await service.archivePursuit('pursuit_1');

        final all = await service.getAllPursuits();
        final archived = all.firstWhere((p) => p.id == 'pursuit_1');
        expect(archived.isArchived, true);
      });
    });

    group('deletePursuit', () {
      test('deletes pursuit permanently', () async {
        final pursuit = createTestPursuit(id: 'pursuit_1');
        await service.createPursuit(pursuit);

        await service.deletePursuit('pursuit_1');

        final found = await service.getPursuitById('pursuit_1');
        expect(found, isNull);
      });
    });

    group('canCreatePursuit', () {
      test('premium user can always create', () async {
        await service.createPursuit(createTestPursuit());
        await service.createPursuit(createTestPursuit());

        final canCreate = await service.canCreatePursuit(true);
        expect(canCreate, true);
      });

      test('free user can create when no active pursuits', () async {
        final canCreate = await service.canCreatePursuit(false);
        expect(canCreate, true);
      });

      test('free user cannot create when has active pursuit', () async {
        await service.createPursuit(createTestPursuit());

        final canCreate = await service.canCreatePursuit(false);
        expect(canCreate, false);
      });

      test('free user can create when only has completed/archived pursuits', () async {
        await service.createPursuit(createTestPursuit(isArchived: true));
        await service.createPursuit(createTestPursuit(completedAt: DateTime.now()));

        final canCreate = await service.canCreatePursuit(false);
        expect(canCreate, true);
      });
    });

    group('getActivePursuitCount', () {
      test('returns correct count', () async {
        await service.createPursuit(createTestPursuit(name: 'Active1'));
        await service.createPursuit(createTestPursuit(name: 'Active2'));
        await service.createPursuit(createTestPursuit(name: 'Archived', isArchived: true));

        final count = await service.getActivePursuitCount();
        expect(count, 2);
      });
    });

    group('getTransactions', () {
      test('returns transactions for specific pursuit', () async {
        await service.createPursuit(createTestPursuit(id: 'p1'));
        await service.createPursuit(createTestPursuit(id: 'p2'));

        await service.addSavings('p1', 100, TransactionSource.manual);
        await service.addSavings('p1', 200, TransactionSource.pool);
        await service.addSavings('p2', 500, TransactionSource.manual);

        final p1Transactions = await service.getTransactions('p1');
        expect(p1Transactions.length, 2);

        final p2Transactions = await service.getTransactions('p2');
        expect(p2Transactions.length, 1);
      });

      test('returns empty list for pursuit with no transactions', () async {
        await service.createPursuit(createTestPursuit(id: 'p1'));

        final transactions = await service.getTransactions('p1');
        expect(transactions, isEmpty);
      });
    });

    group('clearAll', () {
      test('clears all data', () async {
        await service.createPursuit(createTestPursuit());
        await service.createPursuit(createTestPursuit());

        await service.clearAll();

        final pursuits = await service.getAllPursuits();
        expect(pursuits, isEmpty);
      });
    });
  });
}
