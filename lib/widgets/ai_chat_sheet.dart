import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../providers/finance_provider.dart';
import '../providers/currency_provider.dart';
import '../services/ai_service.dart';
import '../theme/theme.dart';

class AIChatSheet extends StatefulWidget {
  const AIChatSheet({super.key});

  @override
  State<AIChatSheet> createState() => _AIChatSheetState();
}

class _AIChatSheetState extends State<AIChatSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Dynamic AI greeting
  String _greeting = '';
  bool _greetingLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAIGreeting();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // reverse: true olduğu için 0 en alt
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadAIGreeting() async {
    try {
      final financeProvider = context.read<FinanceProvider>();
      final currencyProvider = context.read<CurrencyProvider>();
      final userProfile = financeProvider.userProfile;
      final expenses = financeProvider.expenses;

      if (userProfile == null) {
        setState(() {
          _greeting = 'Merhaba! Ben Vantag.\nFinansal sorularını yanıtlamaya hazırım.';
          _greetingLoading = false;
        });
        return;
      }

      // Bütçe hesapla
      final now = DateTime.now();
      final monthlySpent = expenses
          .where((e) =>
              e.date.month == now.month &&
              e.date.year == now.year &&
              e.decision == ExpenseDecision.yes)
          .fold(0.0, (sum, e) => sum + e.amount);
      final remaining = userProfile.monthlyIncome - monthlySpent;
      final usagePercent = userProfile.monthlyIncome > 0
          ? (monthlySpent / userProfile.monthlyIncome * 100)
          : 0;

      // Son 3 harcama
      final recentExpenses = expenses
          .where((e) => e.decision == ExpenseDecision.yes)
          .take(3)
          .map((e) => '${e.category}: ${e.amount.toStringAsFixed(0)}')
          .join(', ');

      // Cache key oluştur
      final cacheKey =
          '${monthlySpent.toStringAsFixed(0)}_${remaining.toStringAsFixed(0)}_${usagePercent.toStringAsFixed(0)}';

      // Cache kontrol
      final cachedGreeting = await _getCachedGreeting(cacheKey);
      if (cachedGreeting != null) {
        if (mounted) {
          setState(() {
            _greeting = cachedGreeting;
            _greetingLoading = false;
          });
        }
        return;
      }

      // AI'dan karşılama iste
      final personality = AIService().personalityMode;
      final currency = currencyProvider.code;
      final prompt = '''
Kullanıcıyı karşıla. Sen Vantag, finans asistanısın.

BÜTÇE:
- Gelir: ${userProfile.monthlyIncome.toStringAsFixed(0)} $currency
- Harcanan: ${monthlySpent.toStringAsFixed(0)} $currency
- Kalan: ${remaining.toStringAsFixed(0)} $currency
- Kullanım: %${usagePercent.toStringAsFixed(0)}
${recentExpenses.isNotEmpty ? '- Son: $recentExpenses' : ''}

KURAL:
- ${personality == PersonalityMode.friendly ? 'Samimi, "sen" de' : 'Profesyonel, "siz" de'}
- MAX 1 cümle + 1 soru
- 1 emoji max
- Son harcamaya atıf yapabilirsin

ÖRNEK:
- "Kahveye yine mi daldın? 😄 Gel konuşalım"
- "Bütçe %80'de, dikkat! Ne yapalım?"
- "Çiçek gibisin, %30 kullandın. Analiz mi?"

SADECE karşılama cümlesini yaz:
''';

      final response = await AIService().getGreeting(prompt);

      // Cache'e kaydet
      await _cacheGreeting(cacheKey, response);

      if (mounted) {
        setState(() {
          _greeting = response;
          _greetingLoading = false;
        });
      }
    } catch (e) {
      // Fallback
      if (mounted) {
        setState(() {
          _greeting = _getFallbackGreeting();
          _greetingLoading = false;
        });
      }
    }
  }

  // Fallback - Internet yoksa
  String _getFallbackGreeting() {
    final financeProvider = context.read<FinanceProvider>();
    final userProfile = financeProvider.userProfile;
    final expenses = financeProvider.expenses;

    if (userProfile == null) {
      return 'Merhaba! Ben Vantag.\nFinansal sorularını yanıtlamaya hazırım.';
    }

    final now = DateTime.now();
    final monthlySpent = expenses
        .where((e) =>
            e.date.month == now.month &&
            e.date.year == now.year &&
            e.decision == ExpenseDecision.yes)
        .fold(0.0, (sum, e) => sum + e.amount);
    final remaining = userProfile.monthlyIncome - monthlySpent;
    final usagePercent = userProfile.monthlyIncome > 0
        ? (monthlySpent / userProfile.monthlyIncome * 100)
        : 0;

    if (remaining < 0) {
      return 'Bütçe biraz zorlanıyor gibi.\nGel birlikte bakalım ne yapabiliriz?';
    } else if (usagePercent > 80) {
      return 'Ayın sonuna az kaldı, dikkatli olalım.\nNasıl yardımcı olabilirim?';
    } else if (usagePercent > 50) {
      return 'Bütçe idare ediyor.\nBir şey sormak ister misin?';
    } else {
      return 'Bütçen gayet iyi durumda!\nNeyi analiz edelim?';
    }
  }

  // Cache metodları (SharedPreferences ile)
  Future<String?> _getCachedGreeting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('ai_greeting_$key');
    final timestamp = prefs.getInt('ai_greeting_timestamp_$key') ?? 0;

    // 1 saat geçtiyse cache geçersiz
    if (DateTime.now().millisecondsSinceEpoch - timestamp > 3600000) {
      return null;
    }
    return cached;
  }

  Future<void> _cacheGreeting(String key, String greeting) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_greeting_$key', greeting);
    await prefs.setInt(
        'ai_greeting_timestamp_$key', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(child: _buildMessageList()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    final facts = AIService().userFacts.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primaryDark.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(PhosphorIconsDuotone.sparkle,
                    size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vantag AI',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  Text(
                    AIService().personalityMode == PersonalityMode.friendly
                        ? 'Samimi mod'
                        : 'Profesyonel mod',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              // Clear history button
              GestureDetector(
                onTap: () async {
                  await AIService().clearHistory();
                  setState(() => _messages.clear());
                  HapticFeedback.mediumImpact();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(PhosphorIcons.trash(),
                      size: 16, color: AppColors.textTertiary),
                ),
              ),
              GestureDetector(
                onTap: _togglePersonality,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AIService().personalityMode == PersonalityMode.friendly
                            ? PhosphorIconsDuotone.smiley
                            : PhosphorIconsDuotone.briefcase,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Icon(PhosphorIcons.caretDown(),
                          size: 12, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: facts
                  .map((fact) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(PhosphorIconsDuotone.lightbulb,
                                size: 12, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                fact,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(PhosphorIconsDuotone.chatsCircle,
                    size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 20),

              // Dinamik greeting
              if (_greetingLoading)
                SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Düşünüyor...',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  _greeting,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5),
                ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildSuggestionChip('Bu ay ne kadar harcadım?'),
                  _buildSuggestionChip('Tasarruf önerisi ver'),
                  _buildSuggestionChip('Bütçemi analiz et'),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == 0) {
          return _buildLoadingBubble();
        }

        final msgIndex = _isLoading ? index - 1 : index;
        final message = _messages.reversed.toList()[msgIndex];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
          border: isUser
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            color: isUser ? Colors.white : AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16)
              .copyWith(bottomLeft: const Radius.circular(4)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Düşünüyor...',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1500.ms, color: AppColors.primary.withValues(alpha: 0.1));
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Bir şey sor...',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(PhosphorIconsBold.paperPlaneTilt,
                  size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    HapticFeedback.lightImpact();
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _isLoading = true;
    });

    _scrollToBottom();

    final financeProvider = context.read<FinanceProvider>();

    try {
      final response = await AIService().getResponse(
        message: text,
        financeProvider: financeProvider,
      );

      if (mounted) {
        HapticFeedback.lightImpact();
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: response));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
              role: 'assistant', content: 'Bir hata oluştu, tekrar dener misin?'));
          _isLoading = false;
        });
      }
    }
  }

  void _togglePersonality() {
    HapticFeedback.selectionClick();
    final current = AIService().personalityMode;
    AIService().setPersonalityMode(
      current == PersonalityMode.friendly
          ? PersonalityMode.professional
          : PersonalityMode.friendly,
    );
    setState(() {});
  }
}

class ChatMessage {
  final String role;
  final String content;
  ChatMessage({required this.role, required this.content});
}
