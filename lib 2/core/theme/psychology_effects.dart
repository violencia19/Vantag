import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'psychology_design_system.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PSYCHOLOGY EFFECTS - Glow, Shimmer, Confetti, Celebrations
/// Apple Liquid Glass + Dopamine Triggers
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// BREATHING GLOW EFFECT
// ═══════════════════════════════════════════════════════════════════════════

/// Animated breathing glow effect widget
/// Creates a pulsing glow around content for emphasis
class BreathingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double blurRadius;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;
  final bool enabled;

  const BreathingGlow({
    super.key,
    required this.child,
    this.glowColor = PsychologyColors.primary,
    this.blurRadius = 24,
    this.minOpacity = 0.15,
    this.maxOpacity = 0.45,
    this.duration = const Duration(milliseconds: 3000),
    this.enabled = true,
  });

  @override
  State<BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<BreathingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PsychologyAnimations.smooth,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BreathingGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _animation.value),
                blurRadius: widget.blurRadius,
                spreadRadius: -4,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PULSE GLOW EFFECT (for warnings)
// ═══════════════════════════════════════════════════════════════════════════

/// Fast pulsing glow for urgent states (budget warning, etc.)
class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double blurRadius;
  final Duration duration;
  final bool enabled;

  const PulseGlow({
    super.key,
    required this.child,
    this.glowColor = PsychologyColors.warning,
    this.blurRadius = 20,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _animation.value),
                blurRadius: widget.blurRadius,
                spreadRadius: -2,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHIMMER EFFECT
// ═══════════════════════════════════════════════════════════════════════════

/// Shimmer loading effect
class PsychologyShimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const PsychologyShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor = PsychologyColors.surface,
    this.highlightColor = PsychologyColors.surfaceElevated,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PsychologyShimmer> createState() => _PsychologyShimmerState();
}

class _PsychologyShimmerState extends State<PsychologyShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PsychologyShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHIMMER TEXT EFFECT
// ═══════════════════════════════════════════════════════════════════════════

/// Shimmer effect specifically for text highlights
class ShimmerText extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool enabled;

  const ShimmerText({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2500),
    this.enabled = true,
  });

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.white,
                Color(0xFFE8E8FF),
                Colors.white,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: widget.child,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GLASS CARD WRAPPER
// ═══════════════════════════════════════════════════════════════════════════

/// Premium glass card with optional breathing glow
class PsychologyGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? glowColor;
  final double glowIntensity;
  final bool enableBreathing;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final LinearGradient? customGradient;

  const PsychologyGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.glowColor,
    this.glowIntensity = 0.2,
    this.enableBreathing = false,
    this.onTap,
    this.borderRadius,
    this.blurSigma = 24,
    this.customGradient,
  });

  @override
  State<PsychologyGlassCard> createState() => _PsychologyGlassCardState();
}

class _PsychologyGlassCardState extends State<PsychologyGlassCard>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pressController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Breathing glow
    _breathingController = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.breathingCycle,
    );
    _breathingAnimation = Tween<double>(
      begin: PsychologyAnimations.glowMin,
      end: PsychologyAnimations.glowMax,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: PsychologyAnimations.smooth,
    ));

    if (widget.enableBreathing && widget.glowColor != null) {
      _breathingController.repeat(reverse: true);
    }

    // Press scale
    _pressController = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.quick,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: PsychologyAnimations.cardPressScale,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: PsychologyAnimations.standardCurve,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? PsychologyRadius.card;
    final effectiveGlowColor = widget.glowColor ?? PsychologyColors.primary;

    Widget content = AnimatedBuilder(
      animation: Listenable.merge([_breathingAnimation, _scaleAnimation]),
      builder: (context, child) {
        final glowOpacity = widget.enableBreathing
            ? _breathingAnimation.value
            : widget.glowIntensity;

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: widget.glowColor != null
                  ? [
                      BoxShadow(
                        color: effectiveGlowColor.withValues(alpha: glowOpacity),
                        blurRadius: 32,
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : PsychologyShadows.card,
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blurSigma,
                  sigmaY: widget.blurSigma,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: widget.customGradient ??
                        (widget.glowColor != null
                            ? PsychologyGlass.gradient(effectiveGlowColor)
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.white.withValues(alpha: 0.04),
                                ],
                              )),
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: _isPressed ? 0.15 : PsychologyGlass.borderOpacity,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Top highlight
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: borderRadius.topLeft,
                            ),
                            gradient: PsychologyGlass.topHighlight,
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: widget.padding ?? PsychologySpacing.cardPadding,
                        child: widget.child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: content,
      );
    }

    return content;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUCCESS CELEBRATION OVERLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Full-screen success celebration with confetti
