import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';
import 'onboarding_pursuit_screen.dart';

/// Onboarding "Aha Moment" screen
/// Shows after profile creation, before main app
/// Lets user try a sample calculation without saving
class OnboardingTryScreen extends StatefulWidget {
  const OnboardingTryScreen({super.key});

  @override
  State<OnboardingTryScreen> createState() => _OnboardingTryScreenState();
}

class _OnboardingTryScreenState extends State<OnboardingTryScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _calculationService = CalculationService();

  bool _showResult = false;
  double _hoursRequired = 0;
  double _daysRequired = 0;
  double _enteredAmount = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = parseTurkishCurrency(_amountController.text);
    if (amount == null || amount <= 0) return;

    HapticFeedback.mediumImpact();

    final financeProvider = context.read<FinanceProvider>();
    final profile = financeProvider.userProfile;

    if (profile == null) return;

    final now = DateTime.now();
    final result = _calculationService.calculateExpense(
      userProfile: profile,
      expenseAmount: amount,
      month: now.month,
      year: now.year,
    );

    setState(() {
      _enteredAmount = amount;
      _hoursRequired = result.hoursRequired;
      _daysRequired = result.daysRequired;
      _showResult = true;
    });

    // Start pulsing animation
    _pulseController.repeat(reverse: true);

    // Haptic on result
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedback.lightImpact();
    });
  }

  void _continueToApp() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingPursuitScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();

    return Scaffold(
      backgroundColor: context.vantColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _showResult
              ? _buildResultView(l10n, currencyProvider)
              : _buildInputView(l10n, currencyProvider),
        ),
      ),
    );
  }

  Widget _buildInputView(
    AppLocalizations l10n,
    CurrencyProvider currencyProvider,
  ) {
    return Padding(
      key: const ValueKey('input'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: VantGradients.primaryButton,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.vantColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.scope,
              size: 40,
              color: context.vantColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            l10n.onboardingTryTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.vantColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            l10n.onboardingTrySubtitle,
            style: TextStyle(
              fontSize: 16,
              color: context.vantColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Amount Input Card
          Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.vantColors.surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.vantColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.amount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
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
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                      onSubmitted: (_) => _calculate(),
                    ),
                  ],
                ),
              ),
          const Spacer(),

          // Calculate Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: VantGradients.primaryButton,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.vantColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.onboardingTryButton,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(CupertinoIcons.equal_square, size: 24),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Skip button
          TextButton(
            onPressed: _continueToApp,
            child: Text(
              l10n.skip,
              style: TextStyle(
                fontSize: 16,
                color: context.vantColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResultView(
    AppLocalizations l10n,
    CurrencyProvider currencyProvider,
  ) {
    return Padding(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Pulsing Result Card
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Opacity(
                  opacity:
                      0.7 + (_pulseAnimation.value - 0.98) * 15, // 0.7 to 1.0
                  child: child,
                ),
              );
            },
            child: _buildResultCard(l10n, currencyProvider),
          ),

          const SizedBox(height: 32),

          // Result Text with pulse
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: 0.7 + (_pulseAnimation.value - 0.98) * 15,
                child: child,
              );
            },
            child: Text(
              l10n.onboardingTryResult(_hoursRequired.toStringAsFixed(1)),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.vantColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.vantColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.vantColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.lightbulb_fill,
                      size: 20,
                      color: context.vantColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.onboardingTryDisclaimer,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.vantColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text_fill,
                      size: 20,
                      color: context.vantColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.onboardingTryNotSaved,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.vantColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: VantGradients.primaryButton,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.vantColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _continueToApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.onboardingContinue,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(CupertinoIcons.arrow_right, size: 24),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    AppLocalizations l10n,
    CurrencyProvider currencyProvider,
  ) {
    return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.vantColors.primary.withValues(alpha: 0.4),
                context.vantColors.secondary.withValues(alpha: 0.25),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.vantColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Amount
              Text(
                currencyProvider.format(_enteredAmount),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: context.vantColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '=',
                style: TextStyle(
                  fontSize: 24,
                  color: context.vantColors.textTertiary,
                ),
              ),
              const SizedBox(height: 8),

              // Hours
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.clock_fill,
                    size: 32,
                    color: context.vantColors.warning,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_hoursRequired.toStringAsFixed(1)} ${l10n.hourAbbreviation}',
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
                '≈ ${_daysRequired.toStringAsFixed(1)} ${l10n.workDays}',
                style: TextStyle(
                  fontSize: 16,
                  color: context.vantColors.textSecondary,
                ),
              ),
            ],
          ),
        );
  }
}
