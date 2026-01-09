import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../providers/providers.dart';
import 'screens.dart';

/// Vantag Animated Splash Screen
/// Animasyon: Yıldız hareketi → V harfi çizimi → Glow → Fade geçişi
class VantagSplashScreen extends StatefulWidget {
  const VantagSplashScreen({super.key});

  @override
  State<VantagSplashScreen> createState() => _VantagSplashScreenState();
}

class _VantagSplashScreenState extends State<VantagSplashScreen>
    with TickerProviderStateMixin {
  // Animasyon sabitleri
  static const _starMoveDuration = 600; // Sahne 1
  static const _rightLegDuration = 600; // Sahne 2
  static const _leftLegDuration = 600; // Sahne 3
  static const _glowDuration = 400; // Sahne 4
  static const _fadeDuration = 300; // Sahne 5

  // Renkler
  static const _bgColor = Color(0xFF1A1A2E);
  static const _purpleColor = Color(0xFF6C63FF);
  static const _tealColor = Color(0xFF4ECDC4);
  static const _starColor = Color(0xFFFFFFFF);

  // Animation Controllers
  late AnimationController _starMoveController;
  late AnimationController _rightLegController;
  late AnimationController _leftLegController;
  late AnimationController _glowController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _starPosition;
  late Animation<double> _starOpacity;
  late Animation<double> _rightLegProgress;
  late Animation<double> _leftLegProgress;
  late Animation<double> _glowIntensity;
  late Animation<double> _fadeOpacity;

  // App initialization
  UserProfile? _profile;
  bool _onboardingCompleted = false;
  bool _initComplete = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeApp();
    _startAnimationSequence();
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

  void _initAnimations() {
    // Sahne 1: Yıldız hareketi
    _starMoveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _starMoveDuration),
    );
    _starPosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starMoveController, curve: Curves.easeInOut),
    );
    _starOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _starMoveController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Sahne 2: V'nin sağ bacağı
    _rightLegController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _rightLegDuration),
    );
    _rightLegProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rightLegController, curve: Curves.easeOut),
    );

    // Sahne 3: V'nin sol bacağı
    _leftLegController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _leftLegDuration),
    );
    _leftLegProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _leftLegController, curve: Curves.easeOut),
    );

    // Sahne 4: Glow efekti
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _glowDuration),
    );
    _glowIntensity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Sahne 5: Fade geçişi
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _fadeDuration),
    );
    _fadeOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
  }

  Future<void> _startAnimationSequence() async {
    // Status bar ayarla
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));

    // Sahne 1: Yıldız hareketi
    await _starMoveController.forward();

    // Sahne 2: Sağ bacak çizimi
    await _rightLegController.forward();

    // Sahne 3: Sol bacak çizimi
    await _leftLegController.forward();

    // Sahne 4: Glow efekti
    await _glowController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _glowController.reverse();

    // İnitializasyon tamamlanana kadar bekle
    while (!_initComplete) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Sahne 5: Fade geçişi
    await _fadeController.forward();

    // Navigasyon
    if (!mounted) return;

    // Onboarding tamamlanmamışsa önce onboarding göster
    if (!_onboardingCompleted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }

    // Profil varsa ana ekrana, yoksa profil oluşturma ekranına git
    if (_profile != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MainScreen(userProfile: _profile!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const UserProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _starMoveController.dispose();
    _rightLegController.dispose();
    _leftLegController.dispose();
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _starMoveController,
          _rightLegController,
          _leftLegController,
          _glowController,
          _fadeController,
        ]),
        builder: (context, _) {
          return Opacity(
            opacity: _fadeOpacity.value,
            child: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _VLogoWithStarPainter(
                    starProgress: _starPosition.value,
                    starOpacity: _starOpacity.value,
                    rightLegProgress: _rightLegProgress.value,
                    leftLegProgress: _leftLegProgress.value,
                    glowIntensity: _glowIntensity.value,
                    purpleColor: _purpleColor,
                    tealColor: _tealColor,
                    starColor: _starColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// V harfi ve yıldız çizimi için CustomPainter
class _VLogoWithStarPainter extends CustomPainter {
  final double starProgress;
  final double starOpacity;
  final double rightLegProgress;
  final double leftLegProgress;
  final double glowIntensity;
  final Color purpleColor;
  final Color tealColor;
  final Color starColor;

  _VLogoWithStarPainter({
    required this.starProgress,
    required this.starOpacity,
    required this.rightLegProgress,
    required this.leftLegProgress,
    required this.glowIntensity,
    required this.purpleColor,
    required this.tealColor,
    required this.starColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // V harfinin köşe noktaları
    final topLeft = Offset(size.width * 0.2, size.height * 0.2);
    final topRight = Offset(size.width * 0.8, size.height * 0.2);
    final bottom = Offset(size.width * 0.5, size.height * 0.85);

    // Yıldızın başlangıç ve bitiş noktası
    final starStart = Offset(size.width * 0.1, size.height * 0.9);
    final starEnd = topRight;

    // Mevcut yıldız pozisyonu
    final currentStarPos = Offset.lerp(starStart, starEnd, starProgress)!;

    // Yıldız izi çizimi (sadece hareket ederken)
    if (starProgress > 0 && starProgress < 1) {
      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            starColor.withValues(alpha: 0),
            starColor.withValues(alpha: 0.3 * starOpacity),
          ],
        ).createShader(Rect.fromPoints(starStart, currentStarPos))
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(starStart, currentStarPos, trailPaint);
    }

    // V harfi - Sağ bacak (yukarıdan aşağı)
    if (rightLegProgress > 0) {
      final rightLegEnd = Offset.lerp(topRight, bottom, rightLegProgress)!;

      final rightLegPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tealColor, purpleColor],
        ).createShader(Rect.fromPoints(topRight, bottom))
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Glow efekti
      if (glowIntensity > 0) {
        final glowPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tealColor.withValues(alpha: 0.5 * glowIntensity),
              purpleColor.withValues(alpha: 0.5 * glowIntensity),
            ],
          ).createShader(Rect.fromPoints(topRight, bottom))
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * glowIntensity);

        canvas.drawLine(topRight, rightLegEnd, glowPaint);
      }

      canvas.drawLine(topRight, rightLegEnd, rightLegPaint);
    }

    // V harfi - Sol bacak (alttan yukarı)
    if (leftLegProgress > 0) {
      final leftLegEnd = Offset.lerp(bottom, topLeft, leftLegProgress)!;

      final leftLegPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [purpleColor, tealColor],
        ).createShader(Rect.fromPoints(bottom, topLeft))
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Glow efekti
      if (glowIntensity > 0) {
        final glowPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              purpleColor.withValues(alpha: 0.5 * glowIntensity),
              tealColor.withValues(alpha: 0.5 * glowIntensity),
            ],
          ).createShader(Rect.fromPoints(bottom, topLeft))
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * glowIntensity);

        canvas.drawLine(bottom, leftLegEnd, glowPaint);
      }

      canvas.drawLine(bottom, leftLegEnd, leftLegPaint);
    }

    // Yıldız çizimi
    if (starOpacity > 0) {
      _drawStar(
        canvas,
        currentStarPos,
        12 + (glowIntensity * 4),
        starColor.withValues(alpha: starOpacity),
        glowIntensity,
      );
    }
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double glow,
  ) {
    // Yıldız glow efekti
    if (glow > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.5 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * glow);

      canvas.drawCircle(center, radius * 1.5, glowPaint);
    }

    // Ana yıldız (4 köşeli)
    final path = Path();
    const points = 4;
    final innerRadius = radius * 0.4;

    for (var i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? radius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, starPaint);

    // Merkez parlama
    final centerGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(center, radius * 0.2, centerGlow);
  }

  @override
  bool shouldRepaint(covariant _VLogoWithStarPainter oldDelegate) {
    return starProgress != oldDelegate.starProgress ||
        starOpacity != oldDelegate.starOpacity ||
        rightLegProgress != oldDelegate.rightLegProgress ||
        leftLegProgress != oldDelegate.leftLegProgress ||
        glowIntensity != oldDelegate.glowIntensity;
  }
}
