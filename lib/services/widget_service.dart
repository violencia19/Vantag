import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Service for providing data to home screen widgets (iOS/Android)
/// Uses home_widget package for cross-platform support
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  // iOS App Group ID (must match widget extension)
  static const String appGroupId = 'group.com.vantag.app';

  // Widget names
  static const String iOSWidgetName = 'VantagWidget';
  static const String androidSmallWidgetName = 'VantagSmallWidgetProvider';
  static const String androidMediumWidgetName = 'VantagMediumWidgetProvider';

  /// Initialize widget service
  Future<void> initialize() async {
    try {
      // Set app group for iOS
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(appGroupId);
      }

      // Register interactivity callback for widget taps
      await HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);

      debugPrint('[Widget] Service initialized');
    } catch (e) {
      debugPrint('[Widget] Initialization error: $e');
    }
  }

  /// Update widget data - call this whenever relevant data changes
  Future<void> updateWidgetData({
    required double todayHours,
    required int todayMinutes,
    required double todayAmount,
    required String currencySymbol,
    required String spendingLevel, // "low", "medium", "high"
    String? pursuitName,
    double? pursuitProgress,
    double? pursuitTarget,
    required String locale, // "en" or "tr"
  }) async {
    try {
      // Save all data for widgets to read
      await HomeWidget.saveWidgetData<double>('todayHours', todayHours);
      await HomeWidget.saveWidgetData<int>('todayMinutes', todayMinutes);
      await HomeWidget.saveWidgetData<double>('todayAmount', todayAmount);
      await HomeWidget.saveWidgetData<String>('currencySymbol', currencySymbol);
      await HomeWidget.saveWidgetData<String>('spendingLevel', spendingLevel);
      await HomeWidget.saveWidgetData<String>('pursuitName', pursuitName ?? '');
      await HomeWidget.saveWidgetData<double>('pursuitProgress', pursuitProgress ?? 0.0);
      await HomeWidget.saveWidgetData<double>('pursuitTarget', pursuitTarget ?? 0.0);
      await HomeWidget.saveWidgetData<String>('locale', locale);
      await HomeWidget.saveWidgetData<String>('lastUpdate', DateTime.now().toIso8601String());

      // Format time strings for widgets (avoids computation on widget side)
      final hourAbbrev = locale == 'tr' ? 's' : 'h';
      final minAbbrev = locale == 'tr' ? 'dk' : 'm';
      final formattedTime = '${todayHours.toInt()}$hourAbbrev ${todayMinutes}$minAbbrev';
      final formattedAmount = '$currencySymbol${todayAmount.toStringAsFixed(0)}';

      await HomeWidget.saveWidgetData<String>('formattedTime', formattedTime);
      await HomeWidget.saveWidgetData<String>('formattedAmount', formattedAmount);

      // Pursuit formatted string
      if (pursuitName != null && pursuitName.isNotEmpty && pursuitTarget != null && pursuitTarget > 0) {
        final pursuitProgressStr = '${pursuitProgress?.toInt() ?? 0}/${pursuitTarget.toInt()} $hourAbbrev';
        await HomeWidget.saveWidgetData<String>('pursuitProgressText', pursuitProgressStr);
        await HomeWidget.saveWidgetData<bool>('hasPursuit', true);
      } else {
        await HomeWidget.saveWidgetData<String>('pursuitProgressText', '');
        await HomeWidget.saveWidgetData<bool>('hasPursuit', false);
      }

      // Trigger widget update on both platforms
      await _updateWidgets();

      debugPrint('[Widget] Data updated: $formattedTime, $formattedAmount, level: $spendingLevel');
    } catch (e) {
      debugPrint('[Widget] Error updating widget data: $e');
    }
  }

  /// Update all widgets
  Future<void> _updateWidgets() async {
    try {
      if (Platform.isIOS) {
        await HomeWidget.updateWidget(iOSName: iOSWidgetName);
      } else if (Platform.isAndroid) {
        // Update both widget sizes
        await HomeWidget.updateWidget(androidName: androidSmallWidgetName);
        await HomeWidget.updateWidget(androidName: androidMediumWidgetName);
      }
    } catch (e) {
      debugPrint('[Widget] Error triggering widget update: $e');
    }
  }

  /// Request widget refresh (call on app launch to sync)
  Future<void> refreshWidgets() async {
    try {
      await _updateWidgets();
      debugPrint('[Widget] Refresh requested');
    } catch (e) {
      debugPrint('[Widget] Refresh error: $e');
    }
  }

  /// Get widget data (for reading back saved data)
  Future<T?> getWidgetData<T>(String key) async {
    try {
      return await HomeWidget.getWidgetData<T>(key);
    } catch (e) {
      debugPrint('[Widget] Error getting widget data: $e');
      return null;
    }
  }

  /// Check if widgets are supported on this platform
  bool get isSupported => Platform.isIOS || Platform.isAndroid;

  /// Calculate spending level based on daily average
  /// Returns "low", "medium", or "high"
  static String calculateSpendingLevel({
    required double todaySpending,
    required double dailyAverage,
  }) {
    if (dailyAverage <= 0) return 'low';

    final ratio = todaySpending / dailyAverage;

    if (ratio < 0.5) {
      return 'low'; // Green - under 50%
    } else if (ratio < 0.7) {
      return 'medium'; // Yellow - 50-70%
    } else {
      return 'high'; // Red - over 70%
    }
  }
}

/// Background callback for widget tap interactions
/// This is called when user taps on widget elements
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  debugPrint('[Widget] Background callback: $uri');

  if (uri == null) return;

  // Handle different deep link paths
  // vantag://home - Open main screen
  // vantag://pursuits - Open pursuits tab
  // These are handled by the app's deep link service when app opens
}

/// Global instance for easy access
final widgetService = WidgetService();

/// Widget types available
enum WidgetType {
  small, // Small widget (2x2) - daily spending
  medium, // Medium widget (4x2) - spending + pursuit
}

/// Widget spending level colors
enum SpendingLevel {
  low, // Green - under 50% of daily average
  medium, // Yellow - 50-70% of daily average
  high, // Red - over 70% of daily average
}

extension SpendingLevelExtension on SpendingLevel {
  String get value {
    switch (this) {
      case SpendingLevel.low:
        return 'low';
      case SpendingLevel.medium:
        return 'medium';
      case SpendingLevel.high:
        return 'high';
    }
  }

  static SpendingLevel fromString(String value) {
    switch (value) {
      case 'medium':
        return SpendingLevel.medium;
      case 'high':
        return SpendingLevel.high;
      default:
        return SpendingLevel.low;
    }
  }
}
