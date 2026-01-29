import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/utils/currency_utils.dart';

void main() {
  group('getSimulationTimeDisplay', () {
    test('Bug fix: uses work hours per day, not calendar hours (24)', () {
      // User scenario from bug report:
      // - Salary: 62,500 TL/month
      // - Work: 5 days/week, 9 hours/day
      // - Expense: 5,500 TL
      // - Expected hours: ~17.4 hours
      // - Expected work days: 17.4 / 9 = 1.93 days (NOT 17.4/24 = 0.72 days)

      const hours = 17.4;
      const workHoursPerDay = 9.0;
      const workDaysPerWeek = 5;

      final result = getSimulationTimeDisplay(
        hours,
        workHoursPerDay: workHoursPerDay,
        workDaysPerWeek: workDaysPerWeek,
      );

      // Should show ~1.9 days, not 0.7 days
      final displayedDays = double.tryParse(result.value2.replaceAll(',', '.')) ?? 0;

      expect(displayedDays, closeTo(1.9, 0.1),
        reason: 'Days should be calculated using work hours (9), not calendar hours (24)');
      expect(displayedDays, greaterThan(1.5),
        reason: 'Days must be greater than 1.5 for 17.4 work hours at 9 hrs/day');
    });

    test('default work hours (8 hrs/day, 5 days/week)', () {
      const hours = 16.0; // 2 work days at 8 hours

      final result = getSimulationTimeDisplay(hours);

      final displayedDays = double.tryParse(result.value2.replaceAll(',', '.')) ?? 0;
      expect(displayedDays, closeTo(2.0, 0.1));
    });

    test('part-time worker (4 hrs/day)', () {
      const hours = 8.0; // 2 work days at 4 hours

      final result = getSimulationTimeDisplay(
        hours,
        workHoursPerDay: 4,
      );

      final displayedDays = double.tryParse(result.value2.replaceAll(',', '.')) ?? 0;
      expect(displayedDays, closeTo(2.0, 0.1));
    });

    test('long work day (12 hrs/day)', () {
      const hours = 24.0; // 2 work days at 12 hours

      final result = getSimulationTimeDisplay(
        hours,
        workHoursPerDay: 12,
      );

      final displayedDays = double.tryParse(result.value2.replaceAll(',', '.')) ?? 0;
      expect(displayedDays, closeTo(2.0, 0.1));
    });

    test('zero hours returns zero values', () {
      final result = getSimulationTimeDisplay(0);

      expect(result.value1, '0');
      expect(result.value2, '0');
      expect(result.isYearMode, false);
    });

    test('year mode threshold uses work hours', () {
      // Year mode should activate based on work hours, not calendar hours
      // With 8 hrs/day, 5 days/week: yearly work hours = 5 * 52 * 8 = 2080 hours

      final belowYearResult = getSimulationTimeDisplay(2000);
      expect(belowYearResult.isYearMode, false);

      final aboveYearResult = getSimulationTimeDisplay(2100);
      expect(aboveYearResult.isYearMode, true);
      expect(aboveYearResult.unit1, 'Yıl');
    });

    test('year calculation with custom work schedule', () {
      // With 6 days/week, 10 hrs/day: yearly = 6 * 52 * 10 = 3120 hours
      const workHoursPerDay = 10.0;
      const workDaysPerWeek = 6;

      final result = getSimulationTimeDisplay(
        3120, // Exactly 1 year of work
        workHoursPerDay: workHoursPerDay,
        workDaysPerWeek: workDaysPerWeek,
      );

      expect(result.isYearMode, true);
      final years = double.tryParse(result.value1.replaceAll(',', '.')) ?? 0;
      expect(years, closeTo(1.0, 0.1));
    });

    test('hours display uses Turkish number format', () {
      final result = getSimulationTimeDisplay(17.4);

      // Should use comma as decimal separator (Turkish format)
      expect(result.value1, contains(','));
      expect(result.unit1, 'Saat');
    });

    test('days display shows correct unit', () {
      final result = getSimulationTimeDisplay(8);

      expect(result.unit2, 'Gün');
    });
  });
}
