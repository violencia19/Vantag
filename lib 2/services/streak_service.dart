import 'package:shared_preferences/shared_preferences.dart';

/// Streak milestone rewards
class StreakReward {
  final int milestone;
  final int proDaysGranted;
  final String title;
  final String description;

  const StreakReward({
    required this.milestone,
    required this.proDaysGranted,
    required this.title,
    required this.description,
  });

  static const rewards = [
    StreakReward(
      milestone: 7,
      proDaysGranted: 1,
      title: '7 Gün Serisi!',
      description: '1 gün ücretsiz Pro kazandın!',
    ),
    StreakReward(
      milestone: 30,
      proDaysGranted: 3,
      title: '30 Gün Serisi!',
      description: '3 gün ücretsiz Pro kazandın!',
    ),
    StreakReward(
      milestone: 100,
      proDaysGranted: 7,
      title: '100 Gün Serisi!',
      description: '7 gün ücretsiz Pro kazandın!',
    ),
  ];

  static StreakReward? getRewardForMilestone(int streak) {
    return rewards.where((r) => r.milestone == streak).firstOrNull;
  }
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastEntryDate;
  final bool isStale; // Streak kırılmış mı?
  final StreakReward? unclaimedReward; // Henüz alınmamış ödül

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastEntryDate,
    this.isStale = false,
    this.unclaimedReward,
  });

  bool get hasStreak => displayStreak > 0;
  bool get isNewRecord =>
      !isStale && currentStreak > 0 && currentStreak >= longestStreak;

  /// Gösterilecek streak değeri (kırılmışsa 0)
  int get displayStreak => isStale ? 0 : currentStreak;

  /// Streak risk altında mı? (Son 4 saat içinde bozulabilir)
  bool get isAtRisk {
    if (lastEntryDate == null || currentStreak == 0) return false;
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final hoursUntilMidnight = endOfDay.difference(now).inHours;
    return hoursUntilMidnight <= 4 && !_isToday(lastEntryDate!);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
}

class StreakService {
  static const _keyCurrentStreak = 'streak_current';
  static const _keyLongestStreak = 'streak_longest';
  static const _keyLastEntryDate = 'streak_last_entry';
  static const _keyClaimedRewards = 'streak_claimed_rewards';

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
    await prefs.remove(_keyClaimedRewards);
  }

  /// Check for unclaimed streak rewards
  Future<StreakReward?> checkForUnclaimedReward() async {
    final prefs = await SharedPreferences.getInstance();
    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final claimedRewards = prefs.getStringList(_keyClaimedRewards) ?? [];

    for (final reward in StreakReward.rewards) {
      if (currentStreak >= reward.milestone &&
          !claimedRewards.contains('${reward.milestone}')) {
        return reward;
      }
    }
    return null;
  }

  /// Claim a streak reward and return Pro days granted
  Future<int> claimReward(StreakReward reward) async {
    final prefs = await SharedPreferences.getInstance();
    final claimedRewards = prefs.getStringList(_keyClaimedRewards) ?? [];

    if (claimedRewards.contains('${reward.milestone}')) {
      return 0; // Already claimed
    }

    claimedRewards.add('${reward.milestone}');
    await prefs.setStringList(_keyClaimedRewards, claimedRewards);

    return reward.proDaysGranted;
  }

  /// Get list of claimed reward milestones
  Future<List<int>> getClaimedRewardMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final claimedRewards = prefs.getStringList(_keyClaimedRewards) ?? [];
    return claimedRewards.map((s) => int.parse(s)).toList();
  }

  /// Get next milestone for current streak
  Future<({int milestone, int daysRemaining})?> getNextMilestone() async {
    final prefs = await SharedPreferences.getInstance();
    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;

    for (final reward in StreakReward.rewards) {
      if (currentStreak < reward.milestone) {
        return (
          milestone: reward.milestone,
          daysRemaining: reward.milestone - currentStreak,
        );
      }
    }
    return null;
  }
}
