import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../theme/theme.dart';

/// Wealth Coach: Victory Manager
/// İrade Zaferi kutlama animasyonlarını yöneten singleton
/// Confetti + Overlay mesajı + Haptic feedback
class VictoryManager {
  static final VictoryManager _instance = VictoryManager._internal();
  factory VictoryManager() => _instance;
  VictoryManager._internal();

  OverlayEntry? _currentOverlay;
  ConfettiController? _confettiController;

  /// İrade Zaferi animasyonunu göster
  void showVictoryAnimation(
    BuildContext context, {
    required double amount,
    required double hours,
  }) {
    // Önceki overlay varsa kaldır
    _currentOverlay?.remove();
    _currentOverlay = null;
    _confettiController?.dispose();

    // Confetti controller oluştur
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Heavy haptic feedback
    HapticFeedback.heavyImpact();

    // Overlay oluştur
    final overlay = Overlay.of(context);
    final controller = _confettiController!;

    _currentOverlay = OverlayEntry(
      builder: (context) => _VictoryCelebration(
        amount: amount,
        hours: hours,
        confettiController: controller,
        onComplete: () {
          // Önce confetti'yi durdur, sonra overlay'i kaldır
          controller.stop();
          _currentOverlay?.remove();
          _currentOverlay = null;
          // Dispose'u biraz beklet - widget tree güncellensin
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_confettiController == controller) {
              _confettiController?.dispose();
              _confettiController = null;
            }
          });
        },
      ),
    );

    overlay.insert(_currentOverlay!);

    // Confetti'yi başlat
    controller.play();
  }

  /// Overlay'i manuel kaldır
  void dismiss() {
    _confettiController?.stop();
    _currentOverlay?.remove();
    _currentOverlay = null;
    Future.delayed(const Duration(milliseconds: 100), () {
      _confettiController?.dispose();
      _confettiController = null;
    });
  }
}

/// Victory Celebration with Confetti
class _VictoryCelebration extends StatefulWidget {
  final double amount;
  final double hours;
  final ConfettiController confettiController;
  final VoidCallback onComplete;

  const _VictoryCelebration({
    required this.amount,
    required this.hours,
    required this.confettiController,
    required this.onComplete,
  });

  @override
  State<_VictoryCelebration> createState() => _VictoryCelebrationState();
}

class _VictoryCelebrationState extends State<_VictoryCelebration>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation (bounce effect: 0 → 1.1 → 1)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_scaleController);

    // Fade animation for dismiss
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Scale in with bounce
    await _scaleController.forward();

    // Wait 2 seconds
    await Future.delayed(const Duration(milliseconds: 1800));

    // Fade out
    await _fadeController.forward();

    // Complete
    widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _formatHours(double hours) {
    if (hours >= 24) {
      final days = (hours / 24).floor();
      final remainingHours = (hours % 24).round();
      if (remainingHours > 0) {
        return '$days Gün $remainingHours Saat';
      }
      return '$days Gün';
    } else if (hours >= 1) {
      final h = hours.floor();
      final minutes = ((hours - h) * 60).round();
      if (minutes > 0) {
        return '$h Saat $minutes Dk';
      }
      return '$h Saat';
    } else {
      return '${(hours * 60).round()} Dakika';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Tıklama ile kapatma
            GestureDetector(
              onTap: () async {
                await _fadeController.forward();
                widget.onComplete();
              },
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),

            // Confetti - Ekranın üstünden
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: widget.confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 25,
                maxBlastForce: 30,
                minBlastForce: 10,
                gravity: 0.2,
                particleDrag: 0.05,
                colors: const [
                  VantColors.medalGold, // Altın
                  VantColors.primary, // Mor
                  VantColors.primaryLight, // Açık mor
                  VantColors.error, // Kırmızı
                  Colors.white,
                ],
              ),
            ),

            // Kutlama mesajı - Ortada
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        VantColors.primary, // Primary mor
                        VantColors.primaryLight, // Açık mor
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: context.vantColors.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.rosette,
                          size: 48,
                          color: VantColors.medalGold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Özgürlük süresi
                      Text(
                        '+${_formatHours(widget.hours)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Özgürlük!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Alt mesaj
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Para cebinde kaldı!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              CupertinoIcons.hand_raised_fill,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Global erişim için kısayol
final victoryManager = VictoryManager();
