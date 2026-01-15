import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../providers/finance_provider.dart';
import 'ai_tools.dart';
import 'ai_tool_handler.dart';
import 'ai_memory_service.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4.1';

  String? _apiKey;
  final AIMemoryService _memory = AIMemoryService();
  bool _isInitialized = false;

  PersonalityMode _personalityMode = PersonalityMode.friendly;

  Future<void> initialize() async {
    print('🤖 [AIService] Başlatılıyor...');

    try {
      _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

      if (_apiKey == null || _apiKey!.isEmpty) {
        print('❌ [AIService] OPENAI_API_KEY boş!');
        return;
      }

      await _memory.initialize();
      _isInitialized = true;
      print('✅ [AIService] OpenAI GPT-4.1 başarıyla başlatıldı!');

    } catch (e, stack) {
      print('❌ [AIService] Hata: $e');
      print('Stack: $stack');
    }
  }

  bool get isInitialized => _isInitialized;
  void setPersonalityMode(PersonalityMode mode) => _personalityMode = mode;
  PersonalityMode get personalityMode => _personalityMode;
  List<String> get userFacts => _memory.facts;

  String _buildSystemPrompt() {
    final isFriendly = _personalityMode == PersonalityMode.friendly;

    return '''
SEN BİR FİNANSAL ASİSTANSIN - VANTAG.

⚠️ ZORUNLU TOOL KULLANIMI (EN ÖNEMLİ KURAL):
Her soruda ÖNCE ilgili tool'u çağır, SONRA cevap ver:
- Harcama/bütçe/tasarruf soruları → get_expenses_summary VEYA get_recent_expenses
- Kullanıcı harcama söylüyorsa → add_expense
- ASLA "seni tanımıyorum", "verin yok" DEME → tool çağır, veri al, sonra konuş!
- Tool çağırmadan ASLA finansal tavsiye verme!

KİMLİK:
${isFriendly
  ? '- Samimi, "sen/kanka" de. Dürüst ve sert ol ama yapıcı.'
  : '- Profesyonel, "siz" de. Ciddi ve analitik.'}
- Kullanıcı hangi dilde yazarsa O DİLDE cevap ver.

HARCAMA EKLEME (add_expense):
- Kullanıcı "X TL harcadım", "Y aldım", "Z yedim" gibi şeyler söylerse add_expense tool'unu kullan.
- Kategori: Yiyecek, Ulaşım, Eğlence, Alışveriş, Fatura, Sağlık, Eğitim, Diğer
- PARA BİRİMİ ALGILAMA: Kullanıcı farklı para birimi belirtirse (örn: "50 dolar", "€30", "20 euro", "£15", "\$100") currency parametresini doldur:
  * "dolar", "\$", "USD" → currency: "USD"
  * "euro", "€", "EUR" → currency: "EUR"
  * "sterlin", "pound", "£", "GBP" → currency: "GBP"
  * Para birimi belirtilmezse currency parametresini gönderme (varsayılan kullanılır)
- Aynı gün içinde aynı kategori ve tutarda harcama varsa UYAR: "Bu harcamayı zaten girmiş olabilirsin. Yine de ekleyeyim mi?"

KİŞİSELLEŞTİRME:
- Kullanıcının en çok harcadığı kategorilere odaklan.
- "Genel olarak şöyle yapabilirsin" YASAK → "Senin Eğlence kategorin X TL, burada şunu yapabilirsin" şeklinde konuş.
- Rakamları kullanıcının kendi verileriyle destekle.

CEVAP KURALLARI:
1. Rakamları HAYAT MALİYETİNE çevir: "X TL = Y saat çalışman"
2. Bilmediğin şey hakkında YORUM YAPMA (market içeriği, abonelik kullanımı vs.)
3. İrade zaferlerini ÖV, motive et.
4. Somut aksiyon ver: "Şunu kes", "Bunu ertele"
5. Temel ihtiyaçlara (market, fatura, ulaşım) "çöp/israf" DEME.
6. Max 3-4 cümle, boş laf yapma.
7. Düşünüyorum listesindeki itemleri birbirleriyle karşılaştır.

YASAKLAR:
- Tool çağırmadan finansal tavsiye vermek
- "Belki", "düşünebilirsin", "değerlendirebilirsin" - belirsiz laflar
- "Çöp", "israf" - temel ihtiyaçlar için
- İçeriğini bilmediğin harcamaya yargı
- Emoji spam (max 1)
- "Seni tanımıyorum", "verin yok" gibi kaçamak cevaplar
''';
  }

  Future<String> getResponse({
    required String message,
    required FinanceProvider financeProvider,
  }) async {
    print('🚀 [AIService] getResponse çağrıldı');
    print('📱 [AIService] Initialized: $_isInitialized');
    print('💬 [AIService] Mesaj: "$message"');

    if (!_isInitialized || _apiKey == null) {
      print('⚠️ [AIService] Servis hazır değil!');
      return 'Servis hazırlanıyor, bir saniye...';
    }

    try {
      final handler = AIToolHandler(financeProvider);
      final systemPrompt = _buildSystemPrompt();

      // Conversation messages
      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': message},
      ];

      // İlk istek
      var response = await _sendRequest(messages);
      print('📥 [AIService] İlk response alındı');

      // Tool call loop
      int maxIterations = 5;
      int iteration = 0;

      while (response['tool_calls'] != null && iteration < maxIterations) {
        iteration++;
        final toolCalls = response['tool_calls'] as List<dynamic>;
        print('🔧 [AIService] Tool çağrısı algılandı (iteration $iteration): ${toolCalls.length} adet');

        // Assistant message with tool calls
        messages.add({
          'role': 'assistant',
          'content': response['content'],
          'tool_calls': toolCalls,
        });

        // Her tool call için sonuç al
        for (final toolCall in toolCalls) {
          final functionName = toolCall['function']['name'] as String;
          final arguments = jsonDecode(toolCall['function']['arguments'] as String) as Map<String, dynamic>;

          print('📞 [AIService] Tool: $functionName');
          print('📋 [AIService] Args: $arguments');

          // Tool'u çalıştır
          final result = await handler.handleToolCall(functionName, arguments);
          print('✅ [AIService] Result: $result');

          // Tool response ekle
          messages.add({
            'role': 'tool',
            'tool_call_id': toolCall['id'],
            'content': jsonEncode(result),
          });
        }

        // Yeni istek gönder
        response = await _sendRequest(messages);
        print('📥 [AIService] Tool sonrası response alındı');
      }

      // Final cevabı al
      final responseText = (response['content'] as String?)?.trim();

      if (responseText == null || responseText.isEmpty) {
        return 'Analiz yapamadım, tekrar sorar mısın?';
      }

      // Mesajları kaydet
      await _memory.saveMessage('user', message);
      await _memory.saveMessage('assistant', responseText);

      print('✅ [AIService] Cevap: ${responseText.substring(0, responseText.length.clamp(0, 100))}...');
      return responseText;

    } catch (e, stack) {
      print('❌ [AIService] Hata: $e');
      print('❌ [AIService] Stack: $stack');

      if (e.toString().contains('429')) {
        return 'Rate limit aşıldı, biraz bekle.';
      }
      if (e.toString().contains('401')) {
        return 'API key geçersiz.';
      }
      return 'Bir sorun oluştu, tekrar dene.';
    }
  }

  Future<Map<String, dynamic>> _sendRequest(List<Map<String, dynamic>> messages) async {
    final body = jsonEncode({
      'model': _model,
      'messages': messages,
      'tools': AITools.getAllTools(),
      'tool_choice': 'auto',
      'max_tokens': 500,
      'temperature': 0.7,
    });

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      print('❌ [AIService] HTTP Error: ${response.statusCode}');
      print('❌ [AIService] Body: ${response.body}');
      throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choice = (json['choices'] as List).first as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>;

    return {
      'content': message['content'],
      'tool_calls': message['tool_calls'],
    };
  }

  Future<String> getGreeting(String prompt) async {
    if (!_isInitialized || _apiKey == null) {
      return 'Merhaba! Nasıl yardımcı olabilirim?';
    }

    try {
      final messages = [
        {'role': 'user', 'content': prompt},
      ];

      final body = jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': 100,
        'temperature': 0.7,
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final choice = (json['choices'] as List).first as Map<String, dynamic>;
        final message = choice['message'] as Map<String, dynamic>;
        return (message['content'] as String?)?.trim() ?? 'Merhaba!';
      }
      return 'Merhaba! Bugün nasıl yardımcı olabilirim?';
    } catch (e) {
      return 'Merhaba! Bugün nasıl yardımcı olabilirim?';
    }
  }

  Future<void> clearHistory() async {
    await _memory.clearAll();
    print('🗑️ [AIService] Geçmiş temizlendi');
  }

  Future<void> removeFact(String fact) async {
    await _memory.removeFact(fact);
  }
}
