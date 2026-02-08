import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import '../providers/providers.dart';
import '../utils/category_utils.dart';
import 'package:vantag/l10n/app_localizations.dart';

enum TimeFilter { week, month, all }

class ReportScreen extends StatefulWidget {
  final UserProfile userProfile;

  const ReportScreen({super.key, required this.userProfile});

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

  // Spending trend selected month
  int? _selectedMonthIndex;

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

  /// Calculate hourly rate from user profile
  double _calculateHourlyRate() {
    final profile = widget.userProfile;
    final monthlyIncome = profile.monthlyIncome;
    final dailyHours = profile.dailyHours;
    final workDaysPerWeek = profile.workDaysPerWeek;

    // Monthly work hours = daily hours × work days per week × 4 weeks
    final monthlyHours = dailyHours * workDaysPerWeek * 4;
    if (monthlyHours <= 0) return 1;

    return monthlyIncome / monthlyHours;
  }

  /// Get last month's expenses for comparison
  List<Expense> _getLastMonthExpenses(List<Expense> allExpenses) {
    final now = DateTime.now();
    final firstDayThisMonth = DateTime(now.year, now.month, 1);
    final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);

    return allExpenses.where((expense) {
      return expense.date.isAfter(
            firstDayLastMonth.subtract(const Duration(days: 1)),
          ) &&
          expense.date.isBefore(firstDayThisMonth);
    }).toList();
  }

  /// Get this month's expenses for comparison
  List<Expense> _getThisMonthExpenses(List<Expense> allExpenses) {
    final now = DateTime.now();
    final firstDayThisMonth = DateTime(now.year, now.month, 1);

    return allExpenses.where((expense) {
      return expense.date.isAfter(
        firstDayThisMonth.subtract(const Duration(days: 1)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Provider'dan reaktif olarak veri al
    final financeProvider = context.watch<FinanceProvider>();
    final allExpenses = financeProvider.realExpenses;
    final isLoading = financeProvider.isLoading;
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: context.vantColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reports,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: context.vantColors.textPrimary,
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
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: VantGradients.background,
        ),
        child: SafeArea(
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
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: context.vantColors.textPrimary,
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
                child: EmptyState.reports(
                  message: l10n.notEnoughDataForReports,
                ),
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

              // NEW: Month Comparison Card (This Month vs Last Month)
              if (_selectedFilter == TimeFilter.month)
                SliverToBoxAdapter(
                  child: _AnimatedSlideIn(
                    delay: const Duration(milliseconds: 50),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildMonthComparisonCard(allExpenses, l10n),
                    ),
                  ),
                ),

              if (_selectedFilter == TimeFilter.month)
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Sub-category comparison insight (PRO) (if any)
              if (_hasComparisonInsight(expenses, allExpenses))
                SliverToBoxAdapter(
                  child: _AnimatedSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LockedProFeature(
                        featureName: l10n.proFeatureTimeAnalysis,
                        child: _buildSubCategoryInsightCard(
                          expenses,
                          allExpenses,
                          l10n,
                        ),
                      ),
                    ),
                  ),
                ),

              if (_hasComparisonInsight(expenses, allExpenses))
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Category chart with animation (PRO - pie chart)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LockedProFeature(
                    featureName: l10n.proFeatureCategoryBreakdown,
                    child: _buildAnimatedCategoryChart(expenses, l10n),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Category Budget Progress (PRO)
              SliverToBoxAdapter(
                child: _AnimatedSlideIn(
                  delay: const Duration(milliseconds: 150),
                  child: LockedProFeature(
                    featureName: l10n.proFeatureBudgetBreakdown,
                    child: _buildBudgetSection(l10n),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Category-based Work Hours Bar Chart (PRO)
              SliverToBoxAdapter(
                child: _AnimatedSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LockedProFeature(
                      featureName: l10n.proFeatureTimeAnalysis,
                      child: _buildWorkHoursBarChart(expenses, l10n),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Sub-category breakdown (PRO) (if any)
              if (_hasSubCategories(expenses))
                SliverToBoxAdapter(
                  child: _AnimatedSlideIn(
                    delay: const Duration(milliseconds: 250),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LockedProFeature(
                        featureName: l10n.proFeatureCategoryBreakdown,
                        child: _buildSubCategoryBreakdown(expenses, l10n),
                      ),
                    ),
                  ),
                ),

              if (_hasSubCategories(expenses))
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Statistics with animation (PRO)
              SliverToBoxAdapter(
                child: _AnimatedSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LockedProFeature(
                      featureName: l10n.proFeatureTimeAnalysis,
                      child: _buildStatistics(expenses, l10n),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Smart Insight Cards (PRO)
              SliverToBoxAdapter(
                child: _AnimatedSlideIn(
                  delay: const Duration(milliseconds: 350),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LockedProFeature(
                      featureName: l10n.proFeatureSpendingTrends,
                      child: _buildSmartInsightCards(
                        expenses,
                        allExpenses,
                        l10n,
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Trend with animation (PRO)
              if (_selectedFilter != TimeFilter.all)
                SliverToBoxAdapter(
                  child: _AnimatedSlideIn(
                    delay: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LockedProFeature(
                        featureName: l10n.proFeatureSpendingTrends,
                        child: _buildTrendCard(expenses, allExpenses, l10n),
                      ),
                    ),
                  ),
                ),

              if (_selectedFilter != TimeFilter.all)
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Yearly Heatmap (PRO)
              SliverToBoxAdapter(
                child: _AnimatedSlideIn(
                  delay: const Duration(milliseconds: 450),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LockedProFeature(
                      featureName: l10n.proFeatureHeatmap,
                      child: _buildYearlyHeatmap(allExpenses, l10n),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTimeFilter(AppLocalizations l10n) {
    final isPremium = context.watch<ProProvider>().isPro;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
              : [const Color(0x0A000000), const Color(0x05000000)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
      ),
      child: Row(
        children: [
          _buildFilterButton(l10n.thisWeek, TimeFilter.week, isPremium),
          _buildFilterButton(l10n.thisMonth, TimeFilter.month, isPremium),
          _buildFilterButton(l10n.allTime, TimeFilter.all, isPremium),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, TimeFilter filter, bool isPremium) {
    final isSelected = _selectedFilter == filter;
    // Lock month and all-time for free users
    final isLocked = !isPremium && filter != TimeFilter.week;
    final l10n = AppLocalizations.of(context);

    // Build semantic label based on state
    String semanticLabel;
    if (isLocked) {
      semanticLabel = l10n.lockedFilterPremium(label);
    } else if (isSelected) {
      semanticLabel = l10n.selectedFilter(label);
    } else {
      semanticLabel = l10n.selectTimeFilter(label);
    }

    return Expanded(
      child: Semantics(
        label: semanticLabel,
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: () {
            if (isLocked) {
              // Show upgrade dialog for locked filters
              UpgradeDialog.show(context, l10n.reportsPremiumOnly);
              return;
            }
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
              color: isSelected
                  ? context.vantColors.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLocked) ...[
                  Icon(
                    CupertinoIcons.lock,
                    size: 12,
                    color: context.vantColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? context.vantColors.textTertiary
                          : isSelected
                          ? context.vantColors.background
                          : context.vantColors.textSecondary,
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

  Widget _buildSummaryCards(List<Expense> expenses, AppLocalizations l10n) {
    final stats = DecisionStats.fromExpenses(expenses);
    final totalSpent = stats.yesTotal;
    final totalSaved = stats.totalSaved;
    final totalCount = expenses.length;
    final savingsRate = totalCount > 0
        ? (stats.noCount / totalCount * 100)
        : 0.0;

    final spentHours = expenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .fold<double>(0, (sum, e) => sum + e.hoursRequired);

    // Include smart choice saved hours in total saved hours
    final hourlyRate = _calculateHourlyRate();
    final smartChoiceSavedHours = hourlyRate > 0
        ? stats.smartChoiceSaved / hourlyRate
        : 0.0;
    final totalSavedHours = stats.savedHours + smartChoiceSavedHours;

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
                color: context.vantColors.decisionYes,
                icon: CupertinoIcons.cart_fill,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnimatedSummaryCard(
                delay: const Duration(milliseconds: 50),
                title: l10n.totalSaved,
                value: totalSaved,
                suffix: ' TL',
                subtitle: l10n.hoursRequired(
                  totalSavedHours.toStringAsFixed(1),
                ),
                color: context.vantColors.decisionNo,
                icon: CupertinoIcons.shield_fill,
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
                color: context.vantColors.info,
                icon: CupertinoIcons.doc_text_fill,
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
                subtitle: savingsRate >= 50
                    ? l10n.doingGreat
                    : l10n.canDoBetter,
                color: savingsRate >= 50
                    ? context.vantColors.success
                    : context.vantColors.warning,
                icon: CupertinoIcons.arrow_up_right,
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
            color: context.vantColors.primary,
            icon: CupertinoIcons.calendar,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NEW: MONTH COMPARISON CARD (This Month vs Last Month)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMonthComparisonCard(
    List<Expense> allExpenses,
    AppLocalizations l10n,
  ) {
    final thisMonthExpenses = _getThisMonthExpenses(allExpenses);
    final lastMonthExpenses = _getLastMonthExpenses(allExpenses);

    final thisMonthTotal = thisMonthExpenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .fold<double>(0, (sum, e) => sum + e.amount);

    final lastMonthTotal = lastMonthExpenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .fold<double>(0, (sum, e) => sum + e.amount);

    final hasLastMonthData = lastMonthExpenses.isNotEmpty;
    final percentChange = hasLastMonthData && lastMonthTotal > 0
        ? ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100)
        : 0.0;

    final isDecrease = percentChange < 0;
    final isNoChange = percentChange.abs() < 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
              : [const Color(0x0A000000), const Color(0x05000000)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
        boxShadow: [
          const BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
          ...VantShadows.glow(VantColors.primary, intensity: 0.08, blur: 16),
        ],
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.vantColors.primary.withValues(alpha: 0.25),
                      context.vantColors.primary.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: VantShadows.glow(VantColors.primary, intensity: 0.2, blur: 12),
                ),
                child: Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  size: 18,
                  color: context.vantColors.primary,
                  shadows: VantShadows.iconHalo(VantColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.monthComparison,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // This Month
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.thisMonth,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: thisMonthTotal),
                      duration: AppAnimations.counter,
                      builder: (context, value, child) {
                        return Text(
                          context.read<CurrencyProvider>().format(value),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: context.vantColors.textPrimary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // VS Arrow and Percentage
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isNoChange
                      ? context.vantColors.surfaceLight
                      : (isDecrease
                            ? context.vantColors.success.withValues(alpha: 0.15)
                            : context.vantColors.warning.withValues(
                                alpha: 0.15,
                              )),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (!hasLastMonthData)
                      Text(
                        l10n.noLastMonthData,
                        style: TextStyle(
                          fontSize: 10,
                          color: context.vantColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else ...[
                      Text(
                        isNoChange
                            ? l10n.noChange
                            : (isDecrease
                                  ? l10n.decreasedBy(
                                      percentChange.abs().toStringAsFixed(0),
                                    )
                                  : l10n.increasedBy(
                                      percentChange.abs().toStringAsFixed(0),
                                    )),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isNoChange
                              ? context.vantColors.textSecondary
                              : (isDecrease
                                    ? context.vantColors.success
                                    : context.vantColors.warning),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isNoChange
                            ? ''
                            : (isDecrease ? l10n.greatProgress : l10n.watchOut),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDecrease
                              ? context.vantColors.success
                              : context.vantColors.warning,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Last Month
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.lastMonth,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasLastMonthData
                          ? context.read<CurrencyProvider>().format(lastMonthTotal)
                          : '-',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: hasLastMonthData
                            ? context.vantColors.textSecondary
                            : context.vantColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NEW: WORK HOURS BAR CHART
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildWorkHoursBarChart(
    List<Expense> expenses,
    AppLocalizations l10n,
  ) {
    final hourlyRate = _calculateHourlyRate();

    // Calculate work hours per category
    final categoryHours = <String, double>{};
    for (final expense in expenses) {
      if (expense.decision == ExpenseDecision.yes) {
        final hours = expense.amount / hourlyRate;
        categoryHours[expense.category] =
            (categoryHours[expense.category] ?? 0) + hours;
      }
    }

    if (categoryHours.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by hours descending
    final sortedCategories = categoryHours.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalHours = categoryHours.values.fold<double>(0, (a, b) => a + b);
    final maxHours = sortedCategories.first.value;

    final colors = [
      context.vantColors.primary,
      context.vantColors.warning,
      context.vantColors.info,
      context.vantColors.error,
      VantColors.categoryShopping,
      VantColors.achievementStreak,
      VantColors.achievementMystery,
      VantColors.categoryEntertainment,
      VantColors.categoryDefault,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
              : [const Color(0x0A000000), const Color(0x05000000)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
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
                  color: context.vantColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.clock_fill,
                  size: 18,
                  color: context.vantColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.workHoursDistribution,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.workHoursDistributionDesc,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.vantColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...sortedCategories.take(6).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            final hours = entry.value.value;
            final percent = totalHours > 0 ? (hours / totalHours * 100) : 0.0;
            final barWidth = maxHours > 0 ? hours / maxHours : 0.0;
            final color = colors[index % colors.length];
            final categoryIcon = ExpenseCategory.getIcon(category);

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < sortedCategories.length - 1 ? 12 : 0,
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _showCharts ? 1.0 : 0),
                duration: Duration(milliseconds: 400 + (index * 80)),
                curve: Curves.easeOutCubic,
                builder: (context, animValue, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(categoryIcon, size: 18, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              CategoryUtils.getLocalizedName(context, category),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: context.vantColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${hours.toStringAsFixed(1)}h',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '%${percent.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.vantColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: barWidth * animValue,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.7)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }),
          if (sortedCategories.length > 6) ...[
            const SizedBox(height: 8),
            Text(
              l10n.moreCategories(sortedCategories.length - 6),
              style: TextStyle(
                fontSize: 11,
                color: context.vantColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NEW: SMART INSIGHT CARDS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSmartInsightCards(
    List<Expense> expenses,
    List<Expense> allExpenses,
    AppLocalizations l10n,
  ) {
    final hourlyRate = _calculateHourlyRate();

    // 1. Most Expensive Day
    final dayTotals = <int, List<double>>{};
    for (final expense in expenses) {
      if (expense.decision == ExpenseDecision.yes) {
        final weekday = expense.date.weekday;
        dayTotals[weekday] ??= [];
        dayTotals[weekday]!.add(expense.amount);
      }
    }

    String? mostExpensiveDay;
    double mostExpensiveDayAvg = 0;
    if (dayTotals.isNotEmpty) {
      final dayAverages = dayTotals.map((day, amounts) {
        return MapEntry(day, amounts.reduce((a, b) => a + b) / amounts.length);
      });
      final maxEntry = dayAverages.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      mostExpensiveDay = _getDayName(maxEntry.key, l10n);
      mostExpensiveDayAvg = maxEntry.value;
    }

    // 2. Most Passed Category
    final passedCounts = <String, int>{};
    for (final expense in expenses) {
      if (expense.decision == ExpenseDecision.no) {
        passedCounts[expense.category] =
            (passedCounts[expense.category] ?? 0) + 1;
      }
    }
    String? mostPassedCategory;
    int mostPassedCount = 0;
    if (passedCounts.isNotEmpty) {
      final maxEntry = passedCounts.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      mostPassedCategory = maxEntry.key;
      mostPassedCount = maxEntry.value;
    }

    // 3. Savings Opportunity (highest category)
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      if (expense.decision == ExpenseDecision.yes) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
    }
    String? highestCategory;
    double savingsHours = 0;
    if (categoryTotals.isNotEmpty) {
      final maxEntry = categoryTotals.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      highestCategory = maxEntry.key;
      // 20% savings in hours
      savingsHours = hourlyRate > 0 ? (maxEntry.value * 0.2) / hourlyRate : 0.0;
    }

    // 4. Weekly Trend (last 4 weeks)
    final weeklyTotals = <int, double>{};
    final now = DateTime.now();
    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: 7 * (i + 1)));
      final weekEnd = now.subtract(Duration(days: 7 * i));
      final weekTotal = allExpenses
          .where(
            (e) =>
                e.decision == ExpenseDecision.yes &&
                e.date.isAfter(weekStart) &&
                e.date.isBefore(weekEnd),
          )
          .fold<double>(0, (sum, e) => sum + e.amount);
      weeklyTotals[i] = weekTotal;
    }

    String trendArrows = '';
    String trendDescription = l10n.noTrendData;
    if (weeklyTotals.length >= 2) {
      int upCount = 0;
      int downCount = 0;
      for (int i = 0; i < 3; i++) {
        final current = weeklyTotals[i] ?? 0;
        final previous = weeklyTotals[i + 1] ?? 0;
        if (current > previous) {
          trendArrows = '↑$trendArrows';
          upCount++;
        } else if (current < previous) {
          trendArrows = '↓$trendArrows';
          downCount++;
        } else {
          trendArrows = '→$trendArrows';
        }
      }
      if (downCount >= 2) {
        trendDescription = l10n.overallDecreasing;
      } else if (upCount >= 2) {
        trendDescription = l10n.overallIncreasing;
      } else {
        trendDescription = l10n.stableTrend;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
              : [const Color(0x0A000000), const Color(0x05000000)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
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
                  color: context.vantColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.lightbulb_fill,
                  size: 18,
                  color: context.vantColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.smartInsights,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2x2 Grid of insight cards
          Row(
            children: [
              Expanded(
                child: _InsightMiniCard(
                  icon: CupertinoIcons.calendar,
                  iconColor: context.vantColors.warning,
                  title: l10n.mostExpensiveDay,
                  value: mostExpensiveDay != null
                      ? l10n.mostExpensiveDayValue(
                          mostExpensiveDay,
                          formatTurkishCurrency(
                            mostExpensiveDayAvg,
                            decimalDigits: 0,
                          ),
                        )
                      : '-',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightMiniCard(
                  icon: CupertinoIcons.nosign,
                  iconColor: context.vantColors.success,
                  title: l10n.mostPassedCategory,
                  value: mostPassedCategory != null
                      ? l10n.mostPassedCategoryValue(
                          CategoryUtils.getLocalizedName(
                            context,
                            mostPassedCategory,
                          ),
                          mostPassedCount,
                        )
                      : '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InsightMiniCard(
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  iconColor: context.vantColors.primary,
                  title: l10n.savingsOpportunity,
                  value: highestCategory != null
                      ? l10n.savingsOpportunityValue(
                          CategoryUtils.getLocalizedName(
                            context,
                            highestCategory,
                          ),
                          savingsHours.toStringAsFixed(1),
                        )
                      : '-',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightMiniCard(
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  iconColor: context.vantColors.info,
                  title: l10n.weeklyTrend,
                  value: trendArrows.isNotEmpty
                      ? l10n.weeklyTrendValue('$trendArrows $trendDescription')
                      : l10n.noTrendData,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday, AppLocalizations l10n) {
    switch (weekday) {
      case 1:
        return l10n.weekdayMonday;
      case 2:
        return l10n.weekdayTuesday;
      case 3:
        return l10n.weekdayWednesday;
      case 4:
        return l10n.weekdayThursday;
      case 5:
        return l10n.weekdayFriday;
      case 6:
        return l10n.weekdaySaturday;
      case 7:
        return l10n.weekdaySunday;
      default:
        return '';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SPENDING TREND CHART (Area Chart)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildYearlyHeatmap(List<Expense> allExpenses, AppLocalizations l10n) {
    // Get last 12 months data
    final now = DateTime.now();
    final monthlyData = <int, _MonthData>{};

    // Initialize last 12 months
    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final normalizedMonth = DateTime(monthDate.year, monthDate.month, 1);
      monthlyData[11 - i] = _MonthData(
        month: normalizedMonth.month,
        year: normalizedMonth.year,
        total: 0,
        count: 0,
      );
    }

    // Group expenses by month
    for (final expense in allExpenses) {
      if (expense.decision == ExpenseDecision.yes) {
        // Find which index this expense belongs to
        for (int i = 0; i < 12; i++) {
          final data = monthlyData[i]!;
          if (expense.date.year == data.year &&
              expense.date.month == data.month) {
            monthlyData[i] = _MonthData(
              month: data.month,
              year: data.year,
              total: data.total + expense.amount,
              count: data.count + 1,
            );
            break;
          }
        }
      }
    }

    // Find max for scaling
    final maxAmount = monthlyData.values
        .map((d) => d.total)
        .fold(0.0, (a, b) => a > b ? a : b);
    final safeMax = maxAmount > 0 ? maxAmount : 1.0;

    // Create chart spots
    final spots = <FlSpot>[];
    for (int i = 0; i < 12; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyData[i]!.total));
    }

    // Get month names
    final monthNames = [
      l10n.monthJan,
      l10n.monthFeb,
      l10n.monthMar,
      l10n.monthApr,
      l10n.monthMay,
      l10n.monthJun,
      l10n.monthJul,
      l10n.monthAug,
      l10n.monthSep,
      l10n.monthOct,
      l10n.monthNov,
      l10n.monthDec,
    ];

    // Currency symbol
    final currencyProvider = context.read<CurrencyProvider>();
    final symbol = currencyProvider.currency.symbol;

    // Selected month info
    String? selectedMonthInfo;
    if (_selectedMonthIndex != null &&
        _selectedMonthIndex! >= 0 &&
        _selectedMonthIndex! < 12) {
      final data = monthlyData[_selectedMonthIndex!]!;
      final monthName = monthNames[data.month - 1];
      selectedMonthInfo = l10n.selectedMonthExpenses(
        monthName,
        '$symbol${formatTurkishCurrency(data.total, decimalDigits: 0)}',
        data.count,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
              : [const Color(0x0A000000), const Color(0x05000000)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.vantColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  size: 18,
                  color: context.vantColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.yearlyHeatmap,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.vantColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ProBadge(),
                      ],
                    ),
                    Text(
                      l10n.yearlyHeatmapDesc,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.vantColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Area Chart
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: safeMax / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: context.vantColors.cardBorder,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            _formatAmount(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: context.vantColors.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= 12) {
                          return const SizedBox.shrink();
                        }
                        // Show every other month to prevent crowding
                        if (index % 2 != 0 && index != 11) {
                          return const SizedBox.shrink();
                        }
                        final data = monthlyData[index]!;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            monthNames[data.month - 1],
                            style: TextStyle(
                              fontSize: 10,
                              color: _selectedMonthIndex == index
                                  ? context.vantColors.primary
                                  : context.vantColors.textTertiary,
                              fontWeight: _selectedMonthIndex == index
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: safeMax * 1.1,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        context.vantColors.cardBackground,
                    tooltipBorder: BorderSide(
                      color: context.vantColors.primary,
                      width: 1,
                    ),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final data = monthlyData[index]!;
                        final monthName = monthNames[data.month - 1];
                        return LineTooltipItem(
                          '$monthName\n$symbol${formatTurkishCurrency(data.total, decimalDigits: 0)}',
                          TextStyle(
                            color: context.vantColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent &&
                        response?.lineBarSpots != null) {
                      final spot = response!.lineBarSpots!.first;
                      setState(() {
                        _selectedMonthIndex = spot.x.toInt();
                      });
                    }
                  },
                  handleBuiltInTouches: true,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: context.vantColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final isSelected = _selectedMonthIndex == index;
                        return FlDotCirclePainter(
                          radius: isSelected ? 6 : 4,
                          color: isSelected
                              ? context.vantColors.primary
                              : context.vantColors.primary.withValues(
                                  alpha: 0.8,
                                ),
                          strokeWidth: isSelected ? 2 : 0,
                          strokeColor: context.vantColors.textPrimary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.vantColors.primary.withValues(alpha: 0.4),
                          context.vantColors.primary.withValues(alpha: 0.1),
                          context.vantColors.primary.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected month info or hint
          if (selectedMonthInfo != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.vantColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.vantColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                selectedMonthInfo,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.vantColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                l10n.tapMonthForDetails,
                style: TextStyle(
                  fontSize: 11,
                  color: context.vantColors.textTertiary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Format amount with K/M suffix
  String _formatAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  /// Build the category budget progress section
  Widget _buildBudgetSection(AppLocalizations l10n) {
    return Consumer<CategoryBudgetProvider>(
      builder: (context, budgetProvider, _) {
        // Initialize budget provider if not done
        if (budgetProvider.budgets.isEmpty && !budgetProvider.isLoading) {
          final financeProvider = context.read<FinanceProvider>();
          final now = DateTime.now();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            budgetProvider.initialize(financeProvider.expenses);
            budgetProvider.setMonth(now.month, now.year);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.creditcard_fill,
                        size: 20,
                        color: context.vantColors.primary,
                      ),
                      const SizedBox(width: 8),
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
                  Semantics(
                    label: l10n.addBudget,
                    button: true,
                    child: GestureDetector(
                      onTap: () => CreateBudgetSheet.show(context),
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
                            Icon(
                              CupertinoIcons.plus,
                              size: 16,
                              color: context.vantColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.addBudget,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.vantColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Budget cards or empty state
            if (budgetProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (!budgetProvider.hasBudgets)
              BudgetSummaryCard(
                onAddBudget: () => CreateBudgetSheet.show(context),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: budgetProvider.budgets
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                entry.key < budgetProvider.budgets.length - 1
                                ? 12
                                : 0,
                          ),
                          child: CategoryBudgetCard(
                            budget: entry.value,
                            animationIndex: entry.key,
                            onTap: () {
                              CreateBudgetSheet.show(
                                context,
                                existingBudget: entry.value.budget,
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedCategoryChart(
    List<Expense> expenses,
    AppLocalizations l10n,
  ) {
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: context.isDarkMode
                  ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
                  : [const Color(0x0A000000), const Color(0x05000000)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Center(
            child: Text(
              l10n.noExpenses,
              style: TextStyle(color: context.vantColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = categoryTotals.values.fold<double>(0, (a, b) => a + b);

    final colors = [
      context.vantColors.primary,
      context.vantColors.warning,
      context.vantColors.info,
      context.vantColors.error,
      VantColors.categoryShopping,
      VantColors.achievementStreak,
      VantColors.achievementMystery,
      VantColors.categoryEntertainment,
      VantColors.categoryDefault,
    ];

    return _AnimatedSlideIn(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: context.isDarkMode
                ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
                : [const Color(0x0A000000), const Color(0x05000000)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.categoryDistribution,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.vantColors.textPrimary,
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
                                  final percentage = total > 0
                                      ? (value / total * 100)
                                      : 0.0;
                                  final isTop = index == 0;

                                  return PieChartSectionData(
                                    value: value,
                                    title: isTop
                                        ? '%${percentage.toStringAsFixed(0)}'
                                        : '',
                                    color: colors[index % colors.length],
                                    radius: isTop ? 50 : 40,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList()
                              : [
                                  PieChartSectionData(
                                    value: 1,
                                    title: '',
                                    color: context.vantColors.surfaceLight,
                                    radius: 40,
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Animated Legend
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sortedCategories
                          .take(5)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            final index = entry.key;
                            final category = entry.value.key;
                            final value = entry.value.value;
                            final percentage = total > 0
                                ? (value / total * 100)
                                : 0.0;
                            final isTop = index == 0;

                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0,
                                end: _showCharts ? 1.0 : 0,
                              ),
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          // Soft glow for top category
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color:
                                                  colors[index % colors.length],
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              boxShadow: isTop
                                                  ? [
                                                      BoxShadow(
                                                        color:
                                                            colors[index %
                                                                    colors
                                                                        .length]
                                                                .withValues(
                                                                  alpha: 0.5,
                                                                ),
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
                                              CategoryUtils.getLocalizedName(
                                                context,
                                                category,
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isTop
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                color: isTop
                                                    ? context
                                                          .vantColors
                                                          .textPrimary
                                                    : context
                                                          .vantColors
                                                          .textSecondary,
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
                                                  ? colors[index %
                                                        colors.length]
                                                  : context
                                                        .vantColors
                                                        .textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          })
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            if (sortedCategories.length > 5) ...[
              const SizedBox(height: 8),
              Text(
                l10n.moreCategories(sortedCategories.length - 5),
                style: TextStyle(
                  fontSize: 11,
                  color: context.vantColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Alt kategori karşılaştırmalı insight
  ({String subCategory, double changePercent, bool isIncrease})?
  _getSubCategoryComparisonInsight(
    List<Expense> currentExpenses,
    List<Expense> previousExpenses,
  ) {
    if (_selectedFilter == TimeFilter.all) return null;
    if (previousExpenses.isEmpty) return null;

    Map<String, double> calculateSubCategoryTotals(List<Expense> expenses) {
      final totals = <String, double>{};
      for (final expense in expenses) {
        if (expense.decision != ExpenseDecision.yes) continue;
        if (expense.subCategory == null || expense.subCategory!.isEmpty) {
          continue;
        }
        totals[expense.subCategory!] =
            (totals[expense.subCategory!] ?? 0) + expense.amount;
      }
      return totals;
    }

    final currentTotals = calculateSubCategoryTotals(currentExpenses);
    final previousTotals = calculateSubCategoryTotals(previousExpenses);

    if (currentTotals.isEmpty && previousTotals.isEmpty) return null;

    String? bestSubCategory;
    double bestChangePercent = 0;
    bool bestIsIncrease = false;

    for (final entry in currentTotals.entries) {
      final subCat = entry.key;
      final currentAmount = entry.value;
      final previousAmount = previousTotals[subCat] ?? 0;

      if (previousAmount > 0) {
        final changePercent =
            ((currentAmount - previousAmount) / previousAmount) * 100;
        if (changePercent.abs() > bestChangePercent.abs()) {
          bestSubCategory = subCat;
          bestChangePercent = changePercent;
          bestIsIncrease = changePercent > 0;
        }
      }
    }

    if (bestSubCategory == null || bestChangePercent.abs() < 5) return null;

    return (
      subCategory: bestSubCategory,
      changePercent: bestChangePercent.abs(),
      isIncrease: bestIsIncrease,
    );
  }

  Widget _buildSubCategoryInsightCard(
    List<Expense> expenses,
    List<Expense> allExpenses,
    AppLocalizations l10n,
  ) {
    final previousExpenses = _getPreviousPeriodExpenses(allExpenses);
    final insight = _getSubCategoryComparisonInsight(
      expenses,
      previousExpenses,
    );
    if (insight == null) return const SizedBox.shrink();

    final periodLabel = switch (_selectedFilter) {
      TimeFilter.week => l10n.thisWeek,
      TimeFilter.month => l10n.thisMonth,
      TimeFilter.all => '',
    };

    final previousLabel = switch (_selectedFilter) {
      TimeFilter.week => l10n.periodWeek,
      TimeFilter.month => l10n.periodMonth,
      TimeFilter.all => '',
    };

    final changeText = insight.isIncrease ? l10n.increased : l10n.decreased;
    final accentColor = insight.isIncrease
        ? context.vantColors.warning
        : context.vantColors.success;

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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              insight.isIncrease
                  ? CupertinoIcons.arrow_up_right
                  : CupertinoIcons.arrow_down_right,
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
                  l10n.subCategoryChange(
                    periodLabel,
                    insight.subCategory,
                    changeText,
                    insight.changePercent.toStringAsFixed(0),
                    previousLabel,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.vantColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.comparedToPrevious,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.vantColors.textTertiary.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasComparisonInsight(
    List<Expense> expenses,
    List<Expense> allExpenses,
  ) {
    if (_selectedFilter == TimeFilter.all) return false;
    final previousExpenses = _getPreviousPeriodExpenses(allExpenses);
    return _getSubCategoryComparisonInsight(expenses, previousExpenses) != null;
  }

  bool _hasSubCategories(List<Expense> expenses) {
    return expenses.any(
      (e) =>
          e.subCategory != null &&
          e.subCategory!.isNotEmpty &&
          e.decision == ExpenseDecision.yes,
    );
  }

  Widget _buildSubCategoryBreakdown(
    List<Expense> expenses,
    AppLocalizations l10n,
  ) {
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

    final sortedMainCategories = categoryBreakdown.entries.toList()
      ..sort((a, b) {
        final totalA = a.value.values.fold<double>(0, (sum, v) => sum + v);
        final totalB = b.value.values.fold<double>(0, (sum, v) => sum + v);
        return totalB.compareTo(totalA);
      });

    final colors = [
      context.vantColors.primary,
      context.vantColors.warning,
      context.vantColors.info,
      context.vantColors.error,
      VantColors.categoryShopping,
      VantColors.achievementStreak,
      VantColors.achievementMystery,
      VantColors.categoryEntertainment,
      VantColors.categoryDefault,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
              : [const Color(0x0A000000), const Color(0x05000000)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
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
                  color: context.vantColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.square_grid_2x2_fill,
                  size: 18,
                  color: context.vantColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.subCategoryDetail,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textPrimary,
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

            final sortedSubs = subCategories.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final mainTotal = subCategories.values.fold<double>(
              0,
              (s, v) => s + v,
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: mainIndex < sortedMainCategories.length - 1 ? 16 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          CategoryUtils.getLocalizedName(context, mainCategory),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.vantColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        context.read<CurrencyProvider>().formatWithDecimals(mainTotal),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                              style: TextStyle(
                                fontSize: 13,
                                color: context.vantColors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            context.read<CurrencyProvider>().formatWithDecimals(subAmount),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.vantColors.textSecondary,
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
    final yesExpenses = expenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .toList();
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

    final noExpenses = expenses
        .where((e) => e.decision == ExpenseDecision.no)
        .toList();
    final noCategoryCounts = <String, int>{};
    for (final expense in noExpenses) {
      noCategoryCounts[expense.category] =
          (noCategoryCounts[expense.category] ?? 0) + 1;
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
              : [const Color(0x0A000000), const Color(0x05000000)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statistics,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.vantColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: CupertinoIcons.calendar,
            label: l10n.avgDailyExpense,
            value:
                context.read<CurrencyProvider>().formatWithDecimals(dailyAverage),
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: CupertinoIcons.arrow_up,
            label: l10n.highestSingleExpense,
            value: highestExpense != null
                ? '${context.read<CurrencyProvider>().formatWithDecimals(highestExpense.amount)} (${CategoryUtils.getLocalizedName(context, highestExpense.category)})'
                : '-',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: CupertinoIcons.nosign,
            label: l10n.mostDeclinedCategory,
            value: mostDeclinedCategory != null
                ? '${CategoryUtils.getLocalizedName(context, mostDeclinedCategory)} (${l10n.times(mostDeclinedCount)})'
                : '-',
            valueColor: context.vantColors.decisionNo,
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
        Icon(icon, size: 18, color: context.vantColors.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.vantColors.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? context.vantColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard(
    List<Expense> expenses,
    List<Expense> allExpenses,
    AppLocalizations l10n,
  ) {
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
    final periodLabel = _selectedFilter == TimeFilter.week
        ? l10n.periodWeek
        : l10n.periodMonth;

    String message;
    if (previousSpent == 0) {
      message = l10n.trendSpentThisPeriod(
        formatTurkishCurrency(currentSpent, decimalDigits: 2),
        periodLabel,
      );
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
            ? context.vantColors.success.withValues(alpha: 0.1)
            : context.vantColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPositive
              ? context.vantColors.success.withValues(alpha: 0.3)
              : context.vantColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPositive
                  ? context.vantColors.success.withValues(alpha: 0.2)
                  : context.vantColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPositive
                  ? CupertinoIcons.arrow_down_right
                  : CupertinoIcons.arrow_up_right,
              color: isPositive
                  ? context.vantColors.success
                  : context.vantColors.warning,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: context.vantColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPositive
                        ? context.vantColors.success
                        : context.vantColors.warning,
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

// ═══════════════════════════════════════════════════════════════════════════
// DATA CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Monthly data for spending trend chart
class _MonthData {
  final int month;
  final int year;
  final double total;
  final int count;

  const _MonthData({
    required this.month,
    required this.year,
    required this.total,
    required this.count,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// PRO Badge Widget
class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.vantColors.gold.withValues(alpha: 0.9),
            context.vantColors.gold.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: context.vantColors.gold.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: context.vantColors.background,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// Insight Mini Card Widget
class _InsightMiniCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InsightMiniCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.vantColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.vantColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.vantColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.vantColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Gecikmeli slide-in animasyonu
class _AnimatedSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedSlideIn({required this.child, this.delay = Duration.zero});

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
      child: SlideTransition(position: _slideAnimation, child: widget.child),
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
      CurvedAnimation(parent: _controller, curve: AppAnimations.standardCurve),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: context.isDarkMode
                  ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
                  : [const Color(0x0A000000), const Color(0x05000000)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
            ],
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [widget.color.withValues(alpha: 0.25), widget.color.withValues(alpha: 0.10)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: VantShadows.glow(widget.color, intensity: 0.2, blur: 12),
                    ),
                    child: Icon(widget.icon, size: 18, color: widget.color, shadows: VantShadows.iconHalo(widget.color)),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 12,
                  color: context.vantColors.textSecondary,
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
                    text =
                        '${widget.prefix ?? ''}${animValue.toInt()}${widget.suffix ?? ''}';
                  } else {
                    text =
                        '${widget.prefix ?? ''}${animValue.toStringAsFixed(0)}${widget.suffix ?? ''}';
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
                style: TextStyle(
                  fontSize: 11,
                  color: context.vantColors.textTertiary,
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
