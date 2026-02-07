import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// The allocation choice made by user
enum PoolAllocationChoice {
  /// Use available pool + add difference from pocket
  fromPocket,

  /// Create shadow debt (pool goes negative)
  createDebt,

  /// Only transfer available amount
  availableOnly,

  /// Cancel the operation
  cancel,
}

/// The source choice when pool is in debt
enum DebtSourceChoice {
  /// One-time income - doesn't affect pool
  oneTimeIncome,

  /// From savings - pool goes more negative
  fromSavings,

  /// Cancel
  cancel,
}

/// Dialog for handling over-allocation from pool
/// Shows 3 options when user wants to add more than available
class PoolAllocationDialog extends StatelessWidget {
  final double available;
  final double requested;
  final String currencySymbol;

  const PoolAllocationDialog({
    super.key,
    required this.available,
    required this.requested,
    required this.currencySymbol,
  });

  double get difference => requested - available;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: context.vantColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.vantColors.cardBorder),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.vantColors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: context.vantColors.warning,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              l10n.overAllocationTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.vantColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              l10n.overAllocationMessage(
                '$currencySymbol${available.toStringAsFixed(0)}',
                '$currencySymbol${requested.toStringAsFixed(0)}',
              ),
              style: TextStyle(
                fontSize: 14,
                color: context.vantColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Option 1: From pocket
            _OptionButton(
              icon: CupertinoIcons.creditcard_fill,
              iconColor: context.vantColors.success,
              title: l10n.fromMyPocket,
              subtitle: l10n.fromMyPocketDesc(
                '$currencySymbol${difference.toStringAsFixed(0)}',
              ),
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(PoolAllocationChoice.fromPocket);
              },
            ),
            const SizedBox(height: 12),

            // Option 2: Create debt
            _OptionButton(
              icon: CupertinoIcons.clock_fill,
              iconColor: context.vantColors.warning,
              title: l10n.deductFromFuture,
              subtitle: l10n.deductFromFutureDesc(
                '$currencySymbol${difference.toStringAsFixed(0)}',
              ),
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(PoolAllocationChoice.createDebt);
              },
            ),
            const SizedBox(height: 12),

            // Option 3: Available only
            if (available > 0)
              _OptionButton(
                icon: CupertinoIcons.money_dollar_circle_fill,
                iconColor: context.vantColors.primary,
                title: l10n.transferAvailableOnly(
                  '$currencySymbol${available.toStringAsFixed(0)}',
                ),
                subtitle: l10n.transferAvailableOnlyDesc,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(PoolAllocationChoice.availableOnly);
                },
              ),

            const SizedBox(height: 16),

            // Cancel button
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop(PoolAllocationChoice.cancel);
              },
              child: Text(
                l10n.cancel,
                style: TextStyle(color: context.vantColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for choosing source when pool is in debt
class DebtSourceDialog extends StatelessWidget {
  final double debtAmount;
  final String currencySymbol;

  const DebtSourceDialog({
    super.key,
    required this.debtAmount,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: context.vantColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.vantColors.cardBorder),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.vantColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.question_circle_fill,
                color: context.vantColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              l10n.oneTimeIncomeTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.vantColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              l10n.oneTimeIncomeDesc,
              style: TextStyle(
                fontSize: 14,
                color: context.vantColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Option 1: One-time income
            _OptionButton(
              icon: CupertinoIcons.sparkles,
              iconColor: context.vantColors.success,
              title: l10n.oneTimeIncomeOption,
              subtitle: l10n.oneTimeIncomeOptionDesc,
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(DebtSourceChoice.oneTimeIncome);
              },
            ),
            const SizedBox(height: 12),

            // Option 2: From savings
            _OptionButton(
              icon: CupertinoIcons.money_dollar_circle_fill,
              iconColor: context.vantColors.warning,
              title: l10n.fromSavingsOption,
              subtitle: l10n.fromSavingsOptionDesc,
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(DebtSourceChoice.fromSavings);
              },
            ),

            const SizedBox(height: 16),

            // Cancel button
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop(DebtSourceChoice.cancel);
              },
              child: Text(
                l10n.cancel,
                style: TextStyle(color: context.vantColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.vantColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.vantColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: context.vantColors.textTertiary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show pool allocation dialog
Future<PoolAllocationChoice?> showPoolAllocationDialog(
  BuildContext context, {
  required double available,
  required double requested,
  required String currencySymbol,
}) {
  return showDialog<PoolAllocationChoice>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (context) => PoolAllocationDialog(
      available: available,
      requested: requested,
      currencySymbol: currencySymbol,
    ),
  );
}

/// Show debt source dialog
Future<DebtSourceChoice?> showDebtSourceDialog(
  BuildContext context, {
  required double debtAmount,
  required String currencySymbol,
}) {
  return showDialog<DebtSourceChoice>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (context) => DebtSourceDialog(
      debtAmount: debtAmount,
      currencySymbol: currencySymbol,
    ),
  );
}
