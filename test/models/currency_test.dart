import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/models/currency.dart';

void main() {
  group('Currency', () {
    group('constructor', () {
      test('creates currency with required parameters', () {
        const currency = Currency(
          code: 'TEST',
          symbol: 'T',
          name: 'Test Currency',
          flag: '🏴',
        );

        expect(currency.code, 'TEST');
        expect(currency.symbol, 'T');
        expect(currency.name, 'Test Currency');
        expect(currency.flag, '🏴');
        expect(currency.symbolBefore, true);
        expect(currency.thousandSeparator, ',');
        expect(currency.decimalSeparator, '.');
        expect(currency.goldUnit, 'oz');
      });

      test('creates currency with all parameters', () {
        const currency = Currency(
          code: 'TRY',
          symbol: '₺',
          name: 'Türk Lirası',
          flag: '🇹🇷',
          symbolBefore: false,
          thousandSeparator: '.',
          decimalSeparator: ',',
          goldUnit: 'gr',
          defaultLocale: 'tr',
        );

        expect(currency.symbolBefore, false);
        expect(currency.thousandSeparator, '.');
        expect(currency.decimalSeparator, ',');
        expect(currency.goldUnit, 'gr');
        expect(currency.defaultLocale, 'tr');
      });
    });

    group('equality', () {
      test('two currencies with same code are equal', () {
        const c1 = Currency(
          code: 'USD',
          symbol: '\$',
          name: 'US Dollar',
          flag: '🇺🇸',
        );

        const c2 = Currency(
          code: 'USD',
          symbol: 'different',
          name: 'Different Name',
          flag: 'X',
        );

        expect(c1, equals(c2));
        expect(c1.hashCode, equals(c2.hashCode));
      });

      test('two currencies with different codes are not equal', () {
        const c1 = Currency(
          code: 'USD',
          symbol: '\$',
          name: 'US Dollar',
          flag: '🇺🇸',
        );

        const c2 = Currency(
          code: 'EUR',
          symbol: '\$',
          name: 'US Dollar',
          flag: '🇺🇸',
        );

        expect(c1, isNot(equals(c2)));
      });
    });
  });

  group('supportedCurrencies', () {
    test('contains TRY', () {
      expect(
        supportedCurrencies.any((c) => c.code == 'TRY'),
        true,
      );
    });

    test('contains USD', () {
      expect(
        supportedCurrencies.any((c) => c.code == 'USD'),
        true,
      );
    });

    test('contains EUR', () {
      expect(
        supportedCurrencies.any((c) => c.code == 'EUR'),
        true,
      );
    });

    test('contains GBP', () {
      expect(
        supportedCurrencies.any((c) => c.code == 'GBP'),
        true,
      );
    });

    test('contains SAR', () {
      expect(
        supportedCurrencies.any((c) => c.code == 'SAR'),
        true,
      );
    });

    test('TRY has correct properties', () {
      final try_ = supportedCurrencies.firstWhere((c) => c.code == 'TRY');
      expect(try_.symbol, '₺');
      expect(try_.symbolBefore, false);
      expect(try_.goldUnit, 'gr');
      expect(try_.defaultLocale, 'tr');
    });

    test('USD has correct properties', () {
      final usd = supportedCurrencies.firstWhere((c) => c.code == 'USD');
      expect(usd.symbol, '\$');
      expect(usd.symbolBefore, true);
      expect(usd.goldUnit, 'oz');
      expect(usd.defaultLocale, 'en');
    });
  });

  group('getCurrencyByCode', () {
    test('returns correct currency for valid code', () {
      final currency = getCurrencyByCode('TRY');
      expect(currency.code, 'TRY');
      expect(currency.symbol, '₺');
    });

    test('returns first currency for invalid code', () {
      final currency = getCurrencyByCode('INVALID');
      expect(currency.code, supportedCurrencies.first.code);
    });

    test('is case sensitive', () {
      final currency = getCurrencyByCode('try');
      expect(currency.code, isNot('TRY'));
    });
  });

  group('getDefaultCurrencyForLocale', () {
    test('returns TRY for Turkish locale', () {
      final currency = getDefaultCurrencyForLocale('tr');
      expect(currency.code, 'TRY');
    });

    test('returns USD for English locale', () {
      final currency = getDefaultCurrencyForLocale('en');
      expect(currency.code, 'USD');
    });

    test('returns EUR for German locale', () {
      final currency = getDefaultCurrencyForLocale('de');
      expect(currency.code, 'EUR');
    });

    test('returns SAR for Arabic locale', () {
      final currency = getDefaultCurrencyForLocale('ar');
      expect(currency.code, 'SAR');
    });

    test('returns USD for unknown locale', () {
      final currency = getDefaultCurrencyForLocale('xx');
      expect(currency.code, 'USD');
    });
  });

  group('allCurrencyCodes', () {
    test('contains all supported currency codes', () {
      expect(allCurrencyCodes, contains('TRY'));
      expect(allCurrencyCodes, contains('USD'));
      expect(allCurrencyCodes, contains('EUR'));
      expect(allCurrencyCodes, contains('GBP'));
      expect(allCurrencyCodes, contains('SAR'));
    });

    test('has same length as supportedCurrencies', () {
      expect(allCurrencyCodes.length, supportedCurrencies.length);
    });
  });
}
