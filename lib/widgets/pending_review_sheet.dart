import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/finance_provider.dart';
import '../services/import_service.dart';
import '../services/merchant_learning_service.dart';
import '../theme/theme.dart';

/// Category option for the review sheet
class _CategoryOption {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

/// Sheet for reviewing and categorizing pending expenses
class PendingReviewSheet extends StatefulWidget {
  /// Expenses to review
  final List<ParsedExpense> expenses;

  /// User ID for merchant learning
  final String userId;

  /// Callback when all expenses are processed
  final VoidCallback? onComplete;

  const PendingReviewSheet({
    super.key,
    required this.expenses,
    required this.userId,
    this.onComplete,
  });

  /// Show the review sheet as a modal
  static Future<void> show(
    BuildContext context, {
    required List<ParsedExpense> expenses,
    required String userId,
    VoidCallback? onComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PendingReviewSheet(
        expenses: expenses,
        userId: userId,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<PendingReviewSheet> createState() => _PendingReviewSheetState();
}

class _PendingReviewSheetState extends State<PendingReviewSheet> {
  late List<ParsedExpense> _remaining;
  final _merchantService = MerchantLearningService();
  int _processedCount = 0;
  int _skippedCount = 0;

  // Category options
  List<_CategoryOption> get _categories => [
    _CategoryOption(
      id: 'Yiyecek',
      label: AppLocalizations.of(context).categoryFood,
      icon: PhosphorIconsDuotone.hamburger,
      color: const Color(0xFFE74C3C),
    ),
    _CategoryOption(
      id: 'Ulaşım',
      label: AppLocalizations.of(context).categoryTransport,
      icon: PhosphorIconsDuotone.car,
      color: const Color(0xFF3498DB),
    ),
    _CategoryOption(
      id: 'Giyim',
      label: AppLocalizations.of(context).categoryClothing,
      icon: PhosphorIconsDuotone.tShirt,
      color: const Color(0xFF9B59B6),
    ),
    _CategoryOption(
      id: 'Elektronik',
      label: AppLocalizations.of(context).categoryElectronics,
      icon: PhosphorIconsDuotone.devices,
      color: const Color(0xFF1ABC9C),
    ),
    _CategoryOption(
      id: 'Eğlence',
      label: AppLocalizations.of(context).categoryEntertainment,
      icon: PhosphorIconsDuotone.gameController,
      color: const Color(0xFFF39C12),
    ),
    _CategoryOption(
      id: 'Sağlık',
      label: AppLocalizations.of(context).categoryHealth,
      icon: PhosphorIconsDuotone.heartbeat,
      color: const Color(0xFFE91E63),
    ),
    _CategoryOption(
      id: 'Eğitim',
      label: AppLocalizations.of(context).categoryEducation,
      icon: PhosphorIconsDuotone.graduationCap,
      color: const Color(0xFF2ECC71),
    ),
    _CategoryOption(
      id: 'Faturalar',
      label: AppLocalizations.of(context).categoryBills,
      icon: PhosphorIconsDuotone.receipt,
      color: const Color(0xFF95A5A6),
    ),
    _CategoryOption(
      id: 'Diğer',
      label: AppLocalizations.of(context).categoryOther,
      icon: PhosphorIconsDuotone.dotsThree,
      color: const Color(0xFF7F8C8D),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _remaining = List.from(widget.expenses);
  }

  void _approveExpense(ParsedExpense expense, String category) async {
    HapticFeedback.mediumImpact();

    // Learn merchant if checkbox is checked
    if (expense.rememberMerchant) {
      await _merchantService.learnMerchant(
        userId: widget.userId,
        rawDescription: expense.rawDescription,
        category: category,
        displayName: expense.effectiveDisplayName ?? expense.rawDescription,
      );
    }

    // Add expense to finance provider
    if (mounted) {
      final financeProvider = context.read<FinanceProvider>();

      // Calculate work time (simplified - uses placeholder hourly rate)
      const hourlyRate = 50.0;
      final hoursRequired = expense.amount / hourlyRate;
      final daysRequired = hoursRequired / 8.0;

      final newExpense = Expense(
        amount: expense.amount,
        category: category,
        subCategory: expense.effectiveDisplayName ?? expense.rawDescription,
        date: expense.date,
        hoursRequired: hoursRequired,
        daysRequired: daysRequired,
        decision: ExpenseDecision.yes,
      );
      await financeProvider.addExpense(newExpense);
    }

    setState(() {
      _remaining.remove(expense);
      _processedCount++;
    });

    _checkComplete();
  }

  void _skipExpense(ParsedExpense expense) {
    HapticFeedback.lightImpact();
    setState(() {
      _remaining.remove(expense);
      _skippedCount++;
    });
    _checkComplete();
  }

  void _checkComplete() {
    if (_remaining.isEmpty && widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.appColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reviewExpenses,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.swipeToCategorizeTip,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_remaining.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          if (widget.expenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: _processedCount / widget.expenses.length,
                backgroundColor: context.appColors.cardBorder,
                valueColor: AlwaysStoppedAnimation(context.appColors.success),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _remaining.isEmpty
                ? _buildEmptyState(l10n)
                : _buildExpenseCard(_remaining.first),
          ),

          // Bottom actions
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Skip button
                  TextButton.icon(
                    onPressed: _remaining.isEmpty
                        ? null
                        : () => _skipExpense(_remaining.first),
                    icon: PhosphorIcon(
                      PhosphorIconsRegular.skipForward,
                      color: context.appColors.textSecondary,
                    ),
                    label: Text(
                      l10n.skip,
                      style: TextStyle(color: context.appColors.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  // Close button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.close),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.appColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(
              PhosphorIconsDuotone.checkCircle,
              size: 40,
              color: context.appColors.success,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.allCategorized,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.categorizedCount(_processedCount, _skippedCount),
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ParsedExpense expense) {
    final l10n = AppLocalizations.of(context);
    final hasSuggestion = expense.hasSuggestion;
    final suggestedCategory = hasSuggestion ? expense.match!.category : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Expense details card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.appColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount
                Text(
                  '${NumberFormat('#,##0', 'tr').format(expense.amount)} ₺',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  expense.rawDescription,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.appColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Date
                Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIconsRegular.calendar,
                      size: 16,
                      color: context.appColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(expense.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ],
                ),

                // Suggestion badge
                if (hasSuggestion) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.appColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          PhosphorIconsFill.lightbulb,
                          size: 16,
                          color: context.appColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.suggestionLabel(expense.match!.displayName),
                          style: TextStyle(
                            fontSize: 14,
                            color: context.appColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Remember merchant checkbox
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      expense.rememberMerchant = !expense.rememberMerchant;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: expense.rememberMerchant
                              ? context.appColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: expense.rememberMerchant
                                ? context.appColors.primary
                                : context.appColors.textTertiary,
                          ),
                        ),
                        child: expense.rememberMerchant
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.rememberMerchant,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Category grid
          Text(
            l10n.selectCategory,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSuggested = suggestedCategory == category.id;

                return _buildCategoryButton(
                  category: category,
                  isSuggested: isSuggested,
                  onTap: () => _approveExpense(expense, category.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton({
    required _CategoryOption category,
    required bool isSuggested,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSuggested
              ? category.color.withValues(alpha: 0.2)
              : context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSuggested ? category.color : context.appColors.cardBorder,
            width: isSuggested ? 2 : 1,
          ),
          boxShadow: isSuggested
              ? [
                  BoxShadow(
                    color: category.color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              category.icon,
              size: 28,
              color: isSuggested
                  ? category.color
                  : context.appColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSuggested ? FontWeight.w600 : FontWeight.w500,
                color: isSuggested
                    ? category.color
                    : context.appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSuggested) ...[
              const SizedBox(height: 2),
              Text(
                AppLocalizations.of(context).suggested,
                style: TextStyle(
                  fontSize: 10,
                  color: category.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return AppLocalizations.of(context).today;
    } else if (diff.inDays == 1) {
      return AppLocalizations.of(context).yesterday;
    } else if (diff.inDays < 7) {
      return AppLocalizations.of(context).daysAgo(diff.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
