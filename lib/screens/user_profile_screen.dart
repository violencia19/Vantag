import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../theme/theme.dart';
import 'income_wizard_screen.dart';
import 'main_screen.dart';

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
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _dailyHoursController.dispose();
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

    setState(() => _isSaving = true);

    final profile = UserProfile(
      incomeSources: _incomeSources,
      dailyHours: dailyHours,
      workDaysPerWeek: _workDaysPerWeek,
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    }
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
                icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
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
                    child: const Icon(
                      LucideIcons.user,
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

                // Dil Seçimi
                _buildLanguageSection(l10n),

                const SizedBox(height: 24),

                // Google Hesabı Bağlama Bölümü
                _buildGoogleLinkSection(l10n),

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

  /// Dil seçimi bölümü
  Widget _buildLanguageSection(AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.globe,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.language,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.selectLanguage,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dil seçenekleri
          Row(
            children: [
              Expanded(
                child: _buildLanguageOption(
                  code: 'tr',
                  name: l10n.turkish,
                  flag: '🇹🇷',
                  isSelected: currentLocale == 'tr',
                  onTap: () {
                    localeProvider.setLocale(const Locale('tr'));
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLanguageOption(
                  code: 'en',
                  name: l10n.english,
                  flag: '🇬🇧',
                  isSelected: currentLocale == 'en',
                  onTap: () {
                    localeProvider.setLocale(const Locale('en'));
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dil seçeneği widget'ı
  Widget _buildLanguageOption({
    required String code,
    required String name,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.check,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Google hesabı bağlama bölümü
  Widget _buildGoogleLinkSection(AppLocalizations l10n) {
    final isLinked = _authService.isLinkedWithGoogle;
    final user = _authService.currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLinked
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLinked
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLinked ? LucideIcons.checkCircle : LucideIcons.link,
                  color: isLinked ? AppColors.success : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLinked ? l10n.googleLinked : l10n.googleAccount,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLinked
                          ? (user?.email ?? l10n.googleLinked)
                          : l10n.backupAndSecure,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bağlı değilse buton göster
          if (!isLinked) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLinkingGoogle ? null : _linkWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  elevation: 0,
                ),
                icon: _isLinkingGoogle
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                        ),
                      )
                    : Image.network(
                        'https://www.google.com/favicon.ico',
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          LucideIcons.globe,
                          size: 20,
                          color: Colors.blue,
                        ),
                      ),
                label: Text(
                  _isLinkingGoogle ? l10n.linking : l10n.linkWithGoogle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Gelir bölümü widget'ı
  Widget _buildIncomeSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.incomeInfo,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            // Detaylı yönetim butonu
            TextButton.icon(
              onPressed: _openIncomeWizard,
              icon: Icon(
                _hasIncomeSources ? LucideIcons.pencil : LucideIcons.plusCircle,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                _hasIncomeSources ? l10n.edit : l10n.detailedEntry,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
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
            child: const Icon(
              LucideIcons.wallet,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixText: 'TL',
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
                      child: const Icon(
                        LucideIcons.wallet,
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
                    Text(
                      source.category.icon,
                      style: const TextStyle(fontSize: 16),
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
