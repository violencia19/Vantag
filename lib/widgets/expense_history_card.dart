import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../utils/category_utils.dart';
import '../utils/currency_utils.dart';
import 'premium_share_card.dart';

class ExpenseHistoryCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Function(ExpenseDecision)? onDecisionUpdate;
  final bool showHint;
  final String currencySymbol;

  const ExpenseHistoryCard({
    super.key,
    required this.expense,
    this.onDelete,
    this.onEdit,
    this.onDecisionUpdate,
    this.showHint = false,
    this.currencySymbol = '₺',
  });

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final months = [
      l10n.monthJan,
      l10n.monthFeb,
      l10n.monthMar,
      l10n.monthApr,
      l10n.monthMay,
      l10n.monthJun,
      l10n.monthJul,
      l10n.monthAug,
      l10n.monthSep,
      l10n.monthOct,
      l10n.monthNov,
      l10n.monthDec,
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getDecisionColor(BuildContext context, ExpenseDecision? decision) {
    return switch (decision) {
      ExpenseDecision.yes => context.appColors.decisionYes,
      ExpenseDecision.thinking => context.appColors.decisionThinking,
      ExpenseDecision.no => context.appColors.decisionNo,
      null => context.appColors.textTertiary,
    };
  }

  IconData _getDecisionIcon(ExpenseDecision? decision) {
    return switch (decision) {
      ExpenseDecision.yes => PhosphorIconsDuotone.checkCircle,
      ExpenseDecision.thinking => PhosphorIconsDuotone.clock,
      ExpenseDecision.no => PhosphorIconsDuotone.xCircle,
      null => PhosphorIconsDuotone.question,
    };
  }

  void _showDecisionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.updateDecision,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionTile(
                context: context,
                icon: PhosphorIconsDuotone.checkCircle,
                label: l10n.bought,
                color: context.appColors.decisionYes,
                onTap: () {
                  Navigator.pop(context);
                  onDecisionUpdate?.call(ExpenseDecision.yes);
                },
              ),
              const SizedBox(height: 12),
              _buildOptionTile(
                context: context,
                icon: PhosphorIconsDuotone.xCircle,
                label: l10n.passed,
                color: context.appColors.decisionNo,
                onTap: () {
                  Navigator.pop(context);
                  onDecisionUpdate?.call(ExpenseDecision.no);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuTile(
                context: context,
                icon: PhosphorIconsDuotone.shareFat,
                label: l10n.share,
                color: context.appColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  _showShareCard(context);
                },
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                context: context,
                icon: PhosphorIconsDuotone.pencilSimple,
                label: l10n.edit,
                color: context.appColors.info,
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                context: context,
                icon: PhosphorIconsDuotone.trash,
                label: l10n.delete,
                color: context.appColors.error,
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareCard(BuildContext context) {
    showShareCardPreview(
      context,
      amount: expense.amount,
      hoursRequired: expense.hoursRequired,
      category: expense.category,
      date: expense.date,
      currencySymbol: currencySymbol,
      decision: expense.decision,
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.appColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDecisionLabel(BuildContext context, ExpenseDecision? decision) {
    final l10n = AppLocalizations.of(context);
    return switch (decision) {
      ExpenseDecision.yes => l10n.accessibilityDecisionYes,
      ExpenseDecision.thinking => l10n.accessibilityDecisionThinking,
      ExpenseDecision.no => l10n.accessibilityDecisionNo,
      null => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final decisionColor = _getDecisionColor(context, expense.decision);
    final isThinking = expense.decision == ExpenseDecision.thinking;

    // Accessibility: Semantic label for screen readers
    final semanticLabel = l10n.accessibilityExpenseItem(
      CategoryUtils.getLocalizedName(context, expense.category),
      formatTurkishCurrency(expense.amount, decimalDigits: 0),
      expense.hoursRequired.toStringAsFixed(1),
      _getDecisionLabel(context, expense.decision),
    );

    Widget card = Semantics(
      label: semanticLabel,
      button: isThinking,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.cardBorder),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isThinking ? () => _showDecisionDialog(context) : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Decision indicator
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: decisionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getDecisionIcon(expense.decision),
                      size: 22,
                      color: decisionColor,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${formatTurkishCurrency(expense.amount, decimalDigits: 2)} TL',
                                  style: AccessibleText.scaled(
                                    context,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: context.appColors.textPrimary,
                                    maxScale: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  CategoryUtils.getLocalizedName(
                                    context,
                                    expense.category,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: context.appColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            // Simulation badge - icon + text
                            if (expense.isSimulation) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.warning.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIconsDuotone.lightning,
                                      size: 12,
                                      color: context.appColors.warning,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Sim',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: context.appColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Auto-recorded badge
                            if (expense.isAutoRecorded) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.info.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIconsDuotone.repeat,
                                      size: 12,
                                      color: context.appColors.info,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.autoRecorded,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: context.appColors.info,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              PhosphorIconsDuotone.clock,
                              size: 14,
                              color: context.appColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${expense.hoursRequired.toStringAsFixed(1)}s / ${expense.daysRequired.toStringAsFixed(1)}g',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.appColors.textTertiary,
                              ),
                            ),
                            if (isThinking) ...[
                              const SizedBox(width: 12),
                              Text(
                                l10n.tapToUpdate,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.appColors.decisionThinking
                                      .withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right side
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(context, expense.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: l10n.accessibilityEditExpense,
                        button: true,
                        child: Tooltip(
                          message: l10n.accessibilityEditExpense,
                          child: GestureDetector(
                            onTap: () => _showOptionsMenu(context),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: context.appColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                PhosphorIconsDuotone.dotsThree,
                                size: 20,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Swipe actions with flutter_slidable
    return Column(
      children: [
        if (showHint)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsDuotone.arrowsLeftRight,
                  size: 16,
                  color: context.appColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.swipeToEditOrDelete,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        Slidable(
          key: ValueKey(
            'expense_${expense.amount}_${expense.date.toIso8601String()}',
          ),

          // Swipe right → Edit (Blue)
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.25,
            children: [
              Semantics(
                label: l10n.accessibilityEditExpense,
                button: true,
                child: CustomSlidableAction(
                  onPressed: (_) {
                    HapticFeedback.lightImpact();
                    onEdit?.call();
                  },
                  backgroundColor: context.appColors.info,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(PhosphorIconsBold.pencilSimple, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        l10n.edit,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Swipe left → Delete (Red)
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.25,
            dismissible: DismissiblePane(
              onDismissed: () {
                HapticFeedback.mediumImpact();
                onDelete?.call();
              },
              confirmDismiss: () => _showDeleteConfirmation(context),
            ),
            children: [
              Semantics(
                label: l10n.accessibilityDeleteExpense,
                button: true,
                child: CustomSlidableAction(
                  onPressed: (_) async {
                    HapticFeedback.lightImpact();
                    final confirmed = await _showDeleteConfirmation(context);
                    if (confirmed) {
                      onDelete?.call();
                    }
                  },
                  backgroundColor: context.appColors.error,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(PhosphorIconsBold.trash, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        l10n.delete,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          child: card,
        ),
      ],
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: context.appColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              l10n.deleteExpense,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              l10n.deleteExpenseConfirm,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: context.appColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context, true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: context.appColors.error,
                ),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
  }
}
