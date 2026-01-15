import '../models/expense.dart';

/// Harcama tekrar tespiti için yardımcı sınıf
class DuplicateChecker {
  /// Verilen parametrelerle eşleşen harcamaları bul
  /// Aynı gün + aynı kategori + aynı tutar olan harcamaları döndürür
  static List<DuplicateMatch> findDuplicates({
    required List<Expense> expenses,
    required double amount,
    required String category,
    DateTime? date,
  }) {
    final checkDate = date ?? DateTime.now();
    final matches = <DuplicateMatch>[];

    for (final expense in expenses) {
      // Aynı gün mü?
      if (!_isSameDay(expense.date, checkDate)) continue;

      // Aynı kategori mi?
      if (expense.category != category) continue;

      // Aynı tutar mı? (küçük farklılıklar için 0.01 tolerans)
      if ((expense.amount - amount).abs() > 0.01) continue;

      // Eşleşme bulundu
      final timeDiff = DateTime.now().difference(expense.date);
      matches.add(DuplicateMatch(
        expense: expense,
        timeSinceEntry: timeDiff,
      ));
    }

    // En yeni eşleşme önce
    matches.sort((a, b) => b.expense.date.compareTo(a.expense.date));
    return matches;
  }

  /// İki tarihin aynı gün olup olmadığını kontrol et
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Eşleşen harcama bilgisi
class DuplicateMatch {
  final Expense expense;
  final Duration timeSinceEntry;

  const DuplicateMatch({
    required this.expense,
    required this.timeSinceEntry,
  });
}
