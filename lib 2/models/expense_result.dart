class ExpenseResult {
  final double expenseAmount;
  final double hoursRequired;
  final double daysRequired;

  const ExpenseResult({
    required this.expenseAmount,
    required this.hoursRequired,
    required this.daysRequired,
  });

  String get formattedResult {
    return 'Bu ürünü almak için ~${hoursRequired.toStringAsFixed(1)} saat veya ${daysRequired.toStringAsFixed(1)} gün çalışmanız gerekir';
  }
}
