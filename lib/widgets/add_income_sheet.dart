import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../providers/providers.dart';
import '../utils/currency_utils.dart';

/// Bottom sheet for adding one-time income (bonus, gift, refund, etc.)
class AddIncomeSheet extends StatefulWidget {
  final VoidCallback? onIncomeAdded;

  const AddIncomeSheet({super.key, this.onIncomeAdded});

  @override
  State<AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends State<AddIncomeSheet>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _profileService = ProfileService();

  IncomeType _selectedType = IncomeType.bonus;
  bool _isLoading = false;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  double? get _amount {
    final text = _amountController.text.trim();
    if (text.isEmpty) return null;
    return parseTurkishCurrency(text);
  }

  bool get _canSave => _amount != null && _amount! > 0;

  Future<void> _saveIncome() async {
    if (!_canSave || _isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final financeProvider = context.read<FinanceProvider>();
      final profile = financeProvider.userProfile;
      final currencyCode =
          profile?.incomeSources.firstOrNull?.currencyCode ?? 'TRY';

      // Create income record
      final income = Income(
        id: Income.generateId(),
        title: _selectedType.getLocalizedLabel(AppLocalizations.of(context)),
        amount: _amount!,
        currencyCode: currencyCode,
        type: _selectedType,
        date: DateTime.now(),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      // Save income to storage
      await _profileService.addIncome(income);

      // Update balance if tracking
      if (profile?.currentBalance != null) {
        await _profileService.addToBalance(_amount!);
        // Refresh provider
        final newProfile = await _profileService.getProfile();
        if (newProfile != null) {
          financeProvider.setUserProfile(newProfile);
        }
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).incomeAdded),
          backgroundColor: context.vantColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      widget.onIncomeAdded?.call();
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.vantColors.surface.withValues(alpha: 0.95),
            context.vantColors.background.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.isDarkMode ? const Color(0x15FFFFFF) : const Color(0x15000000), width: 1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.vantColors.textTertiary.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.vantColors.success.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_down_circle_fill,
                          color: context.vantColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.addIncomeTitle,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: context.vantColors.textPrimary,
                              ),
                            ),
                            Text(
                              l10n.addIncomeSubtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.vantColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Income Type Selector
                  Text(
                    l10n.incomeType,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.vantColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTypeSelector(),
                  const SizedBox(height: 20),

                  // Amount Input
                  Text(
                    l10n.incomeAmount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.vantColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [TurkishCurrencyInputFormatter()],
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: context.vantColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: context.vantColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: context.vantColors.surfaceInput,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      prefixText: '\u20BA ',
                      prefixStyle: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notes Input (optional)
                  Text(
                    l10n.incomeNotes,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.vantColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.vantColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.incomeNotesHint,
                      hintStyle: TextStyle(
                        color: context.vantColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: context.vantColors.surfaceInput,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  RepaintBoundary(
                    child: GestureDetector(
                      onTapDown: _canSave && !_isLoading
                          ? (_) => _buttonAnimationController.forward()
                          : null,
                      onTapUp: _canSave && !_isLoading
                          ? (_) {
                              _buttonAnimationController.reverse();
                              _saveIncome();
                            }
                          : null,
                      onTapCancel: _canSave && !_isLoading
                          ? () => _buttonAnimationController.reverse()
                          : null,
                      child: ScaleTransition(
                        scale: _buttonScaleAnimation,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _canSave && !_isLoading
                                ? context.vantColors.success
                                : context.vantColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _canSave && !_isLoading
                                ? [
                                    BoxShadow(
                                      color: context.vantColors.success
                                          .withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: _isLoading
                              ? Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        context.vantColors.background,
                                      ),
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.add,
                                      size: 20,
                                      color: _canSave
                                          ? context.vantColors.background
                                          : context.vantColors.textTertiary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.addIncome,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _canSave
                                            ? context.vantColors.background
                                            : context.vantColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final l10n = AppLocalizations.of(context);
    final types = [
      IncomeType.bonus,
      IncomeType.gift,
      IncomeType.refund,
      IncomeType.freelance,
      IncomeType.other,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedType = type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? type.color.withValues(alpha: 0.15)
                  : context.vantColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? type.color : context.vantColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  size: 18,
                  color: isSelected
                      ? type.color
                      : context.vantColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  type.getLocalizedLabel(l10n),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? type.color
                        : context.vantColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
