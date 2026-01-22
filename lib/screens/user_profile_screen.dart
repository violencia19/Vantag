import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../theme/theme.dart';
import 'income_wizard_screen.dart';
import 'onboarding_try_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final UserProfile? existingProfile;

  const UserProfileScreen({
    super.key,
    this.existingProfile,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _incomeController = TextEditingController();
  final _dailyHoursController = TextEditingController();
  final _budgetController = TextEditingController();
  final _savingsGoalController = TextEditingController();
  final _profileService = ProfileService();
  final _authService = AuthService();
  int _workDaysPerWeek = 6;
  bool _isSaving = false;
  bool _isLinkingGoogle = false;
  List<IncomeSource> _incomeSources = [];

  bool get _isEditMode => widget.existingProfile != null;
  bool get _hasIncomeSources => _incomeSources.isNotEmpty;
  double get _totalIncome => _incomeSources.fold<double>(0, (sum, s) => sum + s.amount);

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// Google hesabını bağla
  Future<void> _linkWithGoogle() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLinkingGoogle = true);

    try {
      final result = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (result.success) {
        HapticFeedback.mediumImpact();
        _showSuccess(l10n.googleLinkedSuccess);
        setState(() {}); // UI'ı yenile
      } else {
        _showError(result.errorMessage ?? l10n.error);
      }
    } catch (e) {
      if (mounted) {
        _showError('${l10n.error}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLinkingGoogle = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _incomeSources = List.from(widget.existingProfile!.incomeSources);
      _dailyHoursController.text = widget.existingProfile!.dailyHours.toString();
      _workDaysPerWeek = widget.existingProfile!.workDaysPerWeek;

      // Eğer varolan gelirler varsa, toplam geliri göster
      if (_incomeSources.isNotEmpty) {
        _incomeController.text = formatTurkishCurrency(
          widget.existingProfile!.monthlyIncome,
          decimalDigits: 0,
          showDecimals: false,
        );
      }

      // Bütçe değerlerini doldur
      if (widget.existingProfile!.monthlyBudget != null) {
        _budgetController.text = formatTurkishCurrency(
          widget.existingProfile!.monthlyBudget!,
          decimalDigits: 0,
          showDecimals: false,
        );
      }
      if (widget.existingProfile!.monthlySavingsGoal != null) {
        _savingsGoalController.text = formatTurkishCurrency(
          widget.existingProfile!.monthlySavingsGoal!,
          decimalDigits: 0,
          showDecimals: false,
        );
      }
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _dailyHoursController.dispose();
    _budgetController.dispose();
    _savingsGoalController.dispose();
    super.dispose();
  }

  /// Gelir wizard'ını aç
  Future<void> _openIncomeWizard() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomeWizardScreen(
          existingSources: _incomeSources,
        ),
      ),
    );

    // Wizard kapandıktan sonra Provider'dan güncel veriyi al
    if (mounted) {
      final provider = context.read<FinanceProvider>();
      final profile = provider.userProfile;
      if (profile != null) {
        setState(() {
          _incomeSources = profile.incomeSources;
          _incomeController.text = formatTurkishCurrency(
            _totalIncome,
            decimalDigits: 0,
            showDecimals: false,
          );
        });
        HapticFeedback.lightImpact();
      }
    }
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context);
    final dailyHours = double.tryParse(_dailyHoursController.text);

    // Gelir kontrolü
    if (_incomeSources.isEmpty) {
      // Eğer manuel gelir girilmişse onu kullan
      final manualIncome = parseAmount(_incomeController.text);
      if (manualIncome == null || manualIncome <= 0) {
        _showError(l10n.error);
        return;
      }
      // Manuel geliri primary income olarak ekle
      _incomeSources = [IncomeSource.salary(amount: manualIncome)];
    }

    // Çalışma saati validasyonu
    if (dailyHours == null || dailyHours <= 0) {
      _showError(l10n.error);
      return;
    }

    if (dailyHours > 24) {
      _showError(l10n.error);
      return;
    }

    if (dailyHours > 16) {
      _showError(l10n.error);
      return;
    }

    // Yeni kullanıcı için Google bağlantı popup'ı göster
    if (!_isEditMode && !_authService.isLinkedWithGoogle) {
      final shouldLink = await _showGoogleLinkDialog(l10n);
      if (shouldLink == true) {
        await _linkWithGoogle();
      }
    }

    if (!mounted) return;

    setState(() => _isSaving = true);

    // Bütçe değerlerini parse et
    final budget = parseTurkishCurrency(_budgetController.text);
    final savingsGoal = parseTurkishCurrency(_savingsGoalController.text);

    final profile = UserProfile(
      incomeSources: _incomeSources,
      dailyHours: dailyHours,
      workDaysPerWeek: _workDaysPerWeek,
      monthlyBudget: budget,
      monthlySavingsGoal: savingsGoal,
    );

    await _profileService.saveProfile(profile);

    if (!mounted) return;

    // FinanceProvider'ı güncelle
    final financeProvider = context.read<FinanceProvider>();
    financeProvider.setUserProfile(profile);

    HapticFeedback.mediumImpact();

    if (_isEditMode) {
      Navigator.pop(context, profile);
    } else {
      // Go to "Aha Moment" try screen before main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingTryScreen(),
        ),
      );
    }
  }

  /// Google bağlantı dialog'unu göster
  Future<bool?> _showGoogleLinkDialog(AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                PhosphorIconsDuotone.link,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.linkWithGoogleTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.linkWithGoogleDescription,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  elevation: 0,
                ),
                icon: Image.network(
                  'https://www.google.com/favicon.ico',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    PhosphorIconsDuotone.globe,
                    size: 20,
                    color: Colors.blue,
                  ),
                ),
                label: Text(
                  l10n.linkWithGoogle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                l10n.skipForNow,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _isEditMode
          ? AppBar(
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: Icon(PhosphorIconsDuotone.arrowLeft, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                l10n.editProfile,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isEditMode) ...[
                  const SizedBox(height: 48),
                  // Welcome header
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      PhosphorIconsDuotone.user,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.welcome,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.welcomeSubtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 48),
                ] else ...[
                  const SizedBox(height: 24),
                ],

                // Gelir Bölümü
                _buildIncomeSection(l10n),
                const SizedBox(height: 32),

                // Çalışma Saati
                LabeledTextField(
                  controller: _dailyHoursController,
                  label: l10n.dailyWorkHours,
                  keyboardType: TextInputType.number,
                  hint: '8',
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      l10n.hours,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Çalışma Günü
                Text(
                  l10n.weeklyWorkDays,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Work days selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final isSelected = _workDaysPerWeek == day;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _workDaysPerWeek = day),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$day',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.background : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.workingDaysPerWeek(_workDaysPerWeek),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),

                const SizedBox(height: 32),

                // Ek Gelir Bölümü
                _buildAdditionalIncomeSection(l10n),

                const SizedBox(height: 32),

                // Bütçe Ayarları Bölümü
                _buildBudgetSection(l10n),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
                            ),
                          )
                        : Text(
                            _isEditMode ? l10n.save : l10n.getStarted,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ek Gelir bölümü
  Widget _buildAdditionalIncomeSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.additionalIncomeQuestion,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              // 1. Önce mevcut maaş değerini al
              final currentSalary = parseAmount(_incomeController.text);

              // 2. Eğer maaş girilmişse ve henüz _incomeSources'ta yoksa, ekle
              if (currentSalary != null && currentSalary > 0) {
                final hasPrimary = _incomeSources.any((s) => s.isPrimary);
                if (!hasPrimary) {
                  // Yeni maaş ekle
                  _incomeSources.insert(0, IncomeSource.salary(amount: currentSalary));
                } else {
                  // Mevcut primary income'u güncelle
                  final primaryIndex = _incomeSources.indexWhere((s) => s.isPrimary);
                  if (primaryIndex >= 0) {
                    _incomeSources[primaryIndex] = _incomeSources[primaryIndex].copyWith(
                      amount: currentSalary,
                    );
                  }
                }
              }

              // 3. Sonra IncomeWizardScreen'e git
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IncomeWizardScreen(
                    existingSources: _incomeSources,
                    skipToAdditional: true,
                  ),
                ),
              );

              // Wizard kapandıktan sonra Provider'dan güncel veriyi al
              if (mounted) {
                final provider = context.read<FinanceProvider>();
                final profile = provider.userProfile;
                if (profile != null) {
                  setState(() {
                    _incomeSources = profile.incomeSources;
                    _incomeController.text = formatTurkishCurrency(
                      _totalIncome,
                      decimalDigits: 0,
                      showDecimals: false,
                    );
                  });
                  HapticFeedback.lightImpact();
                }
              }
            },
            icon: Icon(PhosphorIconsDuotone.plusCircle, size: 20),
            label: Text(l10n.addAdditionalIncome),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Bütçe Ayarları bölümü
  Widget _buildBudgetSection(AppLocalizations l10n) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        Row(
          children: [
            Icon(PhosphorIconsDuotone.chartPieSlice, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.budgetSettings,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.budgetSettingsHint,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        // Aylık bütçe
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: _budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [TurkishCurrencyInputFormatter()],
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: l10n.monthlySpendingLimit,
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: '30.000',
              hintStyle: TextStyle(color: AppColors.textTertiary.withValues(alpha: 0.5)),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  PhosphorIconsDuotone.wallet,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixText: currencyProvider.code,
              suffixStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.monthlySpendingLimitHint,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 16),

        // Tasarruf hedefi
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: _savingsGoalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [TurkishCurrencyInputFormatter()],
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: l10n.monthlySavingsGoal,
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: '5.000',
              hintStyle: TextStyle(color: AppColors.textTertiary.withValues(alpha: 0.5)),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  PhosphorIconsDuotone.piggyBank,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixText: currencyProvider.code,
              suffixStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.monthlySavingsGoalHint,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),

        // Bilgi kartı
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(PhosphorIconsDuotone.lightbulb, color: AppColors.info, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.budgetInfoMessage,
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Gelir bölümü widget'ı
  Widget _buildIncomeSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.incomeInfo,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Eğer gelir kaynakları varsa, özet göster
        if (_hasIncomeSources) ...[
          _buildIncomeSourcesSummary(l10n),
        ] else ...[
          // Basit gelir girişi
          _buildSimpleIncomeInput(),
        ],
      ],
    );
  }

  /// Basit gelir girişi (wizard kullanılmadıysa)
  Widget _buildSimpleIncomeInput() {
    final currencyProvider = context.watch<CurrencyProvider>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: _incomeController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          TurkishCurrencyInputFormatter(),
        ],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '25.000',
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              PhosphorIconsDuotone.wallet,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixText: currencyProvider.code,
          suffixStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  /// Gelir kaynakları özeti
  Widget _buildIncomeSourcesSummary(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _openIncomeWizard,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            // Toplam
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        PhosphorIconsDuotone.wallet,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.totalIncome,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${formatTurkishCurrency(_totalIncome, decimalDigits: 0, showDecimals: false)} TL',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.incomeSources(_incomeSources.length),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            // Kaynak listesi (kısa özet)
            if (_incomeSources.length <= 3) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 12),
              ...(_incomeSources.map((source) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      source.category.icon,
                      size: 18,
                      color: source.category.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        source.title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${formatTurkishCurrency(source.amount, decimalDigits: 0, showDecimals: false)} TL',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ))),
            ],
          ],
        ),
      ),
    );
  }
}
