import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';
import 'screens.dart';

/// New 3-step onboarding flow
/// Step 1: Value Demo (show value before signup)
/// Step 2: Setup (income + hours + days in single screen)
/// Step 3: First Action (first expense with Aha Moment)
class OnboardingV2Screen extends StatefulWidget {
  const OnboardingV2Screen({super.key});

  @override
  State<OnboardingV2Screen> createState() => _OnboardingV2ScreenState();
}

class _OnboardingV2ScreenState extends State<OnboardingV2Screen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 2: Setup data
  final _incomeController = TextEditingController();
  double _dailyHours = 8;
  int _workDaysPerWeek = 5;

  // Currency selection for onboarding
  late Currency _selectedCurrency;
  late Currency _defaultCurrency;
  bool _currencyInitialized = false;

  // Step 3: First expense data
  final _expenseAmountController = TextEditingController();
  final _expenseDescController = TextEditingController();
  bool _showResult = false;
  double _hoursRequired = 0;
  int _minutesRequired = 0;

  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late ConfettiController _confettiController;

  // Demo animation for step 1
  late AnimationController _demoAnimController;
  late Animation<double> _demoCountAnimation;

  // Analytics tracking
  final DateTime _startTime = DateTime.now();
  DateTime? _stepStartTime;
  static const _stepNames = ['value_demo', 'setup', 'first_action'];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _trackOnboardingStarted();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_currencyInitialized) {
      _defaultCurrency = getDefaultCurrencyForLocale(
        Localizations.localeOf(context).languageCode,
      );
      _selectedCurrency = _defaultCurrency;
      _currencyInitialized = true;
    }
  }

  void _trackOnboardingStarted() {
    _stepStartTime = DateTime.now();
    AnalyticsService().logOnboardingV2Started();
    AnalyticsService().logOnboardingV2StepViewed(step: 0, stepName: _stepNames[0]);
  }

  void _initAnimations() {
    // Pulse animation for result
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Demo counter animation
    _demoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _demoCountAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _demoAnimController, curve: Curves.easeOutCubic),
    );

    // Start demo animation after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _demoAnimController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    _expenseAmountController.dispose();
    _expenseDescController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _demoAnimController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int page) {
    // Track previous step completion
    if (_stepStartTime != null && _currentStep < _stepNames.length) {
      final timeSpent = DateTime.now().difference(_stepStartTime!).inSeconds;
      AnalyticsService().logOnboardingV2StepCompleted(
        step: _currentStep,
        stepName: _stepNames[_currentStep],
        timeSpentSeconds: timeSpent,
      );
    }

    setState(() {
      _currentStep = page;
    });

    // Track new step viewed
    _stepStartTime = DateTime.now();
    if (page < _stepNames.length) {
      AnalyticsService().logOnboardingV2StepViewed(step: page, stepName: _stepNames[page]);
    }
  }

  Future<void> _completeSetup() async {
    // Validate income
    final income = parseTurkishCurrency(_incomeController.text);
    if (income == null || income <= 0) {
      _showError(AppLocalizations.of(context).pleaseEnterIncome);
      return;
    }

    HapticFeedback.mediumImpact();

    // Set currency provider to selected currency
    await context.read<CurrencyProvider>().setCurrency(_selectedCurrency);

    // Create profile with income source
    final profile = UserProfile(
      dailyHours: _dailyHours,
      workDaysPerWeek: _workDaysPerWeek,
      incomeSources: [
        IncomeSource.salary(
          amount: income,
          title: AppLocalizations.of(context).mainIncome,
          currencyCode: _selectedCurrency.code,
        ),
      ],
    );

    // Save profile
    final financeProvider = context.read<FinanceProvider>();
    financeProvider.setUserProfile(profile);
    await ProfileService().saveProfile(profile);

    // Track profile setup
    AnalyticsService().logOnboardingProfileSetup(
      monthlyIncome: income,
      workingHours: _dailyHours.toInt(),
      workingDays: _workDaysPerWeek,
    );

    // Go to step 3
    _nextStep();
  }

  void _calculateFirstExpense() {
    final amount = parseTurkishCurrency(_expenseAmountController.text);
    if (amount == null || amount <= 0) return;

    HapticFeedback.mediumImpact();

    final financeProvider = context.read<FinanceProvider>();
    final profile = financeProvider.userProfile;

    if (profile == null) return;

    final calculationService = CalculationService();
    final now = DateTime.now();
    final result = calculationService.calculateExpense(
      userProfile: profile,
      expenseAmount: amount,
      month: now.month,
      year: now.year,
    );

    setState(() {
      _hoursRequired = result.hoursRequired;
      _minutesRequired = ((result.hoursRequired % 1) * 60).round();
      _showResult = true;
    });

    // Track Aha Moment
    AnalyticsService().logOnboardingAhaMoment(
      amount: amount,
      hoursRequired: result.hoursRequired,
    );

    _pulseController.repeat(reverse: true);
  }

  Future<void> _saveFirstExpenseAndComplete() async {
    HapticFeedback.heavyImpact();
    _confettiController.play();

    final amount = parseTurkishCurrency(_expenseAmountController.text);
    if (amount == null || amount <= 0) return;

    // Save expense with calculated hours
    final financeProvider = context.read<FinanceProvider>();
    final expense = Expense(
      amount: amount,
      category: _expenseDescController.text.isEmpty
          ? AppLocalizations.of(context).categoryOther
          : _expenseDescController.text,
      date: DateTime.now(),
      hoursRequired: _hoursRequired,
      daysRequired: _hoursRequired / (_dailyHours > 0 ? _dailyHours : 8),
      decision: ExpenseDecision.yes,
    );

    await financeProvider.addExpense(expense);

    // Mark onboarding completed
    await ProfileService().setOnboardingCompleted();

    // Track analytics
    final totalTime = DateTime.now().difference(_startTime).inSeconds;
    AnalyticsService().logExpenseAdded(category: 'onboarding', method: 'manual');
    AnalyticsService().logOnboardingV2Completed(
      totalTimeSeconds: totalTime,
      addedFirstExpense: true,
    );
    AnalyticsService().logFirstExpense();
    AnalyticsService().logActivationEvent(eventType: 'first_expense', daysSinceInstall: 0);

    // Wait for confetti, then navigate
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _skipToMain() async {
    HapticFeedback.lightImpact();

    // If on step 2 or later, still need to create a default profile
    if (_currentStep >= 1) {
      // Set currency provider to selected currency
      await context.read<CurrencyProvider>().setCurrency(_selectedCurrency);

      final defaultIncome = _getDefaultIncome(_selectedCurrency.code);
      final profile = UserProfile(
        dailyHours: 8,
        workDaysPerWeek: 5,
        incomeSources: [
          IncomeSource.salary(
            amount: defaultIncome,
            title: AppLocalizations.of(context).mainIncome,
            currencyCode: _selectedCurrency.code,
          ),
        ],
      );
      final financeProvider = context.read<FinanceProvider>();
      financeProvider.setUserProfile(profile);
      await ProfileService().saveProfile(profile);
    }

    await ProfileService().setOnboardingCompleted();

    // Track skip event
    AnalyticsService().logOnboardingV2Skipped(
      lastStepViewed: _currentStep,
      skipReason: 'skip_button',
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  double _getDefaultIncome(String currencyCode) {
    switch (currencyCode) {
      case 'TRY': return 30000;
      case 'USD': return 4000;
      case 'EUR': return 3500;
      case 'GBP': return 3000;
      case 'SAR': return 15000;
      default: return 4000;
    }
  }

  String _getIncomeHint(String currencyCode) {
    switch (currencyCode) {
      case 'TRY': return '25.000';
      case 'USD': return '4,000';
      case 'EUR': return '3,500';
      case 'GBP': return '3,000';
      case 'SAR': return '15,000';
      default: return '4,000';
    }
  }

  String _getExpenseHint(String currencyCode) {
    switch (currencyCode) {
      case 'TRY': return '150';
      case 'USD': return '15';
      case 'EUR': return '12';
      case 'GBP': return '10';
      case 'SAR': return '50';
      default: return '15';
    }
  }

  void _onCurrencyChanged(Currency newCurrency) {
    final oldValue = parseTurkishCurrency(_incomeController.text);
    setState(() => _selectedCurrency = newCurrency);
    if (oldValue != null && oldValue > 0) {
      _incomeController.text = formatForCurrency(oldValue, newCurrency);
    }
  }

  void _showCurrencyPicker() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.vantColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.vantColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Text(
              l10n.settingsCurrency,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.vantColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Currency list
            ...supportedCurrencies.map((currency) {
              final isSelected = currency.code == _selectedCurrency.code;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                  _onCurrencyChanged(currency);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.vantColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(currency.flag, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currency.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.vantColors.textPrimary,
                              ),
                            ),
                            Text(
                              currency.code,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.vantColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          color: context.vantColors.primary,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              );
            }),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.vantColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.vantColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(),

                // Skip button (not on step 1)
                if (_currentStep > 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: TextButton(
                        onPressed: _skipToMain,
                        child: Text(
                          l10n.onboardingV2SkipSetup,
                          style: TextStyle(
                            color: context.vantColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1ValueDemo(l10n),
                      _buildStep2Setup(l10n),
                      _buildStep3FirstAction(l10n),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: [
                context.vantColors.primary,
                context.vantColors.accent,
                context.vantColors.success,
                context.vantColors.warning,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? context.vantColors.primary
                    : context.vantColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: context.vantColors.primary.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 1: VALUE DEMO
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStep1ValueDemo(AppLocalizations l10n) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Animated demo card
          AnimatedBuilder(
            animation: _demoCountAnimation,
            builder: (context, child) {
              final hours = _demoCountAnimation.value.toInt();
              return _buildDemoCard(currencyProvider, hours, l10n);
            },
          ),

          const SizedBox(height: 48),

          // Title (max 5 words)
          Text(
            l10n.onboardingV2Step1Title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.vantColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle (1 line)
          Text(
            l10n.onboardingV2Step1Subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: context.vantColors.textSecondary,
            ),
          ),

          const Spacer(flex: 3),

          // CTA Button (2 words max)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.vantColors.primary,
                foregroundColor: context.vantColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.onboardingV2Step1Cta,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDemoCard(
    CurrencyProvider currencyProvider,
    int hours,
    AppLocalizations l10n,
  ) {
    return VGlassCard.hero(
      glowColor: context.vantColors.primary,
      glowIntensity: 0.3,
      padding: const EdgeInsets.all(32),
      child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Phone icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.vantColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  CupertinoIcons.device_phone_portrait,
                  size: 32,
                  color: context.vantColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Amount
              Text(
                currencyProvider.format(5000),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: context.vantColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Equals sign
              Text(
                '=',
                style: TextStyle(
                  fontSize: 24,
                  color: context.vantColors.textTertiary,
                ),
              ),
              const SizedBox(height: 8),

              // Hours with animation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.clock,
                    size: 28,
                    color: context.vantColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$hours ${l10n.hourAbbreviation}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: context.vantColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.ofYourWork,
                style: TextStyle(
                  fontSize: 14,
                  color: context.vantColors.textSecondary,
                ),
              ),
            ],
          ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 2: SETUP
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStep2Setup(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Title
          Text(
            l10n.onboardingV2Step2Title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.vantColors.textPrimary,
            ),
          ),

          const SizedBox(height: 48),

          // Input 1: Monthly income
          _buildInputCard(
            label: l10n.onboardingV2Step2Income,
            child: TextField(
              controller: _incomeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: context.vantColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: _getIncomeHint(_selectedCurrency.code),
                hintStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textTertiary,
                ),
                prefixText: '${_selectedCurrency.symbol} ',
                prefixStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textPrimary,
                ),
                border: InputBorder.none,
              ),
              inputFormatters: [
                CurrencyAwareInputFormatter(currency: _selectedCurrency),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Currency selector row
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _showCurrencyPicker();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.vantColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.vantColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCurrency.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedCurrency.code,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.vantColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 14,
                        color: context.vantColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    l10n.onboardingCurrencyHint,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.vantColors.textTertiary,
                    ),
                  ),
                ),
                if (_selectedCurrency.code != _defaultCurrency.code)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Text(
                      l10n.onboardingCurrencyProInfo(_defaultCurrency.code),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vantColors.warning,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Input 2: Daily hours (Slider)
          _buildInputCard(
            label: l10n.onboardingV2Step2Hours,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_dailyHours.toInt()} ${l10n.hourAbbreviation}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textPrimary,
                      ),
                    ),
                    Text(
                      '1-12',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.vantColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: context.vantColors.primary,
                    inactiveTrackColor: context.vantColors.surfaceLight,
                    thumbColor: context.vantColors.primary,
                    overlayColor: context.vantColors.primary.withValues(alpha: 0.2),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _dailyHours,
                    min: 1,
                    max: 12,
                    divisions: 11,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _dailyHours = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Input 3: Work days per week (SegmentedControl)
          _buildInputCard(
            label: l10n.onboardingV2Step2Days,
            child: Row(
              children: [5, 6, 7].map((days) {
                final isSelected = _workDaysPerWeek == days;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _workDaysPerWeek = days;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: days < 7 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.vantColors.primary
                            : context.vantColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? context.vantColors.primary
                              : context.vantColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        '$days',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? context.vantColors.background
                              : context.vantColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 48),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _completeSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.vantColors.primary,
                foregroundColor: context.vantColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.onboardingV2Step2Cta,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({required String label, required Widget child}) {
    return VGlassStyledContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.vantColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 3: FIRST ACTION (Aha Moment)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStep3FirstAction(AppLocalizations l10n) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _showResult
          ? _buildStep3Result(l10n, currencyProvider)
          : _buildStep3Input(l10n, currencyProvider),
    );
  }

  Widget _buildStep3Input(AppLocalizations l10n, CurrencyProvider currencyProvider) {
    return SingleChildScrollView(
      key: const ValueKey('input'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.vantColors.primary,
                  context.vantColors.accent,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.doc_text,
              size: 40,
              color: context.vantColors.textPrimary,
            ),
          ),

          // Title
          Text(
            l10n.onboardingV2Step3Title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.vantColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            l10n.onboardingV2Step3Subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: context.vantColors.textSecondary,
            ),
          ),

          const SizedBox(height: 48),

          // Amount input
          _buildInputCard(
            label: l10n.amount,
            child: TextField(
              controller: _expenseAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: context.vantColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: _getExpenseHint(currencyProvider.code),
                hintStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textTertiary,
                ),
                prefixText: '${currencyProvider.symbol} ',
                prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textPrimary,
                ),
                border: InputBorder.none,
              ),
              inputFormatters: [
                CurrencyAwareInputFormatter(currency: currencyProvider.currency),
              ],
              onSubmitted: (_) => _calculateFirstExpense(),
            ),
          ),

          const SizedBox(height: 16),

          // Description input (optional)
          _buildInputCard(
            label: l10n.description,
            child: TextField(
              controller: _expenseDescController,
              style: TextStyle(
                fontSize: 18,
                color: context.vantColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: l10n.expensePlaceholder,
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: context.vantColors.textTertiary,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Calculate button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _calculateFirstExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.vantColors.primary,
                foregroundColor: context.vantColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.plus_slash_minus, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    l10n.onboardingV2Step1Cta,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Result(AppLocalizations l10n, CurrencyProvider currencyProvider) {
    final amount = parseTurkishCurrency(_expenseAmountController.text) ?? 0;

    return Padding(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Result card with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: child,
              );
            },
            child: VGlassCard.hero(
              glowColor: context.vantColors.success,
              glowIntensity: 0.3,
              padding: const EdgeInsets.all(32),
              child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Amount entered
                      Text(
                        currencyProvider.format(amount),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: context.vantColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Result
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.vantColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              size: 28,
                              color: context.vantColors.warning,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.onboardingV2Step3Result(
                                _hoursRequired.toInt(),
                                _minutesRequired,
                              ),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: context.vantColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ),
          ),

          const SizedBox(height: 32),

          // Success message
          VGlassStyledContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: 16,
            glowColor: context.vantColors.success,
            glowIntensity: 0.15,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.vantColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    CupertinoIcons.checkmark_circle,
                    size: 24,
                    color: context.vantColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.onboardingV2Step3Success,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.vantColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveFirstExpenseAndComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.vantColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.onboardingV2Step3Cta,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(CupertinoIcons.arrow_right, size: 24),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
