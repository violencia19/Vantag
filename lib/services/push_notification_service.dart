import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// Push notification service for Firebase Cloud Messaging
/// Only active on iOS and Android platforms
/// On desktop platforms (Windows, macOS, Linux), this service is a no-op
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final NotificationService _localNotifications = NotificationService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Pref keys
  static const _keyPushEnabled = 'push_enabled';
  static const _keyFcmToken = 'fcm_token';
  static const _keyTopics = 'push_topics';

  /// Check if push notifications are supported on this platform
  bool get isSupported => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Initialize push notifications
  /// No-op on unsupported platforms
  Future<void> initialize() async {
    if (!isSupported) {
      debugPrint('[Push] Not supported on this platform');
      return;
    }

    // Firebase Messaging initialization would happen here on iOS/Android
    // For now, this is a stub that will be implemented when building for mobile
    debugPrint('[Push] Service initialized (mobile implementation required)');
  }

  /// Save FCM token
  Future<void> _saveToken(String? token) async {
    if (token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFcmToken, token);
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    if (!isSupported) return;

    try {
      await _saveTopicSubscription(topic, true);
      debugPrint('[Push] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[Push] Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!isSupported) return;

    try {
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
      final topics = await getSubscribedTopics();
      for (final topic in topics.keys) {
        await unsubscribeFromTopic(topic);
      }
    }
  }

  /// Request permission (if not already granted)
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    // Would call FirebaseMessaging.requestPermission() on mobile
    return true;
  }

  /// Dispose resources
  void dispose() {
    // Cleanup subscriptions on mobile
  }
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
