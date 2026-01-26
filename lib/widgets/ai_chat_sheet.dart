import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/finance_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/pro_provider.dart';
import '../services/ai_service.dart';
import '../services/free_tier_service.dart';
import '../theme/theme.dart';
import '../constants/app_limits.dart';
import '../core/theme/premium_effects.dart';
import 'upgrade_dialog.dart';

class AIChatSheet extends StatefulWidget {
  const AIChatSheet({super.key});

  @override
  State<AIChatSheet> createState() => _AIChatSheetState();
}

class _AIChatSheetState extends State<AIChatSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final FreeTierService _freeTierService = FreeTierService();
  bool _isLoading = false;
  bool _showUpsell = false;

  // Dynamic AI greeting
  String _greeting = '';
  bool _greetingLoading = true;

  // Free tier chat limit (used, total)
  int _usedChats = 0;
  int _totalChats = AppLimits.freeAiChatsPerDay;

  @override
  void initState() {
    super.initState();
    _loadAIGreeting();
    _loadChatUsage();
  }

  Future<void> _loadChatUsage() async {
    final (used, total) = await _freeTierService.getAiChatUsage();
    if (mounted) {
      setState(() {
        _usedChats = used;
        _totalChats = total;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // reverse: true olduğu için 0 en alt
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadAIGreeting() async {
    try {
      final financeProvider = context.read<FinanceProvider>();
      final currencyProvider = context.read<CurrencyProvider>();
      final userProfile = financeProvider.userProfile;
      final expenses = financeProvider.realExpenses;

      if (userProfile == null) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _greeting = l10n.aiGreeting;
          _greetingLoading = false;
        });
        return;
      }

      // Bütçe hesapla
      final now = DateTime.now();
      final monthlySpent = expenses
          .where(
            (e) =>
                e.date.month == now.month &&
                e.date.year == now.year &&
                e.decision == ExpenseDecision.yes,
          )
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

      // Get locale early for cache key
      final locale = Localizations.localeOf(context).languageCode;
      final isEnglish = locale == 'en';

      // Cache key oluştur (include language to avoid wrong language from cache)
      final cacheKey =
          '${locale}_${monthlySpent.toStringAsFixed(0)}_${remaining.toStringAsFixed(0)}_${usagePercent.toStringAsFixed(0)}';

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

      final prompt = isEnglish
          ? '''
Greet the user. You are Vantag, a finance assistant.

BUDGET:
- Income: ${userProfile.monthlyIncome.toStringAsFixed(0)} $currency
- Spent: ${monthlySpent.toStringAsFixed(0)} $currency
- Remaining: ${remaining.toStringAsFixed(0)} $currency
- Usage: ${usagePercent.toStringAsFixed(0)}%
${recentExpenses.isNotEmpty ? '- Recent: $recentExpenses' : ''}

RULES:
- ${personality == PersonalityMode.friendly ? 'Casual, use "you"' : 'Professional, formal'}
- MAX 1 sentence + 1 question
- 1 emoji max
- Can reference recent spending

EXAMPLES:
- "Coffee again? 😄 Let's chat"
- "Budget at 80%, careful! What should we do?"
- "Looking good, only 30% used. Analysis?"

ONLY write the greeting:
'''
          : '''
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

      final response = await AIService().getGreeting(
        prompt,
        languageCode: locale,
      );

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
    final l10n = AppLocalizations.of(context);
    final financeProvider = context.read<FinanceProvider>();
    final userProfile = financeProvider.userProfile;
    final expenses = financeProvider.realExpenses;

    if (userProfile == null) {
      return l10n.aiGreeting;
    }

    final now = DateTime.now();
    final monthlySpent = expenses
        .where(
          (e) =>
              e.date.month == now.month &&
              e.date.year == now.year &&
              e.decision == ExpenseDecision.yes,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
    final remaining = userProfile.monthlyIncome - monthlySpent;
    final usagePercent = userProfile.monthlyIncome > 0
        ? (monthlySpent / userProfile.monthlyIncome * 100)
        : 0;

    if (remaining < 0) {
      return l10n.aiFallbackOverBudget;
    } else if (usagePercent > 80) {
      return l10n.aiFallbackHighUsage;
    } else if (usagePercent > 50) {
      return l10n.aiFallbackMediumUsage;
    } else {
      return l10n.aiFallbackLowUsage;
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
      'ai_greeting_timestamp_$key',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  void _showPaywall(BuildContext context) {
    HapticFeedback.mediumImpact();
    // Navigate to paywall
    Navigator.of(context).pushNamed('/paywall');
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<ProProvider>().isPro;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.appColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          // Free tier remaining chats indicator
          if (!isPremium) _buildRemainingChatsIndicator(l10n),
          Expanded(child: _buildMessageList(isPremium)),
          _buildInput(isPremium),
        ],
      ),
    );
  }

  Widget _buildRemainingChatsIndicator(AppLocalizations l10n) {
    final remaining = _totalChats - _usedChats;
    final isLimitReached = remaining <= 0;
    final isLow = remaining <= 1 && !isLimitReached;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLimitReached
            ? context.appColors.error.withValues(alpha: 0.15)
            : isLow
            ? context.appColors.warning.withValues(alpha: 0.15)
            : context.appColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLimitReached
              ? context.appColors.error.withValues(alpha: 0.3)
              : isLow
              ? context.appColors.warning.withValues(alpha: 0.3)
              : context.appColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLimitReached
                ? PhosphorIconsFill.warning
                : isLow
                ? PhosphorIconsDuotone.warning
                : PhosphorIconsDuotone.chatCircle,
            size: 16,
            color: isLimitReached
                ? context.appColors.error
                : isLow
                ? context.appColors.warning
                : context.appColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            isLimitReached
                ? l10n.dailyLimitReached
                : l10n.aiChatUsageIndicator(_usedChats, _totalChats),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isLimitReached
                  ? context.appColors.error
                  : isLow
                  ? context.appColors.warning
                  : context.appColors.textSecondary,
            ),
          ),
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
        color: context.appColors.textTertiary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    final facts = AIService().userFacts.take(3).toList();
    final l10n = AppLocalizations.of(context);

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
                      context.appColors.primary.withValues(alpha: 0.2),
                      context.appColors.primaryDark.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  PhosphorIconsDuotone.sparkle,
                  size: 22,
                  color: context.appColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vantag AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  Text(
                    AIService().personalityMode == PersonalityMode.friendly
                        ? l10n.friendlyMode
                        : l10n.professionalMode,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Clear history button
              Semantics(
                label: l10n.delete,
                button: true,
                child: GestureDetector(
                  onTap: () async {
                    await AIService().clearHistory();
                    setState(() {
                      _messages.clear();
                      _showUpsell = false;
                    });
                    HapticFeedback.mediumImpact();
                  },
                  child: Tooltip(
                    message: l10n.delete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        PhosphorIcons.trash(),
                        size: 16,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
              Semantics(
                label: AIService().personalityMode == PersonalityMode.friendly
                    ? l10n.professionalMode
                    : l10n.friendlyMode,
                hint: l10n.accessibilityToggleOn,
                button: true,
                child: GestureDetector(
                  onTap: _togglePersonality,
                  child: Tooltip(
                    message:
                        AIService().personalityMode == PersonalityMode.friendly
                        ? l10n.professionalMode
                        : l10n.friendlyMode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.appColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AIService().personalityMode ==
                                    PersonalityMode.friendly
                                ? PhosphorIconsDuotone.smiley
                                : PhosphorIconsDuotone.briefcase,
                            size: 16,
                            color: context.appColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            PhosphorIcons.caretDown(),
                            size: 12,
                            color: context.appColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
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
                  .map(
                    (fact) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.appColors.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsDuotone.lightbulb,
                            size: 12,
                            color: context.appColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              fact,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageList(bool isPremium) {
    final l10n = AppLocalizations.of(context);

    if (_messages.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // AI Avatar with rotating glow ring
            RotatingGradientBorder(
              size: 80,
              borderWidth: 3,
              duration: const Duration(seconds: 4),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PremiumColors.cardBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsDuotone.sparkle,
                  size: 32,
                  color: PremiumColors.purple,
                  shadows: PremiumShadows.iconHalo(PremiumColors.purple),
                ),
              ),
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
                        strokeWidth: 2,
                        color: PremiumColors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.aiThinking,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.appColors.textTertiary,
                      ),
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
                  color: context.appColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 32),

            // 4 Suggestion Buttons (for both free and premium users)
            _buildSuggestionButtons(l10n),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount:
          _messages.length +
          (_isLoading ? 1 : 0) +
          (_showUpsell && !isPremium ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the bottom (which is top in reverse)
        if (_isLoading && index == 0) {
          return _buildLoadingBubble();
        }

        // Upsell widget after AI response
        if (_showUpsell && !isPremium && index == (_isLoading ? 1 : 0)) {
          return _buildPremiumUpsell(context);
        }

        final adjustedIndex =
            index - (_isLoading ? 1 : 0) - (_showUpsell && !isPremium ? 1 : 0);
        if (adjustedIndex < 0 || adjustedIndex >= _messages.length) {
          return const SizedBox.shrink();
        }

        final message = _messages.reversed.toList()[adjustedIndex];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildSuggestionButtons(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildSuggestionChip('📊', l10n.aiSuggestion1, 0),
        _buildSuggestionChip('💡', l10n.aiSuggestion2, 1),
        _buildSuggestionChip('🔥', l10n.aiSuggestion3, 2),
        _buildSuggestionChip('🎯', l10n.aiSuggestion4, 3),
      ],
    );
  }

  Widget _buildSuggestionChip(String emoji, String text, int index) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.accessibilitySuggestionButton(text),
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          // Analytics logging
          _logAnalytics('ai_suggestion_tapped', {'suggestion': index});
          _controller.text = text;
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.appColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.appColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logAnalytics(String event, Map<String, dynamic> params) {
    // Placeholder for analytics logging
    // Analytics.log(event, params);
  }

  Widget _buildPremiumUpsell(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedOpacity(
      opacity: _showUpsell ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.appColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsDuotone.lock,
                  size: 18,
                  color: context.appColors.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.aiPremiumUpsell,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              label: l10n.aiPremiumButton,
              button: true,
              child: GestureDetector(
                onTap: () => _showPaywall(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.appColors.primary,
                        context.appColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.aiPremiumButton,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? context.appColors.primary
              : context.appColors.surfaceLight,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
          border: isUser
              ? null
              : Border.all(color: context.appColors.cardBorder),
        ),
        child: message.isTyping
            ? _buildTypingText(message.content)
            : Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : context.appColors.textPrimary,
                  height: 1.4,
                ),
              ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTypingText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: context.appColors.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildLoadingBubble() {
    final l10n = AppLocalizations.of(context);
    return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.appColors.surfaceLight,
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(bottomLeft: const Radius.circular(4)),
              border: Border.all(color: context.appColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.appColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.aiThinking,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1500.ms,
          color: context.appColors.primary.withValues(alpha: 0.1),
        );
  }

  Widget _buildInput(bool isPremium) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(top: BorderSide(color: context.appColors.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggestion buttons when in conversation (for quick access)
          if (_messages.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMiniSuggestionChip('📊', l10n.aiSuggestion1, 0),
                  const SizedBox(width: 8),
                  _buildMiniSuggestionChip('💡', l10n.aiSuggestion2, 1),
                  const SizedBox(width: 8),
                  _buildMiniSuggestionChip('🔥', l10n.aiSuggestion3, 2),
                  const SizedBox(width: 8),
                  _buildMiniSuggestionChip('🎯', l10n.aiSuggestion4, 3),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Input row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.appColors.surfaceLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.appColors.cardBorder),
                  ),
                  child: Semantics(
                    label: l10n.accessibilityAiChatInput,
                    textField: true,
                    child: TextField(
                      controller: _controller,
                      readOnly: !isPremium,
                      onTap: () {
                        if (!isPremium) {
                          _showPaywall(context);
                        }
                      },
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: isPremium
                            ? l10n.aiInputPlaceholder
                            : l10n.aiInputPlaceholderFree,
                        hintStyle: TextStyle(
                          color: context.appColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        suffixIcon: !isPremium
                            ? Icon(
                                PhosphorIconsRegular.lock,
                                size: 18,
                                color: context.appColors.textTertiary,
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.send,
                      enableSuggestions: true,
                      autocorrect: false,
                      enableIMEPersonalizedLearning: true,
                      onSubmitted: isPremium ? (_) => _sendMessage() : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                label: l10n.accessibilityAiSendButton,
                button: true,
                child: Tooltip(
                  message: l10n.accessibilityAiSendButton,
                  child: GestureDetector(
                    onTap: isPremium
                        ? _sendMessage
                        : () => _showPaywall(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isPremium
                              ? [
                                  context.appColors.primary,
                                  context.appColors.primaryDark,
                                ]
                              : [
                                  context.appColors.textTertiary,
                                  context.appColors.textSecondary,
                                ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: isPremium
                            ? [
                                BoxShadow(
                                  color: context.appColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isPremium
                            ? PhosphorIconsBold.paperPlaneTilt
                            : PhosphorIconsBold.lock,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSuggestionChip(String emoji, String text, int index) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.accessibilitySuggestionButton(text),
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _logAnalytics('ai_suggestion_tapped', {'suggestion': index});
          _controller.text = text;
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: context.appColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                text.length > 20 ? '${text.substring(0, 20)}...' : text,
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    final proProvider = context.read<ProProvider>();
    final isPremium = proProvider.isPro;
    final l10n = AppLocalizations.of(context);

    // Check free tier limit before sending
    if (!isPremium) {
      final canUse = await _freeTierService.canUseAiChat(isPremium);
      if (!canUse) {
        HapticFeedback.heavyImpact();
        if (mounted) {
          UpgradeDialog.show(context, l10n.aiChatLimitReached);
        }
        return;
      }
    }

    HapticFeedback.lightImpact();
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _isLoading = true;
      _showUpsell = false;
    });

    _scrollToBottom();

    final financeProvider = context.read<FinanceProvider>();
    final locale = Localizations.localeOf(context);

    try {
      final response = await AIService().getResponse(
        message: text,
        financeProvider: financeProvider,
        isPremium: isPremium,
        proProvider: proProvider,
        languageCode: locale.languageCode,
      );

      if (mounted) {
        HapticFeedback.lightImpact();

        // Increment free tier counter after successful response
        if (!isPremium) {
          await _freeTierService.incrementAiChatCount();
          _loadChatUsage(); // Refresh the usage count
        }

        // Add message with typing effect for free users
        if (!isPremium) {
          await _typeMessage(response);
        } else {
          setState(() {
            _messages.add(ChatMessage(role: 'assistant', content: response));
            _isLoading = false;
          });
        }

        // Show upsell for free users
        if (!isPremium) {
          setState(() {
            _showUpsell = true;
          });
        }

        _scrollToBottom();
      }
    } on AILimitExceededException catch (e) {
      if (mounted) {
        final resetTime = e.resetDate;
        final locale = Localizations.localeOf(context).languageCode;
        final isEnglish = locale == 'en';
        final limitTypeText = isEnglish
            ? (e.limitType == 'daily' ? 'daily' : 'monthly')
            : (e.limitType == 'daily' ? 'günlük' : 'aylık');
        final limitMessage = isEnglish
            ? 'You\'ve reached your $limitTypeText AI limit. Try again in ${_formatResetTime(resetTime, isEnglish)}.'
            : '$limitTypeText AI limitine ulaştın. ${_formatResetTime(resetTime, isEnglish)} sonra tekrar deneyebilirsin.';
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: limitMessage));
          _isLoading = false;
          _showUpsell = true;
        });
      }
    } catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        final isEnglish = locale == 'en';
        setState(() {
          _messages.add(
            ChatMessage(
              role: 'assistant',
              content: isEnglish
                  ? 'Something went wrong, please try again.'
                  : 'Bir hata oluştu, tekrar dener misin?',
            ),
          );
          _isLoading = false;
        });
      }
    }
  }

  String _formatResetTime(DateTime resetDate, [bool isEnglish = false]) {
    final now = DateTime.now();
    final diff = resetDate.difference(now);
    if (diff.inHours < 1) {
      return isEnglish
          ? '${diff.inMinutes} minutes'
          : '${diff.inMinutes} dakika';
    } else if (diff.inHours < 24) {
      return isEnglish ? '${diff.inHours} hours' : '${diff.inHours} saat';
    } else {
      return isEnglish ? '${diff.inDays} days' : '${diff.inDays} gün';
    }
  }

  Future<void> _typeMessage(String fullText) async {
    setState(() {
      _isLoading = false;
      _messages.add(
        ChatMessage(role: 'assistant', content: '', isTyping: true),
      );
    });

    final messageIndex = _messages.length - 1;
    String currentText = '';

    // Type word by word
    final words = fullText.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (!mounted) break;

      currentText += (i > 0 ? ' ' : '') + words[i];

      setState(() {
        _messages[messageIndex] = ChatMessage(
          role: 'assistant',
          content: currentText,
          isTyping: i < words.length - 1,
        );
      });

      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (mounted) {
      setState(() {
        _messages[messageIndex] = ChatMessage(
          role: 'assistant',
          content: fullText,
          isTyping: false,
        );
      });
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
  final bool isTyping;

  ChatMessage({
    required this.role,
    required this.content,
    this.isTyping = false,
  });
}
