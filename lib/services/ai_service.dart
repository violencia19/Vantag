import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../providers/finance_provider.dart';
import '../providers/pro_provider.dart';
import 'ai_tool_handler.dart';
import 'ai_memory_service.dart';

/// AI Chat limit aşıldığında dönen hata
class AILimitExceededException implements Exception {
  final DateTime resetDate;
  final int remainingQuota;
  final String limitType; // "daily" or "monthly"

  AILimitExceededException({
    required this.resetDate,
    required this.remainingQuota,
    required this.limitType,
  });

  @override
  String toString() => 'AI limit exceeded. Resets at: $resetDate';
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Cloud Function URL - europe-west1 region
  static const String _baseUrl =
      'https://europe-west1-flutter-ai-playground-b188b.cloudfunctions.net/aiChat';

  final AIMemoryService _memory = AIMemoryService();
  bool _isInitialized = false;

  PersonalityMode _personalityMode = PersonalityMode.friendly;

  // Last known remaining quota (updated after each request)
  int _remainingQuota = -1;
  int get remainingQuota => _remainingQuota;

  Future<void> initialize() async {
    debugPrint('🤖 [AIService] Başlatılıyor...');

    try {
      await _memory.initialize();
      _isInitialized = true;
      debugPrint(
        '✅ [AIService] Cloud Function tabanlı AI başarıyla başlatıldı!',
      );
    } catch (e, stack) {
      debugPrint('❌ [AIService] Hata: $e');
      debugPrint('Stack: $stack');
    }
  }

  bool get isInitialized => _isInitialized;
  void setPersonalityMode(PersonalityMode mode) => _personalityMode = mode;
  PersonalityMode get personalityMode => _personalityMode;
  List<String> get userFacts => _memory.facts;

  /// Get current user ID from Firebase Auth
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Get subscription type from ProProvider
  /// Note: Currently ProProvider only tracks isPro (pro subscription)
  /// Lifetime detection would need RevenueCat entitlement check
  String _getSubscriptionType(ProProvider? proProvider) {
    if (proProvider == null) return 'free';
    if (proProvider.isPro) return 'pro';
    return 'free';
  }

  Future<String> getResponse({
    required String message,
    required FinanceProvider financeProvider,
    bool isPremium = true,
    ProProvider? proProvider,
    String languageCode = 'tr',
  }) async {
    debugPrint('🚀 [AIService] getResponse çağrıldı');
    debugPrint('📱 [AIService] Initialized: $_isInitialized');
    debugPrint('💬 [AIService] Mesaj: "$message"');
    debugPrint('👑 [AIService] Premium: $isPremium');
    debugPrint('🌍 [AIService] Language: $languageCode');

    if (!_isInitialized) {
      debugPrint('⚠️ [AIService] Servis hazır değil!');
      return languageCode == 'en'
          ? 'Service is loading, one moment...'
          : 'Servis hazırlanıyor, bir saniye...';
    }

    final userId = _currentUserId;
    if (userId == null) {
      debugPrint('⚠️ [AIService] Kullanıcı girişi yok!');
      return languageCode == 'en'
          ? 'Please sign in first.'
          : 'Lütfen önce giriş yapın.';
    }

    try {
      final handler = AIToolHandler(financeProvider);
      final subscriptionType = _getSubscriptionType(proProvider);

      // İlk istek - Cloud Function'a gönder
      var response = await _sendCloudRequest(
        message: message,
        userId: userId,
        isPremium: isPremium,
        subscriptionType: subscriptionType,
        languageCode: languageCode,
      );

      debugPrint('📥 [AIService] İlk response alındı');

      // Tool call loop
      int maxIterations = 5;
      int iteration = 0;
      List<Map<String, dynamic>> toolResults = [];

      while (response['requiresToolExecution'] == true &&
          response['toolCalls'] != null &&
          iteration < maxIterations) {
        iteration++;
        final toolCalls = response['toolCalls'] as List<dynamic>;
        debugPrint(
          '🔧 [AIService] Tool çağrısı algılandı (iteration $iteration): ${toolCalls.length} adet',
        );

        // Assistant message with tool calls
        toolResults.add({
          'role': 'assistant',
          'content': response['response'],
          'tool_calls': toolCalls,
        });

        // Her tool call için sonuç al
        for (final toolCall in toolCalls) {
          final functionName = toolCall['function']['name'] as String;
          final arguments =
              jsonDecode(toolCall['function']['arguments'] as String)
                  as Map<String, dynamic>;

          debugPrint('📞 [AIService] Tool: $functionName');
          debugPrint('📋 [AIService] Args: $arguments');

          // Tool'u local olarak çalıştır
          final result = await handler.handleToolCall(functionName, arguments);
          debugPrint('✅ [AIService] Result: $result');

          // Tool response ekle
          toolResults.add({
            'role': 'tool',
            'tool_call_id': toolCall['id'],
            'content': jsonEncode(result),
          });
        }

        // Tool sonuçlarıyla tekrar Cloud Function'a gönder
        response = await _sendCloudRequest(
          message: message,
          userId: userId,
          isPremium: isPremium,
          subscriptionType: subscriptionType,
          languageCode: languageCode,
          toolResults: toolResults,
        );
        debugPrint('📥 [AIService] Tool sonrası response alındı');
      }

      // Update remaining quota
      if (response['remainingQuota'] != null) {
        _remainingQuota = response['remainingQuota'] as int;
        debugPrint('📊 [AIService] Kalan kota: $_remainingQuota');
      }

      // Final cevabı al
      final responseText = (response['response'] as String?)?.trim();

      if (responseText == null || responseText.isEmpty) {
        return languageCode == 'en'
            ? 'I couldn\'t analyze that, could you ask again?'
            : 'Analiz yapamadım, tekrar sorar mısın?';
      }

      // Mesajları kaydet
      await _memory.saveMessage('user', message);
      await _memory.saveMessage('assistant', responseText);

      debugPrint(
        '✅ [AIService] Cevap: ${responseText.substring(0, responseText.length.clamp(0, 100))}...',
      );
      return responseText;
    } on AILimitExceededException {
      rethrow; // UI'da handle edilecek
    } catch (e, stack) {
      debugPrint('❌ [AIService] Hata: $e');
      debugPrint('❌ [AIService] Stack: $stack');

      if (e.toString().contains('LIMIT_EXCEEDED')) {
        return languageCode == 'en'
            ? 'You\'ve reached your daily AI limit. Try again tomorrow or upgrade to Premium!'
            : 'Günlük AI limitine ulaştın. Yarın tekrar dene veya Premium\'a geç!';
      }
      if (e.toString().contains('429')) {
        return languageCode == 'en'
            ? 'Rate limit exceeded, please wait a moment.'
            : 'Rate limit aşıldı, biraz bekle.';
      }
      return languageCode == 'en'
          ? 'Something went wrong, please try again.'
          : 'Bir sorun oluştu, tekrar dene.';
    }
  }

