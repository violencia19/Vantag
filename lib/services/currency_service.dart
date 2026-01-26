import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'error_logging_service.dart';

class ExchangeRates {
  final double usdBuying;
  final double usdSelling;
  final double eurBuying;
  final double eurSelling;
  final double goldBuying;
  final double goldSelling;
  final DateTime lastUpdated;
  final bool goldFromApi; // true: Truncgil API'den, false: fallback hesaplama

  const ExchangeRates({
    required this.usdBuying,
    required this.usdSelling,
    required this.eurBuying,
    required this.eurSelling,
    required this.goldBuying,
    required this.goldSelling,
    required this.lastUpdated,
    this.goldFromApi = true,
  });

  Map<String, dynamic> toJson() => {
    'usdBuying': usdBuying,
    'usdSelling': usdSelling,
    'eurBuying': eurBuying,
    'eurSelling': eurSelling,
    'goldBuying': goldBuying,
    'goldSelling': goldSelling,
    'lastUpdated': lastUpdated.toIso8601String(),
    'goldFromApi': goldFromApi,
  };

  factory ExchangeRates.fromJson(Map<String, dynamic> json) => ExchangeRates(
    usdBuying: (json['usdBuying'] as num).toDouble(),
    usdSelling: (json['usdSelling'] as num).toDouble(),
    eurBuying: (json['eurBuying'] as num).toDouble(),
    eurSelling: (json['eurSelling'] as num).toDouble(),
    goldBuying: (json['goldBuying'] as num).toDouble(),
    goldSelling: (json['goldSelling'] as num).toDouble(),
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    goldFromApi: json['goldFromApi'] as bool? ?? true,
  );

  // Ortalama kurlar
  double get usdRate => (usdBuying + usdSelling) / 2;
  double get eurRate => (eurBuying + eurSelling) / 2;
  double get goldRate => (goldBuying + goldSelling) / 2; // TRY per gram

  // Gold in USD per troy ounce (1 oz = 31.1035 grams)
  // Convert from TRY/gram to USD/oz: (TRY/gram * 31.1035) / (TRY/USD)
  double? get goldOzUsd {
    if (usdRate <= 0) return null;
    return (goldRate * 31.1035) / usdRate;
  }

  // Alias for goldRate - TRY per gram
  double get goldGramTry => goldRate;
}

class CurrencyService {
  static const _tcmbUrl = 'https://www.tcmb.gov.tr/kurlar/today.xml';
  static const _truncgilUrl = 'https://finans.truncgil.com/v4/today.json';
  static const _cacheKey = 'cached_exchange_rates';
  static const _goldCacheKey = 'cached_gold_price';
  static const _goldCacheDateKey = 'cached_gold_date';

