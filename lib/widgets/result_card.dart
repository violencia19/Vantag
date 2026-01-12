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
    final l10n = AppLocalizations.of(context)!;
    final insightService = InsightService();
    final insight = insightService.getExpenseInsight(result);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Time display - Two blocks side by side
          Builder(
            builder: (context) {
              final timeDisplay = getSimulationTimeDisplay(result.hoursRequired);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left block: Hours or Years
                  _buildTimeBlock(
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
                    color: AppColors.cardBorder,
                  ),
                  // Right block: Days
                  _buildTimeBlock(
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
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primary.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                emotionalMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textPrimary,
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
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    PhosphorIconsDuotone.lightbulb,
                    size: 18,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
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
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    PhosphorIconsDuotone.chartBar,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      categoryInsight!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.info,
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
            _buildCurrencyAlternatives(l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrencyAlternatives(AppLocalizations l10n) {
    if (amount == null || exchangeRates == null) return const SizedBox.shrink();

    final usdAmount = amount! / exchangeRates!.usdRate;
    final eurAmount = amount! / exchangeRates!.eurRate;
    final goldGrams = amount! / exchangeRates!.goldRate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLighter,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.5),
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
                color: AppColors.textTertiary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.withThisAmountYouCouldBuy(_formatCurrency(amount!, decimals: 2)),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
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
              _buildCurrencyItem('💵', '${_formatCurrency(usdAmount)} USD'),
              _buildCurrencyItem('💶', '${_formatCurrency(eurAmount)} EUR'),
              _buildCurrencyItem('🥇', l10n.goldGrams(_formatCurrency(goldGrams, decimals: 1))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(String emoji, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBlock({
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -1,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
