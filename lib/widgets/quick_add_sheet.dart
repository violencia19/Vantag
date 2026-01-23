import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/currency_provider.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';
import 'decision_stress_timer.dart';
import 'voice_input_button.dart';

/// Quick add expense bottom sheet
/// Article 11: Category selection required, subcategories open with animation
class QuickAddSheet extends StatefulWidget {
  final Function(double amount, String category, String? subCategory) onAdd;
  final VoidCallback? onCancel;

  const QuickAddSheet({super.key, required this.onAdd, this.onCancel});

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _subCategoryService = SubCategoryService();

  // Anayasa Madde 11: Varsayılan kategori YOK
  String? _selectedCategory;
  String? _selectedSubCategory;
  SubCategorySuggestions? _subCategorySuggestions;
  bool _hasValidAmount = false;
  bool _showCategoryWarning = false;

  // Alt kategori animasyonu
  late AnimationController _subCategoryAnimController;
  late Animation<double> _subCategorySlideAnimation;
  late Animation<double> _subCategoryFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Alt kategori animasyon controller
    _subCategoryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _subCategorySlideAnimation = Tween<double>(begin: -20, end: 0).animate(
      CurvedAnimation(
        parent: _subCategoryAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    _subCategoryFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _subCategoryAnimController,
        curve: Curves.easeOut,
      ),
    );

