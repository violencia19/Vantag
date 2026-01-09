import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import 'screens.dart';

/// VANTAG Premium Laser Splash Screen
/// path_drawing paketi ile SVG path parsing
/// Lazer çizim efekti + Neon glow + Logo fade-in
class LaserSplashScreen extends StatefulWidget {
  const LaserSplashScreen({super.key});

  @override
  State<LaserSplashScreen> createState() => _LaserSplashScreenState();
}

class _LaserSplashScreenState extends State<LaserSplashScreen>
    with TickerProviderStateMixin {
  // SVG Path verisi - Logo
  static const String _svgPathData = '''
M0 2560 l0 -2560 2560 0 2560 0 0 2560 0 2560 -2560 0 -2560 0 0
-2560z m3440 1196 c0 -5 -7 -1 -15 10 -8 10 -14 24 -14 29 0 6 6 1 14 -9 8
-11 15 -24 15 -30z m220 -18 c0 -13 9 -63 19 -113 19 -90 19 -90 -2 -112 -25
-28 -29 -28 -57 -5 l-22 17 24 118 c21 108 38 149 38 95z m210 -46 c0 -4 -21
-28 -47 -52 -45 -44 -44 -38 6 28 24 31 41 41 41 24z m-300 -48 c0 -8 -4 -12
-10 -9 -5 3 -10 13 -10 21 0 8 5 12 10 9 6 -3 10 -13 10 -21z m-210 -40 c0 -2
-9 0 -20 6 -11 6 -20 13 -20 16 0 2 9 0 20 -6 11 -6 20 -13 20 -16z m183 -60
c-4 -18 -19 -13 -30 12 -12 25 -11 25 10 11 12 -8 21 -18 20 -23z m267 -14 c0
-5 -8 -10 -17 -10 -15 0 -16 2 -3 10 19 12 20 12 20 0z m-222 -63 c20 -21 20
-23 3 -46 l-18 -24 -113 22 c-115 22 -143 31 -99 31 13 1 58 9 99 19 99 25
103 25 128 -2z m268 0 l112 -23 -120 -23 c-114 -21 -121 -22 -139 -5 -23 21
-24 32 -2 56 20 22 14 22 149 -5z m-251 -184 c-27 -123 -99 -329 -170 -490
-152 -346 -387 -694 -640 -949 -220 -222 -380 -305 -580 -303 -44 1 -93 4
-110 8 -17 4 15 7 75 7 108 0 205 17 217 38 3 6 3 8 -2 4 -4 -4 -15 -2 -23 5
-13 10 -14 9 -7 -3 4 -8 5 -12 0 -8 -4 4 -13 4 -19 -2 -8 -6 -12 -3 -14 8 -1
14 -7 41 -11 60 -1 2 -6 0 -11 -3 -8 -5 -7 -11 1 -21 6 -8 9 -17 5 -21 -3 -3
-6 -1 -6 6 0 7 -5 9 -10 6 -6 -4 -10 -3 -9 2 4 22 -2 34 -13 26 -7 -4 -4 6 6
22 10 17 15 26 10 22 -4 -4 -13 3 -20 15 -12 23 -12 23 -11 -4 1 -14 7 -24 12
-20 6 3 6 1 2 -3 -4 -5 -15 -10 -24 -11 -12 -2 -13 0 -4 9 13 13 15 31 2 22
-5 -3 -13 0 -17 6 -4 7 -3 9 3 6 6 -4 13 2 16 13 3 11 2 22 -2 24 -3 2 -44
-11 -91 -29 -111 -44 -149 -44 -44 -1 487 205 1072 832 1450 1554 26 51 49 90
52 88 2 -3 -4 -40 -13 -83z m130 74 c0 -1 8 -19 18 -39 9 -21 15 -38 14 -38
-2 0 -23 21 -47 46 -45 46 -45 47 -15 39 16 -3 30 -7 30 -8z m-250 -27 c-16
-16 -34 -30 -39 -30 -10 1 53 60 63 60 3 0 -8 -13 -24 -30z m-160 -55 c-40
-34 -55 -42 -55 -27 0 7 80 62 90 62 3 0 -13 -16 -35 -35z m399 -70 c3 -8 1
-15 -4 -15 -6 0 -10 7 -10 15 0 8 2 15 4 15 2 0 6 -7 10 -15z m-720 -152
c-130 -221 -175 -293 -185 -293 -6 0 4 26 23 58 18 33 69 122 113 200 51 91
86 142 96 142 12 0 0 -28 -47 -107z m847 25 c5 -10 6 -18 1 -18 -5 0 -14 11
-20 25 -22 49 -11 44 19 -7z m-1664 -400 c144 -246 303 -527 303 -538 0 -27
-350 -265 -365 -248 -1 2 -50 86 -108 188 -58 102 -137 241 -177 310 -40 69
-83 148 -97 175 -53 110 19 -5 158 -250 132 -232 192 -329 175 -281 -5 15 -4
17 7 7 12 -9 14 -7 13 11 -1 15 4 22 13 20 9 -2 11 3 7 14 -5 14 -4 15 9 4 13
-11 14 -10 9 5 -5 12 -4 16 4 11 7 -4 10 1 7 15 -3 15 0 19 10 15 8 -3 17 0
21 6 4 6 3 8 -4 4 -6 -3 -13 -2 -17 4 -3 5 1 10 9 10 12 0 33 37 27 49 -1 2 8
9 21 15 16 8 22 19 20 34 -2 12 2 22 8 22 6 0 9 4 6 8 -2 4 0 14 6 22 8 12 9
12 4 -2 -9 -28 2 -21 19 13 9 17 14 38 10 46 -5 14 -3 14 12 2 10 -7 15 -10
11 -5 -4 5 -3 16 2 26 7 13 -5 43 -49 121 -98 177 -173 319 -168 319 3 0 45
-69 94 -152z m84 -341 c-10 -9 -11 -8 -5 6 3 10 9 15 12 12 3 -3 0 -11 -7 -18z
m-46 -98 c-4 -5 -12 -9 -18 -8 -9 0 -8 2 1 6 6 2 9 10 6 15 -4 7 -2 8 5 4 6
-4 9 -12 6 -17z
''';

  // Neon renkleri
  static const Color _laserColor = Color(0xFF00FFFF); // Cyan neon
  static const Color _glowColor = Color(0xFF00FFFF);

  // Animation Controllers
  late AnimationController _laserDrawController;
  late AnimationController _logoFadeController;
  late AnimationController _textFadeController;
  late AnimationController _starPulseController;

  // Animations
  late Animation<double> _laserProgress;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _starPulse;

  // Path data
  late Path _logoPath;
  double _totalPathLength = 0;

  // App state
  UserProfile? _profile;
  bool _onboardingCompleted = false;
  bool _initComplete = false;
  bool _drawingComplete = false;

  @override
  void initState() {
    super.initState();
    _initPath();
    _initAnimations();
    _initializeApp();
    _startAnimationSequence();
  }

  void _initPath() {
    // path_drawing ile SVG path parse et
    _logoPath = parseSvgPathData(_svgPathData);

    // Toplam path uzunluğunu hesapla
    for (final metric in _logoPath.computeMetrics()) {
      _totalPathLength += metric.length;
    }
  }

  void _initAnimations() {
    // Lazer çizim - 3 saniye, easeInOutQuart
    _laserDrawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _laserProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _laserDrawController,
        curve: Curves.easeInOutQuart,
      ),
    );

    // Logo fade-in - 800ms
    _logoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoFadeController, curve: Curves.easeOut),
    );

    // Text fade-in - 600ms
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeOut),
    );

    // Star pulse - sürekli döngü
    _starPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
    _starPulse = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _starPulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeApp() async {
    final profileService = ProfileService();
    final notificationService = NotificationService();
    final subscriptionService = SubscriptionService();
    final financeProvider = context.read<FinanceProvider>();

    // Bildirimleri başlat
    await notificationService.initialize();
    await notificationService.initializeDefaultSettings();
    await notificationService.requestPermission();

    // Yarın yenilenecek aboneliklerin bildirimlerini planla
    final tomorrow = await subscriptionService.getSubscriptionsRenewingTomorrow();
    if (tomorrow.isNotEmpty) {
      final subscriptionData = tomorrow
          .map((s) => (id: s.id, name: s.name, amount: s.amount))
          .toList();
      await notificationService.scheduleSubscriptionReminders(subscriptionData);
    }

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

  Future<void> _startAnimationSequence() async {
    // Status bar ayarla
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    // SAHNE 1: Lazer çizim (3 saniye)
    await _laserDrawController.forward();

    setState(() => _drawingComplete = true);
    _starPulseController.stop();

    await Future.delayed(const Duration(milliseconds: 200));

    // SAHNE 2: Logo fade-in
    await _logoFadeController.forward();

    // SAHNE 3: Text fade-in
    await _textFadeController.forward();

    // İnitializasyon tamamlanana kadar bekle
    while (!_initComplete) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Son bekleme (~4-5 saniye toplam)
    await Future.delayed(const Duration(milliseconds: 1000));

    // Navigasyon
    if (!mounted) return;
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
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
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _laserDrawController.dispose();
    _logoFadeController.dispose();
    _textFadeController.dispose();
    _starPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Mevcut tema arka planı
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _laserDrawController,
          _logoFadeController,
          _textFadeController,
          _starPulseController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              // Arka plan gradient (mevcut tema)
              Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.background,
                ),
              ),

              // Lazer çizim alanı
              if (!_drawingComplete)
                Center(
                  child: SizedBox(
                    width: size.width * 0.85,
                    height: size.width * 0.85,
                    child: CustomPaint(
                      painter: _LaserPathPainter(
                        path: _logoPath,
                        progress: _laserProgress.value,
                        totalLength: _totalPathLength,
                        laserColor: _laserColor,
                        glowColor: _glowColor,
                        starPulse: _starPulse.value,
                      ),
                    ),
                  ),
                ),

              // Logo ve VANTAG text (çizim bittikten sonra)
              if (_drawingComplete)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: 0.85 + (_logoOpacity.value * 0.15),
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset(
                                'assets/icon/app_icon.png',
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.primaryButton,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // VANTAG text
                      Opacity(
                        opacity: _textOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - _textOpacity.value)),
                          child: Column(
                            children: [
                              // Premium gradient text
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'VANTAG',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Slogan
                              Text(
                                'Finansal Ustunlugun',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 6,
                                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Lazer çizim efekti CustomPainter
/// PathMetrics ile kısmi path çizimi + Neon glow + Parlayan uç
class _LaserPathPainter extends CustomPainter {
  final Path path;
  final double progress;
  final double totalLength;
  final Color laserColor;
  final Color glowColor;
  final double starPulse;

  _LaserPathPainter({
    required this.path,
    required this.progress,
    required this.totalLength,
    required this.laserColor,
    required this.glowColor,
    required this.starPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // SVG path'i ekrana sığdır
    // Orijinal koordinatlar: ~5120x5120
    final pathBounds = path.getBounds();
    final scaleX = size.width / pathBounds.width;
    final scaleY = size.height / pathBounds.height;
    final scale = math.min(scaleX, scaleY) * 0.9;

    canvas.save();

    // Merkeze taşı ve ölçekle
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale, scale);
    canvas.translate(
      -pathBounds.center.dx,
      -pathBounds.center.dy,
    );

    // Hedef uzunluk
    final targetLength = totalLength * progress;
    double drawnLength = 0;
    Offset? laserTipPosition;

    // Path'i segment segment çiz
    for (final metric in path.computeMetrics()) {
      if (drawnLength >= targetLength) break;

      final remainingLength = targetLength - drawnLength;
      final segmentLength = math.min(metric.length, remainingLength);

      // Segment path'ini çıkar
      final segmentPath = metric.extractPath(0, segmentLength);

      // GLOW LAYER 1 - Dış glow (en geniş)
      final outerGlowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.15)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawPath(segmentPath, outerGlowPaint);

      // GLOW LAYER 2 - Orta glow
      final midGlowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.3)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawPath(segmentPath, midGlowPaint);

      // GLOW LAYER 3 - İç glow (parlak)
      final innerGlowPaint = Paint()
        ..color = laserColor.withValues(alpha: 0.6)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(segmentPath, innerGlowPaint);

      // ANA ÇİZGİ - Neon core
      final corePaint = Paint()
        ..color = laserColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(segmentPath, corePaint);

      // Lazer uç pozisyonunu al (tangent)
      final tangent = metric.getTangentForOffset(segmentLength);
      if (tangent != null) {
        laserTipPosition = tangent.position;
      }

      drawnLength += metric.length;
    }

    // LAZER UCU - Parlayan neon yıldız
    if (laserTipPosition != null && progress > 0 && progress < 1) {
      _drawLaserTip(canvas, laserTipPosition);
    }

    canvas.restore();
  }

  void _drawLaserTip(Canvas canvas, Offset position) {
    final baseRadius = 8.0 * starPulse;

    // Dış halo - çok parlak
    for (var i = 4; i >= 1; i--) {
      final haloPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.15 / i)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 25.0 * i);
      canvas.drawCircle(position, baseRadius * (1 + i * 0.8), haloPaint);
    }

    // Orta glow
    final midPaint = Paint()
      ..color = laserColor.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(position, baseRadius * 1.2, midPaint);

    // Parlak beyaz merkez
    final corePaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(position, baseRadius * 0.4, corePaint);

    // Işın efektleri (4 yönlü)
    final rayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + (math.pi / 4);
      final innerR = baseRadius * 0.5;
      final outerR = baseRadius * 2.0;

      final start = Offset(
        position.dx + innerR * math.cos(angle),
        position.dy + innerR * math.sin(angle),
      );
      final end = Offset(
        position.dx + outerR * math.cos(angle),
        position.dy + outerR * math.sin(angle),
      );

      canvas.drawLine(start, end, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LaserPathPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        starPulse != oldDelegate.starPulse;
  }
}
