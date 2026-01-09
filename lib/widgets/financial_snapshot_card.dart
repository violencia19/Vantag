import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

/// Premium Financial Snapshot Card
/// Net balance card - 56px light font, pulsing dot, glassmorphism
class FinancialSnapshotCard extends StatelessWidget {
  final double totalIncome;
  final double totalSpent;
  final double savedAmount;
  final int savedCount;
  final int incomeSourceCount;
  final VoidCallback? onTap;

  const FinancialSnapshotCard({
    super.key,
    required this.totalIncome,
    required this.totalSpent,
    required this.savedAmount,
    this.savedCount = 0,
    this.incomeSourceCount = 1,
    this.onTap,
  });

  double get netBalance => totalIncome - totalSpent;
  double get remainingPercent =>
      totalIncome > 0 ? ((totalIncome - totalSpent) / totalIncome * 100).clamp(0, 100) : 100;
  double get spentPercent =>
      totalIncome > 0 ? (totalSpent / totalIncome * 100).clamp(0, 100) : 0;
  bool get isHealthy => netBalance >= 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Net Balance Label + Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Pulsing Dot
                          PulsingDot(
                            color: isHealthy ? AppColors.secondary : AppColors.error,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.netBalance,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      // Source badge
                      if (incomeSourceCount > 0)
                        PremiumBadge(
                          text: l10n.sources(incomeSourceCount),
                          icon: LucideIcons.wallet,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Main amount: Net Balance - 56px light (Animated)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.3),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  formatTurkishCurrency(netBalance.abs(),
                                      decimalDigits: 0, showDecimals: false),
                                  key: ValueKey<double>(netBalance),
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w300,
                                    color: isHealthy
                                        ? AppColors.textPrimary
                                        : AppColors.error,
                                    letterSpacing: -2,
                                    height: 1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 8),
                                child: Text(
                                  'TL',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Trend indicator (Animated)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: PremiumBadge(
                          key: ValueKey<double>(remainingPercent),
                          text: '${remainingPercent.toStringAsFixed(0)}%',
                          color: isHealthy ? AppColors.secondary : AppColors.error,
                          icon: isHealthy
                              ? LucideIcons.trendingUp
                              : LucideIcons.trendingDown,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Progress bar - Gradient purple → turquoise
                  _buildProgressBar(l10n),

                  const SizedBox(height: 24),

                  // Bottom info: Income | Expense | Saved
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: LucideIcons.arrowDown,
                          iconColor: AppColors.secondary,
                          label: l10n.income,
                          value: totalIncome,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          icon: LucideIcons.arrowUp,
                          iconColor: AppColors.error,
                          label: l10n.expense,
                          value: totalSpent,
                        ),
                      ),
                      if (savedAmount > 0) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatItem(
                            icon: LucideIcons.shieldCheck,
                            iconColor: AppColors.primary,
                            label: l10n.saved,
                            value: savedAmount,
                            badge: savedCount > 0 ? savedCount : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.budgetUsage,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${formatTurkishCurrency(totalSpent, decimalDigits: 0, showDecimals: false)} / ${formatTurkishCurrency(totalIncome, decimalDigits: 0, showDecimals: false)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Bar - Gradient purple → turquoise
        PremiumProgressBar(
          progress: spentPercent / 100,
          height: 8,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double value,
    int? badge,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            PremiumIconBadge(
              icon: icon,
              color: iconColor,
              size: 36,
            ),
            if (badge != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: Text(
            key: ValueKey<double>(value),
            formatTurkishCurrency(value, decimalDigits: 0, showDecimals: false),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
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
                color: (isHealthy ? AppColors.secondary : AppColors.error)
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
                    color: isHealthy ? AppColors.secondary : AppColors.error,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    if (spentPercent < 50) return AppColors.secondary;
    if (spentPercent < 75) return AppColors.warning;
    return AppColors.error;
  }
}
