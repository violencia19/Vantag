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
import 'pursuit_list_screen.dart';
import 'settings_screen.dart';

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

  // ExpenseScreen'e erişim için GlobalKey
  final GlobalKey<State<ExpenseScreen>> _expenseScreenKey = GlobalKey();

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

  /// ShowCase hedef widget'ına scroll et
  void _scrollToShowcaseTarget(GlobalKey key) {
    // Küçük bir gecikme ile pozisyon hesapla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = key.currentContext;
      if (targetContext == null) return;

      // Hedef widget'ın pozisyonunu bul
      final renderBox = targetContext.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      // Ekrana göre pozisyon
      final position = renderBox.localToGlobal(Offset.zero);
      final widgetHeight = renderBox.size.height;
      final screenHeight = MediaQuery.of(context).size.height;
      final safeAreaTop = MediaQuery.of(context).padding.top;

      // Nav bar öğeleri için scroll yapma (ekranın altında)
      if (position.dy > screenHeight - 150) {
        return;
      }

      // ExpenseScreen'in ScrollController'ını al
      final expenseState = _expenseScreenKey.currentState;
      ScrollController? scrollController;

      if (expenseState != null && expenseState is dynamic) {
        try {
          scrollController = (expenseState as dynamic).scrollController as ScrollController?;
        } catch (_) {
          // ScrollController bulunamazsa Scrollable.maybeOf kullan
        }
      }

      // Alternatif: Scrollable.maybeOf kullan
      if (scrollController == null || !scrollController.hasClients) {
        final scrollable = Scrollable.maybeOf(targetContext);
        if (scrollable != null) {
          final scrollPosition = scrollable.position;
          _animateScrollToTarget(scrollPosition, position.dy, widgetHeight, screenHeight, safeAreaTop);
        }
        return;
      }

      // ScrollController ile scroll yap
      _animateScrollToTarget(scrollController.position, position.dy, widgetHeight, screenHeight, safeAreaTop);
    });
  }

  /// Hedef widget'a animasyonlu scroll
  void _animateScrollToTarget(
    ScrollPosition scrollPosition,
    double targetY,
    double widgetHeight,
    double screenHeight,
    double safeAreaTop,
  ) {
    // Hedef pozisyonu hesapla - widget ekranın üst 1/3'ünde olsun
    final targetPosition = screenHeight * 0.25;
    final scrollOffset = targetY - targetPosition;

    // Widget zaten görünür alanda mı?
    final visibleTop = safeAreaTop + 50; // Header için boşluk
    final visibleBottom = screenHeight - 200; // Nav bar + tooltip için boşluk

    if (targetY >= visibleTop && (targetY + widgetHeight) <= visibleBottom) {
      // Widget zaten görünür - scroll gerekmez
      return;
    }

    // Hedef scroll pozisyonunu hesapla
    final newScrollPosition = scrollPosition.pixels + scrollOffset;

    // Scroll animasyonu
    scrollPosition.animateTo(
      newScrollPosition.clamp(0.0, scrollPosition.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
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

    // Setup deep link callbacks with actual hourly rate from provider
    DeepLinkService().setCallbacks(
      getHourlyRate: () {
        final financeProvider = context.read<FinanceProvider>();
        return financeProvider.hourlyRate;
      },
      onAddExpense: (expense) async {
        final financeProvider = context.read<FinanceProvider>();
        await financeProvider.addExpense(expense);
      },
    );

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

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  void _showAddExpenseSheet() {
    showAddExpenseSheet(
      context,
      exchangeRates: _exchangeRates,
      onExpenseAdded: () {
        // Refresh streak if needed
        HapticFeedback.mediumImpact();
        // Navigate to home tab to show the new expense
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
    );
  }

  void _showAIChat() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => const AIChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider'ı WATCH et - gelir değiştiğinde tüm ekran yenilensin
    final financeProvider = context.watch<FinanceProvider>();
    final currentProfile = financeProvider.userProfile ??
        UserProfile(incomeSources: [], dailyHours: 8, workDaysPerWeek: 5);

    return ShowCaseWidget(
      // Otomatik scroll (ShowCaseWidget'ın kendi mekanizması)
      enableAutoScroll: true,
      scrollDuration: const Duration(milliseconds: 400),
      onComplete: (index, key) {
        // Son adım tamamlandığında
        if (index == 11) {
          _onTourComplete();
        }
      },
      onStart: (index, key) {
        // Hedef widget'a scroll et (yedek mekanizma)
        _scrollToShowcaseTarget(key);
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
                            key: _expenseScreenKey,
                            userProfile: currentProfile,
                            exchangeRates: _exchangeRates,
                            isLoadingRates: _isLoadingRates,
                            hasRateError: _hasRateError,
                            onRetryRates: _fetchExchangeRates,
                          ),
                          ReportScreen(userProfile: currentProfile),
                          const PursuitListScreen(),
                          const SettingsScreen(),
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
              onAddTap: _showAddExpenseSheet,
            ),
            // AI Chat FAB
            floatingActionButton: AIFloatingButton(
              onTap: _showAIChat,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
