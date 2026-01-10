import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../utils/currency_utils.dart';
import 'expense_screen.dart';
import 'report_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final bool startTour;

  const MainScreen({
    super.key,
    this.userProfile,
    this.startTour = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  // _userProfile kaldırıldı - artık Provider'dan okunuyor

  final _connectivityService = ConnectivityService();
  final _currencyService = CurrencyService();
  final _calculationService = CalculationService();

  bool _isConnected = true;
  ExchangeRates? _exchangeRates;
  bool _isLoadingRates = true;
  bool _hasRateError = false;
  StreamSubscription<bool>? _connectivitySubscription;

  // Tour
  bool _shouldStartTour = false;

  @override
  void initState() {
    super.initState();
    // Profile artık Provider'dan okunuyor
    _initializeServices();
    _checkTour();

    // Status bar stilini ayarla
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _checkTour() async {
    // Widget'tan gelen parametre ile kontrol et
    if (widget.startTour) {
      setState(() => _shouldStartTour = true);
      return;
    }

    // İlk kez açılış kontrolü
    final hasSeenTour = await TourService.hasSeenTour();
    if (!hasSeenTour && mounted) {
      setState(() => _shouldStartTour = true);
    }
  }

  void _startTour(BuildContext context) {
    // Önce ana sayfaya yönlendir (index 0)
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
    }

    // Kısa bir gecikme ile turu başlat (sayfa geçişi için)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        ShowCaseWidget.of(context).startShowCase([
          TourKeys.financialSnapshot,
          TourKeys.currencyRates,
          TourKeys.streakWidget,
          TourKeys.subscriptionButton,
          TourKeys.dateChips,
          TourKeys.amountField,
          TourKeys.descriptionField,
          TourKeys.categoryField,
          TourKeys.navBarReport,
          TourKeys.navBarAchievements,
          TourKeys.navBarProfile,
          TourKeys.navBarAddButton,
        ]);
      }
    });
  }

  void _onTourComplete() async {
    await TourService.markTourComplete();
    if (mounted) {
      setState(() => _shouldStartTour = false);
    }
  }

  // _activeProfile kaldırıldı - build() içinde Provider'dan direkt okunuyor

  Future<void> _initializeServices() async {
    // Connectivity service başlat
    await _connectivityService.initialize();
    _isConnected = _connectivityService.isConnected;

    // Connectivity değişikliklerini dinle
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((isConnected) {
      setState(() => _isConnected = isConnected);

      // İnternet geldiğinde kurları güncelle
      if (isConnected) {
        _fetchExchangeRates();
      }
    });

    // Kurları çek
    await _fetchExchangeRates();

    // Bildirimleri planla
    await _scheduleNotifications();

    if (mounted) setState(() {});
  }

  Future<void> _scheduleNotifications() async {
    final notificationService = NotificationService();

    // Streak verilerini Provider'dan al
    final financeProvider = context.read<FinanceProvider>();
    final streakData = financeProvider.streakData;

    // Streak hatırlatması planla
    await notificationService.scheduleStreakReminder(
      currentStreak: streakData.currentStreak,
      lastEntryDate: streakData.lastEntryDate,
    );

    // Haftalık içgörü planla
    await notificationService.scheduleWeeklyInsight(
      streakDays: streakData.currentStreak,
    );
  }

  Future<void> _fetchExchangeRates() async {
    setState(() {
      _isLoadingRates = true;
      _hasRateError = false;
    });

    try {
      final rates = await _currencyService.getRates();
      if (mounted) {
        setState(() {
          _exchangeRates = rates;
          _isLoadingRates = false;
          _hasRateError = rates == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRates = false;
          _hasRateError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  void _onProfileUpdated(UserProfile profile) {
    // Provider zaten watch edildiğinden setState gerekli değil
    // ProfileScreen callback beklentisi için metod korunuyor
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  void _showQuickAddSheet() {
    showQuickAddSheet(
      context,
      onAdd: (amount, category, subCategory) {
        _processQuickAdd(amount, category, subCategory);
      },
    );
  }

  void _processQuickAdd(double amount, String category, String? subCategory) {
    final now = DateTime.now();

    // Provider'dan güncel profili al
    final provider = context.read<FinanceProvider>();
    final currentProfile = provider.userProfile ??
        UserProfile(incomeSources: [], dailyHours: 8, workDaysPerWeek: 5);

    // Hesaplama yap
    final result = _calculationService.calculateExpense(
      userProfile: currentProfile,
      expenseAmount: amount,
      month: now.month,
      year: now.year,
    );

    // Simülasyon tespiti
    final recordType = Expense.detectRecordType(amount, result.hoursRequired);

    // Expense oluştur - karar bekliyor durumunda
    final expense = Expense(
      amount: amount,
      category: category,
      subCategory: subCategory,
      date: now,
      hoursRequired: result.hoursRequired,
      daysRequired: result.daysRequired,
      recordType: recordType,
      decision: ExpenseDecision.thinking, // Başlangıçta "düşünüyorum"
      decisionDate: now,
    );

    // Provider'a ekle
    final financeProvider = context.read<FinanceProvider>();
    financeProvider.addExpense(expense);

    // Feedback
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(PhosphorIconsDuotone.clock, size: 18, color: AppColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${formatTurkishCurrency(amount, decimalDigits: 2)} TL - ${result.hoursRequired.toStringAsFixed(1)} saat',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );

    // Ana sayfaya git
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    // Provider'ı WATCH et - gelir değiştiğinde tüm ekran yenilensin
    final financeProvider = context.watch<FinanceProvider>();
    final currentProfile = financeProvider.userProfile ??
        UserProfile(incomeSources: [], dailyHours: 8, workDaysPerWeek: 5);

    return ShowCaseWidget(
      onComplete: (index, key) {
        // Son adım tamamlandığında
        if (index == 11) {
          _onTourComplete();
        }
      },
      onStart: (index, key) {
        // Tur başladığında
      },
      builder: (context) => Builder(
        builder: (context) {
          // Tur başlatılmalı mı kontrol et
          if (_shouldStartTour) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_shouldStartTour) {
                _shouldStartTour = false;
                _startTour(context);
              }
            });
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            extendBody: true, // Nav bar arkasında içerik görünsün
            body: Stack(
              children: [
                // Ana içerik
                Column(
                  children: [
                    // İnternet bağlantısı banner'ı
                    _OfflineBanner(isVisible: !_isConnected),

                    // Ekranlar
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: [
                          ExpenseScreen(
                            userProfile: currentProfile,
                            exchangeRates: _exchangeRates,
                            isLoadingRates: _isLoadingRates,
                            hasRateError: _hasRateError,
                            onRetryRates: _fetchExchangeRates,
                          ),
                          ReportScreen(userProfile: currentProfile),
                          const AchievementsScreen(),
                          ProfileScreen(
                            userProfile: currentProfile,
                            onProfileUpdated: _onProfileUpdated,
                            onStartTour: () => _startTour(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Premium floating nav bar with Showcase
            bottomNavigationBar: PremiumNavBarWithShowcase(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              onAddTap: _showQuickAddSheet,
            ),
          );
        },
      ),
    );
  }
}

/// Offline banner - minimal ve şık
class _OfflineBanner extends StatelessWidget {
  final bool isVisible;

  const _OfflineBanner({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          width: double.infinity,
          color: AppColors.warning.withValues(alpha: 0.95),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      PhosphorIconsDuotone.wifiSlash,
                      size: 16,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.offlineMode,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.background,
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
}
