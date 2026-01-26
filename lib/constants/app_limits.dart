/// Centralized app limits for free tier and premium features.
/// Single source of truth for all feature limits.
class AppLimits {
  AppLimits._(); // Prevent instantiation

  // ===== AI CHAT =====
  /// Free users can use 4 AI preset buttons per day (no free text input).
  /// Free text input is PREMIUM ONLY.
  static const int freeAiChatsPerDay = 4;

  // ===== VOICE INPUT =====
  /// Free users can use voice input 3 times per day (very cheap, good UX).
  static const int freeVoiceInputPerDay = 3;

  /// Pro users can use voice input 10 times per day (shown as unlimited).
  static const int proVoiceInputPerDay = 10;

  // ===== PURSUITS =====
  /// Free users can have 1 active pursuit (savings goal).
  static const int freePursuits = 1;

  // ===== EXPENSE HISTORY =====
  /// Free users can view last 30 days of expense history.
  static const int freeHistoryDays = 30;

  // ===== CURRENCY =====
  /// Free users can only use TRY currency.
  static const String freeCurrency = 'TRY';

  // ===== REPORTS =====
  /// Free users can only view weekly reports.
  static const String freeReportPeriod = 'weekly';
}
