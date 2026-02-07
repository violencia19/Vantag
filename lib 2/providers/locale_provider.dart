import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcının dil tercihini yöneten provider
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const String _firstLaunchKey = 'locale_first_launch_done';

  Locale? _locale;

  /// Mevcut locale (null ise sistem dili kullanılır)
  Locale? get locale => _locale;

  /// Desteklenen diller
  static const List<Locale> supportedLocales = [
    Locale('tr'), // Türkçe
    Locale('en'), // İngilizce
  ];

  /// Provider'ı başlat ve kaydedilmiş dili yükle
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    final firstLaunchDone = prefs.getBool(_firstLaunchKey) ?? false;

    if (localeCode != null) {
      // User has a saved preference
      _locale = Locale(localeCode);
    } else if (!firstLaunchDone) {
      // First launch - set based on phone language
      final phoneLocale = _getPhoneLocale();
      if (phoneLocale == 'tr') {
        _locale = const Locale('tr');
      } else {
        _locale = const Locale('en');
      }
      // Save the initial preference
      await prefs.setString(_localeKey, _locale!.languageCode);
      await prefs.setBool(_firstLaunchKey, true);
    }

    notifyListeners();
  }

  /// Get phone's language code
  String _getPhoneLocale() {
    try {
      final localeName = Platform.localeName; // e.g., "tr_TR", "en_US"
      if (localeName.isNotEmpty) {
        return localeName.split('_').first.toLowerCase();
      }
    } catch (e) {
      debugPrint('[LocaleProvider] Error getting phone locale: $e');
    }
    return 'en'; // Default to English if detection fails
  }

  /// Check if phone language is Turkish
  static bool isPhoneTurkish() {
    try {
      final localeName = Platform.localeName;
      return localeName.toLowerCase().startsWith('tr');
    } catch (e) {
      return false;
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
