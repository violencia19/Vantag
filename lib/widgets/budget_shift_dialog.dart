import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/savings_pool.dart';
import '../providers/savings_pool_provider.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

/// Bütçe kaydırma diyaloğu
/// Kullanıcı havuzda yetersiz bakiye olduğunda hangi bütçeden kaydıracağını seçer
class BudgetShiftDialog extends StatefulWidget {
  final double shortfall; // Eksik tutar
  final double totalAmount; // Toplam istenen tutar
  final String dreamId;
  final String dreamName;
  final String currencySymbol;

  const BudgetShiftDialog({
    super.key,
    required this.shortfall,
    required this.totalAmount,
    required this.dreamId,
    required this.dreamName,
    required this.currencySymbol,
  });

  /// Diyaloğu göster ve sonucu döndür
  static Future<BudgetShiftResult?> show({
    required BuildContext context,
    required double shortfall,
    required double totalAmount,
    required String dreamId,
    required String dreamName,
    required String currencySymbol,
  }) {
    return showModalBottomSheet<BudgetShiftResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => BudgetShiftDialog(
        shortfall: shortfall,
        totalAmount: totalAmount,
        dreamId: dreamId,
        dreamName: dreamName,
        currencySymbol: currencySymbol,
      ),
    );
  }

  @override
  State<BudgetShiftDialog> createState() => _BudgetShiftDialogState();
}

class _BudgetShiftDialogState extends State<BudgetShiftDialog> {
  BudgetShiftSource? _selectedSource;
  bool _isLoading = false;

  List<_BudgetOption> get _options {
    final l10n = AppLocalizations.of(context);
    final pool = context.read<SavingsPoolProvider>();

    return [
      _BudgetOption(
        source: BudgetShiftSource.food,
        emoji: '🍔',
        label: l10n.budgetShiftFromFood,
      ),
      _BudgetOption(
        source: BudgetShiftSource.entertainment,
        emoji: '🎬',
        label: l10n.budgetShiftFromEntertainment,
      ),
      _BudgetOption(
        source: BudgetShiftSource.clothing,
        emoji: '👕',
        label: l10n.budgetShiftFromClothing,
      ),
      _BudgetOption(
        source: BudgetShiftSource.transport,
        emoji: '🚗',
        label: l10n.budgetShiftFromTransport,
      ),
      _BudgetOption(
        source: BudgetShiftSource.shopping,
        emoji: '🛒',
        label: l10n.budgetShiftFromShopping,
      ),
      _BudgetOption(
        source: BudgetShiftSource.extraIncome,
        emoji: '💰',
        label: l10n.extraIncome,
        isHighlighted: true,
      ),
      if (pool.canUseJoker)
        _BudgetOption(
          source: BudgetShiftSource.joker,
          emoji: '🃏',
          label: l10n.useJoker,
          isJoker: true,
        ),
    ];
  }

  Future<void> _confirm() async {
    if (_selectedSource == null) return;

    setState(() => _isLoading = true);

    final poolProvider = context.read<SavingsPoolProvider>();

    // Allocation yap
    final result = await poolProvider.allocateToDream(
      widget.totalAmount,
      widget.dreamId,
      source: _selectedSource,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context, BudgetShiftResult(
        success: true,
        source: _selectedSource!,
        amount: widget.shortfall,
      ));
    } else if (result.isJokerAlreadyUsed) {
      _showError(AppLocalizations.of(context).jokerUsed);
    } else {
      _showError(result.errorMessage ?? 'Error');
    }
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

  void _createDebt() async {
    setState(() => _isLoading = true);

    final poolProvider = context.read<SavingsPoolProvider>();
    await poolProvider.createShadowDebt(widget.totalAmount, widget.dreamId);

    if (!mounted) return;

    setState(() => _isLoading = false);

    HapticFeedback.heavyImpact();
    Navigator.pop(context, BudgetShiftResult(
      success: true,
      source: null,
      amount: widget.shortfall,
      isDebt: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Dream icon & name
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('✨', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.dreamName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.currencySymbol}${formatTurkishCurrency(widget.totalAmount, decimalDigits: 0, showDecimals: false)} ekleniyor',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Question
              Text(
                l10n.budgetShiftQuestion(
                  '${widget.currencySymbol}${formatTurkishCurrency(widget.shortfall, decimalDigits: 0, showDecimals: false)}',
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Havuzda yeterli bakiye yok. Bu parayı nereden kaydırmak istersin?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Options
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _options.map((option) {
                  final isSelected = _selectedSource == option.source;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedSource = option.source);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (option.isJoker
                                ? AppColors.warning.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.15))
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (option.isJoker ? AppColors.warning : AppColors.primary)
                              : AppColors.cardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(option.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? (option.isJoker ? AppColors.warning : AppColors.primary)
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedSource != null && !_isLoading ? _confirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.surfaceLight,
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
                      : const Text(
                          'Onayla',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Create debt option
              Center(
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _createDebt,
                  icon: Icon(
                    PhosphorIconsDuotone.warning,
                    size: 18,
                    color: AppColors.error,
                  ),
                  label: Text(
                    l10n.createShadowDebt,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetOption {
  final BudgetShiftSource source;
  final String emoji;
  final String label;
  final bool isHighlighted;
  final bool isJoker;

  const _BudgetOption({
    required this.source,
    required this.emoji,
    required this.label,
    this.isHighlighted = false,
    this.isJoker = false,
  });
}

/// Budget shift sonucu
class BudgetShiftResult {
  final bool success;
  final BudgetShiftSource? source;
  final double amount;
  final bool isDebt;

  const BudgetShiftResult({
    required this.success,
    this.source,
    required this.amount,
    this.isDebt = false,
  });
}
