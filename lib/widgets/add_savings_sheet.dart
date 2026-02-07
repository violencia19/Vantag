import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
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

  List<double> _getQuickAmounts(String currencyCode) {
    switch (currencyCode) {
      case 'TRY': return [100.0, 500.0, 1000.0, 5000.0];
      case 'USD': return [5.0, 25.0, 50.0, 200.0];
      case 'EUR': return [5.0, 20.0, 50.0, 200.0];
      case 'GBP': return [5.0, 20.0, 50.0, 150.0];
      case 'SAR': return [20.0, 100.0, 200.0, 1000.0];
      default: return [5.0, 25.0, 50.0, 200.0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();
    final currencySymbol = currencyProvider.currency.symbol;

    // Currency-aware quick amount chips
    final quickAmounts = _getQuickAmounts(currencyProvider.code);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: VantBlur.medium, sigmaY: VantBlur.medium),
        child: Container(
      decoration: BoxDecoration(
        color: VantColors.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0x15FFFFFF), width: 1),
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
                      color: context.vantColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Pursuit info header
                _buildPursuitHeader(),
                const SizedBox(height: 24),

                // Title
                Text(l10n.addSavings, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: Color(0xFFFAFAFA))),
                const SizedBox(height: 16),

                // Amount input
                TextField(
                  controller: _amountController,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA1A1AA)).copyWith(
                    color: context.vantColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: currencySymbol,
                    hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA1A1AA)).copyWith(
                      color: context.vantColors.textTertiary,
                    ),
                    prefixStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA1A1AA)).copyWith(
                      color: context.vantColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: VantColors.surfaceInput,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: context.vantColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.vantColors.success.withValues(alpha: 0.5),
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF71717A)).copyWith(
                    color: context.vantColors.textSecondary,
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA1A1AA)).copyWith(
                    color: context.vantColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.addNote,
                    hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA1A1AA)).copyWith(
                      color: context.vantColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: VantColors.surfaceInput,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: context.vantColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.vantColors.success.withValues(alpha: 0.5),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.doc_text,
                      color: context.vantColors.textTertiary,
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
                        backgroundColor: context.vantColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: context.vantColors.success
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.add, size: 18),
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
    ),
    ),
    );
  }

  Widget _buildPursuitHeader() {
    final currencyProvider = context.watch<CurrencyProvider>();

    return VGlassCard(
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA1A1AA)).copyWith(
                    color: context.vantColors.textPrimary,
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
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF71717A)).copyWith(
                        color: context.vantColors.success,
                      ),
                    ),
                    Text(
                      ' / ${currencyProvider.currency.symbol}${widget.pursuit.targetAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF71717A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.vantColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.pursuit.progressPercentDisplay}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF71717A)).copyWith(
                color: context.vantColors.success,
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
            backgroundColor: context.vantColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
            backgroundColor: context.vantColors.error,
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
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.vantColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.vantColors.cardBorder, width: 0.5),
          ),
          child: Text(
            formattedAmount,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF71717A)).copyWith(
              color: context.vantColors.success,
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
    barrierColor: Colors.black.withValues(alpha: 0.85),
    backgroundColor: Colors.transparent,
    builder: (_) => AddSavingsSheet(
      pursuit: pursuit,
      source: source,
      prefilledAmount: prefilledAmount,
    ),
  );
}
