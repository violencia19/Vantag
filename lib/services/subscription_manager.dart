import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/models.dart';
import 'subscription_service.dart';
import 'profile_service.dart';

/// Abonelik yönetim singleton'ı
/// İstatistik hesaplama, iş günü karşılığı, takvim desteği
class SubscriptionManager {
  static final SubscriptionManager _instance = SubscriptionManager._internal();
  factory SubscriptionManager() => _instance;
  SubscriptionManager._internal();

  final _subscriptionService = SubscriptionService();
  final _profileService = ProfileService();

  // Cache
  UserProfile? _cachedProfile;
  List<Subscription>? _cachedSubscriptions;
  DateTime? _lastCacheTime;
  static const _cacheValidityMinutes = 5;

  /// Cache'i temizle
  void clearCache() {
    _cachedProfile = null;
    _cachedSubscriptions = null;
    _lastCacheTime = null;
  }

  /// Cache geçerli mi?
  bool get _isCacheValid {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!).inMinutes < _cacheValidityMinutes;
  }

  /// Profil ve abonelikleri yükle (cache'li)
  Future<void> _ensureLoaded() async {
    if (_isCacheValid && _cachedProfile != null && _cachedSubscriptions != null) {
      return;
    }

    _cachedProfile = await _profileService.getProfile();
    _cachedSubscriptions = await _subscriptionService.getSubscriptions();
    _lastCacheTime = DateTime.now();
  }

  /// Tüm aktif abonelikleri getir
  Future<List<Subscription>> getActiveSubscriptions() async {
    await _ensureLoaded();
    return _cachedSubscriptions?.where((s) => s.isActive).toList() ?? [];
  }

  /// Aktif abonelik sayısı
  Future<int> getActiveCount() async {
    final active = await getActiveSubscriptions();
    return active.length;
  }

  /// Toplam aylık abonelik tutarı
  Future<double> getTotalMonthlyCost() async {
    final active = await getActiveSubscriptions();
    return active.fold<double>(0, (sum, s) => sum + s.amount);
  }

  /// Önümüzdeki X gün içinde yenilenecek abonelikleri getir
  Future<List<Subscription>> getUpcomingRenewals(int days) async {
    final active = await getActiveSubscriptions();
    return active.where((s) => s.daysUntilRenewal <= days).toList()
      ..sort((a, b) => a.daysUntilRenewal.compareTo(b.daysUntilRenewal));
  }

  /// Bugün yenilenecek abonelikleri getir
  Future<List<Subscription>> getTodayRenewals() async {
    final active = await getActiveSubscriptions();
    return active.where((s) => s.isRenewalToday).toList();
  }

  /// Yarın yenilenecek abonelikleri getir
  Future<List<Subscription>> getTomorrowRenewals() async {
    final active = await getActiveSubscriptions();
    return active.where((s) => s.isRenewalTomorrow).toList();
  }

  /// Belirli bir ay için abonelikleri gün bazında grupla (takvim görünümü için)
  /// Key: Ayın günü (1-31), Value: O gün yenilenen abonelikler
  Future<Map<int, List<Subscription>>> getSubscriptionsByDay(int year, int month) async {
    final active = await getActiveSubscriptions();
    final Map<int, List<Subscription>> result = {};

    for (final sub in active) {
      final renewalDay = sub.getRenewalDayForMonth(year, month);
      result.putIfAbsent(renewalDay, () => []).add(sub);
    }

    return result;
  }

  /// Bir abonelik için gereken iş günü sayısını hesapla
  Future<double> calculateWorkDays(double amount) async {
    await _ensureLoaded();
    if (_cachedProfile == null || _cachedProfile!.monthlyIncome <= 0) {
      return 0;
    }

    final profile = _cachedProfile!;

    // Aylık çalışma saati: workDaysPerWeek * 4.33 * dailyHours
    final monthlyWorkHours = profile.workDaysPerWeek * 4.33 * profile.dailyHours;
    if (monthlyWorkHours <= 0) return 0;

    // Saatlik ücret
    final hourlyRate = profile.monthlyIncome / monthlyWorkHours;
    if (hourlyRate <= 0) return 0;

    // Abonelik için gereken saat
    final hoursNeeded = amount / hourlyRate;

    // İş günü = saat / günlük çalışma saati
    return hoursNeeded / profile.dailyHours;
  }

  /// Bir abonelik için gereken iş saati
  Future<double> calculateWorkHours(double amount) async {
    await _ensureLoaded();
    if (_cachedProfile == null || _cachedProfile!.monthlyIncome <= 0) {
      return 0;
    }

    final profile = _cachedProfile!;

    final monthlyWorkHours = profile.workDaysPerWeek * 4.33 * profile.dailyHours;
    if (monthlyWorkHours <= 0) return 0;

    final hourlyRate = profile.monthlyIncome / monthlyWorkHours;
    if (hourlyRate <= 0) return 0;

    return amount / hourlyRate;
  }

  /// Toplam abonelikler için gereken aylık iş günü
  Future<double> calculateTotalMonthlyWorkDays() async {
    final total = await getTotalMonthlyCost();
    return calculateWorkDays(total);
  }

  /// Abonelik istatistikleri
  Future<SubscriptionStats> getStats() async {
    final active = await getActiveSubscriptions();
    final totalCost = await getTotalMonthlyCost();
    final workDays = await calculateTotalMonthlyWorkDays();
    final todayRenewals = await getTodayRenewals();
    final tomorrowRenewals = await getTomorrowRenewals();

    return SubscriptionStats(
      totalCount: active.length,
      totalMonthlyCost: totalCost,
      totalWorkDays: workDays,
      renewingTodayCount: todayRenewals.length,
      renewingTomorrowCount: tomorrowRenewals.length,
    );
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
}

/// Abonelik istatistikleri
class SubscriptionStats {
  final int totalCount;
  final double totalMonthlyCost;
  final double totalWorkDays;
  final int renewingTodayCount;
  final int renewingTomorrowCount;

  const SubscriptionStats({
    required this.totalCount,
    required this.totalMonthlyCost,
    required this.totalWorkDays,
    required this.renewingTodayCount,
    required this.renewingTomorrowCount,
  });

  /// Durum metni
  String get statusText {
    if (renewingTodayCount > 0) {
      return 'Bugün $renewingTodayCount abonelik yenileniyor';
    }
    if (renewingTomorrowCount > 0) {
      return 'Yarın $renewingTomorrowCount abonelik yenileniyor';
    }
    if (totalCount > 0) {
      return '$totalCount aktif abonelik';
    }
    return 'Henüz abonelik yok';
  }

  /// Durum rengi
  Color get statusColor {
    if (renewingTodayCount > 0) return const Color(0xFFFF8C42); // Turuncu
    if (renewingTomorrowCount > 0) return const Color(0xFFFFD93D); // Sarı
    return const Color(0xFF4ECDC4); // Turkuaz
  }

  /// Durum ikonu
  IconData get statusIcon {
    if (renewingTodayCount > 0) return LucideIcons.bellRing;
    if (renewingTomorrowCount > 0) return LucideIcons.clock;
    return LucideIcons.checkCircle;
  }
}

/// Global erişim için kısayol
final subscriptionManager = SubscriptionManager();
