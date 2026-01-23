import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

class ResultCard extends StatelessWidget {
  final ExpenseResult result;
  final String? categoryInsight;
  final String? emotionalMessage;
  final double? amount;
  final ExchangeRates? exchangeRates;

  const ResultCard({
    super.key,
    required this.result,
    this.categoryInsight,
    this.emotionalMessage,
    this.amount,
    this.exchangeRates,
  });

  String _formatCurrency(double value, {int decimals = 2}) {
    return formatTurkishCurrency(value, decimalDigits: decimals);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insightService = InsightService();
    final insight = insightService.getExpenseInsight(context, result);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Column(
        children: [
          // Time display - Two blocks side by side
          Builder(
            builder: (context) {
              final timeDisplay = getSimulationTimeDisplay(
                result.hoursRequired,
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left block: Hours or Years
                  _buildTimeBlock(
                    context: context,
                    value: timeDisplay.value1,
                    unit: timeDisplay.unit1,
                    icon: timeDisplay.isYearMode
                        ? PhosphorIconsDuotone.calendar
                        : PhosphorIconsDuotone.clock,
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    color: context.appColors.cardBorder,
                  ),
                  // Right block: Days
                  _buildTimeBlock(
                    context: context,
                    value: timeDisplay.value2,
                    unit: timeDisplay.unit2,
                    icon: PhosphorIconsDuotone.sun,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Emotional message (if exists)
          if (emotionalMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.appColors.primary.withValues(alpha: 0.08),
                    context.appColors.primary.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.appColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                emotionalMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: context.appColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Insight message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.appColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.appColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.lightbulb,
                    size: 18,
                    color: context.appColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category insight
          if (categoryInsight != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.appColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsDuotone.chartBar,
                    size: 16,
                    color: context.appColors.info,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      categoryInsight!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: context.appColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Alternative currency display
          if (amount != null && exchangeRates != null) ...[
            const SizedBox(height: 16),
            _buildCurrencyAlternatives(context, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrencyAlternatives(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (amount == null || exchangeRates == null) return const SizedBox.shrink();

    final usdAmount = amount! / exchangeRates!.usdRate;
    final eurAmount = amount! / exchangeRates!.eurRate;
    final goldGrams = amount! / exchangeRates!.goldRate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surfaceLighter,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.appColors.cardBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsDuotone.arrowsLeftRight,
                size: 14,
                color: context.appColors.textTertiary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.withThisAmountYouCouldBuy(
                    _formatCurrency(amount!, decimals: 2),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.appColors.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildCurrencyItem(
                context,
                '💵',
                '${_formatCurrency(usdAmount)} USD',
              ),
              _buildCurrencyItem(
                context,
                '💶',
                '${_formatCurrency(eurAmount)} EUR',
              ),
              _buildCurrencyItem(
                context,
                '🥇',
                l10n.goldGrams(_formatCurrency(goldGrams, decimals: 1)),
              ),
            ],
          ),
        ],
      ),
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBlock({
    required BuildContext context,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: context.appColors.textTertiary),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
            letterSpacing: -1,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
