import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class SubscriptionService {
  static const _keySubscriptions = 'subscriptions';

  // Future chain pattern - race condition önleme
  static Future<void> _chain = Future.value();

  Future<T> _withLock<T>(Future<T> Function() operation) async {
    final previous = _chain;
    final completer = Completer<void>();
    _chain = completer.future;

    await previous;

    try {
      return await operation();
    } finally {
      completer.complete();
    }
  }

  /// Tüm abonelikleri getir
  Future<List<Subscription>> getSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keySubscriptions);

    if (json == null || json.isEmpty) {
      return [];
    }

    try {
      return Subscription.decodeList(json);
    } catch (e) {
      return [];
    }
  }

  /// Sadece aktif abonelikleri getir
  Future<List<Subscription>> getActiveSubscriptions() async {
    final all = await getSubscriptions();
    return all.where((s) => s.isActive).toList();
  }

  /// Abonelik ekle
  Future<void> addSubscription(Subscription subscription) async {
    await _withLock(() async {
      final subs = await getSubscriptions();
      subs.add(subscription);
      await _saveSubscriptions(subs);
    });
  }

  /// Abonelik güncelle
  Future<void> updateSubscription(String id, Subscription subscription) async {
    await _withLock(() async {
      final subs = await getSubscriptions();
      final index = subs.indexWhere((s) => s.id == id);
      if (index != -1) {
        subs[index] = subscription;
        await _saveSubscriptions(subs);
      }
    });
  }

  /// Abonelik sil
  Future<void> deleteSubscription(String id) async {
    await _withLock(() async {
      final subs = await getSubscriptions();
      subs.removeWhere((s) => s.id == id);
      await _saveSubscriptions(subs);
    });
  }

  /// Yaklaşan abonelikleri getir (önümüzdeki X gün içinde)
  Future<List<Subscription>> getUpcomingSubscriptions({
    int withinDays = 3,
  }) async {
    final active = await getActiveSubscriptions();
    return active.where((s) => s.daysUntilRenewal <= withinDays).toList()
      ..sort((a, b) => a.daysUntilRenewal.compareTo(b.daysUntilRenewal));
  }

  /// Yarın yenilenecek abonelikler (bildirim için)
  Future<List<Subscription>> getSubscriptionsRenewingTomorrow() async {
    final active = await getActiveSubscriptions();
    return active.where((s) => s.isRenewalTomorrow).toList();
  }

  /// Bugün yenilenecek abonelikler (otomatik kayıt için)
  Future<List<Subscription>> getSubscriptionsRenewingToday() async {
    final active = await getActiveSubscriptions();
    return active.where((s) => s.isRenewalToday).toList();
  }

  /// Toplam aylık abonelik tutarı
  Future<double> getTotalMonthlyAmount() async {
    final active = await getActiveSubscriptions();
    return active.fold<double>(0, (sum, s) => sum + s.amount);
  }

  /// Abonelik sayısı
  Future<int> getActiveCount() async {
    final active = await getActiveSubscriptions();
    return active.length;
  }

  Future<void> _saveSubscriptions(List<Subscription> subs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubscriptions, Subscription.encodeList(subs));
  }

  /// Benzersiz ID oluştur
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Sonraki kullanılabilir renk indeksini döndür (round-robin)
  Future<int> getNextColorIndex() async {
    final active = await getActiveSubscriptions();
    if (active.isEmpty) return 0;

    // Mevcut renkleri say
    final colorCounts = <int, int>{};
    for (final sub in active) {
      colorCounts[sub.colorIndex] = (colorCounts[sub.colorIndex] ?? 0) + 1;
    }

    // En az kullanılan rengi bul
    int minCount = 999;
    int minIndex = 0;
    for (int i = 0; i < SubscriptionColors.count; i++) {
      final count = colorCounts[i] ?? 0;
      if (count < minCount) {
        minCount = count;
        minIndex = i;
      }
    }

    return minIndex;
  }

  /// Bugün yenilenen ve otomatik kayıt açık olan abonelikleri getir
  Future<List<Subscription>> getAutoRecordSubscriptionsForToday() async {
    final today = await getSubscriptionsRenewingToday();
    return today.where((s) => s.autoRecord).toList();
  }

  /// Belirli bir ay için abonelikleri gün bazında grupla (takvim görünümü için)
  Future<Map<int, List<Subscription>>> getSubscriptionsByDay(
    int year,
    int month,
  ) async {
    final active = await getActiveSubscriptions();
    final Map<int, List<Subscription>> result = {};

    for (final sub in active) {
      final renewalDay = sub.getRenewalDayForMonth(year, month);
      result.putIfAbsent(renewalDay, () => []).add(sub);
    }

    return result;
  }
}
