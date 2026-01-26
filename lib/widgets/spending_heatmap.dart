import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

/// Task 68: Category Trend Chart
/// Shows spending trend by category over time
class CategoryTrendChart extends StatelessWidget {
  final List<Expense> expenses;
  final int monthsToShow;
  final List<Color>? categoryColors;

  const CategoryTrendChart({
    super.key,
    required this.expenses,
    this.monthsToShow = 6,
    this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    final monthlyData = _calculateMonthlyByCategory();
    if (monthlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final categories = monthlyData.values
        .expand((m) => m.keys)
        .toSet()
        .take(5)
        .toList();

    final defaultColors = [
      context.appColors.primary,
      context.appColors.success,
      context.appColors.warning,
      context.appColors.error,
      context.appColors.secondary,
    ];

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
          Text(
            'Kategori Trendi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.appColors.cardBorder,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        _formatAmount(value),
                        style: TextStyle(
                          fontSize: 10,
                          color: context.appColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final months = monthlyData.keys.toList();
                        if (value.toInt() >= months.length) return const SizedBox();
                        final date = months[value.toInt()];
                        return Text(
                          _getMonthAbbr(date.month),
                          style: TextStyle(
                            fontSize: 10,
                            color: context.appColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final color = categoryColors?[index % (categoryColors?.length ?? 1)] ??
                      defaultColors[index % defaultColors.length];

                  return LineChartBarData(
                    spots: monthlyData.entries.toList().asMap().entries.map((e) {
                      final monthIndex = e.key;
                      final monthData = e.value.value;
                      return FlSpot(monthIndex.toDouble(), monthData[category] ?? 0);
                    }).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.1),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final color = categoryColors?[index % (categoryColors?.length ?? 1)] ??
                  defaultColors[index % defaultColors.length];

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Map<DateTime, Map<String, double>> _calculateMonthlyByCategory() {
    final result = <DateTime, Map<String, double>>{};
    final now = DateTime.now();

    for (var i = monthsToShow - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      result[month] = {};
    }

    for (final expense in expenses) {
      if (expense.decision == ExpenseDecision.yes) {
        final month = DateTime(expense.date.year, expense.date.month, 1);
        if (result.containsKey(month)) {
          result[month]![expense.category] =
              (result[month]![expense.category] ?? 0) + expense.amount;
        }
      }
    }

    return result;
  }

  String _formatAmount(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _getMonthAbbr(int month) {
    const abbrs = ['', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
                   'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return abbrs[month];
  }
}

/// Task 69: Work Hours Equivalent Chart
/// Shows expenses as work hours needed to earn that amount
class WorkHoursChart extends StatelessWidget {
  final List<Expense> expenses;
  final double hourlyRate;
  final int daysToShow;

  const WorkHoursChart({
    super.key,
    required this.expenses,
    required this.hourlyRate,
    this.daysToShow = 7,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyRate <= 0) return const SizedBox.shrink();

    final dailyHours = _calculateDailyWorkHours();

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
                Icons.access_time,
                color: context.appColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Çalışma Saati Karşılığı',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = dailyHours.keys.toList();
                        if (value.toInt() >= days.length) return const SizedBox();
                        final date = days[value.toInt()];
                        return Text(
                          _getDayAbbr(date.weekday),
                          style: TextStyle(
                            fontSize: 10,
                            color: context.appColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: dailyHours.entries.toList().asMap().entries.map((e) {
                  final index = e.key;
                  final hours = e.value.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: hours,
                        color: hours > 8
                            ? context.appColors.error
                            : hours > 4
                                ? context.appColors.warning
                                : context.appColors.success,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Toplam: ${_totalHours().toStringAsFixed(1)} saat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              Text(
                ' (${hourlyRate.toStringAsFixed(0)} TL/saat)',
                style: TextStyle(
                  fontSize: 12,
                  color: context.appColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<DateTime, double> _calculateDailyWorkHours() {
    final result = <DateTime, double>{};
    final now = DateTime.now();

    for (var i = daysToShow - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      result[day] = 0;
    }

    for (final expense in expenses) {
      if (expense.decision == ExpenseDecision.yes) {
        final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
        if (result.containsKey(day)) {
          result[day] = result[day]! + (expense.amount / hourlyRate);
        }
      }
    }

    return result;
  }

  double _totalHours() {
    return _calculateDailyWorkHours().values.fold(0.0, (a, b) => a + b);
  }

  String _getDayAbbr(int weekday) {
    const abbrs = ['', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return abbrs[weekday];
  }
}
