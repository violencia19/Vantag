import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../utils/currency_utils.dart';

// ============================================
// BİLDİRİM TÜRLERİ
// ============================================

enum NotificationType {
  delayedAwareness, // Gecikmiş farkındalık (aldım sonrası)
  reinforceDecision, // Vazgeçmeyi güçlendirme
  streakReminder, // Streak hatırlatma
  weeklyInsight, // Haftalık içgörü
  subscriptionReminder, // Abonelik yenileme hatırlatma
}

// ============================================
// BİLDİRİM MESAJ HAVUZLARI
// ============================================

class NotificationMessages {
  static final _random = Random();

  // Gecikmiş Farkındalık (Aldım sonrası 6-12 saat) - 10-20 kelime
  static const delayedAwareness = [
    'Bugün aldığın şey hala aynı heyecanı veriyor mu, yoksa heves geçti mi?',
    'Aldığın ürünü kullandın mı? Beklentilerini karşıladı mı merak ediyoruz.',
    'O alışveriş beklediğin gibi miydi? Bir an düşün ve değerlendir.',
    'Aradan saatler geçti. Hala memnun musun aldığın şeyle?',
    'Düşündüğün kadar gerekli miymiş? Şimdi geriye bakınca ne hissediyorsun?',
    'Aynı kararı tekrar verir miydin? Bir düşün, cevabını kendin bil.',
    'O ürün hayatına gerçek bir değer kattı mı, yoksa sadece anlık bir hevesti?',
    'Peki şimdi nasıl hissediyorsun? O para iyi harcanmış gibi mi geliyor?',
    'Aldığın şey beklentini karşıladı mı? Yoksa hayal kırıklığı mı yaşadın?',
    'Tekrar düşünsen yine alır mıydın? Cevabın sana çok şey söyleyecek.',
    'Birkaç saat önce harcadığın para, şimdi hala iyi bir karar gibi mi görünüyor?',
    'Aldığın şeyi ne kadar kullandın? Gerçekten ihtiyacın var mıydı?',
  ];

  // Vazgeçmeyi Güçlendirme (aynı gün) - 10-20 kelime
  static const reinforceDecision = [
    'Bugün kendin için iyi bir karar verdin. O para şimdi seninle kalıyor.',
    'Bir adım geri atabilmek güç ister. Bunu başardığın için kendini kutla.',
    'O parayı cebinde tutmayı başardın. Gelecekte bunun için teşekkür edeceksin.',
    'Dürtülerine karşı koydun, tebrikler. Bu küçük zaferler büyük farklar yaratır.',
    'Gelecekteki sen bugün için minnettardır. Akıllı bir karar verdin.',
    'Gereksiz bir harcamayı önledin. Bu paranı daha önemli şeylere ayırabilirsin.',
    'Bugün irade kazandı. Her vazgeçiş, finansal özgürlüğe bir adım daha yaklaştırır.',
    'Kolay olan almaktı, zor olanı seçtin. Bu karakter gücü göstergesi.',
    'Her hayır, geleceğine evet demektir. Bugün kendine yatırım yaptın.',
    'Kurtardığın her kuruş bir kazançtır. Küçük adımlar büyük sonuçlar doğurur.',
    'Bugün akıllıca davrandın. Bilinçli tüketici olma yolunda ilerliyorsun.',
    'Kontrolü elinde tuttun. Paraya değil, para sana hizmet etmeli.',
    'Paranın değerini biliyorsun. Bu farkındalık seni öne taşıyacak.',
  ];

