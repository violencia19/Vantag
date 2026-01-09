import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Discovery Tour yönetim servisi
class TourService {
  static const _keyHasSeenTour = 'has_seen_tour';
  static const _keyTourVersion = 'tour_version';

  // Tur versiyonu - yeni özellikler eklenince artırılır
  static const int currentTourVersion = 1;

  /// Kullanıcı turu daha önce gördü mü?
  static Future<bool> hasSeenTour() async {
    final prefs = await SharedPreferences.getInstance();
    final seenVersion = prefs.getInt(_keyTourVersion) ?? 0;
    return seenVersion >= currentTourVersion;
  }

  /// Turu tamamlandı olarak işaretle
  static Future<void> markTourComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenTour, true);
    await prefs.setInt(_keyTourVersion, currentTourVersion);
  }

  /// Tur durumunu sıfırla (ayarlardan tekrar başlatmak için)
  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasSeenTour);
    await prefs.setInt(_keyTourVersion, 0);
  }
}

/// Tour GlobalKey'leri
class TourKeys {
  // Expense Screen
  static final amountField = GlobalKey();
  static final descriptionField = GlobalKey();
  static final categoryField = GlobalKey();
  static final dateChips = GlobalKey();
  static final calculateButton = GlobalKey();

  // Main Screen - Nav Bar
  static final navBarExpense = GlobalKey();
  static final navBarReport = GlobalKey();
  static final navBarAchievements = GlobalKey();
  static final navBarProfile = GlobalKey();
  static final navBarAddButton = GlobalKey();

  // Header
  static final streakWidget = GlobalKey();
  static final subscriptionButton = GlobalKey();

  // Financial Snapshot
  static final financialSnapshot = GlobalKey();

  // Currency Rates
  static final currencyRates = GlobalKey();
}

/// Tour adımı bilgisi
class TourStep {
  final GlobalKey key;
  final String title;
  final String description;
  final ShapeBorder? shapeBorder;

  const TourStep({
    required this.key,
    required this.title,
    required this.description,
    this.shapeBorder,
  });
}

/// Tour adımları listesi
class TourSteps {
  static List<TourStep> get all => [
    TourStep(
      key: TourKeys.amountField,
      title: 'Tutar Girişi',
      description: 'Harcama tutarını buraya gir. Fiş tarama butonu ile fişten otomatik okuyabilirsin.',
    ),
    TourStep(
      key: TourKeys.descriptionField,
      title: 'Akıllı Eşleştirme',
      description: 'Mağaza veya ürün adını yaz. Migros, A101, Starbucks gibi... Uygulama otomatik olarak kategori önericek!',
    ),
    TourStep(
      key: TourKeys.categoryField,
      title: 'Kategori Seçimi',
      description: 'Akıllı eşleştirme bulamazsa veya düzeltmek istersen buradan manuel seçim yapabilirsin.',
    ),
    TourStep(
      key: TourKeys.dateChips,
      title: 'Geçmiş Tarih Seçimi',
      description: 'Dün veya önceki günlerin harcamalarını da girebilirsin. Takvim ikonuna tıklayarak istediğin tarihi seç.',
    ),
    TourStep(
      key: TourKeys.financialSnapshot,
      title: 'Finansal Özet',
      description: 'Aylık gelirin, harcamaların ve kurtardığın para burada. Tüm veriler anlık güncellenir.',
    ),
    TourStep(
      key: TourKeys.currencyRates,
      title: 'Döviz Kurları',
      description: 'Güncel USD, EUR ve altın fiyatları. Tıklayarak detaylı bilgi alabilirsin.',
    ),
    TourStep(
      key: TourKeys.streakWidget,
      title: 'Seri Takibi',
      description: 'Her gün harcama girdiğinde serin artar. Düzenli takip etmek bilinçli harcamanın anahtarı!',
    ),
    TourStep(
      key: TourKeys.subscriptionButton,
      title: 'Abonelikler',
      description: 'Netflix, Spotify gibi düzenli aboneliklerini buradan takip et. Yaklaşan ödemeler için bildirim alırsın.',
    ),
    TourStep(
      key: TourKeys.navBarReport,
      title: 'Raporlar',
      description: 'Aylık ve kategorilere göre harcama analizlerini buradan görüntüle.',
    ),
    TourStep(
      key: TourKeys.navBarAchievements,
      title: 'Rozetler',
      description: 'Tasarruf hedeflerine ulaştıkça rozetler kazan. Motivasyonunu yüksek tut!',
    ),
    TourStep(
      key: TourKeys.navBarProfile,
      title: 'Profil & Ayarlar',
      description: 'Gelir bilgilerini düzenle, bildirim tercihlerini yönet ve uygulama ayarlarına eriş.',
    ),
    TourStep(
      key: TourKeys.navBarAddButton,
      title: 'Hızlı Ekleme',
      description: 'Her yerden hızlıca harcama eklemek için bu butonu kullan. Pratik ve hızlı!',
    ),
  ];
}
