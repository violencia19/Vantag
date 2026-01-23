import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/currency_provider.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';
import 'animated_counter.dart';

/// Saved money counter widget showing savings statistics
class SavedMoneyCounter extends StatelessWidget {
  final DecisionStats stats;
  final ExchangeRates? exchangeRates;

  const SavedMoneyCounter({super.key, required this.stats, this.exchangeRates});

  String _formatCurrency(double amount, {int decimals = 2}) {
    return formatTurkishCurrency(amount, decimalDigits: decimals);
  }

  String _formatTime(AppLocalizations l10n) {
    final hours = stats.savedHours;
    final days = stats.savedDays;

    if (days >= 1) {
      return l10n.savedTimeHoursDays(
        hours.toStringAsFixed(0),
        days.toStringAsFixed(1),
      );
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
      messages.add(
        l10n.savedDollars(formatTurkishCurrency(usdAmount, decimalDigits: 2)),
      );
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

    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();
    final emotionalMessage = _getEmotionalMessage(l10n);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.appColors.primary.withValues(alpha: 0.2),
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
              color: context.appColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              PhosphorIconsDuotone.shieldCheck,
              size: 22,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Amount with slot-machine style animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              NumberTicker(
                value: stats.savedAmount,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.primary,
                  letterSpacing: -2,
                  height: 1.2,
                ),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                useGrouping: true,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  currencyProvider.symbol,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Label
          Text(
            l10n.youSaved,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),

          // Currency alternatives
          if (exchangeRates != null && stats.savedAmount > 0) ...[
            const SizedBox(height: 16),

            // OR text
            Text(
              l10n.or,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: context.appColors.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // Currency list
            _buildCurrencyAlternatives(context, l10n),
          ],

          const SizedBox(height: 16),

          // Time saved
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: context.appColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIconsDuotone.clock,
                  size: 14,
                  color: context.appColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(l10n),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.appColors.textSecondary,
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
                color: context.appColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      emotionalMessage,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.primary,
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

  Widget _buildCurrencyAlternatives(
    BuildContext context,
    AppLocalizations l10n,
  ) {
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
        _buildCurrencyItem(context, '💵', '${_formatCurrency(usdAmount)} USD'),
        _buildCurrencyItem(context, '💶', '${_formatCurrency(eurAmount)} EUR'),
        _buildCurrencyItem(
          context,
          '🥇',
          l10n.goldGramsShort(_formatCurrency(goldGrams, decimals: 1)),
        ),
      ],
    );
  }

  Widget _buildCurrencyItem(BuildContext context, String emoji, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
