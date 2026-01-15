/// Global merchant database for automatic category matching
/// Only contains WORLDWIDE known brands (50+ merchants)
class GlobalMerchants {
  GlobalMerchants._();

  /// Map of normalized merchant names to categories
  static const Map<String, String> merchants = {
    // Digital Services
    'NETFLIX': 'entertainment',
    'SPOTIFY': 'entertainment',
    'YOUTUBE': 'entertainment',
    'APPLE': 'digital',
    'GOOGLE': 'digital',
    'AMAZON': 'shopping',
    'STEAM': 'entertainment',
    'PLAYSTATION': 'entertainment',
    'XBOX': 'entertainment',
    'ADOBE': 'digital',
    'MICROSOFT': 'digital',
    'DISCORD': 'digital',
    'TWITCH': 'entertainment',
    'CHATGPT': 'digital',
    'OPENAI': 'digital',
    'NOTION': 'digital',
    'FIGMA': 'digital',
    'CANVA': 'digital',
    'DROPBOX': 'digital',
    'ICLOUD': 'digital',

    // Global Fast Food
    'MCDONALDS': 'food',
    'MCDONALD': 'food',
    'BURGER KING': 'food',
    'KFC': 'food',
    'STARBUCKS': 'food',
    'DOMINOS': 'food',
    'PIZZA HUT': 'food',
    'SUBWAY': 'food',
    'PAPA JOHNS': 'food',
    'POPEYES': 'food',
    'WENDYS': 'food',
    'TACO BELL': 'food',
    'DUNKIN': 'food',
    'COSTA COFFEE': 'food',
    'LITTLE CAESARS': 'food',

    // Global Clothing
    'ZARA': 'clothing',
    'H&M': 'clothing',
    'HM': 'clothing',
    'NIKE': 'clothing',
    'ADIDAS': 'clothing',
    'PUMA': 'clothing',
    'UNIQLO': 'clothing',
    'GAP': 'clothing',
    'LEVIS': 'clothing',
    'GUESS': 'clothing',
    'TOMMY HILFIGER': 'clothing',
    'CALVIN KLEIN': 'clothing',
    'UNDER ARMOUR': 'clothing',
    'NEW BALANCE': 'clothing',
    'FOREVER 21': 'clothing',
    'PULL BEAR': 'clothing',
    'BERSHKA': 'clothing',
    'MASSIMO DUTTI': 'clothing',
    'MANGO': 'clothing',
    'LACOSTE': 'clothing',

    // Global Gas Stations
    'SHELL': 'transport',
    'BP': 'transport',
    'TOTAL': 'transport',
    'ESSO': 'transport',
    'CHEVRON': 'transport',
    'EXXON': 'transport',
    'MOBIL': 'transport',
    'OPET': 'transport',
    'PETROL OFISI': 'transport',
    'TURKIYE PETROLLERI': 'transport',

    // Global Electronics / Tech
    'SAMSUNG': 'electronics',
    'SONY': 'electronics',
    'LG': 'electronics',
    'APPLE STORE': 'electronics',
    'MEDIAMARKT': 'electronics',
    'MEDIA MARKT': 'electronics',
    'BEST BUY': 'electronics',
    'TEKNOSA': 'electronics',
    'VATAN': 'electronics',

    // Global E-commerce
    'EBAY': 'shopping',
    'ALIEXPRESS': 'shopping',
    'ALIBABA': 'shopping',
    'WISH': 'shopping',
    'ETSY': 'shopping',
    'SHEIN': 'clothing',
    'TEMU': 'shopping',
    'TRENDYOL': 'shopping',
    'HEPSIBURADA': 'shopping',
    'N11': 'shopping',
    'GITTIGIDIYOR': 'shopping',

    // Transport / Ride-sharing
    'UBER': 'transport',
    'BOLT': 'transport',
    'LYFT': 'transport',
    'GRAB': 'transport',
    'BITAKSI': 'transport',

    // Global Furniture / Home
    'IKEA': 'shopping',
    'KOTON': 'clothing',

    // Airlines
    'TURKISH AIRLINES': 'transport',
    'THY': 'transport',
    'LUFTHANSA': 'transport',
    'EMIRATES': 'transport',
    'RYANAIR': 'transport',
    'EASYJET': 'transport',
    'PEGASUS': 'transport',
    'SUNCOUNTRY': 'transport',

    // Turkish Supermarkets
    'MIGROS': 'food',
    'CARREFOUR': 'food',
    'BIM': 'food',
    'A101': 'food',
    'SOK': 'food',
    'METRO': 'food',
    'MACRO': 'food',
    'GETIR': 'food',
    'YEMEKSEPETI': 'food',
  };

  /// Get category for a normalized description
  static String? getCategory(String normalized) {
    // First try exact key match
    if (merchants.containsKey(normalized)) {
      return merchants[normalized];
    }

    // Then try contains match (for descriptions like "NETFLIX SUBSCRIPTION")
    for (final entry in merchants.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Get merchant name from normalized description
  static String? getMerchantName(String normalized) {
    // First try exact key match
    if (merchants.containsKey(normalized)) {
      return normalized;
    }

    // Then try contains match
    for (final key in merchants.keys) {
      if (normalized.contains(key)) {
        return key;
      }
    }
    return null;
  }

  /// Get display-friendly merchant name (Title Case)
  static String getDisplayName(String merchantKey) {
    // Convert to title case
    return merchantKey
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}