    // Klavyeyi otomatik aç
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _subCategoryController.dispose();
    _amountFocusNode.dispose();
    _subCategoryAnimController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    final amount = parseAmount(_amountController.text);
    setState(() {
      _hasValidAmount = amount != null && amount > 0;
      // Uyarıyı kaldır (tekrar deneyebilir)
      if (_hasValidAmount) _showCategoryWarning = false;
    });
  }

  /// Ana kategori seçildiğinde
  Future<void> _onCategorySelected(String category) async {
    HapticFeedback.selectionClick();

    setState(() {
      _selectedCategory = category;
      _selectedSubCategory = null;
      _showCategoryWarning = false;
    });

    // Alt kategori önerilerini yükle
    final suggestions = await _subCategoryService.getSuggestions(category);

    if (mounted) {
      setState(() {
        _subCategorySuggestions = suggestions;
      });

      // Animasyonu başlat
      _subCategoryAnimController.forward(from: 0);
    }
  }

  /// Alt kategori seçildiğinde
  void _onSubCategorySelected(String subCategory) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedSubCategory = subCategory;
      _subCategoryController.text = subCategory;
    });
  }

  /// Submit form
  void _submit() {
    final l10n = AppLocalizations.of(context);
    final amount = parseAmount(_amountController.text);

    // Amount validation
    if (amount == null || amount <= 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterValidAmount),
          backgroundColor: context.appColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Article 11: Category validation
    if (_selectedCategory == null) {
      HapticFeedback.heavyImpact();
      setState(() => _showCategoryWarning = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                PhosphorIconsDuotone.warningCircle,
                color: context.appColors.background,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.pleaseSelectExpenseGroup,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: context.appColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Başarılı - kaydet
    HapticFeedback.mediumImpact();
    soundService.playCoin();
    final subCategory = _subCategoryController.text.trim().isNotEmpty
        ? _subCategoryController.text.trim()
        : _selectedSubCategory;

    widget.onAdd(amount, _selectedCategory!, subCategory);
    Navigator.pop(context);
  }

  bool get _canSubmit => _hasValidAmount && _selectedCategory != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        // Solid dark background - not transparent
        color: context.appColors.gradientMid, // #1A1A2E - solid dark
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: context.appColors.cardBorder,
          width: 1,
        ),
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
                  color: context.appColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.newExpense,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.categoryRequired,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Voice input button - opens full VoiceInputScreen
                    const CompactVoiceButton(),
                    const SizedBox(width: 8),
                    // Close button
                    IconButton(
                      tooltip: l10n.close,
                      onPressed: () {
                        widget.onCancel?.call();
                        Navigator.pop(context);
                      },
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: context.appColors.surfaceLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsDuotone.x,
                          size: 20,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            // STEP 1: Amount input
            _buildAmountInput(l10n),

            const SizedBox(height: 24),

            // STEP 2: Category selection (required)
            _buildCategorySection(l10n),

            // STEP 3: Subcategory (animated, optional)
            _buildSubCategorySection(l10n),

            const SizedBox(height: 28),

            // Calculate button
            _buildSubmitButton(l10n),
          ],
        ),
      ),
    );
  }

  /// Amount input field
  Widget _buildAmountInput(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: context.appColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _hasValidAmount
              ? context.appColors.primary.withValues(alpha: 0.5)
              : context.appColors.cardBorder,
          width: _hasValidAmount ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              focusNode: _amountFocusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                PremiumCurrencyFormatter(
                  allowDecimals: true,
                  maxIntegerDigits: 12,
                ),
              ],
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textTertiary.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => _validateAmount(),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.tl,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Category selection section
  Widget _buildCategorySection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: _showCategoryWarning
                    ? context.appColors.warning
                    : context.appColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.expenseGroup,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _showCategoryWarning
                    ? context.appColors.warning
                    : context.appColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _showCategoryWarning
                    ? context.appColors.warning.withValues(alpha: 0.15)
                    : context.appColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                l10n.required,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _showCategoryWarning
                      ? context.appColors.warning
                      : context.appColors.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Kategori chips - yatay scroll
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ExpenseCategory.all.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = ExpenseCategory.all[index];
              final isSelected = category == _selectedCategory;

              return Semantics(
                label: ExpenseCategory.getLocalizedName(category, l10n),
                button: true,
                selected: isSelected,
                child: GestureDetector(
                  onTap: () => _onCategorySelected(category),
                  child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.appColors.primary
                        : _showCategoryWarning
                        ? context.appColors.warning.withValues(alpha: 0.08)
                        : context.appColors.surfaceLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? context.appColors.primary
                          : _showCategoryWarning
                          ? context.appColors.warning.withValues(alpha: 0.3)
                          : context.appColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: context.appColors.primary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ExpenseCategory.getIcon(category),
                        size: 20,
                        color: isSelected
                            ? context.appColors.background
                            : ExpenseCategory.getColor(category),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ExpenseCategory.getLocalizedName(category, l10n),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? context.appColors.background
                              : context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Subcategory section (animated)
  Widget _buildSubCategorySection(AppLocalizations l10n) {
    // Don't show if category not selected
    if (_selectedCategory == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _subCategoryAnimController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _subCategorySlideAnimation.value),
          child: Opacity(
            opacity: _subCategoryFadeAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Subcategory title
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: context.appColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.detail,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.optional,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Alt kategori önerileri
                if (_subCategorySuggestions != null &&
                    !_subCategorySuggestions!.isEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Son kullanılanlar (outline stil)
                      ..._subCategorySuggestions!.recent.map(
                        (sub) => _buildSubCategoryChip(sub, isRecent: true),
                      ),
                      // Sabit öneriler
                      ..._subCategorySuggestions!.fixed.map(
                        (sub) => _buildSubCategoryChip(sub, isRecent: false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // Manuel giriş alanı
                Container(
                  decoration: BoxDecoration(
                    color: context.appColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.appColors.cardBorder),
                  ),
                  child: TextField(
                    controller: _subCategoryController,
                    keyboardType: TextInputType.text,
                    enableSuggestions: true,
                    autocorrect: false,
                    enableIMEPersonalizedLearning: true,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Örn: ${_getExampleForCategory(_selectedCategory!)}',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: context.appColors.textTertiary.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      prefixIcon: Icon(
                        PhosphorIconsDuotone.notepad,
                        size: 22,
                        color: context.appColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() => _selectedSubCategory = null);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Alt kategori chip
  Widget _buildSubCategoryChip(String subCategory, {required bool isRecent}) {
    final isSelected = _selectedSubCategory == subCategory;

    return Semantics(
      label: subCategory,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => _onSubCategorySelected(subCategory),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? context.appColors.secondary.withValues(alpha: 0.15)
                : isRecent
                ? Colors.transparent
                : context.appColors.surfaceLighter,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? context.appColors.secondary
                  : isRecent
                  ? context.appColors.secondary.withValues(alpha: 0.4)
                  : context.appColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecent)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    PhosphorIconsDuotone.clockCounterClockwise,
                    size: 14,
                    color: isSelected
                        ? context.appColors.secondary
                        : context.appColors.textTertiary,
                  ),
                ),
              Text(
                subCategory,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? context.appColors.secondary
                      : context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Submit button
  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submit, // Always clickable, validation inside
        style: ElevatedButton.styleFrom(
          backgroundColor: _canSubmit
              ? context.appColors.primary
              : context.appColors.surfaceLight,
          foregroundColor: _canSubmit
              ? context.appColors.background
              : context.appColors.textTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _canSubmit
                  ? PhosphorIconsDuotone.calculator
                  : PhosphorIconsDuotone.handTap,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              _selectedCategory == null ? l10n.selectCategory : l10n.calculate,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// Kategori için örnek alt kategori
  String _getExampleForCategory(String category) {
    switch (category) {
      case 'Yiyecek':
        return 'Kahve, Market, Restoran';
      case 'Ulaşım':
        return 'Benzin, Taksi, Otobüs';
      case 'Giyim':
        return 'Kaban, Ayakkabı, T-shirt';
      case 'Elektronik':
        return 'Telefon, Kulaklık, Şarj';
      case 'Eğlence':
        return 'Sinema, Oyun, Konser';
      case 'Sağlık':
        return 'İlaç, Doktor, Vitamin';
      case 'Eğitim':
        return 'Kitap, Kurs, Defter';
      case 'Faturalar':
        return 'Elektrik, Su, İnternet';
      default:
        return 'Açıklama yazın...';
    }
  }
}

/// Quick Add Sheet'i göster (legacy)
void showQuickAddSheet(
  BuildContext context, {
  required Function(double amount, String category, String? subCategory) onAdd,
}) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.95),
    builder: (context) => QuickAddSheet(onAdd: onAdd),
  );
}

/// Premium harcama ekleme modal'ı göster (WealthModal ile)
void showPremiumExpenseModal(
  BuildContext context, {
  required Function(double amount, String category, String? subCategory) onAdd,
}) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.95),
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 350),
    ),
    builder: (context) => _PremiumQuickAddModal(onAdd: onAdd),
  );
}

