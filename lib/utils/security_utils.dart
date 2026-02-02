import 'package:flutter/foundation.dart';

/// Security utilities for input validation and sanitization
class SecurityUtils {
  SecurityUtils._();

  // Maximum lengths for input fields
  static const int maxDescriptionLength = 200;
  static const int maxCategoryLength = 50;
  static const int maxNameLength = 100;

  // ─────────────────────────────────────────────────────────────────
  // INPUT VALIDATION
  // ─────────────────────────────────────────────────────────────────

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate amount (positive number)
  static bool isValidAmount(String input) {
    final amount = double.tryParse(input.replaceAll(',', '.'));
    return amount != null && amount > 0;
  }

  /// Parse amount safely
  static double? parseAmount(String input) {
    if (input.isEmpty) return null;
    final normalized = input
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(normalized);
  }

  /// Validate percentage (0-100)
  static bool isValidPercentage(String input) {
    final value = double.tryParse(input);
    return value != null && value >= 0 && value <= 100;
  }

  // ─────────────────────────────────────────────────────────────────
  // INPUT SANITIZATION
  // ─────────────────────────────────────────────────────────────────

  /// Sanitize text input (remove control characters)
  static String sanitizeText(String input) {
    // Remove control characters except newlines and tabs
    return input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
  }

  /// Sanitize and trim text
  static String sanitizeAndTrim(String input, {int maxLength = 500}) {
    final sanitized = sanitizeText(input.trim());
    if (sanitized.length > maxLength) {
      return sanitized.substring(0, maxLength);
    }
    return sanitized;
  }

  /// Sanitize filename
  static String sanitizeFilename(String filename) {
    // Remove or replace characters that are unsafe in filenames
    return filename
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\.{2,}'), '.')
        .trim();
  }

  // ─────────────────────────────────────────────────────────────────
  // DATA MASKING (FOR LOGGING)
  // ─────────────────────────────────────────────────────────────────

  /// Mask email for logging (show first 2 chars and domain)
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) return '**@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }

  /// Mask phone number for logging
  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return '****';
    return '****${digits.substring(digits.length - 4)}';
  }

  /// Mask user ID for logging (show first 4 and last 4 chars)
  static String maskUserId(String userId) {
    if (userId.length <= 8) return '****';
    return '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
  }

  // ─────────────────────────────────────────────────────────────────
  // RATE LIMITING HELPERS
  // ─────────────────────────────────────────────────────────────────

  /// Check if action should be rate limited
  static bool shouldRateLimit({
    required DateTime? lastAction,
    required Duration minInterval,
  }) {
    if (lastAction == null) return false;
    return DateTime.now().difference(lastAction) < minInterval;
  }

  // ─────────────────────────────────────────────────────────────────
  // SECURE COMPARISON
  // ─────────────────────────────────────────────────────────────────

  /// Constant-time string comparison (prevents timing attacks)
  static bool secureCompare(String a, String b) {
    if (a.length != b.length) return false;

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

/// Throttle helper for preventing button spam
/// Tracks last action time per key to prevent rapid repeated actions
class ActionThrottle {
  static final Map<String, DateTime> _lastActions = {};

  /// Check if action is allowed (not throttled)
  /// Returns true if action is allowed, false if throttled
  static bool canPerform(String actionKey, {Duration minInterval = const Duration(milliseconds: 500)}) {
    final now = DateTime.now();
    final lastAction = _lastActions[actionKey];

    if (lastAction != null && now.difference(lastAction) < minInterval) {
      debugPrint('[Throttle] Action "$actionKey" throttled');
      return false;
    }

    _lastActions[actionKey] = now;
    return true;
  }

  /// Reset throttle for a specific action
  static void reset(String actionKey) {
    _lastActions.remove(actionKey);
  }

  /// Clear all throttles
  static void clearAll() {
    _lastActions.clear();
  }
}
