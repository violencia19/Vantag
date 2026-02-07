import 'package:firebase_analytics/firebase_analytics.dart';
import '../main.dart' show analytics;

/// Analytics Service for tracking user events
/// Provides easy-to-use methods for common tracking scenarios
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics get _analytics => analytics;

  // ─────────────────────────────────────────────────────────────────
  // FEATURE ADOPTION EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Generic feature usage tracking
  Future<void> logFeatureUsed(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {'feature_name': featureName},
    );
  }

  /// Track AI Chat opened/used
  Future<void> logAIChatUsed() async => logFeatureUsed('ai_chat');

  /// Track receipt/OCR scanner used
  Future<void> logReceiptScanned() async => logFeatureUsed('receipt_scanner');

  /// Track Pro feature tapped (conversion funnel)
  Future<void> logProFeatureTapped(String featureName) async {
    await _analytics.logEvent(
      name: 'pro_feature_tapped',
      parameters: {'feature_name': featureName},
    );
  }

  /// Track subscription started (after purchase)
  Future<void> logSubscriptionStarted(String plan) async {
    await _analytics.logEvent(
      name: 'subscription_started',
      parameters: {'plan': plan}, // 'monthly', 'yearly', 'lifetime'
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // EXPENSE EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track when user adds an expense with method info
  Future<void> logExpenseAdded({
    required String method, // 'manual', 'voice', 'ocr'
    double? amount,
    String? category,
    String? decision,
  }) async {
    await _analytics.logEvent(
      name: 'expense_added',
      parameters: {
        'method': method,
        if (amount != null) 'amount': amount,
        if (category != null) 'category': category,
        if (decision != null) 'decision': decision,
      },
    );
  }

  /// Track expense decision (bought/thinking/skipped)
  Future<void> logExpenseDecision({
    required String decision,
    required double amount,
    required String category,
  }) async {
    await _analytics.logEvent(
      name: 'expense_decision',
      parameters: {
        'decision': decision,
        'amount': amount,
        'category': category,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SUBSCRIPTION EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track subscription added
  Future<void> logSubscriptionAdded({
    required String name,
    required double amount,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_added',
      parameters: {'name': name, 'amount': amount},
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // PURSUIT (SAVINGS GOAL) EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track pursuit created (simple)
  Future<void> logPursuitCreatedSimple() async => logFeatureUsed('pursuit_created');

  /// Track pursuit created with details
  Future<void> logPursuitCreated({
    required String category,
    required double targetAmount,
  }) async {
    await _analytics.logEvent(
      name: 'pursuit_created',
      parameters: {'category': category, 'target_amount': targetAmount},
    );
  }

  /// Track savings added to pursuit
  Future<void> logSavingsAdded({
    required double amount,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: 'savings_added',
      parameters: {'amount': amount, 'source': source},
    );
  }

  /// Track pursuit completed
  Future<void> logPursuitCompleted({
    required String pursuitId,
    required double targetAmount,
  }) async {
    await _analytics.logEvent(
      name: 'pursuit_completed',
      parameters: {'pursuit_id': pursuitId, 'target_amount': targetAmount},
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // AI CHAT EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track AI chat message sent
  Future<void> logAIChatMessage({required bool isPremium}) async {
    await _analytics.logEvent(
      name: 'ai_chat_message',
      parameters: {'is_premium': isPremium ? 1 : 0},
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // PREMIUM EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track premium purchase started
  Future<void> logPurchaseStarted({required String productId}) async {
    await _analytics.logEvent(
      name: 'purchase_started',
      parameters: {'product_id': productId},
    );
  }

  /// Track premium purchase completed
  Future<void> logPurchaseCompleted({
    required String productId,
    required double price,
  }) async {
    await _analytics.logPurchase(
      currency: 'TRY',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productId,
          price: price,
        ),
      ],
    );
  }

  /// Track paywall viewed
  Future<void> logPaywallViewed({String? source}) async {
    await _analytics.logEvent(
      name: 'paywall_viewed',
      parameters: {'source': source ?? 'unknown'},
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // NAVIGATION EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track screen view
  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ─────────────────────────────────────────────────────────────────
  // ONBOARDING EVENTS (Legacy)
  // ─────────────────────────────────────────────────────────────────

  /// Track onboarding step completed
  Future<void> logOnboardingStep({required int step}) async {
    await _analytics.logEvent(
      name: 'onboarding_step',
      parameters: {'step': step},
    );
  }

  /// Track onboarding completed
  Future<void> logOnboardingCompleted() async {
    await _analytics.logEvent(name: 'onboarding_completed');
  }

  // ─────────────────────────────────────────────────────────────────
  // ONBOARDING V2 FUNNEL EVENTS (3-Step Value-First Flow)
  // ─────────────────────────────────────────────────────────────────

  /// Track onboarding V2 started
  Future<void> logOnboardingV2Started() async {
    await _analytics.logEvent(name: 'onboarding_v2_started');
  }

  /// Track onboarding V2 step viewed
  Future<void> logOnboardingV2StepViewed({
    required int step,
    required String stepName,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_v2_step_viewed',
      parameters: {
        'step': step,
        'step_name': stepName, // 'value_demo', 'setup', 'first_action'
      },
    );
  }

  /// Track onboarding V2 step completed
  Future<void> logOnboardingV2StepCompleted({
    required int step,
    required String stepName,
    int? timeSpentSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_v2_step_completed',
      parameters: {
        'step': step,
        'step_name': stepName,
        if (timeSpentSeconds != null) 'time_spent_seconds': timeSpentSeconds,
      },
    );
  }

  /// Track onboarding V2 "Aha Moment" - when user sees their first time conversion
  Future<void> logOnboardingAhaMoment({
    required double amount,
    required double hoursRequired,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_aha_moment',
      parameters: {
        'amount': amount,
        'hours_required': hoursRequired,
      },
    );
  }

  /// Track onboarding V2 completed with funnel data
  Future<void> logOnboardingV2Completed({
    required int totalTimeSeconds,
    required bool addedFirstExpense,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_v2_completed',
      parameters: {
        'total_time_seconds': totalTimeSeconds,
        'added_first_expense': addedFirstExpense ? 1 : 0,
      },
    );
  }

  /// Track onboarding V2 skipped (user exits early)
  Future<void> logOnboardingV2Skipped({
    required int lastStepViewed,
    required String skipReason,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_v2_skipped',
      parameters: {
        'last_step_viewed': lastStepViewed,
        'skip_reason': skipReason, // 'back_button', 'skip_button', 'app_closed'
      },
    );
  }

  /// Track profile setup during onboarding
  Future<void> logOnboardingProfileSetup({
    required double monthlyIncome,
    required int workingHours,
    required int workingDays,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_profile_setup',
      parameters: {
        'monthly_income': monthlyIncome,
        'working_hours': workingHours,
        'working_days': workingDays,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ONBOARDING CHECKLIST EVENTS (Main Screen Quick Wins)
  // ─────────────────────────────────────────────────────────────────

  /// Track checklist item viewed
  Future<void> logChecklistViewed({required int completedCount}) async {
    await _analytics.logEvent(
      name: 'checklist_viewed',
      parameters: {'completed_count': completedCount},
    );
  }

  /// Track checklist item completed
  Future<void> logChecklistItemCompleted({
    required String itemName,
    required int itemIndex,
    required int totalCompleted,
  }) async {
    await _analytics.logEvent(
      name: 'checklist_item_completed',
      parameters: {
        'item_name': itemName, // 'add_expense', 'view_report', 'create_pursuit', 'enable_notifications'
        'item_index': itemIndex,
        'total_completed': totalCompleted,
      },
    );
  }

  /// Track checklist completed (all items done)
  Future<void> logChecklistCompleted({required int totalTimeMinutes}) async {
    await _analytics.logEvent(
      name: 'checklist_completed',
      parameters: {'total_time_minutes': totalTimeMinutes},
    );
  }

  /// Track checklist dismissed early
  Future<void> logChecklistDismissed({required int completedCount}) async {
    await _analytics.logEvent(
      name: 'checklist_dismissed',
      parameters: {'completed_count': completedCount},
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ENGAGEMENT & MILESTONE EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track milestone achieved
  Future<void> logMilestoneAchieved({
    required String milestoneName,
    required String milestoneType,
    Map<String, dynamic>? extraData,
  }) async {
    await _analytics.logEvent(
      name: 'milestone_achieved',
      parameters: {
        'milestone_name': milestoneName,
        'milestone_type': milestoneType, // 'streak', 'savings', 'expense_count', 'pursuit', 'feature'
        ...?extraData,
      },
    );
  }

  /// Track celebration shown
  Future<void> logCelebrationShown({
    required String celebrationType,
    required String milestoneName,
  }) async {
    await _analytics.logEvent(
      name: 'celebration_shown',
      parameters: {
        'celebration_type': celebrationType, // 'confetti', 'modal', 'toast'
        'milestone_name': milestoneName,
      },
    );
  }

  /// Track user activity for engagement
  Future<void> logDailyActivity({
    required int currentStreak,
    required int expenseCount,
    required int pursuitCount,
  }) async {
    await _analytics.logEvent(
      name: 'daily_activity',
      parameters: {
        'current_streak': currentStreak,
        'expense_count': expenseCount,
        'pursuit_count': pursuitCount,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // RE-ENGAGEMENT & STALLED USER EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track user inactivity detected
  Future<void> logUserInactive({
    required int daysInactive,
    required String activityState,
  }) async {
    await _analytics.logEvent(
      name: 'user_inactive',
      parameters: {
        'days_inactive': daysInactive,
        'activity_state': activityState, // 'warning', 'stalled', 'critical', 'dormant', 'churning'
      },
    );
  }

  /// Track re-engagement push sent
  Future<void> logReengagementPushSent({
    required int daysInactive,
    required String pushType,
  }) async {
    await _analytics.logEvent(
      name: 'reengagement_push_sent',
      parameters: {
        'days_inactive': daysInactive,
        'push_type': pushType, // 'gentle', 'urgent', 'win_back'
      },
    );
  }

  /// Track welcome back shown
  Future<void> logWelcomeBackShown({
    required int daysInactive,
    required int recoveryPercent,
  }) async {
    await _analytics.logEvent(
      name: 'welcome_back_shown',
      parameters: {
        'days_inactive': daysInactive,
        'recovery_percent': recoveryPercent,
      },
    );
  }

  /// Track user returned after inactivity
  Future<void> logUserReturned({
    required int daysInactive,
    required String returnSource,
  }) async {
    await _analytics.logEvent(
      name: 'user_returned',
      parameters: {
        'days_inactive': daysInactive,
        'return_source': returnSource, // 'organic', 'push', 'email'
      },
    );
  }

  /// Track streak recovered
  Future<void> logStreakRecovered({
    required int previousStreak,
    required int recoveredStreak,
    required int recoveryPercent,
  }) async {
    await _analytics.logEvent(
      name: 'streak_recovered',
      parameters: {
        'previous_streak': previousStreak,
        'recovered_streak': recoveredStreak,
        'recovery_percent': recoveryPercent,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // EMPTY STATE & CTA EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track empty state viewed
  Future<void> logEmptyStateViewed({
    required String screenName,
    required String emptyStateType,
  }) async {
    await _analytics.logEvent(
      name: 'empty_state_viewed',
      parameters: {
        'screen_name': screenName,
        'empty_state_type': emptyStateType, // 'expenses', 'pursuits', 'reports', etc.
      },
    );
  }

  /// Track empty state CTA tapped
  Future<void> logEmptyStateCtaTapped({
    required String screenName,
    required String ctaAction,
  }) async {
    await _analytics.logEvent(
      name: 'empty_state_cta_tapped',
      parameters: {
        'screen_name': screenName,
        'cta_action': ctaAction, // 'add_expense', 'create_pursuit', etc.
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CONVERSION FUNNEL EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track activation event (user completed key action)
  Future<void> logActivationEvent({
    required String eventType,
    required int daysSinceInstall,
  }) async {
    await _analytics.logEvent(
      name: 'activation_event',
      parameters: {
        'event_type': eventType, // 'first_expense', 'profile_setup', 'first_pursuit'
        'days_since_install': daysSinceInstall,
      },
    );
  }

  /// Track retention milestone
  Future<void> logRetentionMilestone({
    required int dayNumber,
    required int expenseCount,
    required int pursuitCount,
  }) async {
    await _analytics.logEvent(
      name: 'retention_milestone',
      parameters: {
        'day_number': dayNumber, // 1, 3, 7, 14, 30
        'expense_count': expenseCount,
        'pursuit_count': pursuitCount,
      },
    );
  }

  /// Generic event logging method
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters?.map((key, value) {
        // Firebase only accepts String, int, double for parameters
        if (value is String || value is int || value is double) {
          return MapEntry(key, value);
        }
        return MapEntry(key, value.toString());
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ACHIEVEMENT EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track achievement unlocked
  Future<void> logAchievementUnlocked({required String achievementId}) async {
    await _analytics.logUnlockAchievement(id: achievementId);
  }

  // ─────────────────────────────────────────────────────────────────
  // STREAK EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track streak milestone
  Future<void> logStreakMilestone({required int days}) async {
    await _analytics.logEvent(
      name: 'streak_milestone',
      parameters: {'days': days},
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // USER PROPERTIES (Retention & Cohort Analysis)
  // ─────────────────────────────────────────────────────────────────

  /// Set first open date for cohort analysis
  Future<void> setUserFirstOpenDate() async {
    final now = DateTime.now();
    await _analytics.setUserProperty(
      name: 'first_open_date',
      value:
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    );
  }

  /// Set user type (pro/free)
  Future<void> setUserType(bool isPro) async {
    await _analytics.setUserProperty(
      name: 'user_type',
      value: isPro ? 'pro' : 'free',
    );
  }

  /// Set user premium status (legacy - kept for compatibility)
  Future<void> setUserPremiumStatus(bool isPremium) async {
    await _analytics.setUserProperty(
      name: 'is_premium',
      value: isPremium.toString(),
    );
    // Also update user_type for consistency
    await setUserType(isPremium);
  }

  /// Set user preferred currency
  Future<void> setUserCurrency(String currency) async {
    await _analytics.setUserProperty(name: 'currency', value: currency);
  }

  /// Set user preferred language
  Future<void> setUserLanguage(String language) async {
    await _analytics.setUserProperty(name: 'app_language', value: language);
  }

  /// Set app version
  Future<void> setAppVersion(String version) async {
    await _analytics.setUserProperty(name: 'app_version', value: version);
  }

  // ─────────────────────────────────────────────────────────────────
  // FUNNEL EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track first expense added (milestone)
  Future<void> logFirstExpense() async {
    await _analytics.logEvent(name: 'first_expense');
  }

  /// Track first pursuit created (milestone)
  Future<void> logFirstPursuit() async {
    await _analytics.logEvent(name: 'first_pursuit');
  }

  /// Track upgrade button clicked
  Future<void> logUpgradeClicked({String? source}) async {
    await _analytics.logEvent(
      name: 'upgrade_clicked',
      parameters: {'source': source ?? 'unknown'},
    );
  }

  /// Track AI chat used
  Future<void> logAiChatUsed({required bool isPremium}) async {
    await _analytics.logEvent(
      name: 'ai_chat_used',
      parameters: {'is_premium': isPremium ? 1 : 0},
    );
  }

  /// Track voice input used
  Future<void> logVoiceInputUsed() async {
    await _analytics.logEvent(name: 'voice_input_used');
  }

  /// Track backup created
  Future<void> logBackupCreated() async {
    await _analytics.logEvent(name: 'backup_created');
  }

  /// Track backup restored
  Future<void> logBackupRestored() async {
    await _analytics.logEvent(name: 'backup_restored');
  }

  /// Get analytics observer for navigation
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─────────────────────────────────────────────────────────────────
  // PERFORMANCE MONITORING (Tasks 75-78)
  // ─────────────────────────────────────────────────────────────────

  /// Track app startup time
  Future<void> logStartupTime({required int milliseconds}) async {
    await _analytics.logEvent(
      name: 'app_startup_time',
      parameters: {'duration_ms': milliseconds},
    );
  }

  /// Track screen load time
  Future<void> logScreenLoadTime({
    required String screenName,
    required int milliseconds,
  }) async {
    await _analytics.logEvent(
      name: 'screen_load_time',
      parameters: {
        'screen_name': screenName,
        'duration_ms': milliseconds,
      },
    );
  }

  /// Track API response time
  Future<void> logApiResponseTime({
    required String endpoint,
    required int milliseconds,
    required bool success,
  }) async {
    await _analytics.logEvent(
      name: 'api_response_time',
      parameters: {
        'endpoint': endpoint,
        'duration_ms': milliseconds,
        'success': success ? 1 : 0,
      },
    );
  }

  /// Track memory usage (high memory warning)
  Future<void> logHighMemoryUsage({required int megabytes}) async {
    await _analytics.logEvent(
      name: 'high_memory_usage',
      parameters: {'memory_mb': megabytes},
    );
  }

  /// Track battery optimization mode
  Future<void> logBatteryOptimization({required bool enabled}) async {
    await _analytics.logEvent(
      name: 'battery_optimization',
      parameters: {'enabled': enabled ? 1 : 0},
    );
  }

  /// Track crash/ANR event
  Future<void> logPerformanceIssue({
    required String issueType, // 'anr', 'slow_render', 'frozen_frame'
    String? details,
  }) async {
    await _analytics.logEvent(
      name: 'performance_issue',
      parameters: {
        'issue_type': issueType,
        'details': details ?? '',
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SOCIAL & SHARING EVENTS (Tasks 60-61)
  // ─────────────────────────────────────────────────────────────────

  /// Track pursuit shared
  Future<void> logPursuitShared({required double progress}) async {
    await _analytics.logEvent(
      name: 'pursuit_shared',
      parameters: {'progress_percent': (progress * 100).toInt()},
    );
  }

  /// Track achievement shared
  Future<void> logAchievementShared({required String achievementId}) async {
    await _analytics.logEvent(
      name: 'achievement_shared',
      parameters: {'achievement_id': achievementId},
    );
  }

  /// Track streak shared
  Future<void> logStreakShared({required int days}) async {
    await _analytics.logEvent(
      name: 'streak_shared',
      parameters: {'streak_days': days},
    );
  }
}
