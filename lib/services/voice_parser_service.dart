import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/voice_parse_result.dart';

/// Service for parsing voice input into expense data
/// Uses hybrid approach: fast regex first, GPT-4o fallback for complex cases
class VoiceParserService {
  static final VoiceParserService _instance = VoiceParserService._();
  factory VoiceParserService() => _instance;
  VoiceParserService._();

  /// Category keywords for regex matching - keys match ExpenseCategory.all
  static const Map<String, List<String>> _categoryKeywords = {
    'Yiyecek': [
      'kahve', 'coffee', 'yemek', 'food', 'restoran', 'restaurant',
      'market', 'migros', 'bim', 'a101', 'şok', 'carrefour',
      'starbucks', 'mcdonalds', 'burger', 'pizza', 'döner', 'kebap',
      'lokanta', 'cafe', 'kafe', 'çay', 'içecek', 'atıştırmalık',
      'kahvaltı', 'öğle yemeği', 'akşam yemeği', 'getir', 'yemeksepeti', 'glovo',
    ],
    'Ulaşım': [
      'uber', 'taksi', 'taxi', 'benzin', 'akaryakıt', 'shell', 'opet', 'bp',
      'otobüs', 'metro', 'metrobüs', 'tramvay', 'vapur', 'ferry',
      'uçak', 'bilet', 'thy', 'pegasus', 'ulaşım', 'yol', 'otopark',
      'parking', 'bitaksi', 'bolt', 'grab',
    ],
    'Giyim': [
      'giyim', 'ayakkabı', 'çanta', 'saat', 'aksesuar', 'kıyafet',
      'zara', 'h&m', 'lcw', 'defacto', 'koton', 'mavi', 'pantolon',
      'gömlek', 'elbise', 'ceket', 'mont', 'kazak',
    ],
    'Elektronik': [
      'telefon', 'bilgisayar', 'laptop', 'tablet', 'kulaklık', 'elektronik',
      'iphone', 'samsung', 'apple', 'macbook', 'airpods', 'şarj',
      'kablo', 'adaptör', 'monitor', 'klavye', 'mouse',
    ],
    'Eğlence': [
      'netflix', 'spotify', 'youtube', 'prime', 'disney', 'eğlence',
      'sinema', 'film', 'konser', 'tiyatro', 'oyun', 'game',
      'steam', 'playstation', 'xbox', 'twitch', 'müzik', 'kitap', 'dergi',
    ],
    'Sağlık': [
      'eczane', 'pharmacy', 'ilaç', 'medicine', 'doktor', 'doctor',
      'hastane', 'hospital', 'klinik', 'clinic', 'sağlık', 'health',
      'diş', 'göz', 'check-up', 'muayene', 'tedavi',
    ],
    'Eğitim': [
      'kurs', 'course', 'eğitim', 'education', 'okul', 'school',
      'üniversite', 'university', 'udemy', 'coursera', 'özel ders',
      'dershane', 'sınav', 'exam',
    ],
    'Faturalar': [
      'fatura', 'bill', 'elektrik', 'doğalgaz', 'aidat', 'kira', 'rent',
    ],
    'Abonelik': [
      'abonelik', 'subscription', 'turkcell', 'vodafone', 'türk telekom',
      'internet', 'telefon faturası', 'aylık',
    ],
  };

