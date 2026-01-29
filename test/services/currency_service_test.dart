import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/services/currency_service.dart';

void main() {
  late CurrencyService currencyService;
  late ExchangeRates mockRates;
  late ExchangeRates zeroRates;
  late ExchangeRates highRates;

  setUp(() {
    currencyService = CurrencyService();

    // Standard mock rates
    mockRates = ExchangeRates(
      usdBuying: 32.0,
      usdSelling: 32.5,
      eurBuying: 35.0,
      eurSelling: 35.5,
      goldBuying: 2850.0,
      goldSelling: 2860.0,
      lastUpdated: DateTime.now(),
    );

    // Zero rates for edge case testing
    zeroRates = ExchangeRates(
      usdBuying: 0,
      usdSelling: 0,
      eurBuying: 0,
      eurSelling: 0,
      goldBuying: 0,
      goldSelling: 0,
      lastUpdated: DateTime.now(),
    );

    // High rates for large number testing
    highRates = ExchangeRates(
      usdBuying: 50.0,
      usdSelling: 50.5,
      eurBuying: 55.0,
      eurSelling: 55.5,
      goldBuying: 5000.0,
      goldSelling: 5100.0,
      lastUpdated: DateTime.now(),
    );
  });

  group('CurrencyService', () {
    // ========================================
    // ExchangeRates Model Tests
    // ========================================
    group('ExchangeRates', () {
      test('1. calculates average USD rate correctly', () {
        // (32.0 + 32.5) / 2 = 32.25
        expect(mockRates.usdRate, 32.25);
      });

      test('2. calculates average EUR rate correctly', () {
        // (35.0 + 35.5) / 2 = 35.25
        expect(mockRates.eurRate, 35.25);
      });

      test('3. calculates average gold rate correctly', () {
        // (2850.0 + 2860.0) / 2 = 2855
        expect(mockRates.goldRate, 2855.0);
      });

      test('4. goldGramTry returns gold rate', () {
        expect(mockRates.goldGramTry, mockRates.goldRate);
      });

      test('5. goldOzUsd calculates correctly', () {
        // (goldRate * 31.1035) / usdRate
        // (2855 * 31.1035) / 32.25 = 2753.7...
        final expectedOz = (mockRates.goldRate * 31.1035) / mockRates.usdRate;
        expect(mockRates.goldOzUsd, closeTo(expectedOz, 0.1));
      });

      test('6. goldOzUsd returns null when usdRate is zero', () {
        expect(zeroRates.goldOzUsd, isNull);
      });

      test('7. toJson and fromJson round-trip', () {
        final json = mockRates.toJson();
        final restored = ExchangeRates.fromJson(json);

        expect(restored.usdBuying, mockRates.usdBuying);
        expect(restored.usdSelling, mockRates.usdSelling);
        expect(restored.eurBuying, mockRates.eurBuying);
        expect(restored.eurSelling, mockRates.eurSelling);
        expect(restored.goldBuying, mockRates.goldBuying);
        expect(restored.goldSelling, mockRates.goldSelling);
        expect(restored.goldFromApi, mockRates.goldFromApi);
      });

      test('8. fromJson handles goldFromApi default value', () {
        final json = mockRates.toJson();
        json.remove('goldFromApi'); // Remove the field

        final restored = ExchangeRates.fromJson(json);
        expect(restored.goldFromApi, true); // Default value
      });
    });

    // ========================================
    // convertToUSD Tests
    // ========================================
    group('convertToUSD', () {
      test('1. converts TRY to USD correctly', () {
        // 322.5 TRY / 32.25 USD rate = 10 USD
        final result = currencyService.convertToUSD(322.5, mockRates);
        expect(result, closeTo(10.0, 0.01));
      });

      test('2. handles zero amount', () {
        final result = currencyService.convertToUSD(0, mockRates);
        expect(result, 0);
      });

      test('3. handles negative amount', () {
        final result = currencyService.convertToUSD(-322.5, mockRates);
        expect(result, closeTo(-10.0, 0.01));
      });

      test('4. handles very large amounts', () {
        final result = currencyService.convertToUSD(1000000, mockRates);
        // 1000000 / 32.25 = 31007.75...
        expect(result, closeTo(31007.75, 1.0));
      });

      test('5. handles very small amounts', () {
        final result = currencyService.convertToUSD(0.01, mockRates);
        expect(result, greaterThan(0));
        expect(result, lessThan(0.01));
      });

      test('6. returns zero when rate is zero', () {
        final result = currencyService.convertToUSD(100, zeroRates);
        expect(result, 0);
      });
    });

    // ========================================
    // convertToEUR Tests
    // ========================================
    group('convertToEUR', () {
      test('1. converts TRY to EUR correctly', () {
        // 352.5 TRY / 35.25 EUR rate = 10 EUR
        final result = currencyService.convertToEUR(352.5, mockRates);
        expect(result, closeTo(10.0, 0.01));
      });

      test('2. handles zero amount', () {
        final result = currencyService.convertToEUR(0, mockRates);
        expect(result, 0);
      });

      test('3. handles negative amount', () {
        final result = currencyService.convertToEUR(-352.5, mockRates);
        expect(result, closeTo(-10.0, 0.01));
      });

      test('4. handles large amounts', () {
        final result = currencyService.convertToEUR(1000000, mockRates);
        expect(result, closeTo(28368.79, 1.0));
      });

      test('5. returns zero when rate is zero', () {
        final result = currencyService.convertToEUR(100, zeroRates);
        expect(result, 0);
      });
    });

    // ========================================
    // convertFromUSD Tests
    // ========================================
    group('convertFromUSD', () {
      test('1. converts USD to TRY correctly', () {
        // 10 USD * 32.25 = 322.5 TRY
        final result = currencyService.convertFromUSD(10, mockRates);
        expect(result, closeTo(322.5, 0.1));
      });

      test('2. handles zero amount', () {
        final result = currencyService.convertFromUSD(0, mockRates);
        expect(result, 0);
      });

      test('3. handles negative amount', () {
        final result = currencyService.convertFromUSD(-10, mockRates);
        expect(result, closeTo(-322.5, 0.1));
      });

      test('4. handles large amounts', () {
        final result = currencyService.convertFromUSD(100000, mockRates);
        expect(result, closeTo(3225000, 100));
      });

      test('5. handles fractional amounts', () {
        final result = currencyService.convertFromUSD(0.5, mockRates);
        expect(result, closeTo(16.125, 0.01));
      });
    });

    // ========================================
    // convertFromEUR Tests
    // ========================================
    group('convertFromEUR', () {
      test('1. converts EUR to TRY correctly', () {
        // 10 EUR * 35.25 = 352.5 TRY
        final result = currencyService.convertFromEUR(10, mockRates);
        expect(result, closeTo(352.5, 0.1));
      });

      test('2. handles zero amount', () {
        final result = currencyService.convertFromEUR(0, mockRates);
        expect(result, 0);
      });

      test('3. handles negative amount', () {
        final result = currencyService.convertFromEUR(-10, mockRates);
        expect(result, closeTo(-352.5, 0.1));
      });

      test('4. handles large amounts', () {
        final result = currencyService.convertFromEUR(100000, mockRates);
        expect(result, closeTo(3525000, 100));
      });
    });

    // ========================================
    // convertToGold Tests
    // ========================================
    group('convertToGold', () {
      test('1. converts TRY to gold grams correctly', () {
        // 28550 TRY / 2855 gold price = 10 grams
        final result = currencyService.convertToGold(28550, mockRates);
        expect(result, closeTo(10.0, 0.01));
      });

      test('2. handles zero amount', () {
        final result = currencyService.convertToGold(0, mockRates);
        expect(result, 0);
      });

      test('3. handles small amounts (fractional gram)', () {
        final result = currencyService.convertToGold(100, mockRates);
        // 100 / 2855 = 0.035 grams
        expect(result, closeTo(0.035, 0.001));
      });

      test('4. handles large amounts', () {
        final result = currencyService.convertToGold(1000000, mockRates);
        // 1000000 / 2855 = 350.26 grams
        expect(result, closeTo(350.26, 0.1));
      });

      test('5. returns zero when gold rate is zero', () {
        final result = currencyService.convertToGold(100, zeroRates);
        expect(result, 0);
      });
    });

    // ========================================
    // convertFromGold Tests
    // ========================================
    group('convertFromGold', () {
      test('1. converts gold grams to TRY correctly', () {
        // 10 grams * 2855 gold price = 28550 TRY
        final result = currencyService.convertFromGold(10, mockRates);
        expect(result, closeTo(28550.0, 1.0));
      });

      test('2. handles zero amount', () {
        final result = currencyService.convertFromGold(0, mockRates);
        expect(result, 0);
      });

      test('3. handles fractional grams', () {
        final result = currencyService.convertFromGold(0.5, mockRates);
        // 0.5 * 2855 = 1427.5 TRY
        expect(result, closeTo(1427.5, 0.1));
      });

      test('4. handles large amounts (1 kg gold)', () {
        final result = currencyService.convertFromGold(1000, mockRates);
        // 1000 * 2855 = 2,855,000 TRY
        expect(result, closeTo(2855000, 100));
      });
    });

    // ========================================
    // Cross-Conversion Consistency Tests
    // ========================================
    group('cross-conversion consistency', () {
      test('1. USD round-trip conversion', () {
        const originalTRY = 1000.0;
        final usd = currencyService.convertToUSD(originalTRY, mockRates);
        final backToTRY = currencyService.convertFromUSD(usd, mockRates);
        expect(backToTRY, closeTo(originalTRY, 0.01));
      });

      test('2. EUR round-trip conversion', () {
        const originalTRY = 1000.0;
        final eur = currencyService.convertToEUR(originalTRY, mockRates);
        final backToTRY = currencyService.convertFromEUR(eur, mockRates);
        expect(backToTRY, closeTo(originalTRY, 0.01));
      });

      test('3. Gold round-trip conversion', () {
        const originalTRY = 10000.0;
        final gold = currencyService.convertToGold(originalTRY, mockRates);
        final backToTRY = currencyService.convertFromGold(gold, mockRates);
        expect(backToTRY, closeTo(originalTRY, 0.01));
      });

      test('4. EUR is more valuable than USD (same TRY amount)', () {
        const amountTRY = 1000.0;
        final usd = currencyService.convertToUSD(amountTRY, mockRates);
        final eur = currencyService.convertToEUR(amountTRY, mockRates);

        // EUR has higher rate, so you get less EUR for same TRY
        expect(eur, lessThan(usd));
      });

      test('5. conversion maintains proportionality', () {
        final usd100 = currencyService.convertToUSD(100, mockRates);
        final usd200 = currencyService.convertToUSD(200, mockRates);

        expect(usd200, closeTo(usd100 * 2, 0.01));
      });
    });

    // ========================================
    // Rate Changes Impact Tests
    // ========================================
    group('rate changes', () {
      test('1. higher rates mean less foreign currency', () {
        const amount = 1000.0;
        final standardUSD = currencyService.convertToUSD(amount, mockRates);
        final highRateUSD = currencyService.convertToUSD(amount, highRates);

        // Higher USD rate means you get less USD for same TRY
        expect(highRateUSD, lessThan(standardUSD));
      });

      test('2. lower rates mean more foreign currency', () {
        final lowRates = ExchangeRates(
          usdBuying: 20.0,
          usdSelling: 20.5,
          eurBuying: 22.0,
          eurSelling: 22.5,
          goldBuying: 1500.0,
          goldSelling: 1550.0,
          lastUpdated: DateTime.now(),
        );

        const amount = 1000.0;
        final standardUSD = currencyService.convertToUSD(amount, mockRates);
        final lowRateUSD = currencyService.convertToUSD(amount, lowRates);

        // Lower USD rate means you get more USD for same TRY
        expect(lowRateUSD, greaterThan(standardUSD));
      });
    });

    // ========================================
    // Edge Cases and Error Handling
    // ========================================
    group('edge cases', () {
      test('1. handles very precise decimal values', () {
        final result = currencyService.convertToUSD(123.456789, mockRates);
        expect(result.isFinite, true);
      });

      test('2. handles maximum finite double', () {
        // Should not throw
        expect(
          () => currencyService.convertToUSD(double.maxFinite / 100, mockRates),
          returnsNormally,
        );
      });

      test('3. handles minimum positive double', () {
        final result = currencyService.convertToUSD(double.minPositive, mockRates);
        expect(result, greaterThanOrEqualTo(0));
      });

      test('4. buying and selling rates create spread', () {
        // Selling rate should be higher than buying rate
        expect(mockRates.usdSelling, greaterThan(mockRates.usdBuying));
        expect(mockRates.eurSelling, greaterThan(mockRates.eurBuying));
        expect(mockRates.goldSelling, greaterThan(mockRates.goldBuying));
      });

      test('5. lastUpdated is preserved correctly', () {
        final now = DateTime.now();
        final rates = ExchangeRates(
          usdBuying: 32.0,
          usdSelling: 32.5,
          eurBuying: 35.0,
          eurSelling: 35.5,
          goldBuying: 2850.0,
          goldSelling: 2860.0,
          lastUpdated: now,
        );

        expect(rates.lastUpdated, now);
      });

      test('6. goldFromApi flag works correctly', () {
        final ratesFromApi = ExchangeRates(
          usdBuying: 32.0,
          usdSelling: 32.5,
          eurBuying: 35.0,
          eurSelling: 35.5,
          goldBuying: 2850.0,
          goldSelling: 2860.0,
          lastUpdated: DateTime.now(),
          goldFromApi: true,
        );

        final ratesFallback = ExchangeRates(
          usdBuying: 32.0,
          usdSelling: 32.5,
          eurBuying: 35.0,
          eurSelling: 35.5,
          goldBuying: 2850.0,
          goldSelling: 2860.0,
          lastUpdated: DateTime.now(),
          goldFromApi: false,
        );

        expect(ratesFromApi.goldFromApi, true);
        expect(ratesFallback.goldFromApi, false);
      });
    });
  });
}
