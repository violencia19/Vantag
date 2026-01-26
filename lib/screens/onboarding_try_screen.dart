import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
      backgroundColor: context.appColors.background,
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
              gradient: AppGradients.primaryButton,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.appColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              PhosphorIconsDuotone.target,
              size: 40,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            l10n.onboardingTryTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            l10n.onboardingTrySubtitle,
            style: TextStyle(
              fontSize: 16,
              color: context.appColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Amount Input Card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.appColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.appColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.amount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.textSecondary,
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
                        color: context.appColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textTertiary,
                        ),
                        prefixText: '${currencyProvider.symbol} ',
                        prefixStyle: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
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
            ),
          ),
          const Spacer(),

          // Calculate Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.primaryButton,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.primary.withValues(alpha: 0.3),
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
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(PhosphorIconsDuotone.calculator, size: 24),
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
                color: context.appColors.textTertiary,
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
                color: context.appColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.appColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIconsDuotone.lightbulb,
                      size: 20,
                      color: context.appColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.onboardingTryDisclaimer,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.textSecondary,
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
                      PhosphorIconsDuotone.notepad,
                      size: 20,
                      color: context.appColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.onboardingTryNotSaved,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.textSecondary,
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
                gradient: AppGradients.primaryButton,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.primary.withValues(alpha: 0.3),
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
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(PhosphorIconsDuotone.arrowRight, size: 24),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.appColors.primary.withValues(alpha: 0.2),
                context.appColors.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.appColors.primary.withValues(alpha: 0.3),
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
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '=',
                style: TextStyle(
                  fontSize: 24,
                  color: context.appColors.textTertiary,
                ),
              ),
              const SizedBox(height: 8),

              // Hours
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsDuotone.clock,
                    size: 32,
                    color: context.appColors.warning,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_hoursRequired.toStringAsFixed(1)} ${l10n.hourAbbreviation}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '≈ ${_daysRequired.toStringAsFixed(1)} ${l10n.workDays}',
                style: TextStyle(
                  fontSize: 16,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
