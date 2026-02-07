import '../models/models.dart';

class CalculationService {
  int workDaysInMonth(int year, int month, int workDaysPerWeek) {
    final totalDays = DateTime(year, month + 1, 0).day;
    int count = 0;

    for (int i = 1; i <= totalDays; i++) {
      final day = DateTime(year, month, i);
      final weekday = day.weekday; // 1=Mon ... 7=Sun

      if (workDaysPerWeek == 7) {
        count++;
      } else if (workDaysPerWeek == 6 && weekday != 7) {
        count++;
      } else if (workDaysPerWeek == 5 && weekday <= 5) {
        count++;
      } else if (workDaysPerWeek < 5 && weekday <= workDaysPerWeek) {
        count++;
      }
    }

    return count;
  }

  ExpenseResult calculateExpense({
    required UserProfile userProfile,
    required double expenseAmount,
    required int month,
    required int year,
  }) {
    final totalWorkDays = workDaysInMonth(
      year,
      month,
      userProfile.workDaysPerWeek,
    );

    final totalWorkHours = totalWorkDays * userProfile.dailyHours;
    final hoursRequired = userProfile.monthlyIncome > 0
        ? (expenseAmount / userProfile.monthlyIncome) * totalWorkHours
        : 0.0;
    final daysRequired = userProfile.dailyHours > 0
        ? hoursRequired / userProfile.dailyHours
        : 0.0;

    return ExpenseResult(
      expenseAmount: expenseAmount,
      hoursRequired: hoursRequired,
      daysRequired: daysRequired,
    );
  }
}
