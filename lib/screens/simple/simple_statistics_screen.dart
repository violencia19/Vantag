import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/theme.dart';
import '../../utils/currency_utils.dart';

/// Simple Mode - Statistics Screen with pie chart
class SimpleStatisticsScreen extends StatefulWidget {
  const SimpleStatisticsScreen({super.key});

  @override
  State<SimpleStatisticsScreen> createState() => _SimpleStatisticsScreenState();
}

class _SimpleStatisticsScreenState extends State<SimpleStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  // Category colors
  static const Map<String, Color> _categoryColors = {
    'Yiyecek': Color(0xFF4CAF50),
    'Food': Color(0xFF4CAF50),
    'Ulaşım': Color(0xFF2196F3),
    'Transport': Color(0xFF2196F3),
    'Alışveriş': Color(0xFFE91E63),
    'Shopping': Color(0xFFE91E63),
    'Faturalar': Color(0xFFFF9800),
    'Bills': Color(0xFFFF9800),
    'Eğlence': Color(0xFF9C27B0),
    'Entertainment': Color(0xFF9C27B0),
    'Sağlık': Color(0xFF00BCD4),
    'Health': Color(0xFF00BCD4),
    'Eğitim': Color(0xFF795548),
    'Education': Color(0xFF795548),
    'Diğer': Color(0xFF607D8B),
    'Other': Color(0xFF607D8B),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() {
        _selectedMonth = nextMonth;
      });
    }
  }

  List<Expense> _getMonthExpenses(List<Expense> allExpenses) {
    return allExpenses.where((e) {
      return e.date.year == _selectedMonth.year &&
          e.date.month == _selectedMonth.month &&
          e.decision == ExpenseDecision.yes;
    }).toList();
  }

  Map<String, double> _getCategoryTotals(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      final category = expense.category;
      totals[category] = (totals[category] ?? 0) + expense.amount;
    }
    // Sort by amount descending
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final financeProvider = context.watch<FinanceProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final expenses = financeProvider.realExpenses;
    final monthExpenses = _getMonthExpenses(expenses);
    final categoryTotals = _getCategoryTotals(monthExpenses);
    final totalExpense = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final currencySymbol = currencyProvider.currency.symbol;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.simpleStatistics,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),

            // Month Selector
            _buildMonthSelector(l10n),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.appColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: context.appColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: context.appColors.textPrimary,
                unselectedLabelColor: context.appColors.textSecondary,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: l10n.simpleExpenses),
                  Tab(text: l10n.simpleIncomeTab),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Expenses Tab
                  _buildExpensesTab(
                    categoryTotals,
                    totalExpense,
                    currencySymbol,
                    l10n,
                  ),
                  // Income Tab (simplified)
                  _buildIncomeTab(financeProvider, currencySymbol, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(AppLocalizations l10n) {
    final now = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == now.year &&
        _selectedMonth.month == now.month;

    final locale = Localizations.localeOf(context).languageCode;
    final monthFormat = DateFormat.yMMMM(locale);
    final monthName = monthFormat.format(_selectedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: Icon(
              PhosphorIconsBold.caretLeft,
              color: context.appColors.textPrimary,
              size: 20,
            ),
          ),
          Text(
            monthName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: isCurrentMonth ? null : _nextMonth,
            icon: Icon(
              PhosphorIconsBold.caretRight,
              color: isCurrentMonth
                  ? context.appColors.textTertiary
                  : context.appColors.textPrimary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(
    Map<String, double> categoryTotals,
    double totalExpense,
    String currencySymbol,
    AppLocalizations l10n,
  ) {
    if (categoryTotals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsDuotone.chartPie,
              size: 64,
              color: context.appColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.simpleNoData,
              style: TextStyle(
                fontSize: 16,
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Pie Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildPieSections(categoryTotals, totalExpense),
                centerSpaceRadius: 50,
                sectionsSpace: 2,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.appColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.simpleTotal,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
                Text(
                  '$currencySymbol${formatTurkishCurrency(totalExpense, decimalDigits: 0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.error,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Category List
          ...categoryTotals.entries.map((entry) {
            final percentage = (entry.value / totalExpense * 100);
            final color = _categoryColors[entry.key] ??
                context.appColors.textTertiary;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.appColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$currencySymbol${formatTurkishCurrency(entry.value, decimalDigits: 0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> categoryTotals,
    double total,
  ) {
    return categoryTotals.entries.map((entry) {
      final percentage = entry.value / total * 100;
      final color = _categoryColors[entry.key] ??
          context.appColors.textTertiary;

      return PieChartSectionData(
        value: entry.value,
        color: color,
        radius: 35,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        titleStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: context.appColors.textPrimary,
        ),
      );
    }).toList();
  }

  Widget _buildIncomeTab(
    FinanceProvider financeProvider,
    String currencySymbol,
    AppLocalizations l10n,
  ) {
    final profile = financeProvider.userProfile;
    final totalIncome = profile?.monthlyIncome ?? 0;
    final incomeSources = profile?.incomeSources ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Total Income
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.appColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.appColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  l10n.simpleTotalIncome,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currencySymbol${formatTurkishCurrency(totalIncome, decimalDigits: 0)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Income Sources
          if (incomeSources.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.simpleIncomeSources,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...incomeSources.map((source) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.appColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      source.category.icon,
                      color: source.category.color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        source.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '$currencySymbol${formatTurkishCurrency(source.amount, decimalDigits: 0)}',
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
          ],
        ],
      ),
    );
  }
}
