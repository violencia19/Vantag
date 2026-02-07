import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/services/analytics_service.dart';

/// Email trigger service for backend integration
/// This service logs analytics events that the backend uses to trigger emails
class EmailTriggerService {
  static final EmailTriggerService _instance = EmailTriggerService._internal();
  factory EmailTriggerService() => _instance;
  EmailTriggerService._internal();

  // Pref keys
  static const String _keyOnboardingEmailsSent = 'email_onboarding_sent';
  static const String _keyLastEmailTrigger = 'email_last_trigger';

  // ===========================================
  // ONBOARDING EMAIL TRIGGERS
  // ===========================================

  /// Trigger welcome email on user registration
  Future<void> triggerWelcomeEmail({required String userId}) async {
    await AnalyticsService().logEvent(
      'trigger_email',
      parameters: {
        'email_type': 'welcome',
        'sequence': 'onboarding',
        'user_id': userId,
      },
    );
  }

  /// Trigger onboarding sequence based on day
  Future<void> triggerOnboardingEmail({
    required int dayNumber,
    required String userId,
    required int expenseCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sentEmails = prefs.getStringList(_keyOnboardingEmailsSent) ?? [];

    final emailKey = 'onboarding_day$dayNumber';

    // Don't send if already sent
    if (sentEmails.contains(emailKey)) return;

    // Condition checks based on day
    bool shouldSend = false;
    String emailType = '';

    switch (dayNumber) {
      case 1:
        shouldSend = expenseCount < 1;
        emailType = 'quick_win';
        break;
      case 3:
        shouldSend = expenseCount < 3;
        emailType = 'value_reminder';
        break;
      case 7:
        shouldSend = true; // Always send feature discovery
        emailType = 'feature_discovery';
        break;
      case 14:
        shouldSend = true;
        emailType = 'streak_motivation';
        break;
    }

    if (!shouldSend) return;

    await AnalyticsService().logEvent(
      'trigger_email',
      parameters: {
        'email_type': emailType,
        'sequence': 'onboarding',
        'day_number': dayNumber,
        'user_id': userId,
        'expense_count': expenseCount,
      },
    );

    // Mark as sent
    sentEmails.add(emailKey);
    await prefs.setStringList(_keyOnboardingEmailsSent, sentEmails);
  }

  // ===========================================
  // RE-ENGAGEMENT EMAIL TRIGGERS
  // ===========================================

  /// Trigger re-engagement email based on inactivity
  Future<void> triggerReengagementEmail({
    required int daysInactive,
    required String userId,
    bool hadStreak = false,
  }) async {
    String emailType;

    if (daysInactive >= 30) {
      emailType = 'final_attempt';
    } else if (daysInactive >= 14) {
      emailType = 'win_back';
    } else if (daysInactive >= 7) {
      emailType = 'value_recap';
    } else if (daysInactive >= 5 && hadStreak) {
      emailType = 'streak_warning';
    } else if (daysInactive >= 3) {
      emailType = 'miss_you';
    } else {
      return; // Not inactive enough
    }

    await AnalyticsService().logEvent(
      'trigger_email',
      parameters: {
        'email_type': emailType,
        'sequence': 'reengagement',
        'days_inactive': daysInactive,
        'user_id': userId,
        'had_streak': hadStreak,
      },
    );

    await _recordEmailTrigger(emailType);
  }

  // ===========================================
  // MILESTONE EMAIL TRIGGERS
  // ===========================================

  /// Trigger milestone celebration email
  Future<void> triggerMilestoneEmail({
    required String milestoneType,
    required String userId,
    Map<String, dynamic>? extraData,
  }) async {
    await AnalyticsService().logEvent(
      'trigger_email',
      parameters: {
        'email_type': 'milestone_$milestoneType',
        'sequence': 'milestone',
        'milestone_type': milestoneType,
        'user_id': userId,
        ...?extraData,
      },
    );
  }

  /// Trigger streak milestone email
  Future<void> triggerStreakMilestoneEmail({
    required int streakDays,
    required String userId,
  }) async {
    // Only trigger for specific milestones
    final milestones = [7, 14, 30, 60, 100, 365];
    if (!milestones.contains(streakDays)) return;

    await triggerMilestoneEmail(
      milestoneType: 'streak_$streakDays',
      userId: userId,
      extraData: {'streak_days': streakDays},
    );
  }

  /// Trigger savings milestone email
  Future<void> triggerSavingsMilestoneEmail({
    required double totalSaved,
    required String userId,
    required String currencySymbol,
  }) async {
    // Check for milestones
    final milestones = [1000, 5000, 10000, 50000, 100000];

    for (final milestone in milestones) {
      if (totalSaved >= milestone && totalSaved < milestone * 1.1) {
        await triggerMilestoneEmail(
          milestoneType: 'saved_$milestone',
          userId: userId,
          extraData: {
            'amount': totalSaved,
            'currency': currencySymbol,
          },
        );
        break;
      }
    }
  }

  // ===========================================
  // SUBSCRIPTION EMAIL TRIGGERS
  // ===========================================

  /// Trigger trial ending email
  Future<void> triggerTrialEndingEmail({
    required String userId,
    required int daysRemaining,
  }) async {
    if (daysRemaining > 3) return;

    await AnalyticsService().logEvent(
      'trigger_email',
      parameters: {
        'email_type': 'trial_ending',
        'sequence': 'subscription',
        'user_id': userId,
        'days_remaining': daysRemaining,
      },
    );
  }

  /// Trigger subscription confirmed email
  Future<void> triggerSubscriptionConfirmedEmail({
    required String userId,
    required String planType,
  }) async {
    await AnalyticsService().logEvent(
      'trigger_email',
      parameters: {
        'email_type': 'subscription_confirmed',
        'sequence': 'subscription',
        'user_id': userId,
        'plan_type': planType,
      },
    );
  }

  /// Trigger subscription cancelled email
  Future<void> triggerSubscriptionCancelledEmail({
    required String userId,
  }) async {
    await AnalyticsService().logEvent(
      'trigger_email',
      parameters: {
        'email_type': 'subscription_cancelled',
        'sequence': 'subscription',
        'user_id': userId,
      },
    );
  }

  /// Trigger win-back email for expired subscriptions
  Future<void> triggerSubscriptionWinBackEmail({
    required String userId,
    required int daysSinceExpiry,
  }) async {
    if (daysSinceExpiry < 7) return;

    await AnalyticsService().logEvent(
      'trigger_email',
      parameters: {
        'email_type': 'subscription_winback',
        'sequence': 'subscription',
        'user_id': userId,
        'days_since_expiry': daysSinceExpiry,
      },
    );
  }

  // ===========================================
  // WEEKLY DIGEST TRIGGER
  // ===========================================

  /// Trigger weekly digest email
  Future<void> triggerWeeklyDigestEmail({
    required String userId,
    required double weeklyTotal,
    required double weeklyHours,
    required double? previousWeekTotal,
    required String currencySymbol,
  }) async {
    await AnalyticsService().logEvent(
      'trigger_email',
      parameters: {
        'email_type': 'weekly_digest',
        'sequence': 'digest',
        'user_id': userId,
        'weekly_total': weeklyTotal,
        'weekly_hours': weeklyHours,
        'previous_week_total': previousWeekTotal ?? 0,
        'currency': currencySymbol,
      },
    );
  }

  // ===========================================
  // EMAIL CTA TRACKING
  // ===========================================

  /// Track when user clicks email CTA (deep link opened)
  Future<void> trackEmailCtaClicked({
    required String emailType,
    required String ctaAction,
  }) async {
    await AnalyticsService().logEvent(
      'email_cta_clicked',
      parameters: {
        'email_type': emailType,
        'cta_action': ctaAction,
      },
    );
  }

  // ===========================================
  // HELPER METHODS
  // ===========================================

  Future<void> _recordEmailTrigger(String emailType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyLastEmailTrigger,
      '${emailType}_${DateTime.now().toIso8601String()}',
    );
  }

  /// Check if enough time has passed since last email trigger
  Future<bool> canTriggerEmail({
    Duration minimumInterval = const Duration(hours: 24),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final lastTrigger = prefs.getString(_keyLastEmailTrigger);

    if (lastTrigger == null) return true;

    final parts = lastTrigger.split('_');
    if (parts.length < 2) return true;

    final timestamp = DateTime.tryParse(parts.last);
    if (timestamp == null) return true;

    return DateTime.now().difference(timestamp) >= minimumInterval;
  }

  /// Clear onboarding email tracking (for testing)
  Future<void> resetOnboardingEmails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingEmailsSent);
  }
}
