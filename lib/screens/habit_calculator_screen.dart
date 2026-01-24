import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/currency_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';
import '../utils/habit_calculator.dart';
import '../widgets/premium_share_card.dart';

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
  Color _customCategoryColor = AppColors.primary;
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

  static final List<Color> _colorOptions = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.categoryFood,
    AppColors.categoryEducation,
    AppColors.categoryHealth,
    AppColors.categoryShopping,
    AppColors.achievementMystery,
    AppColors.categoryEntertainment,
  ];

  bool _hasLoadedInitialIncome = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load user's monthly income as default value (only once)
    if (!_hasLoadedInitialIncome) {
      _hasLoadedInitialIncome = true;
      final financeProvider = context.read<FinanceProvider>();
      final userIncome = financeProvider.userProfile?.monthlyIncome ?? 0;
      if (userIncome > 0) {
        _monthlyIncome = userIncome;
        _incomeController.text = formatTurkishCurrency(
          userIncome,
          decimalDigits: 0,
          showDecimals: false,
        );
      }
    }
  }

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
      barrierColor: context.appColors.background.withValues(alpha: 0.95),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: context.appColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: context.appColors.cardBorder),
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
                      color: context.appColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context).createOwnCategory,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                // Icon picker
                Text(
                  AppLocalizations.of(context).selectEmoji,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
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
                              : context.appColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? tempColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            iconData,
                            size: 24,
                            color: isSelected
                                ? tempColor
                                : context.appColors.textSecondary,
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
                            color: isSelected
                                ? context.appColors.textPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                PhosphorIconsBold.check,
                                color: context.appColors.textPrimary,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Name input
                TextField(
                  autofocus: true,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).categoryName,
                    labelStyle: TextStyle(
                      color: context.appColors.textSecondary,
                    ),
                    hintText: AppLocalizations.of(context).categoryNameHint,
                    hintStyle: TextStyle(
                      color: context.appColors.textTertiary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    filled: true,
                    fillColor: context.appColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.appColors.primary),
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
                                'custom', // key
                                _customCategoryName, // display name
                                _customCategoryIcon,
                                _customCategoryColor,
                              );
                            });
                            Navigator.pop(context);
                            _goToNextPage();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.primary,
                      foregroundColor: context.appColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: context.appColors.surfaceLight,
                    ),
                    child: Text(
                      AppLocalizations.of(context).continueButton,
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
      backgroundColor: context.appColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.appColors.gradientStart,
              context.appColors.gradientMid,
              context.appColors.gradientEnd,
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
    final l10n = AppLocalizations.of(context);
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
                    color: context.appColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.x,
                    color: context.appColors.textSecondary,
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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.selectHabitShock,
                style: TextStyle(
                  fontSize: 16,
                  color: context.appColors.textSecondary,
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
              itemCount: getLocalizedHabitCategories(l10n).length,
              itemBuilder: (context, index) {
                final category = getLocalizedHabitCategories(l10n)[index];
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
              foregroundColor: context.appColors.textSecondary,
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
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.appColors.cardBorder),
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
                  child: Icon(category.icon, size: 40, color: category.color),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
    final l10n = AppLocalizations.of(context);
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
                    color: context.appColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.caretLeft,
                    color: context.appColors.textSecondary,
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
                          color:
                              (_selectedCategory?.color ??
                                      context.appColors.primary)
                                  .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedCategory?.icon ?? PhosphorIconsFill.sparkle,
                          size: 44,
                          color:
                              _selectedCategory?.color ??
                              context.appColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedCategory?.name ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.appColors.textPrimary,
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
                          activeTrackColor: context.appColors.primary,
                          inactiveTrackColor: context.appColors.surfaceLight,
                          thumbColor: context.appColors.primary,
                          overlayColor: context.appColors.primary.withValues(
                            alpha: 0.2,
                          ),
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
                        style: TextStyle(
                          color: context.appColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: context.appColors.surfaceLight,
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
                            borderSide: BorderSide(
                              color: context.appColors.primary,
                            ),
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
                      style: TextStyle(
                        color: context.appColors.textSecondary,
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
                    children: HabitCalculator.frequencyKeys.map((freqKey) {
                      final isSelected = _selectedFrequency == freqKey;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            HabitCalculator.getLocalizedFrequency(
                              freqKey,
                              l10n,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedFrequency = selected ? freqKey : null;
                            });
                          },
                          selectedColor: context.appColors.primary,
                          backgroundColor: context.appColors.surfaceLight,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? context.appColors.textPrimary
                                : context.appColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? context.appColors.primary
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
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        enabled: !_dontWantToSay,
                        inputFormatters: [
                          PremiumCurrencyFormatter(
                            allowDecimals: false,
                            maxIntegerDigits: 12,
                          ),
                        ],
                        style: TextStyle(
                          color: _dontWantToSay
                              ? context.appColors.textTertiary
                              : context.appColors.textPrimary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.exampleAmount,
                          hintStyle: TextStyle(
                            color: context.appColors.textTertiary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: _dontWantToSay
                              ? context.appColors.surface
                              : context.appColors.surfaceLight,
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
                            borderSide: BorderSide(
                              color: context.appColors.primary,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          final parsed = parseAmount(value);
                          setState(() {
                            _monthlyIncome = parsed ?? 0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyProvider.code,
                      style: TextStyle(
                        color: context.appColors.textSecondary,
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
                        activeColor: context.appColors.primary,
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
                        style: TextStyle(
                          color: context.appColors.textSecondary,
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
                          ? LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            )
                          : null,
                      color: _isValid ? null : context.appColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: _isValid ? _calculate : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: context.appColors.textPrimary,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: Colors.transparent,
                        disabledForegroundColor: context.appColors.textTertiary,
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
                                  : context.appColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            PhosphorIconsDuotone.arrowRight,
                            size: 20,
                            color: _isValid
                                ? context.appColors.textPrimary
                                : context.appColors.textTertiary,
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
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: context.appColors.textPrimary,
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
    final l10n = AppLocalizations.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.scale(scale: 0.9 + (0.1 * animValue), child: child),
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
                color: (_selectedCategory?.color ?? context.appColors.primary)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedCategory?.icon ?? PhosphorIconsFill.sparkle,
                size: 64,
                color: _selectedCategory?.color ?? context.appColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Animated counter
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: _result!.yearlyDays),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.resultDays(value.toString()),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.yearlyHabitCost(_selectedCategory?.name ?? ''),
                style: TextStyle(
                  fontSize: 18,
                  color: context.appColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 32),
            // Divider
            Container(height: 1, color: context.appColors.textPrimary.withValues(alpha: 0.2)),
            const SizedBox(height: 24),
            // Detail row
            Text(
              l10n.monthlyYearlyCost(
                l10n.habitMonthlyDetail(_result!.monthlyDays, _result!.monthlyExtraHours),
                _formatCurrency(_result!.yearlyAmount),
              ),
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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
                foregroundColor: context.appColors.textPrimary,
                side: BorderSide(color: context.appColors.textTertiary),
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
                foregroundColor: context.appColors.textSecondary,
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
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: context.appColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareResult() {
    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context);
    showHabitShareCardPreview(
      context,
      icon: _selectedCategory!.icon,
      iconColor: _selectedCategory!.color,
      categoryName: _selectedCategory!.name,
      yearlyDays: _result!.yearlyDays,
      yearlyAmount: _result!.yearlyAmount,
      frequency: HabitCalculator.getLocalizedFrequency(
        _selectedFrequency!,
        l10n,
      ),
    );
  }

  String _formatCurrency(double amount) {
    final currencyProvider = context.read<CurrencyProvider>();
    final symbol = currencyProvider.symbol;
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}