  /// TCMB'den güncel kurları çeker
  Future<ExchangeRates?> fetchRates() async {
    try {
      // TCMB'den döviz kurlarını al
      final tcmbResponse = await http
          .get(
            Uri.parse(_tcmbUrl),
            headers: {'Accept': 'application/xml', 'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(const Duration(seconds: 10));

      if (tcmbResponse.statusCode != 200) {
        return null;
      }

      // Altın fiyatını al (Truncgil API)
      final goldPrice = await _fetchGoldPrice();

      final rates = _parseXml(tcmbResponse.body, goldPrice);
      if (rates != null) {
        await _cacheRates(rates);
      }
      return rates;
    } catch (e, stack) {
      await errorLogger.logApiError(
        endpoint: _tcmbUrl,
        statusCode: null,
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Truncgil API'den gram altın fiyatını çeker
  Future<({double buying, double selling})?> _fetchGoldPrice() async {
    try {
      // Önce cache kontrol et (günde 1 kez güncelle)
      final cachedGold = await _getCachedGoldPrice();
      if (cachedGold != null) {
        return cachedGold;
      }

      final response = await http
          .get(
            Uri.parse(_truncgilUrl),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'Mozilla/5.0',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return await _getLastCachedGoldPrice();
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // GRA = Gram Altın
      final graData = json['GRA'] as Map<String, dynamic>?;
      if (graData == null) {
        return await _getLastCachedGoldPrice();
      }

      final buying = (graData['Buying'] as num?)?.toDouble() ?? 0;
      final selling = (graData['Selling'] as num?)?.toDouble() ?? 0;

      if (buying <= 0 || selling <= 0) {
        return await _getLastCachedGoldPrice();
      }

      // Cache'e kaydet
      await _cacheGoldPrice(buying, selling);

      return (buying: buying, selling: selling);
    } catch (e) {
      return await _getLastCachedGoldPrice();
    }
  }

  /// Altın fiyatını cache'e kaydeder
  Future<void> _cacheGoldPrice(double buying, double selling) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_goldCacheKey, buying);
    await prefs.setDouble('${_goldCacheKey}_selling', selling);
    await prefs.setString(_goldCacheDateKey, DateTime.now().toIso8601String());
  }

  /// Cache'den altın fiyatını getirir (günde 1 kez güncelleme için)
  Future<({double buying, double selling})?> _getCachedGoldPrice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = prefs.getString(_goldCacheDateKey);

      if (dateStr == null) return null;

      final cacheDate = DateTime.parse(dateStr);
      final now = DateTime.now();

      // Aynı gün içindeyse cache'i kullan
      if (cacheDate.year == now.year &&
          cacheDate.month == now.month &&
          cacheDate.day == now.day) {
        final buying = prefs.getDouble(_goldCacheKey);
        final selling = prefs.getDouble('${_goldCacheKey}_selling');

        if (buying != null && selling != null && buying > 0 && selling > 0) {
          return (buying: buying, selling: selling);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Hata durumunda son cache'lenmiş altın fiyatını getirir
  Future<({double buying, double selling})?> _getLastCachedGoldPrice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final buying = prefs.getDouble(_goldCacheKey);
      final selling = prefs.getDouble('${_goldCacheKey}_selling');

      if (buying != null && selling != null && buying > 0 && selling > 0) {
        return (buying: buying, selling: selling);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// XML'i parse eder ve kurları döndürür
  ExchangeRates? _parseXml(
    String xmlString,
    ({double buying, double selling})? goldPrice,
  ) {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      final currencies = document.findAllElements('Currency');

      double? usdBuying, usdSelling;
      double? eurBuying, eurSelling;

      for (final currency in currencies) {
        final code = currency.getAttribute('CurrencyCode');

        if (code == 'USD') {
          usdBuying = _parseDouble(currency, 'ForexBuying');
          usdSelling = _parseDouble(currency, 'ForexSelling');
        } else if (code == 'EUR') {
          eurBuying = _parseDouble(currency, 'ForexBuying');
          eurSelling = _parseDouble(currency, 'ForexSelling');
        }
      }

      if (usdBuying == null ||
          usdSelling == null ||
          eurBuying == null ||
          eurSelling == null) {
        return null;
      }

      // Altın fiyatı Truncgil API'den alınıyor
      // Eğer API'den alınamazsa USD bazlı yaklaşık hesaplama yap
      double goldBuying;
      double goldSelling;
      bool goldFromApi;

      if (goldPrice != null) {
        goldBuying = goldPrice.buying;
        goldSelling = goldPrice.selling;
        goldFromApi = true;
      } else {
        // Fallback: XAU/USD dünya fiyatı üzerinden hesapla (~85 USD/gram)
        const fallbackGoldUsdPerGram = 85.0;
        goldBuying = fallbackGoldUsdPerGram * usdBuying;
        goldSelling = fallbackGoldUsdPerGram * usdSelling;
        goldFromApi = false;
      }

      return ExchangeRates(
        usdBuying: usdBuying,
        usdSelling: usdSelling,
        eurBuying: eurBuying,
        eurSelling: eurSelling,
        goldBuying: goldBuying,
        goldSelling: goldSelling,
        lastUpdated: DateTime.now(),
        goldFromApi: goldFromApi,
      );
    } catch (e) {
      return null;
    }
  }

  double? _parseDouble(xml.XmlElement element, String tagName) {
    try {
      final node = element.findElements(tagName).firstOrNull;
      if (node == null || node.innerText.isEmpty) return null;
      return double.tryParse(node.innerText);
    } catch (e) {
      return null;
    }
  }

  /// Kurları locale cache'ler
  Future<void> _cacheRates(ExchangeRates rates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(rates.toJson()));
  }

  /// Cache'lenmiş kurları getirir
  Future<ExchangeRates?> getCachedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ExchangeRates.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Önce fetch dener, başarısız olursa cache'den getirir
  Future<ExchangeRates?> getRates({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      // Önce cache kontrol et
      final cached = await getCachedRates();
      if (cached != null) {
        // Cache 1 saatten yeniyse direkt kullan
        final age = DateTime.now().difference(cached.lastUpdated);
        if (age.inHours < 1) {
          return cached;
        }
      }
    }

    // Fetch dene
    final fetched = await fetchRates();
    if (fetched != null) {
      return fetched;
    }

    // Fetch başarısız, cache'den dön
    return await getCachedRates();
  }

  /// TL'yi USD'ye çevirir
  double convertToUSD(double amountTL, ExchangeRates rates) {
    if (rates.usdRate <= 0) return 0;
    return amountTL / rates.usdRate;
  }

  /// TL'yi EUR'ya çevirir
  double convertToEUR(double amountTL, ExchangeRates rates) {
    if (rates.eurRate <= 0) return 0;
    return amountTL / rates.eurRate;
  }

  /// TL'yi gram altına çevirir
  double convertToGold(double amountTL, ExchangeRates rates) {
    if (rates.goldRate <= 0) return 0;
    return amountTL / rates.goldRate;
  }

  /// USD'yi TL'ye çevirir
  double convertFromUSD(double amountUSD, ExchangeRates rates) {
    return amountUSD * rates.usdRate;
  }

  /// EUR'yu TL'ye çevirir
  double convertFromEUR(double amountEUR, ExchangeRates rates) {
    return amountEUR * rates.eurRate;
  }

  /// Gram altını TL'ye çevirir
  double convertFromGold(double amountGold, ExchangeRates rates) {
    return amountGold * rates.goldRate;
  }
}
