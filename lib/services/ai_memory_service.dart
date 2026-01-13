import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AIMemoryService {
  static final AIMemoryService _instance = AIMemoryService._internal();
  factory AIMemoryService() => _instance;
  AIMemoryService._internal();

  static const String _factsBoxName = 'user_facts';
  static const String _messagesBoxName = 'chat_messages';
  static const int _extractionInterval = 5; // Her 5 mesajda bir extraction

  late Box<String> _factsBox;
  late Box<Map> _messagesBox;
  late GenerativeModel _extractorModel;

  int _messagesSinceLastExtraction = 0;
  List<String> _userFacts = [];

  Future<void> initialize() async {
    await Hive.initFlutter();
    _factsBox = await Hive.openBox<String>(_factsBoxName);
    _messagesBox = await Hive.openBox<Map>(_messagesBoxName);

    // Fact extraction için Flash model (ucuz)
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _extractorModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );

    // Mevcut fact'leri yükle
    _userFacts = _factsBox.values.toList();
  }

  // Mesaj kaydet
  Future<void> saveMessage(String role, String content) async {
    await _messagesBox.add({
      'role': role,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _messagesSinceLastExtraction++;

    // Her 5 mesajda bir fact extraction
    if (_messagesSinceLastExtraction >= _extractionInterval) {
      await _extractFacts();
      _messagesSinceLastExtraction = 0;
    }
  }

  // AI ile akıllı fact extraction
  Future<void> _extractFacts() async {
    try {
      // Son 10 mesajı al
      final recentMessages = _messagesBox.values
          .toList()
          .reversed
          .take(10)
          .map((m) => '${m['role']}: ${m['content']}')
          .join('\n');

      if (recentMessages.isEmpty) return;

      final prompt = '''
Aşağıdaki konuşmadan kullanıcı hakkında önemli ve kalıcı bilgileri çıkar.

KURALLAR:
- Sadece uzun vadeli geçerli bilgiler (alışkanlıklar, tercihler, aile durumu, iş)
- Anlık durumları YAZMA ("bugün yorgun" gibi)
- Her bilgi tek satır, kısa ve öz
- Maksimum 5 bilgi
- Daha önce bilinen bilgileri tekrar yazma
- Yeni bir şey yoksa BOŞ döndür

MEVCUT BİLİNENLER:
${_userFacts.isEmpty ? 'Henüz bilgi yok' : _userFacts.join('\n')}

KONUŞMA:
$recentMessages

YENİ BİLGİLER (her satıra bir bilgi, yoksa BOŞ yaz):
''';

      final response = await _extractorModel.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';

      if (text.isNotEmpty && text.toUpperCase() != 'BOŞ') {
        final newFacts = text.split('\n')
            .map((f) => f.trim())
            .where((f) => f.isNotEmpty && !f.toUpperCase().contains('BOŞ'))
            .where((f) => !_userFacts.contains(f)) // Duplicate'leri atla
            .toList();

        for (final fact in newFacts) {
          if (_userFacts.length >= 30) {
            // En eski fact'i sil
            final oldest = _userFacts.removeAt(0);
            await _factsBox.delete(oldest);
          }
          _userFacts.add(fact);
          await _factsBox.add(fact);
        }
      }
    } catch (e) {
      // Extraction başarısız olursa sessizce devam et
    }
  }

  // Memory özeti (API'ye gönderilecek)
  String getMemorySummary() {
    if (_userFacts.isEmpty) return '';
    return '''
KULLANICI HAKKINDA BİLİNENLER:
${_userFacts.map((f) => '- $f').join('\n')}
''';
  }

  // Son N mesajı al (kronolojik sırada)
  List<Map<String, String>> getRecentMessages(int count) {
    try {
      final allMessages = _messagesBox.values.toList();
      if (allMessages.isEmpty) return [];

      return allMessages
          .reversed
          .take(count)
          .toList()
          .reversed // Kronolojik sıraya çevir
          .map((m) => {
            'role': (m['role'] as String?) ?? '',
            'content': (m['content'] as String?) ?? '',
          })
          .where((m) => m['content']!.isNotEmpty)
          .toList();
    } catch (e) {
      print('❌ [AIMemory] Error: $e');
      return [];
    }
  }

  // Tüm geçmişi sil
  Future<void> clearAll() async {
    await _factsBox.clear();
    await _messagesBox.clear();
    _userFacts.clear();
    _messagesSinceLastExtraction = 0;
  }

  // Fact'leri manuel düzenle
  List<String> get facts => List.unmodifiable(_userFacts);

  Future<void> removeFact(String fact) async {
    _userFacts.remove(fact);
    final key = _factsBox.keys.firstWhere(
      (k) => _factsBox.get(k) == fact,
      orElse: () => null,
    );
    if (key != null) await _factsBox.delete(key);
  }
}