  Future<Map<String, dynamic>> _sendCloudRequest({
    required String message,
    required String userId,
    required bool isPremium,
    required String subscriptionType,
    String languageCode = 'tr',
    List<Map<String, dynamic>>? toolResults,
  }) async {
    final body = jsonEncode({
      'message': message,
      'userId': userId,
      'isPremium': isPremium,
      'subscriptionType': subscriptionType,
      'language': languageCode,
      if (toolResults != null) 'toolResults': toolResults,
    });

    debugPrint('📤 [AIService] Cloud Function\'a istek gönderiliyor...');

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 60));

    debugPrint('📥 [AIService] HTTP Status: ${response.statusCode}');

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    // Handle errors
    if (response.statusCode == 429) {
      final error = json['error'] as String?;
      if (error == 'LIMIT_EXCEEDED') {
        final resetDateStr = json['resetDate'] as String?;
        final remainingQuota = json['remainingQuota'] as int? ?? 0;
        final limitType = json['limitType'] as String? ?? 'daily';

        throw AILimitExceededException(
          resetDate: resetDateStr != null
              ? DateTime.parse(resetDateStr)
              : DateTime.now().add(const Duration(days: 1)),
          remainingQuota: remainingQuota,
          limitType: limitType,
        );
      }
      throw Exception('Rate limited');
    }

    if (response.statusCode != 200) {
      debugPrint('❌ [AIService] HTTP Error: ${response.statusCode}');
      debugPrint('❌ [AIService] Body: ${response.body}');
      final errorMsg = json['message'] ?? json['error'] ?? 'Unknown error';
      throw Exception(
        'Cloud Function error: ${response.statusCode} - $errorMsg',
      );
    }

    return json;
  }

  Future<String> getGreeting(
    String prompt, {
    String languageCode = 'tr',
  }) async {
    final isEnglish = languageCode == 'en';
    final defaultGreeting = isEnglish
        ? 'Hello! How can I help you today?'
        : 'Merhaba! Nasıl yardımcı olabilirim?';

    if (!_isInitialized) {
      return defaultGreeting;
    }

    final userId = _currentUserId;
    if (userId == null) {
      return defaultGreeting;
    }

    try {
      // Simple greeting - use Cloud Function
      final response = await _sendCloudRequest(
        message: prompt,
        userId: userId,
        isPremium: true, // Greeting doesn't count against quota
        subscriptionType: 'pro',
        languageCode: languageCode,
      );

      return (response['response'] as String?)?.trim() ??
          (isEnglish ? 'Hello!' : 'Merhaba!');
    } catch (e) {
      debugPrint('⚠️ [AIService] Greeting error: $e');
      return isEnglish
          ? 'Hello! How can I help you today?'
          : 'Merhaba! Bugün nasıl yardımcı olabilirim?';
    }
  }

  Future<void> clearHistory() async {
    await _memory.clearAll();
    debugPrint('🗑️ [AIService] Geçmiş temizlendi');
  }

  Future<void> removeFact(String fact) async {
    await _memory.removeFact(fact);
  }
}
