import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

/// Centralized error handling utility with Crashlytics integration
class ErrorHandler {
  /// Log error to Crashlytics and debug console
  static void handle(dynamic error, StackTrace? stack, {String? context}) {
    // Log to Crashlytics
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: context ?? 'Unknown error',
    );

    debugPrint('❌ [${context ?? 'Error'}] $error');
    if (stack != null) {
      debugPrint('Stack: $stack');
    }
  }

  /// Show user-friendly error message via SnackBar
  static void showUserError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success message via SnackBar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Execute async operation with error handling
  /// Returns [fallback] on error, logs to Crashlytics
  static Future<T?> tryAsync<T>(
    Future<T> Function() action, {
    String? context,
    T? fallback,
  }) async {
    try {
      return await action();
    } catch (e, stack) {
      handle(e, stack, context: context);
      return fallback;
    }
  }

  /// Execute sync operation with error handling
  static T? trySync<T>(
    T Function() action, {
    String? context,
    T? fallback,
  }) {
    try {
      return action();
    } catch (e, stack) {
      handle(e, stack, context: context);
      return fallback;
    }
  }

  /// Log a non-fatal error without throwing
  static void logNonFatal(String message, {String? context}) {
    FirebaseCrashlytics.instance.log('[$context] $message');
    debugPrint('⚠️ [${context ?? 'Warning'}] $message');
  }

  /// Set custom key for debugging
  static void setCustomKey(String key, dynamic value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
  }
}
