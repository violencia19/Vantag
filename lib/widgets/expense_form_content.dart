import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import 'labeled_text_field.dart';
import 'turkish_currency_input.dart';
import 'smart_choice_toggle.dart';

/// Harcama formu içeriği - Modal ve inline kullanım için
class ExpenseFormContent extends StatefulWidget {
  final Expense? editingExpense;
  final Function(ExpenseFormData) onSubmit;
  final VoidCallback? onCancel;
  final String submitLabel;
  final bool showSmartChoice;

  const ExpenseFormContent({
    super.key,
    this.editingExpense,
    required this.onSubmit,
    this.onCancel,
    this.submitLabel = 'Kaydet',
    this.showSmartChoice = true,
  });

  @override
  State<ExpenseFormContent> createState() => ExpenseFormContentState();
}

class ExpenseFormContentState extends State<ExpenseFormContent>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _subCategoryFocusNode = FocusNode();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  double? _smartChoiceSavedFrom;
  bool _showSubCategorySuggestions = false;
  SubCategorySuggestions? _subCategorySuggestions;

  // Smart Match
  late AnimationController _smartMatchAnimController;
  late Animation<double> _smartMatchScale;
  bool _smartMatchActive = false;
  bool _categoryValidationError = false;
  bool _userManuallySelectedCategory = false;

  // Dirty tracking
  bool _isDirty = false;
  String _initialAmount = '';
  String _initialDescription = '';
  String? _initialCategory;

  @override
  void initState() {
    super.initState();

    // Smart match animasyonu
    _smartMatchAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _smartMatchScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _smartMatchAnimController, curve: Curves.easeOutBack),
    );

    // Editing mode
    if (widget.editingExpense != null) {
      final expense = widget.editingExpense!;
      _amountController.text = formatTurkishCurrency(expense.amount);
      _selectedCategory = expense.category;
      _selectedDate = expense.date;
      if (expense.subCategory != null) {
        _subCategoryController.text = expense.subCategory!;
      }
      _userManuallySelectedCategory = true;
    }

    // Track initial values
    _initialAmount = _amountController.text;
    _initialDescription = _descriptionController.text;
    _initialCategory = _selectedCategory;

    // Listeners
    _amountController.addListener(_checkDirty);
    _descriptionController.addListener(_checkDirty);

    _subCategoryFocusNode.addListener(() {
      if (_subCategoryFocusNode.hasFocus) {
        setState(() => _showSubCategorySuggestions = true);
      }
    });

    _loadSubCategorySuggestions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _subCategoryController.dispose();
    _subCategoryFocusNode.dispose();
    _smartMatchAnimController.dispose();
    super.dispose();
  }

  void _checkDirty() {
    final isDirty = _amountController.text != _initialAmount ||
        _descriptionController.text != _initialDescription ||
        _selectedCategory != _initialCategory;
    if (isDirty != _isDirty) {
      setState(() => _isDirty = isDirty);
    }
  }

  /// Dışarıdan dirty kontrolü için
  bool get isDirty => _isDirty;

  Future<void> _loadSubCategorySuggestions() async {
    if (_selectedCategory == null) {
      if (mounted) setState(() => _subCategorySuggestions = null);
      return;
    }
    final suggestions = await SubCategoryService().getSuggestions(_selectedCategory!);
    if (mounted) setState(() => _subCategorySuggestions = suggestions);
  }

  void _onDescriptionChanged(String text) {
    if (_userManuallySelectedCategory) return;

    final predicted = CategoryLearningService.predictCategory(text);
    if (predicted != null && ExpenseCategory.all.contains(predicted)) {
      setState(() {
        _selectedCategory = predicted;
        _smartMatchActive = true;
        _categoryValidationError = false;
      });
      _smartMatchAnimController.forward().then((_) {
        _smartMatchAnimController.reverse();
      });
      _loadSubCategorySuggestions();
    }
    _checkDirty();
  }

  void _onCategoryManuallySelected(String? category) {
    if (category == null) return;

    setState(() {
      _selectedCategory = category;
      _userManuallySelectedCategory = true;
      _categoryValidationError = false;
      _smartMatchActive = false;
    });

    _loadSubCategorySuggestions();

    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) {
      CategoryLearningService.learn(description, category);
    }
    _checkDirty();
  }

  void _selectSubCategory(String subCategory) {
    _subCategoryController.text = subCategory;
    setState(() => _showSubCategorySuggestions = false);
    _subCategoryFocusNode.unfocus();
  }

  Future<void> _showDatePicker() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: l10n.selectExpenseDate,
      cancelText: l10n.cancel,
      confirmText: l10n.select,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _checkDirty();
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final amount = parseTurkishCurrency(_amountController.text);

    if (amount == null || amount <= 0) {
      _showError(l10n.pleaseEnterValidAmount);
      return;
    }

    if (amount > 100000000) {
      _showError(l10n.amountTooHigh);
      return;
    }

    if (_selectedCategory == null) {
      setState(() => _categoryValidationError = true);
      _showError(l10n.pleaseSelectCategory);
      return;
    }

    HapticFeedback.mediumImpact();

    widget.onSubmit(ExpenseFormData(
      amount: amount,
      category: _selectedCategory!,
      subCategory: _subCategoryController.text.trim().isEmpty
          ? null
          : SubCategoryService.normalize(_subCategoryController.text.trim()),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      date: _selectedDate,
      savedFrom: _smartChoiceSavedFrom,
      isSmartChoice: _smartChoiceSavedFrom != null && _smartChoiceSavedFrom! > amount,
    ));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return l10n.today;
    if (dateOnly == yesterday) return l10n.yesterday;

    final months = [
      l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
      l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
      l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Amount
        LabeledTextField(
          controller: _amountController,
          label: l10n.amountTL,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          hint: '0,00',
          inputFormatters: [TurkishCurrencyInputFormatter()],
        ),

        const SizedBox(height: 16),

        // Bilinçli Tercih (Smart Choice)
        if (widget.showSmartChoice)
          SmartChoiceToggle(
            selectedCategory: _selectedCategory,
            currentAmount: parseTurkishCurrency(_amountController.text) ?? 0,
            onSavedFromChanged: (value) {
              setState(() => _smartChoiceSavedFrom = value);
            },
          ),

        if (widget.showSmartChoice) const SizedBox(height: 16),

        // 2. Description
        TextField(
          controller: _descriptionController,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            labelText: l10n.descriptionLabel,
            labelStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            hintText: l10n.descriptionHint,
            hintStyle: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: _smartMatchActive
                ? const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      LucideIcons.sparkles,
                      size: 18,
                      color: AppColors.success,
                    ),
                  )
                : null,
          ),
          onChanged: _onDescriptionChanged,
        ),

        const SizedBox(height: 16),

        // 3. Kategori
        AnimatedBuilder(
          animation: _smartMatchAnimController,
          builder: (context, child) {
            return Transform.scale(
              scale: _smartMatchActive ? _smartMatchScale.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _smartMatchActive
                      ? [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : _categoryValidationError
                          ? [
                              BoxShadow(
                                color: AppColors.error.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: Text(
                    l10n.selectCategory,
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  ),
                  items: ExpenseCategory.all.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(
                            ExpenseCategory.getIcon(category),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onCategoryManuallySelected,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    labelStyle: TextStyle(
                      color: _categoryValidationError
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _categoryValidationError
                            ? AppColors.error
                            : AppColors.cardBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _categoryValidationError
                            ? AppColors.error
                            : (_smartMatchActive ? AppColors.success : AppColors.cardBorder),
                        width: _smartMatchActive || _categoryValidationError ? 1.5 : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          },
        ),

        // Smart match indicator
        if (_smartMatchActive && _selectedCategory != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.autoSelected(_selectedCategory!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // 4. Sub-category
        TextField(
          controller: _subCategoryController,
          focusNode: _subCategoryFocusNode,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: l10n.subCategoryOptional,
            hintStyle: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          onTap: () => setState(() => _showSubCategorySuggestions = true),
        ),

        // Sub category suggestions
        if (_showSubCategorySuggestions && _subCategorySuggestions != null && !_subCategorySuggestions!.isEmpty)
          _buildSubCategoryChips(),

        const SizedBox(height: 16),

        // 5. Tarih
        GestureDetector(
          onTap: _showDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.date,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(_selectedDate, l10n),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              widget.submitLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Cancel button
        if (widget.onCancel != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: Text(l10n.cancel),
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSubCategoryChips() {
    final suggestions = _subCategorySuggestions!;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          ...suggestions.recent.map((s) => _SubCatChip(
                label: s,
                isRecent: true,
                onTap: () => _selectSubCategory(s),
              )),
          ...suggestions.fixed.map((s) => _SubCatChip(
                label: s,
                isRecent: false,
                onTap: () => _selectSubCategory(s),
              )),
        ],
      ),
    );
  }
}

class _SubCatChip extends StatelessWidget {
  final String label;
  final bool isRecent;
  final VoidCallback onTap;

  const _SubCatChip({
    required this.label,
    required this.isRecent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isRecent ? Colors.transparent : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isRecent
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRecent)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  LucideIcons.history,
                  size: 12,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isRecent ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Form verisi
class ExpenseFormData {
  final double amount;
  final String category;
  final String? subCategory;
  final String? description;
  final DateTime date;
  final double? savedFrom;
  final bool isSmartChoice;

  const ExpenseFormData({
    required this.amount,
    required this.category,
    this.subCategory,
    this.description,
    required this.date,
    this.savedFrom,
    this.isSmartChoice = false,
  });
}
