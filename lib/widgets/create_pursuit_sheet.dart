import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/quiet_luxury.dart';
import '../utils/emoji_helper.dart';
import 'upgrade_dialog.dart';

/// Bottom sheet for creating or editing a pursuit
class CreatePursuitSheet extends StatefulWidget {
  final Pursuit? pursuit; // If provided, edit mode

  const CreatePursuitSheet({super.key, this.pursuit});

  @override
  State<CreatePursuitSheet> createState() => _CreatePursuitSheetState();
}

class _CreatePursuitSheetState extends State<CreatePursuitSheet> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _initialSavingsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  PursuitCategory _selectedCategory = PursuitCategory.other;
  String _selectedEmoji = '📦';
  bool _isLoading = false;

  bool get _isEditMode => widget.pursuit != null;

  @override
  void initState() {
    super.initState();
    if (widget.pursuit != null) {
      _nameController.text = widget.pursuit!.name;
      _targetController.text = widget.pursuit!.targetAmount.toStringAsFixed(0);
      _selectedCategory = widget.pursuit!.category;
      _selectedEmoji = widget.pursuit!.emoji;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _initialSavingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();
    final currencySymbol = currencyProvider.currency.symbol;

    return Container(
      decoration: const BoxDecoration(
        color: QuietLuxury.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: QuietLuxury.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    _isEditMode ? l10n.editPursuit : l10n.createPursuit,
                    style: QuietLuxury.heading,
                  ),
                  const SizedBox(height: 24),

                  // Name input
                  _buildLabel(l10n.pursuitName),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    enableSuggestions: true,
                    autocorrect: false,
                    enableIMEPersonalizedLearning: true,
                    style: QuietLuxury.body.copyWith(
                      color: QuietLuxury.textPrimary,
                    ),
                    decoration: _inputDecoration(
                      hintText: l10n.pursuitNameHint,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pursuitNameRequired;
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 20),

                  // Target amount
                  _buildLabel(l10n.targetAmount),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _targetController,
                    style: QuietLuxury.body.copyWith(
                      color: QuietLuxury.textPrimary,
                    ),
                    decoration: _inputDecoration(
                      hintText: '0',
                      prefixText: currencySymbol,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ThousandsSeparatorFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pursuitAmountRequired;
                      }
                      final amount = _parseAmount(value);
                      if (amount <= 0) {
                        return l10n.pursuitAmountInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Category selection
                  _buildLabel(l10n.pursuitSelectCategory),
                  const SizedBox(height: 12),
                  _buildCategoryGrid(),
                  const SizedBox(height: 20),

                  // Initial savings (only for new pursuits)
                  if (!_isEditMode) ...[
                    _buildLabel(l10n.pursuitInitialSavings),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _initialSavingsController,
                      style: QuietLuxury.body.copyWith(
                        color: QuietLuxury.textPrimary,
                      ),
                      decoration: _inputDecoration(
                        hintText: l10n.pursuitInitialSavingsHint,
                        prefixText: currencySymbol,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ThousandsSeparatorFormatter(),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Create/Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QuietLuxury.positive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: QuietLuxury.positive
                            .withValues(alpha: 0.5),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _isEditMode ? l10n.save : l10n.createPursuit,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: QuietLuxury.label.copyWith(
        color: QuietLuxury.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? prefixText}) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      hintStyle: QuietLuxury.body.copyWith(color: QuietLuxury.textTertiary),
      prefixStyle: QuietLuxury.body.copyWith(color: QuietLuxury.textSecondary),
      filled: true,
      fillColor: QuietLuxury.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: QuietLuxury.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: QuietLuxury.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: QuietLuxury.positive.withValues(alpha: 0.5),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: QuietLuxury.negative),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PursuitCategory.values.map((category) {
        final isSelected = category == _selectedCategory;
        final categoryLabel = _getCategoryLabel(category);
        return Semantics(
          label: categoryLabel,
          selected: isSelected,
          button: true,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedCategory = category;
                _selectedEmoji = category.emoji;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? QuietLuxury.positive.withValues(alpha: 0.2)
                    : QuietLuxury.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? QuietLuxury.positive.withValues(alpha: 0.5)
                      : QuietLuxury.cardBorder,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    _getCategoryLabel(category),
                    style: QuietLuxury.label.copyWith(
                      color: isSelected
                          ? QuietLuxury.positive
                          : QuietLuxury.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getCategoryLabel(PursuitCategory category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case PursuitCategory.tech:
        return l10n.pursuitCategoryTech;
      case PursuitCategory.travel:
        return l10n.pursuitCategoryTravel;
      case PursuitCategory.home:
        return l10n.pursuitCategoryHome;
      case PursuitCategory.fashion:
        return l10n.pursuitCategoryFashion;
      case PursuitCategory.vehicle:
        return l10n.pursuitCategoryVehicle;
      case PursuitCategory.education:
        return l10n.pursuitCategoryEducation;
      case PursuitCategory.health:
        return l10n.pursuitCategoryHealth;
      case PursuitCategory.other:
        return l10n.pursuitCategoryOther;
    }
  }

  double _parseAmount(String value) {
    // Handle Turkish number format (1.234,56)
    final cleaned = value
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final l10n = AppLocalizations.of(context);
    final pursuitProvider = context.read<PursuitProvider>();
    final proProvider = context.read<ProProvider>();
    final currencyProvider = context.read<CurrencyProvider>();

    try {
      final targetAmount = _parseAmount(_targetController.text);
      final initialSavings = _parseAmount(_initialSavingsController.text);

      if (_isEditMode) {
        // Update existing pursuit
        final updated = widget.pursuit!.copyWith(
          name: _nameController.text.trim(),
          targetAmount: targetAmount,
          category: _selectedCategory,
          emoji: _selectedEmoji,
        );
        await pursuitProvider.updatePursuit(updated);
        HapticFeedback.mediumImpact();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // Create new pursuit
        final name = _nameController.text.trim();

        // Get smart emoji based on name, fallback to selected/category emoji
        final smartEmoji = getDefaultPursuitEmoji(name);
        final finalEmoji = hasSmartEmoji(name) ? smartEmoji : _selectedEmoji;

        final pursuit = Pursuit.create(
          name: name,
          targetAmount: targetAmount,
          currency: currencyProvider.currency.code,
          category: _selectedCategory,
          emoji: finalEmoji,
          initialSavings: initialSavings,
        );

        final success = await pursuitProvider.createPursuit(
          pursuit,
          isPremium: proProvider.isPro,
        );

        if (!success) {
          // Free tier limit reached - show upgrade dialog
          HapticFeedback.heavyImpact();
          setState(() => _isLoading = false);
          if (mounted) {
            Navigator.of(context).pop(); // Close the sheet first
            UpgradeDialog.show(context, l10n.pursuitLimitReachedFree);
          }
          return;
        }

        HapticFeedback.mediumImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.pursuitCreated),
              backgroundColor: QuietLuxury.positive,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: QuietLuxury.negative,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Input formatter for thousands separator
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) return newValue;

    final number = int.tryParse(digits);
    if (number == null) return oldValue;

    final formatted = formatWithThousandsSeparator(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String formatWithThousandsSeparator(int number) {
    final str = number.toString();
    final result = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        result.write('.');
      }
      result.write(str[i]);
    }
    return result.toString();
  }
}

/// Show the create pursuit sheet
Future<bool?> showCreatePursuitSheet(BuildContext context, {Pursuit? pursuit}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    barrierColor: Colors.black.withOpacity(0.85),
    backgroundColor: Colors.transparent,
    builder: (_) => CreatePursuitSheet(pursuit: pursuit),
  );
}
