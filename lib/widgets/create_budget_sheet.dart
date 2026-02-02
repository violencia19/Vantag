import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/category_budget.dart';
import '../models/expense.dart';
import '../providers/category_budget_provider.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';
import 'turkish_currency_input.dart';

/// Bottom sheet to create or edit a category budget
class CreateBudgetSheet extends StatefulWidget {
  final CategoryBudget? existingBudget;
  final String? preselectedCategory;

  const CreateBudgetSheet({
    super.key,
    this.existingBudget,
    this.preselectedCategory,
  });

  bool get isEditMode => existingBudget != null;

  /// Show the create budget sheet
  static Future<bool?> show(
    BuildContext context, {
    CategoryBudget? existingBudget,
    String? preselectedCategory,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => CreateBudgetSheet(
        existingBudget: existingBudget,
        preselectedCategory: preselectedCategory,
      ),
    );
  }

  @override
  State<CreateBudgetSheet> createState() => _CreateBudgetSheetState();
}

class _CreateBudgetSheetState extends State<CreateBudgetSheet> {
  final _amountController = TextEditingController();
  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode) {
      _selectedCategory = widget.existingBudget!.category;
      _amountController.text = formatTurkishCurrency(
        widget.existingBudget!.monthlyLimit,
        decimalDigits: 0,
      );
    } else if (widget.preselectedCategory != null) {
      _selectedCategory = widget.preselectedCategory;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (_selectedCategory == null) {
      _showError(AppLocalizations.of(context).pleaseSelectCategory);
      return;
    }

    final amount = parseTurkishCurrency(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError(AppLocalizations.of(context).validationAmountPositive);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final budgetProvider = context.read<CategoryBudgetProvider>();

      final budget = widget.isEditMode
          ? widget.existingBudget!.copyWith(
              monthlyLimit: amount,
              category: _selectedCategory,
            )
          : CategoryBudget(category: _selectedCategory!, monthlyLimit: amount);

      final success = widget.isEditMode
          ? await budgetProvider.updateBudget(budget)
          : await budgetProvider.addBudget(budget);

      if (success && mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteBudget() async {
    if (!widget.isEditMode) return;

    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deleteBudget,
          style: TextStyle(color: context.appColors.textPrimary),
        ),
        content: Text(
          l10n.deleteBudgetConfirm,
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
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isSaving = true);

      try {
        final budgetProvider = context.read<CategoryBudgetProvider>();
        final success = await budgetProvider.deleteBudget(
          widget.existingBudget!.id,
        );

        if (success && mounted) {
          HapticFeedback.mediumImpact();
          Navigator.pop(context, true);
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.appColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();
    final budgetProvider = context.watch<CategoryBudgetProvider>();

    // Get available categories (exclude already budgeted unless editing)
    final availableCategories = widget.isEditMode
        ? ExpenseCategory.all
        : budgetProvider.getCategoriesWithoutBudget(ExpenseCategory.all);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.gradientMid,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.appColors.textTertiary.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.isEditMode ? l10n.editBudget : l10n.addBudget,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Row(
                          children: [
                            if (widget.isEditMode)
                              Semantics(
                                button: true,
                                label: l10n.delete,
                                child: IconButton(
                                  onPressed: _isSaving ? null : _deleteBudget,
                                  tooltip: l10n.delete,
                                  icon: Icon(
                                    CupertinoIcons.trash,
                                    color: context.appColors.error,
                                    size: 22,
                                  ),
                                ),
                              ),
                            Semantics(
                              button: true,
                              label: l10n.accessibilityCloseSheet,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                tooltip: l10n.close,
                                icon: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: context.appColors.surfaceLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.xmark,
                                    size: 20,
                                    color: context.appColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category dropdown
                          Text(
                            l10n.category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            hint: Text(
                              l10n.selectCategory,
                              style: TextStyle(
                                color: context.appColors.textTertiary,
                              ),
                            ),
                            items: availableCategories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(
                                      ExpenseCategory.getIcon(category),
                                      size: 20,
                                      color: context.appColors.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      ExpenseCategory.getLocalizedName(
                                        category,
                                        l10n,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: widget.isEditMode
                                ? null
                                : (value) {
                                    setState(() => _selectedCategory = value);
                                  },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: context.appColors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: context.appColors.cardBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: context.appColors.cardBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: context.appColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            dropdownColor: context.appColors.surface,
                            style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Amount input
                          Text(
                            l10n.monthlyLimit,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: context.appColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.appColors.cardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  currencyProvider.symbol,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: context.appColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      TurkishCurrencyInputFormatter(),
                                    ],
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: context.appColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: context.appColors.textTertiary
                                            .withValues(alpha: 0.5),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Helper text
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: context.appColors.info.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.appColors.info.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.info_circle,
                                  color: context.appColors.info,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.budgetHelperText,
                                    style: TextStyle(
                                      color: context.appColors.info,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppGradients.primaryButton,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.appColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveBudget,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isSaving
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.floppy_disk,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            widget.isEditMode
                                                ? l10n.save
                                                : l10n.addBudget,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
