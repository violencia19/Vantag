import '../models/expense.dart';

/// AI için finansal hesaplama yardımcı fonksiyonları

/// Bu ayki toplam harcamayı hesaplar
double calculateMonthlySpent(List<Expense> expenses) {
  final now = DateTime.now();
  return expenses
      .where(
        (e) =>
            e.date.month == now.month &&
            e.date.year == now.year &&
            e.decision == ExpenseDecision.yes,
      )
      .fold(0.0, (sum, e) => sum + e.amount);
}

/// Tutarı çalışma saati olarak formatlar
String formatAsHours(double amount, double hourlyRate) {
  if (hourlyRate <= 0) return '-';
  final hours = amount / hourlyRate;
  return '${hours.toStringAsFixed(1)}h';
}

/// Bu ayki tasarruf miktarını hesaplar (vazgeçilen + smart choice)
double calculateMonthlySaved(List<Expense> expenses) {
  final now = DateTime.now();
  return expenses
      .where((e) => e.date.month == now.month && e.date.year == now.year)
      .fold(0.0, (sum, e) {
        double saved = 0.0;
        // Vazgeçilen harcamalar
        if (e.decision == ExpenseDecision.no) {
          saved += e.amount;
        }
        // Smart Choice tasarrufları
        if (e.isSmartChoice && e.savedAmount > 0) {
          saved += e.savedAmount;
        }
        return sum + saved;
      });
}

/// Belirli bir kategorideki bu ayki harcamayı hesaplar
double calculateCategorySpent(List<Expense> expenses, String category) {
  final now = DateTime.now();
  return expenses
      .where(
        (e) =>
            e.date.month == now.month &&
            e.date.year == now.year &&
            e.category == category &&
            e.decision == ExpenseDecision.yes,
      )
      .fold(0.0, (sum, e) => sum + e.amount);
}

/// Günlük ortalama harcamayı hesaplar
double calculateDailyAverage(List<Expense> expenses) {
  final now = DateTime.now();
  final thisMonthExpenses = expenses.where(
    (e) =>
        e.date.month == now.month &&
        e.date.year == now.year &&
        e.decision == ExpenseDecision.yes,
  );

  if (thisMonthExpenses.isEmpty) return 0.0;

  final total = thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
  final daysInMonth = now.day;
  return total / daysInMonth;
}
