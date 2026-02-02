import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:vantag/services/analytics_service.dart';
import 'package:vantag/services/push_notification_service.dart';

/// Re-engagement service for stalled users
/// Detects inactive users and triggers recovery mechanisms
class ReengagementService {
  static final ReengagementService _instance = ReengagementService._internal();
  factory ReengagementService() => _instance;
  ReengagementService._internal();

  // Storage keys
  static const String _keyLastActiveDate = 'reengagement_last_active';
  static const String _keyLastReengagementShown = 'reengagement_last_shown';
  static const String _keyReengagementCount = 'reengagement_count';
  static const String _keyWelcomeBackShown = 'reengagement_welcome_back_shown';
  static const String _keyLastPushScheduled = 'reengagement_last_push';

  // Thresholds (in days)
  static const int stalledThresholdDays = 3;
  static const int warningThresholdDays = 2;
  static const int criticalThresholdDays = 7;
  static const int dormantThresholdDays = 14;
  static const int churningThresholdDays = 30;

  /// User activity state
  UserActivityState _cachedState = UserActivityState.active;

  /// Record user activity (call on app open, expense add, etc.)
  Future<void> recordActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastActiveDate, DateTime.now().toIso8601String());
    await prefs.setBool(_keyWelcomeBackShown, false);
    _cachedState = UserActivityState.active;
  }

  /// Get last active date
  Future<DateTime?> getLastActiveDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyLastActiveDate);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  /// Get days since last activity
  Future<int> getDaysSinceLastActivity() async {
    final lastActive = await getLastActiveDate();
    if (lastActive == null) return 0;
    return DateTime.now().difference(lastActive).inDays;
  }

  /// Check if user is stalled
  Future<bool> isUserStalled({int? customThreshold}) async {
    final days = await getDaysSinceLastActivity();
    return days >= (customThreshold ?? stalledThresholdDays);
  }

  /// Get user activity state
  Future<UserActivityState> getUserActivityState() async {
    final days = await getDaysSinceLastActivity();

    if (days == 0) {
      _cachedState = UserActivityState.active;
    } else if (days < warningThresholdDays) {
      _cachedState = UserActivityState.active;
    } else if (days < stalledThresholdDays) {
      _cachedState = UserActivityState.warning;
    } else if (days < criticalThresholdDays) {
      _cachedState = UserActivityState.stalled;
    } else if (days < dormantThresholdDays) {
      _cachedState = UserActivityState.critical;
    } else if (days < churningThresholdDays) {
      _cachedState = UserActivityState.dormant;
    } else {
      _cachedState = UserActivityState.churning;
    }

    return _cachedState;
  }

  /// Check if stalled and trigger appropriate actions
  Future<ReengagementResult> checkAndTriggerReengagement() async {
    final days = await getDaysSinceLastActivity();
    final state = await getUserActivityState();

    if (state == UserActivityState.active) {
      return ReengagementResult(
        state: state,
        daysSinceActive: days,
        actionTaken: ReengagementAction.none,
      );
    }

    // Log analytics
    await AnalyticsService().logEvent(
      'user_inactive',
      parameters: {
        'days_inactive': days,
        'state': state.name,
      },
    );

    // Determine action based on state
    ReengagementAction action = ReengagementAction.none;

    switch (state) {
      case UserActivityState.warning:
        // Just track, no action yet
        action = ReengagementAction.tracked;
        break;

      case UserActivityState.stalled:
        // Schedule re-engagement push
        await _scheduleReengagementPush(days);
        action = ReengagementAction.pushScheduled;
        break;

      case UserActivityState.critical:
        // More urgent push + email trigger
        await _scheduleUrgentPush(days);
        await _triggerEmailReengagement(days);
        action = ReengagementAction.urgentOutreach;
        break;

      case UserActivityState.dormant:
        // Win-back campaign
        await _triggerWinBackCampaign(days);
        action = ReengagementAction.winBackCampaign;
        break;

      case UserActivityState.churning:
        // Final attempt
        await _triggerFinalAttempt(days);
        action = ReengagementAction.finalAttempt;
        break;

      case UserActivityState.active:
        break;
    }

    return ReengagementResult(
      state: state,
      daysSinceActive: days,
      actionTaken: action,
    );
  }

  /// Schedule re-engagement push notification
  Future<void> _scheduleReengagementPush(int daysSinceActive) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we already scheduled recently
    final lastPush = prefs.getString(_keyLastPushScheduled);
    if (lastPush != null) {
      final lastPushDate = DateTime.tryParse(lastPush);
      if (lastPushDate != null) {
        final hoursSincePush = DateTime.now().difference(lastPushDate).inHours;
        if (hoursSincePush < 24) return; // Don't spam
      }
    }

    // Schedule push notification
    await PushNotificationService().scheduleReengagementNotification(
      daysSinceActive: daysSinceActive,
    );

    await prefs.setString(_keyLastPushScheduled, DateTime.now().toIso8601String());

    await AnalyticsService().logEvent(
      'reengagement_push_scheduled',
      parameters: {'days_inactive': daysSinceActive},
    );
  }

  /// Schedule urgent push for critical users
  Future<void> _scheduleUrgentPush(int daysSinceActive) async {
    await PushNotificationService().scheduleUrgentReengagementNotification(
      daysSinceActive: daysSinceActive,
    );

    await AnalyticsService().logEvent(
      'urgent_reengagement_push',
      parameters: {'days_inactive': daysSinceActive},
    );
  }

  /// Trigger email re-engagement (logs event for backend to handle)
  Future<void> _triggerEmailReengagement(int daysSinceActive) async {
    await AnalyticsService().logEvent(
      'trigger_reengagement_email',
      parameters: {
        'days_inactive': daysSinceActive,
        'email_type': 'miss_you',
      },
    );
  }

  /// Trigger win-back campaign
  Future<void> _triggerWinBackCampaign(int daysSinceActive) async {
    await AnalyticsService().logEvent(
      'trigger_win_back_campaign',
      parameters: {
        'days_inactive': daysSinceActive,
        'campaign_type': 'dormant_user',
      },
    );
  }

  /// Final attempt for churning users
  Future<void> _triggerFinalAttempt(int daysSinceActive) async {
    await AnalyticsService().logEvent(
      'trigger_final_attempt',
      parameters: {
        'days_inactive': daysSinceActive,
        'campaign_type': 'churn_prevention',
      },
    );
  }

  /// Check if welcome back should be shown
  Future<bool> shouldShowWelcomeBack() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(_keyWelcomeBackShown) ?? false;
    if (alreadyShown) return false;

    final days = await getDaysSinceLastActivity();
    return days >= stalledThresholdDays;
  }

  /// Mark welcome back as shown
  Future<void> markWelcomeBackShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWelcomeBackShown, true);

    final count = prefs.getInt(_keyReengagementCount) ?? 0;
    await prefs.setInt(_keyReengagementCount, count + 1);

    await AnalyticsService().logEvent(
      'welcome_back_shown',
      parameters: {'reengagement_count': count + 1},
    );
  }

  /// Get welcome back message based on days inactive
  WelcomeBackMessage getWelcomeBackMessage(BuildContext context, int daysSinceActive) {
    final l10n = AppLocalizations.of(context);

    if (daysSinceActive < 7) {
      return WelcomeBackMessage(
        title: l10n.welcomeBackTitle3Days,
        subtitle: l10n.welcomeBackSubtitle3Days,
        ctaText: l10n.welcomeBackCta3Days,
        icon: Icons.wb_sunny_rounded,
        color: const Color(0xFFF59E0B),
      );
    } else if (daysSinceActive < 14) {
      return WelcomeBackMessage(
        title: l10n.welcomeBackTitle7Days,
        subtitle: l10n.welcomeBackSubtitle7Days,
        ctaText: l10n.welcomeBackCta7Days,
        icon: Icons.favorite_rounded,
        color: const Color(0xFFEF4444),
      );
    } else if (daysSinceActive < 30) {
      return WelcomeBackMessage(
        title: l10n.welcomeBackTitle14Days,
        subtitle: l10n.welcomeBackSubtitle14Days,
        ctaText: l10n.welcomeBackCta14Days,
        icon: Icons.rocket_launch_rounded,
        color: const Color(0xFF6C63FF),
      );
    } else {
      return WelcomeBackMessage(
        title: l10n.welcomeBackTitle30Days,
        subtitle: l10n.welcomeBackSubtitle30Days,
        ctaText: l10n.welcomeBackCta30Days,
        icon: Icons.celebration_rounded,
        color: const Color(0xFF10B981),
      );
    }
  }

  /// Get streak recovery bonus (for gamification)
  int getStreakRecoveryBonus(int daysSinceActive) {
    // Shorter absence = higher bonus percentage retained
    if (daysSinceActive <= 3) return 75; // Keep 75% of streak
    if (daysSinceActive <= 7) return 50; // Keep 50%
    if (daysSinceActive <= 14) return 25; // Keep 25%
    return 0; // Streak reset
  }

  /// Clear all re-engagement data (for testing)
  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastActiveDate);
    await prefs.remove(_keyLastReengagementShown);
    await prefs.remove(_keyReengagementCount);
    await prefs.remove(_keyWelcomeBackShown);
    await prefs.remove(_keyLastPushScheduled);
  }
}

/// User activity state enum
enum UserActivityState {
  active,    // 0-1 days
  warning,   // 2 days
  stalled,   // 3-6 days
  critical,  // 7-13 days
  dormant,   // 14-29 days
  churning,  // 30+ days
}

/// Re-engagement action taken
enum ReengagementAction {
  none,
  tracked,
  pushScheduled,
  urgentOutreach,
  winBackCampaign,
  finalAttempt,
}

/// Result of re-engagement check
class ReengagementResult {
  final UserActivityState state;
  final int daysSinceActive;
  final ReengagementAction actionTaken;

  const ReengagementResult({
    required this.state,
    required this.daysSinceActive,
    required this.actionTaken,
  });
}

/// Welcome back message model
class WelcomeBackMessage {
  final String title;
  final String subtitle;
  final String ctaText;
  final IconData icon;
  final Color color;

  const WelcomeBackMessage({
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.icon,
    required this.color,
  });
}
