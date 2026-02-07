import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized error logging service for Firebase Crashlytics
/// Ensures sensitive data is not leaked to crash reports
class ErrorLoggingService {
  // Patterns to redact from logs
  static final _sensitivePatterns = [
    RegExp(r'Bearer\s+[\w.-]+', caseSensitive: false),
    RegExp(r'api.?key\s*[=:]\s*\S+', caseSensitive: false),
    RegExp(r'password\s*[=:]\s*\S+', caseSensitive: false),
    RegExp(r'secret\s*[=:]\s*\S+', caseSensitive: false),
    RegExp(r'token\s*[=:]\s*\S+', caseSensitive: false),
    RegExp(r'sk-[A-Za-z0-9]{20,}'), // OpenAI API keys
    RegExp(r'AIza[A-Za-z0-9_-]{35}'), // Google/Firebase API keys
  ];

  /// Redact sensitive data from string
  static String _redactSensitive(String input) {
    var result = input;
    for (final pattern in _sensitivePatterns) {
      result = result.replaceAll(pattern, '[REDACTED]');
    }
    return result;
  }
  static final ErrorLoggingService _instance = ErrorLoggingService._internal();
  factory ErrorLoggingService() => _instance;
  ErrorLoggingService._internal();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Log a non-fatal error to Crashlytics
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? extraInfo,
  }) async {
    try {
      // Log to debug console
      debugPrint('[$reason] Error: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }

      // Add custom keys for extra context
      if (extraInfo != null) {
        for (final entry in extraInfo.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Record to Crashlytics
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('[ErrorLogging] Failed to log error: $e');
    }
  }

  /// Log a custom message to Crashlytics
  Future<void> log(String message) async {
    try {
      debugPrint('[Log] $message');
      await _crashlytics.log(message);
    } catch (e) {
      debugPrint('[ErrorLogging] Failed to log message: $e');
    }
  }

  /// Log API error with details (redacts sensitive data)
  Future<void> logApiError({
    required String endpoint,
    required int? statusCode,
    required dynamic error,
    StackTrace? stackTrace,
    String? responseBody,
  }) async {
    // Redact sensitive data from response body
    final safeResponseBody = responseBody != null
        ? _redactSensitive(responseBody.substring(0, (responseBody.length).clamp(0, 500)))
        : 'null';

    await logError(
      error,
      stackTrace,
      reason: 'API Error: $endpoint',
      extraInfo: {
        'endpoint': endpoint,
        'statusCode': statusCode ?? 'null',
        'responseBody': safeResponseBody,
      },
    );
  }

  /// Log parse error with details (redacts sensitive data)
  Future<void> logParseError({
    required String dataType,
    required dynamic error,
    StackTrace? stackTrace,
    String? rawData,
  }) async {
    // Redact sensitive data from raw data
    final safeRawData = rawData != null
        ? _redactSensitive(rawData.substring(0, (rawData.length).clamp(0, 200)))
        : 'null';

    await logError(
      error,
      stackTrace,
      reason: 'Parse Error: $dataType',
      extraInfo: {
        'dataType': dataType,
        'rawDataPreview': safeRawData,
      },
    );
  }

  /// Log offline error
  Future<void> logOfflineError(String feature) async {
    await log('Offline attempt: $feature');
  }

  /// Set user identifier for error tracking
  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('[ErrorLogging] Failed to set user ID: $e');
    }
  }
}

/// Global instance for easy access
final errorLogger = ErrorLoggingService();
