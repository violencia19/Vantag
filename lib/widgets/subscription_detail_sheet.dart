import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';
import 'turkish_currency_input.dart';

/// Subscription detail and edit bottom sheet
class SubscriptionDetailSheet extends StatefulWidget {
  final Subscription subscription;
  final Function(Subscription) onUpdate;
  final VoidCallback onDelete;

  const SubscriptionDetailSheet({
    super.key,
    required this.subscription,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<SubscriptionDetailSheet> createState() => _SubscriptionDetailSheetState();
}

class _SubscriptionDetailSheetState extends State<SubscriptionDetailSheet> {
  final _subscriptionManager = SubscriptionManager();
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late int _selectedDay;
  late int _selectedColorIndex;
  late String _selectedCategory;
  late bool _autoRecord;

  double? _workHours;
  double? _workDays;

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
    _initControllers();
    _loadWorkTime();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.subscription.name);
    _amountController = TextEditingController(
      text: formatTurkishCurrency(widget.subscription.amount),
    );
    _selectedDay = widget.subscription.renewalDay;
    _selectedColorIndex = widget.subscription.colorIndex;
    _selectedCategory = widget.subscription.category;
    _autoRecord = widget.subscription.autoRecord;
  }

  Future<void> _loadWorkTime() async {
    final hours = await _subscriptionManager.calculateWorkHours(widget.subscription.amount);
    final days = await _subscriptionManager.calculateWorkDays(widget.subscription.amount);

    if (mounted) {
      setState(() {
        _workHours = hours;
        _workDays = days;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    HapticFeedback.selectionClick();
    setState(() => _isEditing = !_isEditing);
  }

  void _save() {
    final amount = parseTurkishCurrency(_amountController.text);
    if (amount == null || amount <= 0 || _nameController.text.trim().isEmpty) {
      return;
    }

    final updated = widget.subscription.copyWith(
      name: _nameController.text.trim(),
      amount: amount,
      renewalDay: _selectedDay,
      colorIndex: _selectedColorIndex,
      category: _selectedCategory,
      autoRecord: _autoRecord,
    );

    HapticFeedback.mediumImpact();
    widget.onUpdate(updated);
    Navigator.pop(context);
  }

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.gradientMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deleteSubscription,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          l10n.deleteSubscriptionConfirm(widget.subscription.name),
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close sheet
              widget.onDelete();
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Color(0xFFE74C3C)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sub = widget.subscription;

    return Container(
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
                  child: _isEditing ? _buildEditView(l10n) : _buildDetailView(sub, l10n),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailView(Subscription sub, AppLocalizations l10n) {
    return Column(
      children: [
        // Title and color
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: sub.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: sub.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: sub.color.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub.category,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Edit button
            IconButton(
              onPressed: _toggleEdit,
              icon: const Icon(PhosphorIconsDuotone.pencilSimple),
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Amount card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sub.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.monthlyAmount,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatTurkishCurrency(sub.amount, decimalDigits: 2)} ₺',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.everyMonth,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      '${sub.renewalDay}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Statistics
        Row(
          children: [
            Expanded(child: _buildStatCard(
              l10n.subscriptionDuration,
              l10n.daysCount(sub.daysSinceSubscription),
              PhosphorIconsDuotone.calendar,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              l10n.totalPaid,
              '${formatTurkishCurrency(sub.totalPaid, decimalDigits: 0)} ₺',
              PhosphorIconsDuotone.creditCard,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(
              l10n.workHours,
              _workHours != null ? l10n.hoursCount(_workHours!.toStringAsFixed(1)) : '-',
              PhosphorIconsDuotone.clock,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              l10n.workDays,
              _workDays != null ? l10n.daysCountDecimal(_workDays!.toStringAsFixed(2)) : '-',
              PhosphorIconsDuotone.briefcase,
            )),
          ],
        ),
        const SizedBox(height: 16),

        // Auto record status
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                sub.autoRecord ? PhosphorIconsDuotone.checkCircle : PhosphorIconsDuotone.xCircle,
                size: 20,
                color: sub.autoRecord ? const Color(0xFF2ECC71) : AppColors.textTertiary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sub.autoRecord
                      ? l10n.autoRecordOn
                      : l10n.autoRecordOff,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Delete button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _confirmDelete,
            icon: const Icon(PhosphorIconsDuotone.trash, size: 18),
            label: Text(l10n.deleteSubscription),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE74C3C),
              side: const BorderSide(color: Color(0xFFE74C3C), width: 1),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Text(
              l10n.editSubscription,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _toggleEdit,
              child: Text(
                l10n.cancel,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Subscription name
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(l10n.subscriptionName),
        ),
        const SizedBox(height: 16),

        // Monthly amount
        TextFormField(
          controller: _amountController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(l10n.monthlyAmountLabel),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [TurkishCurrencyInputFormatter()],
        ),
        const SizedBox(height: 16),

        // Category and renewal day
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                l10n.category,
                _selectedCategory,
                _categories,
                (v) => setState(() => _selectedCategory = v),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDayDropdown(l10n),
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
                child: Text(
                  l10n.autoRecord,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
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

        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              l10n.saveChanges,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.gradientMid,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              items: items.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              )).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayDropdown(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.renewalDay,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              items: List.generate(31, (i) => i + 1)
                  .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedDay = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
