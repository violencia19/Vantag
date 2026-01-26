import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized error logging service for Firebase Crashlytics
class ErrorLoggingService {
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

  /// Log API error with details
  Future<void> logApiError({
    required String endpoint,
    required int? statusCode,
    required dynamic error,
    StackTrace? stackTrace,
    String? responseBody,
  }) async {
    await logError(
      error,
      stackTrace,
      reason: 'API Error: $endpoint',
      extraInfo: {
        'endpoint': endpoint,
        'statusCode': statusCode ?? 'null',
        'responseBody': responseBody?.substring(0, (responseBody.length).clamp(0, 500)) ?? 'null',
      },
    );
  }

  /// Log parse error with details
  Future<void> logParseError({
    required String dataType,
    required dynamic error,
    StackTrace? stackTrace,
    String? rawData,
  }) async {
    await logError(
      error,
      stackTrace,
      reason: 'Parse Error: $dataType',
      extraInfo: {
        'dataType': dataType,
        'rawDataPreview': rawData?.substring(0, (rawData.length).clamp(0, 200)) ?? 'null',
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
