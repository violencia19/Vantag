import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../utils/category_utils.dart';
import '../utils/currency_utils.dart';
import 'premium_share_card.dart';

class ExpenseHistoryCard extends StatefulWidget {
  final Expense expense;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Function(ExpenseDecision)? onDecisionUpdate;
  final bool showHint;
  final String currencySymbol;
  final double dailyWorkHours;

  const ExpenseHistoryCard({
    super.key,
    required this.expense,
    this.onDelete,
    this.onEdit,
    this.onDecisionUpdate,
    this.showHint = false,
    this.currencySymbol = '₺',
    this.dailyWorkHours = 8,
  });

  @override
  State<ExpenseHistoryCard> createState() => _ExpenseHistoryCardState();
}

class _ExpenseHistoryCardState extends State<ExpenseHistoryCard>
    with SingleTickerProviderStateMixin {
  // iOS 26 Liquid Glass: Subtle breathing glow
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Expense get expense => widget.expense;
  VoidCallback? get onDelete => widget.onDelete;
  VoidCallback? get onEdit => widget.onEdit;
  Function(ExpenseDecision)? get onDecisionUpdate => widget.onDecisionUpdate;
  bool get showHint => widget.showHint;
  String get currencySymbol => widget.currencySymbol;
  double get dailyWorkHours => widget.dailyWorkHours;

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
      ExpenseDecision.yes => context.vantColors.decisionYes,
      ExpenseDecision.thinking => context.vantColors.decisionThinking,
      ExpenseDecision.no => context.vantColors.decisionNo,
      null => context.vantColors.textTertiary,
    };
  }

  IconData _getDecisionIcon(ExpenseDecision? decision) {
    return switch (decision) {
      ExpenseDecision.yes => CupertinoIcons.checkmark_circle_fill,
      ExpenseDecision.thinking => CupertinoIcons.clock_fill,
      ExpenseDecision.no => CupertinoIcons.xmark_circle_fill,
      null => CupertinoIcons.question_circle_fill,
    };
  }

  void _showDecisionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.vantColors.surface,
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
                  color: context.vantColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.updateDecision,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionTile(
                context: context,
                icon: CupertinoIcons.checkmark_circle_fill,
                label: l10n.bought,
                color: context.vantColors.decisionYes,
                onTap: () {
                  Navigator.pop(context);
                  onDecisionUpdate?.call(ExpenseDecision.yes);
                },
              ),
              const SizedBox(height: 12),
              _buildOptionTile(
                context: context,
                icon: CupertinoIcons.xmark_circle_fill,
                label: l10n.passed,
                color: context.vantColors.decisionNo,
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
          borderRadius: BorderRadius.circular(16),
          child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
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
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.vantColors.surface,
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
                  color: context.vantColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuTile(
                context: context,
                icon: CupertinoIcons.share,
                label: l10n.share,
                color: context.vantColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  _showShareCard(context);
                },
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                context: context,
                icon: CupertinoIcons.pencil,
                label: l10n.edit,
                color: context.vantColors.info,
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                context: context,
                icon: CupertinoIcons.trash,
                label: l10n.delete,
                color: context.vantColors.error,
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.vantColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
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

    // iOS 26 Liquid Glass: Animated card with subtle glow
    Widget card = AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Semantics(
          label: semanticLabel,
          button: isThinking,
          child: Padding(
            padding: const EdgeInsets.only(bottom: VantSpacing.md),
            // iOS 26: Outer glow container
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // Animated glow based on decision color
                  BoxShadow(
                    color: decisionColor.withValues(
                      alpha: _glowAnimation.value,
                    ),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                  // Subtle shadow for depth
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  // iOS 26: Enhanced blur for list items (20σ)
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      // iOS 26 Liquid Glass: Premium gradient
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.vantColors.surface.withValues(alpha: 0.8),
                          context.vantColors.surface.withValues(alpha: 0.6),
                        ],
                      ),
                      // Glass border
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isThinking ? () => _showDecisionDialog(context) : null,
                        borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Decision indicator - Revolut style (44x44, radius 14)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: decisionColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getDecisionIcon(expense.decision),
                      size: 22,
                      color: decisionColor,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content - Revolut style
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title (amount + category)
                        Text(
                          '${formatTurkishCurrency(expense.amount, decimalDigits: 0)} $currencySymbol',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.vantColors.textPrimary,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Subtitle (category + badges)
                        Row(
                          children: [
                            Text(
                              CategoryUtils.getLocalizedName(
                                context,
                                expense.category,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: context.vantColors.textTertiary,
                              ),
                            ),
                            // Work time
                            Text(
                              ' · ${formatWorkTime(
                                expense.hoursRequired,
                                workHoursPerDay: dailyWorkHours,
                                locale: Localizations.localeOf(context).languageCode,
                              )}',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.vantColors.textTertiary,
                              ),
                            ),
                            // Simulation badge
                            if (expense.isSimulation) ...[
                              Text(
                                ' · Sim',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.vantColors.warning,
                                ),
                              ),
                            ],
                            // Auto-recorded badge
                            if (expense.isAutoRecorded) ...[
                              Text(
                                ' · ${l10n.autoRecorded}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.vantColors.info,
                                ),
                              ),
                            ],
                            // Tap to update hint
                            if (isThinking) ...[
                              Text(
                                ' · ${l10n.tapToUpdate}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.vantColors.decisionThinking,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right side - Amount (Revolut style)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Date
                      Text(
                        _formatDate(context, expense.date),
                        style: TextStyle(
                          fontSize: 13,
                          color: context.vantColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  // Options menu button
                  const SizedBox(width: 8),
                  Semantics(
                    label: l10n.accessibilityEditExpense,
                    button: true,
                    child: GestureDetector(
                      onTap: () => _showOptionsMenu(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: Icon(
                          CupertinoIcons.ellipsis_vertical,
                          size: 20,
                          color: context.vantColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
                  CupertinoIcons.arrow_left_right,
                  size: 16,
                  color: context.vantColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.swipeToEditOrDelete,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.vantColors.textTertiary,
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
                  backgroundColor: context.vantColors.info,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.pencil, size: 22),
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
                  backgroundColor: context.vantColors.error,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.trash, size: 22),
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
            backgroundColor: context.vantColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              l10n.deleteExpense,
              style: TextStyle(
                color: context.vantColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              l10n.deleteExpenseConfirm,
              style: TextStyle(color: context.vantColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: context.vantColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context, true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: context.vantColors.error,
                ),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
  }
}