class SuccessCelebration extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onComplete;
  final Duration displayDuration;

  const SuccessCelebration({
    super.key,
    required this.title,
    this.subtitle,
    this.onComplete,
    this.displayDuration = const Duration(seconds: 3),
  });

  @override
  State<SuccessCelebration> createState() => _SuccessCelebrationState();
}

class _SuccessCelebrationState extends State<SuccessCelebration>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final List<_ConfettiParticle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.slow,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: PsychologyAnimations.bounce),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Generate confetti particles
    _generateParticles();

    // Start animations
    HapticFeedback.heavyImpact();
    _scaleController.forward();
    _confettiController.forward();

    // Auto dismiss
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  void _generateParticles() {
    final colors = [
      PsychologyColors.primary,
      PsychologyColors.secondary,
      PsychologyColors.success,
      PsychologyColors.gold,
      PsychologyColors.streakFlame,
    ];

    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.3,
        velocityX: (_random.nextDouble() - 0.5) * 0.02,
        velocityY: 0.01 + _random.nextDouble() * 0.02,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationVelocity: (_random.nextDouble() - 0.5) * 0.1,
        size: 8 + _random.nextDouble() * 8,
        color: colors[_random.nextInt(colors.length)],
      ));
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _confettiController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop
            Container(
              color: Colors.black.withValues(alpha: _opacityAnimation.value * 0.8),
            ),

            // Confetti
            CustomPaint(
              size: Size.infinite,
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _confettiController.value,
              ),
            ),

            // Content
            Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: PsychologyColors.successGradient,
                          boxShadow: PsychologyShadows.glow(
                            PsychologyColors.success,
                            intensity: 0.5,
                            blur: 40,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        widget.title,
                        style: PsychologyTypography.headlineMedium.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle!,
                          style: PsychologyTypography.bodyMedium.copyWith(
                            color: PsychologyColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double velocityX;
  double velocityY;
  double rotation;
  double rotationVelocity;
  double size;
  Color color;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationVelocity,
    required this.size,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = (particle.x + particle.velocityX * progress * 100) * size.width;
      final y = (particle.y + particle.velocityY * progress * 100 + progress * 0.5) * size.height;
      final rotation = particle.rotation + particle.rotationVelocity * progress * 100;

      if (y > size.height + 50) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
// LEVEL PROGRESS BAR
// ═══════════════════════════════════════════════════════════════════════════

/// Horizontal progress bar with shimmer effect
class LevelProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final bool showShimmer;
  final BorderRadius? borderRadius;

  const LevelProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.color,
    this.backgroundColor,
    this.showShimmer = true,
    this.borderRadius,
  });

  @override
  State<LevelProgressBar> createState() => _LevelProgressBarState();
}

class _LevelProgressBarState extends State<LevelProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.showShimmer) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(widget.height / 2);
    final color = widget.color ?? PsychologyColors.primary;
    final bgColor = widget.backgroundColor ?? PsychologyColors.surfaceElevated;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Progress fill
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.progress.clamp(0.0, 1.0),
              child: AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withValues(alpha: 0.8),
                          color,
                        ],
                        stops: widget.showShimmer
                            ? [
                                (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                                _shimmerController.value.clamp(0.0, 1.0),
                                (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                              ]
                            : const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: radius,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GRADIENT BORDER
// ═══════════════════════════════════════════════════════════════════════════

/// Widget with animated gradient border
class GradientBorder extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final LinearGradient gradient;

  const GradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 1.5,
    this.borderRadius = 20,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          color: PsychologyColors.surface,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ACCESSIBLE TEXT HELPER
// ═══════════════════════════════════════════════════════════════════════════

/// Accessible text with scaling support
class AccessibleText {
  AccessibleText._();

  /// Create text style with accessibility scaling
  static TextStyle scaled(
    BuildContext context, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
    double maxScale = 1.5,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;
    final scale = textScaler.scale(1.0).clamp(1.0, maxScale);

    return TextStyle(
      fontSize: fontSize * scale,
      fontWeight: fontWeight,
      color: color ?? PsychologyColors.textPrimary,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}
