import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

/// Step-by-step income entry wizard
/// Premium UX with multiple income source support
class IncomeWizardScreen extends StatefulWidget {
  final UserProfile? existingProfile;
  final List<IncomeSource>? existingSources;
  final bool isEditing;
  /// If true, skips salary step and goes directly to additional income form
  final bool skipToAdditional;

  const IncomeWizardScreen({
    super.key,
    this.existingProfile,
    this.existingSources,
    this.isEditing = false,
    this.skipToAdditional = false,
  });

  @override
  State<IncomeWizardScreen> createState() => _IncomeWizardScreenState();
}

class _IncomeWizardScreenState extends State<IncomeWizardScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _salaryController = TextEditingController();
  final _additionalAmountController = TextEditingController();
  final _additionalTitleController = TextEditingController();
  final _hoursController = TextEditingController();
  final _pageController = PageController();

  // State
  int _currentStep = 0;
  List<IncomeSource> _incomeSources = [];
  IncomeCategory? _selectedCategory;
  double _dailyHours = 8.0;
  int _workDaysPerWeek = 5;
  bool _isLoading = false;

  // Animation
  late AnimationController _fadeController;

  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider'a erişim için didChangeDependencies kullan (sadece 1 kez)
    if (!_isDataLoaded) {
      _isDataLoaded = true;
      _loadExistingData();

      // skipToAdditional true ise, direkt ek gelir adımına atla
      if (widget.skipToAdditional) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _currentStep = 2);
            _pageController.jumpToPage(2);
          }
        });
      }
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeController.forward();
  }

  void _loadExistingData() {
    // Provider'dan güncel veriyi al (en güvenilir kaynak)
    final provider = context.read<FinanceProvider>();
    final providerProfile = provider.userProfile;

    if (providerProfile != null && providerProfile.incomeSources.isNotEmpty) {
      // Provider'da veri var - onu kullan
      _incomeSources = List.from(providerProfile.incomeSources);
      _dailyHours = providerProfile.dailyHours;
      _workDaysPerWeek = providerProfile.workDaysPerWeek;
      _hoursController.text = _dailyHours.toStringAsFixed(0);

      // Ana maaşı bul
      final primary = providerProfile.primarySource;
      if (primary != null) {
        _salaryController.text = formatTurkishCurrency(
          primary.amount,
          decimalDigits: 0,
          showDecimals: false,
        );
      }
    }
    // Fallback: widget parametrelerini kontrol et
    else if (widget.existingSources != null && widget.existingSources!.isNotEmpty) {
      _incomeSources = List.from(widget.existingSources!);

      // Ana maaşı bul
      final primary = _incomeSources.where((s) => s.isPrimary).firstOrNull;
      if (primary != null) {
        _salaryController.text = formatTurkishCurrency(
          primary.amount,
          decimalDigits: 0,
          showDecimals: false,
        );
      }
    }
    else if (widget.existingProfile != null) {
      final profile = widget.existingProfile!;
      _incomeSources = List.from(profile.incomeSources);
      _dailyHours = profile.dailyHours;
      _workDaysPerWeek = profile.workDaysPerWeek;
      _hoursController.text = _dailyHours.toStringAsFixed(0);

      // Ana maaşı bul
      final primary = profile.primarySource;
      if (primary != null) {
        _salaryController.text = formatTurkishCurrency(
          primary.amount,
          decimalDigits: 0,
          showDecimals: false,
        );
      }
    } else {
      _hoursController.text = '8';
    }
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _additionalAmountController.dispose();
    _additionalTitleController.dispose();
    _hoursController.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _saveSalary() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = parseAmount(_salaryController.text);
    if (amount == null || amount <= 0) {
      _showError(l10n.pleaseEnterValidSalary);
      return;
    }

    // Mevcut primary income'u güncelle veya yeni oluştur
    final existingPrimaryIndex = _incomeSources.indexWhere((s) => s.isPrimary);

    if (existingPrimaryIndex >= 0) {
      _incomeSources[existingPrimaryIndex] = _incomeSources[existingPrimaryIndex].copyWith(
        amount: amount,
      );
    } else {
      _incomeSources.insert(0, IncomeSource.salary(amount: amount));
    }

    HapticFeedback.lightImpact();
    _nextStep();
  }

  void _addAdditionalIncome() {
    final l10n = AppLocalizations.of(context)!;
    final amount = parseAmount(_additionalAmountController.text);
    final title = _additionalTitleController.text.trim();

    if (amount == null || amount <= 0) {
      _showError(l10n.pleaseEnterValidIncomeAmount);
      return;
    }

    if (_selectedCategory == null) {
      _showError(l10n.pleaseSelectCategory);
      return;
    }

    final source = IncomeSource.additional(
      title: title.isEmpty ? _selectedCategory!.label : title,
      amount: amount,
      category: _selectedCategory!,
    );

    setState(() {
      _incomeSources.add(source);
      _additionalAmountController.clear();
      _additionalTitleController.clear();
      _selectedCategory = null;
    });

    HapticFeedback.mediumImpact();
  }

  void _removeIncome(String id) {
    setState(() {
      _incomeSources.removeWhere((s) => s.id == id);
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _complete() async {
    final l10n = AppLocalizations.of(context)!;
    // Double-tap protection
    if (_isLoading) return;

    // Get work hours
    final hours = double.tryParse(_hoursController.text) ?? 8.0;

    if (_incomeSources.isEmpty) {
      _showError(l10n.atLeastOneIncomeRequired);
      return;
    }

    setState(() => _isLoading = true);

    // Capture context before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<FinanceProvider>();

    try {
      // Save income sources (auto persists)
      await provider.setIncomeSources(_incomeSources);

      // Save work hours (auto persists)
      await provider.updateWorkSchedule(
        dailyHours: hours,
        workDaysPerWeek: _workDaysPerWeek,
      );

      // Mounted check after async
      if (!mounted) return;

      HapticFeedback.heavyImpact();

      // Success message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.checkCircle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                widget.isEditing
                    ? l10n.incomesUpdated
                    : l10n.incomesSaved,
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigator - data already saved in Provider, just go back
      navigator.pop();
    } catch (e) {
      // Show error only if there's a real error
      if (mounted) {
        _showError(l10n.saveError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? l10n.editIncomes : l10n.addIncome,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1_Salary(),
                _buildStep2_AskMore(),
                _buildStep3_AddMore(),
                _buildStep4_Summary(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 3) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ============================================
  // STEP 1: Primary Salary
  // ============================================
  Widget _buildStep1_Salary() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💼', style: TextStyle(fontSize: 40)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Center(
            child: Text(
              l10n.whatIsYourSalary,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              l10n.enterNetAmount,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Amount input
          TextField(
            controller: _salaryController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              TurkishCurrencyInputFormatter(),
            ],
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary.withValues(alpha: 0.5),
              ),
              suffixText: 'TL',
              suffixStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Work hours
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyWork,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _hoursController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: InputDecoration(
                          hintText: '8',
                          suffixText: l10n.hours,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.cardBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _workDaysPerWeek,
                            isExpanded: true,
                            items: [5, 6, 7].map((days) {
                              return DropdownMenuItem(
                                value: days,
                                child: Text('$days ${l10n.daysPerWeek}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _workDaysPerWeek = value ?? 5);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Continue button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveSalary,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.continueButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STEP 2: Additional Income Question
  // ============================================
  Widget _buildStep2_AskMore() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💰', style: TextStyle(fontSize: 48)),
            ),
          ),

          const SizedBox(height: 32),

          Text(
            l10n.doYouHaveOtherIncome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            l10n.otherIncomeDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 48),

          // Yes button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plusCircle, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    l10n.yesAddIncome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // No button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              onPressed: () {
                // Skip to summary
                setState(() => _currentStep = 3);
                _pageController.animateToPage(
                  3,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.cardBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.noOnlySalary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STEP 3: Add Additional Income
  // ============================================
  Widget _buildStep3_AddMore() {
    final l10n = AppLocalizations.of(context)!;
    final additionalSources = _incomeSources.where((s) => !s.isPrimary).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addAdditionalIncome,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // Category selection
          Text(
            l10n.incomeType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: IncomeCategory.values
                .where((c) => c != IncomeCategory.salary)
                .map((category) {
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = category);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
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

          // Title (optional)
          TextField(
            controller: _additionalTitleController,
            decoration: InputDecoration(
              labelText: l10n.descriptionOptional,
              hintText: _selectedCategory?.label ?? l10n.descriptionOptionalHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Amount
          TextField(
            controller: _additionalAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              TurkishCurrencyInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: l10n.monthlyAmount,
              hintText: '0',
              suffixText: l10n.tl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addAdditionalIncome,
              icon: const Icon(LucideIcons.plus),
              label: Text(l10n.addIncome),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Added incomes list
          if (additionalSources.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              l10n.addedIncomes,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...additionalSources.map((source) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Text(
                      source.category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            source.category.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${formatTurkishCurrency(source.amount, decimalDigits: 0, showDecimals: false)} TL',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      color: AppColors.error,
                      onPressed: () => _removeIncome(source.id),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 32),

          // Continue button - auto add if form has data
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // If form has filled data, add first
                final hasAmount = parseAmount(_additionalAmountController.text) != null &&
                    parseAmount(_additionalAmountController.text)! > 0;
                final hasCategory = _selectedCategory != null;

                if (hasAmount && hasCategory) {
                  // Form filled, add first then continue
                  _addAdditionalIncome();
                }
                _nextStep();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.continueButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Back button
          Center(
            child: TextButton(
              onPressed: _previousStep,
              child: Text(l10n.goBack),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STEP 4: Summary
  // ============================================
  Widget _buildStep4_Summary() {
    final l10n = AppLocalizations.of(context)!;
    final total = _incomeSources.fold<double>(
      0,
      (sum, s) => sum + s.amount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.checkCircle,
              size: 48,
              color: AppColors.success,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            l10n.incomeSummary,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 32),

          // Total card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  l10n.totalMonthlyIncome,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatTurkishCurrency(total, decimalDigits: 0, showDecimals: false)} ${l10n.tl}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.incomeSourceCount(_incomeSources.length),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Income breakdown
          ...List.generate(_incomeSources.length, (index) {
            final source = _incomeSources[index];
            final percentage = total > 0 ? (source.amount / total * 100) : 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: source.isPrimary
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        source.category.icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          source.category.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${formatTurkishCurrency(source.amount, decimalDigits: 0, showDecimals: false)} TL',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '%${percentage.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),

          // Complete button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _complete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.complete,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Edit button
          TextButton(
            onPressed: () {
              setState(() => _currentStep = 2);
              _pageController.animateToPage(
                2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            },
            child: Text(l10n.editMyIncomes),
          ),
        ],
      ),
    );
  }
}
