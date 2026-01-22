import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleProvider', () {
    late LocaleProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = LocaleProvider();
    });

    group('initial state', () {
      test('locale is null initially', () {
        expect(provider.locale, isNull);
      });
    });

    group('initialize', () {
      test('loads saved locale', () async {
        SharedPreferences.setMockInitialValues({'app_locale': 'en'});
        provider = LocaleProvider();

        await provider.initialize();
        expect(provider.locale?.languageCode, 'en');
      });

      test('keeps null locale when no saved locale', () async {
        await provider.initialize();
        expect(provider.locale, isNull);
      });
    });

    group('setLocale', () {
      test('sets Turkish locale', () async {
        await provider.setLocale(const Locale('tr'));
        expect(provider.locale?.languageCode, 'tr');
      });

      test('sets English locale', () async {
        await provider.setLocale(const Locale('en'));
        expect(provider.locale?.languageCode, 'en');
      });

      test('ignores unsupported locale', () async {
        await provider.setLocale(const Locale('fr'));
        expect(provider.locale, isNull);
      });

      test('persists locale to SharedPreferences', () async {
        await provider.setLocale(const Locale('en'));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('app_locale'), 'en');
      });
    });

    group('clearLocale', () {
      test('clears locale', () async {
        await provider.setLocale(const Locale('en'));
        await provider.clearLocale();
        expect(provider.locale, isNull);
      });

      test('removes locale from SharedPreferences', () async {
        await provider.setLocale(const Locale('en'));
        await provider.clearLocale();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('app_locale'), isNull);
      });
    });

    group('getLanguageName', () {
      test('returns Türkçe for tr', () {
        expect(provider.getLanguageName('tr'), 'Türkçe');
      });

      test('returns English for en', () {
        expect(provider.getLanguageName('en'), 'English');
      });

      test('returns code for unknown language', () {
        expect(provider.getLanguageName('fr'), 'fr');
      });
    });

    group('isTurkish', () {
      test('returns true when Turkish', () async {
        await provider.setLocale(const Locale('tr'));
        expect(provider.isTurkish, true);
      });

      test('returns false when English', () async {
        await provider.setLocale(const Locale('en'));
        expect(provider.isTurkish, false);
      });

      test('returns false when null', () {
        expect(provider.isTurkish, false);
      });
    });

    group('isEnglish', () {
      test('returns true when English', () async {
        await provider.setLocale(const Locale('en'));
        expect(provider.isEnglish, true);
      });

      test('returns false when Turkish', () async {
        await provider.setLocale(const Locale('tr'));
        expect(provider.isEnglish, false);
      });

      test('returns false when null', () {
        expect(provider.isEnglish, false);
      });
    });

    group('supportedLocales', () {
      test('contains Turkish and English', () {
        expect(LocaleProvider.supportedLocales, contains(const Locale('tr')));
        expect(LocaleProvider.supportedLocales, contains(const Locale('en')));
      });

      test('has exactly 2 locales', () {
        expect(LocaleProvider.supportedLocales.length, 2);
      });
    });

    group('notifyListeners', () {
      test('notifies listeners when locale changes', () async {
        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        await provider.setLocale(const Locale('en'));
        expect(notifyCount, 1);

        await provider.setLocale(const Locale('tr'));
        expect(notifyCount, 2);
      });

      test('notifies listeners when locale is cleared', () async {
        await provider.setLocale(const Locale('en'));

        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        await provider.clearLocale();
        expect(notifyCount, 1);
      });
    });
  });
}
