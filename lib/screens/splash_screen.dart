import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../providers/providers.dart';
import 'screens.dart';

/// Vantag Video Splash Screen
/// Akış: Video (4s) → Background fade → Logo heartbeat (1s) → Navigate
class VantagSplashScreen extends StatefulWidget {
  const VantagSplashScreen({super.key});

  @override
  State<VantagSplashScreen> createState() => _VantagSplashScreenState();
}

class _VantagSplashScreenState extends State<VantagSplashScreen>
    with TickerProviderStateMixin {
  // Renkler
  static const _bgColor = Color(0xFF1A1A2E);

  // Video player
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _videoEnded = false;

  // Heartbeat animation
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatScale;

  // Background fade animation
  late AnimationController _bgFadeController;
  late Animation<double> _bgFadeOpacity;

  // App initialization
  UserProfile? _profile;
  bool _onboardingCompleted = false;
  bool _initComplete = false;

  @override
  void initState() {
    super.initState();
    _setSystemUI();
    _initAnimations(); // Önce animasyonlar
    _initVideo(); // Sonra video
    _initializeApp();
  }

  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initVideo() {
    debugPrint('🎬 [Splash] Video init başlıyor...');
    try {
      _videoController = VideoPlayerController.asset('lib/assets/videos/splash_video.mp4')
        ..setVolume(0) // Muted
        ..setLooping(false);

      _videoController!.initialize().then((_) {
        debugPrint('🎬 [Splash] Video initialized!');
        if (mounted) {
          setState(() {
            _videoInitialized = true;
          });
          _videoController!.play();
          _startVideoEndListener();
        }
      }).catchError((error) {
        debugPrint('🎬 [Splash] Video init error: $error');
        // Video yüklenemezse direkt logo göster
        if (mounted) {
          _onVideoEnded();
        }
      });
    } catch (e) {
      debugPrint('🎬 [Splash] Video catch error: $e');
      // Video oluşturulamadıysa direkt logo göster
      if (mounted) {
        _onVideoEnded();
      }
    }
  }

  void _startVideoEndListener() {
    final controller = _videoController;
    if (controller == null) return;

    controller.addListener(() {
      if (controller.value.isInitialized &&
          !_videoEnded &&
          controller.value.position >= controller.value.duration) {
        _onVideoEnded();
      }
    });

    // Fallback: 4 saniye sonra video bitmiş say
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_videoEnded) {
        _onVideoEnded();
      }
    });
  }

  void _onVideoEnded() {
    if (_videoEnded) return;
    setState(() {
      _videoEnded = true;
    });
    _startPostVideoAnimations();
  }

  void _initAnimations() {
    // Background fade animation (video bitince arkaplan görünür)
    _bgFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bgFadeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgFadeController, curve: Curves.easeOut),
    );

    // Heartbeat animation: 1.0 → 1.2 → 1.0 → 1.1 → 1.0
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heartbeatScale = TweenSequence<double>([
      // 1.0 → 1.2 (büyük nabız)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      // 1.2 → 1.0 (geri çekilme)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      // 1.0 → 1.1 (küçük nabız)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      // 1.1 → 1.0 (son geri çekilme)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_heartbeatController);
  }

  Future<void> _startPostVideoAnimations() async {
    // Background fade
    await _bgFadeController.forward();

    // Kısa bekleme
    await Future.delayed(const Duration(milliseconds: 100));

    // Heartbeat animasyonu
    await _heartbeatController.forward();

    // Init tamamlanmasını bekle
    while (!_initComplete) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Kısa bekleme sonra navigate
    await Future.delayed(const Duration(milliseconds: 200));

    _navigateToNextScreen();
  }

  Future<void> _initializeApp() async {
    final profileService = ProfileService();
    final notificationService = NotificationService();
    final subscriptionService = SubscriptionService();

    // FinanceProvider'ı initialize et
    final financeProvider = context.read<FinanceProvider>();

    // Bildirimleri başlat
    await notificationService.initialize();
    await notificationService.initializeDefaultSettings();
    await notificationService.requestPermission();

    // Yarın yenilenecek aboneliklerin bildirimlerini planla
    _scheduleSubscriptionNotifications(subscriptionService, notificationService);

    // Profil ve onboarding kontrolü
    final results = await Future.wait([
      profileService.getProfile(),
      profileService.isOnboardingCompleted(),
      financeProvider.initialize(),
    ]);

    _profile = results[0] as UserProfile?;
    _onboardingCompleted = results[1] as bool;
    _initComplete = true;
  }

  Future<void> _scheduleSubscriptionNotifications(
    SubscriptionService subscriptionService,
    NotificationService notificationService,
  ) async {
    final tomorrow = await subscriptionService.getSubscriptionsRenewingTomorrow();

    if (tomorrow.isNotEmpty) {
      final subscriptionData = tomorrow
          .map((s) => (id: s.id, name: s.name, amount: s.amount))
          .toList();

      await notificationService.scheduleSubscriptionReminders(subscriptionData);
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    Widget nextScreen;

    if (!_onboardingCompleted) {
      nextScreen = const OnboardingScreen();
    } else if (_profile != null) {
      nextScreen = MainScreen(userProfile: _profile!);
    } else {
      nextScreen = const UserProfileScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _heartbeatController.dispose();
    _bgFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Video (en altta)
          if (_videoInitialized && !_videoEnded && _videoController != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),

          // Layer 2: Background color (video bitince fade in)
          if (_videoEnded)
            AnimatedBuilder(
              animation: _bgFadeController,
              builder: (context, _) {
                return Opacity(
                  opacity: _bgFadeOpacity.value,
                  child: Container(color: _bgColor),
                );
              },
            ),

          // Layer 3: Logo (video bitince heartbeat ile görünür)
          if (_videoEnded)
            Center(
              child: AnimatedBuilder(
                animation: _heartbeatController,
                builder: (context, child) {
                  // Animasyon başlamadan scale 1.0 olsun
                  final scale = _heartbeatController.isAnimating || _heartbeatController.isCompleted
                      ? _heartbeatScale.value
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 120,
                  height: 120,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
