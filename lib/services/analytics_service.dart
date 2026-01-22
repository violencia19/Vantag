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
      parameters: {
        'name': name,
        'amount': amount,
      },
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
      parameters: {
        'category': category,
        'target_amount': targetAmount,
      },
    );
  }

  /// Track savings added to pursuit
  Future<void> logSavingsAdded({
    required double amount,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: 'savings_added',
      parameters: {
        'amount': amount,
        'source': source,
      },
    );
  }

  /// Track pursuit completed
  Future<void> logPursuitCompleted({
    required String pursuitId,
    required double targetAmount,
  }) async {
    await _analytics.logEvent(
      name: 'pursuit_completed',
      parameters: {
        'pursuit_id': pursuitId,
        'target_amount': targetAmount,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // AI CHAT EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track AI chat message sent
  Future<void> logAIChatMessage({
    required bool isPremium,
  }) async {
    await _analytics.logEvent(
      name: 'ai_chat_message',
      parameters: {
        'is_premium': isPremium ? 1 : 0,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // PREMIUM EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track premium purchase started
  Future<void> logPurchaseStarted({
    required String productId,
  }) async {
    await _analytics.logEvent(
      name: 'purchase_started',
      parameters: {
        'product_id': productId,
      },
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
  Future<void> logPaywallViewed({
    String? source,
  }) async {
    await _analytics.logEvent(
      name: 'paywall_viewed',
      parameters: {
        'source': source ?? 'unknown',
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // NAVIGATION EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track screen view
  Future<void> logScreenView({
    required String screenName,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ONBOARDING EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track onboarding step completed
  Future<void> logOnboardingStep({
    required int step,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_step',
      parameters: {
        'step': step,
      },
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
  Future<void> logAchievementUnlocked({
    required String achievementId,
  }) async {
    await _analytics.logUnlockAchievement(id: achievementId);
  }

  // ─────────────────────────────────────────────────────────────────
  // STREAK EVENTS
  // ─────────────────────────────────────────────────────────────────

  /// Track streak milestone
  Future<void> logStreakMilestone({
    required int days,
  }) async {
    await _analytics.logEvent(
      name: 'streak_milestone',
      parameters: {
        'days': days,
      },
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
    await _analytics.setUserProperty(
      name: 'currency',
      value: currency,
    );
  }

  /// Set user preferred language
  Future<void> setUserLanguage(String language) async {
    await _analytics.setUserProperty(
      name: 'language',
      value: language,
    );
  }
}
