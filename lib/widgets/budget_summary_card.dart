import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/category_budget.dart';
import '../providers/category_budget_provider.dart';
import '../services/category_budget_service.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';
import 'category_budget_card.dart';
import 'create_budget_sheet.dart';

/// Card showing overall budget summary with warnings
/// iOS 26 Liquid Glass Premium Design
class BudgetSummaryCard extends StatefulWidget {
  final VoidCallback? onViewAll;
  final VoidCallback? onAddBudget;

  const BudgetSummaryCard({super.key, this.onViewAll, this.onAddBudget});

  @override
  State<BudgetSummaryCard> createState() => _BudgetSummaryCardState();
}

class _BudgetSummaryCardState extends State<BudgetSummaryCard>
    with SingleTickerProviderStateMixin {
  // iOS 26 Liquid Glass: Animated breathing glow
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final budgetProvider = context.watch<CategoryBudgetProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    if (budgetProvider.isLoading) {
      return const SizedBox.shrink();
    }

    // No budgets - show empty state
    if (!budgetProvider.hasBudgets) {
      return _buildEmptyState(context, l10n);
    }

    final summary = budgetProvider.summary;
    if (summary == null) return const SizedBox.shrink();

    final totalBudgetConverted = currencyProvider.convertFromTRY(
      summary.totalBudget,
    );
    final totalSpentConverted = currencyProvider.convertFromTRY(
      summary.totalSpent,
    );

    // iOS 26 Liquid Glass: Animated card with breathing glow
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              // Animated breathing glow
              BoxShadow(
                color: context.vantColors.primary.withValues(
                  alpha: _glowAnimation.value,
                ),
                blurRadius: 28,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              // Deep shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              // iOS 26: Enhanced 24σ blur
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  // iOS 26 Liquid Glass: Premium gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      VantColors.primary.withValues(alpha: 0.2),
                      VantColors.primaryDark.withValues(alpha: 0.12),
                      const Color(0xFF1E1B4B).withValues(alpha: 0.25),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  // Glass border
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // iOS 26: Top highlight for glass light refraction
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: context.vantColors.primary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CupertinoIcons.creditcard,
                            color: context.vantColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.budgetProgress,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.vantColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onViewAll?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.vantColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.viewAll,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.vantColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 14,
                              color: context.vantColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Total progress
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.totalBudget,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.vantColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currencyProvider.symbol}${formatTurkishCurrency(totalSpentConverted, decimalDigits: 0)} / ${currencyProvider.symbol}${formatTurkishCurrency(totalBudgetConverted, decimalDigits: 0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: context.vantColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Overall percentage
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getOverallColor(
                          context,
                          summary,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '%${summary.overallPercentUsed.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _getOverallColor(context, summary),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Overall progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (summary.overallPercentUsed / 100).clamp(0, 1),
                    backgroundColor: context.vantColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation(
                      _getOverallColor(context, summary),
                    ),
                    minHeight: 8,
                  ),
                ),

                const SizedBox(height: 16),

                // Category status counts
                Row(
                  children: [
                    _buildStatusChip(
                      context,
                      icon: CupertinoIcons.checkmark_circle_fill,
                      color: context.vantColors.success,
                      label: l10n.categoriesOnTrack(summary.categoriesOnTrack),
                    ),
                    const SizedBox(width: 8),
                    if (summary.categoriesNearLimit > 0 ||
                        summary.categoriesOverBudget > 0)
                      _buildStatusChip(
                        context,
                        icon: CupertinoIcons.exclamationmark_triangle_fill,
                        color: summary.categoriesOverBudget > 0
                            ? context.vantColors.error
                            : context.vantColors.warning,
                        label: summary.categoriesOverBudget > 0
                            ? l10n.categoriesOverBudget(
                                summary.categoriesOverBudget,
                              )
                            : l10n.categoriesNearLimit(
                                summary.categoriesNearLimit,
                              ),
                      ),
                  ],
                ),

                // Warning budgets (if any)
                if (budgetProvider.warningBudgets.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: budgetProvider.warningBudgets
                        .take(3)
                        .map(
                          (b) => CompactBudgetCard(budget: b, onTap: widget.onViewAll),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.vantColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.vantColors.cardBorder,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.vantColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.creditcard,
              color: context.vantColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noBudgetsYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.vantColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noBudgetsDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.vantColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              CreateBudgetSheet.show(context);
            },
            icon: const Icon(CupertinoIcons.plus, size: 18),
            label: Text(l10n.addBudget),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.vantColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getOverallColor(BuildContext context, BudgetSummary summary) {
    if (summary.overallPercentUsed >= 100) return context.vantColors.error;
    if (summary.overallPercentUsed >= 80) return context.vantColors.warning;
    if (summary.overallPercentUsed >= 50) return Colors.amber;
    return context.vantColors.success;
  }
}

/// Warning banner for dashboard when budgets are at risk
class BudgetWarningBanner extends StatelessWidget {
  final List<CategoryBudgetWithSpent> budgets;
  final VoidCallback? onTap;

  const BudgetWarningBanner({super.key, required this.budgets, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (budgets.isEmpty) return const SizedBox.shrink();

    final hasOverBudget = budgets.any((b) => b.isOverBudget);
    final color = hasOverBudget
        ? context.vantColors.error
        : context.vantColors.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                hasOverBudget
                    ? CupertinoIcons.exclamationmark_triangle
                    : CupertinoIcons.exclamationmark_circle,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasOverBudget
                        ? l10n.budgetExceededTitle
                        : l10n.budgetNearLimit,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${budgets.length} ${budgets.length == 1 ? l10n.category.toLowerCase() : l10n.categories.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
