import 'package:flutter/foundation.dart';
import '../models/currency.dart';
import '../models/income_source.dart';
import '../services/currency_preference_service.dart';
import '../services/currency_service.dart';
import '../services/exchange_rate_service.dart';

/// Provider for managing the selected currency and exchange rates
class CurrencyProvider extends ChangeNotifier {
  Currency _currency = supportedCurrencies.first; // Default to TRY
  bool _isInitialized = false;
  bool _isLoadingRates = false;
  String? _rateError;

  // Exchange rate service singleton
  final ExchangeRateService _exchangeService = ExchangeRateService();

  // TCMB rates from CurrencyService (fallback when Firestore is empty)
  ExchangeRates? _tcmbRates;

  // Getters
  Currency get currency => _currency;
  bool get isInitialized => _isInitialized;
  bool get isLoadingRates => _isLoadingRates;
  String? get rateError => _rateError;
  bool get hasRates => _exchangeService.hasRates;

  /// Initialize and load saved currency
  Future<void> loadCurrency() async {
    if (_isInitialized) return;

    _currency = await CurrencyPreferenceService.getCurrency();
    _isInitialized = true;

    // Initialize exchange service from cache
    await _exchangeService.initialize();

    // Also load TCMB rates (from cache first, then API)
    try {
      final currencyService = CurrencyService();
      _tcmbRates = await currencyService.getRates();
      debugPrint('💱 [CurrencyProvider] Initialized with TCMB rates: USD=${_tcmbRates?.usdRate}, EUR=${_tcmbRates?.eurRate}');
    } catch (e) {
      debugPrint('⚠️ [CurrencyProvider] Failed to load TCMB rates: $e');
    }

    notifyListeners();
  }

  /// Set currency and persist
  Future<void> setCurrency(Currency currency) async {
    if (_currency.code == currency.code) return;

    _currency = currency;
    await CurrencyPreferenceService.setCurrency(currency.code);
    notifyListeners();
  }

  /// Fetch latest exchange rates
  Future<void> fetchRates({bool forceRefresh = false}) async {
    if (_isLoadingRates && !forceRefresh) return;

    _isLoadingRates = true;
    _rateError = null;
    notifyListeners();

    try {
      // Try to fetch from Firestore first
      await _exchangeService.fetchAllRates(forceRefresh: forceRefresh);

      // Also fetch TCMB rates as backup (these are always fresh from API)
      final currencyService = CurrencyService();
      _tcmbRates = await currencyService.getRates(forceRefresh: forceRefresh);

      debugPrint('💱 [CurrencyProvider] TCMB rates loaded: USD=${_tcmbRates?.usdRate}, EUR=${_tcmbRates?.eurRate}');

      if (!_exchangeService.hasRates && _tcmbRates == null) {
        _rateError = 'Failed to fetch exchange rates';
      }
    } catch (e) {
      _rateError = e.toString();
    } finally {
      _isLoadingRates = false;
      notifyListeners();
    }
  }

  /// Format amount with current currency
  String format(double amount) {
    return CurrencyPreferenceService.format(_currency, amount);
  }

  /// Format amount with decimals
  String formatWithDecimals(double amount, {int decimalDigits = 2}) {
    return CurrencyPreferenceService.format(
      _currency,
      amount,
      decimalDigits: decimalDigits,
    );
  }

  /// Format without symbol
  String formatWithoutSymbol(double amount, {int decimalDigits = 0}) {
    return CurrencyPreferenceService.formatWithoutSymbol(
      _currency,
      amount,
      decimalDigits: decimalDigits,
    );
  }

  /// Get just the symbol
  String get symbol => _currency.symbol;

  /// Get currency code
  String get code => _currency.code;

  // ═══════════════════════════════════════════════════════════════════
  // EXCHANGE RATE METHODS
  // ═══════════════════════════════════════════════════════════════════

  /// Convert amount between currencies
  /// Returns null if rates are not available
  double? convert(double amount, String from, String to) {
    return _exchangeService.convert(amount, from, to);
  }

  /// Convert amount to current currency
  double? convertToCurrent(double amount, String from) {
    return _exchangeService.convert(amount, from, _currency.code);
  }

  /// Convert amount from current currency
  double? convertFromCurrent(double amount, String to) {
    return _exchangeService.convert(amount, _currency.code, to);
  }

  /// Get rate between two currencies
  double? getRate(String from, String to) {
    return _exchangeService.getRate(from, to);
  }

  /// Get display rates for current currency
  CurrencyDisplayRates getDisplayRates() {
    return _exchangeService.getDisplayRates(_currency.code);
  }

  /// Get gold price in current currency
  double? get goldPrice {
    return _exchangeService.getGoldPrice(_currency.code);
  }

  /// Get gold unit for current currency
  String get goldUnit => _currency.goldUnit;

