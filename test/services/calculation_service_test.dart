import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/services/calculation_service.dart';
import 'package:vantag/models/user_profile.dart';
import 'package:vantag/models/income_source.dart';

void main() {
  late CalculationService calculationService;

  setUp(() {
    calculationService = CalculationService();
  });

  // Helper function to create a profile with salary
  UserProfile createProfile({
    required double income,
    double dailyHours = 8,
    int workDaysPerWeek = 5,
  }) {
    return UserProfile(
      incomeSources: income > 0
          ? [
              IncomeSource(
                id: '1',
                title: 'Maaş',
                amount: income,
                category: IncomeCategory.salary,
                createdAt: DateTime.now(),
                isPrimary: true,
              ),
            ]
          : [],
      dailyHours: dailyHours,
      workDaysPerWeek: workDaysPerWeek,
    );
  }

  group('CalculationService', () {
    // ========================================
    // calculateExpense Tests (10+ cases)
    // ========================================
    group('calculateExpense', () {
      test('1. normal case - calculates hours required correctly', () {
        final profile = createProfile(income: 10000);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 1,
          year: 2024,
        );

        // January 2024 has 23 work days (Mon-Fri)
        // Total hours = 23 * 8 = 184 hours
        // Hourly rate = 10000 / 184 = ~54.35 TL/hour
        // Hours for 1000 TL = 1000 / 10000 * 184 = 18.4 hours
        expect(result.expenseAmount, 1000);
        expect(result.hoursRequired, closeTo(18.4, 0.5));
        expect(result.daysRequired, closeTo(2.3, 0.2));
      });

      test('2. zero income - returns zero hours required', () {
        final profile = createProfile(income: 0);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 1,
          year: 2024,
        );

        expect(result.expenseAmount, 1000);
        expect(result.hoursRequired, 0.0);
        expect(result.daysRequired, 0.0);
      });

      test('3. zero expense amount - returns zero hours', () {
        final profile = createProfile(income: 10000);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 0,
          month: 1,
          year: 2024,
        );

        expect(result.expenseAmount, 0);
        expect(result.hoursRequired, 0.0);
        expect(result.daysRequired, 0.0);
      });

      test('4. expense equals full monthly income - requires full month work', () {
        final profile = createProfile(income: 5000);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 5000,
          month: 1,
          year: 2024,
        );

        // January 2024 = 23 work days * 8 hours = 184 hours
        expect(result.hoursRequired, closeTo(184, 1));
        expect(result.daysRequired, closeTo(23, 1));
      });

      test('5. very small expense - calculates fractional hours', () {
        final profile = createProfile(income: 10000);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 10,
          month: 1,
          year: 2024,
        );

        // 10 / 10000 * 184 = 0.184 hours
        expect(result.hoursRequired, closeTo(0.184, 0.01));
        expect(result.hoursRequired, greaterThan(0));
      });

      test('6. very large expense (exceeds income) - proportional calculation', () {
        final profile = createProfile(income: 10000);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 100000,
          month: 1,
          year: 2024,
        );

        // 100000 / 10000 * 184 = 1840 hours (10 months worth)
        expect(result.hoursRequired, closeTo(1840, 10));
        expect(result.daysRequired, closeTo(230, 5));
      });

      test('7. different work days per week (6 days)', () {
        final profile = createProfile(income: 10000, workDaysPerWeek: 6);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 1,
          year: 2024,
        );

        // January 2024 with 6-day week = 27 work days
        // Total hours = 27 * 8 = 216 hours
        // Hours for 1000 TL = 1000 / 10000 * 216 = 21.6 hours
        expect(result.hoursRequired, closeTo(21.6, 0.5));
      });

      test('8. different work days per week (7 days)', () {
        final profile = createProfile(income: 10000, workDaysPerWeek: 7);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 1,
          year: 2024,
        );

        // January 2024 with 7-day week = 31 work days
        // Total hours = 31 * 8 = 248 hours
        // Hours for 1000 TL = 1000 / 10000 * 248 = 24.8 hours
        expect(result.hoursRequired, closeTo(24.8, 0.5));
      });

      test('9. different daily hours (4 hours part-time)', () {
        final profile = createProfile(income: 5000, dailyHours: 4);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 500,
          month: 1,
          year: 2024,
        );

        // January 2024 = 23 work days * 4 hours = 92 total hours
        // Hours for 500 TL = 500 / 5000 * 92 = 9.2 hours
        expect(result.hoursRequired, closeTo(9.2, 0.2));
      });

      test('10. zero daily hours - returns zero days required', () {
        final profile = UserProfile(
          incomeSources: [
            IncomeSource(
              id: '1',
              title: 'Maaş',
              amount: 10000,
              category: IncomeCategory.salary,
              createdAt: DateTime.now(),
              isPrimary: true,
            ),
          ],
          dailyHours: 0,
          workDaysPerWeek: 5,
        );

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 1,
          year: 2024,
        );

        // Zero daily hours means division by zero protection
        expect(result.daysRequired, 0.0);
      });

      test('11. February non-leap year calculation', () {
        final profile = createProfile(income: 10000);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 2,
          year: 2023, // Non-leap year
        );

        // February 2023 has 20 work days
        // Total hours = 20 * 8 = 160
        // Hours for 1000 TL = 1000 / 10000 * 160 = 16 hours
        expect(result.hoursRequired, closeTo(16, 0.5));
      });

      test('12. February leap year calculation', () {
        final profile = createProfile(income: 10000);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 2,
          year: 2024, // Leap year
        );

        // February 2024 has 21 work days
        // Total hours = 21 * 8 = 168
        // Hours for 1000 TL = 1000 / 10000 * 168 = 16.8 hours
        expect(result.hoursRequired, closeTo(16.8, 0.5));
      });

      test('13. December end of year calculation', () {
        final profile = createProfile(income: 10000);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 12,
          year: 2024,
        );

        // December 2024 has 22 work days (Mon-Fri)
        expect(result.hoursRequired, greaterThan(0));
      });

      test('14. multiple income sources calculation', () {
        final profile = UserProfile(
          incomeSources: [
            IncomeSource(
              id: '1',
              title: 'Maaş',
              amount: 10000,
              category: IncomeCategory.salary,
              createdAt: DateTime.now(),
              isPrimary: true,
            ),
            IncomeSource(
              id: '2',
              title: 'Freelance',
              amount: 5000,
              category: IncomeCategory.freelance,
              createdAt: DateTime.now(),
              isPrimary: false,
            ),
          ],
          dailyHours: 8,
          workDaysPerWeek: 5,
        );

        // Total income = 15000 TL
        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1500,
          month: 1,
          year: 2024,
        );

        // 1500 / 15000 * 184 = 18.4 hours
        expect(result.hoursRequired, closeTo(18.4, 0.5));
      });

      test('15. very high income - small hours for expense', () {
        final profile = createProfile(income: 1000000); // 1 million TL

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 1,
          year: 2024,
        );

        // 1000 / 1000000 * 184 = 0.184 hours
        expect(result.hoursRequired, closeTo(0.184, 0.01));
      });
    });

    // ========================================
    // workDaysInMonth Tests (10+ cases)
    // ========================================
    group('workDaysInMonth', () {
      test('1. January 2024 with 5-day work week', () {
        final workDays = calculationService.workDaysInMonth(2024, 1, 5);
        expect(workDays, 23); // 23 weekdays (Mon-Fri)
      });

      test('2. January 2024 with 6-day work week', () {
        final workDays = calculationService.workDaysInMonth(2024, 1, 6);
        expect(workDays, 27); // 23 weekdays + 4 Saturdays
      });

      test('3. January 2024 with 7-day work week', () {
        final workDays = calculationService.workDaysInMonth(2024, 1, 7);
        expect(workDays, 31); // All 31 days
      });

      test('4. February leap year (2024)', () {
        final workDays = calculationService.workDaysInMonth(2024, 2, 5);
        expect(workDays, 21); // 21 weekdays in Feb 2024
      });

      test('5. February non-leap year (2023)', () {
        final workDays = calculationService.workDaysInMonth(2023, 2, 5);
        expect(workDays, 20); // 20 weekdays in Feb 2023
      });

      test('6. April 30-day month', () {
        final workDays = calculationService.workDaysInMonth(2024, 4, 5);
        // April 2024 starts on Monday
        expect(workDays, 22); // 22 weekdays
      });

      test('7. work 4 days per week (Mon-Thu)', () {
        final workDays = calculationService.workDaysInMonth(2024, 1, 4);
        // January 2024: only Mon-Thu counted
        expect(workDays, lessThan(23));
        expect(workDays, greaterThan(15));
      });

      test('8. work 3 days per week (Mon-Wed)', () {
        final workDays = calculationService.workDaysInMonth(2024, 1, 3);
        expect(workDays, lessThan(20));
        expect(workDays, greaterThan(10));
      });

      test('9. work 2 days per week (Mon-Tue)', () {
        final workDays = calculationService.workDaysInMonth(2024, 1, 2);
        expect(workDays, lessThan(15));
        expect(workDays, greaterThan(5));
      });

      test('10. work 1 day per week (only Monday)', () {
        final workDays = calculationService.workDaysInMonth(2024, 1, 1);
        expect(workDays, greaterThanOrEqualTo(4)); // At least 4 Mondays
        expect(workDays, lessThanOrEqualTo(5)); // At most 5 Mondays
      });

      test('11. December 31-day month', () {
        final workDays = calculationService.workDaysInMonth(2024, 12, 5);
        expect(workDays, 22); // December 2024 has 22 weekdays
      });

      test('12. month boundary - handles December to January transition', () {
        final decWorkDays = calculationService.workDaysInMonth(2023, 12, 5);
        final janWorkDays = calculationService.workDaysInMonth(2024, 1, 5);

        // Both should be valid positive numbers
        expect(decWorkDays, greaterThan(0));
        expect(janWorkDays, greaterThan(0));
      });

      test('13. all months in a year have valid work days', () {
        for (int month = 1; month <= 12; month++) {
          final workDays = calculationService.workDaysInMonth(2024, month, 5);
          expect(workDays, greaterThan(15), reason: 'Month $month failed');
          expect(workDays, lessThanOrEqualTo(23), reason: 'Month $month failed');
        }
      });

      test('14. different years work correctly', () {
        // Test multiple years
        for (int year = 2020; year <= 2030; year++) {
          final workDays = calculationService.workDaysInMonth(year, 1, 5);
          expect(workDays, greaterThan(15), reason: 'Year $year failed');
          expect(workDays, lessThanOrEqualTo(23), reason: 'Year $year failed');
        }
      });
    });

    // ========================================
    // Edge Cases and Error Handling
    // ========================================
    group('edge cases', () {
      test('negative expense amount handled gracefully', () {
        final profile = createProfile(income: 10000);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: -100,
          month: 1,
          year: 2024,
        );

        // Negative amounts result in negative hours (no crash)
        expect(result.hoursRequired, lessThan(0));
      });

      test('very precise decimal amounts', () {
        final profile = createProfile(income: 10000.123);

        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000.456,
          month: 1,
          year: 2024,
        );

        expect(result.hoursRequired, greaterThan(0));
        expect(result.hoursRequired.isFinite, true);
      });

      test('maximum double value does not crash', () {
        final profile = createProfile(income: 10000);

        // Should not throw
        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: double.maxFinite / 2,
          month: 1,
          year: 2024,
        );

        expect(result.hoursRequired.isFinite || result.hoursRequired.isInfinite, true);
      });
    });
  });
}
