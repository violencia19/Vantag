import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

/// USD-based exchange rate service
/// Primary source: Firestore (updated by Cloud Function every hour)
/// Fallback: Direct API calls
class ExchangeRateService {
  // Singleton
  static final ExchangeRateService _instance = ExchangeRateService._internal();
  factory ExchangeRateService() => _instance;
  ExchangeRateService._internal();

  // ═══════════════════════════════════════════════════════════════════
  // CURRENCY CLASSIFICATIONS
  // ═══════════════════════════════════════════════════════════════════
  static const List<String> majorCurrencies = ['USD', 'EUR', 'GBP'];
  static const List<String> minorCurrencies = ['TRY', 'SAR'];

  // Firestore path
  static const _firestorePath = 'app_data/exchange_rates';

  // Cache keys
  static const _ratesCacheKey = 'exchange_rates_usd_base';
  static const _goldCacheKey = 'gold_price_usd';
  static const _goldTryKey = 'gold_price_try_gram';
  static const _lastFetchKey = 'exchange_rates_last_fetch';

  // Fallback API URLs (used when Firestore is unavailable)
  static const _exchangeRateApiUrl = 'https://api.exchangerate-api.com/v4/latest/USD';
  static const _goldApiUrl = 'https://api.metals.live/v1/spot/gold';
  static const _truncgilGoldUrl = 'https://finans.truncgil.com/v4/today.json';

  // State - rates relative to 1 USD
  Map<String, double> _ratesInUSD = {};
  double? _goldUSD; // Gold price in USD per troy ounce
  double? _goldTRYPerGram; // Gold price in TRY per gram (from Truncgil)
  DateTime? _lastFetch;
  bool _isLoading = false;
  String _source = 'none';

  // Getters
  bool get hasRates => _ratesInUSD.isNotEmpty;
  bool get hasGold => _goldUSD != null;
  bool get isLoading => _isLoading;
  DateTime? get lastFetch => _lastFetch;
  String get source => _source;
  Map<String, double> get rates => Map.unmodifiable(_ratesInUSD);
  double? get goldUsdPerOz => _goldUSD;
  double? get goldTryPerGram => _goldTRYPerGram;

  // ═══════════════════════════════════════════════════════════════════
  // RATE BAR DATA - For Currency Rate Widget Display
  // ═══════════════════════════════════════════════════════════════════

