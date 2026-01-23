import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Wealth Coach: ThinkingStats - Düşünüyorum istatistikleri
class ThinkingStats {
  final int totalCount;
  final int expiredCount;
  final int pendingCount;
  final double totalAmount;
  final double expiredAmount;
  final List<Expense> itemsNeedingReminder;

  const ThinkingStats({
    this.totalCount = 0,
    this.expiredCount = 0,
    this.pendingCount = 0,
    this.totalAmount = 0,
    this.expiredAmount = 0,
    this.itemsNeedingReminder = const [],
  });

  factory ThinkingStats.fromExpenses(List<Expense> expenses) {
    final thinkingItems = expenses
        .where((e) => e.decision == ExpenseDecision.thinking)
        .toList();

    final expiredItems = thinkingItems.where((e) => e.isExpired).toList();
    final pendingItems = thinkingItems.where((e) => !e.isExpired).toList();

    // 72 saat sonra hatırlatma gereken öğeler
    final reminderThreshold = DateTime.now().subtract(
      const Duration(hours: 72),
    );
    final needsReminder = thinkingItems.where((e) {
      final created = e.decisionDate ?? e.date;
      return created.isBefore(reminderThreshold) && !e.isExpired;
    }).toList();

    return ThinkingStats(
      totalCount: thinkingItems.length,
      expiredCount: expiredItems.length,
      pendingCount: pendingItems.length,
      totalAmount: thinkingItems.fold(0, (sum, e) => sum + e.amount),
      expiredAmount: expiredItems.fold(0, (sum, e) => sum + e.amount),
      itemsNeedingReminder: needsReminder,
    );
  }

  bool get hasExpiredItems => expiredCount > 0;
  bool get hasItemsNeedingReminder => itemsNeedingReminder.isNotEmpty;
}

/// Wealth Coach: Düşünüyorum listesi yönetimi servisi
class ThinkingItemsService {
  static const _keyLastExpirationCheck = 'thinking_last_expiration_check';
  static const _keyExpiredItemsNotified = 'thinking_expired_notified';

  /// Uygulama açılışında süresi dolan öğeleri kontrol et
  static Future<List<Expense>> checkAndExpireItems(
    List<Expense> expenses,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Son kontrol zamanını al
    final lastCheckStr = prefs.getString(_keyLastExpirationCheck);
    final lastCheck = lastCheckStr != null
        ? DateTime.parse(lastCheckStr)
        : DateTime.now().subtract(const Duration(days: 1));

    // Günde bir kez kontrol et
    if (DateTime.now().difference(lastCheck).inHours < 24) {
      return [];
    }

    // Kontrol zamanını güncelle
    await prefs.setString(
      _keyLastExpirationCheck,
      DateTime.now().toIso8601String(),
    );

    // Süresi dolan thinking items'ları bul
    final expiredItems = expenses
        .where(
          (e) =>
              e.decision == ExpenseDecision.thinking &&
              e.isExpired &&
              e.status != ExpenseStatus.archived,
        )
        .toList();

    return expiredItems;
  }

  /// Süresi dolmuş öğeyi manuel olarak vazgeçilmiş olarak işaretle
  static Expense markAsAbandoned(Expense expense, {String? reason}) {
    return expense.copyWith(
      decision: ExpenseDecision.no,
      status: ExpenseStatus.archived,
      archivedAt: DateTime.now(),
      archiveReason: reason ?? 'Süre doldu - otomatik vazgeçildi',
    );
  }

  /// Süresi dolmuş öğeyi hâlâ almak istediğini işaretle
  static Expense markAsPurchased(Expense expense) {
    return expense.copyWith(
      decision: ExpenseDecision.yes,
      decisionDate: DateTime.now(),
    );
  }

  /// Düşünme süresini uzat (yeni karar tarihi ile)
  static Expense extendThinkingTime(Expense expense) {
    return expense.copyWith(decisionDate: DateTime.now());
  }

  /// 72 saat sonra hatırlatma gereken öğeleri getir
  static List<Expense> getItemsForReminder(List<Expense> expenses) {
    final reminderThreshold = DateTime.now().subtract(
      const Duration(hours: 72),
    );

    return expenses.where((e) {
      if (e.decision != ExpenseDecision.thinking) return false;
      if (e.isExpired) return false;

      final created = e.decisionDate ?? e.date;
      return created.isBefore(reminderThreshold);
    }).toList();
  }

  /// Kategori bazlı kalan süreyi formatla
  static String formatRemainingTime(Duration? remaining) {
    if (remaining == null ||
        remaining.isNegative ||
        remaining == Duration.zero) {
      return 'Süre doldu';
    }

    if (remaining.inDays > 0) {
      return '${remaining.inDays} gün kaldı';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} saat kaldı';
    } else {
      return '${remaining.inMinutes} dk kaldı';
    }
  }

  /// Süresi yakında dolacak öğeler (son 6 saat)
  static List<Expense> getExpiringItems(List<Expense> expenses) {
    final warningThreshold = const Duration(hours: 6);

    return expenses.where((e) {
      if (e.decision != ExpenseDecision.thinking) return false;
      if (e.isExpired) return false;

      final remaining = e.remainingTime;
      return remaining != null && remaining <= warningThreshold;
    }).toList();
  }

  /// Bildirim gönderilmiş süresi dolmuş öğeleri takip et
  static Future<void> markExpiredAsNotified(List<String> expenseIds) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_keyExpiredItemsNotified) ?? [];
    final updated = {...existing, ...expenseIds}.toList();
    await prefs.setStringList(_keyExpiredItemsNotified, updated);
  }

  /// Öğenin bildirilip bildirilmediğini kontrol et
  static Future<bool> wasNotified(String expenseId) async {
    final prefs = await SharedPreferences.getInstance();
    final notified = prefs.getStringList(_keyExpiredItemsNotified) ?? [];
    return notified.contains(expenseId);
  }

  /// Thinking items için özet mesaj oluştur
  static String getSummaryMessage(ThinkingStats stats) {
    if (stats.totalCount == 0) {
      return 'Düşündüğün bir harcama yok';
    }

    final parts = <String>[];

    if (stats.pendingCount > 0) {
      parts.add('${stats.pendingCount} harcama bekliyor');
    }

    if (stats.expiredCount > 0) {
      parts.add('${stats.expiredCount} karar bekliyor');
    }

    return parts.join(', ');
  }
}
