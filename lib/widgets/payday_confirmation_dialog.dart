import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../providers/finance_provider.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

/// Dialog shown on payday to confirm salary received and update balance
class PaydayConfirmationDialog extends StatefulWidget {
  final VoidCallback? onConfirmed;
  final VoidCallback? onSkipped;

  const PaydayConfirmationDialog({super.key, this.onConfirmed, this.onSkipped});

  /// Show the payday confirmation dialog if today is payday
  static Future<void> showIfPayday(BuildContext context) async {
    final financeProvider = context.read<FinanceProvider>();
    final profile = financeProvider.userProfile;

    if (profile == null) return;
    if (profile.salaryDay == null) return;
    if (!profile.isPayday) return;
    if (profile.isSalaryConfirmedThisMonth) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaydayConfirmationDialog(
        onConfirmed: () => Navigator.pop(context),
        onSkipped: () => Navigator.pop(context),
      ),
    );
  }

  @override
  State<PaydayConfirmationDialog> createState() =>
      _PaydayConfirmationDialogState();
}

class _PaydayConfirmationDialogState extends State<PaydayConfirmationDialog>
    with SingleTickerProviderStateMixin {
  final _balanceController = TextEditingController();
  final _profileService = ProfileService();
  bool _showBalanceInput = false;
  bool _isLoading = false;

  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebrationController.forward();

    // Pre-fill with current balance + expected salary
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final financeProvider = context.read<FinanceProvider>();
      final profile = financeProvider.userProfile;
      if (profile != null) {
        final currentBalance = profile.currentBalance ?? 0;
        final salary = profile.monthlyIncome;
        final newBalance = currentBalance + salary;
        _balanceController.text = formatTurkishCurrency(
          newBalance,
          decimalDigits: 0,
        );
      }
    });
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _confirmSalary() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.heavyImpact();

    try {
      final financeProvider = context.read<FinanceProvider>();
      final profile = financeProvider.userProfile;

      double? newBalance;
      if (_showBalanceInput && _balanceController.text.isNotEmpty) {
        newBalance = parseTurkishCurrency(_balanceController.text);
      } else if (profile != null) {
        // Auto-add salary to balance
        final currentBalance = profile.currentBalance ?? 0;
        newBalance = currentBalance + profile.monthlyIncome;
      }

      // Record salary confirmation
      final updatedProfile = await _profileService.confirmSalaryReceived(
        newBalance: newBalance,
      );

      if (updatedProfile != null) {
        financeProvider.setUserProfile(updatedProfile);
      }

      // Add salary as income record
      final income = Income.salary(
        amount: profile?.monthlyIncome ?? 0,
        title: AppLocalizations.of(context).incomeTypeSalary,
        currencyCode: profile?.incomeSources.firstOrNull?.currencyCode ?? 'TRY',
      );
      await _profileService.addIncome(income);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).paydayCelebration),
          backgroundColor: context.vantColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      widget.onConfirmed?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: context.vantColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skip() {
    HapticFeedback.lightImpact();
    widget.onSkipped?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.vantColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.vantColors.cardBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration icon
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _celebrationController,
                    curve: Curves.elasticOut,
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.vantColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      CupertinoIcons.gift_fill,
                      size: 40,
                      color: context.vantColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  l10n.paydayTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: context.vantColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Message
                Text(
                  l10n.paydayMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.vantColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Optional balance input
                if (_showBalanceInput) ...[
                  Text(
                    l10n.paydayNewBalance,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.vantColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _balanceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [TurkishCurrencyInputFormatter()],
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: context.vantColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: context.vantColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: context.vantColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixText: '\u20BA ',
                      prefixStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Update balance toggle
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showBalanceInput = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: context.vantColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.pencil,
                            size: 18,
                            color: context.vantColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.paydayUpdateBalance,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: context.vantColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmSalary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.vantColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(CupertinoIcons.checkmark_alt, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.paydayConfirm,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Skip button
                TextButton(
                  onPressed: _isLoading ? null : _skip,
                  child: Text(
                    l10n.paydaySkip,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.vantColors.textTertiary,
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
}