  // Streak Hatırlatma (akşam, giriş yoksa) - 10-20 kelime
  static const streakReminder = [
    'Bugünkü zinciri koparmamak ister misin? Birkaç dakikan yeterli, serin devam etsin.',
    'Serilerin devam etmek için seni bekliyor. Gün bitmeden bir kayıt eklemeyi unutma.',
    'Günü kaydetmeden bitirme. O kadar emek verdikten sonra seriyi kaybetme.',
    'Bugün henüz bir şey girmedin. Küçük bir kayıt bile serin için yeterli.',
    'Serin tehlikede, bir göz at. Birkaç saniyeni ayırıp günü kaydet.',
    'Günlük alışkanlığını unutma. Her gün takip etmek başarının anahtarı.',
    'Bugün de kayıt tutmak ister misin? Düzenli takip, bilinçli harcamanın ilk adımı.',
    'Seriyi sürdürmek için son şans. Gece olmadan bir giriş yap.',
    'Bir dakikanı ayır, günü kaydet. O kadar güzel gidiyordun, devam et.',
    'Bugünü atlamamak için hatırlatma. Süreklilik, değişimin temelidir.',
    'Streak bozulmadan önce gel. Emeklerini boşa çıkarma.',
    'Gün bitmeden bir kayıt ekle. Yarın için bu alışkanlığı sürdür.',
  ];

  // Abonelik Yenileme Hatırlatma - 10-20 kelime
  static const subscriptionReminder = [
    '{name} aboneliğin yarın yenileniyor. {amount} TL hesabından çekilecek.',
    'Yarın {name} için {amount} TL ödenecek. Hazırlıklı ol!',
    '{name} yenileme günü yarın. {amount} TL otomatik çekilecek.',
    'Hatırlatma: {name} aboneliğin yarın {amount} TL ile yenilenecek.',
    'Yarın {amount} TL tutarında {name} ödemesi var. Bakiyeni kontrol et.',
  ];

  static String getSubscriptionReminderMessage(String name, double amount) {
    final template =
        subscriptionReminder[_random.nextInt(subscriptionReminder.length)];
    return template
        .replaceAll('{name}', name)
        .replaceAll(
          '{amount}',
          formatTurkishCurrency(amount, decimalDigits: 2),
        );
  }

  // Maaş Günü (Payday) - Kutlama mesajları
  static const paydayMessages = [
    'Bugün maaş günü! 💰 Bütçeni kontrol etmek için harika bir gün.',
    'Maaş yattı mı? Bütçeni planlamak için uygulamayı ziyaret et!',
    'Günaydın! Bugün hesabını kontrol etmeyi unutma. 💳',
    'Aylık gelirin hesabında! Hedeflerine yatırım yapmayı düşün.',
    'Maaş gününde küçük bir hatırlatma: Tasarruf hedefini gözden geçir!',
  ];

  static String getPaydayMessage() {
    return paydayMessages[_random.nextInt(paydayMessages.length)];
  }

  // Haftalık Mini İçgörü - 10-20 kelime
  static const weeklyInsightTemplates = [
    'Bu hafta en çok {category} kategorisinde düşündün. Belki bu alanda dikkatli olmalısın.',
    'Geçen hafta {count} kez vazgeçip {amount} TL kurtardın. Harika bir başarı!',
    'Bu hafta {category} için en çok zaman harcadın. Bu kategoriyi gözden geçirmeli misin?',
    '{days} günlük serin devam ediyor, harika gidiyorsun. Böyle devam et!',
    'Bu hafta ortalama {hours} saatlik işler için düşündün. Büyük kararlar veriyorsun.',
    'Geçen haftaya göre daha tutumlu davrandın. İlerleme kaydediyorsun, tebrikler!',
    'Bu hafta {count} harcama girdin. Her kayıt bilinçli harcama yolunda bir adım.',
    'En uzun düşünme süren {category} kategorisindeydi. Zor kararlarla yüzleşiyorsun.',
    'Bu hafta toplamda {amount} TL kaydettin. Bu para geleceğin için çalışıyor.',
    'Haftalık ortalamanın üzerinde kurtardın. Kendi rekorunu kırıyorsun!',
  ];

