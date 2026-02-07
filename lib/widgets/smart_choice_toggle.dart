import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import 'turkish_currency_input.dart';
import 'package:vantag/l10n/app_localizations.dart';

/// Wealth Coach: Smart Choice Toggle Widget
/// Glassmorphism tasarım ile "Aslında şunu alacaktım" seçeneği
class SmartChoiceToggle extends StatefulWidget {
  final String? selectedCategory;
  final double currentAmount;
  final ValueChanged<double?> onSavedFromChanged;
  final bool isEnabled;

  const SmartChoiceToggle({
    super.key,
    this.selectedCategory,
    required this.currentAmount,
    required this.onSavedFromChanged,
    this.isEnabled = true,
  });

  @override
  State<SmartChoiceToggle> createState() => _SmartChoiceToggleState();
}

class _SmartChoiceToggleState extends State<SmartChoiceToggle>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final _alternativeController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _expandAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Kategori değişince varsayılan öneriyi güncelle
    _updateDefaultThreshold();
  }

  @override
  void didUpdateWidget(SmartChoiceToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _updateDefaultThreshold();
    }

    // Form temizlendiğinde toggle'ı kapat ve sıfırla
    // currentAmount 0 olduğunda veya kategori null olduğunda
    if ((oldWidget.currentAmount > 0 && widget.currentAmount == 0) ||
        (oldWidget.selectedCategory != null &&
            widget.selectedCategory == null)) {
      if (_isExpanded) {
        _isExpanded = false;
        _animController.reverse();
        _alternativeController.clear();
        // Build sonrasında callback çağır (setState during build hatasını önler)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSavedFromChanged(null);
        });
      }
    }
  }

  void _updateDefaultThreshold() {
    if (widget.selectedCategory != null &&
        _alternativeController.text.isEmpty) {
      final defaultThreshold = CategoryThresholds.getDefault(
        widget.selectedCategory!,
      );
      // Varsayılan değeri sadece şu anki tutardan büyükse öner
      if (defaultThreshold > widget.currentAmount && widget.currentAmount > 0) {
        _alternativeController.text = formatTurkishCurrency(defaultThreshold);
      }
    }
  }

  @override
  void dispose() {
    _alternativeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!widget.isEnabled) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animController.forward();
      _updateDefaultThreshold();
    } else {
      _animController.reverse();
      widget.onSavedFromChanged(null);
    }
  }

  void _onAlternativeAmountChanged(String value) {
    final amount = parseTurkishCurrency(value);
    if (amount != null && amount > widget.currentAmount) {
      widget.onSavedFromChanged(amount);
      HapticFeedback.selectionClick();
    } else {
      widget.onSavedFromChanged(null);
    }
  }

  double? get _savedAmount {
    final alternativeAmount = parseTurkishCurrency(_alternativeController.text);
    if (alternativeAmount != null && alternativeAmount > widget.currentAmount) {
      return alternativeAmount - widget.currentAmount;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Golden glow efekti (aktifken)
            boxShadow: _isExpanded
                ? [
                    BoxShadow(
                      color: VantColors.medalGold.withValues(
                        alpha: 0.3 * _glowAnimation.value,
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: _isExpanded
                      ? VantColors.medalGold.withValues(alpha: 0.1)
                      : context.vantColors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isExpanded
                        ? VantColors.medalGold.withValues(alpha: 0.5)
                        : context.vantColors.cardBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Toggle Header
                    InkWell(
                      onTap: _toggle,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icon
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _isExpanded
                                    ? VantColors.medalGold.withValues(alpha: 0.2)
                                    : context.vantColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _isExpanded
                                    ? CupertinoIcons.arrow_down_right
                                    : CupertinoIcons.lightbulb,
                                color: _isExpanded
                                    ? VantColors.medalGold
                                    : context.vantColors.textSecondary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Text
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final l10n = AppLocalizations.of(context);
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.mindfulChoice,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _isExpanded
                                              ? VantColors.medalGold
                                              : context.vantColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isExpanded
                                            ? l10n.mindfulChoiceExpandedDesc
                                            : l10n.mindfulChoiceCollapsedDesc,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              context.vantColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            // Toggle indicator
                            AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                CupertinoIcons.chevron_down,
                                color: _isExpanded
                                    ? VantColors.medalGold
                                    : context.vantColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expanded content
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Divider
                            Container(
                              height: 1,
                              color: context.vantColors.cardBorder,
                            ),
                            const SizedBox(height: 16),
                            // Alternative amount input
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return TextField(
                                  controller: _alternativeController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: TextStyle(
                                    color: context.vantColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: l10n.mindfulChoiceAmountLabel,
                                    labelStyle: TextStyle(
                                      color: context.vantColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                    hintText: l10n.mindfulChoiceAmountHint(
                                      formatTurkishCurrency(
                                        CategoryThresholds.getDefault(
                                          widget.selectedCategory ?? 'Diğer',
                                        ),
                                      ),
                                    ),
                                    hintStyle: TextStyle(
                                      color: context.vantColors.textTertiary,
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: context.vantColors.background
                                        .withValues(alpha: 0.5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: Icon(
                                      CupertinoIcons.bag,
                                      color: context.vantColors.textTertiary,
                                      size: 20,
                                    ),
                                  ),
                                  inputFormatters: [
                                    TurkishCurrencyInputFormatter(),
                                  ],
                                  onChanged: _onAlternativeAmountChanged,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            // Freedom Preview
                            if (_savedAmount != null && _savedAmount! > 0)
                              _buildFreedomPreview(context),
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
      },
    );
  }

  Widget _buildFreedomPreview(BuildContext context) {
    final saved = _savedAmount!;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            VantColors.medalGold.withValues(alpha: 0.15),
            VantColors.categoryHealth.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VantColors.medalGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: VantColors.medalGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.shield_lefthalf_fill,
              color: VantColors.medalGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mindfulChoiceSavings(
                    formatTurkishCurrency(saved, decimalDigits: 0),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: VantColors.medalGold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.mindfulChoiceSavingsDesc,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.vantColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
