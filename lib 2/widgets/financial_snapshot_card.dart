import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../core/theme/psychology_design_system.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart' hide GlassCard;
import '../core/theme/premium_effects.dart';
import '../utils/currency_utils.dart';

/// Premium Financial Snapshot Card
/// Revolut-style clean design, mirror layout for income/expense
class FinancialSnapshotCard extends StatefulWidget {
  final double totalIncome;
  final double totalSpent;
  final double savedAmount;
  final int savedCount;
  final int incomeSourceCount;
  final VoidCallback? onTap;

  // Budget-based parameters (optional)
  final double? availableBudget; // Discretionary budget after mandatory
  final double? discretionarySpent; // Only discretionary expenses
  final double? mandatorySpent; // Mandatory expenses total

  const FinancialSnapshotCard({
    super.key,
    required this.totalIncome,
    required this.totalSpent,
    required this.savedAmount,
    this.savedCount = 0,
    this.incomeSourceCount = 1,
    this.onTap,
    this.availableBudget,
    this.discretionarySpent,
    this.mandatorySpent,
  });

  @override
  State<FinancialSnapshotCard> createState() => _FinancialSnapshotCardState();
}

class _FinancialSnapshotCardState extends State<FinancialSnapshotCard>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<double> _countAnimation;

  // iOS 26 Liquid Glass: Animated breathing glow
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  double _previousNetBalance = 0;
  double _previousIncome = 0;
  double _previousSpent = 0;

  double get netBalance => widget.totalIncome - widget.totalSpent;

  // Budget-based progress calculation
  bool get _hasBudgetData =>
      widget.availableBudget != null && widget.discretionarySpent != null;

  /// Progress bar için harcama yüzdesi
  /// Budget varsa: discretionarySpent / availableBudget
  /// Yoksa: totalSpent / totalIncome
  double get spentPercent {
    if (_hasBudgetData && widget.availableBudget! > 0) {
      return (widget.discretionarySpent! / widget.availableBudget! * 100).clamp(
        0,
        150,
      );
    }
    return widget.totalIncome > 0
        ? (widget.totalSpent / widget.totalIncome * 100).clamp(0, 100)
        : 0;
  }

  double get remainingPercent => (100 - spentPercent).clamp(0, 100);

  bool get isHealthy => netBalance >= 0;

  @override
  void initState() {
    super.initState();
    // Psychology-based 800ms count-up animation
    _countController = AnimationController(
      duration: PsychologyAnimations.countUp,
      vsync: this,
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: PsychologyAnimations.standardCurve,
    );
    _countController.forward();

    // Psychology-based breathing glow effect (3s cycle)
    _glowController = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.breathingCycle,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: PsychologyAnimations.glowMin + 0.15, // Enhanced for hero card
      end: PsychologyAnimations.glowMax + 0.15,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: PsychologyAnimations.smooth,
    ));
  }

  @override
  void didUpdateWidget(FinancialSnapshotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalIncome != widget.totalIncome ||
        oldWidget.totalSpent != widget.totalSpent) {
      _previousNetBalance = oldWidget.totalIncome - oldWidget.totalSpent;
      _previousIncome = oldWidget.totalIncome;
      _previousSpent = oldWidget.totalSpent;
      _countController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  double _lerp(double begin, double end, double t) {
    return begin + (end - begin) * t;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();

    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (context, child) {
        final animatedNetBalance = _lerp(
          _previousNetBalance,
          netBalance,
          _countAnimation.value,
        );
        final animatedIncome = _lerp(
          _previousIncome,
          widget.totalIncome,
          _countAnimation.value,
        );
        final animatedSpent = _lerp(
          _previousSpent,
          widget.totalSpent,
          _countAnimation.value,
        );
        final animatedRemaining = widget.totalIncome > 0
            ? ((animatedIncome - animatedSpent) / animatedIncome * 100).clamp(
                0.0,
                100.0,
              )
            : 100.0;

        // Accessibility: Semantic label for screen readers
        final semanticLabel = l10n.accessibilitySpendingProgress(
          spentPercent.toInt(),
        );

        return Semantics(
          label: semanticLabel,
          button: widget.onTap != null,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // iOS 26 Liquid Glass: Animated outer glow container
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(PsychologyRadius.xxl + 4),
                      boxShadow: [
                        // Animated breathing glow with psychology primary
                        BoxShadow(
                          color: PsychologyColors.primary.withValues(
                            alpha: _glowAnimation.value,
                          ),
                          blurRadius: 40,
                          spreadRadius: -4,
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
                        // iOS 26: Enhanced 30σ blur
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(PsychologyRadius.xxl + 4),
                            // Psychology-based glass gradient
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
                              color: Colors.white.withValues(
                                alpha: PsychologyGlass.highlightOpacity + 0.05,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // iOS 26: Top highlight for glass light refraction
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 60,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.12),
                                        Colors.white.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Content
                              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Label + Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isHealthy
                                    ? context.appColors.success
                                    : context.appColors.error,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isHealthy
                                                ? context.appColors.success
                                                : context.appColors.error)
                                            .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.netBalance.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (widget.incomeSourceCount > 0)
                          ShimmerEffect(
                            duration: const Duration(milliseconds: 3000),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: context.appColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.appColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.creditcard_fill,
                                    size: 14,
                                    color: context.appColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.sources(widget.incomeSourceCount),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: context.appColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ), // Design System: section spacing
                    // Big Balance Number with BreatheGlow - HERO ELEMENT
                    BreatheGlow(
                      glowColor: PremiumColors.purple,
                      blurRadius: 48, // Enhanced glow
                      minOpacity: 0.3,
                      maxOpacity: 0.6,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Design System: fontSize 52, w700, letterSpacing -1, Space Grotesk
                          // FittedBox ensures text scales down if needed
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                formatTurkishCurrency(
                                  currencyProvider.convertFromTRY(
                                    animatedNetBalance.abs(),
                                  ),
                                  decimalDigits: 0,
                                  showDecimals: false,
                                ),
                                style:
                                    AccessibleText.scaled(
                                      context,
                                      fontSize: 52,
                                      fontWeight: FontWeight.w700,
                                      maxScale:
                                          1.2, // Limit scale for hero numbers
                                    ).copyWith(
                                      fontFamily:
                                          AppFonts.heading, // Space Grotesk
                                      letterSpacing: -1,
                                      color: isHealthy
                                          ? Colors.white
                                          : context.appColors.error,
                                      height: 1,
                                      shadows: [
                                        Shadow(
                                          color:
                                              (isHealthy
                                                      ? PremiumColors.purple
                                                      : context.appColors.error)
                                                  .withValues(alpha: 0.4),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              currencyProvider.symbol,
                              style: AccessibleText.scaled(
                                context,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: context.appColors.textSecondary
                                    .withValues(alpha: 0.8),
                                maxScale: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Percentage badge - with glow effect
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isHealthy
                                        ? context.appColors.success
                                        : context.appColors.error)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  (isHealthy
                                          ? context.appColors.success
                                          : context.appColors.error)
                                      .withValues(alpha: 0.25),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isHealthy
                                            ? context.appColors.success
                                            : context.appColors.error)
                                        .withValues(alpha: 0.2),
                                blurRadius: 16,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isHealthy
                                    ? CupertinoIcons.arrow_up_right
                                    : CupertinoIcons.arrow_down_right,
                                size: 18,
                                color: isHealthy
                                    ? context.appColors.success
                                    : context.appColors.error,
                                shadows: PremiumShadows.iconHalo(
                                  isHealthy
                                      ? context.appColors.success
                                      : context.appColors.error,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${animatedRemaining.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: isHealthy
                                      ? context.appColors.success
                                      : context.appColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ), // Design System: section spacing
                    // Progress Bar with LevelProgressBar
                    _buildProgressBar(l10n, currencyProvider),

                    const SizedBox(
                      height: 24,
                    ), // Design System: section spacing
                    // Income / Expense - Mirror Layout with GradientBorder
                                _buildIncomeExpenseRow(
                                  l10n,
                                  animatedIncome,
                                  animatedSpent,
                                  currencyProvider,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildProgressBar(
    AppLocalizations l10n,
    CurrencyProvider currencyProvider,
  ) {
    // Budget-based values when available
    final double displaySpent;
    final double displayBudget;

    if (_hasBudgetData) {
      displaySpent = currencyProvider.convertFromTRY(
        widget.discretionarySpent!,
      );
      displayBudget = currencyProvider.convertFromTRY(widget.availableBudget!);
    } else {
      displaySpent = currencyProvider.convertFromTRY(widget.totalSpent);
      displayBudget = currencyProvider.convertFromTRY(widget.totalIncome);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.budgetUsage.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: context.appColors.textTertiary,
              ),
            ),
            // Percentage badge with shimmer
            ShimmerEffect(
              duration: const Duration(milliseconds: 2500),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumColors.purple.withValues(alpha: 0.3),
                      PremiumColors.gradientEnd.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: PremiumColors.purple.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${spentPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Premium Level Progress Bar
        LevelProgressBar(
          progress: (spentPercent / 100).clamp(0.0, 1.0),
          height: 10,
          showShimmer: true,
        ),
        const SizedBox(height: 10),
        // Budget numbers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatTurkishCurrency(
                displaySpent,
                decimalDigits: 0,
                showDecimals: false,
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.appColors.textSecondary,
              ),
            ),
            Text(
              formatTurkishCurrency(
                displayBudget,
                decimalDigits: 0,
                showDecimals: false,
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.appColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseRow(
    AppLocalizations l10n,
    double income,
    double spent,
    CurrencyProvider currencyProvider,
  ) {
    final incomeConverted = currencyProvider.convertFromTRY(income);
    final spentConverted = currencyProvider.convertFromTRY(spent);

    // Symmetric layout constants
    const double iconSize = 48;
    const double iconBorderRadius = 14;
    const double iconInnerSize = 24;
    const double labelFontSize = 12;
    const double amountFontSize = 28;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive font size for very small screens
        final responsiveAmountSize = constraints.maxWidth < 300
            ? 22.0
            : amountFontSize;

        return GradientBorder(
          borderWidth: 1.5,
          borderRadius: 20, // Design System: consistent border radius
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.2),
              PremiumColors.purple.withValues(alpha: 0.5),
              Colors.white.withValues(alpha: 0.15),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20), // Design System: 20px padding
            child: Row(
              children: [
                // Income - Sol taraf (Label → Arrow → Amount vertical layout)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Label on top
                      Text(
                        l10n.income.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: context.appColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Arrow icon in middle
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: context.appColors.success.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(iconBorderRadius),
                          boxShadow: PremiumShadows.coloredGlow(
                            context.appColors.success,
                            intensity: 0.6,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_down,
                          size: iconInnerSize,
                          color: context.appColors.success,
                          shadows: PremiumShadows.iconHalo(
                            context.appColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Amount at bottom
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatTurkishCurrency(
                            incomeConverted,
                            decimalDigits: 0,
                            showDecimals: false,
                          ),
                          style: TextStyle(
                            fontSize: responsiveAmountSize,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: context.appColors.success.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dikey Divider - subtle gradient
                Container(
                  width: 1,
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),

                // Expense - Sağ taraf (Label → Arrow → Amount vertical layout)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Label on top
                      Text(
                        l10n.expense.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: context.appColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Arrow icon in middle
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: context.appColors.error.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(iconBorderRadius),
                          boxShadow: PremiumShadows.coloredGlow(
                            context.appColors.error,
                            intensity: 0.6,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_up,
                          size: iconInnerSize,
                          color: context.appColors.error,
                          shadows: PremiumShadows.iconHalo(
                            context.appColors.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Amount at bottom
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatTurkishCurrency(
                            spentConverted,
                            decimalDigits: 0,
                            showDecimals: false,
                          ),
                          style: TextStyle(
                            fontSize: responsiveAmountSize,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: context.appColors.error.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
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
}

/// Kompakt Financial Snapshot - Header'da kullanım için
class CompactFinancialBadge extends StatelessWidget {
  final double netBalance;
  final double spentPercent;
  final VoidCallback? onTap;

  const CompactFinancialBadge({
    super.key,
    required this.netBalance,
    required this.spentPercent,
    this.onTap,
  });

  bool get isHealthy => netBalance >= 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            // Subtle glow
            BoxShadow(
              color: (isHealthy
                      ? context.appColors.success
                      : context.appColors.error)
                  .withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            // iOS 26: Enhanced blur
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                // iOS 26 Liquid Glass gradient
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isHealthy
                          ? context.appColors.success
                          : context.appColors.error)
                      .withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isHealthy
                        ? context.appColors.success
                        : context.appColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatTurkishCurrency(
                    netBalance.abs(),
                    decimalDigits: 0,
                    showDecimals: false,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getPercentColor(context).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${spentPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getPercentColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Color _getPercentColor(BuildContext context) {
    if (spentPercent < 50) return context.appColors.success;
    if (spentPercent < 75) return context.appColors.warning;
    return context.appColors.error;
  }
}
