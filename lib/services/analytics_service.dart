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
  // EXPENSE EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track when user adds an expense
  Future<void> logExpenseAdded({
    required double amount,
    required String category,
    required String decision,
  }) async {
    await _analytics.logEvent(
      name: 'expense_added',
      parameters: {
        'amount': amount,
        'category': category,
        'decision': decision,
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

  /// Track pursuit created
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
  // ONBOARDING EVENTS
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
  // USER PROPERTIES
  // ─────────────────────────────────────────────────────────────────

  /// Set user premium status
  Future<void> setUserPremiumStatus(bool isPremium) async {
    await _analytics.setUserProperty(
      name: 'is_premium',
      value: isPremium.toString(),
    );
  }

  /// Set user preferred currency
  Future<void> setUserCurrency(String currency) async {
    await _analytics.setUserProperty(name: 'currency', value: currency);
  }

  /// Set user preferred language
  Future<void> setUserLanguage(String language) async {
    await _analytics.setUserProperty(name: 'language', value: language);
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
