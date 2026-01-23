import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/theme/app_theme.dart';

/// Wealth Coach: Frugal Streak Manager
/// İrade Zaferi serisini takip eden sınıf
class StreakManager {
  static final StreakManager _instance = StreakManager._internal();
  factory StreakManager() => _instance;
  StreakManager._internal();

  // Mevcut durum
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastVictoryDate;

  // Birikimler
  double _totalSavedAmount = 0;
  double _totalSavedHours = 0;

  // SharedPreferences keys
  static const _keyCurrentStreak = 'frugal_current_streak';
  static const _keyLongestStreak = 'frugal_longest_streak';
  static const _keyLastVictoryDate = 'frugal_last_victory_date';
  static const _keyTotalSavedAmount = 'frugal_total_saved_amount';
  static const _keyTotalSavedHours = 'frugal_total_saved_hours';

  // Getters
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  DateTime? get lastVictoryDate => _lastVictoryDate;
  double get totalSavedAmount => _totalSavedAmount;
  double get totalSavedHours => _totalSavedHours;

  /// Streak seviyesi (aura rengi için)
  StreakLevel get streakLevel {
    if (_currentStreak >= 10) return StreakLevel.gold;
    if (_currentStreak >= 5) return StreakLevel.purple;
    if (_currentStreak >= 3) return StreakLevel.blue;
    return StreakLevel.none;
  }

  /// Verileri yükle
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    _longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    _totalSavedAmount = prefs.getDouble(_keyTotalSavedAmount) ?? 0;
    _totalSavedHours = prefs.getDouble(_keyTotalSavedHours) ?? 0;

    final lastVictoryStr = prefs.getString(_keyLastVictoryDate);
    if (lastVictoryStr != null) {
      _lastVictoryDate = DateTime.parse(lastVictoryStr);
    }

    // Streak aktif mi kontrol et
    checkAndResetStreak();
  }

  /// Verileri kaydet
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyCurrentStreak, _currentStreak);
    await prefs.setInt(_keyLongestStreak, _longestStreak);
    await prefs.setDouble(_keyTotalSavedAmount, _totalSavedAmount);
    await prefs.setDouble(_keyTotalSavedHours, _totalSavedHours);

    if (_lastVictoryDate != null) {
      await prefs.setString(
        _keyLastVictoryDate,
        _lastVictoryDate!.toIso8601String(),
      );
    }
  }

  /// Yeni İrade Zaferi kaydet
  Future<void> recordVictory({
    required double amount,
    required double hours,
  }) async {
    final now = DateTime.now();

    // Aynı gün içinde tekrar zafer varsa streak artmaz, sadece birikim
    if (_lastVictoryDate != null && _isSameDay(_lastVictoryDate!, now)) {
      _totalSavedAmount += amount;
      _totalSavedHours += hours;
      await _save();
      return;
    }

    // Streak kontrolü
    if (isStreakActive()) {
      // Streak devam ediyor
      _currentStreak++;
    } else {
      // Yeni streak başlat
      _currentStreak = 1;
    }

    // En uzun streak güncelle
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }

    // Birikimler
    _totalSavedAmount += amount;
    _totalSavedHours += hours;

    // Tarih güncelle
    _lastVictoryDate = now;

    await _save();
  }

  /// Streak aktif mi? (Son 48 saat içinde zafer var mı?)
  bool isStreakActive() {
    if (_lastVictoryDate == null) return false;

    final now = DateTime.now();
    final difference = now.difference(_lastVictoryDate!);

    // 48 saat içindeyse aktif (1 gün atlama hakkı)
    return difference.inHours < 48;
  }

  /// Streak sıfırlama kontrolü
  void checkAndResetStreak() {
    if (!isStreakActive() && _currentStreak > 0) {
      _currentStreak = 0;
      _save();
    }
  }

  /// Aynı gün mü?
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Toplam özgürleşilen süreyi formatla
  String get formattedTotalTime {
    final hours = _totalSavedHours;

    if (hours >= 24) {
      final days = (hours / 24).floor();
      final remainingHours = (hours % 24).round();
      if (remainingHours > 0) {
        return '$days Gün $remainingHours Saat';
      }
      return '$days Gün';
    } else if (hours >= 1) {
      return '${hours.round()} Saat';
    } else {
      return '${(hours * 60).round()} Dakika';
    }
  }

  /// Toplam tasarrufu formatla
  String get formattedTotalAmount {
    if (_totalSavedAmount >= 1000000) {
      return '${(_totalSavedAmount / 1000000).toStringAsFixed(1)}M ₺';
    } else if (_totalSavedAmount >= 1000) {
      return '${(_totalSavedAmount / 1000).toStringAsFixed(1)}K ₺';
    }
    return '${_totalSavedAmount.toStringAsFixed(0)} ₺';
  }

  /// Streak'i sıfırla (test için)
  Future<void> reset() async {
    _currentStreak = 0;
    _longestStreak = 0;
    _lastVictoryDate = null;
    _totalSavedAmount = 0;
    _totalSavedHours = 0;
    await _save();
  }
}

/// Streak seviyesi (aura rengi için)
enum StreakLevel {
  none, // 0-2 streak
  blue, // 3-4 streak
  purple, // 5-9 streak
  gold; // 10+ streak

  Color get auraColor {
    switch (this) {
      case StreakLevel.none:
        return const Color(0x00000000); // Transparent
      case StreakLevel.blue:
        return AppColors.categoryEntertainment; // Blue
      case StreakLevel.purple:
        return AppColors.categoryShopping; // Purple
      case StreakLevel.gold:
        return AppColors.medalGold; // Gold
    }
  }

  double get auraOpacity {
    switch (this) {
      case StreakLevel.none:
        return 0.0;
      case StreakLevel.blue:
        return 0.25;
      case StreakLevel.purple:
        return 0.3;
      case StreakLevel.gold:
        return 0.4;
    }
  }
}

/// Global erişim için kısayol
final streakManager = StreakManager();
