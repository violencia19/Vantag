import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
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
    // Animated glow effect - subtle breathing
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
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
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              // Animated outer glow
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(
                  alpha: _glowAnimation.value,
                ),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              // Deep shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  // Premium glass gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                      const Color(0xFF7C3AED).withValues(alpha: 0.25),
                      const Color(0xFF1E1B4B).withValues(alpha: 0.4),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  // Glass border with highlight
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
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
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.0),
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
          margin: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.0),
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
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF06B6D4);

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
        const SizedBox(height: 14),
        // Value - Premium tabular numbers
        Text(
          value,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -2,
            height: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: [
              Shadow(
                color: iconColor.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Unit label
        Text(
          unit.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              const Color(0xFF06B6D4).withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          widget.emotionalMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String insight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
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
                colors: [
                  const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  const Color(0xFFF59E0B).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.lightbulb_fill,
              size: 20,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.chart_bar_fill,
            size: 18,
            color: Color(0xFF3B82F6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.categoryInsight!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3B82F6),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
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
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.withThisAmountYouCouldBuy(
                    _formatCurrency(widget.amount!, decimals: 2),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _buildCurrencyChip(
                icon: CupertinoIcons.money_dollar,
                value: '${_formatCurrency(usdAmount)} USD',
                color: const Color(0xFF10B981),
              ),
              _buildCurrencyChip(
                icon: CupertinoIcons.money_euro,
                value: '${_formatCurrency(eurAmount)} EUR',
                color: const Color(0xFF3B82F6),
              ),
              _buildCurrencyChip(
                icon: CupertinoIcons.circle_fill,
                value: l10n.goldGrams(_formatCurrency(goldGrams, decimals: 1)),
                color: const Color(0xFFF59E0B),
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
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
