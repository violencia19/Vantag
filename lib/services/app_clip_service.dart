import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for iOS App Clips functionality
/// App Clips allow users to quickly access specific features without installing the full app
class AppClipService {
  static final AppClipService _instance = AppClipService._internal();
  factory AppClipService() => _instance;
  AppClipService._internal();

  // Method channel for App Clip communication
  static const MethodChannel _channel = MethodChannel('com.vantag.app/appclip');

  // Storage keys
  static const String _keyClipData = 'app_clip_data';
  static const String _keyClipLaunched = 'launched_from_clip';
  static const String _keyClipInvocation = 'clip_invocation_url';

  bool _isAppClip = false;
  bool _hasFullApp = false;
  AppClipInvocation? _invocation;

  bool get isAppClip => _isAppClip;
  bool get hasFullApp => _hasFullApp;
  AppClipInvocation? get invocation => _invocation;

  // Callbacks
  Function(AppClipInvocation)? onInvocationReceived;
  Function()? onFullAppInstalled;

  /// Initialize App Clip service
  Future<void> initialize() async {
    if (!Platform.isIOS) return;

    try {
      // Check if running as App Clip
      final result = await _channel.invokeMethod<Map>('checkAppClipStatus');
      if (result != null) {
        _isAppClip = result['isAppClip'] ?? false;
        _hasFullApp = result['hasFullApp'] ?? false;
        debugPrint('[AppClip] Status: isClip=$_isAppClip, hasFullApp=$_hasFullApp');
      }

      // Get invocation URL if launched from clip
      await _checkInvocation();

      // Setup method call handler for incoming calls
      _channel.setMethodCallHandler(_handleMethodCall);

      debugPrint('[AppClip] Service initialized');
    } catch (e) {
      debugPrint('[AppClip] Initialization error: $e');
    }
  }

  /// Handle method calls from native side
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onInvocation':
        final url = call.arguments['url'] as String?;
        if (url != null) {
          _invocation = AppClipInvocation.fromUrl(url);
          onInvocationReceived?.call(_invocation!);
        }
        break;

      case 'onFullAppInstalled':
        _hasFullApp = true;
        onFullAppInstalled?.call();
        break;

      default:
        debugPrint('[AppClip] Unknown method: ${call.method}');
    }
    return null;
  }

  /// Check for invocation URL
  Future<void> _checkInvocation() async {
    try {
      final url = await _channel.invokeMethod<String>('getInvocationUrl');
      if (url != null && url.isNotEmpty) {
        _invocation = AppClipInvocation.fromUrl(url);
        debugPrint('[AppClip] Invocation: ${_invocation?.action}');

        // Store for handoff to full app
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyClipInvocation, url);
        await prefs.setBool(_keyClipLaunched, true);
      }
    } catch (e) {
      debugPrint('[AppClip] Invocation check error: $e');
    }
  }

  /// Store data for handoff to full app
  Future<void> storeClipData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyClipData, json.encode(data));
      debugPrint('[AppClip] Data stored for handoff');
    } catch (e) {
      debugPrint('[AppClip] Store data error: $e');
    }
  }

  /// Retrieve data from App Clip (when full app launches)
  Future<Map<String, dynamic>?> retrieveClipData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wasLaunchedFromClip = prefs.getBool(_keyClipLaunched) ?? false;

      if (!wasLaunchedFromClip) return null;

      final dataJson = prefs.getString(_keyClipData);
      if (dataJson != null) {
        // Clear the data after retrieval
        await prefs.remove(_keyClipData);
        await prefs.remove(_keyClipLaunched);
        await prefs.remove(_keyClipInvocation);

        return Map<String, dynamic>.from(json.decode(dataJson));
      }
    } catch (e) {
      debugPrint('[AppClip] Retrieve data error: $e');
    }
    return null;
  }

  /// Get the original invocation URL if launched from clip
  Future<String?> getStoredInvocationUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyClipInvocation);
  }

  /// Prompt user to install full app
  Future<void> promptFullAppInstall() async {
    if (!_isAppClip) return;

    try {
      await _channel.invokeMethod('promptFullAppInstall');
      debugPrint('[AppClip] Full app install prompted');
    } catch (e) {
      debugPrint('[AppClip] Prompt install error: $e');
    }
  }

  /// Open App Store page for full app
  Future<void> openAppStore() async {
    try {
      await _channel.invokeMethod('openAppStore');
    } catch (e) {
      debugPrint('[AppClip] Open App Store error: $e');
    }
  }

  /// Check if specific feature is available in App Clip
  bool isFeatureAvailable(AppClipFeature feature) {
    if (!_isAppClip) return true; // Full app has all features

    // App Clip limited features
    switch (feature) {
      case AppClipFeature.quickExpense:
      case AppClipFeature.viewSavings:
      case AppClipFeature.viewStreak:
        return true;
      case AppClipFeature.aiChat:
      case AppClipFeature.pursuits:
      case AppClipFeature.reports:
      case AppClipFeature.subscriptions:
      case AppClipFeature.achievements:
      case AppClipFeature.settings:
        return false; // These require full app
    }
  }

  /// Get recommended action based on invocation
  AppClipAction getRecommendedAction() {
    if (_invocation == null) return AppClipAction.showQuickExpense;

    switch (_invocation!.action) {
      case 'add':
      case 'expense':
        return AppClipAction.showQuickExpense;
      case 'savings':
      case 'progress':
        return AppClipAction.showSavingsProgress;
      case 'streak':
        return AppClipAction.showStreak;
      default:
        return AppClipAction.showQuickExpense;
    }
  }
}

