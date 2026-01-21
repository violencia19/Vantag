import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/services/calculation_service.dart';
import 'package:vantag/models/user_profile.dart';
import 'package:vantag/models/income_source.dart';

void main() {
  late CalculationService calculationService;

  setUp(() {
    calculationService = CalculationService();
  });

  group('CalculationService', () {
    group('calculateExpense', () {
      test('normal case - calculates hours required correctly', () {
        // Arrange: 10,000 TL monthly income, 8 hours/day, 5 days/week
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
          dailyHours: 8,
          workDaysPerWeek: 5,
        );

        // Act: Calculate for 1000 TL expense in January 2024
        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 1,
          year: 2024,
        );

        // Assert
        expect(result.expenseAmount, 1000);
        expect(result.hoursRequired, greaterThan(0));
        expect(result.daysRequired, greaterThan(0));

        // January 2024 has 23 work days (Mon-Fri)
        // Total hours = 23 * 8 = 184 hours
        // Hourly rate = 10000 / 184 = ~54.35 TL/hour
        // Hours for 1000 TL = 1000 / 54.35 = ~18.4 hours
        expect(result.hoursRequired, closeTo(18.4, 0.5));
        expect(result.daysRequired, closeTo(2.3, 0.2));
      });

      test('zero income - returns zero hours required', () {
        // Arrange: Profile with no income
        const profile = UserProfile(
          incomeSources: [],
          dailyHours: 8,
          workDaysPerWeek: 5,
        );

        // Act
        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 1000,
          month: 1,
          year: 2024,
        );

        // Assert: With zero income, hours required should be 0
        expect(result.expenseAmount, 1000);
        expect(result.hoursRequired, 0.0);
        expect(result.daysRequired, 0.0);
      });

      test('high expense relative to income - calculates proportionally', () {
        // Arrange: 5,000 TL income, expense equals full income
        final profile = UserProfile(
          incomeSources: [
            IncomeSource(
              id: '1',
              title: 'Maaş',
              amount: 5000,
              category: IncomeCategory.salary,
              createdAt: DateTime.now(),
              isPrimary: true,
            ),
          ],
          dailyHours: 8,
          workDaysPerWeek: 5,
        );

        // Act: Expense equals monthly income
        final result = calculationService.calculateExpense(
          userProfile: profile,
          expenseAmount: 5000,
          month: 1,
          year: 2024,
        );

        // Assert: Should require full month's work hours
        // January 2024 = 23 work days * 8 hours = 184 hours
        expect(result.hoursRequired, closeTo(184, 1));
        expect(result.daysRequired, closeTo(23, 1));
      });
    });

    group('workDaysInMonth', () {
      test('calculates work days for 5-day week correctly', () {
        // January 2024 has 23 weekdays (Mon-Fri)
        final workDays = calculationService.workDaysInMonth(2024, 1, 5);
        expect(workDays, 23);
      });

      test('calculates work days for 6-day week correctly', () {
        // January 2024: 23 weekdays + 4 Saturdays = 27 days
        final workDays = calculationService.workDaysInMonth(2024, 1, 6);
        expect(workDays, 27);
      });

      test('calculates work days for 7-day week correctly', () {
        // January 2024 has 31 days
        final workDays = calculationService.workDaysInMonth(2024, 1, 7);
        expect(workDays, 31);
      });

      test('February leap year has correct work days', () {
        // February 2024 is a leap year (29 days)
        final workDays = calculationService.workDaysInMonth(2024, 2, 5);
        expect(workDays, 21); // 21 weekdays in Feb 2024
      });
    });
  });
}
