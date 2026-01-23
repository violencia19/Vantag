import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/quiet_luxury.dart';
import 'pursuit_progress_visual.dart';
import 'budget_shift_dialog.dart';

/// Bottom sheet for redirecting cancelled expense to a pursuit
class RedirectSavingsSheet extends StatefulWidget {
  final double amount;
  final String currency;

  const RedirectSavingsSheet({
    super.key,
    required this.amount,
    required this.currency,
  });

  @override
  State<RedirectSavingsSheet> createState() => _RedirectSavingsSheetState();
}

class _RedirectSavingsSheetState extends State<RedirectSavingsSheet> {
  String? _selectedPursuitId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pursuitProvider = context.watch<PursuitProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final pursuits = pursuitProvider.activePursuits;

    final formattedAmount =
        '${currencyProvider.currency.symbol}${widget.amount.toStringAsFixed(0)}';

    return Container(
      decoration: const BoxDecoration(
        color: QuietLuxury.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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

              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: QuietLuxury.positive.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIconsDuotone.piggyBank,
                      color: QuietLuxury.positive,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.redirectSavings,
                          style: QuietLuxury.heading.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.redirectSavingsMessage(formattedAmount),
                          style: QuietLuxury.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pursuit list
              if (pursuits.isEmpty)
                _buildEmptyState(l10n)
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: pursuits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final pursuit = pursuits[index];
                      final isSelected = pursuit.id == _selectedPursuitId;

                      return _PursuitSelectionTile(
                        pursuit: pursuit,
                        isSelected: isSelected,
                        currencySymbol: currencyProvider.currency.symbol,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedPursuitId = pursuit.id);
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  // Skip button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: QuietLuxury.textSecondary,
                        side: BorderSide(color: QuietLuxury.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.skipRedirect),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedPursuitId == null || _isLoading
                          ? null
                          : _onAddSavings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QuietLuxury.positive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: QuietLuxury.positive
                            .withValues(alpha: 0.3),
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
                              l10n.addSavings,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: QuietLuxury.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuietLuxury.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(
            PhosphorIconsDuotone.star,
            size: 48,
            color: QuietLuxury.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.emptyPursuitsTitle,
            style: QuietLuxury.body.copyWith(color: QuietLuxury.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.emptyPursuitsMessage,
            style: QuietLuxury.label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _onAddSavings() async {
    if (_selectedPursuitId == null) return;

    setState(() => _isLoading = true);

    final savingsPoolProvider = context.read<SavingsPoolProvider>();
    final pursuitProvider = context.read<PursuitProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final l10n = AppLocalizations.of(context);

    // Get pursuit details for dialog
    final pursuit = pursuitProvider.getPursuitById(_selectedPursuitId!);
    if (pursuit == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Try to allocate from pool
      final result = await savingsPoolProvider.allocateToDream(
        widget.amount,
        _selectedPursuitId!,
      );

      if (result.isSuccess) {
        // Also update pursuit's saved amount
        final reachedTarget = await pursuitProvider.addSavings(
          _selectedPursuitId!,
          widget.amount,
          source: TransactionSource.expenseCancelled,
          currency: widget.currency,
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
      } else if (result.needsBudgetShift || result.needsFullSource) {
        // Show budget shift dialog
        if (mounted) {
          Navigator.of(context).pop(); // Close redirect sheet first

          final shiftResult = await BudgetShiftDialog.show(
            context: context,
            shortfall: result.shortfall ?? widget.amount,
            totalAmount: widget.amount,
            dreamId: _selectedPursuitId!,
            dreamName: pursuit.name,
            currencySymbol: currencyProvider.currency.symbol,
          );

          if (shiftResult != null && shiftResult.success) {
            // Allocation was done in dialog, now update pursuit
            await pursuitProvider.addSavings(
              _selectedPursuitId!,
              widget.amount,
              source: TransactionSource.expenseCancelled,
              currency: widget.currency,
            );
          }
        }
      } else {
        // Other error
        HapticFeedback.heavyImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Error'),
              backgroundColor: QuietLuxury.negative,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _PursuitSelectionTile extends StatelessWidget {
  final Pursuit pursuit;
  final bool isSelected;
  final String currencySymbol;
  final VoidCallback onTap;

  const _PursuitSelectionTile({
    required this.pursuit,
    required this.isSelected,
    required this.currencySymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? QuietLuxury.positive.withValues(alpha: 0.15)
              : QuietLuxury.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? QuietLuxury.positive.withValues(alpha: 0.5)
                : QuietLuxury.cardBorder,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Progress visual
            PursuitCircularProgress(
              progress: pursuit.progressPercent,
              emoji: pursuit.emoji,
              size: 44,
              strokeWidth: 3,
              progressColor: isSelected
                  ? QuietLuxury.positive
                  : QuietLuxury.textTertiary,
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pursuit.name,
                    style: QuietLuxury.body.copyWith(
                      color: QuietLuxury.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$currencySymbol${pursuit.savedAmount.toStringAsFixed(0)} / $currencySymbol${pursuit.targetAmount.toStringAsFixed(0)}',
                    style: QuietLuxury.label,
                  ),
                ],
              ),
            ),
            // Progress badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? QuietLuxury.positive.withValues(alpha: 0.2)
                    : QuietLuxury.cardBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${pursuit.progressPercentDisplay}%',
                style: QuietLuxury.label.copyWith(
                  color: isSelected
                      ? QuietLuxury.positive
                      : QuietLuxury.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show the redirect savings sheet
Future<bool?> showRedirectSavingsSheet(
  BuildContext context, {
  required double amount,
  required String currency,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => RedirectSavingsSheet(amount: amount, currency: currency),
  );
}