  /// Amount patterns in Turkish
  static final List<RegExp> _amountPatterns = [
    // "50 lira", "50 TL", "50₺"
    RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:lira|tl|₺)', caseSensitive: false),
    // "50 liralık"
    RegExp(r'(\d+(?:[.,]\d+)?)\s*liralık', caseSensitive: false),
    // Standalone numbers at start/end
    RegExp(r'^(\d+(?:[.,]\d+)?)\b'),
    RegExp(r'\b(\d+(?:[.,]\d+)?)$'),
    // Numbers with currency context
    RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:para|tutar|ücret|fiyat)',
      caseSensitive: false,
    ),
  ];

  /// Main parse function - always uses AI for best accuracy
  Future<VoiceParseResult> parse(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return VoiceParseResult.failed(text);
    }

    // Always use AI for parsing - handles any language and phrasing
    try {
      final aiResult = await parseWithAI(trimmed);
      if (aiResult.isValid) {
        return aiResult;
      }
    } catch (e) {
      debugPrint('[VoiceParser] AI error: $e');
      // AI failed, try basic regex fallback
    }

    // Fallback to basic regex only if AI fails
    return parseWithRegex(trimmed);
  }

  /// Parse using regex patterns (fast, no API cost)
  VoiceParseResult parseWithRegex(String text) {
    final normalized = _normalizeText(text);

    // Extract amount
    double? amount;
    for (final pattern in _amountPatterns) {
      final match = pattern.firstMatch(normalized);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(',', '.');
        amount = double.tryParse(amountStr);
        if (amount != null && amount > 0) break;
      }
    }

    // Detect category
    String? category;
    final lowerText = normalized.toLowerCase();
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          category = entry.key;
          break;
        }
      }
      if (category != null) break;
    }

    // Extract description (remove amount and currency markers)
    String description = text
        .replaceAll(
          RegExp(
            r'\d+(?:[.,]\d+)?\s*(?:lira|tl|₺|liralık)?',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (description.isEmpty) {
      description = text;
    }

    // Try to extract merchant name
    String? merchantName;
    final knownMerchants = [
      'starbucks',
      'mcdonalds',
      'burger king',
      'kfc',
      'dominos',
      'migros',
      'bim',
      'a101',
      'şok',
      'carrefour',
      'uber',
      'bolt',
      'bitaksi',
      'netflix',
      'spotify',
      'youtube',
      'amazon',
      'trendyol',
      'hepsiburada',
      'getir',
      'yemeksepeti',
    ];

    for (final merchant in knownMerchants) {
      if (lowerText.contains(merchant)) {
        merchantName =
            merchant.substring(0, 1).toUpperCase() + merchant.substring(1);
        break;
      }
    }

    return VoiceParseResult.fromRegex(
      amount: amount,
      category: category,
      description: description,
      originalText: text,
      merchantName: merchantName,
    );
  }

  /// Parse using AI - handles any language naturally
  Future<VoiceParseResult> parseWithAI(String text) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    // Use exact app category names from ExpenseCategory.all
    final prompt = '''Extract expense info from this sentence (any language):

"$text"

Return ONLY valid JSON:
{"amount": number or null, "description": "short description", "category": "CATEGORY", "store": "store name or null", "item": "item/product or null"}

IMPORTANT: category MUST be exactly one of these values:
Yiyecek, Ulaşım, Giyim, Elektronik, Eğlence, Sağlık, Eğitim, Faturalar, Abonelik, Diğer

Category guide:
- Yiyecek: food, groceries, restaurants, coffee, snacks
- Ulaşım: taxi, uber, gas, bus, metro, parking
- Giyim: clothes, shoes, accessories, shopping
- Elektronik: phone, laptop, electronics, gadgets
- Eğlence: netflix, spotify, games, cinema, entertainment
- Sağlık: medicine, doctor, pharmacy, health
- Eğitim: courses, books, school, education
- Faturalar: electricity, water, gas bills, rent
- Abonelik: subscriptions, monthly services
- Diğer: anything else

Field guide:
- store: The shop/brand name where purchase was made (HM, Starbucks, Migros, etc.)
- item: The specific product/item bought (Kazak, Kahve, Ekmek, etc.)
- description: Combine store + item if both exist, otherwise use what's available

Examples:
- "500 liraya HM'den kazak aldım" → {"amount": 500, "category": "Giyim", "store": "HM", "item": "Kazak", "description": "HM Kazak"}
- "Starbucks'ta kahve 80 lira" → {"amount": 80, "category": "Yiyecek", "store": "Starbucks", "item": "Kahve", "description": "Starbucks Kahve"}
- "Taksi tuttu 150" → {"amount": 150, "category": "Ulaşım", "store": null, "item": "Taksi", "description": "Taksi"}
- "Netflix 80 TL" → {"amount": 80, "category": "Eğlence", "store": "Netflix", "item": null, "description": "Netflix"}
- "Markete 200 verdim" → {"amount": 200, "category": "Yiyecek", "store": null, "item": null, "description": "Market alışverişi"}''';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0,
          'max_tokens': 100,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('AI API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;

      // Extract JSON from response (handle markdown code blocks)
      String jsonStr = content.trim();
      if (jsonStr.contains('```')) {
        final jsonMatch = RegExp(
          r'```(?:json)?\s*([\s\S]*?)```',
        ).firstMatch(jsonStr);
        if (jsonMatch != null) {
          jsonStr = jsonMatch.group(1)!.trim();
        }
      }

      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Validate category is in allowed list
      final rawCategory = parsed['category'] as String? ?? 'Diğer';
      final validCategories = [
        'Yiyecek', 'Ulaşım', 'Giyim', 'Elektronik', 'Eğlence',
        'Sağlık', 'Eğitim', 'Faturalar', 'Abonelik', 'Diğer',
      ];
      final category = validCategories.contains(rawCategory) ? rawCategory : 'Diğer';

      // Extract store and item
      final store = parsed['store'] as String?;
      final item = parsed['item'] as String?;

      // Build result with high confidence since AI understood it
      return VoiceParseResult(
        amount: parsed['amount'] != null
            ? (parsed['amount'] as num).toDouble()
            : null,
        category: category,
        description: parsed['description'] as String? ?? text,
        originalText: text,
        confidence: parsed['amount'] != null
            ? VoiceConfidence.high
            : VoiceConfidence.low,
        source: VoiceParseSource.gpt,
        merchantName: store, // Use store as merchant name
        store: store,
        item: item,
      );
    } catch (e) {
      debugPrint('[VoiceParser] AI parse error: $e');
      return VoiceParseResult.failed(text);
    }
  }

  /// Legacy GPT method - kept for compatibility
  Future<VoiceParseResult> parseWithGPT(String text) => parseWithAI(text);

  /// Normalize Turkish text for matching
  String _normalizeText(String text) {
    return text
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .replaceAll('Ş', 'ş')
        .replaceAll('Ğ', 'ğ')
        .replaceAll('Ü', 'ü')
        .replaceAll('Ö', 'ö')
        .replaceAll('Ç', 'ç')
        .toLowerCase()
        .trim();
  }

  /// Get category display name
  static String getCategoryDisplayName(
    String? category, {
    bool turkish = true,
  }) {
    if (category == null) return turkish ? 'Diğer' : 'Other';

    final names = turkish
        ? {
            'food': 'Yiyecek',
            'transport': 'Ulaşım',
            'entertainment': 'Eğlence',
            'shopping': 'Giyim',
            'health': 'Sağlık',
            'bills': 'Faturalar',
            'education': 'Eğitim',
            'other': 'Diğer',
          }
        : {
            'food': 'Food',
            'transport': 'Transport',
            'entertainment': 'Entertainment',
            'shopping': 'Clothing',
            'health': 'Health',
            'bills': 'Bills',
            'education': 'Education',
            'other': 'Other',
          };

    return names[category.toLowerCase()] ?? (turkish ? 'Diğer' : 'Other');
  }

  /// Convert API category to app category
  static String mapToAppCategory(String? apiCategory) {
    if (apiCategory == null) return 'Diğer';

    // Valid app categories (must match ExpenseCategory.all)
    const validCategories = [
      'Yiyecek', 'Ulaşım', 'Giyim', 'Elektronik', 'Eğlence',
      'Sağlık', 'Eğitim', 'Faturalar', 'Abonelik', 'Diğer',
    ];

    // If already a valid category, return as-is
    if (validCategories.contains(apiCategory)) {
      return apiCategory;
    }

    // Fallback mapping for English categories (backwards compatibility)
    const englishMapping = {
      'food': 'Yiyecek',
      'transport': 'Ulaşım',
      'entertainment': 'Eğlence',
      'shopping': 'Giyim',
      'health': 'Sağlık',
      'bills': 'Faturalar',
      'education': 'Eğitim',
      'other': 'Diğer',
    };

    return englishMapping[apiCategory.toLowerCase()] ?? 'Diğer';
  }
}
