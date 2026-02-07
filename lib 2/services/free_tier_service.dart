import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_limits.dart';

/// Service to manage free tier limitations
/// Centralizes all free tier logic for consistent enforcement
class FreeTierService {
  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTANTS (use AppLimits as single source of truth)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Maximum AI chat messages per day for free users
  static int get maxFreeAiChats => AppLimits.freeAiChatsPerDay;

  /// Maximum active pursuits for free users
  static int get maxFreePursuits => AppLimits.freePursuits;

  /// Free users can only use TRY currency
  static String get freeCurrency => AppLimits.freeCurrency;

  // SharedPreferences keys
  static const String _keyAiChatLastDate = 'free_ai_chat_last_date';
  static const String _keyAiChatCount = 'free_ai_chat_count';
  static const String _keyVoiceInputLastDate = 'voice_input_last_date';
  static const String _keyVoiceInputCount = 'voice_input_count';

  // Singleton
  static final FreeTierService _instance = FreeTierService._internal();
  factory FreeTierService() => _instance;
  FreeTierService._internal();

  // ═══════════════════════════════════════════════════════════════════════════
  // AI CHAT LIMITS (4/day for free users)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get today's AI chat count for free users
  Future<int> getTodayAiChatCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_keyAiChatLastDate) ?? '';

    // Reset counter if new day
    if (lastDate != today) {
      await prefs.setString(_keyAiChatLastDate, today);
      await prefs.setInt(_keyAiChatCount, 0);
      return 0;
    }

    return prefs.getInt(_keyAiChatCount) ?? 0;
  }

  /// Check if free user can use AI chat
  Future<bool> canUseAiChat(bool isPremium) async {
    if (isPremium) return true;
    final count = await getTodayAiChatCount();
    return count < maxFreeAiChats;
  }

  /// Get remaining AI chats for today
  /// Returns -1 for premium users (unlimited)
  Future<int> getRemainingAiChats(bool isPremium) async {
    if (isPremium) return -1; // Unlimited
    final count = await getTodayAiChatCount();
    return max(0, maxFreeAiChats - count);
  }

  /// Increment AI chat count after successful message
  Future<void> incrementAiChatCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await getTodayAiChatCount();
    await prefs.setInt(_keyAiChatCount, count + 1);
  }

  /// Get reset time for AI chat limit (midnight)
  DateTime getAiChatResetTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VOICE INPUT LIMITS (1/day free, 10/day pro)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Maximum voice inputs per day for free users
  static int get maxFreeVoiceInputs => AppLimits.freeVoiceInputPerDay;

  /// Maximum voice inputs per day for pro users
  static int get maxProVoiceInputs => AppLimits.proVoiceInputPerDay;

  /// Get today's voice input count
  Future<int> getTodayVoiceInputCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_keyVoiceInputLastDate) ?? '';

    // Reset counter if new day
    if (lastDate != today) {
      await prefs.setString(_keyVoiceInputLastDate, today);
      await prefs.setInt(_keyVoiceInputCount, 0);
      return 0;
    }

    return prefs.getInt(_keyVoiceInputCount) ?? 0;
  }

  /// Check if user can use voice input
  /// Returns a result with canUse flag and appropriate message type
  Future<VoiceInputLimitResult> canUseVoiceInput(bool isPremium) async {
    final count = await getTodayVoiceInputCount();

    if (isPremium) {
      // Pro user: 10/day limit (shown as unlimited)
      if (count >= maxProVoiceInputs) {
        return VoiceInputLimitResult(
          canUse: false,
          limitType: VoiceInputLimitType.proServerBusy,
        );
      }
      return VoiceInputLimitResult(canUse: true);
    } else {
      // Free user: 1/day limit
      if (count >= maxFreeVoiceInputs) {
        return VoiceInputLimitResult(
          canUse: false,
          limitType: VoiceInputLimitType.freeLimitReached,
        );
      }
      return VoiceInputLimitResult(canUse: true);
    }
  }

  /// Increment voice input count after successful use
  Future<void> incrementVoiceInputCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await getTodayVoiceInputCount();
    await prefs.setInt(_keyVoiceInputCount, count + 1);
  }

  /// Reset voice input count (for testing)
  Future<void> resetVoiceInputCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyVoiceInputLastDate);
    await prefs.remove(_keyVoiceInputCount);
    debugPrint('[FreeTierService] Voice input count reset');
  }

  /// Get remaining voice inputs for today
  /// Returns (used, total) tuple
  Future<(int used, int total)> getVoiceInputUsage(bool isPremium) async {
    final count = await getTodayVoiceInputCount();
    final maxLimit = isPremium ? maxProVoiceInputs : maxFreeVoiceInputs;
    return (count, maxLimit);
  }

  /// Get remaining AI chats for today (free users)
  /// Returns (used, total) tuple
  Future<(int used, int total)> getAiChatUsage() async {
    final count = await getTodayAiChatCount();
    return (count, maxFreeAiChats);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATEMENT IMPORT LIMITS (1/month free, 10/month pro)
  // ═══════════════════════════════════════════════════════════════════════════

  static const String _keyStatementImportMonth = 'statement_import_month';
  static const String _keyStatementImportCount = 'statement_import_count';

  /// Maximum statement imports per month for free users
  static const int maxFreeStatementImports = 1;

  /// Maximum statement imports per month for pro users
  static const int maxProStatementImports = 10;

  /// Get current month's statement import count
  Future<int> getMonthlyStatementImportCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = _getCurrentMonth();
    final savedMonth = prefs.getString(_keyStatementImportMonth) ?? '';

    // Reset counter if new month
    if (savedMonth != currentMonth) {
      await prefs.setString(_keyStatementImportMonth, currentMonth);
      await prefs.setInt(_keyStatementImportCount, 0);
      return 0;
    }

    return prefs.getInt(_keyStatementImportCount) ?? 0;
  }

  /// Get current month string (YYYY-MM)
  String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Check if user can import a statement
  Future<StatementImportLimitResult> canImportStatement(bool isPremium) async {
    final count = await getMonthlyStatementImportCount();
    final maxLimit = isPremium
        ? maxProStatementImports
        : maxFreeStatementImports;

    if (count >= maxLimit) {
      return StatementImportLimitResult(
        canUse: false,
        currentCount: count,
        maxCount: maxLimit,
        isPremium: isPremium,
      );
    }

    return StatementImportLimitResult(
      canUse: true,
      currentCount: count,
      maxCount: maxLimit,
      isPremium: isPremium,
    );
  }

  /// Increment statement import count after successful import
  Future<void> incrementStatementImportCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await getMonthlyStatementImportCount();
    await prefs.setInt(_keyStatementImportCount, count + 1);
    debugPrint('[FreeTierService] Statement import count: ${count + 1}');
  }

  /// Get remaining statement imports for this month
  Future<int> getRemainingStatementImports(bool isPremium) async {
    final count = await getMonthlyStatementImportCount();
    final maxLimit = isPremium
        ? maxProStatementImports
        : maxFreeStatementImports;
    return max(0, maxLimit - count);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PURSUIT LIMITS (1 active for free users)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if free user can create a new pursuit
  bool canCreatePursuit(bool isPremium, int activePursuitCount) {
    if (isPremium) return true;
    return activePursuitCount < maxFreePursuits;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CURRENCY LIMITS (TRY only for free users)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if currency is available for user
  bool isCurrencyAvailable(bool isPremium, String currencyCode) {
    if (isPremium) return true;
    return currencyCode == freeCurrency;
  }

  /// Get list of available currencies for user
  List<String> getAvailableCurrencies(bool isPremium) {
    if (isPremium) {
      return ['TRY', 'USD', 'EUR', 'GBP', 'SAR'];
    }
    return [freeCurrency];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REPORT LIMITS (Weekly only for free users)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if report period is available for user
  /// Free users can only access weekly reports
  bool isReportPeriodAvailable(bool isPremium, String period) {
    if (isPremium) return true;
    // Only 'week' is available for free users
    return period == 'week';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXPORT LIMITS (Premium only)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if export is available for user
  bool canExport(bool isPremium) {
    return isPremium;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARE CARD (Watermark for free users)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if share card should show watermark
  bool shouldShowWatermark(bool isPremium) {
    return !isPremium;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEBUG / TESTING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Reset AI chat count (for testing)
  Future<void> resetAiChatCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAiChatLastDate);
    await prefs.remove(_keyAiChatCount);
    debugPrint('[FreeTierService] AI chat count reset');
  }
}

/// Type of voice input limit reached
enum VoiceInputLimitType {
  /// Free user reached daily limit
  freeLimitReached,

  /// Pro user reached hidden limit (show as server busy)
  proServerBusy,
}

/// Result of voice input limit check
class VoiceInputLimitResult {
  final bool canUse;
  final VoiceInputLimitType? limitType;

  const VoiceInputLimitResult({required this.canUse, this.limitType});
}

/// Result of statement import limit check
class StatementImportLimitResult {
  final bool canUse;
  final int currentCount;
  final int maxCount;
  final bool isPremium;

  const StatementImportLimitResult({
    required this.canUse,
    required this.currentCount,
    required this.maxCount,
    required this.isPremium,
  });

  /// Remaining imports this month
  int get remaining => maxCount - currentCount;
}
