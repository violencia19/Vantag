import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium UI Effects - Figma Design System
/// Glassmorphism, glow effects, animations

// ===========================================
// PREMIUM COLORS
// ===========================================

class PremiumColors {
  PremiumColors._();

  /// Ana arka plan - koyu mor (siyah değil!)
  static const Color background = Color(0xFF0D0B14);

  /// Kart arka planı
  static const Color cardBackground = Color(0xFF1A1625);

  /// Yükseltilmiş yüzey
  static const Color surfaceElevated = Color(0xFF2D2440);

  /// Mor tonları
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFA78BFA);
  static const Color purpleDark = Color(0xFF6D28D9);

  /// Gradient renkleri
  static const Color gradientStart = Color(0xFF8B5CF6);
  static const Color gradientEnd = Color(0xFF06B6D4);
}

// ===========================================
// PREMIUM DECORATIONS
// ===========================================

class PremiumDecorations {
  PremiumDecorations._();

  /// Glass Card - Blur + gradient border
  static BoxDecoration glassCard({
    double borderRadius = 16,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.12),
        width: 1,
      ),
    );
  }

  /// Glass Card with gradient border
  static BoxDecoration glassCardGradient({
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
        ],
      ),
    );
  }
}

// ===========================================
// PREMIUM SHADOWS
// ===========================================

class PremiumShadows {
  PremiumShadows._();

  /// Purple glow - intense
  static List<BoxShadow> glowPurple = [
    BoxShadow(
      color: PremiumColors.purple.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: PremiumColors.purple.withOpacity(0.15),
      blurRadius: 40,
      spreadRadius: 0,
    ),
  ];

  /// Purple glow - soft
  static List<BoxShadow> glowPurpleSoft = [
    BoxShadow(
      color: PremiumColors.purple.withOpacity(0.2),
      blurRadius: 30,
      spreadRadius: 0,
    ),
  ];

  /// Premium shadow - subtle
  static List<BoxShadow> shadowPremium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  /// Premium shadow - floating effect
  static List<BoxShadow> shadowPremiumFloat = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: PremiumColors.purple.withOpacity(0.15),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  /// Icon halo - drop shadow for icons
  static List<Shadow> iconHalo(Color color) {
    return [
      Shadow(
        color: color.withOpacity(0.5),
        blurRadius: 12,
      ),
      Shadow(
        color: color.withOpacity(0.3),
        blurRadius: 24,
      ),
    ];
  }

  /// Colored glow
  static List<BoxShadow> coloredGlow(Color color, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.4 * intensity),
        blurRadius: 20,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: color.withOpacity(0.2 * intensity),
        blurRadius: 40,
        spreadRadius: 0,
      ),
    ];
  }
}

// ===========================================
// GRADIENT BORDER
// ===========================================

class GradientBorder extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final Gradient? gradient;

  const GradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 1.5,
    this.borderRadius = 16,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                PremiumColors.purple.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            color: PremiumColors.cardBackground,
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ===========================================
// GLASS CARD WIDGET
// ===========================================

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final double blur;
  final Color? backgroundColor;
  final bool showBorder;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.blur = 20,
    this.backgroundColor,
    this.showBorder = true,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  )
                : null,
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ===========================================
// SHIMMER EFFECT
// ===========================================

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color shimmerColor;
  final double shimmerWidth;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.shimmerColor = Colors.white,
    this.shimmerWidth = 0.3,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                widget.shimmerColor.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: [
                (_controller.value - widget.shimmerWidth).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + widget.shimmerWidth).clamp(0.0, 1.0),
              ],
              transform: GradientRotation(math.pi / 4),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

// ===========================================
// BREATHE GLOW - Pulse Animation
// ===========================================

class BreatheGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;
  final double blurRadius;

  const BreatheGlow({
    super.key,
    required this.child,
    this.glowColor = PremiumColors.purple,
    this.minOpacity = 0.4,
    this.maxOpacity = 0.7,
    this.duration = const Duration(seconds: 3),
    this.blurRadius = 30,
  });

  @override
  State<BreatheGlow> createState() => _BreatheGlowState();
}

class _BreatheGlowState extends State<BreatheGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_animation.value),
                blurRadius: widget.blurRadius,
                spreadRadius: 0,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// ===========================================
// SPARKLE FLOAT - Float + Scale Animation
// ===========================================

class SparkleFloat extends StatefulWidget {
  final Widget child;
  final double floatHeight;
  final double scaleRange;
  final Duration duration;

  const SparkleFloat({
    super.key,
    required this.child,
    this.floatHeight = 8,
    this.scaleRange = 0.05,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<SparkleFloat> createState() => _SparkleFloatState();
}

class _SparkleFloatState extends State<SparkleFloat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0,
      end: -widget.floatHeight,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + widget.scaleRange,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ===========================================
// ROTATING GRADIENT BORDER - For Avatar
// ===========================================

class RotatingGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double size;
  final Duration duration;
  final List<Color>? colors;

  const RotatingGradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 3,
    this.size = 48,
    this.duration = const Duration(seconds: 3),
    this.colors,
  });

  @override
  State<RotatingGradientBorder> createState() => _RotatingGradientBorderState();
}

class _RotatingGradientBorderState extends State<RotatingGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              transform: GradientRotation(_controller.value * 2 * math.pi),
              colors: widget.colors ??
                  [
                    PremiumColors.purple,
                    PremiumColors.gradientEnd,
                    PremiumColors.purpleLight,
                    PremiumColors.purple,
                  ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumColors.cardBackground,
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// ===========================================
// PREMIUM BUTTON
// ===========================================

class PremiumButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool showShimmer;
  final bool showGlow;
  final double borderRadius;
  final EdgeInsets? padding;

  const PremiumButton({
    super.key,
    required this.child,
    this.onTap,
    this.showShimmer = true,
    this.showGlow = false,
    this.borderRadius = 12,
    this.padding,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: widget.showGlow ? PremiumShadows.glowPurple : PremiumShadows.shadowPremium,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );

    if (widget.showShimmer) {
      button = ShimmerEffect(child: button);
    }

    return button;
  }
}

// ===========================================
// LEVEL PROGRESS BAR
// ===========================================

class LevelProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double height;
  final bool showShimmer;

  const LevelProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.showShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    Widget bar = Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          // Progress fill
          FractionallySizedBox(
            widthFactor: clampedProgress,
            child: BreatheGlow(
              glowColor: PremiumColors.purple,
              blurRadius: 15,
              minOpacity: 0.3,
              maxOpacity: 0.6,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  gradient: const LinearGradient(
                    colors: [
                      PremiumColors.purpleDark,
                      PremiumColors.purple,
                      PremiumColors.purpleLight,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (showShimmer) {
      bar = ShimmerEffect(child: bar);
    }

    return bar;
  }
}

// ===========================================
// SMART BADGE
// ===========================================

class SmartBadge extends StatelessWidget {
  final String text;
  final bool showShimmer;

  const SmartBadge({
    super.key,
    this.text = 'Smart',
    this.showShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [
            PremiumColors.purple,
            PremiumColors.gradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.purple.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (showShimmer) {
      return ShimmerEffect(
        duration: const Duration(milliseconds: 2500),
        child: badge,
      );
    }

    return badge;
  }
}

// ===========================================
// RADIAL GRADIENT OVERLAY
// ===========================================

class RadialGradientOverlay extends StatelessWidget {
  final Widget child;
  final Color? centerColor;
  final double radius;

  const RadialGradientOverlay({
    super.key,
    required this.child,
    this.centerColor,
    this.radius = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: radius,
                  colors: [
                    (centerColor ?? PremiumColors.purple).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
