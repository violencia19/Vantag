import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import 'turkish_currency_input.dart';

/// Add new subscription bottom sheet
class AddSubscriptionSheet extends StatefulWidget {
  final Function(Subscription) onAdd;

  const AddSubscriptionSheet({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends State<AddSubscriptionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _subscriptionService = SubscriptionService();

  int _selectedDay = DateTime.now().day;
  int _selectedColorIndex = 0;
  String _selectedCategory = 'Eğlence';
  bool _autoRecord = true;
  bool _isLoading = false;

  static const List<String> _categories = [
    'Eğlence',
    'Dijital',
    'Sağlık',
    'Eğitim',
    'Spor',
    'Haberleşme',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _loadNextColorIndex();
  }

  Future<void> _loadNextColorIndex() async {
    final index = await _subscriptionService.getNextColorIndex();
    if (mounted) {
      setState(() => _selectedColorIndex = index);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final amount = parseTurkishCurrency(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterValidAmount)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final subscription = Subscription(
      id: _subscriptionService.generateId(),
      name: _nameController.text.trim(),
      amount: amount,
      renewalDay: _selectedDay,
      category: _selectedCategory,
      colorIndex: _selectedColorIndex,
      autoRecord: _autoRecord,
      createdAt: DateTime.now(),
    );

    HapticFeedback.mediumImpact();
    widget.onAdd(subscription);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.gradientMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          l10n.newSubscription,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Subscription name
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          enableSuggestions: true,
                          autocorrect: false,
                          enableIMEPersonalizedLearning: true,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(l10n.subscriptionName, l10n.subscriptionNameHint),
                          validator: (v) => v?.trim().isEmpty == true ? l10n.nameRequired : null,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),

                        // Monthly amount
                        TextFormField(
                          controller: _amountController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(l10n.monthlyAmountLabel, l10n.amountHint),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [TurkishCurrencyInputFormatter()],
                          validator: (v) => v?.isEmpty == true ? l10n.amountRequired : null,
                        ),
                        const SizedBox(height: 16),

                        // Category and renewal day
                        Row(
                          children: [
                            // Category
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCategory,
                                        isExpanded: true,
                                        dropdownColor: AppColors.gradientMid,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                        items: _categories.map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        )).toList(),
                                        onChanged: (v) {
                                          if (v != null) setState(() => _selectedCategory = v);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Renewal day
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.renewalDay,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: _selectedDay,
                                        isExpanded: true,
                                        dropdownColor: AppColors.gradientMid,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                        items: List.generate(31, (i) => i + 1)
                                            .map((d) => DropdownMenuItem(
                                                  value: d,
                                                  child: Text('$d'),
                                                ))
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) setState(() => _selectedDay = v);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Color picker
                        Text(
                          l10n.color,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            SubscriptionColors.count,
                            (index) => GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedColorIndex = index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: SubscriptionColors.get(index),
                                  shape: BoxShape.circle,
                                  border: _selectedColorIndex == index
                                      ? Border.all(color: Colors.white, width: 2.5)
                                      : null,
                                  boxShadow: _selectedColorIndex == index
                                      ? [
                                          BoxShadow(
                                            color: SubscriptionColors.get(index).withValues(alpha: 0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Auto record toggle
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIconsDuotone.sparkle,
                                size: 20,
                                color: _autoRecord ? AppColors.primary : AppColors.textTertiary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.autoRecord,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      l10n.autoRecordDescription,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _autoRecord,
                                onChanged: (v) => setState(() => _autoRecord = v),
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    l10n.addSubscription,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
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

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
      filled: true,
      fillColor: AppColors.surface.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