  static String getRandomMessage(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  static String getWeeklyInsight({
    String? topCategory,
    int? savedCount,
    double? savedAmount,
    int? streakDays,
    double? avgHours,
    int? totalCount,
  }) {
    final template =
        weeklyInsightTemplates[_random.nextInt(weeklyInsightTemplates.length)];

    return template
        .replaceAll('{category}', topCategory ?? 'genel')
        .replaceAll('{count}', (savedCount ?? 0).toString())
        .replaceAll(
          '{amount}',
          formatTurkishCurrency(savedAmount ?? 0, decimalDigits: 2),
        )
        .replaceAll('{days}', (streakDays ?? 0).toString())
        .replaceAll('{hours}', (avgHours ?? 0).toStringAsFixed(1));
  }
}

// ============================================
// BİLDİRİM SERVİSİ
// ============================================

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Bildirim ID'leri
  static const _idDelayedAwareness = 1;
  static const _idReinforceDecision = 2;
  static const _idStreakReminder = 3;
  static const _idWeeklyInsight = 4;
  // Trial notification IDs (5-9)
  static const _idTrialMidpoint = 5;
  static const _idTrialOneDayLeft = 6;
  static const _idTrialEndsToday = 7;
  static const _idTrialExpired = 8;
  static const _idFirstExpense = 9;
  // Daily reminder
  static const _idDailyReminder = 10;
  // Payday notification
  static const _idPayday = 11;
  static const _idSubscriptionBase = 100; // Abonelikler için 100+ ID

  // Pref keys
  static const _keyLastReinforceDate = 'notif_last_reinforce_date';
  static const _keyNotificationsEnabled = 'notif_enabled';
  static const _keyDelayedAwarenessEnabled = 'notif_delayed_awareness';
  static const _keyReinforceEnabled = 'notif_reinforce';
  static const _keyStreakReminderEnabled = 'notif_streak_reminder';
  static const _keyWeeklyInsightEnabled = 'notif_weekly_insight';
  static const _keySubscriptionReminderEnabled = 'notif_subscription_reminder';
  // Trial & daily reminder keys
  static const _keyTrialReminderEnabled = 'notif_trial_reminder';
  static const _keyDailyReminderEnabled = 'notif_daily_reminder';
  static const _keyDailyReminderHour = 'notif_daily_reminder_hour';
  static const _keyDailyReminderMinute = 'notif_daily_reminder_minute';
  static const _keyTrialStartDate = 'notif_trial_start_date';
  static const _keyTrialDays = 'notif_trial_days';
  // Payday notification
  static const _keyPaydayReminderEnabled = 'notif_payday_reminder';

  /// Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Timezone başlat
    tz_data.initializeTimeZones();

