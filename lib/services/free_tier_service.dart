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
