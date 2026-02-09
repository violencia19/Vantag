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
  String get navSettings => 'Ayarlar';

  @override
  String get profile => 'Profil';

  @override
  String get profileSavedTime => 'Vantag ile Kurtarılan Zaman';

  @override
  String profileHours(String hours) {
    return '$hours Saat';
  }

  @override
  String get profileMemberSince => 'Üyelik Süresi';

  @override
  String profileDays(int days) {
    return '$days Gün';
  }

  @override
  String get profileBadgesEarned => 'Kazanılan Rozet';

  @override
  String get profileGoogleConnected => 'Google Hesabı Bağlı';

  @override
  String get profileGoogleNotConnected => 'Google Hesabı Bağlı Değil';

  @override
  String get profileSignOut => 'Çıkış Yap';

  @override
  String get profileSignOutConfirm => 'Çıkış yapmak istediğinize emin misiniz?';

  @override
  String get proMember => 'Pro Üye';

  @override
  String get proMemberToast => 'Pro Üyesiniz ✓';

  @override
  String get settingsGeneral => 'Genel';

  @override
  String get settingsCurrency => 'Para Birimi';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemeAutomatic => 'Otomatik';

  @override
  String get simpleMode => 'Basit Mod';

  @override
  String get simpleModeDescription =>
      'Sadece temel özelliklerle basitleştirilmiş deneyim';

  @override
  String get simpleModeEnabled => 'Basit mod etkin';

  @override
  String get simpleModeDisabled => 'Basit mod devre dışı';

  @override
  String get simpleModeHint =>
      'AI sohbet, rozetler ve hedefler gibi tüm özelliklere erişmek için Basit Modu kapatın';

  @override
  String get simpleTransactions => 'İşlemler';

  @override
  String get simpleStatistics => 'İstatistik';

  @override
  String get simpleSettings => 'Ayarlar';

  @override
  String get simpleIncome => 'Gelir';

  @override
  String get simpleExpense => 'Gider';

  @override
  String get simpleExpenses => 'Giderler';

  @override
  String get simpleBalance => 'Bakiye';

  @override
  String get simpleTotal => 'Toplam';

  @override
  String get simpleTotalIncome => 'Toplam Gelir';

  @override
  String get simpleIncomeTab => 'Gelir';

  @override
  String get simpleIncomeSources => 'Gelir Kaynakları';

  @override
  String get simpleNoTransactions => 'Bu ay işlem yok';

  @override
  String get simpleNoData => 'Bu ay için veri yok';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsReminders => 'Hatırlatıcılar';

  @override
  String get settingsSoundEffects => 'Ses Efektleri';

  @override
  String get settingsSoundVolume => 'Ses Seviyesi';

  @override
  String get settingsProPurchases => 'Pro & Satın Alma';

  @override
  String get settingsVantagPro => 'Vantag Pro';

  @override
  String get settingsRestorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get settingsRestoreSuccess => 'Satın alımlar geri yüklendi';

  @override
  String get settingsRestoreNone => 'Geri yüklenecek satın alım bulunamadı';

  @override
  String get settingsDataPrivacy => 'Veri & Gizlilik';

  @override
  String get settingsExportData => 'Verileri Dışa Aktar';

  @override
  String get settingsImportStatement => 'Ekstre Yükle';

  @override
  String get settingsImportStatementDesc =>
      'Banka ekstrenizi yükleyin (PDF/CSV)';

  @override
  String get importStatementTitle => 'Ekstre Yükle';

  @override
  String get importStatementSelectFile => 'Dosya Seç';

  @override
  String get importStatementSupportedFormats =>
      'Desteklenen formatlar: PDF, CSV';

  @override
  String get importStatementDragDrop => 'Banka ekstrenizi seçmek için dokunun';

  @override
  String get importStatementProcessing => 'Ekstre işleniyor...';

  @override
  String importStatementSuccess(int count) {
    return '$count işlem başarıyla içe aktarıldı';
  }

  @override
  String get importStatementError => 'Ekstre içe aktarılırken hata oluştu';

  @override
  String get importStatementNoTransactions => 'Ekstrede işlem bulunamadı';

  @override
  String get importStatementUnsupportedFormat => 'Desteklenmeyen dosya formatı';

  @override
  String importStatementMonthlyLimit(int remaining) {
    return 'Bu ay $remaining içe aktarma hakkınız kaldı';
  }

  @override
  String get importStatementLimitReached =>
      'Aylık içe aktarma limitine ulaşıldı';

  @override
  String get importStatementLimitReachedDesc =>
      'Bu ayki tüm içe aktarma haklarınızı kullandınız. Daha fazlası için Pro\'ya yükseltin.';

  @override
  String get importStatementProLimit => 'Ayda 10 içe aktarma';

  @override
  String get importStatementFreeLimit => 'Ayda 1 içe aktarma';

  @override
  String get importStatementReviewTitle => 'İşlemleri İncele';

  @override
  String get importStatementReviewDesc => 'İçe aktarılacak işlemleri seçin';

  @override
  String importStatementImportSelected(int count) {
    return 'Seçilenleri İçe Aktar ($count)';
  }

  @override
  String get importStatementSelectAll => 'Tümünü Seç';

  @override
  String get importStatementDeselectAll => 'Seçimi Kaldır';

  @override
  String get settingsPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsVersion => 'Versiyon';

  @override
  String get settingsContactUs => 'Bize Ulaşın';

  @override
  String get settingsGrowth => 'Davet et, 3 gün Premium kazan!';

  @override
  String get settingsInviteFriends => 'Arkadaşını Davet Et';

  @override
  String get settingsInviteMessage =>
      'Vantag ile harcamalarımı kontrol ediyorum! Sen de dene:';

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
  String get descriptionLabel => 'Açıklama';

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
  String get monthJan => 'Oca';

  @override
  String get monthFeb => 'Şub';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Nis';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Haz';

  @override
  String get monthJul => 'Tem';

  @override
  String get monthAug => 'Ağu';

  @override
  String get monthSep => 'Eyl';

  @override
  String get monthOct => 'Eki';

  @override
  String get monthNov => 'Kas';

  @override
  String get monthDec => 'Ara';

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
  String get ok => 'Tamam';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get change => 'Değiştir';

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
  String get decision => 'Karar';

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
  String get editProfile => 'Profili Düzenle';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get selectCurrency => 'Para Birimi Seçin';

  @override
  String get currency => 'Para Birimi';

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
  String get googleNotLinked => 'Google Bağlı Değil';

  @override
  String get linkWithGoogle => 'Google ile Bağla';

  @override
  String get linking => 'Bağlanıyor...';

  @override
  String get backupAndSecure => 'Verilerini yedekle ve güvende tut';

  @override
  String get dataNotBackedUp => 'Verileriniz yedeklenmemiş';

  @override
  String get googleLinkedSuccess => 'Google hesabı başarıyla bağlandı!';

  @override
  String get googleLinkFailed => 'Google hesabı bağlanamadı';

  @override
  String get appleAccount => 'Apple Hesabı';

  @override
  String get appleLinked => 'Apple Bağlandı';

  @override
  String get appleNotLinked => 'Apple Bağlı Değil';

  @override
  String get linkWithApple => 'Apple ile Bağla';

  @override
  String get profileAppleConnected => 'Apple Hesabı Bağlı';

  @override
  String get profileAppleNotConnected => 'Apple Hesabı Bağlı Değil';

  @override
  String get appleLinkedSuccess => 'Apple hesabı başarıyla bağlandı!';

  @override
  String get appleLinkFailed => 'Apple hesabı bağlanamadı';

  @override
  String get appleSignInNotAvailable =>
      'Apple ile giriş bu cihazda kullanılamıyor';

  @override
  String get editWorkHours => 'Çalışma Saati';

  @override
  String get editWorkHoursSubtitle =>
      'Zaman hesaplamaları için günlük çalışma saatiniz';

  @override
  String hoursPerDay(String hours) {
    return '$hours saat/gün';
  }

  @override
  String get workHoursUpdated => 'Çalışma saati güncellendi';

  @override
  String get freeCurrencyNote =>
      'Ücretsiz kullanıcılar sadece TL kullanabilir. Tüm para birimleri için Pro\'ya yükseltin.';

  @override
  String get currencyLockNote =>
      'Seçilen para birimi kilitlenecek. Pro kullanıcılar istediği zaman değiştirebilir.';

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
  String get noInternet => 'İnternet Bağlantısı Yok';

  @override
  String get offline => 'Çevrimdışı';

  @override
  String get offlineMessage =>
      'Veriler bağlantı sağlandığında senkronize edilecek';

  @override
  String get backOnline => 'Tekrar Çevrimiçi';

  @override
  String get dataSynced => 'Veriler senkronize edildi';

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
  String get notificationSettings => 'Bildirimler';

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
  String get categoryClothing => 'Giyim';

  @override
  String get categoryElectronics => 'Elektronik';

  @override
  String get categorySubscription => 'Abonelik';

  @override
  String get weekdayMonday => 'Pazartesi';

  @override
  String get weekdayTuesday => 'Salı';

  @override
  String get weekdayWednesday => 'Çarşamba';

  @override
  String get weekdayThursday => 'Perşembe';

  @override
  String get weekdayFriday => 'Cuma';

  @override
  String get weekdaySaturday => 'Cumartesi';

  @override
  String get weekdaySunday => 'Pazar';

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
  String get dangerZone => 'Tehlikeli Bölge';

  @override
  String get appVersion => 'Uygulama Sürümü';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get deleteAccount => 'Hesabımı Sil';

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
  String get editExpense => 'Harcama Düzenle';

  @override
  String get deleteExpense => 'Harcamayı Sil';

  @override
  String get deleteExpenseConfirm =>
      'Bu harcamayı silmek istediğine emin misin?';

  @override
  String get updateExpense => 'Güncelle';

  @override
  String get expenseHistory => 'Geçmiş';

  @override
  String recordCount(int count) {
    return '$count kayıt';
  }

  @override
  String recordCountLimited(int shown, int total) {
    return '$total kayıttan $shown tanesi';
  }

  @override
  String get unlockFullHistory => 'Tam Geçmişi Aç';

  @override
  String proHistoryDescription(int count) {
    return 'Ücretsiz kullanıcılar son 30 günü görebilir. Sınırsız geçmiş için Pro\'ya yükseltin.';
  }

  @override
  String get upgradeToPro => 'Pro\'ya Yükselt';

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
  String get selectCategory => 'Kategori Seçin';

  @override
  String autoSelected(String category) {
    return 'Otomatik seçildi: $category';
  }

  @override
  String get pleaseSelectCategory => 'Lütfen bir kategori seçin';

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
  String get largeAmountTitle => 'Büyük Tutar';

  @override
  String get largeAmountMessage =>
      'Bu gerçek bir harcama mı, yoksa simülasyon mu?';

  @override
  String get realExpenseButton => 'Gerçek Harcama';

  @override
  String get simulationButton => 'Simülasyon';

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
    return 'Ayın $day. günü';
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
  String get autoRecordDescription =>
      'Harcama fatura tarihinde otomatik eklenecek';

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
  String get hourAbbreviation => 'sa';

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
  String get deleteAccountWarningTitle => 'Hesabınızı Silmek Üzeresiniz';

  @override
  String get deleteAccountWarningMessage =>
      'Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecektir:\n\n• Harcamalar\n• Gelirler\n• Taksitler\n• Birikim Hedefleri\n• Başarımlar\n• Ayarlar';

  @override
  String get deleteAccountConfirmPlaceholder =>
      'Onaylamak için \'Onaylıyorum\' yazın';

  @override
  String get deleteAccountConfirmWord => 'Onaylıyorum';

  @override
  String get deleteAccountButton => 'Hesabı Sil';

  @override
  String get deleteAccountSuccess => 'Hesabınız başarıyla silindi';

  @override
  String get deleteAccountError => 'Hesap silinirken bir hata oluştu';

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
  String get exampleAmount => 'örn: 20.000';

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
  String get habitCatCoffee => 'Kahve';

  @override
  String get habitCatSmoking => 'Sigara';

  @override
  String get habitCatEatingOut => 'Dışarıda Yemek';

  @override
  String get habitCatGaming => 'Oyun/Eğlence';

  @override
  String get habitCatClothing => 'Kıyafet';

  @override
  String get habitCatTaxi => 'Taksi/Uber';

  @override
  String get freqOnceDaily => 'Günde 1';

  @override
  String get freqTwiceDaily => 'Günde 2';

  @override
  String get freqEveryTwoDays => '2 günde 1';

  @override
  String get freqOnceWeekly => 'Haftada 1';

  @override
  String get freqTwoThreeWeekly => 'Haftada 2-3';

  @override
  String get freqFewMonthly => 'Ayda birkaç';

  @override
  String get habitSharePreText => 'Bu alışkanlık yılda';

  @override
  String get habitShareWorkDays => 'İŞ GÜNÜ';

  @override
  String get habitSharePostText => 'çalışmana eşdeğer';

  @override
  String get habitSharePerYear => '/yıl';

  @override
  String get habitShareCTA => 'Senin alışkanlıkların kaç gün?';

  @override
  String get habitShareText => 'Senin alışkanlıkların kaç gün? 👀 vantag.app';

  @override
  String habitShareTextWithLink(String link) {
    return 'Senin alışkanlıkların kaç gün? 👀 $link';
  }

  @override
  String habitMonthlyDetail(int days, int hours) {
    return '$days gün $hours saat';
  }

  @override
  String get editIncomes => 'Gelirleri Düzenle';

  @override
  String get editIncome => 'Gelir Düzenle';

  @override
  String get addIncome => 'Gelir Ekle';

  @override
  String get changePhoto => 'Fotoğraf';

  @override
  String get takePhoto => 'Fotoğraf Çek';

  @override
  String get chooseFromGallery => 'Galeriden Seç';

  @override
  String get removePhoto => 'Fotoğrafı Kaldır';

  @override
  String get photoSelectError => 'Fotoğraf seçilemedi';

  @override
  String get editSalary => 'Maaş';

  @override
  String get editSalarySubtitle => 'Aylık maaşınızı güncelleyin';

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
  String get addAdditionalIncome => '+ Ek Gelir Ekle';

  @override
  String get additionalIncomeQuestion => 'Ek Geliriniz Var mı?';

  @override
  String get budgetSettings => 'Bütçe Ayarları';

  @override
  String get budgetSettingsHint =>
      'İsteğe bağlı. Belirlemezseniz gelirinize göre hesaplanır.';

  @override
  String get monthlySpendingLimit => 'Aylık Harcama Limiti';

  @override
  String get monthlySpendingLimitHint =>
      'Bu ay maksimum ne kadar harcamak istiyorsunuz?';

  @override
  String get monthlySavingsGoal => 'Aylık Tasarruf Hedefi';

  @override
  String get monthlySavingsGoalHint =>
      'Her ay ne kadar biriktirmek istiyorsunuz?';

  @override
  String get budgetInfoMessage =>
      'Progress bar, zorunlu giderler düşüldükten sonra kalan bütçenize göre hesaplanır.';

  @override
  String get linkWithGoogleTitle => 'Google ile Bağla';

  @override
  String get linkWithGoogleDescription =>
      'Verilerinize tüm cihazlardan güvenle erişin';

  @override
  String get skipForNow => 'Şimdilik geç';

  @override
  String get incomeType => 'Gelir türü';

  @override
  String get incomeCategorySalary => 'Maaş';

  @override
  String get incomeCategoryFreelance => 'Freelance';

  @override
  String get incomeCategoryRental => 'Kira Geliri';

  @override
  String get incomeCategoryPassive => 'Pasif Gelir';

  @override
  String get incomeCategoryOther => 'Diğer';

  @override
  String get incomeCategorySalaryDesc => 'Aylık düzenli maaş';

  @override
  String get incomeCategoryFreelanceDesc => 'Serbest çalışma gelirleri';

  @override
  String get incomeCategoryRentalDesc => 'Ev, araba vb. kira gelirleri';

  @override
  String get incomeCategoryPassiveDesc => 'Yatırım, temettü, faiz vb.';

  @override
  String get incomeCategoryOtherDesc => 'Diğer gelir kaynakları';

  @override
  String get mainSalary => 'Ana Maaş';

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
  String get expense => 'GİDER';

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
  String get sharing => 'Paylaşılıyor...';

  @override
  String get frequency => 'Sıklık';

  @override
  String get daysAbbrev => 'gün';

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
  String get autoRecordEnabled => 'Otomatik kayıt açık';

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
  String get shareVia => 'Paylaş';

  @override
  String get saveToGallery => 'Galeriye Kaydet';

  @override
  String get savedToGallery => 'Galeriye kaydedildi';

  @override
  String get otherApps => 'Diğer Uygulamalar';

  @override
  String get expenseDeleted => 'Harcama silindi';

  @override
  String get undo => 'Geri Al';

  @override
  String get choosePlatform => 'Platform Seç';

  @override
  String get savingToGallery => 'Kaydediliyor...';

  @override
  String get pleaseEnterValidSalary => 'Lütfen geçerli bir maaş girin';

  @override
  String get pleaseEnterValidIncomeAmount => 'Lütfen geçerli bir tutar girin';

  @override
  String get atLeastOneIncomeRequired =>
      'En az bir gelir kaynağı eklemelisiniz';

  @override
  String get incomesUpdated => 'Gelirler güncellendi';

  @override
  String get incomesSaved => 'Gelirler kaydedildi';

  @override
  String get saveError => 'Kaydetme sırasında bir hata oluştu';

  @override
  String incomeSourceCount(int count) {
    return '$count gelir kaynağı';
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

  @override
  String get workHoursDistribution => 'Çalışma Saati Dağılımı';

  @override
  String get workHoursDistributionDesc =>
      'Her kategori için kaç saat çalıştığını gör';

  @override
  String hoursShort(String hours) {
    return '${hours}s';
  }

  @override
  String categoryHoursBar(String hours, String percent) {
    return '$hours saat (%$percent)';
  }

  @override
  String get monthComparison => 'Ay Karşılaştırması';

  @override
  String get vsLastMonth => 'Geçen Aya Göre';

  @override
  String get noLastMonthData => 'Geçen ay verisi yok';

  @override
  String decreasedBy(String percent) {
    return '↓ %$percent azaldı';
  }

  @override
  String increasedBy(String percent) {
    return '↑ %$percent arttı';
  }

  @override
  String get noChange => 'Değişim yok';

  @override
  String get greatProgress => 'Harika ilerleme!';

  @override
  String get watchOut => 'Dikkat!';

  @override
  String get smartInsights => 'Akıllı Bilgiler';

  @override
  String get mostExpensiveDay => 'En Pahalı Gün';

  @override
  String mostExpensiveDayValue(String day, String amount) {
    return '$day (ort. $amount TL)';
  }

  @override
  String get mostPassedCategory => 'En Çok Vazgeçilen';

  @override
  String mostPassedCategoryValue(String category, int count) {
    return '$category ($count kez)';
  }

  @override
  String get savingsOpportunity => 'Tasarruf Fırsatı';

  @override
  String savingsOpportunityValue(String category, String hours) {
    return '$category\'i %20 azalt = ayda ${hours}s kazan';
  }

  @override
  String get weeklyTrend => 'Haftalık Trend';

  @override
  String weeklyTrendValue(String trend) {
    return 'Son 4 hafta: $trend';
  }

  @override
  String get overallDecreasing => 'Genel düşüş';

  @override
  String get overallIncreasing => 'Genel artış';

  @override
  String get stableTrend => 'Stabil';

  @override
  String get noTrendData => 'Yeterli veri yok';

  @override
  String get yearlyView => 'Yıllık Görünüm';

  @override
  String get yearlyHeatmap => 'Harcama Trendi';

  @override
  String get yearlyHeatmapDesc => 'Son 12 ayın aylık harcama trendi';

  @override
  String get lowSpending => 'Az';

  @override
  String get highSpending => 'Çok';

  @override
  String get noSpending => 'Harcama yok';

  @override
  String get tapDayForDetails => 'Detay için güne dokun';

  @override
  String get tapMonthForDetails => 'Detay için aya dokun';

  @override
  String selectedDayExpenses(String date, String amount, int count) {
    return '$date: $amount TL ($count harcama)';
  }

  @override
  String selectedMonthExpenses(String month, String amount, int count) {
    return '$month: $amount ($count harcama)';
  }

  @override
  String get proBadge => 'PRO';

  @override
  String get proFeature => 'Pro Özellik';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get mindfulChoice => 'Bilinçli Tercih';

  @override
  String get mindfulChoiceExpandedDesc => 'Aslında ne almayı planlamıştın?';

  @override
  String get mindfulChoiceCollapsedDesc =>
      'Aslında daha pahalısını mı alacaktın?';

  @override
  String get mindfulChoiceAmountLabel => 'Aklındaki Tutar (₺)';

  @override
  String mindfulChoiceAmountHint(String amount) {
    return 'Örn: $amount';
  }

  @override
  String mindfulChoiceSavings(String amount) {
    return '$amount TL tasarruf';
  }

  @override
  String get mindfulChoiceSavingsDesc => 'Bilinçli tercih ile cebinde kalıyor';

  @override
  String get tierBronze => 'Bronz';

  @override
  String get tierSilver => 'Gümüş';

  @override
  String get tierGold => 'Altın';

  @override
  String get tierPlatinum => 'Platin';

  @override
  String get achievementCategoryStreak => 'Seri';

  @override
  String get achievementCategorySavings => 'Tasarruf';

  @override
  String get achievementCategoryDecision => 'Karar';

  @override
  String get achievementCategoryRecord => 'Kayıt';

  @override
  String get achievementCategoryHidden => 'Gizli';

  @override
  String get achievementStreakB1Title => 'Başlangıç';

  @override
  String get achievementStreakB1Desc => '3 gün üst üste kayıt yap';

  @override
  String get achievementStreakB2Title => 'Devam Ediyorum';

  @override
  String get achievementStreakB2Desc => '7 gün üst üste kayıt yap';

  @override
  String get achievementStreakB3Title => 'Rutin Oluşuyor';

  @override
  String get achievementStreakB3Desc => '14 gün üst üste kayıt yap';

  @override
  String get achievementStreakS1Title => 'Kararlılık';

  @override
  String get achievementStreakS1Desc => '30 gün üst üste kayıt yap';

  @override
  String get achievementStreakS2Title => 'Alışkanlık';

  @override
  String get achievementStreakS2Desc => '60 gün üst üste kayıt yap';

  @override
  String get achievementStreakS3Title => 'Disiplin';

  @override
  String get achievementStreakS3Desc => '90 gün üst üste kayıt yap';

  @override
  String get achievementStreakG1Title => 'Güçlü İrade';

  @override
  String get achievementStreakG1Desc => '150 gün üst üste kayıt yap';

  @override
  String get achievementStreakG2Title => 'Sarsılmaz';

  @override
  String get achievementStreakG2Desc => '250 gün üst üste kayıt yap';

  @override
  String get achievementStreakG3Title => 'İstikrar';

  @override
  String get achievementStreakG3Desc => '365 gün üst üste kayıt yap';

  @override
  String get achievementStreakPTitle => 'Süreklilik';

  @override
  String get achievementStreakPDesc => '730 gün üst üste kayıt yap';

  @override
  String get achievementSavingsB1Title => 'İlk Tasarruf';

  @override
  String get achievementSavingsB1Desc => '250 TL kurtardın';

  @override
  String get achievementSavingsB2Title => 'Birikime Başladım';

  @override
  String get achievementSavingsB2Desc => '500 TL kurtardın';

  @override
  String get achievementSavingsB3Title => 'Yolun Başında';

  @override
  String get achievementSavingsB3Desc => '1.000 TL kurtardın';

  @override
  String get achievementSavingsS1Title => 'Bilinçli Harcama';

  @override
  String get achievementSavingsS1Desc => '2.500 TL kurtardın';

  @override
  String get achievementSavingsS2Title => 'Kontrollü';

  @override
  String get achievementSavingsS2Desc => '5.000 TL kurtardın';

  @override
  String get achievementSavingsS3Title => 'Tutarlı';

  @override
  String get achievementSavingsS3Desc => '10.000 TL kurtardın';

  @override
  String get achievementSavingsG1Title => 'Güçlü Birikim';

  @override
  String get achievementSavingsG1Desc => '25.000 TL kurtardın';

  @override
  String get achievementSavingsG2Title => 'Finansal Farkındalık';

  @override
  String get achievementSavingsG2Desc => '50.000 TL kurtardın';

  @override
  String get achievementSavingsG3Title => 'Sağlam Zemin';

  @override
  String get achievementSavingsG3Desc => '100.000 TL kurtardın';

  @override
  String get achievementSavingsP1Title => 'Uzun Vadeli Düşünce';

  @override
  String get achievementSavingsP1Desc => '250.000 TL kurtardın';

  @override
  String get achievementSavingsP2Title => 'Finansal Netlik';

  @override
  String get achievementSavingsP2Desc => '500.000 TL kurtardın';

  @override
  String get achievementSavingsP3Title => 'Büyük Resim';

  @override
  String get achievementSavingsP3Desc => '1.000.000 TL kurtardın';

  @override
  String get achievementDecisionB1Title => 'İlk Karar';

  @override
  String get achievementDecisionB1Desc => '3 kez vazgeçtin';

  @override
  String get achievementDecisionB2Title => 'Direnç';

  @override
  String get achievementDecisionB2Desc => '7 kez vazgeçtin';

  @override
  String get achievementDecisionB3Title => 'Kontrol';

  @override
  String get achievementDecisionB3Desc => '15 kez vazgeçtin';

  @override
  String get achievementDecisionS1Title => 'Kararlılık';

  @override
  String get achievementDecisionS1Desc => '30 kez vazgeçtin';

  @override
  String get achievementDecisionS2Title => 'Netlik';

  @override
  String get achievementDecisionS2Desc => '60 kez vazgeçtin';

  @override
  String get achievementDecisionS3Title => 'Güçlü Seçimler';

  @override
  String get achievementDecisionS3Desc => '100 kez vazgeçtin';

  @override
  String get achievementDecisionG1Title => 'İrade';

  @override
  String get achievementDecisionG1Desc => '200 kez vazgeçtin';

  @override
  String get achievementDecisionG2Title => 'Soğukkanlılık';

  @override
  String get achievementDecisionG2Desc => '400 kez vazgeçtin';

  @override
  String get achievementDecisionG3Title => 'Üst Seviye Kontrol';

  @override
  String get achievementDecisionG3Desc => '700 kez vazgeçtin';

  @override
  String get achievementDecisionPTitle => 'Tam Hakimiyet';

  @override
  String get achievementDecisionPDesc => '1.000 kez vazgeçtin';

  @override
  String get achievementRecordB1Title => 'Başladım';

  @override
  String get achievementRecordB1Desc => '5 harcama kaydı';

  @override
  String get achievementRecordB2Title => 'Takip Ediyorum';

  @override
  String get achievementRecordB2Desc => '15 harcama kaydı';

  @override
  String get achievementRecordB3Title => 'Düzen Oluştu';

  @override
  String get achievementRecordB3Desc => '30 harcama kaydı';

  @override
  String get achievementRecordS1Title => 'Detaylı Takip';

  @override
  String get achievementRecordS1Desc => '60 harcama kaydı';

  @override
  String get achievementRecordS2Title => 'Analitik';

  @override
  String get achievementRecordS2Desc => '120 harcama kaydı';

  @override
  String get achievementRecordS3Title => 'Sistemli';

  @override
  String get achievementRecordS3Desc => '200 harcama kaydı';

  @override
  String get achievementRecordG1Title => 'Derinlik';

  @override
  String get achievementRecordG1Desc => '350 harcama kaydı';

  @override
  String get achievementRecordG2Title => 'Uzmanlaşma';

  @override
  String get achievementRecordG2Desc => '600 harcama kaydı';

  @override
  String get achievementRecordG3Title => 'Arşiv';

  @override
  String get achievementRecordG3Desc => '1.000 harcama kaydı';

  @override
  String get achievementRecordPTitle => 'Uzun Süreli Kayıt';

  @override
  String get achievementRecordPDesc => '2.000 harcama kaydı';

  @override
  String get achievementHiddenNightTitle => 'Gece Kaydı';

  @override
  String get achievementHiddenNightDesc => '00:00-05:00 arası kayıt yap';

  @override
  String get achievementHiddenEarlyTitle => 'Erken Saat';

  @override
  String get achievementHiddenEarlyDesc => '05:00-07:00 arası kayıt yap';

  @override
  String get achievementHiddenWeekendTitle => 'Hafta Sonu Rutini';

  @override
  String get achievementHiddenWeekendDesc => 'Cumartesi-Pazar 5 kayıt';

  @override
  String get achievementHiddenOcrTitle => 'İlk Tarama';

  @override
  String get achievementHiddenOcrDesc => 'İlk fiş OCR kullanımı';

  @override
  String get achievementHiddenBalancedTitle => 'Dengeli Hafta';

  @override
  String get achievementHiddenBalancedDesc => '7 gün üst üste 0 \"Aldım\"';

  @override
  String get achievementHiddenCategoriesTitle => 'Kategori Tamamlama';

  @override
  String get achievementHiddenCategoriesDesc => 'Tüm 6 kategoride kayıt';

  @override
  String get achievementHiddenGoldTitle => 'Altın Denkliği';

  @override
  String get achievementHiddenGoldDesc =>
      'Kurtarılan para 1 gram altın değerinde';

  @override
  String get achievementHiddenUsdTitle => 'Döviz Denkliği';

  @override
  String get achievementHiddenUsdDesc => 'Kurtarılan para 100\$ değerinde';

  @override
  String get achievementHiddenSubsTitle => 'Abonelik Kontrolü';

  @override
  String get achievementHiddenSubsDesc => '5 abonelik takibi';

  @override
  String get achievementHiddenNoSpendTitle => 'Harcamasız Ay';

  @override
  String get achievementHiddenNoSpendDesc => '1 ay boyunca 0 \"Aldım\"';

  @override
  String get achievementHiddenGoldKgTitle => 'Yüksek Değer Birikim';

  @override
  String get achievementHiddenGoldKgDesc =>
      'Kurtarılan para 1 kg altın değerinde';

  @override
  String get achievementHiddenUsd10kTitle => 'Büyük Döviz Denkliği';

  @override
  String get achievementHiddenUsd10kDesc =>
      'Kurtarılan para 10.000\$ değerinde';

  @override
  String get achievementHiddenAnniversaryTitle => 'Kullanım Yıldönümü';

  @override
  String get achievementHiddenAnniversaryDesc => '365 gün kullanım';

  @override
  String get achievementHiddenEarlyAdopterTitle => 'İlk Nesil Kullanıcı';

  @override
  String get achievementHiddenEarlyAdopterDesc =>
      'Uygulamayı 2 yıl önce indirdi';

  @override
  String get achievementHiddenUltimateTitle => 'Uzun Vadeli Disiplin';

  @override
  String get achievementHiddenUltimateDesc =>
      '1.000.000 TL + 365 gün streak aynı anda';

  @override
  String get achievementHiddenCollectorTitle => 'Koleksiyoncu';

  @override
  String get achievementHiddenCollectorDesc =>
      'Platinum hariç tüm rozetleri topladı';

  @override
  String get easterEgg5Left => '5 kaldı...';

  @override
  String get easterEggAlmost => 'Neredeyse...';

  @override
  String get achievementUnlocked => 'Rozet Açıldı!';

  @override
  String get curiousCatTitle => 'Çok Meraklı';

  @override
  String get curiousCatDescription => 'Gizli Easter Egg\'i buldun!';

  @override
  String get great => 'Harika!';

  @override
  String get achievementHiddenCuriousCatTitle => 'Çok Meraklı';

  @override
  String get achievementHiddenCuriousCatDesc => 'Gizli Easter Egg\'i buldun!';

  @override
  String get recentExpenses => 'Son Harcamalar';

  @override
  String get seeMore => 'Tümünü Gör';

  @override
  String get tapPlusToAdd => 'İlk harcamanı eklemek için + butonuna dokun';

  @override
  String get expenseAdded => 'Harcama başarıyla eklendi';

  @override
  String get duplicateExpenseWarning => 'Bu harcama zaten var gibi görünüyor';

  @override
  String duplicateExpenseDetails(String amount, String category) {
    return '$amount TL $category';
  }

  @override
  String get addAnyway => 'Yine de eklemek istiyor musun?';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get timeAgoNow => 'şimdi';

  @override
  String timeAgoMinutes(int count) {
    return '$count dakika önce';
  }

  @override
  String timeAgoHours(int count) {
    return '$count saat önce';
  }

  @override
  String timeAgoDays(int count) {
    return '$count gün önce';
  }

  @override
  String get exportToExcel => 'Excel\'e Aktar';

  @override
  String get exportReport => 'Rapor Dışa Aktar';

  @override
  String get exporting => 'Dışa aktarılıyor...';

  @override
  String get exportSuccess => 'Rapor başarıyla dışa aktarıldı';

  @override
  String get exportError => 'Dışa aktarma başarısız';

  @override
  String get exportComplete => 'Dışa Aktarma Tamamlandı';

  @override
  String get exportShareOption => 'Paylaş';

  @override
  String get exportSaveOption => 'Dosyalarıma Kaydet';

  @override
  String get exportSavedToDownloads => 'Downloads/Vantag klasörüne kaydedildi';

  @override
  String get exportChooseAction => 'Dosya ile ne yapmak istersiniz?';

  @override
  String get csvHeaderDate => 'Tarih';

  @override
  String get csvHeaderTime => 'Saat';

  @override
  String get csvHeaderAmount => 'Tutar';

  @override
  String get csvHeaderCurrency => 'Para Birimi';

  @override
  String get csvHeaderCategory => 'Kategori';

  @override
  String get csvHeaderSubcategory => 'Alt Kategori';

  @override
  String get csvHeaderDescription => 'Açıklama';

  @override
  String get csvHeaderProduct => 'Ürün';

  @override
  String get csvHeaderDecision => 'Karar';

  @override
  String get csvHeaderWorkHours => 'Çalışma Saati';

  @override
  String get csvHeaderInstallment => 'Taksit';

  @override
  String get csvHeaderMandatory => 'Zorunlu';

  @override
  String get csvSummarySection => 'ÖZET';

  @override
  String get csvTotalExpense => 'Toplam Harcama';

  @override
  String get csvCategoryTotals => 'Kategori Toplamları';

  @override
  String get csvDailyAverage => 'Günlük Ortalama';

  @override
  String get csvWeeklyAverage => 'Haftalık Ortalama';

  @override
  String get csvTopCategory => 'En Çok Harcanan Kategori';

  @override
  String get csvLargestExpense => 'En Büyük Harcama';

  @override
  String get csvTotalWorkHours => 'Toplam Çalışma Saati';

  @override
  String get csvPeriod => 'Dönem';

  @override
  String get csvYes => 'Evet';

  @override
  String get csvNo => 'Hayır';

  @override
  String get financialReport => 'Finansal Özet Raporu';

  @override
  String get createdAt => 'Oluşturulma';

  @override
  String get savingsRate => 'Tasarruf Oranı';

  @override
  String get hourlyRate => 'Saatlik Ücret';

  @override
  String get workHoursEquivalent => 'Çalışma Saati Karşılığı';

  @override
  String get transactionCount => 'İşlem Sayısı';

  @override
  String get average => 'Ortalama';

  @override
  String get percentage => 'Yüzde';

  @override
  String get total => 'Toplam';

  @override
  String get monthly => 'Aylık';

  @override
  String get yearly => 'Yıllık';

  @override
  String get changePercent => 'Değişim %';

  @override
  String get month => 'Ay';

  @override
  String get originalAmount => 'Orijinal Tutar';

  @override
  String get nextRenewal => 'Sonraki Yenileme';

  @override
  String get yearlyAmount => 'Yıllık Tutar';

  @override
  String get badge => 'Rozet';

  @override
  String get status => 'Durum';

  @override
  String get earnedDate => 'Kazanılan Tarih';

  @override
  String get totalBadges => 'Toplam Rozet';

  @override
  String get proFeatureExport => 'Excel Dışa Aktarma Pro özelliğidir';

  @override
  String get upgradeForExport =>
      'Finansal verilerinizi dışa aktarmak için Pro\'ya yükseltin';

  @override
  String get importPremiumOnly => 'İçe Aktarma Pro özelliğidir';

  @override
  String get upgradeForImport =>
      'Banka ekstrelerinizi içe aktarmak için Pro\'ya yükseltin';

  @override
  String get receiptScanned => 'Fiş başarıyla tarandı';

  @override
  String get noAmountFound => 'Görüntüde tutar bulunamadı';

  @override
  String saveAllRecognized(int count) {
    return 'Tümünü Kaydet ($count)';
  }

  @override
  String saveAllRecognizedSuccess(int count) {
    return '$count harcama başarıyla kaydedildi';
  }

  @override
  String get budgets => 'Bütçeler';

  @override
  String get budget => 'Bütçe';

  @override
  String get addBudget => 'Bütçe Ekle';

  @override
  String get editBudget => 'Bütçe Düzenle';

  @override
  String get deleteBudget => 'Bütçe Sil';

  @override
  String get deleteBudgetConfirm =>
      'Bu bütçeyi silmek istediğinizden emin misiniz?';

  @override
  String get monthlyLimit => 'Aylık Limit';

  @override
  String get budgetProgress => 'Bütçe Durumu';

  @override
  String get totalBudget => 'Toplam Bütçe';

  @override
  String remainingAmount(String amount) {
    return '$amount kaldı';
  }

  @override
  String overBudgetAmount(String amount) {
    return '$amount aştın!';
  }

  @override
  String ofBudget(String spent, String total) {
    return '$spent / $total';
  }

  @override
  String get onTrack => 'Yolunda';

  @override
  String get nearLimit => 'Limite yakın';

  @override
  String get overLimit => 'Limit aşıldı';

  @override
  String get noBudgetsYet => 'Henüz bütçe yok';

  @override
  String get noBudgetsDescription =>
      'Kategorilere bütçe koyarak harcamalarını takip et';

  @override
  String get budgetHelperText =>
      'Bu kategori için aylık harcama limiti belirle';

  @override
  String get budgetExceededTitle => 'Bütçe Aşıldı!';

  @override
  String budgetExceededMessage(String category, String amount) {
    return '$category bütçeni $amount aştın';
  }

  @override
  String get budgetNearLimit => 'Bütçe limitine yaklaşıyorsun';

  @override
  String budgetNearLimitMessage(String percent, String category) {
    return '$category bütçenin %$percent\'ini kullandın';
  }

  @override
  String categoriesOnTrack(int count) {
    return '$count yolunda';
  }

  @override
  String categoriesOverBudget(int count) {
    return '$count bütçe aşımı';
  }

  @override
  String categoriesNearLimit(int count) {
    return '$count limite yakın';
  }

  @override
  String get categories => 'kategori';

  @override
  String get viewAll => 'Tümünü Gör';

  @override
  String get viewBudgetsInReports =>
      'Bütçe detaylarını Raporlar sekmesinde gör';

  @override
  String pendingCategorization(int count) {
    return '$count harcama kategorize bekliyor';
  }

  @override
  String suggestionsAvailable(int count) {
    return '$count öneri mevcut';
  }

  @override
  String get reviewExpenses => 'Harcamaları İncele';

  @override
  String get swipeToCategorizeTip => 'Kategorize etmek için bir kategori seçin';

  @override
  String get rememberMerchant => 'Bu satıcıyı hatırla';

  @override
  String suggestionLabel(String name) {
    return 'Öneri: $name';
  }

  @override
  String get suggested => 'Önerilen';

  @override
  String get allCategorized => 'Tamamlandı!';

  @override
  String categorizedCount(int processed, int skipped) {
    return '$processed kategorize edildi, $skipped atlandı';
  }

  @override
  String get importStatement => 'Ekstre Yükle';

  @override
  String get importCSV => 'CSV Yükle';

  @override
  String get importFromBank => 'Bankadan İçe Aktar';

  @override
  String get selectCSVFile => 'CSV dosyası seçin';

  @override
  String get importingExpenses => 'Harcamalar içe aktarılıyor...';

  @override
  String importSuccess(int count) {
    return '$count harcama başarıyla içe aktarıldı';
  }

  @override
  String get importError => 'İçe aktarma başarısız';

  @override
  String recognizedExpenses(int count) {
    return '$count tanındı';
  }

  @override
  String pendingExpenses(int count) {
    return '$count inceleme bekliyor';
  }

  @override
  String get importSummary => 'İçe Aktarma Özeti';

  @override
  String get autoMatched => 'Otomatik Eşleşti';

  @override
  String get needsReview => 'İnceleme Gerekli';

  @override
  String get startReview => 'İncelemeye Başla';

  @override
  String get importAIParsed => 'AI ile Ayrıştırılan İşlemler';

  @override
  String get importNoTransactions => 'Bu dosyada işlem bulunamadı';

  @override
  String importSelected(int count) {
    return '$count Seçiliyi Kaydet';
  }

  @override
  String get transactions => 'işlem';

  @override
  String get selectAll => 'Tümünü Seç';

  @override
  String get selectNone => 'Hiçbirini Seçme';

  @override
  String get selected => 'seçili';

  @override
  String get saving => 'Kaydediliyor...';

  @override
  String get learnedMerchants => 'Öğrenilen Satıcılar';

  @override
  String get noLearnedMerchants => 'Henüz öğrenilen satıcı yok';

  @override
  String get learnedMerchantsDescription =>
      'Kategorize ettiğiniz satıcılar burada görünecek';

  @override
  String merchantCount(int count) {
    return '$count satıcı öğrenildi';
  }

  @override
  String get deleteMerchant => 'Satıcıyı Sil';

  @override
  String get deleteMerchantConfirm =>
      'Bu satıcıyı silmek istediğinizden emin misiniz?';

  @override
  String get voiceInput => 'Sesli Giriş';

  @override
  String get listening => 'Dinleniyor...';

  @override
  String get voiceNotAvailable => 'Bu cihazda sesli giriş kullanılamıyor';

  @override
  String get microphonePermissionDenied => 'Mikrofon izni reddedildi';

  @override
  String get microphonePermissionRequired => 'Mikrofon izni gerekli';

  @override
  String get networkRequired => 'İnternet bağlantısı gerekli';

  @override
  String get understanding => 'Anlıyorum...';

  @override
  String get couldNotUnderstandTryAgain => 'Anlayamadım, tekrar dene';

  @override
  String get couldNotUnderstandSayAgain => 'Anlayamadım, tekrar söyle';

  @override
  String get sayAgain => 'Tekrar söyle';

  @override
  String get yesSave => 'Evet, kaydet';

  @override
  String voiceExpenseAdded(String amount, String description) {
    return '$amount₺ $description eklendi';
  }

  @override
  String get voiceConfirmExpense => 'Harcamayı Onayla';

  @override
  String voiceDetectedAmount(String amount) {
    return 'Algılanan: $amount₺';
  }

  @override
  String get tapToSpeak => 'Konuşmak için dokun';

  @override
  String get speakExpense => 'Harcamanı söyle (örn: \"50 lira kahve\")';

  @override
  String get voiceParsingFailed => 'Anlaşılamadı. Lütfen tekrar dene.';

  @override
  String get voiceHighConfidence => 'Otomatik kaydedildi';

  @override
  String get voiceMediumConfidence => 'Düzenlemek için dokun';

  @override
  String get voiceLowConfidence => 'Lütfen onayla';

  @override
  String get speakYourExpense => 'Harcamanı söyle';

  @override
  String get longPressForVoice => 'Sesli giriş için uzun bas';

  @override
  String get didYouKnow => 'Biliyor muydun?';

  @override
  String get voiceTipMessage =>
      'Daha hızlı ekle! + butonuna uzun bas ve söyle: \"50 lira kahve\"';

  @override
  String get gotIt => 'Anladım';

  @override
  String get tryNow => 'Dene';

  @override
  String get voiceAndShortcuts => 'Ses ve Kısayollar';

  @override
  String get newBadge => 'YENİ';

  @override
  String get voiceInputHint => 'Sesle eklemek için + butonuna uzun bas';

  @override
  String get howToUseVoice => 'Sesli Giriş Nasıl Kullanılır';

  @override
  String get voiceLimitReachedTitle => 'Günlük Limit Doldu';

  @override
  String get voiceLimitReachedFree =>
      'Bugünlük sesli giriş hakkın bitti. Pro\'ya geçerek sınırsız kullanabilir veya yarın tekrar deneyebilirsin.';

  @override
  String get voiceServerBusyTitle => 'Sunucular Yoğun';

  @override
  String get voiceServerBusyMessage =>
      'Ses sunucuları şu an yoğun. Lütfen biraz sonra tekrar dene.';

  @override
  String get longPressFab => '+ Butonuna Uzun Bas';

  @override
  String get longPressFabHint => '1 saniye basılı tut';

  @override
  String get micButton => 'Mikrofon Butonu';

  @override
  String get micButtonHint => 'Harcama eklerken mikrofona tıkla';

  @override
  String get exampleCommands => 'Örnek Komutlar';

  @override
  String get voiceExample1 => '\"50 lira kahve\"';

  @override
  String get voiceExample2 => '\"Markete 200 lira verdim\"';

  @override
  String get voiceExample3 => '\"Taksi 150 tuttu\"';

  @override
  String get voiceExamplesMultiline =>
      '\"50 lira kahve\"\n\"markete 200 TL verdim\"\n\"taksi 150 tuttu\"';

  @override
  String get somethingWentWrong => 'Bir şeyler yanlış gitti. Tekrar dene.';

  @override
  String get errorLoadingData => 'Veri yüklenirken hata oluştu';

  @override
  String get errorSaving => 'Kaydedilirken hata oluştu. Tekrar dene.';

  @override
  String get networkError => 'Ağ hatası. Bağlantını kontrol et.';

  @override
  String get errorLoadingRates => 'Döviz kurları yüklenemedi';

  @override
  String get errorLoadingSubscriptions => 'Abonelikler yüklenemedi';

  @override
  String get autoRecorded => 'Otomatik';

  @override
  String autoRecordedExpenses(int count) {
    return '$count abonelik otomatik eklendi';
  }

  @override
  String get security => 'Güvenlik';

  @override
  String get pinLock => 'PIN Kilidi';

  @override
  String get pinLockDescription => 'Uygulamayı açmak için PIN iste';

  @override
  String get biometricUnlock => 'Biyometrik Kilit';

  @override
  String get biometricDescription => 'Parmak izi veya Face ID kullan';

  @override
  String get enterPin => 'PIN Gir';

  @override
  String get createPin => 'PIN Oluştur';

  @override
  String get createPinDescription => '4 haneli bir PIN seç';

  @override
  String get confirmPin => 'PIN\'i Onayla';

  @override
  String get confirmPinDescription => 'PIN\'ini tekrar gir';

  @override
  String get wrongPin => 'Yanlış PIN. Tekrar dene.';

  @override
  String get pinMismatch => 'PIN\'ler eşleşmiyor. Tekrar dene.';

  @override
  String get pinSet => 'PIN başarıyla ayarlandı';

  @override
  String get useBiometric => 'Biyometrik Kullan';

  @override
  String get unlockWithBiometric => 'Vantag\'ı Aç';

  @override
  String get reset => 'Sıfırla';

  @override
  String get assistantSetupTitle => 'Google Assistant Kurulumu';

  @override
  String get assistantSetupHeadline => '\"Vantag\" demeden harcama ekle';

  @override
  String get assistantSetupSubheadline =>
      'Bu kurulumdan sonra sadece\n\"Hey Google, harcama ekle\" demen yeterli';

  @override
  String get assistantSetupComplete =>
      'Harika! Artık \"Hey Google, harcama ekle\" diyebilirsin';

  @override
  String get assistantSetupStep1Title => 'Google Assistant\'ı Aç';

  @override
  String get assistantSetupStep1Desc =>
      '\"Hey Google, ayarlar\" de veya Google Assistant uygulamasını aç.';

  @override
  String get assistantSetupStep1Tip =>
      'Ana sayfada sağ alt köşedeki profil ikonuna tıkla.';

  @override
  String get assistantSetupStep2Title => 'Rutinler\'e Git';

  @override
  String get assistantSetupStep2Desc =>
      'Ayarlar içinde \"Rutinler\" seçeneğini bul ve tıkla.';

  @override
  String get assistantSetupStep2Tip =>
      'Bazı cihazlarda \"Kısayollar\" olarak da geçebilir.';

  @override
  String get assistantSetupStep3Title => 'Yeni Rutin Oluştur';

  @override
  String get assistantSetupStep3Desc =>
      '\"+\" veya \"Yeni rutin\" butonuna tıkla.';

  @override
  String get assistantSetupStep3Tip => 'Sağ alt köşede olabilir.';

  @override
  String get assistantSetupStep4Title => 'Sesli Komut Ekle';

  @override
  String get assistantSetupStep4Desc =>
      '\"Başladığında\" kısmına tıkla ve \"Sesli komut ekle\" seç.\n\n\"Harcama ekle\" yaz.';

  @override
  String get assistantSetupStep4Tip =>
      'İstersen \"Para ekle\" veya \"Masraf kaydet\" de yazabilirsin.';

  @override
  String get assistantSetupStep5Title => 'Eylemi Ekle';

  @override
  String get assistantSetupStep5Desc =>
      '\"Eylem ekle\" → \"Uygulama aç\" → \"Vantag\" seç.';

  @override
  String get assistantSetupStep5Tip =>
      'Vantag listede yoksa arama kutusuna yaz.';

  @override
  String get assistantSetupStep6Title => 'Kaydet';

  @override
  String get assistantSetupStep6Desc =>
      'Sağ üstteki \"Kaydet\" butonuna tıkla.';

  @override
  String get assistantSetupStep6Tip => 'Rutine bir isim vermeni isteyebilir.';

  @override
  String get step => 'Adım';

  @override
  String get next => 'Sonraki';

  @override
  String get back => 'Geri';

  @override
  String get laterButton => 'Daha sonra yaparım';

  @override
  String get monthlySpendingBreakdown => 'Bu Ay Harcama Dağılımı';

  @override
  String get mandatoryExpenses => 'Zorunlu';

  @override
  String get discretionaryExpenses => 'İsteğe Bağlı';

  @override
  String remainingHoursToSpend(String hours) {
    return '$hours saat daha harcayabilirsin';
  }

  @override
  String budgetExceeded(String amount) {
    return 'Bütçeni $amount aştın!';
  }

  @override
  String get activeInstallments => 'Aktif Taksitler';

  @override
  String installmentCount(int count) {
    return '$count taksit';
  }

  @override
  String moreInstallments(int count) {
    return '+$count taksit daha';
  }

  @override
  String get monthlyBurden => 'Aylık Yük';

  @override
  String get remainingDebt => 'Kalan Borç';

  @override
  String totalInterestCost(String amount, String hours) {
    return 'Toplam vade farkı: $amount ($hours saat)';
  }

  @override
  String get monthAbbreviation => 'ay';

  @override
  String get installmentsLabel => 'taksit';

  @override
  String get remaining => 'Kalan';

  @override
  String get paywallTitle => 'Premium\'a Geç';

  @override
  String get paywallSubtitle =>
      'Tüm özelliklerin kilidini aç ve finansal özgürlüğüne ulaş';

  @override
  String get subscribeToPro => 'Pro\'ya Abone Ol';

  @override
  String get startFreeTrial => '7 Gün Ücretsiz Dene';

  @override
  String get freeTrialBanner => '7 GÜN ÜCRETSİZ';

  @override
  String get freeTrialDescription =>
      'İlk 7 gün tamamen ücretsiz, istediğin zaman iptal et';

  @override
  String trialThenPrice(String price) {
    return 'Deneme sonrası $price/ay';
  }

  @override
  String get noPaymentNow => 'Şimdi ödeme yapılmayacak';

  @override
  String get restorePurchases => 'Satın alımları geri yükle';

  @override
  String get feature => 'Özellik';

  @override
  String get featureAiChat => 'AI Sohbet';

  @override
  String get featureAiChatFree => '4/gün';

  @override
  String get featureHistory => 'Geçmiş';

  @override
  String get featureHistory30Days => '30 gün';

  @override
  String get featureExport => 'Excel Dışa Aktarma';

  @override
  String get featureWidgets => 'Widgetlar';

  @override
  String get featureAds => 'Reklamlar';

  @override
  String get featureUnlimited => 'Sınırsız';

  @override
  String get featureYes => 'Evet';

  @override
  String get featureNo => 'Hayır';

  @override
  String get weekly => 'Haftalık';

  @override
  String get week => 'hafta';

  @override
  String get year => 'yıl';

  @override
  String get bestValue => 'En İyi Değer';

  @override
  String get yearlySavings => '%50\'ye varan tasarruf';

  @override
  String get cancelAnytime => 'İstediğin zaman iptal et';

  @override
  String get aiLimitReached => 'Günlük AI limitine ulaştın';

  @override
  String aiLimitMessage(int used, int limit) {
    return 'Bugün $used/$limit AI sohbet hakkını kullandın. Sınırsız erişim için Pro\'ya yükselt.';
  }

  @override
  String get historyLimitReached => 'Geçmiş sınırına ulaştın';

  @override
  String get historyLimitMessage =>
      'Ücretsiz planda sadece son 30 günlük geçmişi görebilirsin. Tüm geçmişe erişmek için Pro\'ya yükselt.';

  @override
  String get exportProOnly => 'Excel dışa aktarma Pro özelliğidir';

  @override
  String remainingAiUses(int count) {
    return '$count AI hakkın kaldı';
  }

  @override
  String get lifetime => 'Ömür Boyu';

  @override
  String get lifetimeDescription =>
      'Bir kere öde, sonsuza kadar kullan • Ayda 100 AI kredisi';

  @override
  String get oneTime => 'tek seferlik';

  @override
  String get forever => 'SONSUZA KADAR';

  @override
  String get mostPopular => 'EN POPÜLER';

  @override
  String monthlyCredits(int count) {
    return 'Ayda $count AI kredisi';
  }

  @override
  String proMonthlyCredits(int remaining, int limit) {
    return '$remaining/$limit aylık kredi';
  }

  @override
  String get aiLimitFreeTitleEmoji => '🔒 Günlük AI Limitine Ulaştın!';

  @override
  String get aiLimitProTitleEmoji => '⏳ Aylık AI Limitine Ulaştın!';

  @override
  String get aiLimitFreeMessage => 'Bugün 4 AI soru hakkını kullandın.';

  @override
  String get aiLimitProMessage => 'Bu ay 500 AI soru hakkını kullandın.';

  @override
  String get aiLimitLifetimeMessage => 'Bu ay 200 AI kredini kullandın.';

  @override
  String aiLimitResetDate(String day, String month, int days) {
    return 'Limitin $day $month\'ta yenilenir ($days gün kaldı)';
  }

  @override
  String get aiLimitUpgradeToPro => '🚀 Pro\'ya Geç - Sınırsız AI';

  @override
  String get aiLimitBuyCredits => '🔋 Ek Kredi Paketi Al';

  @override
  String get aiLimitTryTomorrow => 'veya yarın tekrar dene';

  @override
  String aiLimitOrWaitDays(int days) {
    return 'veya $days gün sonra yenilenir';
  }

  @override
  String get aiRateLimitTitle => 'Biraz yavaşla!';

  @override
  String get aiRateLimitMessage => 'Çok fazla istek gönderdin, biraz bekle.';

  @override
  String aiRateLimitWait(int minutes) {
    return '$minutes dk bekle';
  }

  @override
  String get creditPurchaseTitle => 'Kredi Satın Al';

  @override
  String get creditPurchaseHeader => 'AI Kredisi Yükle';

  @override
  String get creditPurchaseSubtitle =>
      'Aylık limitin dışında ekstra AI sorguları için kredi satın al.';

  @override
  String get creditCurrentBalance => 'Mevcut Bakiye';

  @override
  String creditAmount(int credits) {
    return '$credits Kredi';
  }

  @override
  String creditPackTitle(int credits) {
    return '$credits Kredi';
  }

  @override
  String creditPackPricePerCredit(String price) {
    return 'Kredi başına ₺$price';
  }

  @override
  String get creditPackPopular => 'EN POPÜLER';

  @override
  String get creditPackBestValue => 'EN TASARRUFLU';

  @override
  String get creditNeverExpire =>
      'Krediler asla sona ermez, istediğin zaman kullan';

  @override
  String creditPurchaseSuccess(int credits) {
    return '$credits kredi hesabına eklendi!';
  }

  @override
  String get pursuits => 'Hayallerim';

  @override
  String get myPursuits => 'Hayallerim';

  @override
  String get navPursuits => 'Hayaller';

  @override
  String get createPursuit => 'Yeni Hayal';

  @override
  String get pursuitName => 'Ne için biriktiriyorsun?';

  @override
  String get pursuitNameHint => 'ör: iPhone 16, Maldivler Tatili...';

  @override
  String get targetAmount => 'Hedef Tutar';

  @override
  String get savedAmount => 'Biriken';

  @override
  String get addSavings => 'Para Ekle';

  @override
  String pursuitProgress(int percent) {
    return '%$percent tamamlandı';
  }

  @override
  String daysToGoal(int days) {
    return '≈ $days iş günü';
  }

  @override
  String get pursuitCompleted => 'Hayalin Gerçek Oldu!';

  @override
  String get congratulations => 'Tebrikler!';

  @override
  String pursuitCompletedMessage(int days, String amount) {
    return '$days günde $amount biriktirdin!';
  }

  @override
  String get shareProgress => 'İlerlemeyi Paylaş';

  @override
  String get activePursuits => 'Aktif';

  @override
  String get completedPursuits => 'Gerçekleşenler';

  @override
  String get archivePursuit => 'Arşivle';

  @override
  String get deletePursuit => 'Sil';

  @override
  String get editPursuit => 'Düzenle';

  @override
  String get deletePursuitConfirm =>
      'Bu hayali silmek istediğinize emin misiniz?';

  @override
  String get pursuitCategoryTech => 'Teknoloji';

  @override
  String get pursuitCategoryTravel => 'Seyahat';

  @override
  String get pursuitCategoryHome => 'Ev';

  @override
  String get pursuitCategoryFashion => 'Moda';

  @override
  String get pursuitCategoryVehicle => 'Araç';

  @override
  String get pursuitCategoryEducation => 'Eğitim';

  @override
  String get pursuitCategoryHealth => 'Sağlık';

  @override
  String get pursuitCategoryOther => 'Diğer';

  @override
  String get emptyPursuitsTitle => 'Hayaline Bir Adım At';

  @override
  String get emptyPursuitsMessage => 'İlk hayalini ekle ve biriktirmeye başla!';

  @override
  String get addFirstPursuit => 'İlk Hayalini Ekle';

  @override
  String get pursuitLimitReached => 'Sınırsız hayal için Pro\'ya geç';

  @override
  String get quickAmounts => 'Hızlı Tutarlar';

  @override
  String get addNote => 'Not ekle (opsiyonel)';

  @override
  String get pursuitCreated => 'Hayal oluşturuldu!';

  @override
  String get savingsAdded => 'Eklendi!';

  @override
  String workHoursRemaining(String hours) {
    return '$hours saatlik emek kaldı';
  }

  @override
  String get pursuitInitialSavings => 'Başlangıç Birikimi';

  @override
  String get pursuitInitialSavingsHint => 'Zaten biriktirdiğin tutar';

  @override
  String get pursuitSelectCategory => 'Kategori Seç';

  @override
  String get redirectSavings => 'Tasarrufu Hayale Aktar';

  @override
  String redirectSavingsMessage(String amount) {
    return 'Vazgeçtiğin $amount tutarı hangi hayaline eklemek istersin?';
  }

  @override
  String get skipRedirect => 'Şimdilik Atla';

  @override
  String get pursuitTransactionHistory => 'İşlem Geçmişi';

  @override
  String get noTransactions => 'Henüz işlem yok';

  @override
  String get transactionSourceManual => 'Manuel Ekleme';

  @override
  String get transactionSourcePool => 'Havuzdan Transfer';

  @override
  String get transactionSourceExpense => 'Vazgeçilen Harcama';

  @override
  String get savingsPool => 'Tasarruf Havuzu';

  @override
  String get savingsPoolAvailable => 'kullanılabilir';

  @override
  String get savingsPoolDebt => 'Borçlusun';

  @override
  String shadowDebtMessage(String amount) {
    return 'Gelecekteki kendinden $amount borç aldın';
  }

  @override
  String budgetShiftQuestion(String amount) {
    return 'Bu $amount hangi bütçenden geldi?';
  }

  @override
  String get jokerUsed => 'Bu ayki joker hakkını kullandın';

  @override
  String get jokerAvailable => 'Joker hakkın var!';

  @override
  String allocatedToDreams(String amount) {
    return '$amount hayallerine ayrıldı';
  }

  @override
  String get extraIncome => 'Ekstra gelir elde ettim';

  @override
  String get useJoker => 'Joker Kullan (ayda 1)';

  @override
  String get budgetShiftFromFood => 'Yemek bütçemden';

  @override
  String get budgetShiftFromEntertainment => 'Eğlence bütçemden';

  @override
  String get budgetShiftFromClothing => 'Giyim bütçemden';

  @override
  String get budgetShiftFromTransport => 'Ulaşım bütçemden';

  @override
  String get budgetShiftFromShopping => 'Alışveriş bütçemden';

  @override
  String get budgetShiftFromHealth => 'Sağlık bütçemden';

  @override
  String get budgetShiftFromEducation => 'Eğitim bütçemden';

  @override
  String get insufficientFunds => 'Yetersiz bakiye';

  @override
  String insufficientFundsMessage(String available, String requested) {
    return 'Havuzda $available var, $requested istiyorsun';
  }

  @override
  String get createShadowDebt => 'Yine de ekle (borç oluştur)';

  @override
  String debtRepaidMessage(String amount) {
    return 'Borcundan $amount ödendi!';
  }

  @override
  String get poolSummaryTotal => 'Toplam Tasarruf';

  @override
  String get poolSummaryAllocated => 'Hayallere Ayrılan';

  @override
  String get poolSummaryAvailable => 'Kullanılabilir';

  @override
  String get overAllocationTitle => 'Yetersiz Havuz Bakiyesi';

  @override
  String overAllocationMessage(String available, String requested) {
    return 'Havuzda $available var. $requested eklemek istiyorsun.';
  }

  @override
  String get fromMyPocket => 'Cebimden ekle';

  @override
  String fromMyPocketDesc(String difference) {
    return 'Havuzu sıfırla + $difference cebimden ekle';
  }

  @override
  String get deductFromFuture => 'İleriki tasarruflardan düş';

  @override
  String deductFromFutureDesc(String amount) {
    return 'Havuz $amount eksiye düşer';
  }

  @override
  String transferAvailableOnly(String amount) {
    return 'Sadece $amount aktar';
  }

  @override
  String get transferAvailableOnlyDesc => 'Havuzdaki kadarını ekle';

  @override
  String get oneTimeIncomeTitle => 'Bu para nereden?';

  @override
  String get oneTimeIncomeDesc => 'Havuzun ekside. Kaynağı seç:';

  @override
  String get oneTimeIncomeOption => 'Tek seferlik gelir';

  @override
  String get oneTimeIncomeOptionDesc => 'Havuzu etkilemez, direkt hedefe gider';

  @override
  String get fromSavingsOption => 'Tasarruflarımdan';

  @override
  String get fromSavingsOptionDesc => 'Havuz daha da eksiye düşer';

  @override
  String debtWarningOnPurchase(String amount) {
    return 'Hayallerine $amount borcun var!';
  }

  @override
  String get debtReminderNotification =>
      'Hayallerine olan borcunu ödemeyi unutma!';

  @override
  String get aiThinking => 'Düşünüyor...';

  @override
  String get aiSuggestion1 => 'Bu ay nereye harcadım?';

  @override
  String get aiSuggestion2 => 'Nereden tasarruf edebilirim?';

  @override
  String get aiSuggestion3 => 'En pahalı alışkanlığım ne?';

  @override
  String get aiSuggestion4 => 'Hedefime ne kadar kaldı?';

  @override
  String get aiPremiumUpsell =>
      'Detaylı analiz ve kişisel tasarruf planı için Premium\'a geç';

  @override
  String get aiPremiumButton => 'Premium\'a Geç';

  @override
  String get aiInputPlaceholderFree => 'Kendi sorunu sor 🔒';

  @override
  String get aiInputPlaceholder => 'Bir şey sor...';

  @override
  String get onboardingTryTitle => 'Haydi Deneyelim!';

  @override
  String get onboardingTrySubtitle =>
      'Ne kadar çalıştığını merak ettiğin bir şey var mı?';

  @override
  String get onboardingTryButton => 'Hesapla';

  @override
  String get onboardingTryDisclaimer =>
      'Bu sadece paranın ne kadar soyut, zamanın ne kadar somut olduğunu göstermek içindi.';

  @override
  String get onboardingTryNotSaved =>
      'Merak etme, bu harcamalara kaydedilmedi.';

  @override
  String get onboardingContinue => 'Uygulamaya Geç';

  @override
  String onboardingTryResult(String hours) {
    return 'Bu harcama hayatından $hours saat götürüyor';
  }

  @override
  String get subscriptionPriceHint => '₺99.99';

  @override
  String currencyUpdatePopup(
    String oldAmount,
    String oldCurrency,
    String newAmount,
    String newCurrency,
  ) {
    return 'Kur güncelleniyor: $oldAmount $oldCurrency ≈ $newAmount $newCurrency olarak güncellendi';
  }

  @override
  String get currencyConverting => 'Para birimi dönüştürülüyor...';

  @override
  String get currencyConversionFailed =>
      'Döviz kuru alınamadı, değerler değiştirilmedi';

  @override
  String get requiredExpense => 'Zorunlu Gider';

  @override
  String get installmentPurchase => 'Taksitli Alım';

  @override
  String get installmentInfo => 'Taksit Bilgileri';

  @override
  String get cashPrice => 'Peşin Fiyat';

  @override
  String get cashPriceHint => 'Ürünün peşin fiyatı';

  @override
  String get numberOfInstallments => 'Taksit Sayısı';

  @override
  String get totalInstallmentPrice => 'Taksitli Toplam Fiyat';

  @override
  String get totalWithInterestHint => 'Vade farkı dahil toplam';

  @override
  String get installmentSummary => 'TAKSİT ÖZETİ';

  @override
  String get willBeSavedAsRequired => 'Zorunlu gider olarak kaydedilecek';

  @override
  String get creditCardOrStoreInstallment => 'Kredi kartı veya mağaza taksiti';

  @override
  String get vantagAI => 'Vantag AI';

  @override
  String get professionalMode => 'Profesyonel mod';

  @override
  String get friendlyMode => 'Samimi mod';

  @override
  String get errorTryAgain => 'Bir hata oluştu, tekrar dener misin?';

  @override
  String get aiFallbackOverBudget =>
      'Bütçe biraz zorlanıyor gibi.\nGel birlikte bakalım ne yapabiliriz?';

  @override
  String get aiFallbackHighUsage =>
      'Ayın sonuna az kaldı, dikkatli olalım.\nNasıl yardımcı olabilirim?';

  @override
  String get aiFallbackMediumUsage =>
      'Bütçe idare ediyor.\nBir şey sormak ister misin?';

  @override
  String get aiFallbackLowUsage =>
      'Bütçen gayet iyi durumda!\nNeyi analiz edelim?';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get mostSpendingDay => 'En Çok Harcama Günü';

  @override
  String get biggestCategory => 'En Büyük Kategori';

  @override
  String get thisMonthVsLast => 'Bu Ay vs Geçen Ay';

  @override
  String get monday => 'Pazartesi';

  @override
  String get tuesday => 'Salı';

  @override
  String get wednesday => 'Çarşamba';

  @override
  String get thursday => 'Perşembe';

  @override
  String get friday => 'Cuma';

  @override
  String get saturday => 'Cumartesi';

  @override
  String get sunday => 'Pazar';

  @override
  String get securePayment => 'Güvenli Ödeme';

  @override
  String get encrypted => 'Şifreli';

  @override
  String get syncing => 'Veriler senkronize ediliyor...';

  @override
  String pendingSync(int count) {
    return '$count değişiklik bekliyor';
  }

  @override
  String get pendingLabel => 'Bekliyor';

  @override
  String insightMinutes(int minutes) {
    return 'Bu harcama hayatından $minutes dakika aldı.';
  }

  @override
  String insightHours(String hours) {
    return 'Bu harcama hayatından $hours saat aldı.';
  }

  @override
  String get insightAlmostDay => 'Bu harcama için neredeyse bir gün çalıştın.';

  @override
  String insightDays(String days) {
    return 'Bu harcama hayatından $days gün aldı.';
  }

  @override
  String insightDaysWorked(String days) {
    return 'Bu harcama için $days gün çalışman gerekti.';
  }

  @override
  String get insightAlmostMonth =>
      'Bu harcama neredeyse bir aylık emeğine mal oldu.';

  @override
  String insightCategoryDays(String category, String days) {
    return 'Bu ay $category için $days gün çalıştın.';
  }

  @override
  String insightCategoryHours(String category, String hours) {
    return 'Bu ay $category için $hours saat çalıştın.';
  }

  @override
  String get insightMonthlyAlmost =>
      'Bu ayki harcamalar için neredeyse tüm ay çalıştın.';

  @override
  String insightMonthlyDays(String days) {
    return 'Bu ay harcamalar için $days gün çalıştın.';
  }

  @override
  String get msgShort1 => 'Birkaç saatlik emeğin, bir anlık heves için mi?';

  @override
  String get msgShort2 =>
      'Bu kadar kısa sürede kazandığın parayı harcamak kolay, kazanmak zor.';

  @override
  String get msgShort3 => 'Sabah işe gittin, öğlene kalmadan bu para gidecek.';

  @override
  String get msgShort4 =>
      'Bir kahve molası kadar sürede kazandın, bir tıkla gidecek.';

  @override
  String get msgShort5 => 'Yarım günlük mesai, tam günlük pişmanlık olmasın.';

  @override
  String get msgShort6 => 'Bu ürün için çalıştığın saatleri düşün.';

  @override
  String get msgShort7 => 'Küçük görünüyor ama toplamda büyük fark yaratıyor.';

  @override
  String get msgShort8 => 'Şimdi değil dersen, yarın da olur.';

  @override
  String get msgMedium1 => 'Bir haftalık emeğin bu ürüne değer mi?';

  @override
  String get msgMedium2 =>
      'Bu parayı biriktirmek günler aldı, harcamak saniyeler alacak.';

  @override
  String get msgMedium3 =>
      'Bir haftanı buna yatırıyor olsaydın kabul eder miydin?';

  @override
  String get msgMedium4 => 'Günlerce emek, anlık bir karar.';

  @override
  String get msgMedium5 => 'Hafta sonu tatili mi, bu ürün mü?';

  @override
  String get msgMedium6 => 'Bu kadar gün boyunca ne için çalıştığını hatırla.';

  @override
  String get msgMedium7 => 'Pazartesiden cumaya kadar bunun için mi çalıştın?';

  @override
  String get msgMedium8 => 'Haftalık bütçeni tek seferde harcamak mantıklı mı?';

  @override
  String get msgLong1 =>
      'Haftalarca çalışman gerekiyor bunun için. Gerçekten değer mi?';

  @override
  String get msgLong2 => 'Bu parayı biriktirmek aylar alabilir.';

  @override
  String get msgLong3 =>
      'Uzun vadeli hedeflerinden birini erteliyor olabilirsin.';

  @override
  String get msgLong4 =>
      'Bu ürün için harcayacağın zaman, tatil planlarını etkiler mi?';

  @override
  String get msgLong5 => 'Bu yatırım mı, harcama mı?';

  @override
  String get msgLong6 => 'Gelecekteki sen bu kararı nasıl değerlendirir?';

  @override
  String get msgLong7 =>
      'Bu kadar uzun süre çalışmak, kalıcı bir şey için olmalı.';

  @override
  String get msgLong8 => 'Ay sonunda bu karara nasıl bakacaksın?';

  @override
  String get msgSim1 =>
      'Bu rakam artık bir harcama değil, ciddi bir yatırım kararı.';

  @override
  String get msgSim2 =>
      'Böyle büyük bir tutar için duygularınla değil, vizyonunla karar ver.';

  @override
  String get msgSim3 => 'Bu tutarın karşılığı olan zamanı hesaplamak bile güç.';

  @override
  String get msgSim4 => 'Hayallerini süsleyen o büyük adım bu olabilir mi?';

  @override
  String get msgSim5 =>
      'Bu kadar büyük bir rakamı yönetmek, sabır ve strateji ister.';

  @override
  String get msgSim6 =>
      'Cüzdanını değil, geleceğini etkileyecek bir noktadasın.';

  @override
  String get msgSim7 =>
      'Büyük rakamlar, büyük sorumluluklar getirir. Hazır mısın?';

  @override
  String get msgSim8 =>
      'Bu tutar senin için sadece bir sayı mı, yoksa bir dönüm noktası mı?';

  @override
  String get msgYes1 => 'Kaydettim. Umarım değer.';

  @override
  String get msgYes2 => 'Bakalım pişman olacak mısın.';

  @override
  String get msgYes3 => 'Tamam, senin paran.';

  @override
  String get msgYes4 => 'Aldın aldın, hayırlı olsun.';

  @override
  String get msgYes5 => 'Keyfin bilir.';

  @override
  String get msgYes6 => 'Peki, kayıtlara geçti.';

  @override
  String get msgYes7 => 'İhtiyaçsa sorun yok.';

  @override
  String get msgYes8 => 'Bazen harcamak da gerekir.';

  @override
  String get msgNo1 => 'Güzel karar. Bu parayı kurtardın.';

  @override
  String get msgNo2 => 'Zor olanı seçtin, gelecekte teşekkür edeceksin.';

  @override
  String get msgNo3 => 'İrade kazandı.';

  @override
  String get msgNo4 => 'Akıllıca. Bu para sana lazım olacak.';

  @override
  String get msgNo5 => 'Vazgeçmek de bir kazanım.';

  @override
  String get msgNo6 => 'Heves geçti, para kaldı.';

  @override
  String get msgNo7 => 'Kendine yatırım yaptın aslında.';

  @override
  String get msgNo8 => 'Zor karar, doğru karar.';

  @override
  String get msgThink1 => 'Düşünmek bedava, harcamak değil.';

  @override
  String get msgThink2 => 'Acele etmemek akıllıca.';

  @override
  String get msgThink3 => 'Bir gece uyu, yarın tekrar bak.';

  @override
  String get msgThink4 => '24 saat bekle, hala istiyorsan gel.';

  @override
  String get msgThink5 => 'Tereddüt ediyorsan muhtemelen gerekli değil.';

  @override
  String get msgThink6 => 'Zaman en iyi danışman.';

  @override
  String get msgThink7 => 'Acil değilse, acele etme.';

  @override
  String get msgThink8 => 'Emin değilsen, cevap muhtemelen hayır.';

  @override
  String get savingMsg1 => 'Harika karar! 💪';

  @override
  String get savingMsg2 => 'Paranı korudun! 🛡️';

  @override
  String get savingMsg3 => 'Gelecekteki sen teşekkür edecek!';

  @override
  String get savingMsg4 => 'Akıllı tercih! 🧠';

  @override
  String get savingMsg5 => 'Biriktirmek güçtür!';

  @override
  String get savingMsg6 => 'Hedefine bir adım daha yaklaştın!';

  @override
  String get savingMsg7 => 'İrade gücü! 💎';

  @override
  String get savingMsg8 => 'Bu para artık senin!';

  @override
  String get savingMsg9 => 'Finansal disiplin! 🎯';

  @override
  String get savingMsg10 => 'Zenginlik inşa ediyorsun!';

  @override
  String get savingMsg11 => 'Güçlü karar! 💪';

  @override
  String get savingMsg12 => 'Cüzdanın teşekkür ediyor!';

  @override
  String get savingMsg13 => 'Şampiyonlar böyle biriktirir! 🏆';

  @override
  String get savingMsg14 => 'Biriken para = Kazanılan özgürlük!';

  @override
  String get savingMsg15 => 'Etkileyici öz kontrol! ⭐';

  @override
  String get spendingMsg1 => 'Kaydedildi! ✓';

  @override
  String get spendingMsg2 => 'Takip ediyorsun, bu önemli.';

  @override
  String get spendingMsg3 => 'Her kayıt bir farkındalık.';

  @override
  String get spendingMsg4 => 'Harcamalarını bilmek güç.';

  @override
  String get spendingMsg5 => 'Kaydedildi! Devam et.';

  @override
  String get spendingMsg6 => 'Takip etmek kontrol sağlar.';

  @override
  String get spendingMsg7 => 'Not alındı! Farkındalık anahtar.';

  @override
  String get spendingMsg8 => 'Takip ettiğin için aferin!';

  @override
  String get spendingMsg9 => 'Veri güçtür! 📊';

  @override
  String get spendingMsg10 => 'Farkında ol, kontrol sende.';

  @override
  String get tourAmountTitle => 'Tutar Girişi';

  @override
  String get tourAmountDesc =>
      'Harcama tutarını buraya gir. Fiş tarama butonu ile fişten otomatik okuyabilirsin.';

  @override
  String get tourDescriptionTitle => 'Akıllı Eşleştirme';

  @override
  String get tourDescriptionDesc =>
      'Mağaza veya ürün adını yaz. Migros, A101, Starbucks gibi... Uygulama otomatik olarak kategori önerecek!';

  @override
  String get tourCategoryTitle => 'Kategori Seçimi';

  @override
  String get tourCategoryDesc =>
      'Akıllı eşleştirme bulamazsa veya düzeltmek istersen buradan manuel seçim yapabilirsin.';

  @override
  String get tourDateTitle => 'Geçmiş Tarih Seçimi';

  @override
  String get tourDateDesc =>
      'Dün veya önceki günlerin harcamalarını da girebilirsin. Takvim ikonuna tıklayarak istediğin tarihi seç.';

  @override
  String get tourSnapshotTitle => 'Finansal Özet';

  @override
  String get tourSnapshotDesc =>
      'Aylık gelirin, harcamaların ve kurtardığın para burada. Tüm veriler anlık güncellenir.';

  @override
  String get tourCurrencyTitle => 'Döviz Kurları';

  @override
  String get tourCurrencyDesc =>
      'Güncel USD, EUR ve altın fiyatları. Tıklayarak detaylı bilgi alabilirsin.';

  @override
  String get tourStreakTitle => 'Seri Takibi';

  @override
  String get tourStreakDesc =>
      'Her gün harcama girdiğinde serin artar. Düzenli takip etmek bilinçli harcamanın anahtarı!';

  @override
  String get tourSubscriptionTitle => 'Abonelikler';

  @override
  String get tourSubscriptionDesc =>
      'Netflix, Spotify gibi düzenli aboneliklerini buradan takip et. Yaklaşan ödemeler için bildirim alırsın.';

  @override
  String get tourReportTitle => 'Raporlar';

  @override
  String get tourReportDesc =>
      'Aylık ve kategorilere göre harcama analizlerini buradan görüntüle.';

  @override
  String get tourAchievementsTitle => 'Rozetler';

  @override
  String get tourAchievementsDesc =>
      'Tasarruf hedeflerine ulaştıkça rozetler kazan. Motivasyonunu yüksek tut!';

  @override
  String get tourProfileTitle => 'Profil';

  @override
  String get tourProfileDesc =>
      'Hesap ayarlarını ve premium özelliklerini burada yönet';

  @override
  String get tourQuickAddTitle => 'Hızlı Ekleme';

  @override
  String get tourQuickAddDesc =>
      'Her yerden hızlıca harcama eklemek için bu butonu kullan. Pratik ve hızlı!';

  @override
  String get notifChannelName => 'Vantag Bildirimleri';

  @override
  String get notifChannelDescription => 'Finansal takip bildirimleri';

  @override
  String get notifTitleThinkAboutIt => 'Bir düşün';

  @override
  String get notifTitleCongratulations => 'Tebrikler';

  @override
  String get notifTitleStreakWaiting => 'Serin bekliyor';

  @override
  String get notifTitleWeeklySummary => 'Haftalık özet';

  @override
  String get notifTitleSubscriptionReminder => 'Abonelik hatırlatma';

  @override
  String get aiGreeting =>
      'Merhaba! Ben Vantag.\nFinansal sorularını yanıtlamaya hazırım.';

  @override
  String get aiServiceUnavailable =>
      'AI asistan şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get onboardingHookTitle => 'Bu kahve 47 dakikan';

  @override
  String get onboardingHookSubtitle => 'Her harcamanın gerçek maliyetini gör';

  @override
  String get pursuitOnboardingTitle => 'Hedefin ne?';

  @override
  String get pursuitOnboardingSubtitle => 'Biriktirmek istediğin bir şey seç';

  @override
  String get pursuitOnboardingAirpods => 'AirPods';

  @override
  String get pursuitOnboardingIphone => 'iPhone';

  @override
  String get pursuitOnboardingVacation => 'Tatil';

  @override
  String get pursuitOnboardingCustom => 'Kendi hedefim';

  @override
  String get pursuitOnboardingCta => 'Bunu istiyorum';

  @override
  String get pursuitOnboardingSkip => 'Şimdilik geç';

  @override
  String pursuitOnboardingHours(int hours) {
    return '$hours saat';
  }

  @override
  String get celebrationTitle => 'Tebrikler!';

  @override
  String celebrationSubtitle(String goalName) {
    return '$goalName hedefine ulaştın!';
  }

  @override
  String celebrationTotalSaved(String hours) {
    return 'Toplam biriktirdiğin: $hours saat';
  }

  @override
  String celebrationDuration(int days) {
    return 'Süre: $days gün';
  }

  @override
  String get celebrationShare => 'Paylaş';

  @override
  String get celebrationNewGoal => 'Yeni Hedef';

  @override
  String get celebrationDismiss => 'Kapat';

  @override
  String get widgetTodayLabel => 'Bugün';

  @override
  String get widgetHoursAbbrev => 's';

  @override
  String get widgetMinutesAbbrev => 'dk';

  @override
  String get widgetSetGoal => 'Hedef belirle';

  @override
  String get widgetNoData => 'Başlamak için aç';

  @override
  String get widgetSmallTitle => 'Günlük Harcama';

  @override
  String get widgetSmallDesc => 'Bugünkü harcamanı saat olarak gör';

  @override
  String get widgetMediumTitle => 'Harcama + Hedef';

  @override
  String get widgetMediumDesc => 'Harcama ve hedef takibi';

  @override
  String accessibilityTodaySpending(String amount, int hours, int minutes) {
    return 'Bugün $amount harcadın, bu $hours saat $minutes dakika çalışmana eşit';
  }

  @override
  String accessibilitySpendingProgress(int percentage) {
    return 'Harcama ilerlemesi: bütçenin yüzde $percentage\'i kullanıldı';
  }

  @override
  String accessibilityExpenseItem(
    String category,
    String amount,
    String hours,
    String decision,
  ) {
    return '$category harcaması $amount, $hours saat sürdü, durum: $decision';
  }

  @override
  String accessibilityPursuitCard(
    String name,
    String saved,
    String target,
    int percentage,
  ) {
    return '$name hedefi, $target hedeften $saved biriktirildi, yüzde $percentage tamamlandı';
  }

  @override
  String get accessibilityAddExpense => 'Yeni harcama ekle';

  @override
  String get accessibilityDecisionYes => 'Satın alındı';

  @override
  String get accessibilityDecisionNo => 'Vazgeçildi';

  @override
  String get accessibilityDecisionThinking => 'Düşünülüyor';

  @override
  String get accessibilityDashboard =>
      'Gelir, gider ve bakiyeyi gösteren finansal pano';

  @override
  String accessibilityNetBalance(String amount, String status) {
    return 'Net bakiye: $amount, $status';
  }

  @override
  String get accessibilityBalanceHealthy => 'artıda';

  @override
  String get accessibilityBalanceNegative => 'eksidə';

  @override
  String accessibilityIncomeTotal(String amount) {
    return 'Toplam gelir: $amount';
  }

  @override
  String accessibilityExpenseTotal(String amount) {
    return 'Toplam harcama: $amount';
  }

  @override
  String get accessibilityAddSavings => 'Bu hedefe birikim ekle';

  @override
  String get accessibilityDeleteExpense => 'Bu harcamayı sil';

  @override
  String get accessibilityEditExpense => 'Bu harcamayı düzenle';

  @override
  String get accessibilityShareExpense => 'Bu harcamayı paylaş';

  @override
  String accessibilityStreakInfo(int days, int best) {
    return 'Mevcut seri: $days gün, en iyi seri: $best gün';
  }

  @override
  String get accessibilityAiChatInput => 'Finansal sorunuzu buraya yazın';

  @override
  String get accessibilityAiSendButton => 'Yapay zeka asistanına mesaj gönder';

  @override
  String accessibilitySuggestionButton(String question) {
    return 'Hızlı soru: $question';
  }

  @override
  String accessibilitySubscriptionCard(
    String name,
    String amount,
    String cycle,
    int day,
  ) {
    return '$name aboneliği, $cycle başına $amount, $day. gün yenilenir';
  }

  @override
  String accessibilitySettingsItem(String title, String value) {
    return '$title, mevcut değer: $value';
  }

  @override
  String get accessibilityToggleOn => 'Açık';

  @override
  String get accessibilityToggleOff => 'Kapalı';

  @override
  String get accessibilityCloseSheet => 'Bu sayfayı kapat';

  @override
  String get accessibilityBackButton => 'Geri dön';

  @override
  String get accessibilityProfileButton => 'Profil menüsünü aç';

  @override
  String get accessibilityNotificationsButton => 'Bildirimleri görüntüle';

  @override
  String get navHomeTooltip => 'Ana sayfa, harcama özeti';

  @override
  String get navPursuitsTooltip => 'Hedefler, birikim amaçları';

  @override
  String get navReportsTooltip => 'Raporlar, harcama analizi';

  @override
  String get navSettingsTooltip => 'Ayarlar ve tercihler';

  @override
  String shareDefaultMessage(String link) {
    return 'Harcamalarımı saat olarak takip ediyorum! Sen de dene: $link';
  }

  @override
  String get shareInviteLink => 'Davet Linkini Paylaş';

  @override
  String get inviteFriends => 'Arkadaşlarını Davet Et';

  @override
  String get yourReferralCode => 'Senin davet kodun';

  @override
  String referralStats(int count) {
    return '$count arkadaşın katıldı';
  }

  @override
  String get referralRewardInfo => 'Her arkadaşın için 7 gün premium kazan!';

  @override
  String get codeCopied => 'Kod kopyalandı!';

  @override
  String get haveReferralCode => 'Davet kodun var mı?';

  @override
  String get referralCodeHint => 'Kodu gir (opsiyonel)';

  @override
  String get referralCodePlaceholder => 'VANTAG-XXXXX';

  @override
  String referralSuccess(String name) {
    return '$name Vantag\'a katıldı! +7 gün premium kazandın';
  }

  @override
  String get welcomeReferred => 'Hoş geldin! 7 gün premium denemen var';

  @override
  String get referralInvalidCode => 'Geçersiz davet kodu';

  @override
  String get referralCodeApplied => 'Davet kodu uygulandı!';

  @override
  String get referralSectionTitle => 'Davetler';

  @override
  String get referralShareDescription => 'Kodunu paylaş, premium gün kazan';

  @override
  String get trialMidpointTitle => 'Yarı yoldasın! ⏳';

  @override
  String trialMidpointBody(String hours) {
    return 'Deneme süren yarılandı. Şu ana kadar $hours saat biriktirdin!';
  }

  @override
  String get trialOneDayLeftTitle => 'Denemen yarın bitiyor ⏰';

  @override
  String get trialOneDayLeftBody => 'Premium\'a geç, biriktirmeye devam et!';

  @override
  String get trialEndsTodayTitle => 'Denemenin son günü! 🎁';

  @override
  String get trialEndsTodayBody => 'Bugün geçersen %50 indirim!';

  @override
  String get trialExpiredTitle => 'Seni özledik! 💜';

  @override
  String get trialExpiredBody => 'Geri dön, hedeflerine devam et';

  @override
  String get dailyReminderTitle => 'Harcamalarını girmeyi unutma! 📝';

  @override
  String get dailyReminderBody => 'Bugünkü harcamalarını saniyeler içinde gir';

  @override
  String get notificationSettingsDesc => 'Hatırlatıcılar ve güncellemeler';

  @override
  String get firstExpenseTitle => 'Harika başlangıç! 🎉';

  @override
  String firstExpenseBody(String hours) {
    return 'Bugün $hours saat biriktirdin!';
  }

  @override
  String get trialReminderEnabled => 'Deneme hatırlatmaları';

  @override
  String get trialReminderDesc => 'Deneme süren bitmeden bildirim al';

  @override
  String get dailyReminderEnabled => 'Günlük hatırlatmalar';

  @override
  String get dailyReminderDesc => 'Akşam harcama girişi hatırlatması';

  @override
  String get dailyReminderTime => 'Hatırlatma saati';

  @override
  String trialDaysRemaining(int days) {
    return 'Denemede $days gün kaldı';
  }

  @override
  String get subscriptionReminder => 'Abonelik hatırlatmaları';

  @override
  String get subscriptionReminderDesc =>
      'Abonelikler yenilenmeden önce bildirim al';

  @override
  String get thinkingReminder => '\"Düşünüyorum\" hatırlatmaları';

  @override
  String get thinkingReminderDesc =>
      'Düşündüğün öğeler için 72 saat sonra hatırlatma al';

  @override
  String get thinkingReminderTitle => 'Hala düşünüyor musun?';

  @override
  String thinkingReminderBody(String item) {
    return 'Karar verdin mi? $item';
  }

  @override
  String get willRemindIn72h => '72 saat sonra hatırlatacağız';

  @override
  String get thinkingAbout => 'Düşündüklerin';

  @override
  String addedDaysAgo(int days) {
    return '$days gün önce eklendi';
  }

  @override
  String get stillThinking => 'Hala düşünüyor musun?';

  @override
  String get stillThinkingMessage => '72 saat oldu. Karar verdin mi?';

  @override
  String get decidedYes => 'Aldım';

  @override
  String get decidedNo => 'Vazgeçtim';

  @override
  String get aiChatLimitReached =>
      'Günlük 4 AI sohbet hakkını kullandın. Sınırsız için premium\'a geç!';

  @override
  String aiChatsRemaining(int count) {
    return 'Bugün $count mesaj hakkın kaldı';
  }

  @override
  String get pursuitLimitReachedFree =>
      'Ücretsiz hesaplarda 1 aktif hedef olabilir. Sınırsız hedef için premium\'a geç!';

  @override
  String get pursuitNameRequired => 'Lütfen bir isim girin';

  @override
  String get pursuitAmountRequired => 'Lütfen bir tutar girin';

  @override
  String get pursuitAmountInvalid => 'Geçerli bir tutar girin';

  @override
  String get exportPremiumOnly => 'Dışa aktarma premium özelliği';

  @override
  String get multiCurrencyPremium =>
      'Çoklu para birimi premium özelliği. Ücretsiz kullanıcılar sadece TRY kullanabilir.';

  @override
  String get reportsPremiumOnly => 'Aylık ve yıllık raporlar premium özelliği';

  @override
  String get upgradeToPremium => 'Premium\'a Geç';

  @override
  String get premiumIncludes => 'Premium içerir:';

  @override
  String get unlimitedAiChat => 'Sınırsız AI sohbet';

  @override
  String get unlimitedPursuits => 'Sınırsız hedef';

  @override
  String get exportFeature => 'Verilerini dışa aktar';

  @override
  String get allCurrencies => 'Tüm para birimleri';

  @override
  String get fullReports => 'Detaylı raporlar';

  @override
  String get cleanShareCards => 'Temiz paylaşım kartları (filigran yok)';

  @override
  String get maybeLater => 'Belki sonra';

  @override
  String get seePremium => 'Premium\'u Gör';

  @override
  String get weeklyOnly => 'Haftalık';

  @override
  String get monthlyPro => 'Aylık (Pro)';

  @override
  String get yearlyPro => 'Yıllık (Pro)';

  @override
  String get currencyLocked => 'Sadece Premium';

  @override
  String freeUserCurrencyNote(String currency) {
    return 'Ücretsiz kullanıcılar sadece TRY kullanabilir. $currency için premium\'a geç.';
  }

  @override
  String get watermarkText => 'vantag.app';

  @override
  String get incomeTypeSalary => 'Maaş';

  @override
  String get incomeTypeBonus => 'Prim';

  @override
  String get incomeTypeGift => 'Hediye';

  @override
  String get incomeTypeRefund => 'İade';

  @override
  String get incomeTypeFreelance => 'Serbest Çalışma';

  @override
  String get incomeTypeRental => 'Kira Geliri';

  @override
  String get incomeTypeInvestment => 'Yatırım Getirisi';

  @override
  String get incomeTypeOther => 'Diğer Gelir';

  @override
  String get salaryDay => 'Maaş Günü';

  @override
  String get salaryDayTitle => 'Maaşınız ne zaman yatıyor?';

  @override
  String get salaryDaySubtitle => 'Maaş gününüzde size hatırlatacağız';

  @override
  String get salaryDayHint => 'Ayın gününü seçin (1-31)';

  @override
  String salaryDaySet(int day) {
    return 'Maaş günü $day olarak ayarlandı';
  }

  @override
  String get salaryDaySkip => 'Şimdilik geç';

  @override
  String get salaryDayNotSet => 'Belirlenmedi';

  @override
  String get currentBalance => 'Güncel Bakiye';

  @override
  String get balanceTitle => 'Güncel bakiyeniz ne kadar?';

  @override
  String get balanceSubtitle => 'Harcamalarınızı daha doğru takip edin';

  @override
  String get balanceHint => 'Banka bakiyenizi girin';

  @override
  String get balanceUpdated => 'Bakiye güncellendi';

  @override
  String get balanceOptional => 'Opsiyonel - daha sonra ekleyebilirsiniz';

  @override
  String get paydayTitle => 'Maaş Günü!';

  @override
  String get paydayMessage => 'Maaşınız yattı mı?';

  @override
  String get paydayConfirm => 'Evet, yattı!';

  @override
  String get paydayNotYet => 'Henüz değil';

  @override
  String get paydaySkip => 'Geç';

  @override
  String get paydayCelebration => 'Tebrikler! Maaş yattı';

  @override
  String get paydayUpdateBalance => 'Bakiyenizi güncelleyin';

  @override
  String get paydayNewBalance => 'Maaş sonrası yeni bakiye';

  @override
  String daysUntilPayday(int days) {
    return 'Maaşa $days gün var';
  }

  @override
  String get paydayToday => 'Bugün maaş günü!';

  @override
  String get paydayTomorrow => 'Yarın maaş günü';

  @override
  String get addIncomeTitle => 'Gelir Kaydet';

  @override
  String get addIncomeSubtitle => 'Prim, hediye, iade vb.';

  @override
  String get incomeAmount => 'Gelen tutar';

  @override
  String get incomeNotes => 'Notlar (opsiyonel)';

  @override
  String get incomeNotesHint => 'ör. Yıl sonu primi, doğum günü hediyesi...';

  @override
  String get incomeAdded => 'Gelir eklendi!';

  @override
  String incomeAddedBalance(String amount) {
    return 'Bakiye güncellendi: $amount';
  }

  @override
  String get thisMonthIncome => 'Bu Ayın Geliri';

  @override
  String get regularIncome => 'Düzenli Gelir';

  @override
  String get additionalIncome => 'Ek Gelirler';

  @override
  String get incomeBreakdown => 'Gelir Dağılımı';

  @override
  String get paydayNotificationTitle => 'Maaş Günü!';

  @override
  String get paydayNotificationBody =>
      'Maaşınız bugün yatıyor olmalı. Hesabınızı kontrol edin!';

  @override
  String get paydayNotificationEnabled => 'Maaş günü hatırlatması';

  @override
  String get paydayNotificationDesc => 'Maaş gününüzde bildirim alın';

  @override
  String get onboardingSalaryDayTitle => 'Maaş Günü Ne Zaman?';

  @override
  String get onboardingSalaryDayDesc =>
      'Maaş gününüzü söyleyin, bütçenizi daha iyi planlamanıza yardımcı olalım';

  @override
  String get onboardingBalanceTitle => 'Başlangıç Bakiyesi';

  @override
  String get onboardingBalanceDesc =>
      'Finanslarınızı doğru takip etmek için güncel bakiyenizi girin';

  @override
  String get onboardingV2Step1Title => 'Harcamalarına farklı bak';

  @override
  String get onboardingV2Step1Subtitle =>
      'Her harcamanın sana kaç saat mal olduğunu gör';

  @override
  String get onboardingV2Step1Demo => '5.000₺\'lik telefon = 20 saat çalışman';

  @override
  String get onboardingV2Step1Cta => 'Hesapla';

  @override
  String get onboardingV2Step2Title => 'Seni tanıyalım';

  @override
  String get onboardingV2Step2Income => 'Aylık gelirin';

  @override
  String get onboardingV2Step2Hours => 'Günlük çalışma saatin';

  @override
  String get onboardingV2Step2Days => 'Haftalık çalışma günün';

  @override
  String get onboardingV2Step2Cta => 'Devam';

  @override
  String get onboardingV2Step3Title => 'İlk harcamanı gir';

  @override
  String get onboardingV2Step3Subtitle => 'Değerini saat olarak gör';

  @override
  String onboardingV2Step3Result(int hours, int minutes) {
    return '= $hours saat $minutes dakika';
  }

  @override
  String get onboardingV2Step3Success =>
      'Harika! Artık her harcamanın değerini bileceksin';

  @override
  String get onboardingV2Step3Cta => 'Başla';

  @override
  String get onboardingV2SkipSetup => 'Daha sonra';

  @override
  String onboardingV2Progress(int current, int total) {
    return 'Adım $current/$total';
  }

  @override
  String get checklistTitle => 'Başlangıç Rehberi';

  @override
  String checklistProgress(int completed, int total) {
    return '$completed/$total tamamlandı';
  }

  @override
  String get checklistFirstExpenseTitle => 'İlk harcamanı ekle';

  @override
  String get checklistFirstExpenseSubtitle => 'Değerini saat olarak gör';

  @override
  String get checklistViewReportTitle => 'Raporunu incele';

  @override
  String get checklistViewReportSubtitle => 'Harcama alışkanlıklarını keşfet';

  @override
  String get checklistCreatePursuitTitle => 'Tasarruf hedefi koy';

  @override
  String get checklistCreatePursuitSubtitle =>
      'Bir şey için biriktirmeye başla';

  @override
  String get checklistNotificationsTitle => 'Bildirimleri aç';

  @override
  String get checklistNotificationsSubtitle => 'Günlük hatırlatmalar al';

  @override
  String get checklistCelebrationTitle => 'Harika başlangıç!';

  @override
  String get checklistCelebrationSubtitle =>
      'Artık Vantag\'ı kullanmaya hazırsın';

  @override
  String get emptyStateExampleTitle => 'Örnek';

  @override
  String get emptyStateExpensesMessage =>
      'Harcamalarının sana kaç saat mal olduğunu gör';

  @override
  String get emptyStateExpensesCta => 'Harcama Ekle';

  @override
  String get emptyStatePursuitsMessage =>
      'Bir hedef koy, ne kadar yaklaştığını takip et';

  @override
  String get emptyStatePursuitsCta => 'Hedef Oluştur';

  @override
  String get emptyStateReportsMessage => 'Harcama alışkanlıklarını keşfet';

  @override
  String get emptyStateReportsCta => 'Harcama Ekle';

  @override
  String get emptyStateSubscriptionsMessage =>
      'Aboneliklerini takip et, unutma';

  @override
  String get emptyStateSubscriptionsCta => 'Abonelik Ekle';

  @override
  String get emptyStateAchievementsMessage =>
      'Rozetler kazanmak için harcama ekle';

  @override
  String get emptyStateSavingsPoolMessage => 'Birikimlerini havuzda topla';

  @override
  String get milestone3DayStreakTitle => '3 Gün Serisi!';

  @override
  String get milestone3DayStreakMessage => 'Harika başlangıç, devam et!';

  @override
  String get milestone7DayStreakTitle => '1 Hafta Serisi!';

  @override
  String get milestone7DayStreakMessage =>
      'Bir hafta boyunca düzenli kullandın';

  @override
  String get milestone14DayStreakTitle => '2 Hafta Serisi!';

  @override
  String get milestone14DayStreakMessage => 'Alışkanlık oluşturmaya başladın';

  @override
  String get milestone30DayStreakTitle => '1 Ay Serisi!';

  @override
  String get milestone30DayStreakMessage => 'Bir ay boyunca her gün! İnanılmaz';

  @override
  String get milestone60DayStreakTitle => '2 Ay Serisi!';

  @override
  String get milestone60DayStreakMessage => 'Finansal farkındalık uzmanı oldun';

  @override
  String get milestone100DayStreakTitle => '100 Gün Serisi!';

  @override
  String get milestone100DayStreakMessage =>
      'Efsanevi başarı! Sen bir şampiyon';

  @override
  String get milestoneFirstSavedTitle => 'İlk Tasarruf!';

  @override
  String get milestoneFirstSavedMessage => 'İlk paranı kurtardın';

  @override
  String get milestoneSaved100Title => '100₺ Kurtardın!';

  @override
  String get milestoneSaved100Message => 'Tasarruf alışkanlığın gelişiyor';

  @override
  String get milestoneSaved1000Title => '1.000₺ Kurtardın!';

  @override
  String get milestoneSaved1000Message => 'Ciddi tasarruf yapıyorsun';

  @override
  String get milestoneSaved5000Title => '5.000₺ Kurtardın!';

  @override
  String get milestoneSaved5000Message => 'Tasarruf ustası oldun!';

  @override
  String get milestoneFirstExpenseTitle => 'İlk Adım!';

  @override
  String get milestoneFirstExpenseMessage => 'İlk harcamanı girdin';

  @override
  String get milestone10ExpensesTitle => '10 Harcama!';

  @override
  String get milestone10ExpensesMessage => 'Artık takip alışkanlığın var';

  @override
  String get milestone50ExpensesTitle => '50 Harcama!';

  @override
  String get milestone50ExpensesMessage => 'Finansal farkındalık uzmanısın';

  @override
  String get milestoneFirstPursuitTitle => 'İlk Hedef!';

  @override
  String get milestoneFirstPursuitMessage => 'Biriktirme yolculuğun başladı';

  @override
  String get milestoneFirstPursuitCompletedTitle => 'Hedef Tamamlandı!';

  @override
  String get milestoneFirstPursuitCompletedMessage => 'İlk hedefine ulaştın!';

  @override
  String get milestoneUsedAiChatTitle => 'AI Keşfi!';

  @override
  String get milestoneUsedAiChatMessage => 'Finansal asistanınla tanıştın';

  @override
  String selectTimeFilter(String filter) {
    return 'Zaman filtresi seç: $filter';
  }

  @override
  String lockedFilterPremium(String filter) {
    return '$filter, premium özellik';
  }

  @override
  String selectedFilter(String filter) {
    return '$filter, seçili';
  }

  @override
  String selectHeatmapDay(String date) {
    return 'Gün seç: $date';
  }

  @override
  String heatmapDayWithSpending(String date, String amount) {
    return '$date, $amount harcama';
  }

  @override
  String heatmapDayNoSpending(String date) {
    return '$date, harcama yok';
  }

  @override
  String get loggedOutFromAnotherDevice => 'Başka Cihazda Giriş Yapıldı';

  @override
  String get loggedOutFromAnotherDeviceMessage =>
      'Hesabınıza başka bir cihazdan giriş yapıldı. Güvenlik nedeniyle bu cihazdan çıkış yapıldı.';

  @override
  String get multiCurrencyProTitle => 'Çoklu Para Birimi';

  @override
  String get multiCurrencyProDescription =>
      'Farklı para birimlerinde gelir ve harcama girişi yapabilmek için Pro üyeliğe yükseltin. USD, EUR, GBP ve daha fazlasını kullanın.';

  @override
  String get multiCurrencyBenefit => 'Tüm para birimlerinde işlem';

  @override
  String get currencyLockedForFree => 'Para birimi değişikliği Pro özelliğidir';

  @override
  String get excelSheetExpenses => 'Harcamalar';

  @override
  String get excelSheetSummary => 'Özet';

  @override
  String get excelSheetCategories => 'Kategoriler';

  @override
  String get excelSheetTimeAnalysis => 'Zaman Analizi';

  @override
  String get excelSheetDecisions => 'Kararlar';

  @override
  String get excelSheetInstallments => 'Taksitler';

  @override
  String get excelHeaderDay => 'Gün';

  @override
  String get excelHeaderStore => 'Mağaza/Yer';

  @override
  String get excelHeaderMinutes => 'Dakika Karşılığı';

  @override
  String get excelHeaderMonthlyInstallment => 'Aylık Ödeme';

  @override
  String get excelHeaderInstallmentCount => 'Taksit';

  @override
  String get excelHeaderSimulation => 'Simülasyon';

  @override
  String get excelHeaderHoursEquiv => 'Saat Karşılığı';

  @override
  String get excelReportTitle => 'Vantag Finansal Rapor';

  @override
  String get excelReportPeriod => 'Rapor Dönemi';

  @override
  String get excelReportGeneratedAt => 'Oluşturulma Tarihi';

  @override
  String get excelTotalExpenses => 'Toplam Harcama';

  @override
  String get excelTotalTransactions => 'Toplam İşlem';

  @override
  String get excelAvgPerTransaction => 'İşlem Başına Ortalama';

  @override
  String get excelMonthlyAverage => 'Aylık Ortalama';

  @override
  String get excelDailyAverage => 'Günlük Ortalama';

  @override
  String get excelWeeklyAverage => 'Haftalık Ortalama';

  @override
  String get excelSavingsRate => 'Tasarruf Oranı';

  @override
  String get excelTotalWorkHours => 'Toplam Çalışma Saati';

  @override
  String get excelTotalWorkDays => 'Toplam Çalışma Günü';

  @override
  String get excelCategoryShare => 'Pay %';

  @override
  String get excelCategoryRank => 'Sıra';

  @override
  String get excelTopCategory => 'En Çok Harcanan';

  @override
  String get excelCategoryCount => 'İşlem Sayısı';

  @override
  String get excelCategoryAvg => 'Kategori Ortalaması';

  @override
  String get excelCategoryTotal => 'Kategori Toplamı';

  @override
  String get excelCategoryHours => 'Çalışma Saati';

  @override
  String get excelTimeTitle => 'Zaman Analizi';

  @override
  String get excelMostActiveDay => 'En Aktif Gün';

  @override
  String get excelMostActiveHour => 'En Aktif Saat';

  @override
  String get excelWeekdayAvg => 'Hafta İçi Ortalama';

  @override
  String get excelWeekendAvg => 'Hafta Sonu Ortalama';

  @override
  String get excelMorningSpend => 'Sabah (06-12)';

  @override
  String get excelAfternoonSpend => 'Öğleden Sonra (12-18)';

  @override
  String get excelEveningSpend => 'Akşam (18-24)';

  @override
  String get excelNightSpend => 'Gece (00-06)';

  @override
  String get excelByDayOfWeek => 'Haftanın Günlerine Göre';

  @override
  String get excelByHour => 'Saate Göre';

  @override
  String get excelByMonth => 'Aya Göre';

  @override
  String get excelDecisionsBought => 'Aldım';

  @override
  String get excelDecisionsThinking => 'Düşünüyorum';

  @override
  String get excelDecisionsPassed => 'Vazgeçtim';

  @override
  String get excelDecisionCount => 'Adet';

  @override
  String get excelDecisionAmount => 'Tutar';

  @override
  String get excelDecisionPercent => 'Yüzde';

  @override
  String get excelDecisionAvg => 'Ortalama';

  @override
  String get excelDecisionHours => 'Çalışma Saati';

  @override
  String get excelImpulseRate => 'Anlık Karar Oranı';

  @override
  String get excelSavingsFromPassed => 'Vazgeçerek Tasarruf';

  @override
  String get excelPotentialSavings => 'Potansiyel Tasarruf (Düşünülen)';

  @override
  String get excelInstallmentName => 'Açıklama';

  @override
  String get excelInstallmentTotal => 'Toplam Tutar';

  @override
  String get excelInstallmentMonthly => 'Aylık Ödeme';

  @override
  String get excelInstallmentProgress => 'İlerleme';

  @override
  String get excelInstallmentRemaining => 'Kalan';

  @override
  String get excelInstallmentStartDate => 'Başlangıç';

  @override
  String get excelInstallmentEndDate => 'Bitiş';

  @override
  String get excelInstallmentInterest => 'Vade Farkı';

  @override
  String get excelNoInstallments => 'Taksitli ödeme bulunmuyor';

  @override
  String get excelTotalMonthlyPayments => 'Toplam Aylık Ödemeler';

  @override
  String get excelTotalRemainingDebt => 'Toplam Kalan Borç';

  @override
  String get excelDayMonday => 'Pazartesi';

  @override
  String get excelDayTuesday => 'Salı';

  @override
  String get excelDayWednesday => 'Çarşamba';

  @override
  String get excelDayThursday => 'Perşembe';

  @override
  String get excelDayFriday => 'Cuma';

  @override
  String get excelDaySaturday => 'Cumartesi';

  @override
  String get excelDaySunday => 'Pazar';

  @override
  String get excelYes => 'Evet';

  @override
  String get excelNo => 'Hayır';

  @override
  String get excelReal => 'Gerçek';

  @override
  String get excelSimulation => 'Simülasyon';

  @override
  String get proFeaturesSheetTitle => 'Pro Özellik';

  @override
  String get proFeaturesSheetSubtitle => 'Bu özellik Pro üyelere özel';

  @override
  String get proFeaturesIncluded => 'Pro üyelik şunları içerir:';

  @override
  String get proFeatureHeatmap => 'Harcama Haritası';

  @override
  String get proFeatureHeatmapDesc => 'Yıllık harcama düzenini görselleştir';

  @override
  String get proFeatureCategoryBreakdown => 'Kategori Dağılımı';

  @override
  String get proFeatureCategoryBreakdownDesc =>
      'Kategorilere göre detaylı pasta grafik analizi';

  @override
  String get proFeatureSpendingTrends => 'Harcama Trendleri';

  @override
  String get proFeatureSpendingTrendsDesc =>
      'Harcamalarının zaman içindeki değişimini takip et';

  @override
  String get proFeatureTimeAnalysis => 'Zaman Analizi';

  @override
  String get proFeatureTimeAnalysisDesc =>
      'Gün ve saate göre en çok ne zaman harcadığını gör';

  @override
  String get proFeatureBudgetBreakdown => 'Bütçe Dağılımı';

  @override
  String get proFeatureBudgetBreakdownDesc =>
      'Bütçe hedeflerine göre harcamalarını takip et';

  @override
  String get proFeatureAdvancedFilters => 'Gelişmiş Filtreler';

  @override
  String get proFeatureAdvancedFiltersDesc =>
      'Aylık, tüm zamanlar ve daha fazla filtre';

  @override
  String get proFeatureExcelExport => 'Excel Dışa Aktarım';

  @override
  String get proFeatureExcelExportDesc => 'Tüm finansal verilerini dışa aktar';

  @override
  String get proFeatureUnlimitedHistory => 'Sınırsız Geçmiş';

  @override
  String get proFeatureUnlimitedHistoryDesc => 'Tüm geçmiş harcamalarına eriş';

  @override
  String get goProButton => 'Pro\'ya Geç';

  @override
  String get lockedFeatureTapToUnlock => 'Açmak için dokun';

  @override
  String voiceUsageIndicator(int used, int total) {
    return 'Bugün $used/$total sesli giriş';
  }

  @override
  String aiChatUsageIndicator(int used, int total) {
    return 'Bugün $used/$total soru';
  }

  @override
  String get dailyLimitReached => 'Günlük limit doldu';

  @override
  String get dailyLimitReachedDesc =>
      'Günlük kullanım hakkın bitti. Sınırsız erişim için Pro\'ya geç!';

  @override
  String get unlimitedWithPro => 'Pro ile sınırsız';

  @override
  String get backupData => 'Verileri Yedekle';

  @override
  String get backupDataDesc => 'Verilerini JSON dosyası olarak dışa aktar';

  @override
  String get restoreData => 'Yedeği Geri Yükle';

  @override
  String get restoreDataDesc => 'Yedek dosyasından verileri içe aktar';

  @override
  String get backupCreating => 'Yedek oluşturuluyor...';

  @override
  String get backupSuccess => 'Yedek başarıyla oluşturuldu';

  @override
  String get backupError => 'Yedek oluşturulamadı';

  @override
  String get restoreConfirmTitle => 'Verileri Geri Yükle?';

  @override
  String get restoreConfirmMessage =>
      'Yedek verileri mevcut verilerine eklenecek. Devam edilsin mi?';

  @override
  String restoreSuccess(int expenses, int pursuits, int subscriptions) {
    return 'Veriler geri yüklendi! $expenses harcama, $pursuits hedef, $subscriptions abonelik içe aktarıldı.';
  }

  @override
  String get restoreError => 'Veriler geri yüklenemedi';

  @override
  String get noFileSelected => 'Dosya seçilmedi';

  @override
  String get invalidBackupFormat => 'Geçersiz yedek dosyası formatı';

  @override
  String get shareApp => 'Arkadaşına Öner';

  @override
  String get shareAppDesc => 'Vantag\'ı arkadaşlarına öner';

  @override
  String get shareAppMessage =>
      'Vantag\'a bak - Her harcamanın kaç saat çalışmana mal olduğunu gösteriyor! İndir: https://play.google.com/store/apps/details?id=com.vantag.app';

  @override
  String get sendFeedback => 'Geri Bildirim Gönder';

  @override
  String get sendFeedbackDesc => 'Vantag\'ı geliştirmemize yardım et';

  @override
  String get feedbackEmailSubject => 'Vantag Geri Bildirim';

  @override
  String get rateApp => 'Uygulamayı Puanla';

  @override
  String get rateAppDesc => 'Play Store\'da puanla';

  @override
  String get whatsNew => 'Yenilikler';

  @override
  String whatsNewInVersion(String version) {
    return 'v$version Yenilikleri';
  }

  @override
  String get updateRequired => 'Güncelleme Gerekli';

  @override
  String get updateRequiredMessage =>
      'Vantag\'ın yeni bir sürümü mevcut. Devam etmek için lütfen güncelle.';

  @override
  String get updateNow => 'Şimdi Güncelle';

  @override
  String get dailyLimits => 'Günlük Limitler';

  @override
  String get aiChat => 'AI Sohbet';

  @override
  String get statementImport => 'Ekstre İçe Aktarma';

  @override
  String get subscriptionAutoRenewalNotice =>
      'Abonelik, mevcut dönem sona ermeden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Abonelikleri Ayarlar\'dan yönetin.';

  @override
  String get welcomeBackTitle3Days => 'Tekrar Hoş Geldin!';

  @override
  String get welcomeBackSubtitle3Days =>
      'Seni özledik. Harcamalarını takip etmeye devam et.';

  @override
  String get welcomeBackCta3Days => 'Harcama Ekle';

  @override
  String get welcomeBackTitle7Days => 'Geri Döndün!';

  @override
  String get welcomeBackSubtitle7Days =>
      'Bir hafta oldu. Finansal hedeflerine devam edelim.';

  @override
  String get welcomeBackCta7Days => 'Nereden Kaldık?';

  @override
  String get welcomeBackTitle14Days => 'Merhaba Yeniden!';

  @override
  String get welcomeBackSubtitle14Days =>
      'Seni bekledik. Yeni bir başlangıç yapmaya hazır mısın?';

  @override
  String get welcomeBackCta14Days => 'Yeniden Başla';

  @override
  String get welcomeBackTitle30Days => 'Hoş Geldin Geri!';

  @override
  String get welcomeBackSubtitle30Days =>
      'Uzun zaman oldu ama hedeflerine ulaşmak hâlâ mümkün!';

  @override
  String get welcomeBackCta30Days => 'Hemen Başla';

  @override
  String get welcomeBackStreakLost => 'Seriniz sıfırlandı';

  @override
  String welcomeBackStreakRecovered(int percent) {
    return 'Serinin %$percent\'i kurtarıldı!';
  }

  @override
  String get reengagementPushTitle3Days => 'Harcamalarını takip etmeyi unutma!';

  @override
  String get reengagementPushBody3Days =>
      'Bugün ne kadar tasarruf ettin? Hemen gir ve gör.';

  @override
  String get reengagementPushTitle5Days => 'Seni özledik!';

  @override
  String get reengagementPushBody5Days =>
      'Finansal hedeflerine ulaşmak için devam et.';

  @override
  String get reengagementPushTitle7Days => 'Geri dön, serinin bozulmasın!';

  @override
  String get reengagementPushBody7Days =>
      'Streak\'ini kaybetme, hemen bir harcama ekle.';

  @override
  String get reengagementUrgentTitle => 'Finansal kontrolün elden kaçmasın!';

  @override
  String get reengagementUrgentBody =>
      'Harcamalarını güncelle ve yoluna devam et.';

  @override
  String get pushOnboardingDay1Title => 'İlk harcamanı ekle!';

  @override
  String get pushOnboardingDay1Body =>
      'Bir kahve veya yemek - küçük başla, farkı gör.';

  @override
  String get pushOnboardingDay3Title => 'Kaç saat çalıştığını biliyor musun?';

  @override
  String get pushOnboardingDay3Body =>
      'Harcamalarını saat olarak görmeye devam et.';

  @override
  String get pushOnboardingDay7Title => '7 gün oldu!';

  @override
  String get pushOnboardingDay7Body =>
      'Streak başlatmak için her gün bir harcama ekle.';

  @override
  String get pushWeeklyInsightTitle => 'Haftalık Özet Hazır';

  @override
  String get pushWeeklyInsightBody =>
      'Bu hafta ne kadar tasarruf ettin? Hemen kontrol et.';

  @override
  String get pushStreakReminderNewTitle => 'Yeni bir seri başlat!';

  @override
  String get pushStreakReminderNewBody =>
      'Bugün ilk harcamanı ekle ve yolculuğa başla.';

  @override
  String pushStreakReminderShortTitle(int days) {
    return '$days günlük serin var!';
  }

  @override
  String get pushStreakReminderShortBody => 'Bugün de ekle, serini koru.';

  @override
  String pushStreakReminderMediumTitle(int days) {
    return '$days gün! Harika gidiyorsun!';
  }

  @override
  String get pushStreakReminderMediumBody =>
      'Seriyi bozmamak için bugün de ekle.';

  @override
  String pushStreakReminderLongTitle(int days) {
    return '$days günlük seri!';
  }

  @override
  String get pushStreakReminderLongBody => 'İnanılmaz bir başarı! Devam et.';

  @override
  String get pushMorningMotivationTitle => 'Günaydın!';

  @override
  String pushMorningMotivationWithSavingsBody(String symbol, String amount) {
    return 'Bu ay $symbol$amount tasarruf ettin. Devam!';
  }

  @override
  String get pushMorningMotivationDefaultBody =>
      'Bugün bir harcama ekleyerek finansal farkındalığını artır.';

  @override
  String get notificationSettingsTitle => 'Bildirim Ayarları';

  @override
  String get notificationSettingsQuietHours => 'Sessiz Saatler';

  @override
  String get notificationSettingsQuietHoursDesc =>
      'Bu saatler arasında bildirim gönderilmez';

  @override
  String get notificationSettingsPreferredTime => 'Tercih Edilen Saat';

  @override
  String get notificationSettingsPreferredTimeDesc =>
      'Bildirimlerin gönderileceği saat';

  @override
  String get notificationSettingsStreakReminders => 'Seri Hatırlatıcıları';

  @override
  String get notificationSettingsStreakRemindersDesc =>
      'Akşamları seri hatırlatması al';

  @override
  String get notificationSettingsMorningMotivation => 'Sabah Motivasyonu';

  @override
  String get notificationSettingsMorningMotivationDesc =>
      'Sabahları motivasyon mesajı al';

  @override
  String get notificationSettingsWeeklyInsights => 'Haftalık Özetler';

  @override
  String get notificationSettingsWeeklyInsightsDesc =>
      'Pazar sabahları haftalık özet al';

  @override
  String get loginPromptTitle => 'Verilerini Kaydet';

  @override
  String get loginPromptSubtitle => 'Hesabını bağla, verilerini kaybetme';

  @override
  String get loginPromptLater => 'Daha sonra';

  @override
  String get additionalIncomePromptTitle => 'Ek gelirin var mı?';

  @override
  String get additionalIncomePromptSubtitle => 'Yan iş, kira, freelance...';

  @override
  String get additionalIncomeYes => 'Evet, ekle';

  @override
  String get additionalIncomeNo => 'Hayır, yok';

  @override
  String get expenseTypeSingle => 'Tek Seferlik';

  @override
  String get expenseTypeRecurring => 'Tekrarlayan';

  @override
  String get expenseTypeInstallment => 'Taksitli';

  @override
  String get monthlyPaymentLabel => 'Aylık taksit:';

  @override
  String installmentCountLabel(int count) {
    return '$count ay';
  }

  @override
  String get interestAmountLabel => 'Vade farkı:';

  @override
  String get interestAsHoursLabel => 'Vade farkı saat olarak:';

  @override
  String get hoursUnit => 'saat';

  @override
  String installmentSavingsWarning(String hours) {
    return 'Peşin alsaydın $hours saat kazanırdın!';
  }

  @override
  String get errorSelectInstallmentCount => 'Lütfen taksit sayısını seçin';

  @override
  String get errorEnterInstallmentTotal =>
      'Lütfen taksitli toplam fiyatı girin';

  @override
  String get insightPeakDay => 'En Çok Harcama Günü';

  @override
  String get insightTopCategory => 'En Büyük Kategori';

  @override
  String get insightMonthComparison => 'Bu Ay vs Geçen Ay';

  @override
  String insightPeakDaySubtitle(String day) {
    return '$day en çok harcadığın gün';
  }

  @override
  String insightTopCategorySubtitle(String category) {
    return '$category en büyük kategorin';
  }

  @override
  String insightMonthDown(String percent) {
    return 'Geçen aya göre %$percent düşüş';
  }

  @override
  String insightMonthUp(String percent) {
    return 'Geçen aya göre %$percent artış';
  }

  @override
  String get dayMonday => 'Pazartesi';

  @override
  String get dayTuesday => 'Salı';

  @override
  String get dayWednesday => 'Çarşamba';

  @override
  String get dayThursday => 'Perşembe';

  @override
  String get dayFriday => 'Cuma';

  @override
  String get daySaturday => 'Cumartesi';

  @override
  String get daySunday => 'Pazar';

  @override
  String get heatmapLow => 'Az';

  @override
  String get heatmapHigh => 'Çok';

  @override
  String get dayAbbrevMon => 'P';

  @override
  String get dayAbbrevTue => 'S';

  @override
  String get dayAbbrevWed => 'Ç';

  @override
  String get dayAbbrevThu => 'P';

  @override
  String get dayAbbrevFri => 'C';

  @override
  String get dayAbbrevSat => 'C';

  @override
  String get dayAbbrevSun => 'P';

  @override
  String get monthAbbrevJan => 'Oca';

  @override
  String get monthAbbrevFeb => 'Şub';

  @override
  String get monthAbbrevMar => 'Mar';

  @override
  String get monthAbbrevApr => 'Nis';

  @override
  String get monthAbbrevMay => 'May';

  @override
  String get monthAbbrevJun => 'Haz';

  @override
  String get monthAbbrevJul => 'Tem';

  @override
  String get monthAbbrevAug => 'Ağu';

  @override
  String get monthAbbrevSep => 'Eyl';

  @override
  String get monthAbbrevOct => 'Eki';

  @override
  String get monthAbbrevNov => 'Kas';

  @override
  String get monthAbbrevDec => 'Ara';

  @override
  String get savingsProjectionTitle => 'Tasarruf Projeksiyonu';

  @override
  String get threeMonths => '3 Ay';

  @override
  String get sixMonths => '6 Ay';

  @override
  String get oneYear => '1 Yıl';

  @override
  String monthlyAverageLabel(String amount) {
    return 'Aylık ortalama: $amount';
  }

  @override
  String get categoryTrendTitle => 'Kategori Trendi';

  @override
  String get workHoursEquivalentTitle => 'Çalışma Saati Karşılığı';

  @override
  String totalHoursLabel(String hours) {
    return 'Toplam: $hours saat';
  }

  @override
  String perHourLabel(String rate) {
    return '($rate/saat)';
  }

  @override
  String get dayAbbrevMonFull => 'Pzt';

  @override
  String get dayAbbrevTueFull => 'Sal';

  @override
  String get dayAbbrevWedFull => 'Çar';

  @override
  String get dayAbbrevThuFull => 'Per';

  @override
  String get dayAbbrevFriFull => 'Cum';

  @override
  String get dayAbbrevSatFull => 'Cmt';

  @override
  String get dayAbbrevSunFull => 'Paz';

  @override
  String get sharePreText => 'Bunu almak için';

  @override
  String get sharePostText => 'çalışman gerekiyor';

  @override
  String get shareCTA => 'Sen kaç saat çalışıyorsun?';

  @override
  String get shareTextDefault => 'Sen kaç saat çalışıyorsun? 👀 vantag.app';

  @override
  String get minuteUnitUpper => 'DK';

  @override
  String get hourUnitUpper => 'SAAT';

  @override
  String get decisionBought => 'Aldım';

  @override
  String get decisionPassed => 'Vazgeçtim';

  @override
  String get decisionThinking => 'Düşünüyorum';

  @override
  String expenseAddedMessage(String amount, String description) {
    return '$amount $description eklendi';
  }

  @override
  String get undoAction => 'Geri Al';

  @override
  String get confirmExpenseTitle => 'Harcamayı Onayla';

  @override
  String get amountLabel => 'Tutar';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get cancelAction => 'İptal';

  @override
  String get addAction => 'Ekle';

  @override
  String referralAppliedMessage(String code) {
    return 'Davet kodu uygulandı: $code';
  }

  @override
  String get workEquivalentBadge => 'ÇALIŞMA KARŞILIĞI';

  @override
  String get hoursUnitUpper => 'SAAT';

  @override
  String get daysUnitUpper => 'GÜN';

  @override
  String get budgetUsageLabel => 'Bütçe Kullanımı';

  @override
  String get whatDecisionLabel => 'Kararın ne oldu?';

  @override
  String daysUnit(int count) {
    return '$count gün';
  }

  @override
  String get profilePhotoTitle => 'Profil Fotoğrafı';

  @override
  String get takePhotoOption => 'Kameradan çek';

  @override
  String get chooseFromGalleryOption => 'Galeriden seç';

  @override
  String get removePhotoOption => 'Fotoğrafı kaldır';

  @override
  String examplePrefix(String examples) {
    return 'Örn: $examples';
  }

  @override
  String get exampleFood => 'Kahve, Market, Restoran';

  @override
  String get exampleTransport => 'Benzin, Taksi, Otobüs';

  @override
  String get exampleClothing => 'Kaban, Ayakkabı, T-shirt';

  @override
  String get exampleElectronics => 'Telefon, Kulaklık, Şarj';

  @override
  String get exampleEntertainment => 'Sinema, Oyun, Konser';

  @override
  String get exampleHealth => 'İlaç, Doktor, Vitamin';

  @override
  String get exampleEducation => 'Kitap, Kurs, Defter';

  @override
  String get exampleBills => 'Elektrik, Su, İnternet';

  @override
  String get exampleDefault => 'Açıklama yazın...';

  @override
  String get newExpenseHeader => 'Yeni Harcama';

  @override
  String get expenseGroupHeader => 'Harcama Grubu';

  @override
  String get calculateAction => 'Hesapla';

  @override
  String get detailOptionalLabel => 'Detay (Opsiyonel)';

  @override
  String get enterValidAmountError => 'Lütfen geçerli bir tutar girin';

  @override
  String get aiDisclaimer =>
      'Yapay zeka tarafından oluşturulan içgörüler yalnızca bilgilendirme amaçlıdır ve finansal tavsiye olarak değerlendirilmemelidir.';

  @override
  String get hourLabel => 'Saat';

  @override
  String get yearLabel => 'Yıl';

  @override
  String goldOunces(String ounces) {
    return '${ounces}oz altın';
  }

  @override
  String goldOuncesShort(String ounces) {
    return '${ounces}oz altın';
  }

  @override
  String couldBuyGoldOunces(String ounces) {
    return 'Bu parayla $ounces ons altın alabilirdin';
  }

  @override
  String get pleaseEnterIncome => 'Lütfen gelirinizi girin';

  @override
  String get mainIncome => 'Ana Gelir';

  @override
  String get ofYourWork => 'çalışman';

  @override
  String get expensePlaceholder => 'Kahve, yemek, market...';

  @override
  String get tourHeroCardTitle => 'Çalışma Karşılığı';

  @override
  String get tourHeroCardDesc =>
      'Harcamaların kaç saat çalışmana denk geldiğini burada gör';

  @override
  String get tourHabitCalcTitle => 'Alışkanlık Hesaplayıcı';

  @override
  String get tourHabitCalcDesc =>
      'Günlük alışkanlıklarının yıllık maliyetini hesapla';

  @override
  String get tourFabTitle => 'Harcama Ekle';

  @override
  String get tourFabDesc => 'Dokun veya uzun bas ile sesli giriş yap 🎤';

  @override
  String get tourReportsTabTitle => 'Raporlar';

  @override
  String get tourReportsTabDesc =>
      'Haftalık, aylık detaylı harcama analizlerin burada 📊';

  @override
  String get tourPursuitsTabTitle => 'Tasarruf Hedefleri';

  @override
  String get tourPursuitsTabDesc =>
      'Bir hayal ekle, vazgeçtiğin paralar otomatik biriksin ⭐';

  @override
  String get tourSettingsTabTitle => 'Ayarlar';

  @override
  String get tourSettingsTabDesc =>
      'Maaş, para birimi, bildirimler ve daha fazlası ⚙️';

  @override
  String get tourSkip => 'Atla';

  @override
  String get tourNext => 'İleri';

  @override
  String get tourDone => 'Tamamla';

  @override
  String get onboardingCurrencyHint => 'Para birimini değiştirmek için dokun';

  @override
  String onboardingCurrencyProInfo(String currency) {
    return 'Farklı para birimleri Pro özelliğidir. Ücretsiz sürümde yalnızca $currency kullanılır.';
  }
}
