import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

/// Service for providing data to home screen widgets (iOS/Android)
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  // Method channel for native widget communication
  static const MethodChannel _channel = MethodChannel('com.vantag.app/widget');

  // App Group ID for iOS (must match widget extension)
  static const String _appGroupId = 'group.com.vantag.app';

  // Widget data keys
  static const String _keyWidgetData = 'widget_data';
  static const String _keyLastUpdate = 'widget_last_update';

  /// Initialize widget service
  Future<void> initialize() async {
    // Initial data sync
    await updateWidgetData(WidgetData.empty());
  }

  /// Update widget data (call this when relevant data changes)
  Future<void> updateWidgetData(WidgetData data) async {
    try {
      final jsonData = json.encode(data.toJson());

      if (Platform.isIOS) {
        await _updateIOSWidget(jsonData);
      } else if (Platform.isAndroid) {
        await _updateAndroidWidget(jsonData);
      }

      // Also save to SharedPreferences as fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyWidgetData, jsonData);
      await prefs.setString(_keyLastUpdate, DateTime.now().toIso8601String());

      debugPrint('[Widget] Data updated: ${data.savedAmount}');
    } catch (e) {
      debugPrint('[Widget] Error updating widget data: $e');
    }
  }

  /// Update iOS widget via UserDefaults (App Groups)
  Future<void> _updateIOSWidget(String jsonData) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'appGroupId': _appGroupId,
        'data': jsonData,
      });
    } catch (e) {
      debugPrint('[Widget] iOS update error: $e');
    }
  }

  /// Update Android widget via native channel
  Future<void> _updateAndroidWidget(String jsonData) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'data': jsonData,
      });
    } catch (e) {
      debugPrint('[Widget] Android update error: $e');
    }
  }

  /// Request widget refresh (iOS only)
  Future<void> refreshWidgets() async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('refreshWidgets');
      debugPrint('[Widget] Refresh requested');
    } catch (e) {
      debugPrint('[Widget] Refresh error: $e');
    }
  }

  /// Get last widget data
  Future<WidgetData?> getLastWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_keyWidgetData);
      if (jsonData != null) {
        return WidgetData.fromJson(json.decode(jsonData));
      }
    } catch (e) {
      debugPrint('[Widget] Error getting widget data: $e');
    }
    return null;
  }

  /// Check if widgets are supported
  Future<bool> isSupported() async {
    try {
      final result = await _channel.invokeMethod('isSupported');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}

/// Data model for widget display
class WidgetData {
  final double savedAmount;
  final double savedHours;
  final int streakDays;
  final int noDecisionCount;
  final double monthlyBudgetUsed;
  final double monthlyBudgetTotal;
  final String currencySymbol;
  final DateTime lastUpdate;

  WidgetData({
    required this.savedAmount,
    required this.savedHours,
    required this.streakDays,
    required this.noDecisionCount,
    required this.monthlyBudgetUsed,
    required this.monthlyBudgetTotal,
    required this.currencySymbol,
    required this.lastUpdate,
  });

  factory WidgetData.empty() {
    return WidgetData(
      savedAmount: 0,
      savedHours: 0,
      streakDays: 0,
      noDecisionCount: 0,
      monthlyBudgetUsed: 0,
      monthlyBudgetTotal: 0,
      currencySymbol: '₺',
      lastUpdate: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'savedAmount': savedAmount,
        'savedHours': savedHours,
        'streakDays': streakDays,
        'noDecisionCount': noDecisionCount,
        'monthlyBudgetUsed': monthlyBudgetUsed,
        'monthlyBudgetTotal': monthlyBudgetTotal,
        'currencySymbol': currencySymbol,
        'lastUpdate': lastUpdate.toIso8601String(),
      };

  factory WidgetData.fromJson(Map<String, dynamic> json) {
    return WidgetData(
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
      savedHours: (json['savedHours'] as num?)?.toDouble() ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      noDecisionCount: json['noDecisionCount'] as int? ?? 0,
      monthlyBudgetUsed: (json['monthlyBudgetUsed'] as num?)?.toDouble() ?? 0,
      monthlyBudgetTotal: (json['monthlyBudgetTotal'] as num?)?.toDouble() ?? 0,
      currencySymbol: json['currencySymbol'] as String? ?? '₺',
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.parse(json['lastUpdate'] as String)
          : DateTime.now(),
    );
  }

  /// Get budget progress (0.0 - 1.0)
  double get budgetProgress {
    if (monthlyBudgetTotal <= 0) return 0;
    return (monthlyBudgetUsed / monthlyBudgetTotal).clamp(0.0, 1.0);
  }

  /// Get formatted saved amount
  String get formattedSavedAmount {
    if (savedAmount >= 1000000) {
      return '${(savedAmount / 1000000).toStringAsFixed(1)}M$currencySymbol';
    } else if (savedAmount >= 1000) {
      return '${(savedAmount / 1000).toStringAsFixed(1)}K$currencySymbol';
    }
    return '${savedAmount.toStringAsFixed(0)}$currencySymbol';
  }

  /// Get formatted saved hours
  String get formattedSavedHours {
    if (savedHours >= 24) {
      final days = savedHours / 8;
      return '${days.toStringAsFixed(1)} days';
    }
    return '${savedHours.toStringAsFixed(1)}h';
  }
}

/// Global instance
final widgetService = WidgetService();

/// Widget types available
enum WidgetType {
  small, // Small widget (savings amount only)
  medium, // Medium widget (savings + streak)
  large, // Large widget (full dashboard)
}

/// Widget theme options
enum WidgetTheme {
  dark, // Dark theme (default)
  light, // Light theme
  system, // Follow system
}
