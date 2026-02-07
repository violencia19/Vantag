import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Push notification service for Firebase Cloud Messaging
/// Only active on iOS and Android platforms
/// On desktop platforms (Windows, macOS, Linux), this service is a no-op
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Pref keys
  static const _keyPushEnabled = 'push_enabled';
  static const _keyFcmToken = 'fcm_token';
  static const _keyTopics = 'push_topics';
  static const _keyQuietHoursStart = 'push_quiet_start';
  static const _keyQuietHoursEnd = 'push_quiet_end';
  static const _keyPreferredTime = 'push_preferred_time';
  static const _keyLastActivityHour = 'push_last_activity_hour';
  static const _keyActivityHours = 'push_activity_hours';
  static const _keyLastPushSent = 'push_last_sent';
  static const _keyPushHistory = 'push_history';

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

  /// Save FCM token (will be used when Firebase Messaging is integrated)
  Future<void> saveToken(String? token) async {
    if (token == null) return;
    _fcmToken = token;
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

  // ===========================================
  // NOTIFICATION TIMING OPTIMIZATION
  // ===========================================

  /// Default quiet hours (22:00 - 08:00)
  static const int _defaultQuietStart = 22;
  static const int _defaultQuietEnd = 8;

  /// Record user activity to learn optimal notification time
  Future<void> recordUserActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final hour = now.hour;

    // Store last activity hour
    await prefs.setInt(_keyLastActivityHour, hour);

    // Update activity hours histogram
    final histogramJson = prefs.getString(_keyActivityHours) ?? '{}';
    final histogram = Map<String, int>.from(json.decode(histogramJson));
    final hourKey = hour.toString();
    histogram[hourKey] = (histogram[hourKey] ?? 0) + 1;
    await prefs.setString(_keyActivityHours, json.encode(histogram));

    debugPrint('[Push] Recorded activity at hour: $hour');
  }

  /// Get optimal notification time based on user activity patterns
  Future<NotificationTime> getOptimalNotificationTime({
    PushNotificationType type = PushNotificationType.general,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Check for user-preferred time
    final preferredHour = prefs.getInt(_keyPreferredTime);
    if (preferredHour != null) {
      return NotificationTime(
        hour: preferredHour,
        minute: 0,
        source: NotificationTimeSource.userPreferred,
      );
    }

    // Analyze activity histogram
    final histogramJson = prefs.getString(_keyActivityHours) ?? '{}';
    final histogram = Map<String, int>.from(json.decode(histogramJson));

    if (histogram.isNotEmpty) {
      // Find peak activity hour (excluding quiet hours)
      final quietStart = prefs.getInt(_keyQuietHoursStart) ?? _defaultQuietStart;
      final quietEnd = prefs.getInt(_keyQuietHoursEnd) ?? _defaultQuietEnd;

      int peakHour = 9; // Default
      int maxCount = 0;

      for (final entry in histogram.entries) {
        final hour = int.parse(entry.key);
        if (!_isQuietHour(hour, quietStart, quietEnd) && entry.value > maxCount) {
          maxCount = entry.value;
          peakHour = hour;
        }
      }

      // Adjust based on notification type
      final adjustedHour = _adjustTimeForType(peakHour, type);

      return NotificationTime(
        hour: adjustedHour,
        minute: 0,
        source: NotificationTimeSource.learned,
      );
    }

    // Fall back to type-specific defaults
    return _getDefaultTimeForType(type);
  }

  /// Adjust notification time based on type
  int _adjustTimeForType(int baseHour, PushNotificationType type) {
    switch (type) {
      case PushNotificationType.streakReminder:
        // Send in evening (before bed) to remind about daily tracking
        return baseHour < 18 ? 20 : baseHour;
      case PushNotificationType.morningMotivation:
        // Send in morning
        return baseHour > 10 ? 9 : baseHour;
      case PushNotificationType.weeklyInsight:
        // Send on Sunday morning
        return 10;
      case PushNotificationType.reengagement:
        // Send during peak activity
        return baseHour;
      case PushNotificationType.achievement:
        // Send immediately (no adjustment)
        return baseHour;
      case PushNotificationType.general:
        return baseHour;
    }
  }

  /// Get default time for notification type
  NotificationTime _getDefaultTimeForType(PushNotificationType type) {
    switch (type) {
      case PushNotificationType.streakReminder:
        return const NotificationTime(
          hour: 20,
          minute: 0,
          source: NotificationTimeSource.defaultTime,
        );
      case PushNotificationType.morningMotivation:
        return const NotificationTime(
          hour: 9,
          minute: 0,
          source: NotificationTimeSource.defaultTime,
        );
      case PushNotificationType.weeklyInsight:
        return const NotificationTime(
          hour: 10,
          minute: 0,
          source: NotificationTimeSource.defaultTime,
        );
      case PushNotificationType.reengagement:
        return const NotificationTime(
          hour: 12,
          minute: 0,
          source: NotificationTimeSource.defaultTime,
        );
      case PushNotificationType.achievement:
      case PushNotificationType.general:
        return const NotificationTime(
          hour: 12,
          minute: 0,
          source: NotificationTimeSource.defaultTime,
        );
    }
  }

  /// Check if hour is within quiet hours
  bool _isQuietHour(int hour, int quietStart, int quietEnd) {
    if (quietStart < quietEnd) {
      // e.g., 1:00 - 6:00
      return hour >= quietStart && hour < quietEnd;
    } else {
      // e.g., 22:00 - 8:00 (spans midnight)
      return hour >= quietStart || hour < quietEnd;
    }
  }

  /// Set user-preferred notification time
  Future<void> setPreferredNotificationTime(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPreferredTime, hour);
    debugPrint('[Push] Set preferred time: $hour:00');
  }

  /// Set quiet hours
  Future<void> setQuietHours({required int startHour, required int endHour}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyQuietHoursStart, startHour);
    await prefs.setInt(_keyQuietHoursEnd, endHour);
    debugPrint('[Push] Set quiet hours: $startHour:00 - $endHour:00');
  }

  /// Get quiet hours settings
  Future<QuietHours> getQuietHours() async {
    final prefs = await SharedPreferences.getInstance();
    return QuietHours(
      startHour: prefs.getInt(_keyQuietHoursStart) ?? _defaultQuietStart,
      endHour: prefs.getInt(_keyQuietHoursEnd) ?? _defaultQuietEnd,
    );
  }

  /// Check if now is within quiet hours
  Future<bool> isCurrentlyQuietHours() async {
    final quietHours = await getQuietHours();
    final currentHour = DateTime.now().hour;
    return _isQuietHour(currentHour, quietHours.startHour, quietHours.endHour);
  }

  /// Calculate next allowed notification time (respects quiet hours)
  Future<DateTime> getNextAllowedNotificationTime({
    PushNotificationType type = PushNotificationType.general,
  }) async {
    final optimalTime = await getOptimalNotificationTime(type: type);
    final quietHours = await getQuietHours();
    final now = DateTime.now();

    // Create target datetime for today
    var target = DateTime(now.year, now.month, now.day, optimalTime.hour, optimalTime.minute);

    // If target is in the past or during quiet hours, adjust
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    // Ensure not during quiet hours
    while (_isQuietHour(target.hour, quietHours.startHour, quietHours.endHour)) {
      target = target.add(const Duration(hours: 1));
    }

    return target;
  }

  /// Record that a push was sent (for rate limiting)
  Future<void> recordPushSent(PushNotificationType type) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(_keyLastPushSent, now);

    // Update push history
    final historyJson = prefs.getString(_keyPushHistory) ?? '[]';
    final history = List<Map<String, dynamic>>.from(json.decode(historyJson));
    history.add({
      'type': type.name,
      'timestamp': now,
    });
    // Keep last 50 entries
    if (history.length > 50) {
      history.removeRange(0, history.length - 50);
    }
    await prefs.setString(_keyPushHistory, json.encode(history));
  }

  /// Check if we should send a push (rate limiting)
  Future<bool> shouldSendPush({
    required PushNotificationType type,
    Duration minimumInterval = const Duration(hours: 4),
  }) async {
    // Check quiet hours first
    if (await isCurrentlyQuietHours()) {
      debugPrint('[Push] Currently in quiet hours, skipping');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastSentStr = prefs.getString(_keyLastPushSent);

    if (lastSentStr != null) {
      final lastSent = DateTime.tryParse(lastSentStr);
      if (lastSent != null) {
        final timeSince = DateTime.now().difference(lastSent);
        if (timeSince < minimumInterval) {
          debugPrint('[Push] Rate limited: ${timeSince.inMinutes}m since last push');
          return false;
        }
      }
    }

    return true;
  }

  // ===========================================
  // SCHEDULED NOTIFICATION SEQUENCES
  // ===========================================

  /// Schedule onboarding notification sequence (Day 1, 3, 7)
  Future<void> scheduleOnboardingSequence() async {
    if (!isSupported) return;

    debugPrint('[Push] Scheduling onboarding sequence');

    // Day 1: Evening reminder to add expense
    await _scheduleNotification(
      id: 'onboarding_day1',
      title: 'İlk harcamanı ekle!',
      body: 'Bir kahve veya yemek - küçük başla, farkı gör.',
      delay: const Duration(hours: 8),
      type: PushNotificationType.general,
    );

    // Day 3: Value reminder
    await _scheduleNotification(
      id: 'onboarding_day3',
      title: 'Kaç saat çalıştığını biliyor musun?',
      body: 'Harcamalarını saat olarak görmeye devam et.',
      delay: const Duration(days: 3),
      type: PushNotificationType.morningMotivation,
    );

    // Day 7: Streak motivation
    await _scheduleNotification(
      id: 'onboarding_day7',
      title: '7 gün oldu! 🎉',
      body: 'Streak başlatmak için her gün bir harcama ekle.',
      delay: const Duration(days: 7),
      type: PushNotificationType.streakReminder,
    );
  }

  /// Schedule weekly insight notification (Sunday morning)
  Future<void> scheduleWeeklyInsightNotification() async {
    if (!isSupported) return;

    final now = DateTime.now();
    final daysUntilSunday = (DateTime.sunday - now.weekday) % 7;
    final nextSunday = now.add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
    final scheduledTime = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 10, 0);

    await _scheduleNotification(
      id: 'weekly_insight',
      title: 'Haftalık Özet Hazır 📊',
      body: 'Bu hafta ne kadar tasarruf ettin? Hemen kontrol et.',
      scheduledTime: scheduledTime,
      type: PushNotificationType.weeklyInsight,
    );

    debugPrint('[Push] Weekly insight scheduled for: $scheduledTime');
  }

  /// Schedule daily streak reminder (evening)
  Future<void> scheduleDailyStreakReminder({required int currentStreak}) async {
    if (!isSupported) return;

    final optimalTime = await getOptimalNotificationTime(type: PushNotificationType.streakReminder);
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, optimalTime.hour, 0);

    // If time has passed, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    String title;
    String body;

    if (currentStreak == 0) {
      title = 'Yeni bir seri başlat!';
      body = 'Bugün ilk harcamanı ekle ve yolculuğa başla.';
    } else if (currentStreak < 7) {
      title = '$currentStreak günlük serin var!';
      body = 'Bugün de ekle, serini koru.';
    } else if (currentStreak < 30) {
      title = '🔥 $currentStreak gün! Harika gidiyorsun!';
      body = 'Seriyi bozmamak için bugün de ekle.';
    } else {
      title = '🏆 $currentStreak günlük seri!';
      body = 'İnanılmaz bir başarı! Devam et.';
    }

    await _scheduleNotification(
      id: 'streak_reminder',
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      type: PushNotificationType.streakReminder,
    );

    debugPrint('[Push] Streak reminder scheduled for: $scheduledTime');
  }

  /// Schedule morning motivation (9 AM)
  Future<void> scheduleMorningMotivation({
    required double savedThisMonth,
    required String currencySymbol,
  }) async {
    if (!isSupported) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 9, 0);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    String title;
    String body;

    if (savedThisMonth > 0) {
      title = 'Günaydın! ☀️';
      body = 'Bu ay $currencySymbol${savedThisMonth.toStringAsFixed(0)} tasarruf ettin. Devam!';
    } else {
      title = 'Günaydın! ☀️';
      body = 'Bugün bir harcama ekleyerek finansal farkındalığını artır.';
    }

    await _scheduleNotification(
      id: 'morning_motivation',
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      type: PushNotificationType.morningMotivation,
    );
  }

  /// Internal method to schedule a notification
  Future<void> _scheduleNotification({
    required String id,
    required String title,
    required String body,
    Duration? delay,
    DateTime? scheduledTime,
    required PushNotificationType type,
  }) async {
    if (!isSupported) return;

    final targetTime = scheduledTime ?? DateTime.now().add(delay ?? Duration.zero);

    // Check quiet hours
    final quietHours = await getQuietHours();
    if (_isQuietHour(targetTime.hour, quietHours.startHour, quietHours.endHour)) {
      debugPrint('[Push] Notification $id would be during quiet hours, adjusting');
      // Adjust to next morning
      final adjusted = DateTime(
        targetTime.year,
        targetTime.month,
        targetTime.day,
        quietHours.endHour,
        0,
      );
      debugPrint('[Push] Adjusted time: $adjusted');
    }

    // Note: Actual scheduling would use flutter_local_notifications or FCM
    debugPrint('[Push] Schedule: $id at $targetTime - $title');
  }

  // ===========================================
  // RE-ENGAGEMENT NOTIFICATIONS
  // ============================================

  /// Schedule re-engagement notification for stalled users
  Future<void> scheduleReengagementNotification({
    required int daysSinceActive,
  }) async {
    if (!isSupported) return;

    // Push message varies based on inactivity period
    String title;
    String body;

    if (daysSinceActive <= 3) {
      title = 'Harcamalarını takip etmeyi unutma!';
      body = 'Bugün ne kadar tasarruf ettin? Hemen gir ve gör.';
    } else if (daysSinceActive <= 5) {
      title = 'Seni özledik! 👋';
      body = 'Finansal hedeflerine ulaşmak için devam et.';
    } else {
      title = 'Geri dön, serinin bozulmasın!';
      body = 'Streak\'ini kaybetme, hemen bir harcama ekle.';
    }

    // Note: Actual scheduling would use FirebaseMessaging on mobile
    // This logs the intent for now
    debugPrint('[Push] Schedule re-engagement: $title - $body (days: $daysSinceActive)');
  }

  /// Schedule urgent re-engagement for critical users (7+ days inactive)
  Future<void> scheduleUrgentReengagementNotification({
    required int daysSinceActive,
  }) async {
    if (!isSupported) return;

    String title;
    String body;

    if (daysSinceActive <= 10) {
      title = 'Finansal kontrolün elden kaçmasın!';
      body = 'Bir hafta oldu, harcamalarını güncelle.';
    } else if (daysSinceActive <= 14) {
      title = 'Hedeflerine ulaşmak hâlâ mümkün!';
      body = 'Geri dön ve nereden kaldığına bak.';
    } else {
      title = 'Vantag seni bekliyor!';
      body = 'Tek bir harcama ekleyerek yeniden başla.';
    }

    debugPrint('[Push] Schedule urgent re-engagement: $title - $body (days: $daysSinceActive)');
  }

  /// Schedule streak reminder (evening)
  Future<void> scheduleStreakReminder({
    required int currentStreak,
  }) async {
    if (!isSupported) return;

    final title = '$currentStreak günlük serin var!';
    const body = 'Bugünkü harcamanı ekleyerek serini koru.';

    debugPrint('[Push] Schedule streak reminder: $title - $body');
  }

  /// Schedule milestone celebration push
  Future<void> scheduleMilestoneCelebration({
    required String milestoneName,
    required String message,
  }) async {
    if (!isSupported) return;

    debugPrint('[Push] Schedule milestone: $milestoneName - $message');
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
  static const String streakReminders = 'streak_reminders';
  static const String morningMotivation = 'morning_motivation';
  static const String reengagement = 'reengagement';
}

/// Notification types for timing optimization
enum PushNotificationType {
  general,
  streakReminder,
  morningMotivation,
  weeklyInsight,
  reengagement,
  achievement,
}

/// Source of notification time calculation
enum NotificationTimeSource {
  userPreferred,
  learned,
  defaultTime,
}

/// Notification time model
class NotificationTime {
  final int hour;
  final int minute;
  final NotificationTimeSource source;

  const NotificationTime({
    required this.hour,
    required this.minute,
    required this.source,
  });

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ($source)';
}

/// Quiet hours model
class QuietHours {
  final int startHour;
  final int endHour;

  const QuietHours({
    required this.startHour,
    required this.endHour,
  });

  @override
  String toString() => '${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00';
}

/// Push notification schedule item
class ScheduledNotification {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final PushNotificationType type;
  final bool sent;

  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.type,
    this.sent = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'scheduledTime': scheduledTime.toIso8601String(),
    'type': type.name,
    'sent': sent,
  };

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) {
    return ScheduledNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      type: PushNotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PushNotificationType.general,
      ),
      sent: json['sent'] as bool? ?? false,
    );
  }
}
