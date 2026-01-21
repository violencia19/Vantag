import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/savings_pool_provider.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

/// Tasarruf Havuzu kartı - Hayallerim ekranında gösterilir
class SavingsPoolCard extends StatelessWidget {
  final bool compact;

  const SavingsPoolCard({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pool = context.watch<SavingsPoolProvider>();
    final currency = context.watch<CurrencyProvider>();
    final symbol = currency.currency.symbol;

    if (pool.isLoading) {
      return _buildLoadingState();
    }

    if (compact) {
      return _buildCompactCard(context, l10n, pool, symbol);
    }

    return _buildFullCard(context, l10n, pool, symbol);
  }

  Widget _buildLoadingState() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildCompactCard(
    BuildContext context,
    AppLocalizations l10n,
    SavingsPoolProvider pool,
    String symbol,
  ) {
    final hasDebt = pool.hasDebt;
    final available = pool.available;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasDebt
              ? [
                  AppColors.error.withValues(alpha: 0.15),
                  AppColors.error.withValues(alpha: 0.05),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDebt
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: hasDebt
                  ? AppColors.error.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                hasDebt ? '🔴' : '💰',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.savingsPool,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      hasDebt
                          ? '-$symbol${formatTurkishCurrency(pool.shadowDebt.abs(), decimalDigits: 0, showDecimals: false)}'
                          : '$symbol${formatTurkishCurrency(available, decimalDigits: 0, showDecimals: false)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: hasDebt ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasDebt ? l10n.savingsPoolDebt : l10n.savingsPoolAvailable,
                      style: TextStyle(
                        fontSize: 13,
                        color: hasDebt ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Joker indicator
          if (pool.canUseJoker)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🃏', style: TextStyle(fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildFullCard(
    BuildContext context,
    AppLocalizations l10n,
    SavingsPoolProvider pool,
    String symbol,
  ) {
    final hasDebt = pool.hasDebt;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasDebt
              ? [
                  AppColors.error.withValues(alpha: 0.1),
                  AppColors.surface,
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.surface,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasDebt
              ? AppColors.error.withValues(alpha: 0.2)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                hasDebt ? '🔴' : '💰',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.savingsPool,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (pool.canUseJoker)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🃏', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '1',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Main amount
          if (hasDebt) ...[
            Text(
              '-$symbol${formatTurkishCurrency(pool.shadowDebt.abs(), decimalDigits: 0, showDecimals: false)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.shadowDebtMessage(
                '$symbol${formatTurkishCurrency(pool.shadowDebt.abs(), decimalDigits: 0, showDecimals: false)}',
              ),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.error.withValues(alpha: 0.8),
              ),
            ),
          ] else ...[
            Text(
              '$symbol${formatTurkishCurrency(pool.available, decimalDigits: 0, showDecimals: false)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.savingsPoolAvailable,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Breakdown
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildBreakdownRow(
                  l10n.poolSummaryTotal,
                  '$symbol${formatTurkishCurrency(pool.totalSaved, decimalDigits: 0, showDecimals: false)}',
                  AppColors.textPrimary,
                ),
                const SizedBox(height: 8),
                _buildBreakdownRow(
                  l10n.poolSummaryAllocated,
                  '-$symbol${formatTurkishCurrency(pool.allocatedToDreams, decimalDigits: 0, showDecimals: false)}',
                  AppColors.primary,
                ),
                if (hasDebt) ...[
                  const SizedBox(height: 8),
                  _buildBreakdownRow(
                    'Borç',
                    '-$symbol${formatTurkishCurrency(pool.shadowDebt, decimalDigits: 0, showDecimals: false)}',
                    AppColors.error,
                  ),
                ],
                const Divider(height: 16, color: AppColors.cardBorder),
                _buildBreakdownRow(
                  l10n.poolSummaryAvailable,
                  hasDebt
                      ? '-$symbol${formatTurkishCurrency(pool.shadowDebt, decimalDigits: 0, showDecimals: false)}'
                      : '$symbol${formatTurkishCurrency(pool.available, decimalDigits: 0, showDecimals: false)}',
                  hasDebt ? AppColors.error : AppColors.success,
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
