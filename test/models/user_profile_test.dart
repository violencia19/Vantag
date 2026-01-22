import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/models/user_profile.dart';
import 'package:vantag/models/income_source.dart';

void main() {
  group('UserProfile', () {
    group('constructor', () {
      test('creates profile with required parameters', () {
        final source = IncomeSource.salary(amount: 20000);
        final profile = UserProfile(
          incomeSources: [source],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );

        expect(profile.incomeSources.length, 1);
        expect(profile.workDaysPerWeek, 5);
        expect(profile.workHoursPerDay, 8);
        expect(profile.currency, 'TRY');
      });

      test('creates profile with all parameters', () {
        final source = IncomeSource.salary(amount: 25000);
        final profile = UserProfile(
          id: 'user_123',
          name: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          incomeSources: [source],
          workDaysPerWeek: 6,
          workHoursPerDay: 10,
          currency: 'USD',
          monthlyBudget: 5000,
        );

        expect(profile.id, 'user_123');
        expect(profile.name, 'Test User');
        expect(profile.photoUrl, 'https://example.com/photo.jpg');
        expect(profile.workDaysPerWeek, 6);
        expect(profile.workHoursPerDay, 10);
        expect(profile.currency, 'USD');
        expect(profile.monthlyBudget, 5000);
      });
    });

    group('monthlyIncome', () {
      test('returns sum of all income sources', () {
        final sources = [
          IncomeSource.salary(amount: 20000),
          IncomeSource.freelance(amount: 5000),
        ];
        final profile = UserProfile(
          incomeSources: sources,
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );

        expect(profile.monthlyIncome, 25000);
      });

      test('returns 0 when no income sources', () {
        final profile = UserProfile(
          incomeSources: [],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );

        expect(profile.monthlyIncome, 0);
      });
    });

    group('hourlyRate', () {
      test('calculates correct hourly rate', () {
        final source = IncomeSource.salary(amount: 17600);
        final profile = UserProfile(
          incomeSources: [source],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );

        // monthlyWorkHours = 5 * 4.33 * 8 = 173.2
        // hourlyRate = 17600 / 173.2 ≈ 101.6
        expect(profile.hourlyRate, closeTo(101.6, 1));
      });

      test('returns 0 when no income', () {
        final profile = UserProfile(
          incomeSources: [],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );

        expect(profile.hourlyRate, 0);
      });
    });

    group('monthlyWorkHours', () {
      test('calculates correct work hours', () {
        final source = IncomeSource.salary(amount: 20000);
        final profile = UserProfile(
          incomeSources: [source],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );

        // 5 days * 4.33 weeks * 8 hours = 173.2
        expect(profile.monthlyWorkHours, closeTo(173.2, 0.1));
      });
    });

    group('dailyBudget', () {
      test('calculates from monthly budget when set', () {
        final source = IncomeSource.salary(amount: 30000);
        final profile = UserProfile(
          incomeSources: [source],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
          monthlyBudget: 10000,
        );

        // 10000 / 30 ≈ 333.33
        expect(profile.dailyBudget, closeTo(333.33, 0.01));
      });

      test('calculates from income when budget not set', () {
        final source = IncomeSource.salary(amount: 30000);
        final profile = UserProfile(
          incomeSources: [source],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );

        // 30000 / 30 = 1000
        expect(profile.dailyBudget, 1000);
      });
    });

    group('copyWith', () {
      late UserProfile baseProfile;

      setUp(() {
        final source = IncomeSource.salary(amount: 20000);
        baseProfile = UserProfile(
          id: 'user_1',
          name: 'Test User',
          incomeSources: [source],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );
      });

      test('copies with new name', () {
        final copied = baseProfile.copyWith(name: 'New Name');
        expect(copied.name, 'New Name');
        expect(copied.workDaysPerWeek, 5);
      });

      test('copies with new work days', () {
        final copied = baseProfile.copyWith(workDaysPerWeek: 6);
        expect(copied.workDaysPerWeek, 6);
        expect(copied.name, 'Test User');
      });

      test('copies with new income sources', () {
        final newSources = [IncomeSource.salary(amount: 30000)];
        final copied = baseProfile.copyWith(incomeSources: newSources);
        expect(copied.monthlyIncome, 30000);
      });
    });

    group('JSON serialization', () {
      test('toJson and fromJson round trip', () {
        final source = IncomeSource.salary(amount: 25000);
        final original = UserProfile(
          id: 'user_123',
          name: 'Test User',
          incomeSources: [source],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
          currency: 'TRY',
          monthlyBudget: 8000,
        );

        final json = original.toJson();
        final restored = UserProfile.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.monthlyIncome, original.monthlyIncome);
        expect(restored.workDaysPerWeek, original.workDaysPerWeek);
        expect(restored.workHoursPerDay, original.workHoursPerDay);
        expect(restored.currency, original.currency);
        expect(restored.monthlyBudget, original.monthlyBudget);
      });
    });

    group('legacy constructor', () {
      test('creates profile with monthlyIncome parameter', () {
        final profile = UserProfile.legacy(
          monthlyIncome: 20000,
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );

        expect(profile.monthlyIncome, 20000);
        expect(profile.incomeSources.length, 1);
        expect(profile.incomeSources.first.type, IncomeType.salary);
      });
    });
  });

  group('IncomeSource', () {
    group('salary factory', () {
      test('creates salary income source', () {
        final source = IncomeSource.salary(amount: 20000);

        expect(source.type, IncomeType.salary);
        expect(source.amount, 20000);
        expect(source.isActive, true);
      });
    });

    group('freelance factory', () {
      test('creates freelance income source', () {
        final source = IncomeSource.freelance(amount: 5000);

        expect(source.type, IncomeType.freelance);
        expect(source.amount, 5000);
      });
    });

    group('JSON serialization', () {
      test('toJson and fromJson round trip', () {
        final original = IncomeSource.salary(amount: 25000, name: 'Main Job');

        final json = original.toJson();
        final restored = IncomeSource.fromJson(json);

        expect(restored.type, original.type);
        expect(restored.amount, original.amount);
        expect(restored.name, original.name);
        expect(restored.isActive, original.isActive);
      });
    });
  });
}
