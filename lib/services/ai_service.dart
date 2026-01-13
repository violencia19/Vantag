import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';
import '../providers/finance_provider.dart';
import 'ai_memory_service.dart';
import 'streak_service.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  GenerativeModel? _proModel;
  final AIMemoryService _memory = AIMemoryService();
  bool _isInitialized = false;

  PersonalityMode _personalityMode = PersonalityMode.friendly;

  static final _safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
  ];

  Future<void> initialize() async {
    print('🤖 [AIService] Başlatılıyor...');

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        print('❌ [AIService] API Key boş!');
        return;
      }

      _proModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        safetySettings: _safetySettings,
        generationConfig: GenerationConfig(
          maxOutputTokens: 200,
          temperature: 0.7,
        ),
      );
      print('✅ [AIService] Flash model oluşturuldu');

      await _memory.initialize();
      _isInitialized = true;
      print('✅ [AIService] Başarıyla başlatıldı!');

    } catch (e, stack) {
      print('❌ [AIService] Hata: $e');
      print('Stack: $stack');
    }
  }

  bool get isInitialized => _isInitialized;
  void setPersonalityMode(PersonalityMode mode) => _personalityMode = mode;
  PersonalityMode get personalityMode => _personalityMode;
  List<String> get userFacts => _memory.facts;

  double _calculateHourlyRate(UserProfile user) {
    final monthlyWorkHours = user.dailyHours * user.workDaysPerWeek * 4.33;
    if (monthlyWorkHours <= 0) return 0;
    return user.monthlyIncome / monthlyWorkHours;
  }

  Future<String> getResponse({
    required String message,
    required FinanceProvider financeProvider,
  }) async {
    print('💬 [AIService] Mesaj: "$message"');

    if (!_isInitialized || _proModel == null) {
      return 'Servis hazırlanıyor, bir saniye...';
    }

    try {
      print('🧠 [AIService] Pro model kullanılıyor');

      final fullContext = await _buildFullContext(financeProvider);
      final systemPrompt = _buildSystemPrompt(fullContext);

      final previousMessages = _memory.getRecentMessages(6);
      final history = <Content>[Content.text(systemPrompt)];

      for (final m in previousMessages) {
        final role = m['role'] ?? '';
        final content = m['content'] ?? '';
        if (content.isEmpty) continue;

        if (role == 'user') {
          history.add(Content.text(content));
        } else if (role == 'assistant') {
          history.add(Content.model([TextPart(content)]));
        }
      }

      await _memory.saveMessage('user', message);

      final chat = _proModel!.startChat(history: history);
      final response = await chat.sendMessage(Content.text(message));

      final responseText = response.text?.trim();

      if (responseText == null || responseText.isEmpty) {
        return 'Analiz yapamadım, tekrar sorar mısın?';
      }

      await _memory.saveMessage('assistant', responseText);
      print('✅ [AIService] Cevap: ${responseText.substring(0, responseText.length.clamp(0, 50))}...');
      return responseText;

    } on GenerativeAIException catch (e) {
      print('❌ [AIService] API Hatası: ${e.message}');
      if (e.message.contains('quota') || e.message.contains('429')) {
        return 'Günlük limit doldu, yarın devam ederiz.';
      }
      if (e.message.contains('safety')) {
        return 'Bu konuda analiz yapamıyorum.';
      }
      return 'Bağlantı hatası, tekrar dene.';
    } catch (e, stack) {
      print('❌ [AIService] Hata: $e');
      print('Stack: $stack');
      return 'Bir sorun oluştu, tekrar dene.';
    }
  }

  Future<Map<String, dynamic>> _buildFullContext(FinanceProvider fp) async {
    final now = DateTime.now();
    final user = fp.userProfile;
    final allExpenses = fp.expenses;
    final subscriptions = await fp.getActiveSubscriptions();

    // BU AY - ALDIKLARIM
    final thisMonthYes = allExpenses.where((e) =>
      e.date.month == now.month &&
      e.date.year == now.year &&
      e.decision == ExpenseDecision.yes
    ).toList();

    // BU AY - DÜŞÜNÜYORUM
    final thisMonthThinking = allExpenses.where((e) =>
      e.date.month == now.month &&
      e.date.year == now.year &&
      e.decision == ExpenseDecision.thinking
    ).toList();

    // BU AY - VAZGEÇTİM
    final thisMonthNo = allExpenses.where((e) =>
      e.date.month == now.month &&
      e.date.year == now.year &&
      e.decision == ExpenseDecision.no
    ).toList();

    // GEÇEN AY
    final lastMonth = allExpenses.where((e) =>
      e.date.month == (now.month == 1 ? 12 : now.month - 1) &&
      e.date.year == (now.month == 1 ? now.year - 1 : now.year) &&
      e.decision == ExpenseDecision.yes
    ).toList();

    // TOPLAMLAR
    final thisMonthTotal = thisMonthYes.fold(0.0, (sum, e) => sum + e.amount);
    final lastMonthTotal = lastMonth.fold(0.0, (sum, e) => sum + e.amount);
    final thinkingTotal = thisMonthThinking.fold(0.0, (sum, e) => sum + e.amount);
    final savedTotal = thisMonthNo.fold(0.0, (sum, e) => sum + e.amount);

    // SMART CHOICE
    final smartChoiceSaved = thisMonthYes
      .where((e) => e.isSmartChoice && e.savedAmount > 0)
      .fold(0.0, (sum, e) => sum + e.savedAmount);
    final smartChoiceCount = thisMonthYes.where((e) => e.isSmartChoice).length;

    // KATEGORİ ANALİZİ
    final categoryTotals = <String, double>{};
    for (final e in thisMonthYes) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // GELİR
    final incomeSources = user?.incomeSources ?? [];
    final totalIncome = user?.monthlyIncome ?? 0;
    final hourlyRate = user != null ? _calculateHourlyRate(user) : 0.0;

    // ABONELİK
    final subscriptionTotal = subscriptions.fold(0.0, (sum, s) => sum + s.amount);

    // STREAK
    final streak = fp.streakData;

    // DEĞİŞİM
    final changePercent = lastMonthTotal > 0
      ? ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100)
      : 0.0;

    return {
      'user': user,
      'hourlyRate': hourlyRate,
      'totalIncome': totalIncome,
      'incomeSources': incomeSources,
      'thisMonthTotal': thisMonthTotal,
      'lastMonthTotal': lastMonthTotal,
      'changePercent': changePercent,
      'thinkingTotal': thinkingTotal,
      'thinkingCount': thisMonthThinking.length,
      'thinkingItems': thisMonthThinking,
      'savedTotal': savedTotal,
      'savedCount': thisMonthNo.length,
      'smartChoiceSaved': smartChoiceSaved,
      'smartChoiceCount': smartChoiceCount,
      'categoryTotals': sortedCategories,
      'recentExpenses': thisMonthYes.take(15).toList(),
      'subscriptions': subscriptions,
      'subscriptionTotal': subscriptionTotal,
      'streak': streak,
      'remaining': totalIncome - thisMonthTotal,
    };
  }

  String _buildSystemPrompt(Map<String, dynamic> ctx) {
    final isFriendly = _personalityMode == PersonalityMode.friendly;

    final user = ctx['user'] as UserProfile?;
    final hourlyRate = ctx['hourlyRate'] as double;
    final totalIncome = ctx['totalIncome'] as double;
    final incomeSources = ctx['incomeSources'] as List<IncomeSource>;
    final thisMonthTotal = ctx['thisMonthTotal'] as double;
    final lastMonthTotal = ctx['lastMonthTotal'] as double;
    final changePercent = ctx['changePercent'] as double;
    final thinkingTotal = ctx['thinkingTotal'] as double;
    final thinkingCount = ctx['thinkingCount'] as int;
    final thinkingItems = ctx['thinkingItems'] as List<Expense>;
    final savedTotal = ctx['savedTotal'] as double;
    final savedCount = ctx['savedCount'] as int;
    final smartChoiceSaved = ctx['smartChoiceSaved'] as double;
    final smartChoiceCount = ctx['smartChoiceCount'] as int;
    final categoryTotals = ctx['categoryTotals'] as List<MapEntry<String, double>>;
    final recentExpenses = ctx['recentExpenses'] as List<Expense>;
    final subscriptions = ctx['subscriptions'] as List<Subscription>;
    final subscriptionTotal = ctx['subscriptionTotal'] as double;
    final streak = ctx['streak'] as StreakData;
    final remaining = ctx['remaining'] as double;

    final incomeStr = incomeSources.map((s) =>
      '- ${s.title}: ${s.amount.toStringAsFixed(0)} TL'
    ).join('\n');

    final categoryStr = categoryTotals.take(5).map((e) =>
      '- ${e.key}: ${e.value.toStringAsFixed(0)} TL'
    ).join('\n');

    final expenseStr = recentExpenses.map((e) {
      final name = e.subCategory?.isNotEmpty == true ? e.subCategory : e.category;
      final smartTag = e.isSmartChoice ? ' [Akıllı Tercih]' : '';
      return '- $name: ${e.amount.toStringAsFixed(0)} TL$smartTag';
    }).join('\n');

    final thinkingStr = thinkingItems.take(5).map((e) {
      final name = e.subCategory?.isNotEmpty == true ? e.subCategory : e.category;
      return '- $name: ${e.amount.toStringAsFixed(0)} TL';
    }).join('\n');

    final subStr = subscriptions.map((s) =>
      '- ${s.name}: ${s.amount.toStringAsFixed(0)} TL/ay (${s.renewalDay}. gün)'
    ).join('\n');

    return '''
Sen Vantag, premium finans asistanısın.

DİL KURALI:
- Kullanıcı hangi dilde yazarsa O DİLDE cevap ver
- Türkçe = Türkçe, English = English, العربية = العربية

KİMLİK:
${isFriendly
  ? '- Samimi, "sen" de, arkadaş gibi ama zeki'
  : '- Profesyonel, "siz" de, resmi'}
- Tüm verilere erişimin var, başka uygulamaya yönlendirme YASAK

═══════════════════════════════════════
📊 GERÇEK VERİLER
═══════════════════════════════════════

💰 GELİR:
- Toplam: ${totalIncome.toStringAsFixed(0)} TL/ay
- Saatlik: ${hourlyRate.toStringAsFixed(0)} TL
$incomeStr

📉 BU AY:
- Harcanan: ${thisMonthTotal.toStringAsFixed(0)} TL
- Geçen ay: ${lastMonthTotal.toStringAsFixed(0)} TL
- Değişim: %${changePercent.toStringAsFixed(0)}
- Kalan: ${remaining.toStringAsFixed(0)} TL

📂 KATEGORİLER:
$categoryStr

🛒 SON HARCAMALAR:
$expenseStr

🔄 ABONELİKLER (${subscriptionTotal.toStringAsFixed(0)} TL/ay):
$subStr

⏳ DÜŞÜNÜYORUM (${thinkingCount} adet - ${thinkingTotal.toStringAsFixed(0)} TL):
$thinkingStr

✅ TASARRUF:
- Vazgeçilen: ${savedTotal.toStringAsFixed(0)} TL (${savedCount} adet)
- Akıllı Tercih: ${smartChoiceSaved.toStringAsFixed(0)} TL (${smartChoiceCount} adet)

🔥 STREAK: ${streak.currentStreak} gün

═══════════════════════════════════════

FORMAT:
- Max 2-3 cümle, kısa ve net
- Somut rakam ve isim ver
- Harcamayı saate çevir (X saat çalışman)
- Soru sorarak devam et

YASAK:
- "düşünebilirsin", "değerlendirebilirsin", "bakabilirsin"
- "Öncelikle", "Ayrıca"
- Emoji spam (max 1)

TAVSİYE:
- Direkt: "Kes", "İptal et", "Alma"
- Somut: "ChatGPT iptal et = 650 TL/ay = 10 saat"
''';
  }

  Future<String> getGreeting(String prompt) async {
    if (!_isInitialized || _proModel == null) {
      return 'Merhaba! Nasıl yardımcı olabilirim?';
    }

    try {
      final response = await _proModel!.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'Merhaba!';
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
