import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';
import '../services/budget_service.dart';
import '../theme/theme.dart' hide GlassCard;
import '../core/theme/premium_effects.dart';
import '../utils/currency_utils.dart';

/// Bütçe dağılımını gösteren kart
/// Zorunlu giderler vs İsteğe bağlı harcamalar
/// Premium animasyonlar: staggered slide-up, count-up, progress bar
class BudgetBreakdownCard extends StatefulWidget {
  final BudgetService budgetService;
  final int animationIndex;

  const BudgetBreakdownCard({
    super.key,
    required this.budgetService,
    this.animationIndex = 0,
  });

  @override
  State<BudgetBreakdownCard> createState() => _BudgetBreakdownCardState();
}

class _BudgetBreakdownCardState extends State<BudgetBreakdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Staggered delay based on index
    Future.delayed(Duration(milliseconds: 100 * widget.animationIndex), () {
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
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();

    final mandatory = widget.budgetService.mandatoryExpenses;
    final discretionary = widget.budgetService.discretionaryExpenses;
    final total = mandatory + discretionary;
    final mandatoryHours = widget.budgetService.mandatoryHours;
    final discretionaryHours = widget.budgetService.usedHours;

    // Hiç harcama yoksa gösterme
    if (total <= 0) return const SizedBox.shrink();

    final mandatoryPercent = total > 0 ? (mandatory / total * 100) : 0.0;
    final discretionaryPercent = total > 0
        ? (discretionary / total * 100)
        : 0.0;

    // Currency conversion
    final mandatoryConverted = currencyProvider.convertFromTRY(mandatory);
    final discretionaryConverted = currencyProvider.convertFromTRY(
      discretionary,
    );
    final remainingConverted = currencyProvider.convertFromTRY(
      widget.budgetService.remainingBudget.abs(),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                blur: 15,
                boxShadow: PremiumShadows.shadowPremium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık with icon halo
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: context.appColors.primary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: PremiumShadows.coloredGlow(
                              context.appColors.primary,
                              intensity: 0.3,
                            ),
                          ),
                          child: Icon(
                            PhosphorIconsDuotone.chartPie,
                            color: context.appColors.primary,
                            size: 18,
                            shadows: PremiumShadows.iconHalo(
                              context.appColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.monthlySpendingBreakdown,
                          style: TextStyle(
                            color: context.appColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Animated stacked progress bar
                    _AnimatedStackedProgress(
                      mandatoryPercent: mandatoryPercent,
                      discretionaryPercent: discretionaryPercent,
                    ),
                    const SizedBox(height: 20),

                    // Detaylar - stat items with staggered animation
                    Row(
                      children: [
                        // Zorunlu giderler
                        Expanded(
                          child: _AnimatedStatItem(
                            index: 0,
                            icon: PhosphorIconsDuotone.lock,
                            iconColor: context.appColors.info,
                            label: l10n.mandatoryExpenses,
                            amount: mandatoryConverted,
                            hours: mandatoryHours,
                            percent: mandatoryPercent,
                            currencySymbol: currencyProvider.symbol,
                            l10n: l10n,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // İsteğe bağlı
                        Expanded(
                          child: _AnimatedStatItem(
                            index: 1,
                            icon: PhosphorIconsDuotone.shoppingBag,
                            iconColor: context.appColors.warning,
                            label: l10n.discretionaryExpenses,
                            amount: discretionaryConverted,
                            hours: discretionaryHours,
                            percent: discretionaryPercent,
                            currencySymbol: currencyProvider.symbol,
                            l10n: l10n,
                          ),
                        ),
                      ],
                    ),

                    // Kalan bütçe bilgisi
                    if (widget.budgetService.remainingBudget > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.appColors.success.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.appColors.success.withValues(
                              alpha: 0.2,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIconsDuotone.checkCircle,
                              color: context.appColors.success,
                              size: 20,
                              shadows: PremiumShadows.iconHalo(
                                context.appColors.success,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.remainingHoursToSpend(
                                  widget.budgetService.remainingHours
                                      .toStringAsFixed(0),
                                ),
                                style: TextStyle(
                                  color: context.appColors.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Bütçe aşıldı uyarısı
                    if (widget.budgetService.isOverBudget) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.appColors.error.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.appColors.error.withValues(
                              alpha: 0.2,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIconsDuotone.warning,
                              color: context.appColors.error,
                              size: 20,
                              shadows: PremiumShadows.iconHalo(
                                context.appColors.error,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.budgetExceeded(
                                  formatTurkishCurrency(
                                    remainingConverted,
                                    decimalDigits: 0,
                                    showDecimals: false,
                                  ),
                                ),
                                style: TextStyle(
                                  color: context.appColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated stacked progress bar
class _AnimatedStackedProgress extends StatefulWidget {
  final double mandatoryPercent;
  final double discretionaryPercent;

  const _AnimatedStackedProgress({
    required this.mandatoryPercent,
    required this.discretionaryPercent,
  });

  @override
  State<_AnimatedStackedProgress> createState() =>
      _AnimatedStackedProgressState();
}

class _AnimatedStackedProgressState extends State<_AnimatedStackedProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // 200ms delay
    Future.delayed(const Duration(milliseconds: 200), () {
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedMandatory = widget.mandatoryPercent * _animation.value;
        final animatedDiscretionary =
            widget.discretionaryPercent * _animation.value;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final trackColor = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.08);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: context.appColors.primary.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 10,
              color: trackColor,
              child: Row(
                children: [
                  // Zorunlu (mavi/info)
                  if (animatedMandatory > 0)
                    Expanded(
                      flex: animatedMandatory.round().clamp(1, 100),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.appColors.info,
                              context.appColors.info.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // İsteğe bağlı (turuncu/warning)
                  if (animatedDiscretionary > 0)
                    Expanded(
                      flex: animatedDiscretionary.round().clamp(1, 100),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.appColors.warning,
                              context.appColors.warning.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Kalan boşluk
                  if (animatedMandatory + animatedDiscretionary < 100)
                    Expanded(
                      flex: (100 - animatedMandatory - animatedDiscretionary)
                          .round()
                          .clamp(1, 100),
                      child: const SizedBox(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated stat item with count-up
class _AnimatedStatItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final Color iconColor;
  final String label;
  final double amount;
  final double hours;
  final double percent;
  final String currencySymbol;
  final AppLocalizations l10n;

  const _AnimatedStatItem({
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.hours,
    required this.percent,
    required this.currencySymbol,
    required this.l10n,
  });

  @override
  State<_AnimatedStatItem> createState() => _AnimatedStatItemState();
}

class _AnimatedStatItemState extends State<_AnimatedStatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Staggered delay: 300ms base + 100ms per index
    Future.delayed(Duration(milliseconds: 300 + (100 * widget.index)), () {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.iconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.iconColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: widget.iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 14,
                          shadows: PremiumShadows.iconHalo(widget.iconColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            color: context.appColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Count-up animation for amount
                  AnimatedCountUp(
                    value: widget.amount,
                    duration: const Duration(milliseconds: 800),
                    formatter: (value) => formatTurkishCurrency(
                      value,
                      decimalDigits: 0,
                      showDecimals: false,
                    ),
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: widget.iconColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.hours.toStringAsFixed(1)} ${widget.l10n.hourAbbreviation} · %${widget.percent.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: context.appColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
