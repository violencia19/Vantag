import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// Push notification service for Firebase Cloud Messaging
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationService _localNotifications = NotificationService();

  String? _fcmToken;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenSubscription;

  String? get fcmToken => _fcmToken;

  // Pref keys
  static const _keyPushEnabled = 'push_enabled';
  static const _keyFcmToken = 'fcm_token';
  static const _keyTopics = 'push_topics';

  /// Initialize push notifications
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      debugPrint('[Push] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _setupMessaging();
      }
    } catch (e) {
      debugPrint('[Push] Initialization error: $e');
    }
  }

  /// Setup messaging handlers
  Future<void> _setupMessaging() async {
    // Get FCM token
    _fcmToken = await _messaging.getToken();
    debugPrint('[Push] FCM Token: $_fcmToken');
    await _saveToken(_fcmToken);

    // Listen for token refresh
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) {
      debugPrint('[Push] Token refreshed: $token');
      _fcmToken = token;
      _saveToken(token);
    });

    // Handle foreground messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (when app is opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[Push] Foreground message: ${message.messageId}');
    debugPrint('[Push] Data: ${message.data}');
    debugPrint('[Push] Notification: ${message.notification?.title} - ${message.notification?.body}');

    // Show as local notification
    if (message.notification != null) {
      await _showLocalNotification(message);
    }

    // Handle data messages
    if (message.data.isNotEmpty) {
      await _handleDataMessage(message.data);
    }
  }

  /// Handle when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[Push] Message opened app: ${message.messageId}');
    debugPrint('[Push] Data: ${message.data}');

    // Navigate based on notification data
    final action = message.data['action'];
    switch (action) {
      case 'open_expense':
        // Navigate to expense screen
        break;
      case 'open_pursuits':
        // Navigate to pursuits
        break;
      case 'open_achievements':
        // Navigate to achievements
        break;
      case 'open_paywall':
        // Navigate to paywall
        break;
      default:
        // Default action
        break;
    }
  }

  /// Show local notification for push message
  Future<void> _showLocalNotification(RemoteMessage message) async {
    await _localNotifications.initialize();

    // Use the local notification plugin to show the notification
    // This ensures consistent notification appearance
    debugPrint('[Push] Showing local notification for: ${message.notification?.title}');
  }

  /// Handle data-only messages
  Future<void> _handleDataMessage(Map<String, dynamic> data) async {
    final type = data['type'];

    switch (type) {
      case 'sync':
        // Trigger data sync
        debugPrint('[Push] Sync requested');
        break;
      case 'promo':
        // Handle promotional message
        debugPrint('[Push] Promo received: ${data['promo_id']}');
        break;
      case 'achievement':
        // Handle achievement unlock notification
        debugPrint('[Push] Achievement notification: ${data['achievement_id']}');
        break;
      case 'reminder':
        // Handle reminder
        debugPrint('[Push] Reminder: ${data['reminder_type']}');
        break;
      default:
        debugPrint('[Push] Unknown message type: $type');
    }
  }

  /// Save FCM token
  Future<void> _saveToken(String? token) async {
    if (token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFcmToken, token);

    // TODO: Send token to your backend server
    // await _sendTokenToServer(token);
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      await _saveTopicSubscription(topic, true);
      debugPrint('[Push] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[Push] Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      await _saveTopicSubscription(topic, false);
      debugPrint('[Push] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[Push] Error unsubscribing from topic: $e');
    }
  }

  /// Save topic subscription status
  Future<void> _saveTopicSubscription(String topic, bool subscribed) async {
    final prefs = await SharedPreferences.getInstance();
    final topicsJson = prefs.getString(_keyTopics) ?? '{}';
    final topics = Map<String, bool>.from(json.decode(topicsJson));
    topics[topic] = subscribed;
    await prefs.setString(_keyTopics, json.encode(topics));
  }

  /// Get subscribed topics
  Future<Map<String, bool>> getSubscribedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final topicsJson = prefs.getString(_keyTopics) ?? '{}';
    return Map<String, bool>.from(json.decode(topicsJson));
  }

  /// Check if push notifications are enabled
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPushEnabled) ?? true;
  }

  /// Enable/disable push notifications
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPushEnabled, enabled);

    if (!enabled) {
      // Unsubscribe from all topics
      final topics = await getSubscribedTopics();
      for (final topic in topics.keys) {
        await unsubscribeFromTopic(topic);
      }
    }
  }

  /// Get notification settings
  Future<NotificationSettings> getSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Request permission (if not already granted)
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Dispose resources
  void dispose() {
    _foregroundSubscription?.cancel();
    _tokenSubscription?.cancel();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[Push] Background message: ${message.messageId}');
  // Handle background message
  // Note: This runs in a separate isolate, so you can't access stateful services
}

/// Global instance
final pushNotifications = PushNotificationService();

/// Available push notification topics
class PushTopics {
  static const String general = 'general';
  static const String tips = 'tips';
  static const String promos = 'promos';
  static const String achievements = 'achievements';
  static const String weeklyInsights = 'weekly_insights';
}
