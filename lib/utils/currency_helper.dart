/// Currency helper for displaying currency info with flags
class CurrencyHelper {
  static const Map<String, Map<String, String>> currencies = {
    'TRY': {'flag': '🇹🇷', 'name': 'Türk Lirası'},
    'USD': {'flag': '🇺🇸', 'name': 'ABD Doları'},
    'EUR': {'flag': '🇪🇺', 'name': 'Euro'},
    'GBP': {'flag': '🇬🇧', 'name': 'İngiliz Sterlini'},
  };

  static String getFlag(String code) => currencies[code]?['flag'] ?? '🏳️';
  static String getName(String code) => currencies[code]?['name'] ?? code;
  static String getDisplay(String code) => '${getFlag(code)} $code';
  static List<String> get allCodes => currencies.keys.toList();
}
