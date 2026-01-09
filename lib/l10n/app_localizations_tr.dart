// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Vantag';

  @override
  String get appSlogan => 'Finansal Üstünlüğün';

  @override
  String get navExpenses => 'Harcama';

  @override
  String get navReports => 'Rapor';

  @override
  String get navAchievements => 'Rozetler';

  @override
  String get navProfile => 'Profil';

  @override
  String get dashboard => 'Anasayfa';

  @override
  String get totalBalance => 'Toplam Bakiye';

  @override
  String get monthlyIncome => 'Aylık Gelir';

  @override
  String get totalIncome => 'Toplam Gelir';

  @override
  String get totalSpent => 'Toplam Harcama';

  @override
  String get totalSaved => 'Toplam Tasarruf';

  @override
  String get workHours => 'Çalışma Saati';

  @override
  String get workDays => 'Çalışma Günü';

  @override
  String get expenses => 'Harcamalar';

  @override
  String get addExpense => 'Harcama Ekle';

  @override
  String get amount => 'Tutar';

  @override
  String get amountTL => 'Tutar (₺)';

  @override
  String get category => 'Kategori';

  @override
  String get description => 'Açıklama';

  @override
  String get descriptionHint => 'ör: Migros, Spotify, Shell...';

  @override
  String get descriptionLabel => 'Açıklama (Mağaza/Ürün)';

  @override
  String get date => 'Tarih';

  @override
  String get today => 'Bugün';

  @override
  String get weekdayMon => 'Pzt';

  @override
  String get weekdayTue => 'Sal';

  @override
  String get weekdayWed => 'Çar';

  @override
  String get weekdayThu => 'Per';

  @override
  String get weekdayFri => 'Cum';

  @override
  String get weekdaySat => 'Cmt';

  @override
  String get weekdaySun => 'Paz';

  @override
  String get monthJan => 'Ocak';

  @override
  String get monthFeb => 'Şubat';

  @override
  String get monthMar => 'Mart';

  @override
  String get monthApr => 'Nisan';

  @override
  String get monthMay => 'Mayıs';

  @override
  String get monthJun => 'Haziran';

  @override
  String get monthJul => 'Temmuz';

  @override
  String get monthAug => 'Ağustos';

  @override
  String get monthSep => 'Eylül';

  @override
  String get monthOct => 'Ekim';

  @override
  String get monthNov => 'Kasım';

  @override
  String get monthDec => 'Aralık';

  @override
  String get yesterday => 'Dün';

  @override
  String get twoDaysAgo => '2 Gün Önce';

  @override
  String daysAgo(int count) {
    return '$count Gün Önce';
  }

  @override
  String get bought => 'Aldım';

  @override
  String get thinking => 'Düşünüyorum';

  @override
  String get passed => 'Vazgeçtim';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get close => 'Kapat';

  @override
  String get update => 'Güncelle';

  @override
  String get calculate => 'Hesapla';

  @override
  String get giveUp => 'Vazgeç';

  @override
  String get select => 'Seç';

  @override
  String hoursRequired(String hours) {
    return '$hours saat';
  }

  @override
  String daysRequired(String days) {
    return '$days gün';
  }

  @override
  String minutesRequired(int minutes) {
    return '$minutes dakika';
  }

  @override
  String hoursEquivalent(String hours) {
    return '$hours saat karşılığı';
  }

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'İngilizce';

  @override
  String get incomeInfo => 'Gelir Bilgileri';

  @override
  String get dailyWorkHours => 'Günlük Çalışma Saati';

  @override
  String get weeklyWorkDays => 'Haftalık Çalışma Günü';

  @override
  String workingDaysPerWeek(int count) {
    return 'Haftada $count gün çalışıyorum';
  }

  @override
  String get hours => 'saat';

  @override
  String incomeSources(int count) {
    return '$count kaynak';
  }

  @override
  String get detailedEntry => 'Detaylı Giriş';

  @override
  String get googleAccount => 'Google Hesabı';

  @override
  String get googleLinked => 'Google Bağlandı';

  @override
  String get linkWithGoogle => 'Google ile Bağla';

  @override
  String get linking => 'Bağlanıyor...';

  @override
  String get backupAndSecure => 'Verilerini yedekle ve güvende tut';

  @override
  String get googleLinkedSuccess => 'Google hesabı başarıyla bağlandı!';

  @override
  String get welcome => 'Hoş geldin';

  @override
  String get welcomeSubtitle =>
      'Harcamalarını zamanla ölçmek için bilgilerini gir';

  @override
  String get getStarted => 'Başla';

  @override
  String get offlineMode => 'Çevrimdışı mod - Veriler senkronize edilecek';

  @override
  String get reports => 'Raporlar';

  @override
  String get monthlyReport => 'Aylık Rapor';

  @override
  String get categoryReport => 'Kategori Raporu';

  @override
  String get thisMonth => 'Bu Ay';

  @override
  String get lastMonth => 'Geçen Ay';

  @override
  String get thisWeek => 'Bu Hafta';

  @override
  String get allTime => 'Tüm Zamanlar';

  @override
  String get achievements => 'Başarılar';

  @override
  String get badges => 'Rozetler';

  @override
  String get progress => 'İlerleme';

  @override
  String get unlocked => 'Açıldı';

  @override
  String get locked => 'Kilitli';

  @override
  String get streak => 'Seri';

  @override
  String get currentStreak => 'Mevcut Seri';

  @override
  String get bestStreak => 'En İyi Seri';

  @override
  String streakDays(int count) {
    return '$count gün';
  }

  @override
  String get subscriptions => 'Abonelikler';

  @override
  String get subscriptionsDescription =>
      'Netflix, Spotify gibi düzenli aboneliklerini buradan takip et.';

  @override
  String get addSubscription => 'Abonelik Ekle';

  @override
  String get monthlyTotal => 'Aylık Toplam';

  @override
  String get yearlyTotal => 'Yıllık Toplam';

  @override
  String get nextPayment => 'Sonraki Ödeme';

  @override
  String renewalWarning(int days) {
    return '$days gün içinde yenileniyor';
  }

  @override
  String activeSubscriptions(int count) {
    return '$count aktif abonelik';
  }

  @override
  String get monthlySubscriptions => 'Aylık Abonelikler';

  @override
  String get habitCalculator => 'Alışkanlık Hesaplayıcı';

  @override
  String get selectHabit => 'Alışkanlık Seç';

  @override
  String get enterAmount => 'Miktar Gir';

  @override
  String get dailyAmount => 'Günlük Miktar';

  @override
  String get yearlyCost => 'Yıllık Maliyet';

  @override
  String get workDaysEquivalent => 'İş Günü Karşılığı';

  @override
  String get shareResult => 'Sonucu Paylaş';

  @override
  String get habitQuestion => 'Alışkanlığın kaç gününü alıyor?';

  @override
  String get calculateAndShock => 'Hesapla ve şok ol →';

  @override
  String get appTour => 'Uygulama Turu';

  @override
  String get repeatTour => 'Uygulama Turunu Tekrarla';

  @override
  String get tourCompleted => 'Tur Tamamlandı';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notificationSettings => 'Bildirim Ayarları';

  @override
  String get streakReminder => 'Seri Hatırlatıcı';

  @override
  String get weeklyInsights => 'Haftalık Bilgiler';

  @override
  String get error => 'Hata';

  @override
  String get success => 'Başarılı';

  @override
  String get warning => 'Uyarı';

  @override
  String get info => 'Bilgi';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get noData => 'Veri bulunamadı';

  @override
  String get noExpenses => 'Henüz harcama yok';

  @override
  String get noExpensesHint => 'Yukarıdan tutar girerek başla';

  @override
  String get noAchievements => 'Henüz başarı yok';

  @override
  String get recordToEarnBadge => 'Rozet kazanmak için kayıt yap';

  @override
  String get notEnoughDataForReports => 'Raporlar için yeterli veri yok';

  @override
  String get confirmDelete => 'Silmek istediğinizden emin misiniz?';

  @override
  String get deleteConfirmation => 'Bu işlem geri alınamaz.';

  @override
  String get categoryFood => 'Yiyecek';

  @override
  String get categoryTransport => 'Ulaşım';

  @override
  String get categoryEntertainment => 'Eğlence';

  @override
  String get categoryShopping => 'Alışveriş';

  @override
  String get categoryBills => 'Faturalar';

  @override
  String get categoryHealth => 'Sağlık';

  @override
  String get categoryEducation => 'Eğitim';

  @override
  String get categoryDigital => 'Dijital';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get shareTitle => 'Vantag ile tasarruflarıma göz at!';

  @override
  String shareMessage(String amount) {
    return 'Bu ay Vantag ile $amount TL tasarruf ettim!';
  }

  @override
  String get currencyRates => 'Döviz Kurları';

  @override
  String get currencyRatesDescription =>
      'Güncel USD, EUR ve altın fiyatları. Tıklayarak detaylı bilgi alabilirsin.';

  @override
  String get gold => 'Altın';

  @override
  String get dollar => 'Dolar';

  @override
  String get euro => 'Euro';

  @override
  String get moneySavedInPocket => 'Para cebinde kaldı!';

  @override
  String get greatDecision => 'Harika karar!';

  @override
  String freedomCloser(String hours) {
    return 'Para cebinde kaldı, özgürlüğüne $hours daha yakınsın!';
  }

  @override
  String get version => 'Sürüm';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfService => 'Kullanım Şartları';

  @override
  String get about => 'Hakkında';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get greetingMorning => 'Günaydın';

  @override
  String get greetingAfternoon => 'İyi günler';

  @override
  String get greetingEvening => 'İyi akşamlar';

  @override
  String get financialStatus => 'Finansal Durum';

  @override
  String get financialSummary => 'Finansal Özet';

  @override
  String get financialSummaryDescription =>
      'Aylık gelirin, harcamaların ve kurtardığın para burada. Tüm veriler anlık güncellenir.';

  @override
  String get newExpense => 'Yeni Harcama';

  @override
  String get expenseHistory => 'Geçmiş';

  @override
  String recordCount(int count) {
    return '$count kayıt';
  }

  @override
  String get streakTracking => 'Seri Takibi';

  @override
  String get streakTrackingDescription =>
      'Her gün harcama girdiğinde serin artar. Düzenli takip bilinçli harcamanın anahtarı!';

  @override
  String get pastDateSelection => 'Geçmiş Tarih Seçimi';

  @override
  String get pastDateSelectionDescription =>
      'Dün veya önceki günlerin harcamalarını da girebilirsin. Takvim ikonuna tıklayarak istediğin tarihi seç.';

  @override
  String get amountEntry => 'Tutar Girişi';

  @override
  String get amountEntryDescription =>
      'Harcama tutarını buraya gir. Fiş tarama butonu ile fişten otomatik okuyabilirsin.';

  @override
  String get smartMatching => 'Akıllı Eşleştirme';

  @override
  String get smartMatchingDescription =>
      'Mağaza veya ürün adını yaz. Migros, A101, Starbucks gibi... Uygulama otomatik olarak kategori önericek!';

  @override
  String get categorySelection => 'Kategori Seçimi';

  @override
  String get categorySelectionDescription =>
      'Akıllı eşleştirme bulamazsa veya düzeltmek istersen buradan manuel seçim yapabilirsin.';

  @override
  String get selectCategory => 'Kategori seçin';

  @override
  String autoSelected(String category) {
    return 'Otomatik seçildi: $category';
  }

  @override
  String get pleaseSelectCategory =>
      'Lütfen bu harcamanın kategorisini belirleyin';

  @override
  String get subCategoryOptional => 'Alt kategori (opsiyonel)';

  @override
  String get recentlyUsed => 'Son kullanılanlar';

  @override
  String get suggestions => 'Öneriler';

  @override
  String get scanReceipt => 'Fiş tara';

  @override
  String get cameraCapture => 'Kamera ile çek';

  @override
  String get selectFromGallery => 'Galeriden seç';

  @override
  String amountFound(String amount) {
    return 'Tutar bulundu: $amount ₺';
  }

  @override
  String get amountNotFound => 'Tutar bulunamadı. Manuel girin.';

  @override
  String get scanError => 'Tarama hatası. Tekrar deneyin.';

  @override
  String get selectExpenseDate => 'Harcama Tarihi Seçin';

  @override
  String get decisionUpdatedBought => 'Karar güncellendi: Aldın';

  @override
  String decisionSaved(String amount) {
    return 'Vazgeçtin, $amount TL kurtardın!';
  }

  @override
  String get keepThinking => 'Düşünmeye devam';

  @override
  String get expenseUpdated => 'Harcama güncellendi';

  @override
  String get validationEnterAmount => 'Lütfen geçerli bir tutar girin';

  @override
  String get validationAmountPositive => 'Tutar 0\'dan büyük olmalı';

  @override
  String get validationAmountTooHigh => 'Tutar çok yüksek görünüyor';

  @override
  String get simulationSaved => 'Simülasyon Olarak Kaydedildi';

  @override
  String get simulationDescription =>
      'Bu tutar büyük olduğu için simülasyon olarak kaydedildi.';

  @override
  String get simulationInfo =>
      'İstatistiklerini etkilemez, sadece fikir vermek için.';

  @override
  String get understood => 'Anladım';

  @override
  String get monthJanuary => 'Ocak';

  @override
  String get monthFebruary => 'Şubat';

  @override
  String get monthMarch => 'Mart';

  @override
  String get monthApril => 'Nisan';

  @override
  String get monthJune => 'Haziran';

  @override
  String get monthJuly => 'Temmuz';

  @override
  String get monthAugust => 'Ağustos';

  @override
  String get monthSeptember => 'Eylül';

  @override
  String get monthOctober => 'Ekim';

  @override
  String get monthNovember => 'Kasım';

  @override
  String get monthDecember => 'Aralık';

  @override
  String get categoryDistribution => 'Kategori Dağılımı';

  @override
  String moreCategories(int count) {
    return '+$count kategori daha';
  }

  @override
  String get expenseCount => 'Harcama Sayısı';

  @override
  String boughtPassed(int bought, int passed) {
    return '$bought alındı, $passed vazgeçildi';
  }

  @override
  String get passRate => 'Vazgeçme Oranı';

  @override
  String get doingGreat => 'Harika gidiyorsun!';

  @override
  String get canDoBetter => 'Daha iyisini yapabilirsin';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get avgDailyExpense => 'Ortalama Günlük Harcama';

  @override
  String get highestSingleExpense => 'En Yüksek Tek Harcama';

  @override
  String get mostDeclinedCategory => 'En Çok Vazgeçilen Kategori';

  @override
  String times(int count) {
    return '$count kez';
  }

  @override
  String get trend => 'Trend';

  @override
  String trendSpentThisPeriod(String amount, String period) {
    return 'Bu $period $amount TL harcadın';
  }

  @override
  String trendSameAsPrevious(String period) {
    return 'Geçen $period göre aynı harcama yaptın';
  }

  @override
  String trendSpentLess(String percent, String period) {
    return 'Geçen $period göre %$percent daha az harcadın';
  }

  @override
  String trendSpentMore(String percent, String period) {
    return 'Geçen $period göre %$percent daha fazla harcadın';
  }

  @override
  String get periodWeek => 'hafta';

  @override
  String get periodMonth => 'ay';

  @override
  String get subCategoryDetail => 'Alt Kategori Detayı';

  @override
  String get comparedToPrevious => 'Önceki döneme kıyasla';

  @override
  String get increased => 'arttı';

  @override
  String get decreased => 'azaldı';

  @override
  String subCategoryChange(
    String period,
    String subCategory,
    String changeText,
    String percent,
    String previousPeriod,
  ) {
    return '$period $subCategory harcaman $previousPeriod göre %$percent $changeText.';
  }

  @override
  String get listView => 'Liste Görünümü';

  @override
  String get calendarView => 'Takvim Görünümü';

  @override
  String get subscription => 'abonelik';

  @override
  String get workDaysPerMonth => 'iş günü/ay';

  @override
  String everyMonthDay(int day) {
    return 'Her ayın $day\'i';
  }

  @override
  String get noSubscriptionsYet => 'Henüz abonelik yok';

  @override
  String get addSubscriptionsLikeNetflix =>
      'Netflix, Spotify gibi aboneliklerini ekle';

  @override
  String monthlyTotalAmount(String amount) {
    return 'Aylık toplam: $amount TL';
  }

  @override
  String dayOfMonth(int day) {
    return 'Her ayın $day\'i';
  }

  @override
  String get addSubscriptionHint => 'Yeni abonelik eklemek için + butonuna bas';

  @override
  String get tomorrow => 'Yarın';

  @override
  String daysLater(int days) {
    return '$days gün sonra';
  }

  @override
  String get perMonth => '/ay';

  @override
  String get enterSubscriptionName => 'Abonelik adı girin';

  @override
  String get enterValidAmount => 'Geçerli bir tutar girin';

  @override
  String get editSubscription => 'Aboneliği Düzenle';

  @override
  String get newSubscription => 'Yeni Abonelik';

  @override
  String get subscriptionName => 'Abonelik Adı';

  @override
  String get subscriptionNameHint => 'Netflix, Spotify...';

  @override
  String get monthlyAmount => 'Aylık Tutar';

  @override
  String get renewalDay => 'Yenileme Günü';

  @override
  String get active => 'Aktif';

  @override
  String get passivesNotIncluded => 'Pasifler bildirimlere dahil edilmez';

  @override
  String get autoRecord => 'Otomatik Kayıt';

  @override
  String get autoRecordDescription => 'Yenilendiğinde harcama kaydı oluştur';

  @override
  String get add => 'Ekle';

  @override
  String subscriptionCount(int count, String amount) {
    return '$count abonelik, $amount ₺/ay';
  }

  @override
  String get viewSubscriptionsInCalendar => 'Aboneliklerini takvimde gör';

  @override
  String get urgentRenewalWarning => 'Acil Yenileme Uyarısı!';

  @override
  String get upcomingRenewals => 'Yaklaşan Yenilemeler';

  @override
  String renewsWithinOneHour(String name) {
    return '$name - 1 saat içinde yenilenecek';
  }

  @override
  String renewsWithinHours(String name, int hours) {
    return '$name - $hours saat içinde';
  }

  @override
  String renewsToday(String name) {
    return '$name - Bugün yenilenecek';
  }

  @override
  String renewsTomorrow(String name) {
    return '$name - Yarın yenilenecek';
  }

  @override
  String subscriptionsRenewingSoon(int count) {
    return '$count abonelik yakında yenilenecek';
  }

  @override
  String amountPerMonth(String amount) {
    return '$amount ₺/ay';
  }

  @override
  String get hiddenBadges => 'Gizli Rozetler';

  @override
  String badgesEarned(int unlocked, int total) {
    return '$unlocked / $total rozet kazandın';
  }

  @override
  String percentComplete(String percent) {
    return '%$percent tamamlandı';
  }

  @override
  String get completed => 'Tamamlandı!';

  @override
  String get startRecordingForFirstBadge =>
      'İlk rozetini kazanmak için harcama kaydet!';

  @override
  String get greatStartKeepGoing => 'Harika bir başlangıç, devam et!';

  @override
  String get halfwayThere => 'Yarı yola geldin, böyle devam!';

  @override
  String get doingVeryWell => 'Çok iyi gidiyorsun!';

  @override
  String get almostDone => 'Neredeyse tamamladın!';

  @override
  String get allBadgesEarned => 'Tüm rozetleri kazandın, tebrikler!';

  @override
  String get hiddenBadge => 'Gizli Rozet';

  @override
  String get discoverHowToUnlock => 'Nasıl açılacağını keşfet!';

  @override
  String get difficultyEasy => 'Kolay';

  @override
  String get difficultyMedium => 'Orta';

  @override
  String get difficultyHard => 'Zor';

  @override
  String get difficultyLegendary => 'Efsanevi';

  @override
  String get earnedToday => 'Bugün kazandın!';

  @override
  String get earnedYesterday => 'Dün kazandın';

  @override
  String daysAgoEarned(int count) {
    return '$count gün önce';
  }

  @override
  String weeksAgoEarned(int count) {
    return '$count hafta önce';
  }

  @override
  String get tapToAddPhoto => 'Fotoğraf eklemek için dokun';

  @override
  String get dailyWork => 'Günlük Çalışma';

  @override
  String get weeklyWorkingDays => 'Haftalık Çalışma Günleri';

  @override
  String get hourlyEarnings => 'Saatlik Kazanç';

  @override
  String get days => 'gün';

  @override
  String get resetData => 'Verileri Sıfırla';

  @override
  String get resetDataDebug => 'Verileri Sıfırla (DEBUG)';

  @override
  String get resetDataTitle => 'Verileri Sıfırla';

  @override
  String get resetDataMessage =>
      'Tüm uygulama verileri silinecek. Bu işlem geri alınamaz.';

  @override
  String get notificationTypes => 'Bildirim Türleri';

  @override
  String get awarenessReminder => 'Farkındalık Hatırlatması';

  @override
  String get awarenessReminderDesc =>
      'Yüksek tutarlı alımlardan 6-12 saat sonra';

  @override
  String get giveUpCongrats => 'Vazgeçme Tebriği';

  @override
  String get giveUpCongratsDesc => 'Vazgeçtiğinde aynı gün motivasyon';

  @override
  String get streakReminderDesc => 'Akşam, seri kırılmadan önce';

  @override
  String get weeklySummary => 'Haftalık Özet';

  @override
  String get weeklySummaryDesc => 'Pazar günü haftalık içgörü';

  @override
  String get nightModeNotice =>
      'Gece saatlerinde (22:00-08:00) bildirim gönderilmez. Uykunu bozmayız.';

  @override
  String get on => 'Açık';

  @override
  String get off => 'Kapalı';

  @override
  String get lastUpdate => 'Son Güncelleme';

  @override
  String get rates => 'Kurlar';

  @override
  String get usDollar => 'ABD Doları';

  @override
  String get gramGold => 'Gram Altın';

  @override
  String get tcmbNotice =>
      'Kurlar TCMB (Türkiye Cumhuriyet Merkez Bankası) verilerinden alınmaktadır. Altın fiyatları anlık piyasa verilerini yansıtır.';

  @override
  String get buy => 'Alış';

  @override
  String get sell => 'Satış';

  @override
  String get createOwnCategory => 'Kendi Kategorini Oluştur';

  @override
  String get selectEmoji => 'Emoji Seç';

  @override
  String get categoryName => 'Kategori Adı';

  @override
  String get categoryNameHint => 'Örn: Starbucks';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get howManyDaysForHabit => 'Ne için kaç gün çalışıyorsun?';

  @override
  String get selectHabitShock => 'Bir alışkanlık seç, şok ol';

  @override
  String get addMyOwnCategory => 'Kendi kategorimi ekle';

  @override
  String get whatIsYourSalary => 'Aylık Maaşın Ne Kadar?';

  @override
  String get enterNetAmount => 'Net ele geçen tutarı gir';

  @override
  String get howMuchPerTime => 'Bir seferinde kaç TL harcıyorsun?';

  @override
  String get tl => 'TL';

  @override
  String get howOften => 'Ne sıklıkta?';

  @override
  String get whatIsYourIncome => 'Aylık gelirin ne kadar?';

  @override
  String get exampleAmount => 'Örn: 50000';

  @override
  String get dontWantToSay => 'Söylemek istemiyorum';

  @override
  String resultDays(String value) {
    return '$value GÜN';
  }

  @override
  String yearlyHabitCost(String habit) {
    return 'Yılda sadece $habit için\nbu kadar çalışıyorsun';
  }

  @override
  String monthlyYearlyCost(String monthly, String yearly) {
    return 'Aylık: $monthly • Yıllık: $yearly';
  }

  @override
  String get shareOnStory => 'Hikayemde Paylaş';

  @override
  String get tryAnotherHabit => 'Başka alışkanlık dene';

  @override
  String get trackAllExpenses => 'Tüm harcamalarımı takip et';

  @override
  String get editIncomes => 'Gelirleri Düzenle';

  @override
  String get addIncome => 'Gelir Ekle';

  @override
  String get daysPerWeek => 'gün/hafta';

  @override
  String get doYouHaveOtherIncome => 'Başka Bir Gelirin\nVar mı?';

  @override
  String get otherIncomeDescription =>
      'Freelance, kira, yatırım geliri gibi\nek gelirlerini de ekleyebilirsin';

  @override
  String get yesAddIncome => 'Evet, Eklemek İstiyorum';

  @override
  String get noOnlySalary => 'Hayır, Sadece Maaşım Var';

  @override
  String get addAdditionalIncome => 'Ek Gelir Ekle';

  @override
  String get incomeType => 'Gelir Türü';

  @override
  String get descriptionOptional => 'Açıklama (Opsiyonel)';

  @override
  String get descriptionOptionalHint => 'Örn: Upwork Projesi';

  @override
  String get addedIncomes => 'Eklenen Gelirler';

  @override
  String get incomeSummary => 'Gelir Özeti';

  @override
  String get totalMonthlyIncome => 'Toplam Aylık Gelir';

  @override
  String get incomeSource => 'gelir kaynağı';

  @override
  String get complete => 'Tamamla';

  @override
  String get editMyIncomes => 'Gelirlerimi Düzenle';

  @override
  String get goBack => 'Geri Dön';

  @override
  String get notBudgetApp => 'Bu bir bütçe uygulaması değil';

  @override
  String get showRealCost => 'Harcamalarının gerçek bedelini göster: zamanın.';

  @override
  String get everyExpenseDecision => 'Her harcama bir karar';

  @override
  String get youDecide => 'Aldım, düşünüyorum veya vazgeçtim. Sen seç.';

  @override
  String get oneExpenseEnough => 'Bugün tek bir harcama yeter';

  @override
  String get startSmall => 'Küçük başla, farkındalık büyür.';

  @override
  String get skip => 'Atla';

  @override
  String get start => 'Başla';

  @override
  String get whatIsYourDecision => 'Kararın nedir?';

  @override
  String get netBalance => 'NET BAKİYE';

  @override
  String sources(int count) {
    return '$count kaynak';
  }

  @override
  String get income => 'GELİR';

  @override
  String get expense => 'HARCAMA';

  @override
  String get saved => 'KURTARILAN';

  @override
  String get budgetUsage => 'BÜTÇE KULLANIMI';

  @override
  String get startToday => 'Bugün başla!';

  @override
  String dayStreak(int count) {
    return '$count Günlük Seri!';
  }

  @override
  String get startStreak => 'Seriye Başla!';

  @override
  String get keepStreakMessage => 'Her gün harcama kaydederek serini sürdür!';

  @override
  String get startStreakMessage =>
      'Her gün en az 1 harcama kaydet ve seri oluştur!';

  @override
  String longestStreak(int count) {
    return 'En uzun seri: $count gün';
  }

  @override
  String get newRecord => 'Yeni Rekor!';

  @override
  String withThisAmount(String amount) {
    return 'Bu $amount TL ile şunları alabilirdin:';
  }

  @override
  String goldGrams(String grams) {
    return '${grams}g altın';
  }

  @override
  String get ratesLoading => 'Kurlar yükleniyor...';

  @override
  String get ratesLoadFailed => 'Kurlar yüklenemedi';

  @override
  String get goldPriceNotUpdated => 'Altın fiyatı güncellenemedi';

  @override
  String get monthAbbreviations =>
      'Oca,Şub,Mar,Nis,May,Haz,Tem,Ağu,Eyl,Eki,Kas,Ara';

  @override
  String get updateYourDecision => 'Kararını güncelle';

  @override
  String get simulation => 'Simülasyon';

  @override
  String get tapToUpdate => 'Dokunarak güncelle';

  @override
  String get swipeToEditOrDelete => 'Kaydırarak düzenle veya sil';

  @override
  String get pleaseEnterValidAmount => 'Lütfen geçerli bir tutar girin';

  @override
  String get amountTooHigh => 'Tutar çok yüksek görünüyor';

  @override
  String get pleaseSelectExpenseGroup => 'Lütfen önce harcama grubunu belirle';

  @override
  String get categorySelectionRequired => 'Kategori seçimi zorunludur';

  @override
  String get expenseGroup => 'Harcama Grubu';

  @override
  String get required => 'Zorunlu';

  @override
  String get detail => 'Detay';

  @override
  String get optional => 'Opsiyonel';

  @override
  String get editYourCard => 'Kartını Düzenle';

  @override
  String get share => 'Paylaş';

  @override
  String get youSaved => 'kurtardın!';

  @override
  String get noSavingsYet => 'Henüz kurtarılan yok';

  @override
  String get categorySports => 'Spor';

  @override
  String get categoryCommunication => 'Haberleşme';

  @override
  String get subscriptionNameExample => 'Örn: Netflix, Spotify';

  @override
  String get monthlyAmountExample => 'Örn: 99,99';

  @override
  String get color => 'Renk';

  @override
  String get autoRecordOnRenewal => 'Yenileme gününde harcama olarak kaydet';

  @override
  String get deleteSubscription => 'Aboneliği Sil';

  @override
  String deleteSubscriptionConfirm(String name) {
    return '$name aboneliğini silmek istediğine emin misin?';
  }

  @override
  String get subscriptionDuration => 'Abone Süresi';

  @override
  String subscriptionDurationDays(int days) {
    return '$days gün';
  }

  @override
  String get totalPaid => 'Toplam Ödenen';

  @override
  String workHoursAmount(String hours) {
    return '$hours saat';
  }

  @override
  String workDaysAmount(String days) {
    return '$days gün';
  }

  @override
  String get autoRecordEnabled => 'Otomatik harcama kaydı açık';

  @override
  String get autoRecordDisabled => 'Otomatik harcama kaydı kapalı';

  @override
  String get saveChanges => 'Değişiklikleri Kaydet';

  @override
  String get weekdayAbbreviations => 'Pzt,Sal,Çar,Per,Cum,Cmt,Paz';

  @override
  String get homePage => 'Ana Sayfa';

  @override
  String get analysis => 'Analiz';

  @override
  String get reportsDescription =>
      'Aylık ve kategorilere göre harcama analizlerini buradan görüntüle.';

  @override
  String get quickAdd => 'Hızlı Ekleme';

  @override
  String get quickAddDescription =>
      'Her yerden hızlıca harcama eklemek için bu butonu kullan. Pratik ve hızlı!';

  @override
  String get badgesDescription =>
      'Tasarruf hedeflerine ulaştıkça rozetler kazan. Motivasyonunu yüksek tut!';

  @override
  String get profileAndSettings => 'Profil & Ayarlar';

  @override
  String get profileAndSettingsDescription =>
      'Gelir bilgilerini düzenle, bildirim tercihlerini yönet ve uygulama ayarlarına eriş.';

  @override
  String get addSubscriptionButton =>
      'Netflix, Spotify gibi aboneliklerini ekle';

  @override
  String get shareError => 'Paylaşım sırasında bir hata oluştu';

  @override
  String get pleaseEnterValidSalary => 'Please enter a valid salary';

  @override
  String get pleaseEnterValidIncomeAmount => 'Please enter a valid amount';

  @override
  String get atLeastOneIncomeRequired =>
      'You must add at least one income source';

  @override
  String get incomesUpdated => 'Incomes updated';

  @override
  String get incomesSaved => 'Incomes saved';

  @override
  String get saveError => 'An error occurred while saving';

  @override
  String incomeSourceCount(int count) {
    return '$count income sources';
  }

  @override
  String get freedTime => 'Özgürleştin';

  @override
  String get savedAmountLabel => 'Kurtarılan';

  @override
  String get dayLabel => 'Gün';

  @override
  String get zeroMinutes => '0 Dakika';

  @override
  String get zeroAmount => '0 ₺';

  @override
  String shareCardDays(int days) {
    return '$days GÜN';
  }

  @override
  String shareCardDescription(String category) {
    return 'Yılda sadece $category için\nbu kadar çalışıyorum';
  }

  @override
  String get shareCardQuestion => 'Sen kaç gün? 👀';

  @override
  String shareCardDuration(int days) {
    return 'Süre ($days gün)';
  }

  @override
  String shareCardAmountLabel(String amount) {
    return 'Tutar (₺$amount)';
  }

  @override
  String shareCardFrequency(String frequency) {
    return 'Sıklık ($frequency)';
  }

  @override
  String get unsavedChanges => 'Kaydedilmemiş Değişiklikler';

  @override
  String get unsavedChangesConfirm =>
      'Değişiklikleri kaydetmeden çıkmak istediğine emin misin?';

  @override
  String get discardChanges => 'Kaydetme';

  @override
  String get thinkingTime => 'Düşünme süresi...';

  @override
  String get confirm => 'Onayla';

  @override
  String get riskLevelNone => 'Güvenli';

  @override
  String get riskLevelLow => 'Düşük Risk';

  @override
  String get riskLevelMedium => 'Orta Risk';

  @override
  String get riskLevelHigh => 'Yüksek Risk';

  @override
  String get riskLevelExtreme => 'Kritik Risk';

  @override
  String savedTimeHoursDays(String hours, String days) {
    return '$hours saat = $days gün kazandın';
  }

  @override
  String savedTimeHours(String hours) {
    return '$hours saat kazandın';
  }

  @override
  String savedTimeMinutes(int minutes) {
    return '$minutes dakika kazandın';
  }

  @override
  String couldBuyGoldGrams(String grams) {
    return 'Bu parayla $grams gram altın alabilirdin';
  }

  @override
  String equivalentWorkDays(String days) {
    return 'Bu $days gün çalışmana eşdeğer';
  }

  @override
  String equivalentWorkHours(String hours) {
    return 'Bu $hours saat çalışmana eşdeğer';
  }

  @override
  String savedDollars(String amount) {
    return 'Tam $amount dolar biriktirdin';
  }

  @override
  String get or => 'VEYA';

  @override
  String goldGramsShort(String grams) {
    return '${grams}g altın';
  }

  @override
  String get amountRequired => 'Tutar gerekli';

  @override
  String get everyMonth => 'Her ay';

  @override
  String daysCount(int count) {
    return '$count gün';
  }

  @override
  String hoursCount(String count) {
    return '$count saat';
  }

  @override
  String daysCountDecimal(String count) {
    return '$count gün';
  }

  @override
  String get autoRecordOn => 'Otomatik kayıt açık';

  @override
  String get autoRecordOff => 'Otomatik kayıt kapalı';

  @override
  String monthlyAmountTl(String amount) {
    return '$amount TL/ay';
  }

  @override
  String get nameRequired => 'İsim gerekli';

  @override
  String get amountHint => 'Örn: 99,99';

  @override
  String get updateDecision => 'Kararını güncelle';

  @override
  String get categoryRequired => 'Kategori gerekli';

  @override
  String get monthlyAmountLabel => 'Aylık Tutar (TL)';

  @override
  String withThisAmountYouCouldBuy(String amount) {
    return '$amount TL ile şunları alabilirdin:';
  }
}
