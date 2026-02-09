
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_typography.dart';
import '../models/models.dart';
import '../providers/currency_provider.dart';
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
    // Animated glow effect - subtle breathing
    _glowController = AnimationController(
      vsync: this,
      duration: VantAnimation.breathing,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: VantAnimation.glowMin,
      end: VantAnimation.glowMax,
    ).animate(
      CurvedAnimation(parent: _glowController, curve: VantAnimation.curveSmooth),
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
            borderRadius: BorderRadius.circular(VantRadius.xxl + 4),
            boxShadow: [
              // Animated outer glow
              BoxShadow(
                color: VantColors.primary.withValues(
                  alpha: _glowAnimation.value,
                ),
                blurRadius: VantBlur.heavy,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              // Deep shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: VantBlur.mediumHeavy,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(VantRadius.xxl + 4),
                  // Premium gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      VantColors.primary.withValues(alpha: 0.35),
                      VantColors.primaryDark.withValues(alpha: 0.25),
                      context.vantColors.surfaceOverlay.withValues(alpha: 0.4),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  // Glass border with highlight
                  border: Border.all(
                    color: VantColors.glassHighlight,
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
                            top: Radius.circular(VantRadius.xxl + 4),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x25FFFFFF),
                              Colors.transparent,
                            ],
                          ),
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
        );
      },
    );
  }

  Widget _buildHeroTimeDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final timeDisplay = getSimulationTimeDisplay(
      widget.result.hoursRequired,
      workHoursPerDay: widget.dailyHours,
      workDaysPerWeek: widget.workDaysPerWeek,
      hourUnit: l10n.hourLabel,
      dayUnit: l10n.dayLabel,
      yearUnit: l10n.yearLabel,
      locale: locale,
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
          margin: const EdgeInsets.symmetric(horizontal: VantSpacing.xxl + 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                VantColors.textPrimary.withValues(alpha: 0.0),
                VantColors.textPrimary.withValues(alpha: 0.3),
                VantColors.textPrimary.withValues(alpha: 0.0),
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
        ? VantColors.primary
        : VantColors.secondaryDark;

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
        const SizedBox(height: VantSpacing.md + 2),
        // Value - Premium tabular numbers
        Text(
          value,
          style: VantTypography.displayMedium.copyWith(
            fontSize: 42,
            shadows: VantShadows.iconHalo(iconColor),
          ),
        ),
        const SizedBox(height: VantSpacing.sm - 2),
        // Unit label
        Text(
          unit.toUpperCase(),
          style: VantTypography.labelSmall.copyWith(
            color: VantColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VantSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: VantSpacing.xl,
          vertical: VantSpacing.lg,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              VantColors.primaryMuted,
              VantColors.secondarySubtle,
            ],
          ),
          borderRadius: BorderRadius.circular(VantRadius.lg),
          border: Border.all(
            color: VantColors.glassBorder,
          ),
        ),
        child: Text(
          widget.emotionalMessage!,
          textAlign: TextAlign.center,
          style: VantTypography.bodyMedium.copyWith(
            fontStyle: FontStyle.italic,
            color: VantColors.textPrimary.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String insight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VantSpacing.lg),
      decoration: BoxDecoration(
        color: VantColors.glassWhite,
        borderRadius: BorderRadius.circular(VantRadius.lg),
        border: Border.all(
          color: VantColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  VantColors.warning.withValues(alpha: 0.12),
                  VantColors.warning.withValues(alpha: 0.036),
                ],
              ),
              borderRadius: BorderRadius.circular(VantRadius.md),
            ),
            child: const Icon(
              CupertinoIcons.lightbulb_fill,
              size: 20,
              color: VantColors.warning,
            ),
          ),
          const SizedBox(width: VantSpacing.md + 2),
          Expanded(
            child: Text(
              insight,
              style: VantTypography.bodySmall.copyWith(
                color: VantColors.textPrimary.withValues(alpha: 0.8),
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
        horizontal: VantSpacing.lg,
        vertical: VantSpacing.md + 2,
      ),
      decoration: BoxDecoration(
        color: VantColors.infoSubtle,
        borderRadius: BorderRadius.circular(VantRadius.md + 2),
        border: Border.all(
          color: VantColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.chart_bar_fill,
            size: 18,
            color: VantColors.info,
          ),
          const SizedBox(width: VantSpacing.md),
          Expanded(
            child: Text(
              widget.categoryInsight!,
              style: VantTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: VantColors.info,
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
      padding: const EdgeInsets.all(VantSpacing.lg),
      decoration: BoxDecoration(
        color: VantColors.glassWhite,
        borderRadius: BorderRadius.circular(VantRadius.lg),
        border: Border.all(
          color: VantColors.glassBorder,
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
                color: VantColors.textTertiary,
              ),
              const SizedBox(width: VantSpacing.sm),
              Expanded(
                child: Text(
                  l10n.withThisAmountYouCouldBuy(
                    _formatCurrency(widget.amount!, decimals: 2),
                  ),
                  style: VantTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: VantColors.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: VantSpacing.md + 2),
          Wrap(
            spacing: VantSpacing.xl,
            runSpacing: VantSpacing.sm + 2,
            children: [
              _buildCurrencyChip(
                icon: CupertinoIcons.money_dollar,
                value: '${_formatCurrency(usdAmount)} USD',
                color: VantColors.success,
              ),
              _buildCurrencyChip(
                icon: CupertinoIcons.money_euro,
                value: '${_formatCurrency(eurAmount)} EUR',
                color: VantColors.info,
              ),
              _buildCurrencyChip(
                icon: CupertinoIcons.circle_fill,
                value: context.read<CurrencyProvider>().currency.goldUnit == 'oz'
                    ? l10n.goldOunces((goldGrams / 31.1035).toStringAsFixed(2))
                    : l10n.goldGrams(_formatCurrency(goldGrams, decimals: 1)),
                color: VantColors.warning,
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
        const SizedBox(width: VantSpacing.sm - 2),
        Text(
          value,
          style: VantTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: VantColors.textPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
