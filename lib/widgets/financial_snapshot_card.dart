import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

/// Premium Financial Snapshot Card
/// Revolut-style clean design, mirror layout for income/expense
class FinancialSnapshotCard extends StatefulWidget {
  final double totalIncome;
  final double totalSpent;
  final double savedAmount;
  final int savedCount;
  final int incomeSourceCount;
  final VoidCallback? onTap;

  const FinancialSnapshotCard({
    super.key,
    required this.totalIncome,
    required this.totalSpent,
    required this.savedAmount,
    this.savedCount = 0,
    this.incomeSourceCount = 1,
    this.onTap,
  });

  @override
  State<FinancialSnapshotCard> createState() => _FinancialSnapshotCardState();
}

class _FinancialSnapshotCardState extends State<FinancialSnapshotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<double> _countAnimation;

  double _previousNetBalance = 0;
  double _previousIncome = 0;
  double _previousSpent = 0;

  double get netBalance => widget.totalIncome - widget.totalSpent;
  double get remainingPercent =>
      widget.totalIncome > 0 ? ((widget.totalIncome - widget.totalSpent) / widget.totalIncome * 100).clamp(0, 100) : 100;
  double get spentPercent =>
      widget.totalIncome > 0 ? (widget.totalSpent / widget.totalIncome * 100).clamp(0, 100) : 0;
  bool get isHealthy => netBalance >= 0;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );
    _countController.forward();
  }

  @override
  void didUpdateWidget(FinancialSnapshotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalIncome != widget.totalIncome ||
        oldWidget.totalSpent != widget.totalSpent) {
      _previousNetBalance = oldWidget.totalIncome - oldWidget.totalSpent;
      _previousIncome = oldWidget.totalIncome;
      _previousSpent = oldWidget.totalSpent;
      _countController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  double _lerp(double begin, double end, double t) {
    return begin + (end - begin) * t;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyProvider = context.watch<CurrencyProvider>();

    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (context, child) {
        final animatedNetBalance = _lerp(_previousNetBalance, netBalance, _countAnimation.value);
        final animatedIncome = _lerp(_previousIncome, widget.totalIncome, _countAnimation.value);
        final animatedSpent = _lerp(_previousSpent, widget.totalSpent, _countAnimation.value);
        final animatedRemaining = widget.totalIncome > 0
            ? ((animatedIncome - animatedSpent) / animatedIncome * 100).clamp(0.0, 100.0)
            : 100.0;

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1428),
                  const Color(0xFF0D0A1A),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Label + Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isHealthy ? AppColors.success : AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.netBalance.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (widget.incomeSourceCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    PhosphorIconsDuotone.wallet,
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.sources(widget.incomeSourceCount),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Big Balance Number
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatTurkishCurrency(
                                currencyProvider.convertFromTRY(animatedNetBalance.abs()),
                                decimalDigits: 0, showDecimals: false),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -2,
                              color: isHealthy ? Colors.white : AppColors.error,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              currencyProvider.symbol,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Percentage badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isHealthy ? AppColors.success : AppColors.error).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isHealthy ? PhosphorIconsBold.trendUp : PhosphorIconsBold.trendDown,
                                  size: 14,
                                  color: isHealthy ? AppColors.success : AppColors.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${animatedRemaining.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isHealthy ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Progress Bar
                      _buildProgressBar(l10n, currencyProvider),

                      const SizedBox(height: 24),

                      // Income / Expense - Mirror Layout
                      _buildIncomeExpenseRow(l10n, animatedIncome, animatedSpent, currencyProvider),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(AppLocalizations l10n, CurrencyProvider currencyProvider) {
    final spentConverted = currencyProvider.convertFromTRY(widget.totalSpent);
    final incomeConverted = currencyProvider.convertFromTRY(widget.totalIncome);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.budgetUsage.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '${formatTurkishCurrency(spentConverted, decimalDigits: 0, showDecimals: false)} / ${formatTurkishCurrency(incomeConverted, decimalDigits: 0, showDecimals: false)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * (spentPercent / 100).clamp(0.0, 1.0),
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseRow(AppLocalizations l10n, double income, double spent, CurrencyProvider currencyProvider) {
    final incomeConverted = currencyProvider.convertFromTRY(income);
    final spentConverted = currencyProvider.convertFromTRY(spent);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Income - Sol taraf
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.arrowDown,
                    size: 20,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.income,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatTurkishCurrency(incomeConverted, decimalDigits: 0, showDecimals: false),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Dikey Divider
          Container(
            width: 1,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white.withOpacity(0.1),
          ),

          // Expense - Sağ taraf (MIRROR)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.expense,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatTurkishCurrency(spentConverted, decimalDigits: 0, showDecimals: false),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.arrowUp,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kompakt Financial Snapshot - Header'da kullanım için
class CompactFinancialBadge extends StatelessWidget {
  final double netBalance;
  final double spentPercent;
  final VoidCallback? onTap;

  const CompactFinancialBadge({
    super.key,
    required this.netBalance,
    required this.spentPercent,
    this.onTap,
  });

  bool get isHealthy => netBalance >= 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (isHealthy ? AppColors.success : AppColors.error)
                    .withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isHealthy ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatTurkishCurrency(netBalance.abs(),
                      decimalDigits: 0, showDecimals: false),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPercentColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${spentPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getPercentColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPercentColor() {
    if (spentPercent < 50) return AppColors.success;
    if (spentPercent < 75) return AppColors.warning;
    return AppColors.error;
  }
}