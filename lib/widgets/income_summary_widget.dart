import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

/// Dashboard'da gelir ve net bakiye özetini gösteren widget
class IncomeSummaryWidget extends StatelessWidget {
  final double totalIncome;
  final double totalSpent;
  final int incomeSourceCount;
  final VoidCallback? onTap;
  final double expandRatio;

  const IncomeSummaryWidget({
    super.key,
    required this.totalIncome,
    required this.totalSpent,
    this.incomeSourceCount = 1,
    this.onTap,
    this.expandRatio = 1.0,
  });

  double get netBalance => totalIncome - totalSpent;
  double get spendingRate => totalIncome > 0 ? (totalSpent / totalIncome * 100) : 0;
  bool get isPositive => netBalance >= 0;

  @override
  Widget build(BuildContext context) {
    // Boyutları expandRatio'ya göre hesapla
    final containerPadding = 12.0 + (8.0 * expandRatio);
    final iconSize = 16.0 + (8.0 * expandRatio);
    final mainFontSize = 14.0 + (6.0 * expandRatio);
    final subFontSize = 10.0 + (2.0 * expandRatio);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: containerPadding,
          vertical: containerPadding * 0.75,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.cardBorder.withValues(alpha: 0.5 + (0.3 * expandRatio)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gelir ikonu
            Container(
              width: iconSize * 1.8,
              height: iconSize * 1.8,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIconsDuotone.wallet,
                size: iconSize,
                color: AppColors.success,
              ),
            ),
            SizedBox(width: 8 + (4 * expandRatio)),

            // Gelir bilgileri
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toplam gelir
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTurkishCurrency(totalIncome, decimalDigits: 0, showDecimals: false),
                      style: TextStyle(
                        fontSize: mainFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      ' TL',
                      style: TextStyle(
                        fontSize: subFontSize,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (incomeSourceCount > 1) ...[
                      SizedBox(width: 4 + (2 * expandRatio)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4 + (2 * expandRatio),
                          vertical: 1 + expandRatio,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$incomeSourceCount',
                          style: TextStyle(
                            fontSize: subFontSize - 2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2 * expandRatio),
                // Net bakiye
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? PhosphorIconsDuotone.trendUp : PhosphorIconsDuotone.trendDown,
                      size: subFontSize + 2,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${formatTurkishCurrency(netBalance, decimalDigits: 2)}',
                      style: TextStyle(
                        fontSize: subFontSize,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Navigasyon ikonu (expanded durumda)
            if (expandRatio > 0.5 && onTap != null) ...[
              SizedBox(width: 8 + (4 * expandRatio)),
              Icon(
                PhosphorIconsDuotone.caretRight,
                size: iconSize,
                color: AppColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kompakt gelir gösterimi (header için)
class CompactIncomeIndicator extends StatelessWidget {
  final double totalIncome;
  final double totalSpent;
  final VoidCallback? onTap;

  const CompactIncomeIndicator({
    super.key,
    required this.totalIncome,
    required this.totalSpent,
    this.onTap,
  });

  double get netBalance => totalIncome - totalSpent;
  bool get isPositive => netBalance >= 0;
  double get spendingRate => totalIncome > 0 ? (totalSpent / totalIncome * 100) : 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Net bakiye göstergesi
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isPositive ? AppColors.success : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${spendingRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getSpendingColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSpendingColor() {
    if (spendingRate < 50) return AppColors.success;
    if (spendingRate < 75) return AppColors.warning;
    if (spendingRate < 100) return AppColors.error;
    return AppColors.error;
  }
}

/// Gelir/Harcama ilerleme çubuğu
class IncomeProgressBar extends StatelessWidget {
  final double totalIncome;
  final double totalSpent;
  final double height;

  const IncomeProgressBar({
    super.key,
    required this.totalIncome,
    required this.totalSpent,
    this.height = 6,
  });

  double get progress => totalIncome > 0 ? (totalSpent / totalIncome).clamp(0.0, 1.5) : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final progressWidth = constraints.maxWidth * progress.clamp(0.0, 1.0);
          return Stack(
            children: [
              // Progress bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: progressWidth,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getGradientColors(),
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
              // Overflow indicator (eğer %100'ü aştıysa)
              if (progress > 1.0)
                Positioned(
                  right: 0,
                  child: Container(
                    width: height * 1.5,
                    height: height,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                    child: Icon(
                      PhosphorIconsDuotone.warningCircle,
                      size: height - 2,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (progress < 0.5) {
      return [AppColors.success, AppColors.success.withValues(alpha: 0.8)];
    } else if (progress < 0.75) {
      return [AppColors.success, AppColors.warning];
    } else if (progress < 1.0) {
      return [AppColors.warning, AppColors.error];
    } else {
      return [AppColors.error, AppColors.error.withValues(alpha: 0.8)];
    }
  }
}
