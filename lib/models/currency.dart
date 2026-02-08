/// Currency model for multi-currency support
/// Adding a new currency = 1 line in supportedCurrencies list
class Currency {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  final bool symbolBefore;
  final String thousandSeparator;
  final String decimalSeparator;
  final String goldUnit; // 'oz' (ounce) or 'gr' (gram)
  final String? defaultLocale; // Language code that defaults to this currency

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    this.symbolBefore = true,
    this.thousandSeparator = ',',
    this.decimalSeparator = '.',
    this.goldUnit = 'oz',
    this.defaultLocale,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Supported currencies list
/// YENİ CURRENCY EKLEMEK = 1 SATIR - Başka hiçbir yere dokunma!
const List<Currency> supportedCurrencies = [
  // Turkish Lira - symbol after, Turkish separators, gold in grams
  Currency(
    code: 'TRY',
    symbol: '₺',
    name: 'Türk Lirası',
    flag: '🇹🇷',
    symbolBefore: false,
    thousandSeparator: '.',
    decimalSeparator: ',',
    goldUnit: 'gr',
    defaultLocale: 'tr',
  ),
  // US Dollar - symbol before, standard separators, gold in ounces
  Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    flag: '🇺🇸',
    defaultLocale: 'en',
  ),
  // Euro - symbol before, standard separators
  Currency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    flag: '🇪🇺',
    defaultLocale: 'de',
  ),
  // British Pound
  Currency(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
  // Saudi Riyal - symbol after
  Currency(
    code: 'SAR',
    symbol: '﷼',
    name: 'Saudi Riyal',
    flag: '🇸🇦',
    symbolBefore: false,
    defaultLocale: 'ar',
  ),

  // ═══════════════════════════════════════════════════════════════════
  // İLERİDE EKLEMEK İÇİN - Sadece bu satırları uncomment et:
  // ═══════════════════════════════════════════════════════════════════
  // Currency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham', flag: '🇦🇪', symbolBefore: false),
  // Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
  // Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar', flag: '🇨🇦'),
  // Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', flag: '🇦🇺'),
  // Currency(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc', flag: '🇨🇭'),
  // Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
  // Currency(code: 'KRW', symbol: '₩', name: 'Korean Won', flag: '🇰🇷'),
  // Currency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', flag: '🇨🇳'),
  // Currency(code: 'RUB', symbol: '₽', name: 'Russian Ruble', flag: '🇷🇺'),
  // Currency(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real', flag: '🇧🇷'),
];

/// Get currency by code
Currency getCurrencyByCode(String code) {
  return supportedCurrencies.firstWhere(
    (c) => c.code == code,
    orElse: () => supportedCurrencies.first,
  );
}

/// Get default currency for locale - no switch case, data-driven!
Currency getDefaultCurrencyForLocale(String languageCode) {
  // Find currency that has this locale as default
  final match = supportedCurrencies
      .where((c) => c.defaultLocale == languageCode)
      .firstOrNull;
  if (match != null) return match;

  // European locales default to EUR
  if (['fr', 'es', 'it', 'nl', 'pt'].contains(languageCode)) {
    return getCurrencyByCode('EUR');
  }

  // Fallback to USD
  return getCurrencyByCode('USD');
}

/// Get all currency codes
List<String> get allCurrencyCodes =>
    supportedCurrencies.map((c) => c.code).toList();
