import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/models/expense.dart';

/// Tests for ExpenseHistoryService logic
/// Note: Full service tests require SharedPreferences and Firebase mocking
/// These tests focus on Expense model and DecisionStats calculations
void main() {
  group('Expense Model', () {
    // ========================================
    // Basic Expense Creation Tests
    // ========================================
    group('creation', () {
      test('1. creates expense with all required fields', () {
        final expense = Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime(2024, 1, 15),
          hoursRequired: 2.5,
          daysRequired: 0.3,
        );

        expect(expense.amount, 100);
        expect(expense.category, 'Yiyecek');
        expect(expense.hoursRequired, 2.5);
        expect(expense.daysRequired, 0.3);
      });

      test('2. default recordType is real', () {
        final expense = Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 2.5,
          daysRequired: 0.3,
        );

        expect(expense.recordType, RecordType.real);
        expect(expense.isReal, true);
        expect(expense.isSimulation, false);
      });

      test('3. creates simulation expense', () {
        final expense = Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 2.5,
          daysRequired: 0.3,
          recordType: RecordType.simulation,
        );

        expect(expense.isSimulation, true);
        expect(expense.isReal, false);
      });

      test('4. creates expense with decision', () {
        final expense = Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 2.5,
          daysRequired: 0.3,
          decision: ExpenseDecision.yes,
          decisionDate: DateTime.now(),
        );

        expect(expense.decision, ExpenseDecision.yes);
        expect(expense.decisionDate, isNotNull);
      });

      test('5. creates expense with multi-currency support', () {
        final expense = Expense(
          amount: 3200, // TRY
          category: 'Elektronik',
          date: DateTime.now(),
          hoursRequired: 8,
          daysRequired: 1,
          originalAmount: 100, // USD
          originalCurrency: 'USD',
        );

        expect(expense.originalAmount, 100);
        expect(expense.originalCurrency, 'USD');
      });
    });

    // ========================================
    // Installment Expense Tests
    // ========================================
    group('installments', () {
      test('6. calculates installment amount correctly', () {
        final expense = Expense(
          amount: 1000,
          category: 'Elektronik',
          date: DateTime.now(),
          hoursRequired: 10,
          daysRequired: 1.25,
          type: ExpenseType.installment,
          installmentCount: 12,
          installmentTotal: 12000,
          cashPrice: 10000,
        );

        // 12000 / 12 = 1000 TL per month
        expect(expense.installmentAmount, 1000);
      });

      test('7. calculates interest amount correctly', () {
        final expense = Expense(
          amount: 1000,
          category: 'Elektronik',
          date: DateTime.now(),
          hoursRequired: 10,
          daysRequired: 1.25,
          type: ExpenseType.installment,
          installmentCount: 12,
          installmentTotal: 12000,
          cashPrice: 10000,
        );

        // 12000 - 10000 = 2000 TL interest
        expect(expense.interestAmount, 2000);
      });

      test('8. calculates interest rate correctly', () {
        final expense = Expense(
          amount: 1000,
          category: 'Elektronik',
          date: DateTime.now(),
          hoursRequired: 10,
          daysRequired: 1.25,
          type: ExpenseType.installment,
          installmentCount: 12,
          installmentTotal: 12000,
          cashPrice: 10000,
        );

        // (2000 / 10000) * 100 = 20%
        expect(expense.interestRate, 20);
      });

      test('9. calculates remaining installments correctly', () {
        final expense = Expense(
          amount: 1000,
          category: 'Elektronik',
          date: DateTime.now(),
          hoursRequired: 10,
          daysRequired: 1.25,
          type: ExpenseType.installment,
          installmentCount: 12,
          currentInstallment: 5,
          installmentTotal: 12000,
        );

        // 12 - 5 = 7 remaining
        expect(expense.remainingInstallments, 7);
      });

      test('10. installment completed when no remaining', () {
        final expense = Expense(
          amount: 1000,
          category: 'Elektronik',
          date: DateTime.now(),
          hoursRequired: 10,
          daysRequired: 1.25,
          type: ExpenseType.installment,
          installmentCount: 12,
          currentInstallment: 12,
        );

        expect(expense.isInstallmentCompleted, true);
      });
    });

    // ========================================
    // Smart Choice Tests
    // ========================================
    group('smart choice', () {
      test('11. calculates saved amount from smart choice', () {
        final expense = Expense(
          amount: 50,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 1,
          daysRequired: 0.125,
          isSmartChoice: true,
          savedFrom: 100,
        );

        // 100 - 50 = 50 TL saved
        expect(expense.savedAmount, 50);
      });

      test('12. saved amount is zero when not smart choice', () {
        final expense = Expense(
          amount: 50,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 1,
          daysRequired: 0.125,
          isSmartChoice: false,
          savedFrom: 100,
        );

        expect(expense.savedAmount, 0);
      });

      test('13. saved amount clamped to zero minimum', () {
        final expense = Expense(
          amount: 150, // More than savedFrom
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 3,
          daysRequired: 0.375,
          isSmartChoice: true,
          savedFrom: 100,
        );

        expect(expense.savedAmount, 0);
      });
    });

    // ========================================
    // Thinking Items Tests
    // ========================================
    group('thinking items', () {
      test('14. expiration date calculated for thinking decision', () {
        final now = DateTime.now();
        final expense = Expense(
          amount: 100,
          category: 'Yiyecek',
          date: now,
          hoursRequired: 2,
          daysRequired: 0.25,
          decision: ExpenseDecision.thinking,
          decisionDate: now,
        );

        // Yiyecek has 24 hours thinking duration
        expect(expense.expirationDate, isNotNull);
        expect(
          expense.expirationDate!.difference(now).inHours,
          closeTo(24, 1),
        );
      });

      test('15. expiration date null for non-thinking decisions', () {
        final expense = Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 2,
          daysRequired: 0.25,
          decision: ExpenseDecision.yes,
        );

        expect(expense.expirationDate, isNull);
      });

      test('16. isExpired returns true for past expiration', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 7));
        final expense = Expense(
          amount: 100,
          category: 'Yiyecek',
          date: pastDate,
          hoursRequired: 2,
          daysRequired: 0.25,
          decision: ExpenseDecision.thinking,
          decisionDate: pastDate,
        );

        // 24 hours from 7 days ago = definitely expired
        expect(expense.isExpired, true);
      });

      test('17. remaining time calculated correctly', () {
        final expense = Expense(
          amount: 100,
          category: 'Elektronik', // 168 hours (7 days)
          date: DateTime.now(),
          hoursRequired: 2,
          daysRequired: 0.25,
          decision: ExpenseDecision.thinking,
          decisionDate: DateTime.now(),
        );

        final remaining = expense.remainingTime;
        expect(remaining, isNotNull);
        expect(remaining!.inHours, closeTo(168, 2));
      });
    });

    // ========================================
    // Simulation Detection Tests
    // ========================================
    group('simulation detection', () {
      test('18. small amount is real expense', () {
        final type = Expense.detectRecordType(100000, 10);
        expect(type, RecordType.real);
      });

      test('19. very large amount is simulation', () {
        final type = Expense.detectRecordType(1000000, 100);
        expect(type, RecordType.simulation);
      });

      test('20. middle range needs dialog', () {
        expect(Expense.needsSimulationDialog(500000), true);
      });

      test('21. below threshold does not need dialog', () {
        expect(Expense.needsSimulationDialog(100000), false);
      });

      test('22. above simulation threshold does not need dialog', () {
        expect(Expense.needsSimulationDialog(1000000), false);
      });
    });

    // ========================================
    // JSON Serialization Tests
    // ========================================
    group('json serialization', () {
      test('23. toJson includes all fields', () {
        final expense = Expense(
          amount: 100,
          category: 'Yiyecek',
          subCategory: 'Kahve',
          date: DateTime(2024, 1, 15),
          hoursRequired: 2.5,
          daysRequired: 0.3,
          decision: ExpenseDecision.yes,
          decisionDate: DateTime(2024, 1, 15),
          recordType: RecordType.real,
          originalAmount: 3.0,
          originalCurrency: 'USD',
          type: ExpenseType.single,
          isMandatory: false,
        );

        final json = expense.toJson();

        expect(json['amount'], 100);
        expect(json['category'], 'Yiyecek');
        expect(json['subCategory'], 'Kahve');
        expect(json['decision'], 'yes');
        expect(json['originalAmount'], 3.0);
        expect(json['originalCurrency'], 'USD');
      });

      test('24. fromJson restores expense correctly', () {
        final original = Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime(2024, 1, 15),
          hoursRequired: 2.5,
          daysRequired: 0.3,
          decision: ExpenseDecision.no,
        );

        final json = original.toJson();
        final restored = Expense.fromJson(json);

        expect(restored.amount, original.amount);
        expect(restored.category, original.category);
        expect(restored.decision, original.decision);
        expect(restored.hoursRequired, original.hoursRequired);
      });

      test('25. encodeList and decodeList work correctly', () {
        final expenses = [
          Expense(
            amount: 100,
            category: 'Yiyecek',
            date: DateTime(2024, 1, 15),
            hoursRequired: 2.5,
            daysRequired: 0.3,
          ),
          Expense(
            amount: 200,
            category: 'Ulaşım',
            date: DateTime(2024, 1, 16),
            hoursRequired: 5,
            daysRequired: 0.6,
          ),
        ];

        final encoded = Expense.encodeList(expenses);
        final decoded = Expense.decodeList(encoded);

        expect(decoded.length, 2);
        expect(decoded[0].amount, 100);
        expect(decoded[1].amount, 200);
      });

      test('26. backward compatibility with old data (missing fields)', () {
        final oldJson = {
          'amount': 100,
          'category': 'Yiyecek',
          'date': DateTime(2024, 1, 15).toIso8601String(),
          'hoursRequired': 2.5,
          'daysRequired': 0.3,
          // Missing: decision, recordType, status, etc.
        };

        final expense = Expense.fromJson(oldJson);

        expect(expense.amount, 100);
        expect(expense.recordType, RecordType.real); // Default
        expect(expense.status, ExpenseStatus.active); // Default
        expect(expense.isSmartChoice, false); // Default
      });
    });

    // ========================================
    // copyWith Tests
    // ========================================
    group('copyWith', () {
      test('27. copyWith preserves unchanged fields', () {
        final original = Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime(2024, 1, 15),
          hoursRequired: 2.5,
          daysRequired: 0.3,
          decision: ExpenseDecision.yes,
        );

        final modified = original.copyWith(amount: 200);

        expect(modified.amount, 200);
        expect(modified.category, 'Yiyecek'); // Preserved
        expect(modified.decision, ExpenseDecision.yes); // Preserved
      });

      test('28. copyWith can change multiple fields', () {
        final original = Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime(2024, 1, 15),
          hoursRequired: 2.5,
          daysRequired: 0.3,
        );

        final modified = original.copyWith(
          amount: 200,
          category: 'Ulaşım',
          decision: ExpenseDecision.no,
        );

        expect(modified.amount, 200);
        expect(modified.category, 'Ulaşım');
        expect(modified.decision, ExpenseDecision.no);
      });
    });
  });

  // ========================================
  // DecisionStats Tests
  // ========================================
  group('DecisionStats', () {
    test('1. empty list returns zero stats', () {
      final stats = DecisionStats.fromExpenses([]);

      expect(stats.yesCount, 0);
      expect(stats.yesTotal, 0);
      expect(stats.noCount, 0);
      expect(stats.noTotal, 0);
      expect(stats.thinkingCount, 0);
      expect(stats.totalDecisions, 0);
    });

    test('2. counts yes decisions correctly', () {
      final expenses = [
        Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 2,
          daysRequired: 0.25,
          decision: ExpenseDecision.yes,
        ),
        Expense(
          amount: 200,
          category: 'Ulaşım',
          date: DateTime.now(),
          hoursRequired: 4,
          daysRequired: 0.5,
          decision: ExpenseDecision.yes,
        ),
      ];

      final stats = DecisionStats.fromExpenses(expenses);

      expect(stats.yesCount, 2);
      expect(stats.yesTotal, 300);
    });

    test('3. counts no decisions and calculates saved', () {
      final expenses = [
        Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 2,
          daysRequired: 0.25,
          decision: ExpenseDecision.no,
        ),
        Expense(
          amount: 500,
          category: 'Giyim',
          date: DateTime.now(),
          hoursRequired: 10,
          daysRequired: 1.25,
          decision: ExpenseDecision.no,
        ),
      ];

      final stats = DecisionStats.fromExpenses(expenses);

      expect(stats.noCount, 2);
      expect(stats.noTotal, 600);
      expect(stats.savedAmount, 600);
      expect(stats.savedHours, 12);
      expect(stats.savedDays, 1.5);
    });

    test('4. counts thinking decisions', () {
      final expenses = [
        Expense(
          amount: 300,
          category: 'Elektronik',
          date: DateTime.now(),
          hoursRequired: 6,
          daysRequired: 0.75,
          decision: ExpenseDecision.thinking,
        ),
      ];

      final stats = DecisionStats.fromExpenses(expenses);

      expect(stats.thinkingCount, 1);
      expect(stats.thinkingTotal, 300);
    });

    test('5. mixed decisions calculated correctly', () {
      final expenses = [
        Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 2,
          daysRequired: 0.25,
          decision: ExpenseDecision.yes,
        ),
        Expense(
          amount: 200,
          category: 'Ulaşım',
          date: DateTime.now(),
          hoursRequired: 4,
          daysRequired: 0.5,
          decision: ExpenseDecision.no,
        ),
        Expense(
          amount: 300,
          category: 'Giyim',
          date: DateTime.now(),
          hoursRequired: 6,
          daysRequired: 0.75,
          decision: ExpenseDecision.thinking,
        ),
      ];

      final stats = DecisionStats.fromExpenses(expenses);

      expect(stats.totalDecisions, 3);
      expect(stats.yesCount, 1);
      expect(stats.noCount, 1);
      expect(stats.thinkingCount, 1);
    });

    test('6. smart choice savings calculated', () {
      final expenses = [
        Expense(
          amount: 50,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 1,
          daysRequired: 0.125,
          decision: ExpenseDecision.yes,
          isSmartChoice: true,
          savedFrom: 100,
        ),
        Expense(
          amount: 80,
          category: 'Ulaşım',
          date: DateTime.now(),
          hoursRequired: 1.6,
          daysRequired: 0.2,
          decision: ExpenseDecision.yes,
          isSmartChoice: true,
          savedFrom: 150,
        ),
      ];

      final stats = DecisionStats.fromExpenses(expenses);

      // Smart choice saved: (100-50) + (150-80) = 50 + 70 = 120
      expect(stats.smartChoiceCount, 2);
      expect(stats.smartChoiceSaved, 120);
    });

    test('7. totalSaved includes both no decisions and smart choice', () {
      final expenses = [
        // No decision saves 100
        Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 2,
          daysRequired: 0.25,
          decision: ExpenseDecision.no,
        ),
        // Smart choice saves 50
        Expense(
          amount: 50,
          category: 'Ulaşım',
          date: DateTime.now(),
          hoursRequired: 1,
          daysRequired: 0.125,
          decision: ExpenseDecision.yes,
          isSmartChoice: true,
          savedFrom: 100,
        ),
      ];

      final stats = DecisionStats.fromExpenses(expenses);

      // Total saved = noTotal (100) + smartChoiceSaved (50) = 150
      expect(stats.totalSaved, 150);
    });

    test('8. null decisions are not counted', () {
      final expenses = [
        Expense(
          amount: 100,
          category: 'Yiyecek',
          date: DateTime.now(),
          hoursRequired: 2,
          daysRequired: 0.25,
          decision: null, // No decision yet
        ),
      ];

      final stats = DecisionStats.fromExpenses(expenses);

      expect(stats.totalDecisions, 0);
      expect(stats.yesCount, 0);
      expect(stats.noCount, 0);
    });
  });

  // ========================================
  // ExpenseCategory Tests
  // ========================================
  group('ExpenseCategory', () {
    test('1. all returns all categories', () {
      expect(ExpenseCategory.all.length, 10);
      expect(ExpenseCategory.all.contains('Yiyecek'), true);
      expect(ExpenseCategory.all.contains('Elektronik'), true);
    });

    test('2. getIcon returns icon for each category', () {
      for (final category in ExpenseCategory.all) {
        final icon = ExpenseCategory.getIcon(category);
        expect(icon, isNotNull);
      }
    });

    test('3. getColor returns color for each category', () {
      for (final category in ExpenseCategory.all) {
        final color = ExpenseCategory.getColor(category);
        expect(color, isNotNull);
      }
    });

    test('4. unknown category returns default icon', () {
      final icon = ExpenseCategory.getIcon('UnknownCategory');
      expect(icon, isNotNull); // Should return 'Diğer' icon
    });
  });

  // ========================================
  // Category Thresholds Tests
  // ========================================
  group('CategoryThresholds', () {
    test('1. returns default for each category', () {
      expect(CategoryThresholds.getDefault('Yiyecek'), 150.0);
      expect(CategoryThresholds.getDefault('Elektronik'), 2000.0);
    });

    test('2. returns fallback for unknown category', () {
      expect(CategoryThresholds.getDefault('Unknown'), 150.0);
    });
  });

  // ========================================
  // ThinkingDurations Tests
  // ========================================
  group('ThinkingDurations', () {
    test('1. returns hours for each category', () {
      expect(ThinkingDurations.getHours('Yiyecek'), 24);
      expect(ThinkingDurations.getHours('Elektronik'), 168); // 7 days
    });

    test('2. returns Duration for category', () {
      final duration = ThinkingDurations.getDuration('Elektronik');
      expect(duration, const Duration(hours: 168));
    });

    test('3. returns fallback for unknown category', () {
      expect(ThinkingDurations.getHours('Unknown'), 48);
    });
  });
}
