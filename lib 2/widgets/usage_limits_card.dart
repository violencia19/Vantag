import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../services/free_tier_service.dart';
import '../constants/app_limits.dart';

/// Card showing user's remaining daily usage limits
class UsageLimitsCard extends StatefulWidget {
  final bool isPremium;

  const UsageLimitsCard({super.key, this.isPremium = false});

  @override
  State<UsageLimitsCard> createState() => _UsageLimitsCardState();
}

class _UsageLimitsCardState extends State<UsageLimitsCard> {
  final _freeTierService = FreeTierService();

  int _aiChatsUsed = 0;
  int _aiChatsTotal = AppLimits.freeAiChatsPerDay;
  int _voiceUsed = 0;
  int _voiceTotal = AppLimits.freeVoiceInputPerDay;

  @override
  void initState() {
    super.initState();
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    final (aiUsed, aiTotal) = await _freeTierService.getAiChatUsage();
    final (voiceUsed, voiceTotal) = await _freeTierService.getVoiceInputUsage(widget.isPremium);

    if (mounted) {
      setState(() {
        _aiChatsUsed = aiUsed;
        _aiChatsTotal = aiTotal;
        _voiceUsed = voiceUsed;
        _voiceTotal = voiceTotal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.isPremium) {
      return _buildPremiumCard(context, l10n);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar_fill,
                size: 20,
                color: context.appColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.dailyLimits,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildLimitRow(
            context,
            icon: CupertinoIcons.chat_bubble_2_fill,
            label: l10n.aiChat,
            used: _aiChatsUsed,
            total: _aiChatsTotal,
            color: AppColors.categoryEntertainment,
          ),

          const SizedBox(height: 12),

          _buildLimitRow(
            context,
            icon: CupertinoIcons.mic_fill,
            label: l10n.voiceInput,
            used: _voiceUsed,
            total: _voiceTotal,
            color: AppColors.categoryTransport,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.appColors.primary.withValues(alpha: 0.2),
            context.appColors.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.infinite,
            size: 28,
            color: context.appColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.unlimitedWithPro,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
                Text(
                  l10n.proMember,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.star_fill,
            size: 24,
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildLimitRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int used,
    required int total,
    required Color color,
  }) {
    final remaining = total - used;
    final progress = total > 0 ? used / total : 0.0;
    final isExhausted = remaining <= 0;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$remaining / $total',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isExhausted
                          ? context.appColors.error
                          : context.appColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: context.appColors.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isExhausted ? context.appColors.error : color,
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
