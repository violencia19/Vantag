import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/models/expense.dart';

void main() {
  group('Expense', () {
    group('constructor', () {
      test('creates expense with required parameters', () {
        final expense = Expense(
          amount: 100.0,
          category: 'Yiyecek',
          date: DateTime(2024, 1, 15),
          hoursRequired: 2.5,
          daysRequired: 0.3,
        );

        expect(expense.amount, 100.0);
        expect(expense.category, 'Yiyecek');
        expect(expense.hoursRequired, 2.5);
        expect(expense.daysRequired, 0.3);
        expect(expense.decision, isNull);
        expect(expense.recordType, RecordType.real);
        expect(expense.status, ExpenseStatus.active);
        expect(expense.isSmartChoice, false);
        expect(expense.isMandatory, false);
        expect(expense.type, ExpenseType.single);
      });

      test('creates expense with all parameters', () {
        final expense = Expense(
          amount: 500.0,
          category: 'Elektronik',
          subCategory: 'Telefon',
          date: DateTime(2024, 1, 15),
          hoursRequired: 10.0,
          daysRequired: 1.25,
          decision: ExpenseDecision.yes,
          decisionDate: DateTime(2024, 1, 16),
          recordType: RecordType.simulation,
          status: ExpenseStatus.active,
          savedFrom: 600.0,
          isSmartChoice: true,
          originalAmount: 50.0,
          originalCurrency: 'USD',
          type: ExpenseType.installment,
          isMandatory: false,
          installmentCount: 6,
          currentInstallment: 1,
          cashPrice: 480.0,
          installmentTotal: 540.0,
        );

        expect(expense.subCategory, 'Telefon');
        expect(expense.decision, ExpenseDecision.yes);
        expect(expense.recordType, RecordType.simulation);
        expect(expense.savedFrom, 600.0);
        expect(expense.isSmartChoice, true);
        expect(expense.originalAmount, 50.0);
        expect(expense.originalCurrency, 'USD');
        expect(expense.type, ExpenseType.installment);
        expect(expense.installmentCount, 6);
      });
    });

    group('copyWith', () {
      late Expense baseExpense;

      setUp(() {
        baseExpense = Expense(
          amount: 100.0,
          category: 'Yiyecek',
          date: DateTime(2024, 1, 15),
          hoursRequired: 2.5,
          daysRequired: 0.3,
        );
      });

      test('copies with new amount', () {
        final copied = baseExpense.copyWith(amount: 200.0);
        expect(copied.amount, 200.0);
        expect(copied.category, 'Yiyecek');
      });

      test('copies with new category', () {
        final copied = baseExpense.copyWith(category: 'Ulaşım');
        expect(copied.amount, 100.0);
        expect(copied.category, 'Ulaşım');
      });

      test('copies with new decision', () {
        final copied = baseExpense.copyWith(decision: ExpenseDecision.no);
        expect(copied.decision, ExpenseDecision.no);
      });

      test('copies with new status', () {
        final copied = baseExpense.copyWith(status: ExpenseStatus.archived);
        expect(copied.status, ExpenseStatus.archived);
      });
    });

    group('JSON serialization', () {
      test('toJson and fromJson round trip', () {
        final original = Expense(
          amount: 150.0,
          category: 'Giyim',
          subCategory: 'Ayakkabı',
          date: DateTime(2024, 1, 15),
          hoursRequired: 3.75,
          daysRequired: 0.47,
          decision: ExpenseDecision.thinking,
          isSmartChoice: true,
          savedFrom: 200.0,
        );

        final json = original.toJson();
        final restored = Expense.fromJson(json);

        expect(restored.amount, original.amount);
        expect(restored.category, original.category);
        expect(restored.subCategory, original.subCategory);
        expect(restored.hoursRequired, original.hoursRequired);
        expect(restored.decision, original.decision);
        expect(restored.isSmartChoice, original.isSmartChoice);
        expect(restored.savedFrom, original.savedFrom);
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'amount': 100.0,
          'category': 'Yiyecek',
          'date': '2024-01-15T00:00:00.000',
          'hoursRequired': 2.5,
          'daysRequired': 0.3,
        };

        final expense = Expense.fromJson(json);
        expect(expense.amount, 100.0);
        expect(expense.decision, isNull);
        expect(expense.subCategory, isNull);
        expect(expense.savedFrom, isNull);
      });

      test('toJson includes all non-null fields', () {
        final expense = Expense(
          amount: 100.0,
          category: 'Yiyecek',
          date: DateTime(2024, 1, 15),
          hoursRequired: 2.5,
          daysRequired: 0.3,
          originalAmount: 10.0,
          originalCurrency: 'USD',
        );

        final json = expense.toJson();
        expect(json['amount'], 100.0);
        expect(json['category'], 'Yiyecek');
        expect(json['originalAmount'], 10.0);
        expect(json['originalCurrency'], 'USD');
      });
    });
  });

  group('ExpenseDecision', () {
    test('label returns correct Turkish text', () {
      expect(ExpenseDecision.yes.label, 'Aldım');
      expect(ExpenseDecision.thinking.label, 'Düşünüyorum');
      expect(ExpenseDecision.no.label, 'Vazgeçtim');
    });
  });

  group('RecordType', () {
    test('label returns correct Turkish text', () {
      expect(RecordType.real.label, 'Gerçek');
      expect(RecordType.simulation.label, 'Simülasyon');
    });
  });

  group('ExpenseType', () {
    test('label returns correct Turkish text', () {
      expect(ExpenseType.single.label, 'Tek Seferlik');
      expect(ExpenseType.recurring.label, 'Tekrarlayan');
      expect(ExpenseType.installment.label, 'Taksitli');
    });
  });

  group('ExpenseStatus', () {
    test('label returns correct Turkish text', () {
      expect(ExpenseStatus.active.label, 'Aktif');
      expect(ExpenseStatus.thinking.label, 'Karar Aşamasında');
      expect(ExpenseStatus.archived.label, 'İrade Zaferi');
    });

    test('displayName returns same as label', () {
      for (final status in ExpenseStatus.values) {
        expect(status.displayName, status.label);
      }
    });
  });

  group('CategoryThresholds', () {
    test('returns correct default for each category', () {
      expect(CategoryThresholds.getDefault('Yiyecek'), 150.0);
      expect(CategoryThresholds.getDefault('Ulaşım'), 100.0);
      expect(CategoryThresholds.getDefault('Elektronik'), 2000.0);
      expect(CategoryThresholds.getDefault('Giyim'), 500.0);
    });

    test('returns fallback for unknown category', () {
      expect(CategoryThresholds.getDefault('BilinmeyenKategori'), 150.0);
    });
  });

  group('ThinkingDurations', () {
    test('returns correct hours for each category', () {
      expect(ThinkingDurations.getHours('Yiyecek'), 24);
      expect(ThinkingDurations.getHours('Elektronik'), 168);
      expect(ThinkingDurations.getHours('Ulaşım'), 48);
    });

    test('returns fallback for unknown category', () {
      expect(ThinkingDurations.getHours('BilinmeyenKategori'), 48);
    });

    test('getDuration returns correct Duration', () {
      expect(ThinkingDurations.getDuration('Yiyecek'), const Duration(hours: 24));
      expect(ThinkingDurations.getDuration('Elektronik'), const Duration(hours: 168));
    });
  });

  group('ExpenseCategory', () {
    test('all contains expected categories', () {
      expect(ExpenseCategory.all, contains('Yiyecek'));
      expect(ExpenseCategory.all, contains('Ulaşım'));
      expect(ExpenseCategory.all, contains('Giyim'));
      expect(ExpenseCategory.all, contains('Elektronik'));
      expect(ExpenseCategory.all, contains('Eğlence'));
      expect(ExpenseCategory.all, contains('Sağlık'));
      expect(ExpenseCategory.all, contains('Eğitim'));
      expect(ExpenseCategory.all, contains('Faturalar'));
      expect(ExpenseCategory.all, contains('Abonelik'));
      expect(ExpenseCategory.all, contains('Diğer'));
    });

    test('getIcon returns non-null for all categories', () {
      for (final category in ExpenseCategory.all) {
        expect(ExpenseCategory.getIcon(category), isNotNull);
      }
    });

    test('getColor returns non-null for all categories', () {
      for (final category in ExpenseCategory.all) {
        expect(ExpenseCategory.getColor(category), isNotNull);
      }
    });

    test('getIcon returns fallback for unknown category', () {
      expect(ExpenseCategory.getIcon('BilinmeyenKategori'), isNotNull);
    });

    test('getColor returns fallback for unknown category', () {
      expect(ExpenseCategory.getColor('BilinmeyenKategori'), isNotNull);
    });
  });
}
