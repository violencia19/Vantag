import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to manage iOS Live Activities and Dynamic Island
class LiveActivityService {
  static const _channel = MethodChannel('com.vantag.app/live_activity');

  static LiveActivityService? _instance;
  static LiveActivityService get instance => _instance ??= LiveActivityService._();

  LiveActivityService._();

  bool _isActivityRunning = false;
  String? _currentActivityId;

  bool get isActivityRunning => _isActivityRunning;

  /// Start a new Live Activity
  Future<bool> startActivity({
    required int streakDays,
    required double todaySpent,
    required double dailyBudget,
    required String currencySymbol,
    required String formattedTime,
    required String spendingLevel,
  }) async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<Map>('startActivity', {
        'streakDays': streakDays,
        'todaySpent': todaySpent,
        'dailyBudget': dailyBudget,
        'currencySymbol': currencySymbol,
        'formattedTime': formattedTime,
        'spendingLevel': spendingLevel,
      });

      if (result != null && result['success'] == true) {
        _isActivityRunning = true;
        _currentActivityId = result['activityId'] as String?;
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      debugPrint('[LiveActivity] Start error: ${e.message}');
      return false;
    } on MissingPluginException {
      debugPrint('[LiveActivity] Not available on this device');
      return false;
    }
  }

  /// Update the current Live Activity
  Future<bool> updateActivity({
    required int streakDays,
    required double todaySpent,
    required double dailyBudget,
    required String currencySymbol,
    required String formattedTime,
    required String spendingLevel,
  }) async {
    if (!Platform.isIOS || !_isActivityRunning) return false;

    try {
      final result = await _channel.invokeMethod<bool>('updateActivity', {
        'activityId': _currentActivityId,
        'streakDays': streakDays,
        'todaySpent': todaySpent,
        'dailyBudget': dailyBudget,
        'currencySymbol': currencySymbol,
        'formattedTime': formattedTime,
        'spendingLevel': spendingLevel,
      });

      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('[LiveActivity] Update error: ${e.message}');
      return false;
    }
  }

  /// End the current Live Activity
  Future<bool> endActivity() async {
    if (!Platform.isIOS || !_isActivityRunning) return false;

    try {
      final result = await _channel.invokeMethod<bool>('endActivity', {
        'activityId': _currentActivityId,
      });

      if (result == true) {
        _isActivityRunning = false;
        _currentActivityId = null;
      }
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('[LiveActivity] End error: ${e.message}');
      return false;
    }
  }

  /// Check if Live Activities are supported
  Future<bool> areActivitiesSupported() async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>('areActivitiesSupported');
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Get spending level based on percentage of daily budget used
  static String getSpendingLevel(double todaySpent, double dailyBudget) {
    if (dailyBudget <= 0) return 'low';

    final percentage = todaySpent / dailyBudget;
    if (percentage >= 0.8) return 'high';
    if (percentage >= 0.5) return 'medium';
    return 'low';
  }
}
