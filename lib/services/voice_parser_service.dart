import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/voice_parse_result.dart';

/// Service for parsing voice input into expense data
/// Uses hybrid approach: fast regex first, GPT-4o fallback for complex cases
class VoiceParserService {
  static final VoiceParserService _instance = VoiceParserService._();
  factory VoiceParserService() => _instance;
  VoiceParserService._();

  /// Category keywords for regex matching
  static const Map<String, List<String>> _categoryKeywords = {
    'food': [
      'kahve',
      'coffee',
      'yemek',
      'food',
      'restoran',
      'restaurant',
      'market',
      'migros',
      'bim',
      'a101',
      'şok',
      'carrefour',
      'starbucks',
      'mcdonalds',
      'burger',
      'pizza',
      'döner',
      'kebap',
      'lokanta',
      'cafe',
      'kafe',
      'çay',
      'su',
      'içecek',
      'atıştırmalık',
      'kahvaltı',
      'öğle',
      'akşam',
      'yemeği',
      'getir',
      'yemeksepeti',
      'trendyol yemek',
      'glovo',
    ],
    'transport': [
      'uber',
      'taksi',
      'taxi',
      'benzin',
      'akaryakıt',
      'shell',
      'opet',
      'bp',
      'otobüs',
      'metro',
      'metrobüs',
      'tramvay',
      'vapur',
      'ferry',
      'uçak',
      'bilet',
      'thy',
      'pegasus',
      'ulaşım',
      'yol',
      'otopark',
      'parking',
      'bitaksi',
      'bolt',
      'grab',
    ],
    'entertainment': [
      'netflix',
      'spotify',
      'youtube',
      'prime',
      'disney',
      'eğlence',
      'sinema',
      'film',
      'konser',
      'tiyatro',
      'oyun',
      'game',
      'steam',
      'playstation',
      'xbox',
      'twitch',
      'müzik',
      'kitap',
      'dergi',
    ],
    'shopping': [
      'amazon',
      'trendyol',
      'hepsiburada',
      'n11',
      'alışveriş',
      'giyim',
      'ayakkabı',
      'çanta',
      'saat',
      'aksesuar',
      'elektronik',
      'telefon',
      'bilgisayar',
      'laptop',
      'tablet',
      'kulaklık',
      'zara',
      'h&m',
      'lcw',
      'defacto',
      'koton',
      'mavi',
    ],
    'health': [
      'eczane',
      'pharmacy',
      'ilaç',
      'medicine',
      'doktor',
      'doctor',
      'hastane',
      'hospital',
      'klinik',
      'clinic',
      'sağlık',
      'health',
      'diş',
      'göz',
      'check-up',
      'muayene',
      'tedavi',
      'sigorta',
    ],
    'bills': [
      'fatura',
      'bill',
      'elektrik',
      'su',
      'doğalgaz',
      'internet',
      'telefon',
      'cep',
      'turkcell',
      'vodafone',
      'türk telekom',
      'aidat',
      'kira',
      'rent',
      'abonelik',
      'subscription',
    ],
    'education': [
      'kurs',
      'course',
      'eğitim',
      'education',
      'okul',
      'school',
      'üniversite',
      'university',
      'kitap',
      'book',
      'udemy',
      'coursera',
      'özel ders',
      'dershane',
      'sınav',
      'exam',
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

    final prompt = '''Extract expense info from this sentence (any language):

"$text"

Return ONLY valid JSON:
{"amount": number or null, "description": "what was bought (short)", "category": "food|transport|entertainment|shopping|health|bills|education|other"}

Examples:
- "Kahvaltıya 50 lira verdim" → {"amount": 50, "description": "Kahvaltı", "category": "food"}
- "Spent 20 dollars on coffee" → {"amount": 20, "description": "Coffee", "category": "food"}
- "Taksi tuttu 150" → {"amount": 150, "description": "Taksi", "category": "transport"}
- "Netflix 80 TL" → {"amount": 80, "description": "Netflix", "category": "entertainment"}
- "Markete 200 verdim" → {"amount": 200, "description": "Market", "category": "shopping"}''';

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
      );

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

      // Build result with high confidence since AI understood it
      return VoiceParseResult(
        amount: parsed['amount'] != null
            ? (parsed['amount'] as num).toDouble()
            : null,
        category: parsed['category'] as String? ?? 'other',
        description: parsed['description'] as String? ?? text,
        originalText: text,
        confidence: parsed['amount'] != null
            ? VoiceConfidence.high
            : VoiceConfidence.low,
        source: VoiceParseSource.gpt,
        merchantName: null,
      );
    } catch (e) {
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
            'shopping': 'Alışveriş',
            'health': 'Sağlık',
            'bills': 'Faturalar',
            'education': 'Eğitim',
            'other': 'Diğer',
          }
        : {
            'food': 'Food',
            'transport': 'Transport',
            'entertainment': 'Entertainment',
            'shopping': 'Shopping',
            'health': 'Health',
            'bills': 'Bills',
            'education': 'Education',
            'other': 'Other',
          };

    return names[category.toLowerCase()] ?? (turkish ? 'Diğer' : 'Other');
  }

  /// Convert API category to app category
  static String mapToAppCategory(String? apiCategory) {
    const mapping = {
      'food': 'Yiyecek',
      'transport': 'Ulaşım',
      'entertainment': 'Eğlence',
      'shopping': 'Alışveriş',
      'health': 'Sağlık',
      'bills': 'Faturalar',
      'education': 'Eğitim',
      'other': 'Diğer',
    };
    return mapping[apiCategory?.toLowerCase()] ?? 'Diğer';
  }
}
