import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/category_budget.dart';
import '../models/expense.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';
import 'create_budget_sheet.dart';

/// Card showing budget progress for a single category
class CategoryBudgetCard extends StatefulWidget {
  final CategoryBudgetWithSpent budget;
  final VoidCallback? onTap;
  final int animationIndex;

  const CategoryBudgetCard({
    super.key,
    required this.budget,
    this.onTap,
    this.animationIndex = 0,
  });

  @override
  State<CategoryBudgetCard> createState() => _CategoryBudgetCardState();
}

class _CategoryBudgetCardState extends State<CategoryBudgetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _progressAnimation =
        Tween<double>(
          begin: 0,
          end: widget.budget.percentUsedClamped / 100,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Staggered delay
    Future.delayed(Duration(milliseconds: 80 * widget.animationIndex), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(CategoryBudgetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.budget.percentUsed != widget.budget.percentUsed) {
      _progressAnimation =
          Tween<double>(
            begin: _progressAnimation.value,
            end: widget.budget.percentUsedClamped / 100,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor() {
    final percent = widget.budget.percentUsed;
    if (percent >= 100) return context.appColors.error;
    if (percent >= 80) return context.appColors.warning;
    if (percent >= 50) return Colors.amber;
    return context.appColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();
    final budget = widget.budget;

    final spentConverted = currencyProvider.convertFromTRY(budget.spent);
    final limitConverted = currencyProvider.convertFromTRY(
      budget.budget.monthlyLimit,
    );
    final remainingConverted = currencyProvider.convertFromTRY(
      budget.remaining.abs(),
    );

    final progressColor = _getProgressColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap?.call();
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                CreateBudgetSheet.show(context, existingBudget: budget.budget);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.appColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: budget.isOverBudget
                        ? context.appColors.error.withValues(alpha: 0.3)
                        : budget.isNearLimit
                        ? context.appColors.warning.withValues(alpha: 0.3)
                        : context.appColors.cardBorder,
                    width: budget.isOverBudget || budget.isNearLimit ? 1.5 : 1,
                  ),
                  boxShadow: [
                    if (budget.isOverBudget)
                      BoxShadow(
                        color: context.appColors.error.withValues(alpha: 0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Category icon + name + percentage
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            ExpenseCategory.getIcon(budget.budget.category),
                            color: progressColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ExpenseCategory.getLocalizedName(
                                  budget.budget.category,
                                  l10n,
                                ),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: context.appColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                budget.isOverBudget
                                    ? l10n.overLimit
                                    : budget.isNearLimit
                                    ? l10n.nearLimit
                                    : l10n.onTrack,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: progressColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Percentage badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '%${budget.percentUsed.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: progressColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.appColors.surfaceLight,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width:
                                      constraints.maxWidth *
                                      _progressAnimation.value,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        progressColor.withValues(alpha: 0.8),
                                        progressColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: progressColor.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Amount info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Spent / Limit
                        Text(
                          l10n.ofBudget(
                            '${currencyProvider.symbol}${formatTurkishCurrency(spentConverted, decimalDigits: 0)}',
                            '${currencyProvider.symbol}${formatTurkishCurrency(limitConverted, decimalDigits: 0)}',
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                        // Remaining
                        Row(
                          children: [
                            Icon(
                              budget.isOverBudget
                                  ? PhosphorIconsFill.warning
                                  : PhosphorIconsFill.checkCircle,
                              size: 14,
                              color: budget.isOverBudget
                                  ? context.appColors.error
                                  : context.appColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              budget.isOverBudget
                                  ? l10n.overBudgetAmount(
                                      '${currencyProvider.symbol}${formatTurkishCurrency(remainingConverted, decimalDigits: 0)}',
                                    )
                                  : l10n.remainingAmount(
                                      '${currencyProvider.symbol}${formatTurkishCurrency(remainingConverted, decimalDigits: 0)}',
                                    ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: budget.isOverBudget
                                    ? context.appColors.error
                                    : context.appColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
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
}

/// Compact budget card for dashboard
class CompactBudgetCard extends StatelessWidget {
  final CategoryBudgetWithSpent budget;
  final VoidCallback? onTap;

  const CompactBudgetCard({super.key, required this.budget, this.onTap});

  Color _getProgressColor(BuildContext context) {
    final percent = budget.percentUsed;
    if (percent >= 100) return context.appColors.error;
    if (percent >= 80) return context.appColors.warning;
    return context.appColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progressColor = _getProgressColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: progressColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: progressColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ExpenseCategory.getIcon(budget.budget.category),
              color: progressColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              ExpenseCategory.getLocalizedName(budget.budget.category, l10n),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: progressColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '%${budget.percentUsed.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
