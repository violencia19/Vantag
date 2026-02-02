import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';
import 'notification_service.dart';

/// Engagement milestones for celebrations
enum EngagementMilestone {
  // Streak milestones
  streak3Days,
  streak7Days,
  streak14Days,
  streak30Days,
  streak60Days,
  streak100Days,

  // Savings milestones
  firstSaved,
  saved100,
  saved500,
  saved1000,
  saved5000,
  saved10000,

  // Usage milestones
  firstExpense,
  tenExpenses,
  fiftyExpenses,
  hundredExpenses,

  // Pursuit milestones
  firstPursuit,
  firstPursuitCompleted,
  threePursuitsCompleted,

  // Feature discovery
  usedAiChat,
  usedVoiceInput,
  usedReceiptScanner,
  sharedCard,
}

/// Celebration data for showing to user
class CelebrationData {
  final EngagementMilestone milestone;
  final String titleKey;
  final String messageKey;
  final String emoji;
  final int? rewardDays; // Pro days reward (if any)

  const CelebrationData({
    required this.milestone,
    required this.titleKey,
    required this.messageKey,
    required this.emoji,
    this.rewardDays,
  });
}

/// Engagement service for tracking user progress and triggering celebrations
/// Handles streaks, milestones, and re-engagement logic
class EngagementService {
  static final EngagementService _instance = EngagementService._internal();
  factory EngagementService() => _instance;
  EngagementService._internal();

  // Keys for SharedPreferences
  static const String _keyLastActiveDate = 'engagement_last_active';
  static const String _keyCurrentStreak = 'engagement_current_streak';
  static const String _keyLongestStreak = 'engagement_longest_streak';
  static const String _keyCompletedMilestones = 'engagement_completed_milestones';
  static const String _keyPendingCelebration = 'engagement_pending_celebration';