  /// Get formatted gold price
  String? get goldPriceFormatted {
    final price = goldPrice;
    if (price == null) return null;
    return formatWithDecimals(price, decimalDigits: goldUnit == 'gr' ? 2 : 2);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════

  /// Get all supported currencies
  List<Currency> get supportedCurrencyList => supportedCurrencies;

  /// Get currencies except current
  List<Currency> get otherCurrencies {
    return supportedCurrencies.where((c) => c.code != _currency.code).toList();
  }

  /// Check if a currency is supported
  bool isCurrencySupported(String code) {
    return supportedCurrencies.any((c) => c.code == code);
  }

  /// Convert TRY amount to current currency
  /// Uses TCMB rates first (most accurate), falls back to ExchangeRateService
  /// If current currency is TRY, returns the same amount
  /// If rates not available, returns the original amount
  double convertFromTRY(double amountTRY) {
    if (_currency.code == 'TRY') return amountTRY;

    // Try TCMB rates first (direct from API, most accurate)
    if (_tcmbRates != null) {
      double? rate;
      switch (_currency.code) {
        case 'USD':
          rate = _tcmbRates!.usdRate;
          break;
        case 'EUR':
          rate = _tcmbRates!.eurRate;
          break;
        case 'GBP':
          // GBP not directly available, approximate via USD
          rate = _tcmbRates!.usdRate * 1.27;
          break;
        case 'SAR':
          // SAR pegged to USD at 3.75
          rate = _tcmbRates!.usdRate / 3.75;
          break;
      }

      if (rate != null && rate > 0) {
        final result = amountTRY / rate;
        debugPrint('💱 [convertFromTRY] $amountTRY TRY → ${_currency.code}');
        debugPrint('   Using TCMB rate: $rate, Result: $result');
        return result;
      }
    }

    // Fallback to ExchangeRateService
    final converted = _exchangeService.convert(
      amountTRY,
      'TRY',
      _currency.code,
    );
    return converted ?? amountTRY;
  }

  /// Format amount converting from TRY if needed
  String formatFromTRY(double amountTRY, {int decimalDigits = 0}) {
    final converted = convertFromTRY(amountTRY);
    return CurrencyPreferenceService.format(
      _currency,
      converted,
      decimalDigits: decimalDigits,
    );
  }

  /// Convert amount from current currency TO TRY
  /// Uses TCMB rates first (most accurate)
  double convertToTRY(double amount) {
    if (_currency.code == 'TRY') return amount;

    // Try TCMB rates first
    if (_tcmbRates != null) {
      double? rate;
      switch (_currency.code) {
        case 'USD':
          rate = _tcmbRates!.usdRate;
          break;
        case 'EUR':
          rate = _tcmbRates!.eurRate;
          break;
        case 'GBP':
          rate = _tcmbRates!.usdRate * 1.27;
          break;
        case 'SAR':
          rate = _tcmbRates!.usdRate / 3.75;
          break;
      }

      if (rate != null && rate > 0) {
        final result = amount * rate;
        debugPrint('💱 [convertToTRY] $amount ${_currency.code} → TRY');
        debugPrint('   Using TCMB rate: $rate, Result: $result');
        return result;
      }
    }

    // Fallback to ExchangeRateService
    final converted = _exchangeService.convert(
      amount,
      _currency.code,
      'TRY',
    );
    return converted ?? amount;
  }

  /// Get TCMB rates (for direct access if needed)
  ExchangeRates? get tcmbRates => _tcmbRates;

  /// Check if we have valid TCMB rates
  bool get hasTcmbRates => _tcmbRates != null;

  // ═══════════════════════════════════════════════════════════════════
  // SALARY CONVERSION METHODS
  // ═══════════════════════════════════════════════════════════════════

  /// Convert a single income source to target currency
  /// Returns a new IncomeSource with converted amount, preserving original values
  IncomeSource? convertIncomeSource(
    IncomeSource source,
    String targetCurrency,
  ) {
    if (source.originalCurrencyCode == targetCurrency) {
      // Same as original - return with original amount
      return source.convertedTo(
        newAmount: source.originalAmount,
        newCurrencyCode: targetCurrency,
      );
    }

    final converted = _exchangeService.convert(
      source.originalAmount,
      source.originalCurrencyCode,
      targetCurrency,
    );

    if (converted == null) return null;

    return source.convertedTo(
      newAmount: converted,
      newCurrencyCode: targetCurrency,
    );
  }

  /// Convert all income sources to target currency
  /// Returns list of converted IncomeSource objects
  List<IncomeSource>? convertIncomeSources(
    List<IncomeSource> sources,
    String targetCurrency,
  ) {
    final converted = <IncomeSource>[];

    for (final source in sources) {
      final convertedSource = convertIncomeSource(source, targetCurrency);
      if (convertedSource == null) return null;
      converted.add(convertedSource);
    }

    return converted;
  }

  /// Get formatted salary conversion info for display
  /// Returns a string like "25,000 TL → $725" or null if conversion fails
  String? getSalaryConversionInfo({
    required double originalAmount,
    required String originalCurrency,
    required String targetCurrency,
  }) {
    if (originalCurrency == targetCurrency) return null;

    final converted = _exchangeService.convert(
      originalAmount,
      originalCurrency,
      targetCurrency,
    );

    if (converted == null) return null;

    final originalCurrencyObj = getCurrencyByCode(originalCurrency);
    final targetCurrencyObj = getCurrencyByCode(targetCurrency);

    final originalFormatted = CurrencyPreferenceService.format(
      originalCurrencyObj,
      originalAmount,
      decimalDigits: 0,
    );

    final convertedFormatted = CurrencyPreferenceService.format(
      targetCurrencyObj,
      converted,
      decimalDigits: 0,
    );

    return '$originalFormatted → $convertedFormatted';
  }
}
