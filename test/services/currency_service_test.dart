import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/services/currency_service.dart';

void main() {
  late CurrencyService currencyService;
  late ExchangeRates mockRates;

  setUp(() {
    currencyService = CurrencyService();
    mockRates = ExchangeRates(
      usdBuying: 32.0,
      usdSelling: 32.5,
      eurBuying: 35.0,
      eurSelling: 35.5,
      goldBuying: 2850.0,
      goldSelling: 2860.0,
      lastUpdated: DateTime.now(),
    );
  });

  group('CurrencyService', () {
    group('convertToUSD', () {
      test('converts TRY to USD correctly', () {
        // 320 TRY / 32 USD rate = 10 USD
        final result = currencyService.convertToUSD(320, mockRates);
        expect(result, closeTo(10.0, 0.1));
      });

      test('handles zero amount', () {
        final result = currencyService.convertToUSD(0, mockRates);
        expect(result, 0);
      });

      test('handles large amounts', () {
        final result = currencyService.convertToUSD(1000000, mockRates);
        expect(result, greaterThan(30000));
      });
    });

    group('convertToEUR', () {
      test('converts TRY to EUR correctly', () {
        // 350 TRY / 35 EUR rate = 10 EUR
        final result = currencyService.convertToEUR(350, mockRates);
        expect(result, closeTo(10.0, 0.1));
      });

      test('handles zero amount', () {
        final result = currencyService.convertToEUR(0, mockRates);
        expect(result, 0);
      });
    });

    group('convertFromUSD', () {
      test('converts USD to TRY correctly', () {
        // 10 USD * 32 = 320 TRY
        final result = currencyService.convertFromUSD(10, mockRates);
        expect(result, closeTo(320.0, 5.0));
      });

      test('handles zero amount', () {
        final result = currencyService.convertFromUSD(0, mockRates);
        expect(result, 0);
      });
    });

    group('convertFromEUR', () {
      test('converts EUR to TRY correctly', () {
        // 10 EUR * 35 = 350 TRY
        final result = currencyService.convertFromEUR(10, mockRates);
        expect(result, closeTo(350.0, 5.0));
      });

      test('handles zero amount', () {
        final result = currencyService.convertFromEUR(0, mockRates);
        expect(result, 0);
      });
    });

    group('convertToGold', () {
      test('converts TRY to gold grams correctly', () {
        // 28500 TRY / 2850 gold price = 10 grams
        final result = currencyService.convertToGold(28500, mockRates);
        expect(result, closeTo(10.0, 0.1));
      });
    });

    group('convertFromGold', () {
      test('converts gold grams to TRY correctly', () {
        // 10 grams * 2850 gold price = 28500 TRY
        final result = currencyService.convertFromGold(10, mockRates);
        expect(result, closeTo(28500.0, 100.0));
      });
    });
  });
}
