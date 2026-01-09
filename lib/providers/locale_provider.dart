import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcının dil tercihini yöneten provider
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale? _locale;

  /// Mevcut locale (null ise sistem dili kullanılır)
  Locale? get locale => _locale;

  /// Desteklenen diller
  static const List<Locale> supportedLocales = [
    Locale('tr'), // Türkçe (varsayılan)
    Locale('en'), // İngilizce
  ];

  /// Provider'ı başlat ve kaydedilmiş dili yükle
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);

    if (localeCode != null) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }

  /// Dili değiştir ve kaydet
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  /// Sistem diline dön
  Future<void> clearLocale() async {
    _locale = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
  }

  /// Dil kodu'ndan okunabilir isim döndür
  String getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }

  /// Mevcut dil Türkçe mi?
  bool get isTurkish => _locale?.languageCode == 'tr';

  /// Mevcut dil İngilizce mi?
  bool get isEnglish => _locale?.languageCode == 'en';
}
