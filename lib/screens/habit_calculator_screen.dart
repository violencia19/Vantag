import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart';
import '../utils/habit_calculator.dart';
import '../widgets/share_card_widget.dart';
import '../widgets/share_edit_sheet.dart';
import '../services/share_service.dart';

/// Viral Habit Calculator
/// 3-step wizard to calculate how many work days user's habits cost
class HabitCalculatorScreen extends StatefulWidget {
  const HabitCalculatorScreen({super.key});

  @override
  State<HabitCalculatorScreen> createState() => _HabitCalculatorScreenState();
}

class _HabitCalculatorScreenState extends State<HabitCalculatorScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  // State
  HabitCategory? _selectedCategory;
  String _customCategoryName = '';
  IconData _customCategoryIcon = PhosphorIconsFill.sparkle;
  Color _customCategoryColor = const Color(0xFF6C63FF);
  double _price = 0;
  String? _selectedFrequency;
  double _monthlyIncome = 0;
  bool _dontWantToSay = false;
  HabitResult? _result;

  // Icon options for custom category
  static final List<IconData> _iconOptions = [
    PhosphorIconsFill.sparkle,
    PhosphorIconsFill.target,
    PhosphorIconsFill.coins,
    PhosphorIconsFill.gift,
    PhosphorIconsFill.beerStein,
    PhosphorIconsFill.wine,
    PhosphorIconsFill.pizza,
    PhosphorIconsFill.popcorn,
    PhosphorIconsFill.filmSlate,
    PhosphorIconsFill.deviceMobile,
    PhosphorIconsFill.laptop,
    PhosphorIconsFill.headphones,
    PhosphorIconsFill.sneaker,
    PhosphorIconsFill.heart,
    PhosphorIconsFill.paintBrush,
    PhosphorIconsFill.barbell,
  ];

  static const List<Color> _colorOptions = [
    Color(0xFF6C63FF),
    Color(0xFF4ECDC4),
    Color(0xFFFF6B6B),
    Color(0xFFF39C12),
    Color(0xFF2ECC71),
    Color(0xFF9B59B6),
    Color(0xFFE91E63),
    Color(0xFF3498DB),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _priceController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _selectCategory(HabitCategory category) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategory = category;
    });
    _goToNextPage();
  }

  void _showCustomCategoryDialog() {
    HapticFeedback.lightImpact();
    String tempName = _customCategoryName;
    IconData tempIcon = _customCategoryIcon;
    Color tempColor = _customCategoryColor;

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
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
                Text(
                  AppLocalizations.of(context)!.createOwnCategory,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                // Icon picker
                Text(
                  AppLocalizations.of(context)!.selectEmoji,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _iconOptions.map((iconData) {
                    final isSelected = iconData == tempIcon;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setModalState(() => tempIcon = iconData);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? tempColor.withValues(alpha: 0.2)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? tempColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            iconData,
                            size: 24,
                            color: isSelected ? tempColor : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Color picker
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorOptions.map((color) {
                    final isSelected = color == tempColor;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setModalState(() => tempColor = color);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(PhosphorIconsBold.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Name input
                TextField(
                  autofocus: true,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.categoryName,
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    hintText: AppLocalizations.of(context)!.categoryNameHint,
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: (value) => tempName = value,
                ),
                const SizedBox(height: 24),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: tempName.trim().isNotEmpty
                        ? () {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _customCategoryName = tempName.trim();
                              _customCategoryIcon = tempIcon;
                              _customCategoryColor = tempColor;
                              _selectedCategory = HabitCategory(
                                _customCategoryName,
                                _customCategoryIcon,
                                _customCategoryColor,
                              );
                            });
                            Navigator.pop(context);
                            _goToNextPage();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.surfaceLight,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.continueButton,
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
      ),
    );
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToPreviousPage() {
    HapticFeedback.lightImpact();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _calculate() {
    if (!_isValid) return;

    HapticFeedback.mediumImpact();

    final income = _dontWantToSay ? 40000.0 : _monthlyIncome;
    final result = HabitCalculator.calculate(
      price: _price,
      frequency: _selectedFrequency!,
      monthlyIncome: income,
    );

    setState(() {
      _result = result;
    });

    _goToNextPage();
  }

  void _resetAndRestart() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategory = null;
      _price = 0;
      _priceController.clear();
      _selectedFrequency = null;
      _monthlyIncome = 0;
      _incomeController.clear();
      _dontWantToSay = false;
      _result = null;
    });
    _pageController.jumpToPage(0);
  }

  bool get _isValid {
    return _selectedCategory != null &&
        _price > 0 &&
        _selectedFrequency != null &&
        (_monthlyIncome > 0 || _dontWantToSay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientMid,
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1CategorySelect(),
              _buildStep2Details(),
              _buildStep3Result(),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 1 - SELECT CATEGORY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStep1CategorySelect() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.x,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Titles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                l10n.howManyDaysForHabit,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.selectHabitShock,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: defaultHabitCategories.length,
              itemBuilder: (context, index) {
                final category = defaultHabitCategories[index];
                return _buildCategoryCard(category);
              },
            ),
          ),
        ),
        // Custom category button
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextButton.icon(
            onPressed: _showCustomCategoryDialog,
            icon: Icon(PhosphorIconsDuotone.pencilSimple, size: 18),
            label: Text(l10n.addMyOwnCategory),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(HabitCategory category) {
    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    size: 40,
                    color: category.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 2 - DETAILS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStep2Details() {
    final l10n = AppLocalizations.of(context)!;
    final currencyProvider = context.watch<CurrencyProvider>();
    return Column(
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              GestureDetector(
                onTap: _goToPreviousPage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.caretLeft,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected category display
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: (_selectedCategory?.color ?? AppColors.primary).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedCategory?.icon ?? PhosphorIconsFill.sparkle,
                          size: 44,
                          color: _selectedCategory?.color ?? AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedCategory?.name ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Price input
                _buildSectionTitle(l10n.howMuchPerTime),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Slider
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.surfaceLight,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withValues(alpha: 0.2),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _price.clamp(20, 1000),
                          min: 20,
                          max: 1000,
                          divisions: 98,
                          onChanged: (value) {
                            setState(() {
                              _price = value;
                              _priceController.text = value.round().toString();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Input box
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        onChanged: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) {
                            setState(() {
                              _price = parsed;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyProvider.code,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Frequency
                _buildSectionTitle(l10n.howOften),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: HabitCalculator.frequencies.map((freq) {
                      final isSelected = _selectedFrequency == freq;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(freq),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedFrequency = selected ? freq : null;
                            });
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceLight,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // Income
                _buildSectionTitle(l10n.whatIsYourIncome),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _incomeController,
                        keyboardType: TextInputType.number,
                        enabled: !_dontWantToSay,
                        style: TextStyle(
                          color: _dontWantToSay
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.exampleAmount,
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: _dontWantToSay
                              ? AppColors.surface
                              : AppColors.surfaceLight,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        onChanged: (value) {
                          final parsed = double.tryParse(value);
                          setState(() {
                            _monthlyIncome = parsed ?? 0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyProvider.code,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _dontWantToSay,
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _dontWantToSay = value ?? false;
                            if (_dontWantToSay) {
                              _incomeController.text = '40.000';
                              _monthlyIncome = 40000;
                            } else {
                              _incomeController.clear();
                              _monthlyIncome = 0;
                            }
                          });
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _dontWantToSay = !_dontWantToSay;
                          if (_dontWantToSay) {
                            _incomeController.text = '40.000';
                            _monthlyIncome = 40000;
                          } else {
                            _incomeController.clear();
                            _monthlyIncome = 0;
                          }
                        });
                      },
                      child: Text(
                        l10n.dontWantToSay,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Calculate button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _isValid
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF6C63FF),
                                Color(0xFF4ECDC4),
                              ],
                            )
                          : null,
                      color: _isValid ? null : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: _isValid ? _calculate : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: Colors.transparent,
                        disabledForegroundColor: AppColors.textTertiary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.calculate,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _isValid
                                  ? Colors.white
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            PhosphorIconsDuotone.arrowRight,
                            size: 20,
                            color: _isValid
                                ? Colors.white
                                : AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 3 - RESULT
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStep3Result() {
    if (_result == null) {
      return const SizedBox();
    }
    final l10n = AppLocalizations.of(context)!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.scale(
            scale: 0.9 + (0.1 * animValue),
            child: child,
          ),
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (_selectedCategory?.color ?? AppColors.primary).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedCategory?.icon ?? PhosphorIconsFill.sparkle,
                size: 64,
                color: _selectedCategory?.color ?? AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Animated counter
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: _result!.yearlyDays),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  l10n.resultDays(value.toString()),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              l10n.yearlyHabitCost(_selectedCategory?.name ?? ''),
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Divider
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 24),
            // Detail row
            Text(
              l10n.monthlyYearlyCost(
                '${_result!.monthlyDays} days ${_result!.monthlyExtraHours} hours',
                _formatCurrency(_result!.yearlyAmount),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            // Buttons
            _buildGradientButton(
              icon: PhosphorIconsFill.shareFat,
              text: l10n.shareOnStory,
              onTap: _shareResult,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _resetAndRestart,
              icon: Icon(PhosphorIconsDuotone.arrowCounterClockwise, size: 20),
              label: Text(l10n.tryAnotherHabit),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.textTertiary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(PhosphorIconsDuotone.listChecks, size: 20),
              label: Text(l10n.trackAllExpenses),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareResult() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareEditSheet(
        icon: _selectedCategory!.icon,
        iconColor: _selectedCategory!.color,
        categoryName: _selectedCategory!.name,
        yearlyDays: _result!.yearlyDays,
        yearlyAmount: _result!.yearlyAmount,
        frequency: _selectedFrequency!,
        onShare: (showAmount, showFrequency) {
          _showShareCardAndShare(showAmount, showFrequency);
        },
      ),
    );
  }

  Future<void> _showShareCardAndShare(bool showAmount, bool showFrequency) async {
    // Paylaşım kartını dialog olarak göster ve screenshot al
    await showDialog(
      context: context,
      barrierColor: Colors.black,
      barrierDismissible: false,
      builder: (context) => _ShareCardDialog(
        icon: _selectedCategory!.icon,
        iconColor: _selectedCategory!.color,
        categoryName: _selectedCategory!.name,
        yearlyDays: _result!.yearlyDays,
        yearlyAmount: showAmount ? _result!.yearlyAmount : null,
        frequency: showFrequency ? _selectedFrequency : null,
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₺${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₺${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₺${amount.toStringAsFixed(0)}';
  }
}

/// Share card dialog - takes screenshot and shares
class _ShareCardDialog extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String categoryName;
  final int yearlyDays;
  final double? yearlyAmount;
  final String? frequency;

  const _ShareCardDialog({
    required this.icon,
    required this.iconColor,
    required this.categoryName,
    required this.yearlyDays,
    this.yearlyAmount,
    this.frequency,
  });

  @override
  State<_ShareCardDialog> createState() => _ShareCardDialogState();
}

class _ShareCardDialogState extends State<_ShareCardDialog> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    // Auto share after card renders
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      await _shareCard();
    });
  }

  Future<void> _shareCard() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    final success = await ShareService.shareWidget(_cardKey);

    if (mounted) {
      Navigator.pop(context);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.shareError),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: _cardKey,
            child: ShareCardWidget(
              icon: widget.icon,
              iconColor: widget.iconColor,
              categoryName: widget.categoryName,
              yearlyDays: widget.yearlyDays,
              yearlyAmount: widget.yearlyAmount,
              frequency: widget.frequency,
            ),
          ),
          const SizedBox(height: 24),
          if (_isSharing)
            const CircularProgressIndicator(
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
