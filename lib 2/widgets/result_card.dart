import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../core/theme/psychology_design_system.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/currency_utils.dart';

/// Premium Result Card - iOS 26 Liquid Glass Design
/// Hero component showing work hours required for an expense
/// Features: Glass morphism, animated glow, premium typography
class ResultCard extends StatefulWidget {
  final ExpenseResult result;
  final String? categoryInsight;
  final String? emotionalMessage;
  final double? amount;
  final ExchangeRates? exchangeRates;
  final String? amountCurrencyCode;
  final double dailyHours;
  final int workDaysPerWeek;

  const ResultCard({
    super.key,
    required this.result,
    this.categoryInsight,
    this.emotionalMessage,
    this.amount,
    this.exchangeRates,
    this.amountCurrencyCode,
    this.dailyHours = 8,
    this.workDaysPerWeek = 5,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Animated glow effect - subtle breathing (psychology-based timing)
    _glowController = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.breathingCycle,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: PsychologyAnimations.glowMin,
      end: PsychologyAnimations.glowMax,
    ).animate(
      CurvedAnimation(parent: _glowController, curve: PsychologyAnimations.smooth),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value, {int decimals = 2}) {
    return formatTurkishCurrency(value, decimalDigits: decimals);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insightService = InsightService();
    final insight = insightService.getExpenseInsight(context, widget.result);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PsychologyRadius.xxl + 4),
            boxShadow: [
              // Animated outer glow
              BoxShadow(
                color: PsychologyColors.primary.withValues(
                  alpha: _glowAnimation.value,
                ),
                blurRadius: PsychologyGlass.heavyBlurSigma,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              // Deep shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: PsychologyGlass.blurSigma,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PsychologyRadius.xxl + 4),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: PsychologyGlass.heroBlurSigma,
                sigmaY: PsychologyGlass.heroBlurSigma,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(PsychologyRadius.xxl + 4),
                  // Premium glass gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PsychologyColors.primary.withValues(alpha: 0.35),
                      PsychologyColors.primaryDark.withValues(alpha: 0.25),
                      PsychologyColors.surfaceOverlay.withValues(alpha: 0.4),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  // Glass border with highlight
                  border: Border.all(
                    color: PsychologyColors.glassHighlight,
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Top-left highlight (glass light refraction)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(PsychologyRadius.xxl + 4),
                          ),
                          gradient: PsychologyGlass.topHighlight,
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Hero time display
                          _buildHeroTimeDisplay(context),

                          const SizedBox(height: 24),

                          // Emotional message
                          if (widget.emotionalMessage != null)
                            _buildEmotionalMessage(context),

                          // Insight message
                          _buildInsightCard(context, insight),

                          // Category insight
                          if (widget.categoryInsight != null) ...[
                            const SizedBox(height: 12),
                            _buildCategoryInsight(context),
                          ],

                          // Currency alternatives
                          if (widget.amount != null &&
                              widget.exchangeRates != null) ...[
                            const SizedBox(height: 16),
                            _buildCurrencyAlternatives(context, l10n),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroTimeDisplay(BuildContext context) {
    final timeDisplay = getSimulationTimeDisplay(
      widget.result.hoursRequired,
      workHoursPerDay: widget.dailyHours,
      workDaysPerWeek: widget.workDaysPerWeek,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left block: Hours or Years
        _buildPremiumTimeBlock(
          context: context,
          value: timeDisplay.value1,
          unit: timeDisplay.unit1,
          icon: timeDisplay.isYearMode
              ? CupertinoIcons.calendar
              : CupertinoIcons.clock_fill,
          isPrimary: true,
        ),
        // Divider with glow
        Container(
          width: 2,
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: PsychologySpacing.xxl + 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PsychologyColors.textPrimary.withValues(alpha: 0.0),
                PsychologyColors.textPrimary.withValues(alpha: 0.3),
                PsychologyColors.textPrimary.withValues(alpha: 0.0),
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        // Right block: Days
        _buildPremiumTimeBlock(
          context: context,
          value: timeDisplay.value2,
          unit: timeDisplay.unit2,
          icon: CupertinoIcons.sun_max_fill,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildPremiumTimeBlock({
    required BuildContext context,
    required String value,
    required String unit,
    required IconData icon,
    required bool isPrimary,
  }) {
    final iconColor = isPrimary
        ? PsychologyColors.primary
        : PsychologyColors.secondary;

    return Column(
      children: [
        // Icon with glass container
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                iconColor.withValues(alpha: 0.25),
                iconColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(height: PsychologySpacing.md + 2),
        // Value - Premium tabular numbers
        Text(
          value,
          style: PsychologyTypography.displayMedium.copyWith(
            fontSize: 42,
            shadows: PsychologyShadows.iconHalo(iconColor),
          ),
        ),
        const SizedBox(height: PsychologySpacing.sm - 2),
        // Unit label
        Text(
          unit.toUpperCase(),
          style: PsychologyTypography.labelSmall.copyWith(
            color: PsychologyColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PsychologySpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: PsychologySpacing.xl,
          vertical: PsychologySpacing.lg,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PsychologyColors.primaryMuted,
              PsychologyColors.secondarySubtle,
            ],
          ),
          borderRadius: BorderRadius.circular(PsychologyRadius.lg),
          border: Border.all(
            color: PsychologyColors.glassBorder,
          ),
        ),
        child: Text(
          widget.emotionalMessage!,
          textAlign: TextAlign.center,
          style: PsychologyTypography.bodyMedium.copyWith(
            fontStyle: FontStyle.italic,
            color: PsychologyColors.textPrimary.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String insight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PsychologySpacing.lg),
      decoration: BoxDecoration(
        color: PsychologyColors.glassFill,
        borderRadius: BorderRadius.circular(PsychologyRadius.lg),
        border: Border.all(
          color: PsychologyColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: PsychologyGlass.gradient(PsychologyColors.warning),
              borderRadius: BorderRadius.circular(PsychologyRadius.md),
            ),
            child: const Icon(
              CupertinoIcons.lightbulb_fill,
              size: 20,
              color: PsychologyColors.warning,
            ),
          ),
          const SizedBox(width: PsychologySpacing.md + 2),
          Expanded(
            child: Text(
              insight,
              style: PsychologyTypography.bodySmall.copyWith(
                color: PsychologyColors.textPrimary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInsight(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: PsychologySpacing.lg,
        vertical: PsychologySpacing.md + 2,
      ),
      decoration: BoxDecoration(
        color: PsychologyColors.infoSubtle,
        borderRadius: BorderRadius.circular(PsychologyRadius.md + 2),
        border: Border.all(
          color: PsychologyColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.chart_bar_fill,
            size: 18,
            color: PsychologyColors.info,
          ),
          const SizedBox(width: PsychologySpacing.md),
          Expanded(
            child: Text(
              widget.categoryInsight!,
              style: PsychologyTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: PsychologyColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyAlternatives(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (widget.amount == null || widget.exchangeRates == null) {
      return const SizedBox.shrink();
    }

    final currencyCode = widget.amountCurrencyCode ?? 'TRY';
    double amountInTRY;

    if (currencyCode == 'TRY') {
      amountInTRY = widget.amount!;
    } else if (currencyCode == 'USD') {
      amountInTRY = widget.amount! * widget.exchangeRates!.usdRate;
    } else if (currencyCode == 'EUR') {
      amountInTRY = widget.amount! * widget.exchangeRates!.eurRate;
    } else if (currencyCode == 'GBP') {
      amountInTRY = widget.amount! * (widget.exchangeRates!.usdRate * 1.27);
    } else if (currencyCode == 'SAR') {
      amountInTRY = widget.amount! * (widget.exchangeRates!.usdRate / 3.75);
    } else {
      amountInTRY = widget.amount!;
    }

    final usdAmount = amountInTRY / widget.exchangeRates!.usdRate;
    final eurAmount = amountInTRY / widget.exchangeRates!.eurRate;
    final goldGrams = amountInTRY / widget.exchangeRates!.goldRate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PsychologySpacing.lg),
      decoration: BoxDecoration(
        color: PsychologyColors.glassFill,
        borderRadius: BorderRadius.circular(PsychologyRadius.lg),
        border: Border.all(
          color: PsychologyColors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.arrow_right_arrow_left,
                size: 14,
                color: PsychologyColors.textTertiary,
              ),
              const SizedBox(width: PsychologySpacing.sm),
              Expanded(
                child: Text(
                  l10n.withThisAmountYouCouldBuy(
                    _formatCurrency(widget.amount!, decimals: 2),
                  ),
                  style: PsychologyTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: PsychologyColors.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsychologySpacing.md + 2),
          Wrap(
            spacing: PsychologySpacing.xl,
            runSpacing: PsychologySpacing.sm + 2,
            children: [
              _buildCurrencyChip(
                icon: CupertinoIcons.money_dollar,
                value: '${_formatCurrency(usdAmount)} USD',
                color: PsychologyColors.success,
              ),
              _buildCurrencyChip(
                icon: CupertinoIcons.money_euro,
                value: '${_formatCurrency(eurAmount)} EUR',
                color: PsychologyColors.info,
              ),
              _buildCurrencyChip(
                icon: CupertinoIcons.circle_fill,
                value: l10n.goldGrams(_formatCurrency(goldGrams, decimals: 1)),
                color: PsychologyColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyChip({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: PsychologySpacing.sm - 2),
        Text(
          value,
          style: PsychologyTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: PsychologyColors.textPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
