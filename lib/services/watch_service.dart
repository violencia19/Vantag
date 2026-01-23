import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for Apple Watch connectivity
class WatchService {
  static final WatchService _instance = WatchService._internal();
  factory WatchService() => _instance;
  WatchService._internal();

  // Method channel for Watch communication
  static const MethodChannel _channel = MethodChannel('com.vantag.app/watch');

  // Event channel for receiving messages from Watch
  static const EventChannel _eventChannel = EventChannel(
    'com.vantag.app/watch_events',
  );

  StreamSubscription? _eventSubscription;
  bool _isReachable = false;
  bool _isPaired = false;
  bool _isInstalled = false;

  bool get isReachable => _isReachable;
  bool get isPaired => _isPaired;
  bool get isInstalled => _isInstalled;

  // Callbacks
  Function(WatchMessage)? onMessageReceived;
  Function(bool)? onReachabilityChanged;

  /// Initialize watch service (iOS only)
  Future<void> initialize() async {
    if (!Platform.isIOS) return;

    try {
      // Check pairing status
      await checkStatus();

      // Listen for watch events
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
        _handleWatchEvent,
        onError: (error) => debugPrint('[Watch] Event error: $error'),
      );

      debugPrint('[Watch] Service initialized');
    } catch (e) {
      debugPrint('[Watch] Initialization error: $e');
    }
  }

  /// Check watch pairing and installation status
  Future<void> checkStatus() async {
    if (!Platform.isIOS) return;

    try {
      final result = await _channel.invokeMethod<Map>('checkStatus');
      if (result != null) {
        _isPaired = result['isPaired'] ?? false;
        _isInstalled = result['isInstalled'] ?? false;
        _isReachable = result['isReachable'] ?? false;
        debugPrint(
          '[Watch] Status: paired=$_isPaired, installed=$_isInstalled, reachable=$_isReachable',
        );
      }
    } catch (e) {
      debugPrint('[Watch] Status check error: $e');
    }
  }

  /// Send data to watch
  Future<bool> sendData(WatchData data) async {
    if (!Platform.isIOS || !_isReachable) return false;

    try {
      final result = await _channel.invokeMethod<bool>('sendData', {
        'data': json.encode(data.toJson()),
      });
      return result ?? false;
    } catch (e) {
      debugPrint('[Watch] Send data error: $e');
      return false;
    }
  }

  /// Update complication data
  Future<bool> updateComplication(ComplicationData data) async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>('updateComplication', {
        'data': json.encode(data.toJson()),
      });
      return result ?? false;
    } catch (e) {
      debugPrint('[Watch] Complication update error: $e');
      return false;
    }
  }

  /// Send user info (background transfer)
  Future<void> sendUserInfo(Map<String, dynamic> info) async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('sendUserInfo', {'info': json.encode(info)});
    } catch (e) {
      debugPrint('[Watch] User info error: $e');
    }
  }

  /// Handle watch events
  void _handleWatchEvent(dynamic event) {
    try {
      final data = event as Map;
      final type = data['type'] as String?;

      switch (type) {
        case 'reachabilityChanged':
          _isReachable = data['isReachable'] ?? false;
          onReachabilityChanged?.call(_isReachable);
          debugPrint('[Watch] Reachability changed: $_isReachable');
          break;

        case 'messageReceived':
          final messageData = data['data'] as Map?;
          if (messageData != null) {
            final message = WatchMessage.fromJson(
              Map<String, dynamic>.from(messageData),
            );
            onMessageReceived?.call(message);
            debugPrint('[Watch] Message received: ${message.type}');
          }
          break;

        case 'complicationTapped':
          // Handle complication tap
          debugPrint('[Watch] Complication tapped');
          break;

        default:
          debugPrint('[Watch] Unknown event: $type');
      }
    } catch (e) {
      debugPrint('[Watch] Event handling error: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _eventSubscription?.cancel();
  }
}

/// Data model for watch display
class WatchData {
  final double savedAmount;
  final int streakDays;
  final double hourlyRate;
  final String currencySymbol;
  final DateTime lastUpdate;

  WatchData({
    required this.savedAmount,
    required this.streakDays,
    required this.hourlyRate,
    required this.currencySymbol,
    required this.lastUpdate,
  });

  Map<String, dynamic> toJson() => {
    'savedAmount': savedAmount,
    'streakDays': streakDays,
    'hourlyRate': hourlyRate,
    'currencySymbol': currencySymbol,
    'lastUpdate': lastUpdate.toIso8601String(),
  };

  factory WatchData.fromJson(Map<String, dynamic> json) {
    return WatchData(
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
      currencySymbol: json['currencySymbol'] as String? ?? '₺',
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.parse(json['lastUpdate'] as String)
          : DateTime.now(),
    );
  }
}

/// Data model for complication display
class ComplicationData {
  final double savedAmount;
  final int streakDays;
  final String shortText;
  final String longText;

  ComplicationData({
    required this.savedAmount,
    required this.streakDays,
    required this.shortText,
    required this.longText,
  });

  Map<String, dynamic> toJson() => {
    'savedAmount': savedAmount,
    'streakDays': streakDays,
    'shortText': shortText,
    'longText': longText,
  };
}

/// Message received from watch
class WatchMessage {
  final String type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  WatchMessage({required this.type, this.data, required this.timestamp});

  factory WatchMessage.fromJson(Map<String, dynamic> json) {
    return WatchMessage(
      type: json['type'] as String? ?? '',
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

/// Global instance
final watchService = WatchService();

/// Watch message types
class WatchMessageTypes {
  static const String addExpense = 'add_expense';
  static const String quickAdd = 'quick_add';
  static const String syncRequest = 'sync_request';
  static const String streakCheck = 'streak_check';
}