    // Android ayarları
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS ayarları
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Windows ayarları
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Vantag',
      appUserModelId: 'com.vantag.app',
      guid: 'd49b0314-ee7b-4e96-8bc3-d8456a7dc348',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      windows: windowsSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Bildirimlere tıklandığında yapılacak işlemler
  }

  /// İzin iste
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true; // Windows, macOS vs.
  }

  // ============================================
  // ZAMAN KONTROL
  // ============================================

  /// Bir sonraki uygun saati hesapla
  DateTime _getNextAvailableTime(DateTime desiredTime) {
    if (desiredTime.hour >= 22) {
      // Ertesi gün 08:00
      return DateTime(
        desiredTime.year,
        desiredTime.month,
        desiredTime.day + 1,
        8,
        0,
      );
    } else if (desiredTime.hour < 8) {
      // Aynı gün 08:00
      return DateTime(
        desiredTime.year,
        desiredTime.month,
        desiredTime.day,
        8,
        0,
      );
    }
    return desiredTime;
  }

  // ============================================
  // 1. GECİKMELİ FARKINDALIK BİLDİRİMİ
  // ============================================

  /// Yüksek tutarlı "Aldım" kararı sonrası bildirim planla
  Future<void> scheduleDelayedAwareness({
    required double amount,
    required int currentStreak,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Ayar kontrolü
    if (!(prefs.getBool(_keyNotificationsEnabled) ?? true)) return;
    if (!(prefs.getBool(_keyDelayedAwarenessEnabled) ?? true)) return;

    // Sadece yüksek tutarlar veya düşük streak
    final isHighAmount = amount >= 500; // 500 TL üstü
    final isLowStreak = currentStreak < 3;

    if (!isHighAmount && !isLowStreak) return;

    // 6-12 saat sonra veya ertesi sabah
    final random = Random();
    final hoursDelay = 6 + random.nextInt(7); // 6-12 saat
    var scheduledTime = DateTime.now().add(Duration(hours: hoursDelay));

    // Gece kontrolü
    scheduledTime = _getNextAvailableTime(scheduledTime);

    final message = NotificationMessages.getRandomMessage(
      NotificationMessages.delayedAwareness,
    );

    await _scheduleNotification(
      id: _idDelayedAwareness,
      title: 'Bir düşün',
      body: message,
      scheduledTime: scheduledTime,
    );
  }

  // ============================================
  // 2. VAZGEÇMEYİ GÜÇLENDİRME BİLDİRİMİ
  // ============================================

  /// "Vazgeçtim" kararı sonrası aynı gün bildirim
  Future<void> scheduleReinforceDecision() async {
    final prefs = await SharedPreferences.getInstance();

    // Ayar kontrolü
    if (!(prefs.getBool(_keyNotificationsEnabled) ?? true)) return;
    if (!(prefs.getBool(_keyReinforceEnabled) ?? true)) return;

    // Günde maksimum 1 kez
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastDate = prefs.getString(_keyLastReinforceDate);

    if (lastDate == todayStr) {
      return;
    }

    // 2-4 saat sonra
    final random = Random();
    final hoursDelay = 2 + random.nextInt(3);
    var scheduledTime = DateTime.now().add(Duration(hours: hoursDelay));

    // Gece kontrolü
    if (scheduledTime.hour >= 22) {
      return; // Bugün göndermiyoruz
    }

    final message = NotificationMessages.getRandomMessage(
      NotificationMessages.reinforceDecision,
    );

    await _scheduleNotification(
      id: _idReinforceDecision,
      title: 'Tebrikler',
      body: message,
      scheduledTime: scheduledTime,
    );

    await prefs.setString(_keyLastReinforceDate, todayStr);
  }

  // ============================================
  // 3. STREAK HATIRLATMA BİLDİRİMİ
  // ============================================

  /// Streak varsa ama bugün giriş yoksa akşam hatırlat
  Future<void> scheduleStreakReminder({
    required int currentStreak,
    required DateTime? lastEntryDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Ayar kontrolü
    if (!(prefs.getBool(_keyNotificationsEnabled) ?? true)) return;
    if (!(prefs.getBool(_keyStreakReminderEnabled) ?? true)) return;

    // Streak yoksa hatırlatma yapma
    if (currentStreak == 0) return;

    // Bugün zaten giriş yapıldıysa hatırlatma yapma
    if (lastEntryDate != null) {
      final today = DateTime.now();
      if (lastEntryDate.year == today.year &&
          lastEntryDate.month == today.month &&
          lastEntryDate.day == today.day) {
        await cancel(_idStreakReminder);
        return;
      }
    }

    // Akşam 20:00'da hatırlat
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 20, 0);

    // Saat geçtiyse hatırlatma yapma
    if (scheduledTime.isBefore(now)) {
      return;
    }

    final message = NotificationMessages.getRandomMessage(
      NotificationMessages.streakReminder,
    );

    await _scheduleNotification(
      id: _idStreakReminder,
      title: 'Serin bekliyor',
      body: message,
      scheduledTime: scheduledTime,
    );
  }

  /// Streak hatırlatmasını iptal et (giriş yapıldığında)
  Future<void> cancelStreakReminder() async {
    await cancel(_idStreakReminder);
  }

  // ============================================
  // 4. HAFTALIK MİNİ İÇGÖRÜ
  // ============================================

  /// Haftalık içgörü bildirimi planla (Pazar 18:00)
  Future<void> scheduleWeeklyInsight({
    String? topCategory,
    int? savedCount,
    double? savedAmount,
    int? streakDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Ayar kontrolü
    if (!(prefs.getBool(_keyNotificationsEnabled) ?? true)) return;
    if (!(prefs.getBool(_keyWeeklyInsightEnabled) ?? true)) return;

    // Bir sonraki Pazar 18:00
    final now = DateTime.now();
    var daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday <= 0) daysUntilSunday += 7;

    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day + daysUntilSunday,
      18,
      0,
    );

    final message = NotificationMessages.getWeeklyInsight(
      topCategory: topCategory,
      savedCount: savedCount,
      savedAmount: savedAmount,
      streakDays: streakDays,
    );

    await _scheduleNotification(
      id: _idWeeklyInsight,
      title: 'Haftalık özet',
      body: message,
      scheduledTime: scheduledTime,
    );
  }

  // ============================================
  // 5. ABONELİK YENİLEME HATIRLATMASI
  // ============================================

  /// Yarın yenilenecek abonelikler için bildirim planla
  Future<void> scheduleSubscriptionReminders(
    List<({String id, String name, double amount})> subscriptions,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Ayar kontrolü
    if (!(prefs.getBool(_keyNotificationsEnabled) ?? true)) return;
    if (!(prefs.getBool(_keySubscriptionReminderEnabled) ?? true)) return;

    // Ertesi gün sabah 09:00'da bildirim
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9, 0);

    for (var i = 0; i < subscriptions.length; i++) {
      final sub = subscriptions[i];
      final message = NotificationMessages.getSubscriptionReminderMessage(
        sub.name,
        sub.amount,
      );

      // Her abonelik için benzersiz ID
      final notificationId = _idSubscriptionBase + i;

      await _scheduleNotification(
        id: notificationId,
        title: 'Abonelik hatırlatma',
        body: message,
        scheduledTime: tomorrow,
      );
    }
  }

  /// Tüm abonelik bildirimlerini iptal et
  Future<void> cancelSubscriptionReminders() async {
    // 100'den 200'e kadar olan ID'leri iptal et
    for (var i = _idSubscriptionBase; i < _idSubscriptionBase + 100; i++) {
      await cancel(i);
    }
  }

  // ============================================
  // 6. TRIAL HATIRLATMA BİLDİRİMLERİ
  // ============================================

  /// Trial bildirimleri planla
  /// trialDays: 7 (referral) veya 3 (normal)
  Future<void> scheduleTrialNotifications({
    required DateTime trialStartDate,
    required int trialDays,
    String? totalSavedHours,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Ayar kontrolü
    if (!(prefs.getBool(_keyNotificationsEnabled) ?? true)) return;
    if (!(prefs.getBool(_keyTrialReminderEnabled) ?? true)) return;

    // Trial bilgilerini kaydet (daha sonra kontrol için)
    await prefs.setString(_keyTrialStartDate, trialStartDate.toIso8601String());
    await prefs.setInt(_keyTrialDays, trialDays);

    final trialEndDate = trialStartDate.add(Duration(days: trialDays));
    final midpoint = trialStartDate.add(Duration(days: trialDays ~/ 2));
    final oneDayBefore = trialEndDate.subtract(const Duration(days: 1));
    final oneDayAfter = trialEndDate.add(const Duration(days: 1));

    final now = DateTime.now();
    final hours = totalSavedHours ?? '0';

    // Midpoint reminder (trial'ın yarısında)
    if (midpoint.isAfter(now)) {
      final midpointTime = DateTime(
        midpoint.year,
        midpoint.month,
        midpoint.day,
        12,
        0,
      );
      await _scheduleNotification(
        id: _idTrialMidpoint,
        title: 'Yarı yoldasın! ⏳',
        body: 'Deneme süren yarılandı. Şu ana kadar $hours saat biriktirdin!',
        scheduledTime: _getNextAvailableTime(midpointTime),
        channelId: 'trial_channel',
        channelName: 'Trial Reminders',
      );
    }

    // 1 day before end
    if (oneDayBefore.isAfter(now)) {
      final oneDayBeforeTime = DateTime(
        oneDayBefore.year,
        oneDayBefore.month,
        oneDayBefore.day,
        10,
        0,
      );
      await _scheduleNotification(
        id: _idTrialOneDayLeft,
        title: 'Denemen yarın bitiyor ⏰',
        body: 'Premium\'a geç, biriktirmeye devam et!',
        scheduledTime: _getNextAvailableTime(oneDayBeforeTime),
        channelId: 'trial_channel',
        channelName: 'Trial Reminders',
      );
    }

    // Trial end day
    if (trialEndDate.isAfter(now)) {
      final endDayTime = DateTime(
        trialEndDate.year,
        trialEndDate.month,
        trialEndDate.day,
        10,
        0,
      );
      await _scheduleNotification(
        id: _idTrialEndsToday,
        title: 'Denemenin son günü! 🎁',
        body: 'Bugün geçersen %50 indirim!',
        scheduledTime: _getNextAvailableTime(endDayTime),
        channelId: 'trial_channel',
        channelName: 'Trial Reminders',
      );
    }

    // 1 day after (win-back)
    if (oneDayAfter.isAfter(now)) {
      final dayAfterTime = DateTime(
        oneDayAfter.year,
        oneDayAfter.month,
        oneDayAfter.day,
        18,
        0,
      );
      await _scheduleNotification(
        id: _idTrialExpired,
        title: 'Seni özledik! 💜',
        body: 'Geri dön, hedeflerine devam et',
        scheduledTime: _getNextAvailableTime(dayAfterTime),
        channelId: 'trial_channel',
        channelName: 'Trial Reminders',
      );
    }
  }

  /// Trial bildirimlerini iptal et (kullanıcı premium'a geçtiğinde)
  Future<void> cancelTrialNotifications() async {
    await cancel(_idTrialMidpoint);
    await cancel(_idTrialOneDayLeft);
    await cancel(_idTrialEndsToday);
    await cancel(_idTrialExpired);
  }

  /// Trial'ın kalan günlerini hesapla
  Future<int?> getTrialDaysRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateStr = prefs.getString(_keyTrialStartDate);
    final trialDays = prefs.getInt(_keyTrialDays);

    if (startDateStr == null || trialDays == null) return null;

    final startDate = DateTime.parse(startDateStr);
    final endDate = startDate.add(Duration(days: trialDays));
    final remaining = endDate.difference(DateTime.now()).inDays;

    return remaining > 0 ? remaining : 0;
  }

  // ============================================
  // 7. İLK HARCAMA KUTLAMASI
  // ============================================

  /// İlk harcama sonrası kutlama bildirimi
  Future<void> scheduleFirstExpenseCelebration({
    required String savedHours,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Ayar kontrolü
    if (!(prefs.getBool(_keyNotificationsEnabled) ?? true)) return;

    // 2-4 saat sonra
    final random = Random();
    final hoursDelay = 2 + random.nextInt(3);
    var scheduledTime = DateTime.now().add(Duration(hours: hoursDelay));

    // Gece kontrolü
    scheduledTime = _getNextAvailableTime(scheduledTime);

    await _scheduleNotification(
      id: _idFirstExpense,
      title: 'Harika başlangıç! 🎉',
      body: 'Bugün $savedHours saat biriktirdin!',
      scheduledTime: scheduledTime,
    );
  }

  // ============================================
  // 8. GÜNLÜK HATIRLATMA
  // ============================================

  /// Günlük hatırlatma planla
  Future<void> scheduleDailyReminder({int hour = 20, int minute = 0}) async {
    final prefs = await SharedPreferences.getInstance();

    // Ayar kontrolü
    if (!(prefs.getBool(_keyNotificationsEnabled) ?? true)) return;
    if (!(prefs.getBool(_keyDailyReminderEnabled) ?? false)) return;

    // Windows ve Linux'ta desteklenmiyor
    if (Platform.isWindows || Platform.isLinux) return;

    // Saati kaydet
    await prefs.setInt(_keyDailyReminderHour, hour);
    await prefs.setInt(_keyDailyReminderMinute, minute);

    // Bir sonraki hatırlatma zamanını hesapla
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // Saat geçtiyse yarına planla
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Günlük Hatırlatmalar',
      channelDescription: 'Günlük harcama girişi hatırlatmaları',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const darwinDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      // Her gün tekrarlayan bildirim
      await _notifications.zonedSchedule(
        _idDailyReminder,
        'Harcamalarını girmeyi unutma! 📝',
        'Bugünkü harcamalarını saniyeler içinde gir',
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Her gün aynı saatte
      );
    } on UnimplementedError {
      // Platform desteklemiyor
    }
  }

  /// Günlük hatırlatmayı iptal et
  Future<void> cancelDailyReminder() async {
    await cancel(_idDailyReminder);
  }

  // ============================================
  // 9. MAAŞ GÜNÜ HATIRLATMASI
  // ============================================

  /// Maaş günü bildirimi planla
  /// [salaryDay]: Ayın günü (1-31)
  Future<void> schedulePaydayNotification({required int salaryDay}) async {
    final prefs = await SharedPreferences.getInstance();

    // Ayar kontrolü
    if (!(prefs.getBool(_keyNotificationsEnabled) ?? true)) return;
    if (!(prefs.getBool(_keyPaydayReminderEnabled) ?? true)) return;

    // Windows ve Linux'ta desteklenmiyor
    if (Platform.isWindows || Platform.isLinux) return;

    // Sonraki maaş gününü hesapla
    final now = DateTime.now();
    DateTime nextPayday;

    if (now.day < salaryDay) {
      // Bu ayın maaş günü henüz gelmedi
      nextPayday = DateTime(now.year, now.month, salaryDay, 9, 0);
    } else {
      // Gelecek ayın maaş günü
      nextPayday = DateTime(now.year, now.month + 1, salaryDay, 9, 0);
    }

    // Gece kontrolü - sabah 09:00'da gönder
    nextPayday = _getNextAvailableTime(nextPayday);

    final message = NotificationMessages.getPaydayMessage();

    final androidDetails = AndroidNotificationDetails(
      'payday_channel',
      'Maaş Günü',
      channelDescription: 'Maaş günü hatırlatmaları',
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      // Her ay aynı günde tekrarlayan bildirim
      await _notifications.zonedSchedule(
        _idPayday,
        'Maaş Günü! 💰',
        message,
        tz.TZDateTime.from(nextPayday, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents:
            DateTimeComponents.dayOfMonthAndTime, // Ayın aynı gününde
      );
    } on UnimplementedError {
      // Platform desteklemiyor
    }
  }

  /// Maaş günü bildirimini iptal et
  Future<void> cancelPaydayNotification() async {
    await cancel(_idPayday);
  }

  /// Maaş günü hatırlatması aktif mi?
  Future<bool> isPaydayReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPaydayReminderEnabled) ?? true;
  }

  /// Günlük hatırlatma saatini al
  Future<({int hour, int minute})?> getDailyReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_keyDailyReminderHour);
    final minute = prefs.getInt(_keyDailyReminderMinute);

    if (hour == null) return null;
    return (hour: hour, minute: minute ?? 0);
  }

  /// Günlük hatırlatma aktif mi?
  Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDailyReminderEnabled) ?? false;
  }

  /// Trial hatırlatması aktif mi?
  Future<bool> isTrialReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTrialReminderEnabled) ?? true;
  }

  // ============================================
  // YARDIMCI METODLAR
  // ============================================

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String channelId = 'vantag_channel',
    String channelName = 'Vantag Bildirimleri',
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
  }) async {
    // Windows ve Linux'ta zamanlanmış bildirimler desteklenmiyor
    if (Platform.isWindows || Platform.isLinux) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Finansal takip bildirimleri',
      importance: importance,
      priority: priority,
      styleInformation: BigTextStyleInformation(body),
    );

    const darwinDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on UnimplementedError {
      // Platform desteklemiyor
    }
  }

  /// Tüm bildirimleri iptal et
  Future<void> cancelAll() async {
    if (Platform.isWindows || Platform.isLinux) return;
    try {
      await _notifications.cancelAll();
    } on UnimplementedError {
      // Windows/Linux'ta desteklenmiyor
    }
  }

  /// Belirli bildirimi iptal et
  Future<void> cancel(int id) async {
    if (Platform.isWindows || Platform.isLinux) return;
    try {
      await _notifications.cancel(id);
    } on UnimplementedError {
      // Windows/Linux'ta desteklenmiyor
    }
  }

  // ============================================
  // AYARLAR
  // ============================================

  /// Bildirimlerin açık olup olmadığını kontrol et
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  /// Tüm bildirimleri aç/kapat
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);

    if (!enabled) {
      await cancelAll();
    }
  }

  /// Bildirim ayarlarını getir
  Future<Map<String, bool>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_keyNotificationsEnabled) ?? true,
      'delayedAwareness': prefs.getBool(_keyDelayedAwarenessEnabled) ?? true,
      'reinforce': prefs.getBool(_keyReinforceEnabled) ?? true,
      'streakReminder': prefs.getBool(_keyStreakReminderEnabled) ?? true,
      'weeklyInsight': prefs.getBool(_keyWeeklyInsightEnabled) ?? true,
      'subscriptionReminder':
          prefs.getBool(_keySubscriptionReminderEnabled) ?? true,
      'trialReminder': prefs.getBool(_keyTrialReminderEnabled) ?? true,
      'dailyReminder': prefs.getBool(_keyDailyReminderEnabled) ?? false,
      'paydayReminder': prefs.getBool(_keyPaydayReminderEnabled) ?? true,
    };
  }

  /// Bildirim ayarını güncelle
  Future<void> updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();

    final prefKey = switch (key) {
      'enabled' => _keyNotificationsEnabled,
      'delayedAwareness' => _keyDelayedAwarenessEnabled,
      'reinforce' => _keyReinforceEnabled,
      'streakReminder' => _keyStreakReminderEnabled,
      'weeklyInsight' => _keyWeeklyInsightEnabled,
      'subscriptionReminder' => _keySubscriptionReminderEnabled,
      'trialReminder' => _keyTrialReminderEnabled,
      'dailyReminder' => _keyDailyReminderEnabled,
      'paydayReminder' => _keyPaydayReminderEnabled,
      _ => null,
    };

    if (prefKey != null) {
      await prefs.setBool(prefKey, value);

      if (key == 'enabled' && !value) {
        await cancelAll();
      } else if (key == 'trialReminder' && !value) {
        await cancelTrialNotifications();
      } else if (key == 'dailyReminder' && !value) {
        await cancelDailyReminder();
      } else if (key == 'dailyReminder' && value) {
        // Re-schedule with saved time
        final time = await getDailyReminderTime();
        await scheduleDailyReminder(
          hour: time?.hour ?? 20,
          minute: time?.minute ?? 0,
        );
      } else if (key == 'paydayReminder' && !value) {
        await cancelPaydayNotification();
      }
    }
  }

  /// Varsayılan ayarları oluştur (ilk kurulum)
  Future<void> initializeDefaultSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_keyNotificationsEnabled)) {
      await prefs.setBool(_keyNotificationsEnabled, true);
      await prefs.setBool(_keyDelayedAwarenessEnabled, true);
      await prefs.setBool(_keyReinforceEnabled, true);
      await prefs.setBool(_keyStreakReminderEnabled, true);
      await prefs.setBool(_keyWeeklyInsightEnabled, true);
      await prefs.setBool(_keySubscriptionReminderEnabled, true);
      await prefs.setBool(_keyTrialReminderEnabled, true);
      await prefs.setBool(_keyPaydayReminderEnabled, true);
      await prefs.setBool(_keyDailyReminderEnabled, false); // Off by default
    }
  }
}