  // Milestone configurations
  static const Map<EngagementMilestone, CelebrationData> _milestoneData = {
    // Streak milestones
    EngagementMilestone.streak3Days: CelebrationData(
      milestone: EngagementMilestone.streak3Days,
      titleKey: 'milestone3DayStreakTitle',
      messageKey: 'milestone3DayStreakMessage',
      emoji: '🔥',
    ),
    EngagementMilestone.streak7Days: CelebrationData(
      milestone: EngagementMilestone.streak7Days,
      titleKey: 'milestone7DayStreakTitle',
      messageKey: 'milestone7DayStreakMessage',
      emoji: '🌟',
      rewardDays: 1,
    ),
    EngagementMilestone.streak14Days: CelebrationData(
      milestone: EngagementMilestone.streak14Days,
      titleKey: 'milestone14DayStreakTitle',
      messageKey: 'milestone14DayStreakMessage',
      emoji: '💪',
      rewardDays: 2,
    ),
    EngagementMilestone.streak30Days: CelebrationData(
      milestone: EngagementMilestone.streak30Days,
      titleKey: 'milestone30DayStreakTitle',
      messageKey: 'milestone30DayStreakMessage',
      emoji: '🏆',
      rewardDays: 7,
    ),
    EngagementMilestone.streak60Days: CelebrationData(
      milestone: EngagementMilestone.streak60Days,
      titleKey: 'milestone60DayStreakTitle',
      messageKey: 'milestone60DayStreakMessage',
      emoji: '👑',
      rewardDays: 14,
    ),
    EngagementMilestone.streak100Days: CelebrationData(
      milestone: EngagementMilestone.streak100Days,
      titleKey: 'milestone100DayStreakTitle',
      messageKey: 'milestone100DayStreakMessage',
      emoji: '🎖️',
      rewardDays: 30,
    ),

    // Savings milestones
    EngagementMilestone.firstSaved: CelebrationData(
      milestone: EngagementMilestone.firstSaved,
      titleKey: 'milestoneFirstSavedTitle',
      messageKey: 'milestoneFirstSavedMessage',
      emoji: '💰',
    ),
    EngagementMilestone.saved100: CelebrationData(
      milestone: EngagementMilestone.saved100,
      titleKey: 'milestoneSaved100Title',
      messageKey: 'milestoneSaved100Message',
      emoji: '💵',
    ),
    EngagementMilestone.saved1000: CelebrationData(
      milestone: EngagementMilestone.saved1000,
      titleKey: 'milestoneSaved1000Title',
      messageKey: 'milestoneSaved1000Message',
      emoji: '🤑',
    ),
    EngagementMilestone.saved5000: CelebrationData(
      milestone: EngagementMilestone.saved5000,
      titleKey: 'milestoneSaved5000Title',
      messageKey: 'milestoneSaved5000Message',
      emoji: '💎',
    ),

    // Usage milestones
    EngagementMilestone.firstExpense: CelebrationData(
      milestone: EngagementMilestone.firstExpense,
      titleKey: 'milestoneFirstExpenseTitle',
      messageKey: 'milestoneFirstExpenseMessage',
      emoji: '🎉',
    ),
    EngagementMilestone.tenExpenses: CelebrationData(
      milestone: EngagementMilestone.tenExpenses,
      titleKey: 'milestone10ExpensesTitle',
      messageKey: 'milestone10ExpensesMessage',
      emoji: '📊',
    ),
    EngagementMilestone.fiftyExpenses: CelebrationData(
      milestone: EngagementMilestone.fiftyExpenses,
      titleKey: 'milestone50ExpensesTitle',
      messageKey: 'milestone50ExpensesMessage',
      emoji: '🚀',
    ),

    // Pursuit milestones
    EngagementMilestone.firstPursuit: CelebrationData(
      milestone: EngagementMilestone.firstPursuit,
      titleKey: 'milestoneFirstPursuitTitle',
      messageKey: 'milestoneFirstPursuitMessage',
      emoji: '🎯',
    ),
    EngagementMilestone.firstPursuitCompleted: CelebrationData(
      milestone: EngagementMilestone.firstPursuitCompleted,
      titleKey: 'milestoneFirstPursuitCompletedTitle',
      messageKey: 'milestoneFirstPursuitCompletedMessage',
      emoji: '🏅',
    ),

    // Feature discovery
    EngagementMilestone.usedAiChat: CelebrationData(
      milestone: EngagementMilestone.usedAiChat,
      titleKey: 'milestoneUsedAiChatTitle',
      messageKey: 'milestoneUsedAiChatMessage',
      emoji: '🤖',
    ),
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // STREAK TRACKING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Record user activity for today (call when user adds expense)
  Future<StreakResult> recordActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastActiveStr = prefs.getString(_keyLastActiveDate);
    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;

    int newStreak = currentStreak;
    bool streakIncreased = false;
    EngagementMilestone? newMilestone;

    if (lastActiveStr == null) {
      // First activity ever
      newStreak = 1;
      streakIncreased = true;
    } else {
      final lastActive = DateTime.parse(lastActiveStr);
      final lastActiveDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
      final difference = today.difference(lastActiveDay).inDays;

      if (difference == 0) {
        // Already active today, no change
        streakIncreased = false;
      } else if (difference == 1) {
        // Consecutive day, increase streak
        newStreak = currentStreak + 1;
        streakIncreased = true;
      } else {
        // Streak broken, reset to 1
        newStreak = 1;
        streakIncreased = true;
      }
    }

    // Update storage
    await prefs.setString(_keyLastActiveDate, today.toIso8601String());
    await prefs.setInt(_keyCurrentStreak, newStreak);

    // Update longest streak if needed
    if (newStreak > longestStreak) {
      await prefs.setInt(_keyLongestStreak, newStreak);
    }

    // Check for streak milestones
    if (streakIncreased) {
      newMilestone = await _checkStreakMilestones(newStreak);
    }

    debugPrint('[Engagement] Streak: $newStreak days (increased: $streakIncreased)');

    return StreakResult(
      currentStreak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      streakIncreased: streakIncreased,
      newMilestone: newMilestone,
    );
  }

  /// Get current streak info
  Future<StreakInfo> getStreakInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastActiveStr = prefs.getString(_keyLastActiveDate);
    var currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;

    bool isActiveToday = false;
    bool streakAtRisk = false;

