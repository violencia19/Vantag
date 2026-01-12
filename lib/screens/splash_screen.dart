import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../providers/providers.dart';
import 'screens.dart';

/// Vantag Video Splash Screen
/// Video plays full screen, fades out, then navigates to main screen
class VantagSplashScreen extends StatefulWidget {
  const VantagSplashScreen({super.key});

  @override
  State<VantagSplashScreen> createState() => _VantagSplashScreenState();
}

class _VantagSplashScreenState extends State<VantagSplashScreen>
    with SingleTickerProviderStateMixin {
  // Background color
  static const _bgColor = Color(0xFF1A1A2E);

  // Video player
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _videoEnded = false;

  // Fade animation for video
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // App initialization
  UserProfile? _profile;
  bool _onboardingCompleted = false;
  bool _initComplete = false;

  @override
  void initState() {
    super.initState();
    _setSystemUI();
    _initFadeAnimation();
    _initVideo();
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

  void _initFadeAnimation() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  void _initVideo() {
    debugPrint('[Splash] Video init starting...');
    try {
      _videoController = VideoPlayerController.asset('lib/assets/videos/splash_video.mp4')
        ..setVolume(0) // Muted
        ..setLooping(false);

      _videoController!.initialize().then((_) {
        debugPrint('[Splash] Video initialized!');
        if (mounted) {
          setState(() {
            _videoInitialized = true;
          });
          _videoController!.play();
          _startVideoEndListener();
        }
      }).catchError((error) {
        debugPrint('[Splash] Video init error: $error');
        // Video couldn't load, navigate directly
        if (mounted) {
          _onVideoEnded();
        }
      });
    } catch (e) {
      debugPrint('[Splash] Video catch error: $e');
      // Video couldn't create, navigate directly
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

    // Fallback: After 4 seconds consider video ended
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_videoEnded) {
        _onVideoEnded();
      }
    });
  }

  void _onVideoEnded() {
    if (_videoEnded) return;
    _videoEnded = true;

    // Start fade out animation
    _fadeController.forward().then((_) async {
      // Wait for app init if not complete
      while (!_initComplete) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Navigate to next screen
      _navigateToNextScreen();
    });
  }

  Future<void> _initializeApp() async {
    final profileService = ProfileService();
    final notificationService = NotificationService();
    final subscriptionService = SubscriptionService();

    // Initialize FinanceProvider
    final financeProvider = context.read<FinanceProvider>();

    // Initialize notifications
    await notificationService.initialize();
    await notificationService.initializeDefaultSettings();
    await notificationService.requestPermission();

    // Schedule subscription renewal notifications
    _scheduleSubscriptionNotifications(subscriptionService, notificationService);

    // Profile and onboarding check
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
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          );
        },
        child: _videoInitialized && _videoController != null
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              )
            : const SizedBox.expand(), // Empty while loading
      ),
    );
  }
}
