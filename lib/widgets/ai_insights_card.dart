import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme.dart';

/// AI Insights Card - Premium UI Element
/// Shows AI-generated insights about spending patterns
class AIInsightsCard extends StatelessWidget {
  final List<Expense> expenses;
  final List<Expense> lastMonthExpenses;

  const AIInsightsCard({
    super.key,
    required this.expenses,
    required this.lastMonthExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insights = _generateInsights(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'AI Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.vantColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const SmartBadge(),
          ],
        ),
        const SizedBox(height: 16),

        // Insight cards
        ...insights.map(
          (insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InsightCard(insight: insight),
          ),
        ),

        // AI disclaimer
        if (insights.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.aiDisclaimer,
              style: TextStyle(
                fontSize: 11,
                color: context.vantColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }

  List<_Insight> _generateInsights(AppLocalizations l10n) {
    final insights = <_Insight>[];

    // 1. Peak Spending Day
    final peakDay = _findPeakSpendingDay(l10n);
    if (peakDay != null) {
      insights.add(
        _Insight(
          icon: CupertinoIcons.calendar,
          iconColor: VantColors.premiumPurple,
          title: l10n.insightPeakDay,
          subtitle: peakDay,
        ),
      );
    }

    // 2. Top Category
    final topCategory = _findTopCategory(l10n);
    if (topCategory != null) {
      insights.add(
        _Insight(
          icon: CupertinoIcons.scope,
          iconColor: VantColors.premiumCyan,
          title: l10n.insightTopCategory,
          subtitle: topCategory,
        ),
      );
    }

    // 3. Month Comparison
    final comparison = _calculateMonthComparison(l10n);
    if (comparison != null) {
      insights.add(
        _Insight(
          icon: comparison.isDown
              ? CupertinoIcons.arrow_down_right
              : CupertinoIcons.arrow_up_right,
          iconColor: comparison.isDown ? VantColors.success : VantColors.error,
          title: l10n.insightMonthComparison,
          subtitle: comparison.text,
        ),
      );
    }

    return insights;
  }

  String? _findPeakSpendingDay(AppLocalizations l10n) {
    if (expenses.isEmpty) return null;

    final dayTotals = <int, double>{};
    for (final expense in expenses) {
      if (expense.decision == ExpenseDecision.yes) {
        final day = expense.date.weekday;
        dayTotals[day] = (dayTotals[day] ?? 0) + expense.amount;
      }
    }

    if (dayTotals.isEmpty) return null;

    final peakDay = dayTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    final dayNames = {
      1: l10n.dayMonday,
      2: l10n.dayTuesday,
      3: l10n.dayWednesday,
      4: l10n.dayThursday,
      5: l10n.dayFriday,
      6: l10n.daySaturday,
      7: l10n.daySunday,
    };

    return l10n.insightPeakDaySubtitle(dayNames[peakDay.key]!);
  }

  String? _findTopCategory(AppLocalizations l10n) {
    if (expenses.isEmpty) return null;

    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      if (expense.decision == ExpenseDecision.yes) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
    }

    if (categoryTotals.isEmpty) return null;

    final topCategory = categoryTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return l10n.insightTopCategorySubtitle(topCategory.key);
  }

  _MonthComparison? _calculateMonthComparison(AppLocalizations l10n) {
    final thisMonthTotal = expenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .fold(0.0, (sum, e) => sum + e.amount);

    final lastMonthTotal = lastMonthExpenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .fold(0.0, (sum, e) => sum + e.amount);

    if (lastMonthTotal == 0) return null;

    final change = ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
    final isDown = change < 0;
    final percent = change.abs().toStringAsFixed(0);

    return _MonthComparison(
      text: isDown ? l10n.insightMonthDown(percent) : l10n.insightMonthUp(percent),
      isDown: isDown,
    );
  }
}

class _Insight {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _Insight({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

class _MonthComparison {
  final String text;
  final bool isDown;

  const _MonthComparison({required this.text, required this.isDown});
}

class _InsightCard extends StatefulWidget {
  final _Insight insight;

  const _InsightCard({required this.insight});

  @override
  State<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<_InsightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GradientBorder(
              borderRadius: 16,
              borderWidth: 1.5,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.vantColors.cardBackground,
                  borderRadius: BorderRadius.circular(14.5),
                  boxShadow: _isPressed
                      ? [VantShadows.glowPurple]
                      : VantShadows.shadowPremium,
                ),
                child: Row(
                  children: [
                    // Icon with glow
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.insight.iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: widget.insight.iconColor.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.insight.icon,
                        color: widget.insight.iconColor,
                        size: 22,
                        shadows: VantShadows.iconHalo(
                          widget.insight.iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.insight.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.vantColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.insight.subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.vantColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
