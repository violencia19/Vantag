import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

typedef MessageCallback = Future<void> Function(Map<String, dynamic> message);
typedef TokenCallback = void Function(String token);

/// Mobile platform implementation using Firebase Messaging
class PushNotificationPlatform {
  FirebaseMessaging? _messaging;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenSubscription;

  FirebaseMessaging get messaging {
    _messaging ??= FirebaseMessaging.instance;
    return _messaging!;
  }

  Future<bool> requestPermission() async {
    if (!Platform.isIOS && !Platform.isAndroid) return false;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() async {
    return await messaging.getToken();
  }

  void onTokenRefresh(TokenCallback callback) {
    _tokenSubscription = messaging.onTokenRefresh.listen(callback);
  }

  void onMessage(MessageCallback callback) {
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      callback(_remoteMessageToMap(message));
    });
  }

  void onMessageOpenedApp(Function(Map<String, dynamic>) callback) {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      callback(_remoteMessageToMap(message));
    });
  }

  Future<Map<String, dynamic>?> getInitialMessage() async {
    final message = await messaging.getInitialMessage();
    if (message != null) {
      return _remoteMessageToMap(message);
    }
    return null;
  }

  Future<void> subscribeToTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await messaging.unsubscribeFromTopic(topic);
  }

  void dispose() {
    _foregroundSubscription?.cancel();
    _tokenSubscription?.cancel();
  }

  Map<String, dynamic> _remoteMessageToMap(RemoteMessage message) {
    return {
      'messageId': message.messageId,
      'notification': message.notification != null
          ? {
              'title': message.notification!.title,
              'body': message.notification!.body,
            }
          : null,
      'data': message.data,
    };
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  // Note: This runs in a separate isolate, so you can't access stateful services
}
