import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import '../providers/providers.dart';
import '../utils/currency_utils.dart';
import 'package:vantag/l10n/app_localizations.dart';

enum TimeFilter { week, month, all }

class ReportScreen extends StatefulWidget {
  final UserProfile userProfile;

  const ReportScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with TickerProviderStateMixin {
  final _subscriptionService = SubscriptionService();
  TimeFilter _selectedFilter = TimeFilter.month;
  double _totalSubscriptionAmount = 0;
  int _subscriptionCount = 0;

  // Animasyon kontrolleri
  late AnimationController _contentAnimController;
  late Animation<double> _contentAnimation;
  bool _showCharts = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSubscriptions();
  }

  void _setupAnimations() {
    _contentAnimController = AnimationController(
      vsync: this,
      duration: AppAnimations.long,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentAnimController,
      curve: AppAnimations.standardCurve,
    );

    // Provider zaten yüklendiyse animasyonu başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startContentAnimation();
    });
  }

  @override
  void dispose() {
    _contentAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptions() async {
    final subscriptions = await _subscriptionService.getActiveSubscriptions();
    final totalSub = await _subscriptionService.getTotalMonthlyAmount();

    if (mounted) {
      setState(() {
        _subscriptionCount = subscriptions.length;
        _totalSubscriptionAmount = totalSub;
      });
    }
  }

  Future<void> _startContentAnimation() async {
    await Future.delayed(AppAnimations.initialDelay);
    if (mounted) {
      _contentAnimController.forward();
      await Future.delayed(AppAnimations.medium);
      if (mounted) {
        setState(() => _showCharts = true);
      }
    }
  }

  List<Expense> _getFilteredExpenses(List<Expense> allExpenses) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allExpenses.where((expense) {
      switch (_selectedFilter) {
        case TimeFilter.week:
          final weekAgo = today.subtract(const Duration(days: 7));
          return expense.date.isAfter(weekAgo);
        case TimeFilter.month:
          final monthAgo = DateTime(now.year, now.month - 1, now.day);
          return expense.date.isAfter(monthAgo);
        case TimeFilter.all:
          return true;
      }
    }).toList();
  }

  List<Expense> _getPreviousPeriodExpenses(List<Expense> allExpenses) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allExpenses.where((expense) {
      switch (_selectedFilter) {
        case TimeFilter.week:
          final weekAgo = today.subtract(const Duration(days: 7));
          final twoWeeksAgo = today.subtract(const Duration(days: 14));
          return expense.date.isAfter(twoWeeksAgo) &&
              expense.date.isBefore(weekAgo);
        case TimeFilter.month:
          final monthAgo = DateTime(now.year, now.month - 1, now.day);
          final twoMonthsAgo = DateTime(now.year, now.month - 2, now.day);
          return expense.date.isAfter(twoMonthsAgo) &&
              expense.date.isBefore(monthAgo);
        case TimeFilter.all:
          return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Provider'dan reaktif olarak veri al
    final financeProvider = context.watch<FinanceProvider>();
    final allExpenses = financeProvider.realExpenses;
    final isLoading = financeProvider.isLoading;
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reports,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                const ListLoadingPlaceholder(itemCount: 4, itemHeight: 100),
              ],
            ),
          ),
        ),
      );
    }

    final expenses = _getFilteredExpenses(allExpenses);
    final hasData = expenses.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reports,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTimeFilter(l10n),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Content
            if (!hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState.reports(message: l10n.notEnoughDataForReports),
              )
            else ...[
              // Summary cards with staggered animation
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _contentAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(_contentAnimation),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSummaryCards(expenses, l10n),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Sub-category comparison insight (if any)
              if (_hasComparisonInsight(expenses, allExpenses))
                SliverToBoxAdapter(
                  child: _AnimatedSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSubCategoryInsightCard(expenses, allExpenses, l10n),
                    ),
                  ),
                ),

              if (_hasComparisonInsight(expenses, allExpenses))
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Category chart with animation
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildAnimatedCategoryChart(expenses, l10n),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Sub-category breakdown (if any)
              if (_hasSubCategories(expenses))
                SliverToBoxAdapter(
                  child: _AnimatedSlideIn(
                    delay: const Duration(milliseconds: 250),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSubCategoryBreakdown(expenses, l10n),
                    ),
                  ),
                ),

              if (_hasSubCategories(expenses))
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Statistics with animation
              SliverToBoxAdapter(
                child: _AnimatedSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildStatistics(expenses, l10n),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Trend with animation
              if (_selectedFilter != TimeFilter.all)
                SliverToBoxAdapter(
                  child: _AnimatedSlideIn(
                    delay: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildTrendCard(expenses, allExpenses, l10n),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilter(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _buildFilterButton(l10n.thisWeek, TimeFilter.week),
          _buildFilterButton(l10n.thisMonth, TimeFilter.month),
          _buildFilterButton(l10n.allTime, TimeFilter.all),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, TimeFilter filter) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
            _showCharts = false;
          });
          // Kısa gecikme sonra chart'ları göster
          Future.delayed(AppAnimations.initialDelay, () {
            if (mounted) setState(() => _showCharts = true);
          });
        },
        child: AnimatedContainer(
          duration: AppAnimations.short,
          curve: AppAnimations.standardCurve,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.background : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<Expense> expenses, AppLocalizations l10n) {
    final stats = DecisionStats.fromExpenses(expenses);
    final totalSpent = stats.yesTotal;
    final totalSaved = stats.savedAmount;
    final totalCount = expenses.length;
    final savingsRate = totalCount > 0
        ? (stats.noCount / totalCount * 100)
        : 0.0;

    final spentHours = expenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .fold<double>(0, (sum, e) => sum + e.hoursRequired);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AnimatedSummaryCard(
                delay: Duration.zero,
                title: l10n.totalSpent,
                value: totalSpent,
                suffix: ' TL',
                subtitle: l10n.hoursEquivalent(spentHours.toStringAsFixed(1)),
                color: AppColors.decisionYes,
                icon: LucideIcons.shoppingCart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnimatedSummaryCard(
                delay: const Duration(milliseconds: 50),
                title: l10n.totalSaved,
                value: totalSaved,
                suffix: ' TL',
                subtitle: l10n.hoursRequired(stats.savedHours.toStringAsFixed(1)),
                color: AppColors.decisionNo,
                icon: LucideIcons.shieldCheck,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AnimatedSummaryCard(
                delay: const Duration(milliseconds: 100),
                title: l10n.expenseCount,
                value: totalCount.toDouble(),
                isInteger: true,
                subtitle: l10n.boughtPassed(stats.yesCount, stats.noCount),
                color: AppColors.info,
                icon: LucideIcons.receipt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnimatedSummaryCard(
                delay: const Duration(milliseconds: 150),
                title: l10n.passRate,
                value: savingsRate,
                prefix: '%',
                isInteger: true,
                subtitle: savingsRate >= 50 ? l10n.doingGreat : l10n.canDoBetter,
                color: savingsRate >= 50 ? AppColors.success : AppColors.warning,
                icon: LucideIcons.trendingUp,
              ),
            ),
          ],
        ),
        if (_subscriptionCount > 0) ...[
          const SizedBox(height: 12),
          _AnimatedSummaryCard(
            delay: const Duration(milliseconds: 200),
            title: l10n.monthlySubscriptions,
            value: _totalSubscriptionAmount,
            suffix: ' TL',
            subtitle: l10n.activeSubscriptions(_subscriptionCount),
            color: AppColors.primary,
            icon: LucideIcons.calendar,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _buildAnimatedCategoryChart(List<Expense> expenses, AppLocalizations l10n) {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      if (expense.decision == ExpenseDecision.yes) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
    }

    if (categoryTotals.isEmpty) {
      return _AnimatedSlideIn(
        delay: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Center(
            child: Text(
              l10n.noExpenses,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = categoryTotals.values.fold<double>(0, (a, b) => a + b);

    final colors = [
      AppColors.primary,
      AppColors.warning,
      AppColors.info,
      AppColors.error,
      const Color(0xFF9B59B6),
      const Color(0xFF1ABC9C),
      const Color(0xFFE91E63),
      const Color(0xFF3F51B5),
      const Color(0xFF795548),
    ];

    return _AnimatedSlideIn(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.categoryDistribution,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  // Animated Pie chart
                  Expanded(
                    child: RepaintBoundary(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          // Clockwise animasyon
                          startDegreeOffset: -90,
                          sections: _showCharts
                              ? sortedCategories.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final value = entry.value.value;
                                  final percentage = (value / total * 100);
                                  final isTop = index == 0;

                                  return PieChartSectionData(
                                    value: value,
                                    title: isTop ? '%${percentage.toStringAsFixed(0)}' : '',
                                    color: colors[index % colors.length],
                                    radius: isTop ? 50 : 40,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    // En büyük kategori için glow efekti
                                    badgeWidget: isTop
                                        ? null
                                        : null,
                                  );
                                }).toList()
                              : [
                                  PieChartSectionData(
                                    value: 1,
                                    title: '',
                                    color: AppColors.surfaceLight,
                                    radius: 40,
                                  ),
                                ],
                        ),
                        // Clockwise animasyon süresi (fl_chart v0.69+)
                        // duration: AppAnimations.counter,
                        // curve: AppAnimations.standardCurve,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Animated Legend
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sortedCategories.take(5).toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value.key;
                        final value = entry.value.value;
                        final percentage = (value / total * 100);
                        final isTop = index == 0;

                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: _showCharts ? 1.0 : 0),
                          duration: Duration(
                            milliseconds: 300 + (index * 50),
                          ),
                          curve: AppAnimations.standardCurve,
                          builder: (context, animValue, child) {
                            return Opacity(
                              opacity: animValue,
                              child: Transform.translate(
                                offset: Offset(20 * (1 - animValue), 0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      // Soft glow for top category
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: colors[index % colors.length],
                                          borderRadius: BorderRadius.circular(2),
                                          boxShadow: isTop
                                              ? [
                                                  BoxShadow(
                                                    color: colors[index % colors.length]
                                                        .withValues(alpha: 0.5),
                                                    blurRadius: 6,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isTop ? FontWeight.w600 : FontWeight.w400,
                                            color: isTop
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '%${percentage.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isTop
                                              ? colors[index % colors.length]
                                              : AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            if (sortedCategories.length > 5) ...[
              const SizedBox(height: 8),
              Text(
                l10n.moreCategories(sortedCategories.length - 5),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Alt kategori karşılaştırmalı insight
  /// Returns: (subCategory, changePercent, isIncrease) or null
  /// Gösterim kuralları:
  /// - Önceki dönem yoksa null
  /// - Değişim ±%5'ten küçükse null
  /// - subCategory null ise null
  ({String subCategory, double changePercent, bool isIncrease})? _getSubCategoryComparisonInsight(
      List<Expense> currentExpenses, List<Expense> previousExpenses) {
    // "Tüm Zamanlar" filtresi için karşılaştırma yapma
    if (_selectedFilter == TimeFilter.all) return null;

    // Önceki dönem boşsa gösterme
    if (previousExpenses.isEmpty) return null;

    // Alt kategori toplamlarını hesapla
    Map<String, double> calculateSubCategoryTotals(List<Expense> expenses) {
      final totals = <String, double>{};
      for (final expense in expenses) {
        if (expense.decision != ExpenseDecision.yes) continue;
        if (expense.subCategory == null || expense.subCategory!.isEmpty) continue;
        totals[expense.subCategory!] =
            (totals[expense.subCategory!] ?? 0) + expense.amount;
      }
      return totals;
    }

    final currentTotals = calculateSubCategoryTotals(currentExpenses);
    final previousTotals = calculateSubCategoryTotals(previousExpenses);

    // Hiç alt kategori yoksa gösterme
    if (currentTotals.isEmpty && previousTotals.isEmpty) return null;

    // En anlamlı değişimi bul
    String? bestSubCategory;
    double bestChangePercent = 0;
    bool bestIsIncrease = false;

    // Mevcut dönemdeki alt kategorileri kontrol et
    for (final entry in currentTotals.entries) {
      final subCat = entry.key;
      final currentAmount = entry.value;
      final previousAmount = previousTotals[subCat] ?? 0;

      if (previousAmount > 0) {
        final changePercent = ((currentAmount - previousAmount) / previousAmount) * 100;
        if (changePercent.abs() > bestChangePercent.abs()) {
          bestSubCategory = subCat;
          bestChangePercent = changePercent;
          bestIsIncrease = changePercent > 0;
        }
      }
    }

    // Değişim ±%5'ten küçükse gösterme
    if (bestSubCategory == null || bestChangePercent.abs() < 5) return null;

    return (
      subCategory: bestSubCategory,
      changePercent: bestChangePercent.abs(),
      isIncrease: bestIsIncrease,
    );
  }

  /// Alt kategori karşılaştırmalı mini insight kartı
  Widget _buildSubCategoryInsightCard(List<Expense> expenses, List<Expense> allExpenses, AppLocalizations l10n) {
    final previousExpenses = _getPreviousPeriodExpenses(allExpenses);
    final insight = _getSubCategoryComparisonInsight(expenses, previousExpenses);
    if (insight == null) return const SizedBox.shrink();

    final periodLabel = switch (_selectedFilter) {
      TimeFilter.week => l10n.thisWeek,
      TimeFilter.month => l10n.thisMonth,
      TimeFilter.all => '', // Bu durumda kart gösterilmez
    };

    final previousLabel = switch (_selectedFilter) {
      TimeFilter.week => l10n.periodWeek,
      TimeFilter.month => l10n.periodMonth,
      TimeFilter.all => '',
    };

    final changeText = insight.isIncrease ? l10n.increased : l10n.decreased;
    final accentColor = insight.isIncrease ? AppColors.warning : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.08),
            accentColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              insight.isIncrease
                  ? LucideIcons.trendingUp
                  : LucideIcons.trendingDown,
              size: 20,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.subCategoryChange(periodLabel, insight.subCategory, changeText, insight.changePercent.toStringAsFixed(0), previousLabel),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.comparedToPrevious,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Karşılaştırmalı insight gösterilecek mi kontrol et
  bool _hasComparisonInsight(List<Expense> expenses, List<Expense> allExpenses) {
    if (_selectedFilter == TimeFilter.all) return false;
    final previousExpenses = _getPreviousPeriodExpenses(allExpenses);
    return _getSubCategoryComparisonInsight(expenses, previousExpenses) != null;
  }

  /// Alt kategori olan harcama var mı kontrol et
  bool _hasSubCategories(List<Expense> expenses) {
    return expenses.any((e) =>
        e.subCategory != null &&
        e.subCategory!.isNotEmpty &&
        e.decision == ExpenseDecision.yes);
  }

  /// Alt kategori breakdown widget'ı
  Widget _buildSubCategoryBreakdown(List<Expense> expenses, AppLocalizations l10n) {
    // Ana kategori -> Alt kategori -> Toplam tutar
    final Map<String, Map<String, double>> categoryBreakdown = {};

    for (final expense in expenses) {
      if (expense.decision != ExpenseDecision.yes) continue;
      if (expense.subCategory == null || expense.subCategory!.isEmpty) continue;

      final mainCat = expense.category;
      final subCat = expense.subCategory!;

      categoryBreakdown[mainCat] ??= {};
      categoryBreakdown[mainCat]![subCat] =
          (categoryBreakdown[mainCat]![subCat] ?? 0) + expense.amount;
    }

    if (categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ana kategorileri toplam harcamaya göre sırala
    final sortedMainCategories = categoryBreakdown.entries.toList()
      ..sort((a, b) {
        final totalA = a.value.values.fold<double>(0, (sum, v) => sum + v);
        final totalB = b.value.values.fold<double>(0, (sum, v) => sum + v);
        return totalB.compareTo(totalA);
      });

    final colors = [
      AppColors.primary,
      AppColors.warning,
      AppColors.info,
      AppColors.error,
      const Color(0xFF9B59B6),
      const Color(0xFF1ABC9C),
      const Color(0xFFE91E63),
      const Color(0xFF3F51B5),
      const Color(0xFF795548),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.layoutGrid,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.subCategoryDetail,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedMainCategories.asMap().entries.map((mainEntry) {
            final mainIndex = mainEntry.key;
            final mainCategory = mainEntry.value.key;
            final subCategories = mainEntry.value.value;
            final mainColor = colors[mainIndex % colors.length];

            // Alt kategorileri sırala
            final sortedSubs = subCategories.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final mainTotal = subCategories.values.fold<double>(0, (s, v) => s + v);

            return Padding(
              padding: EdgeInsets.only(
                bottom: mainIndex < sortedMainCategories.length - 1 ? 16 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ana kategori başlığı
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mainCategory,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${formatTurkishCurrency(mainTotal, decimalDigits: 2)} TL',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Alt kategoriler
                  ...sortedSubs.map((subEntry) {
                    final subName = subEntry.key;
                    final subAmount = subEntry.value;
                    final subPercent = (subAmount / mainTotal * 100);

                    return Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: mainColor.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            '${formatTurkishCurrency(subAmount, decimalDigits: 2)} TL',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: mainColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '%${subPercent.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: mainColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatistics(List<Expense> expenses, AppLocalizations l10n) {
    final yesExpenses = expenses.where((e) => e.decision == ExpenseDecision.yes).toList();
    final totalSpent = yesExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    int dayCount;
    switch (_selectedFilter) {
      case TimeFilter.week:
        dayCount = 7;
        break;
      case TimeFilter.month:
        dayCount = 30;
        break;
      case TimeFilter.all:
        if (expenses.isEmpty) {
          dayCount = 1;
        } else {
          final dates = expenses.map((e) => e.date).toList();
          final earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
          dayCount = DateTime.now().difference(earliest).inDays + 1;
        }
    }

    final dailyAverage = totalSpent / dayCount;

    final highestExpense = yesExpenses.isNotEmpty
        ? yesExpenses.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;

    final noExpenses = expenses.where((e) => e.decision == ExpenseDecision.no).toList();
    final noCategoryCounts = <String, int>{};
    for (final expense in noExpenses) {
      noCategoryCounts[expense.category] = (noCategoryCounts[expense.category] ?? 0) + 1;
    }
    String? mostDeclinedCategory;
    int mostDeclinedCount = 0;
    for (final entry in noCategoryCounts.entries) {
      if (entry.value > mostDeclinedCount) {
        mostDeclinedCount = entry.value;
        mostDeclinedCategory = entry.key;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statistics,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: LucideIcons.calendar,
            label: l10n.avgDailyExpense,
            value: '${formatTurkishCurrency(dailyAverage, decimalDigits: 2)} TL',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: LucideIcons.arrowUp,
            label: l10n.highestSingleExpense,
            value: highestExpense != null
                ? '${formatTurkishCurrency(highestExpense.amount, decimalDigits: 2)} TL (${highestExpense.category})'
                : '-',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: LucideIcons.ban,
            label: l10n.mostDeclinedCategory,
            value: mostDeclinedCategory != null
                ? '$mostDeclinedCategory (${l10n.times(mostDeclinedCount)})'
                : '-',
            valueColor: AppColors.decisionNo,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard(List<Expense> expenses, List<Expense> allExpenses, AppLocalizations l10n) {
    final previousExpenses = _getPreviousPeriodExpenses(allExpenses);

    final currentSpent = expenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .fold<double>(0, (sum, e) => sum + e.amount);

    final previousSpent = previousExpenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .fold<double>(0, (sum, e) => sum + e.amount);

    if (previousSpent == 0 && currentSpent == 0) {
      return const SizedBox.shrink();
    }

    final difference = previousSpent > 0
        ? ((currentSpent - previousSpent) / previousSpent * 100)
        : 0.0;

    final isPositive = difference <= 0;
    final periodLabel = _selectedFilter == TimeFilter.week ? l10n.periodWeek : l10n.periodMonth;

    String message;
    if (previousSpent == 0) {
      message = l10n.trendSpentThisPeriod(formatTurkishCurrency(currentSpent, decimalDigits: 2), periodLabel);
    } else if (difference == 0) {
      message = l10n.trendSameAsPrevious(periodLabel);
    } else {
      final absPercent = difference.abs().toStringAsFixed(0);
      message = isPositive
          ? l10n.trendSpentLess(absPercent, periodLabel)
          : l10n.trendSpentMore(absPercent, periodLabel);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPositive
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPositive ? LucideIcons.trendingDown : LucideIcons.trendingUp,
              color: isPositive ? AppColors.success : AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.trend,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? AppColors.success : AppColors.warning,
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

// ========== YARDIMCI ANİMASYON WİDGET'LARI ==========

/// Gecikmeli slide-in animasyonu
class _AnimatedSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedSlideIn({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedSlideIn> createState() => _AnimatedSlideInState();
}

class _AnimatedSlideInState extends State<_AnimatedSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standardCurve,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animasyonlu özet kartı
class _AnimatedSummaryCard extends StatefulWidget {
  final Duration delay;
  final String title;
  final double value;
  final String? prefix;
  final String? suffix;
  final String subtitle;
  final Color color;
  final IconData icon;
  final bool isFullWidth;
  final bool isInteger;

  const _AnimatedSummaryCard({
    this.delay = Duration.zero,
    required this.title,
    required this.value,
    this.prefix,
    this.suffix,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.isFullWidth = false,
    this.isInteger = false,
  });

  @override
  State<_AnimatedSummaryCard> createState() => _AnimatedSummaryCardState();
}

class _AnimatedSummaryCardState extends State<_AnimatedSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.standardCurve,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, size: 18, color: widget.color),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              // Animated counter
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: widget.value),
                duration: AppAnimations.counter,
                curve: AppAnimations.standardCurve,
                builder: (context, animValue, child) {
                  String text;
                  if (widget.isInteger) {
                    text = '${widget.prefix ?? ''}${animValue.toInt()}${widget.suffix ?? ''}';
                  } else {
                    text = '${widget.prefix ?? ''}${animValue.toStringAsFixed(0)}${widget.suffix ?? ''}';
                  }
                  return Text(
                    text,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: widget.color,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
