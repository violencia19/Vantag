import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/quiet_luxury.dart';
import 'pursuit_progress_visual.dart';
import 'pool_allocation_dialog.dart';

/// Bottom sheet for adding savings to a pursuit
class AddSavingsSheet extends StatefulWidget {
  final Pursuit pursuit;
  final TransactionSource source;
  final double? prefilledAmount;

  const AddSavingsSheet({
    super.key,
    required this.pursuit,
    this.source = TransactionSource.manual,
    this.prefilledAmount,
  });

  @override
  State<AddSavingsSheet> createState() => _AddSavingsSheetState();
}

class _AddSavingsSheetState extends State<AddSavingsSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledAmount != null) {
      _amountController.text = widget.prefilledAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();
    final currencySymbol = currencyProvider.currency.symbol;

    // Quick amount chips
    final quickAmounts = [100.0, 500.0, 1000.0, 5000.0];

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

                // Pursuit info header
                _buildPursuitHeader(),
                const SizedBox(height: 24),

                // Title
                Text(l10n.addSavings, style: QuietLuxury.heading),
                const SizedBox(height: 16),

                // Amount input
                TextField(
                  controller: _amountController,
                  style: QuietLuxury.body.copyWith(
                    color: QuietLuxury.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: currencySymbol,
                    hintStyle: QuietLuxury.body.copyWith(
                      color: QuietLuxury.textTertiary,
                    ),
                    prefixStyle: QuietLuxury.body.copyWith(
                      color: QuietLuxury.textSecondary,
                    ),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autofocus: widget.prefilledAmount == null,
                ),
                const SizedBox(height: 16),

                // Quick amount chips
                Text(
                  l10n.quickAmounts,
                  style: QuietLuxury.label.copyWith(
                    color: QuietLuxury.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickAmounts.map((amount) {
                    return _QuickAmountChip(
                      amount: amount,
                      currencySymbol: currencySymbol,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _amountController.text = amount.toStringAsFixed(0);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Optional note
                TextField(
                  controller: _noteController,
                  keyboardType: TextInputType.text,
                  enableSuggestions: true,
                  autocorrect: false,
                  enableIMEPersonalizedLearning: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: QuietLuxury.body.copyWith(
                    color: QuietLuxury.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.addNote,
                    hintStyle: QuietLuxury.body.copyWith(
                      color: QuietLuxury.textTertiary,
                    ),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(
                      PhosphorIconsRegular.noteBlank,
                      color: QuietLuxury.textTertiary,
                      size: 20,
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Add button
                Semantics(
                  label: l10n.accessibilityAddSavings,
                  button: true,
                  child: SizedBox(
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
                        disabledBackgroundColor: QuietLuxury.positive.withValues(
                          alpha: 0.5,
                        ),
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(PhosphorIconsBold.plus, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.addSavings,
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPursuitHeader() {
    final currencyProvider = context.watch<CurrencyProvider>();

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          PursuitProgressVisual(
            progress: widget.pursuit.progressPercent,
            emoji: widget.pursuit.emoji,
            size: 48,
            animate: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pursuit.name,
                  style: QuietLuxury.body.copyWith(
                    color: QuietLuxury.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${currencyProvider.currency.symbol}${widget.pursuit.savedAmount.toStringAsFixed(0)}',
                      style: QuietLuxury.label.copyWith(
                        color: QuietLuxury.positive,
                      ),
                    ),
                    Text(
                      ' / ${currencyProvider.currency.symbol}${widget.pursuit.targetAmount.toStringAsFixed(0)}',
                      style: QuietLuxury.label,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: QuietLuxury.positive.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.pursuit.progressPercentDisplay}%',
              style: QuietLuxury.label.copyWith(
                color: QuietLuxury.positive,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _parseAmount(String value) {
    final cleaned = value
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> _onSubmit() async {
    final amount = _parseAmount(_amountController.text);
    if (amount <= 0) {
      HapticFeedback.heavyImpact();
      return;
    }

    final l10n = AppLocalizations.of(context);
    final pursuitProvider = context.read<PursuitProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final poolProvider = context.read<SavingsPoolProvider>();
    final symbol = currencyProvider.currency.symbol;

    // Check pool status
    final poolAvailable = poolProvider.available;
    final hasDebt = poolProvider.hasDebt;
    final debtAmount = poolProvider.shadowDebt;

    double finalAmount = amount;
    bool createDebt = false;
    bool isOneTimeIncome = false;

    // Case 1: Pool has debt - ask about source
    if (hasDebt) {
      final choice = await showDebtSourceDialog(
        context,
        debtAmount: debtAmount,
        currencySymbol: symbol,
      );

      if (choice == null || choice == DebtSourceChoice.cancel) {
        return; // User cancelled
      }

      if (choice == DebtSourceChoice.oneTimeIncome) {
        isOneTimeIncome = true;
        // Don't deduct from pool, add directly
      } else {
        // From savings - pool goes more negative
        createDebt = true;
      }
    }
    // Case 2: Pool is positive but amount > available
    else if (poolAvailable < amount) {
      final choice = await showPoolAllocationDialog(
        context,
        available: poolAvailable,
        requested: amount,
        currencySymbol: symbol,
      );

      if (choice == null || choice == PoolAllocationChoice.cancel) {
        return; // User cancelled
      }

      switch (choice) {
        case PoolAllocationChoice.fromPocket:
          // Zero out pool + add difference from pocket (use extraIncome source)
          isOneTimeIncome = true;
          break;
        case PoolAllocationChoice.createDebt:
          // Pool goes negative
          createDebt = true;
          break;
        case PoolAllocationChoice.availableOnly:
          // Only use available
          finalAmount = poolAvailable;
          break;
        case PoolAllocationChoice.cancel:
          return;
      }
    }

    if (finalAmount <= 0) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Deduct from pool (unless one-time income)
      if (!isOneTimeIncome) {
        if (createDebt) {
          // Create shadow debt
          await poolProvider.createShadowDebt(finalAmount, widget.pursuit.id);
        } else {
          // Normal allocation from pool
          await poolProvider.allocateToDream(finalAmount, widget.pursuit.id);
        }
      }

      // Add to pursuit
      final reachedTarget = await pursuitProvider.addSavings(
        widget.pursuit.id,
        finalAmount,
        source: isOneTimeIncome ? TransactionSource.manual : widget.source,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        currency: currencyProvider.currency.code,
      );

      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.savingsAdded),
            backgroundColor: QuietLuxury.positive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.of(context).pop(reachedTarget);
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
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

class _QuickAmountChip extends StatelessWidget {
  final double amount;
  final String currencySymbol;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.amount,
    required this.currencySymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = '+$currencySymbol${amount.toStringAsFixed(0)}';
    return Semantics(
      label: formattedAmount,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: QuietLuxury.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: QuietLuxury.cardBorder, width: 0.5),
          ),
          child: Text(
            formattedAmount,
            style: QuietLuxury.label.copyWith(
              color: QuietLuxury.positive,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Show the add savings sheet
Future<bool?> showAddSavingsSheet(
  BuildContext context, {
  required Pursuit pursuit,
  TransactionSource source = TransactionSource.manual,
  double? prefilledAmount,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    barrierColor: Colors.black.withOpacity(0.85),
    backgroundColor: Colors.transparent,
    builder: (_) => AddSavingsSheet(
      pursuit: pursuit,
      source: source,
      prefilledAmount: prefilledAmount,
    ),
  );
}
