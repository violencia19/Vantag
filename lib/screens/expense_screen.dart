import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../theme/theme.dart';
import '../providers/providers.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'subscription_screen.dart';
import 'habit_calculator_screen.dart';
import 'profile_modal.dart';
import 'paywall_screen.dart';
import 'report_screen.dart';
import 'pursuit_list_screen.dart';

class ExpenseScreen extends StatefulWidget {
  final UserProfile userProfile;
  final ExchangeRates? exchangeRates;
  final bool isLoadingRates;
  final bool hasRateError;
  final VoidCallback? onRetryRates;
  final VoidCallback? onStreakUpdated;

  const ExpenseScreen({
    super.key,
    required this.userProfile,
    this.exchangeRates,
    this.isLoadingRates = false,
    this.hasRateError = false,
    this.onRetryRates,
    this.onStreakUpdated,
  });

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _subscriptionService = SubscriptionService();
  final _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final _streakWidgetKey = GlobalKey<StreakWidgetState>();

  int _upcomingSubscriptionCount = 0;
  bool _showSwipeHint = false;

  // Post-onboarding prompt states
  bool _loginPromptDismissed = false;
  bool _additionalIncomeAsked = false;
  bool _promptStatesLoaded = false;

  static const _keySwipeHintShown = 'swipe_hint_shown';
  static const _keyLoginPromptDismissed = 'login_prompt_dismissed';
  static const _keyAdditionalIncomeAsked = 'additional_income_asked';
  static const int _recentExpensesLimit = 5;

