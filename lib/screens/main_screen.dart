import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'expense_screen.dart';
import 'report_screen.dart';
import 'pursuit_list_screen.dart';
import 'settings_screen.dart';
import 'onboarding_pursuit_screen.dart';
import 'voice_input_screen.dart';
import 'lock_screen.dart';
import 'simple/simple_main_screen.dart';

class MainScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final bool startTour;

  const MainScreen({super.key, this.userProfile, this.startTour = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  // _userProfile kaldırıldı - artık Provider'dan okunuyor

  final _connectivityService = ConnectivityService();
  final _currencyService = CurrencyService();
  final _simpleModeService = SimpleModeService();
  final _deviceService = DeviceService();

  // ExpenseScreen'e erişim için GlobalKey
  final GlobalKey<State<ExpenseScreen>> _expenseScreenKey = GlobalKey();

  bool _isConnected = true;
  ExchangeRates? _exchangeRates;
  bool _isLoadingRates = true;
  bool _hasRateError = false;
  bool _isSimpleMode = false;
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<bool>? _deviceChangeSubscription;

  // Tour
  bool _shouldStartTour = false;

  // Lock state
  bool _isLocked = false;
  bool _checkingLock = true;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Profile artık Provider'dan okunuyor
    _initializeServices();
    _checkTour();
    _checkLockStatus();

    // Status bar stilini ayarla
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(
          0xFF1A1A2E,
        ), // AppColors.background hardcoded for initState
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

    // Mark tour as complete IMMEDIATELY when starting
    // This prevents the tour from showing again even if dismissed early
    TourService.markTourComplete();

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

      if (expenseState != null) {
        try {
          scrollController =
              (expenseState as dynamic).scrollController as ScrollController?;
        } catch (_) {
          // ScrollController bulunamazsa Scrollable.maybeOf kullan
        }
      }

      // Alternatif: Scrollable.maybeOf kullan
      if (scrollController == null || !scrollController.hasClients) {
        final scrollable = Scrollable.maybeOf(targetContext);
        if (scrollable != null) {
          final scrollPosition = scrollable.position;
          _animateScrollToTarget(
            scrollPosition,
            position.dy,
            widgetHeight,
            screenHeight,
            safeAreaTop,
          );
        }
        return;
      }

      // ScrollController ile scroll yap
      _animateScrollToTarget(
        scrollController.position,
        position.dy,
        widgetHeight,
        screenHeight,
        safeAreaTop,
      );
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
    // Check single device policy first
    await _checkDeviceStatus();

    // Connectivity service başlat
    await _connectivityService.initialize();
    _isConnected = _connectivityService.isConnected;

    // Simple mode service başlat
    await _simpleModeService.initialize();
    _isSimpleMode = _simpleModeService.isEnabled;

    // Listen to simple mode changes
    _simpleModeService.addListener(_onSimpleModeChanged);

    // Listen to device changes in real-time (for single device policy)
    _startDeviceWatcher();

    // Connectivity değişikliklerini dinle
    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((isConnected) {
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
      onDeleteExpense: (index) async {
        final financeProvider = context.read<FinanceProvider>();
        await financeProvider.deleteExpense(index);
      },
    );

    // Kurları çek
    await _fetchExchangeRates();

    // Bildirimleri planla
    await _scheduleNotifications();

    // Handle pending pursuit from onboarding
    await _handlePendingPursuit();

    // Sync home screen widget data
    await _syncWidgetData();

    // Otomatik abonelik kayıtlarını işle
    await _processAutoRecordSubscriptions();

    if (mounted) setState(() {});
  }

  /// Otomatik abonelik harcamalarını oluştur
  Future<void> _processAutoRecordSubscriptions() async {
    try {
      final subscriptionService = SubscriptionService();
      final count = await subscriptionService.processAutoRecordSubscriptions();

      if (count > 0 && mounted) {
        // Refresh expenses in provider
        final financeProvider = context.read<FinanceProvider>();
        await financeProvider.initialize();

        // Show notification
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.autoRecordedExpenses(count)),
            backgroundColor: context.appColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('[MainScreen] Error processing auto-records: $e');
    }
  }

  /// Handle pending pursuit creation from onboarding
  Future<void> _handlePendingPursuit() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPending = prefs.getBool(PendingPursuitKeys.hasPending) ?? false;

    if (!hasPending) return;

    final goalId = prefs.getString(PendingPursuitKeys.goalId);
    final isCustom = prefs.getBool(PendingPursuitKeys.isCustom) ?? false;
    final goalName = prefs.getString(PendingPursuitKeys.goalName) ?? '';
    final goalAmount = prefs.getDouble(PendingPursuitKeys.goalAmount) ?? 0;
    final goalEmoji = prefs.getString(PendingPursuitKeys.goalEmoji) ?? '🎯';

    // Clear pending pursuit data
    await prefs.remove(PendingPursuitKeys.hasPending);
    await prefs.remove(PendingPursuitKeys.goalId);
    await prefs.remove(PendingPursuitKeys.goalName);
    await prefs.remove(PendingPursuitKeys.goalAmount);
    await prefs.remove(PendingPursuitKeys.goalEmoji);
    await prefs.remove(PendingPursuitKeys.isCustom);

    if (!mounted) return;

    if (isCustom) {
      // For custom goal, navigate to pursuit list and open create sheet
      // Delay to ensure screen is fully built
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Navigate to Pursuits tab (index 2)
          setState(() => _currentIndex = 2);
          // Show create pursuit sheet
          _showCreatePursuitSheet();
        }
      });
    } else if (goalId != null && goalAmount > 0) {
      // Create the preset pursuit
      final pursuitProvider = context.read<PursuitProvider>();
      final proProvider = context.read<ProProvider>();
      final currencyProvider = context.read<CurrencyProvider>();

      // Initialize pursuit provider if needed
      if (!pursuitProvider.isInitialized) {
        await pursuitProvider.initialize();
      }

      // Determine category based on goal ID
      PursuitCategory category;
      switch (goalId) {
        case 'airpods':
        case 'iphone':
          category = PursuitCategory.tech;
          break;
        case 'vacation':
          category = PursuitCategory.travel;
          break;
        default:
          category = PursuitCategory.other;
      }

      final pursuit = Pursuit.create(
        name: goalName,
        targetAmount: goalAmount,
        currency: currencyProvider.currency.code,
        category: category,
        emoji: goalEmoji,
      );

      await pursuitProvider.createPursuit(
        pursuit,
        isPremium: proProvider.isPro,
      );
      debugPrint('[MainScreen] Created onboarding pursuit: $goalName');
    }
  }

  /// Show create pursuit bottom sheet
  void _showCreatePursuitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.85),
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePursuitSheet(),
    );
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

  /// Sync data to home screen widgets (iOS + Android)
  Future<void> _syncWidgetData() async {
    if (!widgetService.isSupported) return;

    final financeProvider = context.read<FinanceProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final localeProvider = context.read<LocaleProvider>();
    final pursuitProvider = context.read<PursuitProvider>();

    // Get active pursuit for widget display
    final activePursuits = pursuitProvider.activePursuits;
    String? pursuitName;
    double? pursuitProgress;
    double? pursuitTarget;

    if (activePursuits.isNotEmpty) {
      final pursuit = activePursuits.first;
      pursuitName = pursuit.name;
      pursuitProgress = pursuit.savedAmount;
      pursuitTarget = pursuit.targetAmount;
    }

    await financeProvider.syncWidgetData(
      currencySymbol: currencyProvider.currency.symbol,
      locale: localeProvider.locale?.languageCode ?? 'en',
      pursuitName: pursuitName,
      pursuitProgress: pursuitProgress,
      pursuitTarget: pursuitTarget,
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
      debugPrint('[MainScreen] Error loading rates: $e');
      if (mounted) {
        setState(() {
          _isLoadingRates = false;
          _hasRateError = true;
        });
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoadingRates),
            backgroundColor: context.appColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onSimpleModeChanged() {
    if (mounted) {
      setState(() {
        _isSimpleMode = _simpleModeService.isEnabled;
      });
    }
  }

  /// Check if this device is still the active device (single device policy)
  Future<void> _checkDeviceStatus() async {
    final result = await _deviceService.checkDeviceStatus();
    if (result == DeviceCheckResult.anotherDeviceLoggedIn && mounted) {
      _handleDeviceMismatch();
    }
  }

  /// Start watching for device changes in real-time
  void _startDeviceWatcher() {
    _deviceChangeSubscription = _deviceService.watchDeviceChanges().listen((
      anotherDeviceLoggedIn,
    ) {
      if (anotherDeviceLoggedIn && mounted) {
        _handleDeviceMismatch();
      }
    });
  }

  /// Handle device mismatch - show dialog and sign out
  Future<void> _handleDeviceMismatch() async {
    // Cancel device watcher to prevent multiple triggers
    _deviceChangeSubscription?.cancel();
    _deviceChangeSubscription = null;

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    // Show dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              PhosphorIconsDuotone.warning,
              color: context.appColors.warning,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.loggedOutFromAnotherDevice,
                style: TextStyle(
                  color: context.appColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.loggedOutFromAnotherDeviceMessage,
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.understood,
              style: TextStyle(
                color: context.appColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    // Sign out without clearing device token (since we're being kicked out)
    await AuthService().signOut(clearDevice: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _deviceChangeSubscription?.cancel();
    _connectivityService.dispose();
    _simpleModeService.removeListener(_onSimpleModeChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
      // Clean up simulation expenses when app goes to background
      _cleanupSimulations();
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      _checkLockOnResume();
      // Refresh theme for time-based automatic mode
      context.read<ThemeProvider>().refreshTheme();
    } else if (state == AppLifecycleState.detached) {
      // Clean up simulation expenses when app is closing
      _cleanupSimulations();
    }
  }

  /// Clean up simulation expenses - they shouldn't persist
  Future<void> _cleanupSimulations() async {
    try {
      await ExpenseHistoryService().clearSimulations();
      // Refresh provider to reflect changes
      if (mounted) {
        context.read<FinanceProvider>().refresh();
      }
    } catch (e) {
      debugPrint('[Cleanup] Error clearing simulations: $e');
    }
  }

  Future<void> _checkLockStatus() async {
    final lockEnabled = await LockService.isLockEnabled();
    final hasPinSet = await LockService.hasPinSet();

    if (mounted) {
      setState(() {
        _isLocked = lockEnabled && hasPinSet;
        _checkingLock = false;
      });
    }
  }

  Future<void> _checkLockOnResume() async {
    final lockEnabled = await LockService.isLockEnabled();
    final hasPinSet = await LockService.hasPinSet();

    if (lockEnabled && hasPinSet && mounted) {
      setState(() => _isLocked = true);
    }
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
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

  void _openVoiceInput() {
    HapticFeedback.heavyImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VoiceInputScreen()),
    );
  }

  void _showAIChat() {
    HapticFeedback.mediumImpact();
    AnimatedBottomSheet.show(
      context: context,
      maxHeight: MediaQuery.of(context).size.height * 0.85,
      showDragHandle: false,
      child: const AIChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking lock status
    if (_checkingLock) {
      return Scaffold(
        backgroundColor: context.appColors.background,
        body: const SizedBox.shrink(),
      );
    }

    // Show lock screen if locked
    if (_isLocked) {
      return LockScreen(onUnlocked: _onUnlocked);
    }

    // Show Simple Mode screen if enabled
    if (_isSimpleMode) {
      return const SimpleMainScreen();
    }

    // Provider'ı WATCH et - gelir değiştiğinde tüm ekran yenilensin
    final financeProvider = context.watch<FinanceProvider>();
    final currentProfile =
        financeProvider.userProfile ??
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
            backgroundColor: context.appColors.background,
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
              onAddLongPress: _openVoiceInput,
            ),
            // AI Chat FAB (hidden in Simple Mode)
            floatingActionButton: _isSimpleMode
                ? null
                : AIFloatingButton(onTap: _showAIChat),
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
          color: context.appColors.warning.withValues(alpha: 0.95),
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
                      color: context.appColors.textPrimary.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      PhosphorIconsDuotone.wifiSlash,
                      size: 16,
                      color: context.appColors.background,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.offlineMode,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.background,
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