/// Premium Quick Add Modal (WealthModal benzeri tasarım)
class _PremiumQuickAddModal extends StatefulWidget {
  final Function(double amount, String category, String? subCategory) onAdd;

  const _PremiumQuickAddModal({required this.onAdd});

  @override
  State<_PremiumQuickAddModal> createState() => _PremiumQuickAddModalState();
}

class _PremiumQuickAddModalState extends State<_PremiumQuickAddModal>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _subCategoryService = SubCategoryService();

  String? _selectedCategory;
  SubCategorySuggestions? _subCategorySuggestions;
  bool _hasValidAmount = false;
  bool _showCategoryWarning = false;
  bool _showGoldenGlow = false;

  // Sensory feedback için
  double _currentAmount = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Sensory feedback sıfırla
    sensoryFeedback.resetHapticState();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _subCategoryController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    final amount = parseAmount(_amountController.text);
    setState(() {
      _hasValidAmount = amount != null && amount > 0;
      _currentAmount = amount ?? 0;
      if (_hasValidAmount) _showCategoryWarning = false;
    });

    // Haptic Weight - tutar bazlı titreşim
    if (amount != null && amount > 0) {
      sensoryFeedback.triggerHapticForAmount(amount);
    }
  }

  Future<void> _onCategorySelected(String category) async {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategory = category;
      _showCategoryWarning = false;
    });

    final suggestions = await _subCategoryService.getSuggestions(category);
    if (mounted) {
      setState(() => _subCategorySuggestions = suggestions);
    }
  }

  void _submit() {
    final amount = parseAmount(_amountController.text);

    if (amount == null || amount <= 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen geçerli bir tutar girin'),
          backgroundColor: context.appColors.error,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      HapticFeedback.heavyImpact();
      setState(() => _showCategoryWarning = true);
      return;
    }

    // Golden glow efekti
    setState(() => _showGoldenGlow = true);
    HapticFeedback.mediumImpact();
    soundService.playCoin();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        final subCategory = _subCategoryController.text.trim().isNotEmpty
            ? _subCategoryController.text.trim()
            : null;
        widget.onAdd(amount, _selectedCategory!, subCategory);
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = sensoryFeedback.getBackgroundGradient(
      _currentAmount,
    );
    final riskLevel = sensoryFeedback.getRiskLevel(_currentAmount);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              // Blood Pressure Background
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  gradientColors[0].withValues(alpha: 0.95),
                  gradientColors[1].withValues(alpha: 0.98),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: _showGoldenGlow
                    ? AppColors.medalGold
                    : riskLevel.backgroundIntensity > 0.3
                    ? AppColors.categoryBills.withValues(alpha: 0.5)
                    : context.appColors.cardBorder,
                width: _showGoldenGlow || riskLevel.backgroundIntensity > 0.3
                    ? 2
                    : 1,
              ),
              boxShadow: [
                if (_showGoldenGlow)
                  BoxShadow(
                    color: AppColors.medalGold.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                else if (riskLevel.backgroundIntensity > 0.2)
                  BoxShadow(
                    color: AppColors.categoryBills.withValues(alpha: riskLevel.backgroundIntensity * 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              children: [
                // Drag Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.appColors.textTertiary.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Semantics(
                        label: AppLocalizations.of(context).accessibilityCloseSheet,
                        button: true,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: context.appColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              PhosphorIconsDuotone.x,
                              size: 20,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Yeni Harcama',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      child: _buildForm(),
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

  Widget _buildForm() {
    final currencyProvider = context.watch<CurrencyProvider>();
    final riskLevel = sensoryFeedback.getRiskLevel(_currentAmount);
    final borderColor = sensoryFeedback.getAmountBorderColor(_currentAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risk göstergesi (varsa)
        if (riskLevel != RiskLevel.none && _hasValidAmount)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RiskBadge(riskLevel: riskLevel),
          ),

        // Tutar - Blood Pressure efekti ile
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: context.appColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hasValidAmount
                  ? borderColor
                  : context.appColors.cardBorder,
              width: _hasValidAmount && riskLevel != RiskLevel.none ? 2 : 1,
            ),
            boxShadow: _hasValidAmount && riskLevel.backgroundIntensity > 0.2
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    PremiumCurrencyFormatter(
                      allowDecimals: true,
                      maxIntegerDigits: 12,
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.textTertiary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => _validateAmount(),
                ),
              ),
              Text(
                currencyProvider.code,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Kategori başlık
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: _showCategoryWarning
                    ? context.appColors.warning
                    : context.appColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Harcama Grubu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _showCategoryWarning
                    ? context.appColors.warning
                    : context.appColors.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Kategori grid - Premium visibility
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.0, // Daha büyük tıklama alanı (min 48px height)
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: ExpenseCategory.all.length,
          itemBuilder: (context, index) {
            final category = ExpenseCategory.all[index];
            final isSelected = category == _selectedCategory;

            return _PremiumCategoryButton(
              category: category,
              isSelected: isSelected,
              showWarning: _showCategoryWarning,
              onTap: () => _onCategorySelected(category),
            );
          },
        ),

        // Alt kategori önerileri
        if (_selectedCategory != null &&
            _subCategorySuggestions != null &&
            !_subCategorySuggestions!.isEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Detay (Opsiyonel)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._subCategorySuggestions!.recent.map(
                (s) => _buildChip(s, true),
              ),
              ..._subCategorySuggestions!.fixed.map(
                (s) => _buildChip(s, false),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // Kaydet butonu
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: (_hasValidAmount && _selectedCategory != null)
                  ? context.appColors.primary
                  : context.appColors.surfaceLight,
              foregroundColor: (_hasValidAmount && _selectedCategory != null)
                  ? context.appColors.background
                  : context.appColors.textTertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsDuotone.check, size: 22),
                SizedBox(width: 10),
                Text(
                  'Hesapla',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChip(String label, bool isRecent) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _subCategoryController.text = label;
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isRecent
                ? context.appColors.primary.withValues(alpha: 0.15)
                : context.appColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isRecent
                  ? context.appColors.primary.withValues(alpha: 0.5)
                  : context.appColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecent)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    PhosphorIconsDuotone.clockCounterClockwise,
                    size: 14,
                    color: context.appColors.primary,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isRecent ? context.appColors.primary : context.appColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium Category Button with press state
/// Daha görünür arka plan, beyaz yazı, press efekti
class _PremiumCategoryButton extends StatefulWidget {
  final String category;
  final bool isSelected;
  final bool showWarning;
  final VoidCallback onTap;

  const _PremiumCategoryButton({
    required this.category,
    required this.isSelected,
    required this.showWarning,
    required this.onTap,
  });

  @override
  State<_PremiumCategoryButton> createState() => _PremiumCategoryButtonState();
}

class _PremiumCategoryButtonState extends State<_PremiumCategoryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          // Daha görünür arka plan: seçili=primary, basılı=surfaceLighter, normal=surfaceLight
          color: widget.isSelected
              ? context.appColors.primary
              : _isPressed
              ? context.appColors.surfaceLighter
              : widget.showWarning
              ? context.appColors.warning.withValues(alpha: 0.12)
              : context.appColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isSelected
                ? context.appColors.primary
                : _isPressed
                ? context.appColors.primary.withValues(alpha: 0.5)
                : widget.showWarning
                ? context.appColors.warning.withValues(alpha: 0.4)
                : context.appColors.cardBorder,
            width: widget.isSelected || _isPressed ? 2 : 1,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: context.appColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : _isPressed
              ? [
                  BoxShadow(
                    color: context.appColors.textPrimary.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category icon
            Icon(
              ExpenseCategory.getIcon(widget.category),
              size: 20,
              color: widget.isSelected
                  ? context.appColors.background
                  : ExpenseCategory.getColor(widget.category),
              shadows: widget.isSelected || _isPressed
                  ? [
                      Shadow(
                        color: context.appColors.textPrimary.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            const SizedBox(width: 8),
            // Kategori adı - theme-aware colors
            Flexible(
              child: Text(
                ExpenseCategory.getLocalizedName(widget.category, l10n),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w600,
                  // Seçili: koyu arka plan, diğer: theme text
                  color: widget.isSelected
                      ? context.appColors.background
                      : context.appColors.textPrimary,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