  @override
  void initState() {
    super.initState();
    _checkSwipeHint();
    _loadUpcomingSubscriptions();
    _loadPromptStates();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkSwipeHint() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_keySwipeHintShown) ?? false;
    if (!shown) {
      setState(() => _showSwipeHint = true);
      await prefs.setBool(_keySwipeHintShown, true);
    }
  }

  Future<void> _loadUpcomingSubscriptions() async {
    final upcoming = await _subscriptionService.getUpcomingSubscriptions(
      withinDays: 3,
    );
    if (mounted) {
      setState(() => _upcomingSubscriptionCount = upcoming.length);
    }
  }

  Future<void> _loadPromptStates() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _loginPromptDismissed = prefs.getBool(_keyLoginPromptDismissed) ?? false;
        _additionalIncomeAsked = prefs.getBool(_keyAdditionalIncomeAsked) ?? false;
        _promptStatesLoaded = true;
      });
    }
  }

  Future<void> _dismissLoginPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoginPromptDismissed, true);
    if (mounted) {
      setState(() => _loginPromptDismissed = true);
    }
  }

  Future<void> _onLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoginPromptDismissed, true);
    if (mounted) {
      setState(() => _loginPromptDismissed = true);
    }
  }

  Future<void> _dismissAdditionalIncomePrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAdditionalIncomeAsked, true);
    if (mounted) {
      setState(() => _additionalIncomeAsked = true);
    }
  }

  /// Determines which prompt card to show (if any)
  /// Order: Login Prompt -> Additional Income -> Onboarding Checklist
  Widget? _buildPromptCard() {
    if (!_promptStatesLoaded) return null;

    final isLoggedIn = !_authService.isAnonymous;

    // 1. Login Prompt: Show if not logged in and not dismissed
    if (!isLoggedIn && !_loginPromptDismissed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: LoginPromptCard(
          onDismiss: _dismissLoginPrompt,
          onLoginSuccess: _onLoginSuccess,
        ),
      );
    }

    // 2. Additional Income Prompt: Show after login prompt is handled
    if (!_additionalIncomeAsked) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AdditionalIncomePrompt(
          onYes: _dismissAdditionalIncomePrompt,
          onNo: _dismissAdditionalIncomePrompt,
        ),
      );
    }

    // 3. Onboarding Checklist: Show after both prompts are handled
    // OnboardingChecklist handles its own dismissal state internally
    return OnboardingChecklist(
      onAddExpense: () {
        HapticFeedback.lightImpact();
        showAddExpenseSheet(
          context,
          exchangeRates: widget.exchangeRates,
          onExpenseAdded: () {
            _streakWidgetKey.currentState?.refresh();
            widget.onStreakUpdated?.call();
          },
        );
      },
      onViewReport: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(
              userProfile: widget.userProfile,
            ),
          ),
        );
      },
      onCreatePursuit: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PursuitListScreen(),
          ),
        );
      },
    );
  }

  void _showSubscriptionSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    ).then((_) => _loadUpcomingSubscriptions());
  }

  void _openHabitCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HabitCalculatorScreen()),
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  Widget _buildHeaderAction({
    required IconData icon,
    int? badge,
    required VoidCallback onTap,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: lg.GlassContainer(
          width: 44,
          height: 44,
          shape: const lg.LiquidRoundedSuperellipse(borderRadius: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: context.appColors.textSecondary),
              if (badge != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: context.appColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.appColors.gold.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$badge',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.gold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Avatar button that opens profile modal
  Widget _buildAvatarButton(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final photoUrl = user?.photoURL;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.profile,
      button: true,
      child: GestureDetector(
        onTap: () => ProfileModal.show(context),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.appColors.primary.withValues(alpha: 0.3),
                context.appColors.secondary.withValues(alpha: 0.3),
              ],
            ),
            border: Border.all(
              color: context.appColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: context.appColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipOval(
            child: photoUrl != null
                ? Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    cacheWidth: 100,
                    cacheHeight: 100,
                    errorBuilder: (_, __, ___) => _buildDefaultAvatarIcon(),
                  )
                : _buildDefaultAvatarIcon(),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatarIcon() {
    return Container(
      color: context.appColors.surfaceLight,
      child: Icon(
        CupertinoIcons.person_fill,
        size: 24,
        color: context.appColors.textTertiary,
      ),
    );
  }

  Widget _buildHabitCalculatorBanner() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        label: l10n.habitCalculator,
        button: true,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _openHabitCalculator();
          },
          child: lg.GlassCard(
            shape: const lg.LiquidRoundedSuperellipse(borderRadius: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.secondary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  lg.GlassContainer(
                    width: 48,
                    height: 48,
                    shape: const lg.LiquidRoundedSuperellipse(borderRadius: 16),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.bolt_fill,
                        size: 28,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.habitQuestion,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.appColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.calculateAndShock,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.appColors.textPrimary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: context.appColors.textPrimary.withValues(alpha: 0.9),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build budget warning banner if any budgets are at risk
  Widget _buildBudgetWarningBanner() {
    return Consumer<CategoryBudgetProvider>(
      builder: (context, budgetProvider, _) {
        // Initialize if needed
        if (budgetProvider.budgets.isEmpty && !budgetProvider.isLoading) {
          final financeProvider = context.read<FinanceProvider>();
          final now = DateTime.now();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            budgetProvider.initialize(financeProvider.expenses);
            budgetProvider.setMonth(now.month, now.year);
          });
        }

        // Only show if there are warning budgets
        if (!budgetProvider.hasWarnings) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BudgetWarningBanner(
            budgets: budgetProvider.warningBudgets,
            onTap: () {
              // Show snackbar directing to Reports tab
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).viewBudgetsInReports,
                  ),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: AppLocalizations.of(context).viewAll,
                    onPressed: () {
                      // User can navigate to Reports tab
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteExpense(int index) async {
    final financeProvider = context.read<FinanceProvider>();
    await financeProvider.deleteExpense(index);
  }

  void _editExpense(int index) {
    final financeProvider = context.read<FinanceProvider>();
    final expense = financeProvider.expenses[index];

    // Open AddExpenseSheet in edit mode
    showAddExpenseSheet(
      context,
      exchangeRates: widget.exchangeRates,
      existingExpense: expense,
      onExpenseUpdated: (updatedExpense) async {
        await financeProvider.updateExpense(index, updatedExpense);
        _streakWidgetKey.currentState?.refresh();
        widget.onStreakUpdated?.call();
      },
    );
  }

  Future<void> _updateDecision(int index, ExpenseDecision decision) async {
    final financeProvider = context.read<FinanceProvider>();
    await financeProvider.updateExpenseDecision(index, decision);

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          decision == ExpenseDecision.yes
              ? l10n.decisionUpdatedBought
              : l10n.moneySavedInPocket,
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFullHistory(List<Expense> allExpenses) {
    final l10n = AppLocalizations.of(context);
    final isPro = context.read<ProProvider>().isPro;

    // Free: 30, Pro: all
    final visibleExpenses = isPro ? allExpenses : allExpenses.take(30).toList();
    final hasMoreLocked = !isPro && allExpenses.length > 30;
    final totalCount = allExpenses.length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: context.appColors.gradientMid,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: context.appColors.textPrimary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.appColors.textTertiary.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.expenseHistory,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: context.appColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isPro
                                    ? l10n.recordCount(totalCount)
                                    : l10n.recordCountLimited(
                                        visibleExpenses.length,
                                        totalCount,
                                      ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.appColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            tooltip: l10n.close,
                            icon: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: context.appColors.surfaceLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.xmark,
                                size: 20,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Expense list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount:
                            visibleExpenses.length + (hasMoreLocked ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Pro upsell at end
                          if (hasMoreLocked &&
                              index == visibleExpenses.length) {
                            return _buildProUpsell(
                              l10n,
                              totalCount - visibleExpenses.length,
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExpenseHistoryCard(
                              expense: visibleExpenses[index],
                              dailyWorkHours: widget.userProfile.dailyHours,
                              onDelete: () async {
                                await _deleteExpense(index);
                                if (context.mounted) Navigator.pop(context);
                              },
                              onEdit: () {
                                Navigator.pop(context);
                                _editExpense(index);
                              },
                              onDecisionUpdate: (decision) async {
                                await _updateDecision(index, decision);
                                if (context.mounted) Navigator.pop(context);
                              },
                              showHint: false,
                            ),
                          );
                        },
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

  Widget _buildProUpsell(AppLocalizations l10n, int lockedCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, top: 8),
      child: lg.GlassCard(
        shape: const lg.LiquidRoundedSuperellipse(borderRadius: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.appColors.primary.withValues(alpha: 0.15),
                context.appColors.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              lg.GlassContainer(
                width: 56,
                height: 56,
                shape: const lg.LiquidOval(),
                child: Icon(
                  CupertinoIcons.star_fill,
                  size: 28,
                  color: context.appColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.unlockFullHistory,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.proHistoryDescription(lockedCount),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              lg.GlassButton.custom(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showPaywall();
                },
                width: 180,
                height: 48,
                shape: const lg.LiquidRoundedSuperellipse(borderRadius: 16),
                child: Text(
                  l10n.upgradeToPro,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaywallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = context.watch<FinanceProvider>();
    final budgetService = context.watch<BudgetService>();
    final expenses = financeProvider.expenses;
    final stats = financeProvider.stats;
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    // Recent expenses: only show last 5
    final recentExpenses = expenses.take(_recentExpensesLimit).toList();
    final hasMoreExpenses = expenses.length > _recentExpensesLimit;

    return Scaffold(
      backgroundColor: colors.background,
      body: lg.LiquidGlassLayer(
        settings: lg.LiquidGlassSettings(
          thickness: 0.8,
          blur: 15.0,
          refractiveIndex: 1.4,
          glassColor: Colors.white.withValues(alpha: 0.08),
          lightAngle: 135.0,
          lightIntensity: 0.7,
          ambientStrength: 0.25,
          saturation: 1.1,
          chromaticAberration: 0.001,
        ),
        child: Container(
          decoration: BoxDecoration(gradient: colors.backgroundGradient),
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Premium Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Avatar + Calendar + Streak
                      Row(
                        children: [
                          // Avatar
                          _buildAvatarButton(context),
                          const Spacer(),
                          // Calendar button
                          Showcase(
                            key: TourKeys.subscriptionButton,
                            title: l10n.subscriptions,
                            description: l10n.subscriptionsDescription,
                            titleTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.appColors.textPrimary,
                              fontSize: 16,
                            ),
                            descTextStyle: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 14,
                            ),
                            tooltipBackgroundColor: context.appColors.surface,
                            overlayColor: Colors.black,
                            overlayOpacity: 0.95,
                            targetBorderRadius: BorderRadius.circular(16),
                            child: _buildHeaderAction(
                              icon: CupertinoIcons.calendar,
                              badge: _upcomingSubscriptionCount > 0
                                  ? _upcomingSubscriptionCount
                                  : null,
                              onTap: _showSubscriptionSheet,
                              semanticLabel: l10n.subscriptions,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Streak widget
                          Showcase(
                            key: TourKeys.streakWidget,
                            title: l10n.streakTracking,
                            description: l10n.streakTrackingDescription,
                            titleTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.appColors.textPrimary,
                              fontSize: 16,
                            ),
                            descTextStyle: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 14,
                            ),
                            tooltipBackgroundColor: context.appColors.surface,
                            overlayColor: Colors.black,
                            overlayOpacity: 0.95,
                            targetBorderRadius: BorderRadius.circular(16),
                            child: StreakWidget(key: _streakWidgetKey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Greeting
                      Text(
                        '${_getGreeting(l10n)} 👋',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Finansal Durum title - on its own line to prevent truncation
                      GestureDetector(
                        onTap: () => ProfileModal.show(context),
                        child: Text(
                          l10n.financialStatus,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Post-onboarding prompt cards (Login, Additional Income, Checklist)
              if (_buildPromptCard() != null)
                SliverToBoxAdapter(child: _buildPromptCard()!),

              // Renewal Warning Banner
              SliverToBoxAdapter(
                child: RenewalWarningBanner(
                  withinHours: 48,
                  onTap: _showSubscriptionSheet,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Habit Calculator Banner
              SliverToBoxAdapter(child: _buildHabitCalculatorBanner()),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Category Budget Warning Banner
              SliverToBoxAdapter(child: _buildBudgetWarningBanner()),

              // Financial Snapshot Card
              SliverToBoxAdapter(
                child: Showcase(
                  key: TourKeys.financialSnapshot,
                  title: l10n.financialSummary,
                  description: l10n.financialSummaryDescription,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textPrimary,
                    fontSize: 16,
                  ),
                  descTextStyle: TextStyle(
                    color: context.appColors.textSecondary,
                    fontSize: 14,
                  ),
                  tooltipBackgroundColor: context.appColors.surface,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.95,
                  targetBorderRadius: BorderRadius.circular(24),
                  child: FinancialSnapshotCard(
                    totalIncome: financeProvider.totalMonthlyIncome,
                    totalSpent: stats.yesTotal,
                    savedAmount: stats.totalSaved,
                    savedCount: stats.noCount + stats.smartChoiceCount,
                    incomeSourceCount: financeProvider.incomeSourceCount,
                    // Budget-based parameters
                    availableBudget: budgetService.availableBudget,
                    discretionarySpent: budgetService.discretionaryExpenses,
                    mandatorySpent: budgetService.mandatoryExpenses,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Currency Rates - moved right after Financial Snapshot
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Showcase(
                    key: TourKeys.currencyRates,
                    title: l10n.currencyRates,
                    description: l10n.currencyRatesDescription,
                    titleTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.appColors.textPrimary,
                      fontSize: 16,
                    ),
                    descTextStyle: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 14,
                    ),
                    tooltipBackgroundColor: context.appColors.surface,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.95,
                    targetBorderRadius: BorderRadius.circular(16),
                    child: CurrencyRateWidget(
                      rates: widget.exchangeRates,
                      isLoading: widget.isLoadingRates,
                      hasError: widget.hasRateError,
                      onRetry: widget.onRetryRates,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Budget Breakdown Card
              SliverToBoxAdapter(
                child: BudgetBreakdownCard(budgetService: budgetService),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Installment Summary Card
              SliverToBoxAdapter(
                child: InstallmentSummaryCard(budgetService: budgetService),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Recent Expenses Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryButton,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.recentExpenses,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (hasMoreExpenses)
                        Semantics(
                          label: l10n.seeMore,
                          button: true,
                          child: GestureDetector(
                            onTap: () => _showFullHistory(expenses),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: context.appColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: context.appColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.seeMore,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: context.appColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 14,
                                    color: context.appColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Recent Expenses List (max 5) or Empty State
              recentExpenses.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildEmptyState(l10n),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return ExpenseHistoryCard(
                                expense: recentExpenses[index],
                                dailyWorkHours: widget.userProfile.dailyHours,
                                onDelete: () => _deleteExpense(index),
                                onEdit: () => _editExpense(index),
                                onDecisionUpdate: (decision) =>
                                    _updateDecision(index, decision),
                                showHint: _showSwipeHint && index == 0,
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: (index * 100).ms)
                              .slideX(
                                begin: 0.2,
                                end: 0,
                                duration: 300.ms,
                                delay: (index * 100).ms,
                                curve: Curves.easeOutCubic,
                              );
                        }, childCount: recentExpenses.length),
                      ),
                    ),

              // Bottom padding for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return lg.GlassCard(
      shape: const lg.LiquidRoundedSuperellipse(borderRadius: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            lg.GlassContainer(
              width: 72,
              height: 72,
              shape: const lg.LiquidRoundedSuperellipse(borderRadius: 24),
              child: Icon(
                CupertinoIcons.doc_text,
                size: 32,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noExpenses,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tapPlusToAdd,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
