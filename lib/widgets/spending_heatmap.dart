import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/theme.dart';

/// Task 67: Spending Heatmap Widget
/// Shows daily spending intensity in a calendar heatmap view
class SpendingHeatmap extends StatelessWidget {
  final List<Expense> expenses;
  final int weeksToShow;
  final DateTime? startDate;

  const SpendingHeatmap({
    super.key,
    required this.expenses,
    this.weeksToShow = 12,
    this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final start = startDate ?? DateTime.now().subtract(Duration(days: weeksToShow * 7));
    final dailyAmounts = _calculateDailyAmounts(start);
    final maxAmount = dailyAmounts.values.fold(0.0, (max, v) => v > max ? v : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week day labels
        Row(
          children: [
            const SizedBox(width: 24),
            ...['P', 'S', 'Ç', 'P', 'C', 'C', 'P'].map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 10,
                    color: context.appColors.textTertiary,
                  ),
                ),
              ),
            )),
          ],
        ),
        const SizedBox(height: 4),
        // Heatmap grid
        SizedBox(
          height: 7 * 14.0,
          child: Row(
            children: [
              // Month labels column
              SizedBox(
                width: 24,
                child: _buildMonthLabels(context, start),
              ),
              // Heatmap cells
              Expanded(
                child: _buildHeatmapGrid(context, dailyAmounts, maxAmount, start),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        _buildLegend(context),
      ],
    );
  }

  Map<DateTime, double> _calculateDailyAmounts(DateTime start) {
    final amounts = <DateTime, double>{};
    for (final expense in expenses) {
      if (expense.decision == ExpenseDecision.yes) {
        final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
        if (date.isAfter(start.subtract(const Duration(days: 1)))) {
          amounts[date] = (amounts[date] ?? 0) + expense.amount;
        }
      }
    }
    return amounts;
  }

  Widget _buildMonthLabels(BuildContext context, DateTime start) {
    final months = <String>[];
    var current = start;
    var lastMonth = -1;

    for (var week = 0; week < weeksToShow; week++) {
      if (current.month != lastMonth) {
        months.add(_getMonthAbbr(current.month));
        lastMonth = current.month;
      } else {
        months.add('');
      }
      current = current.add(const Duration(days: 7));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: months.take(7).map((m) => SizedBox(
        height: 14,
        child: Text(
          m,
          style: TextStyle(
            fontSize: 8,
            color: context.appColors.textTertiary,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildHeatmapGrid(
    BuildContext context,
    Map<DateTime, double> amounts,
    double maxAmount,
    DateTime start,
  ) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: weeksToShow * 7,
      itemBuilder: (context, index) {
        final date = start.add(Duration(days: index));
        final amount = amounts[DateTime(date.year, date.month, date.day)] ?? 0;
        final intensity = maxAmount > 0 ? (amount / maxAmount) : 0.0;

        return _HeatmapCell(
          intensity: intensity,
          date: date,
          amount: amount,
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Az',
          style: TextStyle(
            fontSize: 10,
            color: context.appColors.textTertiary,
          ),
        ),
        const SizedBox(width: 4),
        ...[0.0, 0.25, 0.5, 0.75, 1.0].map((i) => Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: _getIntensityColor(context, i),
            borderRadius: BorderRadius.circular(2),
          ),
        )),
        const SizedBox(width: 4),
        Text(
          'Çok',
          style: TextStyle(
            fontSize: 10,
            color: context.appColors.textTertiary,
          ),
        ),
      ],
    );
  }

  String _getMonthAbbr(int month) {
    const abbrs = ['', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
                   'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return abbrs[month];
  }

  static Color _getIntensityColor(BuildContext context, double intensity) {
    if (intensity <= 0) {
      return context.appColors.surfaceLight;
    } else if (intensity < 0.25) {
      return context.appColors.success.withValues(alpha: 0.3);
    } else if (intensity < 0.5) {
      return context.appColors.success.withValues(alpha: 0.5);
    } else if (intensity < 0.75) {
      return context.appColors.warning.withValues(alpha: 0.7);
    } else {
      return context.appColors.error.withValues(alpha: 0.9);
    }
  }
}

class _HeatmapCell extends StatelessWidget {
  final double intensity;
  final DateTime date;
  final double amount;

  const _HeatmapCell({
    required this.intensity,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${date.day}/${date.month}: ${amount.toStringAsFixed(0)} TL',
      child: Container(
        decoration: BoxDecoration(
          color: SpendingHeatmap._getIntensityColor(context, intensity),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Task 70: Savings Projection Widget
/// Shows projected savings based on current trend
class SavingsProjection extends StatelessWidget {
  final double currentSavings;
  final double monthlyAverage;
  final int projectionMonths;

  const SavingsProjection({
    super.key,
    required this.currentSavings,
    required this.monthlyAverage,
    this.projectionMonths = 12,
  });

  @override
  Widget build(BuildContext context) {
    final projections = List.generate(projectionMonths, (i) {
      return currentSavings + (monthlyAverage * (i + 1));
    });

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
                Icons.trending_up,
                color: context.appColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tasarruf Projeksiyonu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Projection milestones
          ...[
            (3, '3 Ay'),
            (6, '6 Ay'),
            (12, '1 Yıl'),
          ].where((e) => e.$1 <= projectionMonths).map((milestone) {
            final projected = currentSavings + (monthlyAverage * milestone.$1);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    milestone.$2,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${projected.toStringAsFixed(0)} TL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.success,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (monthlyAverage > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.appColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: context.appColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Aylık ortalama: ${monthlyAverage.toStringAsFixed(0)} TL',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.success,
                      ),
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
}