/// App Clip invocation data
class AppClipInvocation {
  final String originalUrl;
  final String action;
  final Map<String, String> parameters;
  final DateTime timestamp;

  AppClipInvocation({
    required this.originalUrl,
    required this.action,
    required this.parameters,
    required this.timestamp,
  });

  factory AppClipInvocation.fromUrl(String url) {
    final uri = Uri.parse(url);

    // Parse action from path or host
    String action = 'default';
    if (uri.pathSegments.isNotEmpty) {
      action = uri.pathSegments.first;
    } else if (uri.host.isNotEmpty) {
      action = uri.host;
    }

    return AppClipInvocation(
      originalUrl: url,
      action: action,
      parameters: uri.queryParameters,
      timestamp: DateTime.now(),
    );
  }

  /// Get expense amount if provided in invocation
  double? get amount {
    final amountStr = parameters['amount'];
    if (amountStr == null) return null;
    return double.tryParse(amountStr.replaceAll(',', '.'));
  }

  /// Get category if provided
  String? get category => parameters['category'] ?? parameters['cat'];

  /// Get description if provided
  String? get description =>
      parameters['description'] ??
      parameters['desc'] ??
      parameters['note'];
}

/// Features available in App Clip
enum AppClipFeature {
  quickExpense,
  viewSavings,
  viewStreak,
  aiChat,
  pursuits,
  reports,
  subscriptions,
  achievements,
  settings,
}

/// Actions App Clip can perform
enum AppClipAction {
  showQuickExpense,
  showSavingsProgress,
  showStreak,
  promptInstall,
}

/// Global instance
final appClipService = AppClipService();

/// App Clip URL schemes
class AppClipUrls {
  /// Base URL for App Clip invocations
  static const String baseUrl = 'https://appclip.vantag.app';

  /// Generate quick expense URL for NFC/QR
  static String quickExpense({double? amount, String? category}) {
    final params = <String, String>{};
    if (amount != null) params['amount'] = amount.toString();
    if (category != null) params['category'] = category;

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$baseUrl/expense${queryString.isNotEmpty ? '?$queryString' : ''}';
  }

  /// Generate savings progress URL
  static String savingsProgress() => '$baseUrl/savings';

  /// Generate streak check URL
  static String streakCheck() => '$baseUrl/streak';
}
