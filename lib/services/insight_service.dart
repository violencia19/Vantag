import '../models/models.dart';

class InsightService {
  String getExpenseInsight(ExpenseResult result) {
    final hours = result.hoursRequired;
    final days = result.daysRequired;

    if (hours < 1) {
      final minutes = (hours * 60).round();
      return 'Bu harcama hayatından $minutes dakika aldı.';
    } else if (hours < 8) {
      return 'Bu harcama hayatından ${hours.toStringAsFixed(1)} saat aldı.';
    } else if (days < 1) {
      return 'Bu harcama için neredeyse bir gün çalıştın.';
    } else if (days < 5) {
      return 'Bu harcama hayatından ${days.toStringAsFixed(1)} gün aldı.';
    } else if (days < 20) {
      return 'Bu harcama için ${days.toStringAsFixed(0)} gün çalışman gerekti.';
    } else {
      return 'Bu harcama neredeyse bir aylık emeğine mal oldu.';
    }
  }

  String? getCategoryInsight(List<Expense> expenses, String category, int month, int year) {
    final categoryExpenses = expenses.where((e) =>
        e.category == category &&
        e.date.month == month &&
        e.date.year == year).toList();

    if (categoryExpenses.length < 2) return null;

    final totalHours = categoryExpenses.fold<double>(
        0, (sum, e) => sum + e.hoursRequired);
    final totalDays = categoryExpenses.fold<double>(
        0, (sum, e) => sum + e.daysRequired);

    if (totalDays >= 1) {
      return 'Bu ay $category için ${totalDays.toStringAsFixed(1)} gün çalıştın.';
    } else {
      return 'Bu ay $category için ${totalHours.toStringAsFixed(1)} saat çalıştın.';
    }
  }

  String? getMonthlyInsight(List<Expense> expenses, int month, int year) {
    final monthExpenses = expenses.where((e) =>
        e.date.month == month && e.date.year == year).toList();

    if (monthExpenses.isEmpty) return null;

    final totalDays = monthExpenses.fold<double>(
        0, (sum, e) => sum + e.daysRequired);

    if (totalDays >= 20) {
      return 'Bu ayki harcamalar için neredeyse tüm ay çalıştın.';
    } else if (totalDays >= 10) {
      return 'Bu ay harcamalar için ${totalDays.toStringAsFixed(0)} gün çalıştın.';
    }

    return null;
  }
}