    if (lastActiveStr != null) {
      final lastActive = DateTime.parse(lastActiveStr);
      final lastActiveDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
      final difference = today.difference(lastActiveDay).inDays;

      isActiveToday = difference == 0;

      if (difference == 1) {
        // User hasn't been active today but was yesterday
        streakAtRisk = true;
      } else if (difference > 1) {
        // Streak already broken
        currentStreak = 0;
      }
    }

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      isActiveToday: isActiveToday,
      streakAtRisk: streakAtRisk,
    );
  }

  Future<EngagementMilestone?> _checkStreakMilestones(int streak) async {
    EngagementMilestone? milestone;

    switch (streak) {
      case 3:
        milestone = EngagementMilestone.streak3Days;
        break;
      case 7:
        milestone = EngagementMilestone.streak7Days;
        break;
      case 14:
        milestone = EngagementMilestone.streak14Days;
        break;
      case 30:
        milestone = EngagementMilestone.streak30Days;
        break;
      case 60:
        milestone = EngagementMilestone.streak60Days;
        break;
      case 100:
        milestone = EngagementMilestone.streak100Days;
        break;
    }

    if (milestone != null) {
      await _triggerMilestone(milestone);
    }

    return milestone;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MILESTONE DETECTION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check all milestones based on current stats
  Future<List<EngagementMilestone>> checkMilestones({
    required int totalExpenses,
    required double totalSaved,
    required int totalPursuits,
    required int completedPursuits,
    required bool hasUsedAiChat,
    required bool hasUsedVoiceInput,
    required bool hasSharedCard,
  }) async {
    final newMilestones = <EngagementMilestone>[];

    // Expense milestones
    if (totalExpenses >= 1) {
      if (await _triggerMilestone(EngagementMilestone.firstExpense)) {
        newMilestones.add(EngagementMilestone.firstExpense);
      }
    }
    if (totalExpenses >= 10) {
      if (await _triggerMilestone(EngagementMilestone.tenExpenses)) {
        newMilestones.add(EngagementMilestone.tenExpenses);
      }
    }
    if (totalExpenses >= 50) {
      if (await _triggerMilestone(EngagementMilestone.fiftyExpenses)) {
        newMilestones.add(EngagementMilestone.fiftyExpenses);
      }
    }
    if (totalExpenses >= 100) {
      if (await _triggerMilestone(EngagementMilestone.hundredExpenses)) {
        newMilestones.add(EngagementMilestone.hundredExpenses);
      }
    }

    // Savings milestones
    if (totalSaved > 0) {
      if (await _triggerMilestone(EngagementMilestone.firstSaved)) {
        newMilestones.add(EngagementMilestone.firstSaved);
      }
    }
    if (totalSaved >= 100) {
      if (await _triggerMilestone(EngagementMilestone.saved100)) {
        newMilestones.add(EngagementMilestone.saved100);
      }
    }
    if (totalSaved >= 500) {
      if (await _triggerMilestone(EngagementMilestone.saved500)) {
        newMilestones.add(EngagementMilestone.saved500);
      }
    }
    if (totalSaved >= 1000) {
      if (await _triggerMilestone(EngagementMilestone.saved1000)) {
        newMilestones.add(EngagementMilestone.saved1000);
      }
    }
    if (totalSaved >= 5000) {
      if (await _triggerMilestone(EngagementMilestone.saved5000)) {
        newMilestones.add(EngagementMilestone.saved5000);
      }
    }

    // Pursuit milestones
    if (totalPursuits >= 1) {
      if (await _triggerMilestone(EngagementMilestone.firstPursuit)) {
        newMilestones.add(EngagementMilestone.firstPursuit);
      }
    }
    if (completedPursuits >= 1) {
      if (await _triggerMilestone(EngagementMilestone.firstPursuitCompleted)) {
        newMilestones.add(EngagementMilestone.firstPursuitCompleted);
      }
    }
    if (completedPursuits >= 3) {
      if (await _triggerMilestone(EngagementMilestone.threePursuitsCompleted)) {
        newMilestones.add(EngagementMilestone.threePursuitsCompleted);
      }
    }

    // Feature discovery milestones
    if (hasUsedAiChat) {
      if (await _triggerMilestone(EngagementMilestone.usedAiChat)) {
        newMilestones.add(EngagementMilestone.usedAiChat);
      }
    }
    if (hasUsedVoiceInput) {
      if (await _triggerMilestone(EngagementMilestone.usedVoiceInput)) {
        newMilestones.add(EngagementMilestone.usedVoiceInput);
      }
    }
    if (hasSharedCard) {
      if (await _triggerMilestone(EngagementMilestone.sharedCard)) {
        newMilestones.add(EngagementMilestone.sharedCard);
      }
    }

    return newMilestones;
  }

  /// Trigger a specific milestone (returns true if new, false if already completed)
  Future<bool> _triggerMilestone(EngagementMilestone milestone) async {
    final prefs = await SharedPreferences.getInstance();
    final completedList = prefs.getStringList(_keyCompletedMilestones) ?? [];

    if (completedList.contains(milestone.name)) {
      return false; // Already completed
    }

    // Mark as completed
    completedList.add(milestone.name);
    await prefs.setStringList(_keyCompletedMilestones, completedList);

    // Store as pending celebration
    await prefs.setString(_keyPendingCelebration, milestone.name);

    // Track analytics
    AnalyticsService().logFeatureUsed('milestone_${milestone.name}');

    debugPrint('[Engagement] New milestone: ${milestone.name}');

    return true;
  }

  /// Get celebration data for a milestone
  CelebrationData? getCelebrationData(EngagementMilestone milestone) {
    return _milestoneData[milestone];
  }

  /// Get pending celebration (if any)
  Future<CelebrationData?> getPendingCelebration() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingName = prefs.getString(_keyPendingCelebration);

    if (pendingName == null) return null;

    try {
      final milestone = EngagementMilestone.values.firstWhere(
        (m) => m.name == pendingName,
      );
      return _milestoneData[milestone];
    } catch (e) {
      return null;
    }
  }

  /// Clear pending celebration after showing
  Future<void> clearPendingCelebration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPendingCelebration);
  }

  /// Check if a milestone has been completed
  Future<bool> isMilestoneCompleted(EngagementMilestone milestone) async {
    final prefs = await SharedPreferences.getInstance();
    final completedList = prefs.getStringList(_keyCompletedMilestones) ?? [];
    return completedList.contains(milestone.name);
  }

  /// Get all completed milestones
  Future<List<EngagementMilestone>> getCompletedMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final completedList = prefs.getStringList(_keyCompletedMilestones) ?? [];

    return completedList.map((name) {
      try {
        return EngagementMilestone.values.firstWhere((m) => m.name == name);
      } catch (e) {
        return null;
      }
    }).whereType<EngagementMilestone>().toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RE-ENGAGEMENT LOGIC
  // ═══════════════════════════════════════════════════════════════════════════

  /// Schedule streak risk notification
  Future<void> scheduleStreakRiskAlert() async {
    final streakInfo = await getStreakInfo();

    if (streakInfo.streakAtRisk && streakInfo.currentStreak >= 3) {
      await NotificationService().scheduleStreakRiskAlert(
        currentStreak: streakInfo.currentStreak,
      );
    }
  }

  /// Get days since last activity
  Future<int> getDaysSinceLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveStr = prefs.getString(_keyLastActiveDate);

    if (lastActiveStr == null) return -1;

    final lastActive = DateTime.parse(lastActiveStr);
    final now = DateTime.now();
    return now.difference(lastActive).inDays;
  }

  /// Check if user is considered "stalled"
  Future<bool> isUserStalled({int threshold = 3}) async {
    final daysSince = await getDaysSinceLastActivity();
    return daysSince >= threshold;
  }
}

/// Result of recording activity
class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final bool streakIncreased;
  final EngagementMilestone? newMilestone;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakIncreased,
    this.newMilestone,
  });
}

/// Current streak information
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final bool isActiveToday;
  final bool streakAtRisk;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.isActiveToday,
    required this.streakAtRisk,
  });
}