  /// Get formatted rate bar data for the selected currency
  /// Returns appropriate rates based on whether currency is major or minor
  RateBarData getRateBarData(String selectedCurrency) {
    final isMajor = majorCurrencies.contains(selectedCurrency);
    final isMinor = minorCurrencies.contains(selectedCurrency);

    List<RateItem> items = [];

    // Get current rates with fallbacks
    final usdTry = _ratesInUSD['TRY'] ?? 34.50;
    final eurUsd = _ratesInUSD['EUR'] ?? 0.93;
    final gbpUsd = _ratesInUSD['GBP'] ?? 0.79;
    final goldOz = _goldUSD ?? 2650.0;
    final goldGram = _goldTRYPerGram ?? (goldOz * usdTry / 31.1035);

    // Cross rates
    final eurTry = usdTry / eurUsd; // 1 EUR = X TRY
    final eurToUsd = 1 / eurUsd; // 1 EUR = X USD
    final gbpToUsd = 1 / gbpUsd; // 1 GBP = X USD

    if (isMinor) {
      // ─────────────────────────────────────────────────────────────────
      // MINOR CURRENCIES (TRY, SAR) - Show major currencies in local terms
      // ─────────────────────────────────────────────────────────────────
      if (selectedCurrency == 'TRY') {
        // TRY seçili → "🇺🇸 34.52 ₺ | 🇪🇺 37.18 ₺ | 🥇 2,890 ₺/gr"
        items = [
          RateItem(flag: '🇺🇸', value: usdTry, symbol: '₺'),
          RateItem(flag: '🇪🇺', value: eurTry, symbol: '₺'),
          RateItem(flag: '🥇', value: goldGram, symbol: '₺/gr', isGold: true),
        ];
      } else if (selectedCurrency == 'SAR') {
        // SAR seçili → Show rates in SAR (SAR is pegged ~3.75 to USD)
        final sarRate = _ratesInUSD['SAR'] ?? 3.75;
        final goldSar = goldOz * sarRate;
        items = [
          RateItem(flag: '🇺🇸', value: sarRate, symbol: '﷼'),
          RateItem(flag: '🇪🇺', value: sarRate / eurUsd, symbol: '﷼'),
          RateItem(flag: '🥇', value: goldSar, symbol: '\$/oz', isGold: true),
        ];
      }
    } else if (isMajor) {
      // ─────────────────────────────────────────────────────────────────
      // MAJOR CURRENCIES (USD, EUR, GBP) - Show other majors + gold
      // ─────────────────────────────────────────────────────────────────
      if (selectedCurrency == 'USD') {
        // USD seçili → "🇪🇺 0.93 € | 🇬🇧 0.79 £ | 🥇 $2,650/oz"
        items = [
          RateItem(flag: '🇪🇺', value: eurUsd, symbol: '€'),
          RateItem(flag: '🇬🇧', value: gbpUsd, symbol: '£'),
          RateItem(flag: '🥇', value: goldOz, symbol: '\$/oz', isGold: true),
        ];
      } else if (selectedCurrency == 'EUR') {
        // EUR seçili → "🇺🇸 1.08 $ | 🇬🇧 0.85 £ | 🥇 €2,465/oz"
        final gbpPerEur = gbpUsd / eurUsd;
        final goldEur = goldOz * eurUsd;
        items = [
          RateItem(flag: '🇺🇸', value: eurToUsd, symbol: '\$'),
          RateItem(flag: '🇬🇧', value: gbpPerEur, symbol: '£'),
          RateItem(flag: '🥇', value: goldEur, symbol: '€/oz', isGold: true),
        ];
      } else if (selectedCurrency == 'GBP') {
        // GBP seçili → "🇺🇸 1.27 $ | 🇪🇺 1.18 € | 🥇 £2,087/oz"
        final eurPerGbp = eurUsd / gbpUsd;
        final goldGbp = goldOz * gbpUsd;
        items = [
          RateItem(flag: '🇺🇸', value: gbpToUsd, symbol: '\$'),
          RateItem(flag: '🇪🇺', value: eurPerGbp, symbol: '€'),
          RateItem(flag: '🥇', value: goldGbp, symbol: '£/oz', isGold: true),
        ];
      }
    } else {
      // Unknown currency - show USD and EUR rates
      final rate = _ratesInUSD[selectedCurrency] ?? 1.0;
      items = [
        RateItem(flag: '🇺🇸', value: 1 / rate, symbol: '\$'),
        RateItem(flag: '🇪🇺', value: eurUsd / rate, symbol: '€'),
        RateItem(flag: '🥇', value: goldOz / rate, symbol: '/oz', isGold: true),
      ];
    }

    return RateBarData(
      items: items,
      selectedCurrency: selectedCurrency,
      lastUpdated: _lastFetch,
      source: _source,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FETCH METHODS
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch all exchange rates
  /// Priority: 1. Firestore (Cloud Function), 2. Direct API, 3. Local cache
  /// Cache duration: 24 hours to prevent API rate limiting
  Future<void> fetchAllRates({bool forceRefresh = false}) async {
    // Cache check (24 hours)
    if (!forceRefresh && _lastFetch != null) {
      final age = DateTime.now().difference(_lastFetch!);
      if (age.inHours < 24 && _ratesInUSD.isNotEmpty) {
        return;
      }
    }

    if (_isLoading) return;
    _isLoading = true;

    try {
      // Try Firestore first (Cloud Function updates this every hour)
      final firestoreSuccess = await _fetchFromFirestore();

      if (!firestoreSuccess) {
        // Fallback to direct API calls
        await _fetchFromAPIs();
      }

      _lastFetch = DateTime.now();

      // Cache locally
      await _cacheRates();
    } catch (e) {
      // On error, try to load from local cache
      await _loadFromCache();
    } finally {
      _isLoading = false;
    }
  }

  /// Fetch rates from Firestore (primary source)
  Future<bool> _fetchFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .doc(_firestorePath)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      // Parse rates
      final rates = data['rates'] as Map<String, dynamic>?;
      if (rates != null) {
        _ratesInUSD = {};
        for (final entry in rates.entries) {
          if (entry.value is num) {
            _ratesInUSD[entry.key] = (entry.value as num).toDouble();
          }
        }
        _ratesInUSD['USD'] = 1.0;
      }

      // Parse gold
      final gold = data['gold'] as Map<String, dynamic>?;
      if (gold != null) {
        _goldUSD = (gold['usdPerOz'] as num?)?.toDouble();
        _goldTRYPerGram = (gold['tryPerGram'] as num?)?.toDouble();
      }

      // Parse timestamp
      final updatedAt = data['updatedAt'] as Timestamp?;
      if (updatedAt != null) {
        _lastFetch = updatedAt.toDate();
      }

      _source = 'firestore';
      return _ratesInUSD.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Fetch rates directly from APIs (fallback)
  Future<void> _fetchFromAPIs() async {
    await _fetchExchangeRates();
    await _fetchGoldPrice();
    _source = 'api';
  }

  /// Fetch exchange rates from API
  Future<void> _fetchExchangeRates() async {
    try {
      final response = await http.get(
        Uri.parse(_exchangeRateApiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>?;

        if (rates != null) {
          _ratesInUSD = {};
          for (final entry in rates.entries) {
            final value = entry.value;
            if (value is num) {
              _ratesInUSD[entry.key] = value.toDouble();
            }
          }
          _ratesInUSD['USD'] = 1.0;
        }
      }
    } catch (e) {
      // Keep existing rates if fetch fails
    }
  }

  /// Fetch gold price in USD per troy ounce
  Future<void> _fetchGoldPrice() async {
    // Try metals.live API first
    try {
      final response = await http.get(
        Uri.parse(_goldApiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final goldData = data[0] as Map<String, dynamic>?;
          final price = goldData?['price'];
          if (price is num && price > 0) {
            _goldUSD = price.toDouble();
            return;
          }
        }
      }
    } catch (e) {
      // Continue to fallback
    }

    // Fallback: Use Truncgil API for Turkish gold price
    await _fetchGoldFromTruncgil();
  }

  /// Fallback: Fetch gold from Truncgil and convert to USD
  Future<void> _fetchGoldFromTruncgil() async {
    try {
      final response = await http.get(
        Uri.parse(_truncgilGoldUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final graData = data['GRA'] as Map<String, dynamic>?;

        if (graData != null) {
          final buyingTRY = (graData['Buying'] as num?)?.toDouble();
          final sellingTRY = (graData['Selling'] as num?)?.toDouble();

          if (buyingTRY != null && sellingTRY != null && buyingTRY > 0) {
            // Store TRY per gram directly
            _goldTRYPerGram = (buyingTRY + sellingTRY) / 2;

            // Convert to USD per oz if we have TRY rate
            final tryRate = _ratesInUSD['TRY'];
            if (tryRate != null && tryRate > 0) {
              _goldUSD = (_goldTRYPerGram! * 31.1035) / tryRate;
            }
          }
        }
      }
    } catch (e) {
      // Keep existing gold price
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CONVERSION METHODS
  // ═══════════════════════════════════════════════════════════════════

  // Fallback rates (approximate, updated manually if needed)
  static const Map<String, double> _fallbackRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'TRY': 34.5,
    'SAR': 3.75,
  };

  /// Convert amount from one currency to another
  double? convert(double amount, String from, String to) {
    if (from == to) return amount;

    // Use actual rates if available, otherwise use fallback
    final rates = _ratesInUSD.isNotEmpty ? _ratesInUSD : _fallbackRates;

    final fromRate = rates[from];
    final toRate = rates[to];

    if (fromRate == null || toRate == null) return null;
    if (fromRate <= 0) return null;

    return amount * (toRate / fromRate);
  }

  /// Get rate between two currencies
  double? getRate(String from, String to) {
    if (from == to) return 1.0;
    return convert(1, from, to);
  }

  /// Get display rates for the selected currency (legacy method)
  CurrencyDisplayRates getDisplayRates(String selectedCurrency) {
    final rates = <String, double>{};

    for (final currency in supportedCurrencies) {
      if (currency.code == selectedCurrency) {
        rates[currency.code] = 1.0;
      } else {
        final rate = convert(1, selectedCurrency, currency.code);
        if (rate != null) {
          rates[currency.code] = rate;
        }
      }
    }

    // Gold price in selected currency
    double? goldPrice;
    String goldUnit = 'oz';

    if (_goldUSD != null) {
      final selectedCurrencyObj = getCurrencyByCode(selectedCurrency);
      goldUnit = selectedCurrencyObj.goldUnit;

      // For TRY, use direct TRY/gram price if available
      if (selectedCurrency == 'TRY' && _goldTRYPerGram != null) {
        goldPrice = _goldTRYPerGram;
      } else {
        // Convert gold from USD to selected currency
        final goldInSelected = convert(_goldUSD!, 'USD', selectedCurrency);
        if (goldInSelected != null) {
          goldPrice = goldInSelected;
          if (goldUnit == 'gr') {
            goldPrice = goldPrice / 31.1035;
          }
        }
      }
    }

    return CurrencyDisplayRates(
      baseCurrency: selectedCurrency,
      rates: rates,
      goldPrice: goldPrice,
      goldUnit: goldUnit,
      lastUpdated: _lastFetch,
      source: _source,
    );
  }

  /// Get gold price in specified currency and unit
  double? getGoldPrice(String currencyCode, {String? unit}) {
    if (_goldUSD == null) return null;

    final currency = getCurrencyByCode(currencyCode);
    final targetUnit = unit ?? currency.goldUnit;

    // For TRY with gram unit, use direct price if available
    if (currencyCode == 'TRY' && targetUnit == 'gr' && _goldTRYPerGram != null) {
      return _goldTRYPerGram;
    }

    final goldInCurrency = convert(_goldUSD!, 'USD', currencyCode);
    if (goldInCurrency == null) return null;

    if (targetUnit == 'gr') {
      return goldInCurrency / 31.1035;
    }

    return goldInCurrency;
  }

  // ═══════════════════════════════════════════════════════════════════
  // CACHE METHODS
  // ═══════════════════════════════════════════════════════════════════

  /// Cache rates to SharedPreferences
  Future<void> _cacheRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ratesCacheKey, json.encode(_ratesInUSD));
      if (_goldUSD != null) {
        await prefs.setDouble(_goldCacheKey, _goldUSD!);
      }
      if (_goldTRYPerGram != null) {
        await prefs.setDouble(_goldTryKey, _goldTRYPerGram!);
      }
      if (_lastFetch != null) {
        await prefs.setString(_lastFetchKey, _lastFetch!.toIso8601String());
      }
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Load rates from local cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final ratesJson = prefs.getString(_ratesCacheKey);
      if (ratesJson != null) {
        final decoded = json.decode(ratesJson) as Map<String, dynamic>;
        _ratesInUSD = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }

      final goldPrice = prefs.getDouble(_goldCacheKey);
      if (goldPrice != null && goldPrice > 0) {
        _goldUSD = goldPrice;
      }

      final goldTry = prefs.getDouble(_goldTryKey);
      if (goldTry != null && goldTry > 0) {
        _goldTRYPerGram = goldTry;
      }

      final lastFetchStr = prefs.getString(_lastFetchKey);
      if (lastFetchStr != null) {
        _lastFetch = DateTime.tryParse(lastFetchStr);
      }

      _source = 'cache';
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Initialize service (load from cache first, then fetch)
  Future<void> initialize() async {
    await _loadFromCache();
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    _ratesInUSD = {};
    _goldUSD = null;
    _goldTRYPerGram = null;
    _lastFetch = null;
    _source = 'none';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ratesCacheKey);
    await prefs.remove(_goldCacheKey);
    await prefs.remove(_goldTryKey);
    await prefs.remove(_lastFetchKey);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Single rate item for display in rate bar
class RateItem {
  final String flag;
  final double value;
  final String symbol;
  final bool isGold;

  const RateItem({
    required this.flag,
    required this.value,
    required this.symbol,
    this.isGold = false,
  });

  /// Formatted value string with appropriate decimal places
  String get formattedValue {
    String formatted;

    if (isGold) {
      // Gold: show as integer if > 100, otherwise 2 decimals
      if (value >= 1000) {
        // Add thousand separators for large gold values
        formatted = value.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
      } else if (value >= 100) {
        formatted = value.toStringAsFixed(0);
      } else {
        formatted = value.toStringAsFixed(2);
      }
    } else {
      // Currency rates: 2-4 decimal places based on value
      if (value >= 100) {
        formatted = value.toStringAsFixed(2);
      } else if (value >= 1) {
        formatted = value.toStringAsFixed(2);
      } else {
        formatted = value.toStringAsFixed(4);
      }
    }

    return '$formatted $symbol';
  }

  /// Just the formatted number without symbol
  String get formattedNumber {
    if (isGold) {
      if (value >= 1000) {
        return value.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
      } else if (value >= 100) {
        return value.toStringAsFixed(0);
      } else {
        return value.toStringAsFixed(2);
      }
    } else {
      if (value >= 100) {
        return value.toStringAsFixed(2);
      } else if (value >= 1) {
        return value.toStringAsFixed(2);
      } else {
        return value.toStringAsFixed(4);
      }
    }
  }
}

/// Rate bar data containing all items to display
class RateBarData {
  final List<RateItem> items;
  final String selectedCurrency;
  final DateTime? lastUpdated;
  final String source;

  const RateBarData({
    required this.items,
    required this.selectedCurrency,
    this.lastUpdated,
    this.source = 'none',
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

/// Display rates model (legacy, kept for compatibility)
class CurrencyDisplayRates {
  final String baseCurrency;
  final Map<String, double> rates;
  final double? goldPrice;
  final String goldUnit;
  final DateTime? lastUpdated;
  final String source;

  const CurrencyDisplayRates({
    required this.baseCurrency,
    required this.rates,
    this.goldPrice,
    this.goldUnit = 'oz',
    this.lastUpdated,
    this.source = 'none',
  });

  bool hasRate(String code) => rates.containsKey(code);
  double? getRate(String code) => rates[code];

  String? get goldPriceFormatted {
    if (goldPrice == null) return null;
    final decimals = goldUnit == 'gr' ? 2 : 2;
    return goldPrice!.toStringAsFixed(decimals);
  }
}
