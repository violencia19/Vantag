import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/models/user_profile.dart';
import 'package:vantag/models/income_source.dart';

void main() {
  group('UserProfile', () {
    group('constructor', () {
      test('creates profile with default values', () {
        const profile = UserProfile();

        expect(profile.incomeSources, isEmpty);
        expect(profile.dailyHours, 8);
        expect(profile.workDaysPerWeek, 5);
        expect(profile.monthlyBudget, isNull);
        expect(profile.monthlySavingsGoal, isNull);
      });

      test('creates profile with custom values', () {
        final source = IncomeSource.salary(amount: 25000);
        final profile = UserProfile(
          incomeSources: [source],
          dailyHours: 10,
          workDaysPerWeek: 6,
          monthlyBudget: 5000,
          monthlySavingsGoal: 2000,
        );

        expect(profile.incomeSources.length, 1);
        expect(profile.dailyHours, 10);
        expect(profile.workDaysPerWeek, 6);
        expect(profile.monthlyBudget, 5000);
        expect(profile.monthlySavingsGoal, 2000);
      });
    });

    group('monthlyIncome', () {
      test('returns sum of all income sources', () {
        final sources = [
          IncomeSource.salary(amount: 20000),
          IncomeSource.additional(
            title: 'Freelance',
            amount: 5000,
            category: IncomeCategory.freelance,
          ),
        ];
        final profile = UserProfile(incomeSources: sources);

        expect(profile.monthlyIncome, 25000);
      });

      test('returns 0 when no income sources', () {
        const profile = UserProfile();

        expect(profile.monthlyIncome, 0);
      });
    });

    group('hourlyRate', () {
      test('calculates correct hourly rate', () {
        final source = IncomeSource.salary(amount: 16000);
        final profile = UserProfile(
          incomeSources: [source],
          dailyHours: 8,
          workDaysPerWeek: 5,
        );

        // monthlyWorkHours = 8 * 5 * 4 = 160
        // hourlyRate = 16000 / 160 = 100
        expect(profile.hourlyRate, 100);
      });

      test('returns 0 when no income', () {
        const profile = UserProfile();

        expect(profile.hourlyRate, 0);
      });
    });

    group('monthlyWorkHours', () {
      test('calculates correct work hours', () {
        final source = IncomeSource.salary(amount: 20000);
        final profile = UserProfile(
          incomeSources: [source],
          dailyHours: 8,
          workDaysPerWeek: 5,
        );

        // 8 hours * 5 days * 4 weeks = 160
        expect(profile.monthlyWorkHours, 160);
      });
    });

    group('availableBudget', () {
      test('calculates from monthly budget when set', () {
        final source = IncomeSource.salary(amount: 30000);
        final profile = UserProfile(
          incomeSources: [source],
          monthlyBudget: 10000,
          monthlySavingsGoal: 2000,
        );

        // 10000 - 2000 = 8000
        expect(profile.availableBudget, 8000);
      });

      test('calculates from income when budget not set', () {
        final source = IncomeSource.salary(amount: 30000);
        final profile = UserProfile(
          incomeSources: [source],
          monthlySavingsGoal: 5000,
        );

        // 30000 - 5000 = 25000
        expect(profile.availableBudget, 25000);
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        final source = IncomeSource.salary(amount: 20000);
        final baseProfile = UserProfile(
          incomeSources: [source],
          dailyHours: 8,
          workDaysPerWeek: 5,
        );

        final copied = baseProfile.copyWith(workDaysPerWeek: 6);
        expect(copied.workDaysPerWeek, 6);
        expect(copied.dailyHours, 8);
      });

      test('copies with new income sources', () {
        final source = IncomeSource.salary(amount: 20000);
        final baseProfile = UserProfile(incomeSources: [source]);

        final newSources = [IncomeSource.salary(amount: 30000)];
        final copied = baseProfile.copyWith(incomeSources: newSources);
        expect(copied.monthlyIncome, 30000);
      });
    });

    group('income source management', () {
      test('addIncomeSource adds new source', () {
        const baseProfile = UserProfile();
        final source = IncomeSource.salary(amount: 20000);

        final updated = baseProfile.addIncomeSource(source);
        expect(updated.incomeSources.length, 1);
        expect(updated.monthlyIncome, 20000);
      });

      test('removeIncomeSource removes source by id', () {
        final source = IncomeSource.salary(amount: 20000);
        final profile = UserProfile(incomeSources: [source]);

        final updated = profile.removeIncomeSource(source.id);
        expect(updated.incomeSources, isEmpty);
      });

      test('updateIncomeSource updates existing source', () {
        final source = IncomeSource.salary(amount: 20000);
        final profile = UserProfile(incomeSources: [source]);

        final updatedSource = source.copyWith(amount: 25000);
        final updated = profile.updateIncomeSource(source.id, updatedSource);
        expect(updated.monthlyIncome, 25000);
      });
    });

    group('primarySource and additionalSources', () {
      test('returns primary source correctly', () {
        final primary = IncomeSource.salary(amount: 20000);
        final additional = IncomeSource.additional(
          title: 'Freelance',
          amount: 5000,
          category: IncomeCategory.freelance,
        );
        final profile = UserProfile(incomeSources: [primary, additional]);

        expect(profile.primarySource?.amount, 20000);
        expect(profile.primaryIncome, 20000);
      });

      test('returns additional sources correctly', () {
        final primary = IncomeSource.salary(amount: 20000);
        final additional1 = IncomeSource.additional(
          title: 'Freelance',
          amount: 5000,
          category: IncomeCategory.freelance,
        );
        final additional2 = IncomeSource.additional(
          title: 'Rental',
          amount: 3000,
          category: IncomeCategory.rental,
        );
        final profile = UserProfile(
          incomeSources: [primary, additional1, additional2],
        );

        expect(profile.additionalSources.length, 2);
        expect(profile.additionalIncome, 8000);
      });
    });

    group('legacy constructor', () {
      test('creates profile with single salary source', () {
        final profile = UserProfile.legacy(
          monthlyIncome: 20000,
          dailyHours: 8,
          workDaysPerWeek: 5,
        );

        expect(profile.monthlyIncome, 20000);
        expect(profile.incomeSources.length, 1);
        expect(profile.incomeSources.first.category, IncomeCategory.salary);
      });
    });
  });

  group('IncomeSource', () {
    group('salary factory', () {
      test('creates salary income source', () {
        final source = IncomeSource.salary(amount: 20000);

        expect(source.category, IncomeCategory.salary);
        expect(source.amount, 20000);
        expect(source.isPrimary, true);
        expect(source.title, 'Ana Maaş');
      });

      test('creates salary with custom title', () {
        final source = IncomeSource.salary(amount: 20000, title: 'Main Job');

        expect(source.title, 'Main Job');
      });
    });

    group('additional factory', () {
      test('creates additional income source', () {
        final source = IncomeSource.additional(
          title: 'Freelance Work',
          amount: 5000,
          category: IncomeCategory.freelance,
        );

        expect(source.category, IncomeCategory.freelance);
        expect(source.amount, 5000);
        expect(source.isPrimary, false);
        expect(source.title, 'Freelance Work');
      });
    });

    group('JSON serialization', () {
      test('toJson and fromJson round trip', () {
        final original = IncomeSource.salary(amount: 25000, title: 'Main Job');

        final json = original.toJson();
        final restored = IncomeSource.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.category, original.category);
        expect(restored.amount, original.amount);
        expect(restored.title, original.title);
        expect(restored.isPrimary, original.isPrimary);
      });

      test('encodeList and decodeList round trip', () {
        final sources = [
          IncomeSource.salary(amount: 20000),
          IncomeSource.additional(
            title: 'Side gig',
            amount: 5000,
            category: IncomeCategory.freelance,
          ),
        ];

        final encoded = IncomeSource.encodeList(sources);
        final decoded = IncomeSource.decodeList(encoded);

        expect(decoded.length, 2);
        expect(decoded[0].amount, 20000);
        expect(decoded[1].amount, 5000);
      });
    });

    group('copyWith', () {
      test('copies with new amount', () {
        final source = IncomeSource.salary(amount: 20000);
        final copied = source.copyWith(amount: 25000);

        expect(copied.amount, 25000);
        expect(copied.id, source.id);
      });
    });

    group('convertedTo', () {
      test('creates converted copy preserving original', () {
        final source = IncomeSource.salary(amount: 20000, currencyCode: 'TRY');
        final converted = source.convertedTo(
          newAmount: 600,
          newCurrencyCode: 'USD',
        );

        expect(converted.amount, 600);
        expect(converted.currencyCode, 'USD');
        expect(converted.originalAmount, 20000);
        expect(converted.originalCurrencyCode, 'TRY');
      });
    });
  });

  group('IncomeCategory', () {
    test('has all expected categories', () {
      expect(IncomeCategory.values, contains(IncomeCategory.salary));
      expect(IncomeCategory.values, contains(IncomeCategory.freelance));
      expect(IncomeCategory.values, contains(IncomeCategory.rental));
      expect(IncomeCategory.values, contains(IncomeCategory.passive));
      expect(IncomeCategory.values, contains(IncomeCategory.other));
    });

    test('label returns Turkish text', () {
      expect(IncomeCategory.salary.label, 'Maaş');
      expect(IncomeCategory.freelance.label, 'Freelance');
      expect(IncomeCategory.rental.label, 'Kira Geliri');
    });

    test('fromString returns correct category', () {
      expect(IncomeCategory.fromString('salary'), IncomeCategory.salary);
      expect(IncomeCategory.fromString('freelance'), IncomeCategory.freelance);
      expect(IncomeCategory.fromString('unknown'), IncomeCategory.other);
    });
  });
}
