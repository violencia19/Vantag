/// Stub implementation for platforms that don't support Firebase Messaging
/// (Windows, macOS, Linux, Web)

typedef MessageCallback = Future<void> Function(Map<String, dynamic> message);
typedef TokenCallback = void Function(String token);

/// Stub platform implementation - does nothing
class PushNotificationPlatform {
  Future<bool> requestPermission() async => false;

  Future<String?> getToken() async => null;

  void onTokenRefresh(TokenCallback callback) {}

  void onMessage(MessageCallback callback) {}

  void onMessageOpenedApp(Function(Map<String, dynamic>) callback) {}

  Future<Map<String, dynamic>?> getInitialMessage() async => null;

  Future<void> subscribeToTopic(String topic) async {}

  Future<void> unsubscribeFromTopic(String topic) async {}

  void dispose() {}
}
