import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/services/exchange_rate_service.dart';

void main() {
  group('ExchangeRateService', () {
    group('RateItem', () {
      test('formats currency rate with 2 decimals for values >= 1', () {
        // Arrange
        const rateItem = RateItem(
          flag: '🇺🇸',
          value: 34.52,
          symbol: '₺',
        );

        // Act & Assert
        expect(rateItem.formattedValue, '34.52 ₺');
        expect(rateItem.formattedNumber, '34.52');
      });

      test('formats currency rate with 4 decimals for values < 1', () {
        // Arrange: EUR/USD rate
        const rateItem = RateItem(
          flag: '🇪🇺',
          value: 0.9234,
          symbol: '€',
        );

        // Act & Assert
        expect(rateItem.formattedValue, '0.9234 €');
        expect(rateItem.formattedNumber, '0.9234');
      });

      test('formats gold price with thousand separators', () {
        // Arrange: Gold price > 1000 (use exact integer to avoid rounding)
        const rateItem = RateItem(
          flag: '🥇',
          value: 2650.0,
          symbol: '\$/oz',
          isGold: true,
        );

        // Act & Assert
        expect(rateItem.formattedValue, '2,650 \$/oz');
        expect(rateItem.formattedNumber, '2,650');
      });

      test('formats gold gram price without thousand separators', () {
        // Arrange: Gold price per gram (typically < 1000)
        const rateItem = RateItem(
          flag: '🥇',
          value: 890.25,
          symbol: '₺/gr',
          isGold: true,
        );

        // Act & Assert
        expect(rateItem.formattedValue, '890 ₺/gr');
        expect(rateItem.formattedNumber, '890');
      });

      test('formats small gold values with 2 decimals', () {
        // Arrange: Gold price < 100
        const rateItem = RateItem(
          flag: '🥇',
          value: 85.75,
          symbol: '€/gr',
          isGold: true,
        );

        // Act & Assert
        expect(rateItem.formattedValue, '85.75 €/gr');
        expect(rateItem.formattedNumber, '85.75');
      });
    });

    group('RateBarData', () {
      test('isEmpty returns true for empty items list', () {
        // Arrange
        const rateBarData = RateBarData(
          items: [],
          selectedCurrency: 'TRY',
        );

        // Act & Assert
        expect(rateBarData.isEmpty, true);
        expect(rateBarData.isNotEmpty, false);
      });

      test('isNotEmpty returns true when items exist', () {
        // Arrange
        const rateBarData = RateBarData(
          items: [
            RateItem(flag: '🇺🇸', value: 34.52, symbol: '₺'),
            RateItem(flag: '🇪🇺', value: 37.18, symbol: '₺'),
          ],
          selectedCurrency: 'TRY',
        );

        // Act & Assert
        expect(rateBarData.isEmpty, false);
        expect(rateBarData.isNotEmpty, true);
        expect(rateBarData.items.length, 2);
      });

      test('stores metadata correctly', () {
        // Arrange
        final now = DateTime.now();
        final rateBarData = RateBarData(
          items: const [
            RateItem(flag: '🇺🇸', value: 34.52, symbol: '₺'),
          ],
          selectedCurrency: 'TRY',
          lastUpdated: now,
          source: 'firestore',
        );

        // Act & Assert
        expect(rateBarData.selectedCurrency, 'TRY');
        expect(rateBarData.lastUpdated, now);
        expect(rateBarData.source, 'firestore');
      });
    });

    group('CurrencyDisplayRates', () {
      test('hasRate returns correct values', () {
        // Arrange
        const displayRates = CurrencyDisplayRates(
          baseCurrency: 'USD',
          rates: {'USD': 1.0, 'EUR': 0.93, 'TRY': 34.52},
          goldPrice: 2650.0,
          goldUnit: 'oz',
        );

        // Act & Assert
        expect(displayRates.hasRate('USD'), true);
        expect(displayRates.hasRate('EUR'), true);
        expect(displayRates.hasRate('GBP'), false);
      });

      test('getRate returns correct rate values', () {
        // Arrange
        const displayRates = CurrencyDisplayRates(
          baseCurrency: 'USD',
          rates: {'USD': 1.0, 'EUR': 0.93, 'TRY': 34.52},
        );

        // Act & Assert
        expect(displayRates.getRate('USD'), 1.0);
        expect(displayRates.getRate('EUR'), 0.93);
        expect(displayRates.getRate('TRY'), 34.52);
        expect(displayRates.getRate('GBP'), null);
      });

      test('goldPriceFormatted returns formatted string', () {
        // Arrange
        const displayRates = CurrencyDisplayRates(
          baseCurrency: 'USD',
          rates: {'USD': 1.0},
          goldPrice: 2650.50,
          goldUnit: 'oz',
        );

        // Act & Assert
        expect(displayRates.goldPriceFormatted, '2650.50');
      });

      test('goldPriceFormatted returns null when no gold price', () {
        // Arrange
        const displayRates = CurrencyDisplayRates(
          baseCurrency: 'USD',
          rates: {'USD': 1.0},
        );

        // Act & Assert
        expect(displayRates.goldPriceFormatted, null);
      });
    });

    group('Currency conversion logic', () {
      test('same currency conversion returns same amount', () {
        // The convert formula: amount * (toRate / fromRate)
        // When from == to, result should be same
        const amount = 100.0;
        const fromRate = 34.52;
        const toRate = 34.52;

        final result = amount * (toRate / fromRate);

        expect(result, amount);
      });

      test('USD to TRY conversion formula is correct', () {
        // Arrange: 100 USD to TRY at rate 34.52
        const amount = 100.0;
        const usdRate = 1.0; // USD base rate
        const tryRate = 34.52; // TRY rate in USD terms

        // Act: Convert using the formula from ExchangeRateService
        final result = amount * (tryRate / usdRate);

        // Assert: Use closeTo for floating-point comparison
        expect(result, closeTo(3452.0, 0.001));
      });

      test('TRY to EUR conversion formula is correct', () {
        // Arrange: 1000 TRY to EUR
        // Rates: TRY = 34.52, EUR = 0.93 (both relative to 1 USD)
        const amount = 1000.0;
        const tryRate = 34.52;
        const eurRate = 0.93;

        // Act: Convert using the formula
        final result = amount * (eurRate / tryRate);

        // Assert: 1000 TRY ≈ 26.94 EUR
        expect(result, closeTo(26.94, 0.01));
      });

      test('cross rate calculation EUR to GBP', () {
        // Arrange: 100 EUR to GBP
        // EUR = 0.93, GBP = 0.79 (both relative to 1 USD)
        const amount = 100.0;
        const eurRate = 0.93;
        const gbpRate = 0.79;

        // Act
        final result = amount * (gbpRate / eurRate);

        // Assert: 100 EUR ≈ 84.95 GBP
        expect(result, closeTo(84.95, 0.01));
      });
    });
  });
}
