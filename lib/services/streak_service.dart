import 'package:shared_preferences/shared_preferences.dart';

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastEntryDate;
  final bool isStale; // Streak kırılmış mı?

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastEntryDate,
    this.isStale = false,
  });

  bool get hasStreak => displayStreak > 0;
  bool get isNewRecord => !isStale && currentStreak > 0 && currentStreak >= longestStreak;

  /// Gösterilecek streak değeri (kırılmışsa 0)
  int get displayStreak => isStale ? 0 : currentStreak;
}

class StreakService {
  static const _keyCurrentStreak = 'streak_current';
  static const _keyLongestStreak = 'streak_longest';
  static const _keyLastEntryDate = 'streak_last_entry';

  /// Streak verilerini getirir (SADECE OKUMA - side effect yok)
  Future<StreakData> getStreakData() async {
    final prefs = await SharedPreferences.getInstance();

    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    final lastEntryStr = prefs.getString(_keyLastEntryDate);

    DateTime? lastEntryDate;
    if (lastEntryStr != null) {
      lastEntryDate = DateTime.tryParse(lastEntryStr);
    }

    // Streak kırılmış mı kontrol et (ama VERİYİ DEĞİŞTİRME)
    bool isStale = false;
    if (lastEntryDate != null && currentStreak > 0) {
      final daysDiff = _daysDifference(lastEntryDate, DateTime.now());
      if (daysDiff > 1) {
        // Streak kırılmış, ama burada sadece işaretle
        isStale = true;
      }
    }

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastEntryDate: lastEntryDate,
      isStale: isStale,
    );
  }

  /// Harcama girişinde streak'i günceller
  Future<StreakData> recordEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastEntryStr = prefs.getString(_keyLastEntryDate);
    DateTime? lastEntryDate;
    if (lastEntryStr != null) {
      lastEntryDate = DateTime.tryParse(lastEntryStr);
    }

    int currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    int longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;

    if (lastEntryDate == null) {
      // İlk giriş
      currentStreak = 1;
    } else {
      final lastDate = DateTime(
        lastEntryDate.year,
        lastEntryDate.month,
        lastEntryDate.day,
      );
      final daysDiff = _daysDifference(lastDate, today);

      if (daysDiff == 0) {
        // Bugün zaten giriş yapılmış, streak değişmez
        return StreakData(
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          lastEntryDate: lastEntryDate,
        );
      } else if (daysDiff == 1) {
        // Dün giriş yapılmış, streak artır
        currentStreak++;
      } else {
        // Gün atlanmış, streak sıfırla ve yeniden başla
        currentStreak = 1;
      }
    }

    // En uzun streak'i güncelle
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
      await prefs.setInt(_keyLongestStreak, longestStreak);
    }

    // Kaydet
    await prefs.setInt(_keyCurrentStreak, currentStreak);
    await prefs.setString(_keyLastEntryDate, today.toIso8601String());

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastEntryDate: today,
    );
  }

  /// Kırılmış streak'i temizle (explicit çağrı gerekir)
  Future<void> cleanupStaleStreak() async {
    final data = await getStreakData();
    if (data.isStale) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCurrentStreak, 0);
      await prefs.remove(_keyLastEntryDate);
    }
  }

  /// İki tarih arasındaki gün farkını hesaplar
  int _daysDifference(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }

  /// Streak'i tamamen sıfırlar (test için)
  Future<void> resetAllStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentStreak);
    await prefs.remove(_keyLongestStreak);
    await prefs.remove(_keyLastEntryDate);
  }
}
