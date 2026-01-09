import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

/// Saved money counter widget showing savings statistics
class SavedMoneyCounter extends StatelessWidget {
  final DecisionStats stats;
  final ExchangeRates? exchangeRates;

  const SavedMoneyCounter({
    super.key,
    required this.stats,
    this.exchangeRates,
  });

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatCurrency(double amount, {int decimals = 2}) {
    return formatTurkishCurrency(amount, decimalDigits: decimals);
  }

  String _formatTime(AppLocalizations l10n) {
    final hours = stats.savedHours;
    final days = stats.savedDays;

    if (days >= 1) {
      return l10n.savedTimeHoursDays(hours.toStringAsFixed(0), days.toStringAsFixed(1));
    } else if (hours >= 1) {
      return l10n.savedTimeHours(hours.toStringAsFixed(1));
    } else {
      final minutes = (hours * 60).round();
      return l10n.savedTimeMinutes(minutes);
    }
  }

  String? _getEmotionalMessage(AppLocalizations l10n) {
    if (exchangeRates == null) return null;

    final savedTL = stats.savedAmount;
    final goldGrams = savedTL / exchangeRates!.goldRate;
    final days = stats.savedDays;

    final messages = <String>[];

    // Gold message
    if (goldGrams >= 0.1) {
      messages.add(l10n.couldBuyGoldGrams(goldGrams.toStringAsFixed(1)));
    }

    // Work days message
    if (days >= 0.5) {
      if (days >= 1) {
        messages.add(l10n.equivalentWorkDays(days.toStringAsFixed(1)));
      } else {
        final hours = stats.savedHours;
        messages.add(l10n.equivalentWorkHours(hours.toStringAsFixed(0)));
      }
    }

    // USD message
    final usdAmount = savedTL / exchangeRates!.usdRate;
    if (usdAmount >= 10) {
      messages.add(l10n.savedDollars(formatTurkishCurrency(usdAmount, decimalDigits: 2)));
    }

    if (messages.isEmpty) return null;

    // Select a random message
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  @override
  Widget build(BuildContext context) {
    if (stats.noCount == 0) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final emotionalMessage = _getEmotionalMessage(l10n);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatAmount(stats.savedAmount),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'TL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Label
          Text(
            l10n.youSaved,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          // Currency alternatives
          if (exchangeRates != null && stats.savedAmount > 0) ...[
            const SizedBox(height: 16),

            // OR text
            Text(
              l10n.or,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // Currency list
            _buildCurrencyAlternatives(l10n),
          ],

          const SizedBox(height: 16),

          // Time saved
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(l10n),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Emotional message
          if (emotionalMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '💡',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      emotionalMessage,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrencyAlternatives(AppLocalizations l10n) {
    if (exchangeRates == null) return const SizedBox.shrink();

    final savedTL = stats.savedAmount;
    final usdAmount = savedTL / exchangeRates!.usdRate;
    final eurAmount = savedTL / exchangeRates!.eurRate;
    final goldGrams = savedTL / exchangeRates!.goldRate;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildCurrencyItem('💵', '${_formatCurrency(usdAmount)} USD'),
        _buildCurrencyItem('💶', '${_formatCurrency(eurAmount)} EUR'),
        _buildCurrencyItem('🥇', l10n.goldGramsShort(_formatCurrency(goldGrams, decimals: 1))),
      ],
    );
  }

  Widget _buildCurrencyItem(String emoji, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
