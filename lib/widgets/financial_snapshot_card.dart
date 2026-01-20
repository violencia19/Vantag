import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart' hide GlassCard;
import '../theme/app_theme.dart' show AppFonts;
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
    with SingleTickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<double> _countAnimation;

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
      return (widget.discretionarySpent! / widget.availableBudget! * 100)
          .clamp(0, 150);
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
    // Design System: 800ms count-up animation with easeOutCubic
    _countController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );
    _countController.forward();
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
    super.dispose();
  }

  double _lerp(double begin, double end, double t) {
    return begin + (end - begin) * t;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyProvider = context.watch<CurrencyProvider>();

    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (context, child) {
        final animatedNetBalance = _lerp(_previousNetBalance, netBalance, _countAnimation.value);
        final animatedIncome = _lerp(_previousIncome, widget.totalIncome, _countAnimation.value);
        final animatedSpent = _lerp(_previousSpent, widget.totalSpent, _countAnimation.value);
        final animatedRemaining = widget.totalIncome > 0
            ? ((animatedIncome - animatedSpent) / animatedIncome * 100).clamp(0.0, 100.0)
            : 100.0;

        return GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7C3AED),  // Parlak mor - SOL ÜST
                    Color(0xFF5B21B6),  // Orta mor
                    Color(0xFF1E1B4B),  // Koyu mor - SAĞ ALT
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    blurRadius: 32,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
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
                              color: isHealthy ? AppColors.success : AppColors.error,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isHealthy ? AppColors.success : AppColors.error).withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.netBalance.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (widget.incomeSourceCount > 0)
                        ShimmerEffect(
                          duration: const Duration(milliseconds: 3000),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIconsDuotone.wallet,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.sources(widget.incomeSourceCount),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24), // Design System: section spacing

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
                        Text(
                          formatTurkishCurrency(
                            currencyProvider.convertFromTRY(animatedNetBalance.abs()),
                            decimalDigits: 0,
                            showDecimals: false,
                          ),
                          style: TextStyle(
                            fontFamily: AppFonts.heading, // Space Grotesk
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                            color: isHealthy ? Colors.white : AppColors.error,
                            height: 1,
                            shadows: [
                              Shadow(
                                color: (isHealthy ? PremiumColors.purple : AppColors.error).withOpacity(0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            currencyProvider.symbol,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary.withOpacity(0.8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: (isHealthy ? AppColors.success : AppColors.error).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (isHealthy ? AppColors.success : AppColors.error).withOpacity(0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isHealthy ? AppColors.success : AppColors.error).withOpacity(0.2),
                              blurRadius: 16,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isHealthy ? PhosphorIconsBold.trendUp : PhosphorIconsBold.trendDown,
                              size: 18,
                              color: isHealthy ? AppColors.success : AppColors.error,
                              shadows: PremiumShadows.iconHalo(
                                isHealthy ? AppColors.success : AppColors.error,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${animatedRemaining.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isHealthy ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24), // Design System: section spacing

                  // Progress Bar with LevelProgressBar
                  _buildProgressBar(l10n, currencyProvider),

                  const SizedBox(height: 24), // Design System: section spacing

                  // Income / Expense - Mirror Layout with GradientBorder
                  _buildIncomeExpenseRow(l10n, animatedIncome, animatedSpent, currencyProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(AppLocalizations l10n, CurrencyProvider currencyProvider) {
    // Budget-based values when available
    final double displaySpent;
    final double displayBudget;

    if (_hasBudgetData) {
      displaySpent = currencyProvider.convertFromTRY(widget.discretionarySpent!);
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
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.textTertiary,
              ),
            ),
            // Percentage badge with shimmer
            ShimmerEffect(
              duration: const Duration(milliseconds: 2500),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumColors.purple.withOpacity(0.3),
                      PremiumColors.gradientEnd.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: PremiumColors.purple.withOpacity(0.4),
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
              formatTurkishCurrency(displaySpent, decimalDigits: 0, showDecimals: false),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              formatTurkishCurrency(displayBudget, decimalDigits: 0, showDecimals: false),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseRow(AppLocalizations l10n, double income, double spent, CurrencyProvider currencyProvider) {
    final incomeConverted = currencyProvider.convertFromTRY(income);
    final spentConverted = currencyProvider.convertFromTRY(spent);

    return GradientBorder(
      borderWidth: 1.5,
      borderRadius: 20, // Design System: consistent border radius
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          PremiumColors.purple.withOpacity(0.5),
          Colors.white.withOpacity(0.15),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Design System: 20px padding
        child: Row(
          children: [
            // Income - Sol taraf
            Expanded(
              child: Row(
                children: [
                  // Icon with glow halo - enhanced
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: PremiumShadows.coloredGlow(AppColors.success, intensity: 0.6),
                    ),
                    child: Icon(
                      PhosphorIconsDuotone.arrowDown,
                      size: 24,
                      color: AppColors.success,
                      shadows: PremiumShadows.iconHalo(AppColors.success),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Design System: uppercase label, letterSpacing 1.2
                        Text(
                          l10n.income.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Design System: fontSize 28, bold - FittedBox for responsive
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatTurkishCurrency(incomeConverted, decimalDigits: 0, showDecimals: false),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: AppColors.success.withOpacity(0.4),
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

            // Dikey Divider - subtle gradient
            Container(
              width: 1,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),

            // Expense - Sağ taraf (MIRROR)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Design System: uppercase label, letterSpacing 1.2
                        Text(
                          l10n.expense.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Design System: fontSize 28, bold - FittedBox for responsive
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatTurkishCurrency(spentConverted, decimalDigits: 0, showDecimals: false),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: AppColors.error.withOpacity(0.4),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Icon with glow halo - enhanced
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: PremiumShadows.coloredGlow(AppColors.error, intensity: 0.6),
                    ),
                    child: Icon(
                      PhosphorIconsDuotone.arrowUp,
                      size: 24,
                      color: AppColors.error,
                      shadows: PremiumShadows.iconHalo(AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (isHealthy ? AppColors.success : AppColors.error)
                    .withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isHealthy ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatTurkishCurrency(netBalance.abs(),
                      decimalDigits: 0, showDecimals: false),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPercentColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${spentPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getPercentColor(),
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

  Color _getPercentColor() {
    if (spentPercent < 50) return AppColors.success;
    if (spentPercent < 75) return AppColors.warning;
    return AppColors.error;
  }
}