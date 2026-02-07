import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  double get spendingRate =>
      totalIncome > 0 ? (totalSpent / totalIncome * 100) : 0;
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
          color: context.vantColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.vantColors.cardBorder.withValues(
              alpha: 0.5 + (0.3 * expandRatio),
            ),
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
                color: context.vantColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.creditcard_fill,
                size: iconSize,
                color: context.vantColors.success,
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
                      formatTurkishCurrency(
                        totalIncome,
                        decimalDigits: 0,
                        showDecimals: false,
                      ),
                      style: TextStyle(
                        fontSize: mainFontSize,
                        fontWeight: FontWeight.w700,
                        color: context.vantColors.textPrimary,
                      ),
                    ),
                    Text(
                      ' TL',
                      style: TextStyle(
                        fontSize: subFontSize,
                        fontWeight: FontWeight.w500,
                        color: context.vantColors.textSecondary,
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
                          color: context.vantColors.success.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$incomeSourceCount',
                          style: TextStyle(
                            fontSize: subFontSize - 2,
                            fontWeight: FontWeight.w600,
                            color: context.vantColors.success,
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
                      isPositive
                          ? CupertinoIcons.arrow_up_right
                          : CupertinoIcons.arrow_down_right,
                      size: subFontSize + 2,
                      color: isPositive
                          ? context.vantColors.success
                          : context.vantColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${formatTurkishCurrency(netBalance, decimalDigits: 2)}',
                      style: TextStyle(
                        fontSize: subFontSize,
                        fontWeight: FontWeight.w600,
                        color: isPositive
                            ? context.vantColors.success
                            : context.vantColors.error,
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
                CupertinoIcons.chevron_right,
                size: iconSize,
                color: context.vantColors.textTertiary,
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
  double get spendingRate =>
      totalIncome > 0 ? (totalSpent / totalIncome * 100) : 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: context.vantColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.vantColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Net bakiye göstergesi
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isPositive
                    ? context.vantColors.success
                    : context.vantColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${spendingRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getSpendingColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSpendingColor(BuildContext context) {
    if (spendingRate < 50) return context.vantColors.success;
    if (spendingRate < 75) return context.vantColors.warning;
    if (spendingRate < 100) return context.vantColors.error;
    return context.vantColors.error;
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

  double get progress =>
      totalIncome > 0 ? (totalSpent / totalIncome).clamp(0.0, 1.5) : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.vantColors.surfaceLight,
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
                  gradient: LinearGradient(colors: _getGradientColors(context)),
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
                      color: context.vantColors.error,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                    child: Icon(
                      CupertinoIcons.exclamationmark_circle_fill,
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

  List<Color> _getGradientColors(BuildContext context) {
    if (progress < 0.5) {
      return [
        context.vantColors.success,
        context.vantColors.success.withValues(alpha: 0.8),
      ];
    } else if (progress < 0.75) {
      return [context.vantColors.success, context.vantColors.warning];
    } else if (progress < 1.0) {
      return [context.vantColors.warning, context.vantColors.error];
    } else {
      return [
        context.vantColors.error,
        context.vantColors.error.withValues(alpha: 0.8),
      ];
    }
  }
}
