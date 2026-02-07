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
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: 0.12),
        width: 1,
      ),
    );
  }

  /// Glass Card with gradient border
  static BoxDecoration glassCardGradient({double borderRadius = 16}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.05),
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

  /// Purple glow - intense (Design System: opacity 0.4, blur 24px)
  static List<BoxShadow> glowPurple = [
    BoxShadow(
      color: PremiumColors.purple.withValues(alpha: 0.4),
      blurRadius: 24,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: PremiumColors.purple.withValues(alpha: 0.2),
      blurRadius: 48,
      spreadRadius: 0,
    ),
  ];

  /// Purple glow - soft
  static List<BoxShadow> glowPurpleSoft = [
    BoxShadow(
      color: PremiumColors.purple.withValues(alpha: 0.3),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  /// Premium shadow - subtle
  static List<BoxShadow> shadowPremium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];

  /// Premium shadow - floating effect (Design System: enhanced)
  static List<BoxShadow> shadowPremiumFloat = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
    BoxShadow(
      color: PremiumColors.purple.withValues(alpha: 0.3),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Icon halo - drop shadow for icons (Design System: enhanced)
  static List<Shadow> iconHalo(Color color) {
    return [
      Shadow(color: color.withValues(alpha: 0.6), blurRadius: 16),
      Shadow(color: color.withValues(alpha: 0.4), blurRadius: 32),
    ];
  }

  /// Colored glow (Design System: intensity boosted)
  static List<BoxShadow> coloredGlow(Color color, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.5 * intensity),
        blurRadius: 24,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.3 * intensity),
        blurRadius: 48,
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
        gradient:
            gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                PremiumColors.purple.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.1),
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

/// Glass Card Widget - Design System Compliant
/// Theme-aware: adapts to light/dark mode
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final double blur;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final bool showBorder;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.blur = 25,
    this.backgroundColor,
    this.backgroundGradient,
    this.showBorder = true,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark
        ? const Color(0xFF2D1B4E).withValues(alpha: 0.6)
        : const Color(0xFFFFFFFF).withValues(alpha: 0.9);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundGradient == null
                ? (backgroundColor ?? defaultBgColor)
                : null,
            gradient: backgroundGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(color: borderColor, width: 1.5)
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
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
                widget.shimmerColor.withValues(alpha: 0.3),
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

/// Breathe Glow - Design System: Enhanced pulse animation
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
    this.minOpacity = 0.3,
    this.maxOpacity = 0.6,
    this.duration = const Duration(milliseconds: 2500),
    this.blurRadius = 40,
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
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
                color: widget.glowColor.withValues(alpha: _animation.value),
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
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0,
      end: -widget.floatHeight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + widget.scaleRange,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
              colors:
                  widget.colors ??
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
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: widget.showGlow
                    ? PremiumShadows.glowPurple
                    : PremiumShadows.shadowPremium,
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
        color: Colors.white.withValues(alpha: 0.1),
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

  const SmartBadge({super.key, this.text = 'Smart', this.showShimmer = true});

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [PremiumColors.purple, PremiumColors.gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.purple.withValues(alpha: 0.4),
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
                    (centerColor ?? PremiumColors.purple).withValues(
                      alpha: 0.15,
                    ),
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

// ===========================================
// ANIMATED COUNT-UP
// ===========================================

/// Count-up animation for numbers
/// Duration: 800ms, Curve: easeOutCubic
class AnimatedCountUp extends StatelessWidget {
  final double value;
  final double? previousValue;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final String Function(double value)? formatter;

  const AnimatedCountUp({
    super.key,
    required this.value,
    this.previousValue,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: previousValue ?? 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        final displayValue = formatter != null
            ? formatter!(animatedValue)
            : animatedValue.toStringAsFixed(0);
        return Text(displayValue, style: style);
      },
    );
  }
}

// ===========================================
// ANIMATED PROGRESS BAR
// ===========================================

/// Animated progress bar with delay support
/// Duration: 600ms, Delay: customizable
class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final Gradient? progressGradient;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.progressGradient,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    // Start after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _started = true;
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress && _started) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        widget.borderRadius ?? BorderRadius.circular(widget.height / 2);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedProgress = widget.progress * _animation.value;

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color:
                widget.backgroundColor ?? Colors.white.withValues(alpha: 0.1),
            borderRadius: radius,
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: animatedProgress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.progressGradient == null
                        ? (widget.progressColor ?? PremiumColors.purple)
                        : null,
                    gradient: widget.progressGradient,
                    borderRadius: radius,
                    boxShadow: widget.boxShadow,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===========================================
// STAGGERED SLIDE-UP ANIMATION
// ===========================================

/// Slide-up + fade-in animation for cards
/// Duration: 400ms, Stagger: 100ms per item
class StaggeredSlideUp extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration staggerDelay;
  final double slideOffset;
  final Curve curve;
  final bool animate;

  const StaggeredSlideUp({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.slideOffset = 30,
    this.curve = Curves.easeOutCubic,
    this.animate = true,
  });

  @override
  State<StaggeredSlideUp> createState() => _StaggeredSlideUpState();
}

class _StaggeredSlideUpState extends State<StaggeredSlideUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _slideAnimation = Tween<double>(
      begin: widget.slideOffset,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.animate) {
      final delay = widget.staggerDelay * widget.index;
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1.0;
    }
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
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(opacity: _fadeAnimation.value, child: widget.child),
        );
      },
    );
  }
}

// ===========================================
// SCALE FADE ANIMATION
// ===========================================

/// Scale + fade animation for badges/achievements
class ScaleFadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration staggerDelay;
  final double startScale;
  final Curve curve;
  final bool animate;

  const ScaleFadeIn({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 80),
    this.startScale = 0.8,
    this.curve = Curves.easeOutBack,
    this.animate = true,
  });

  @override
  State<ScaleFadeIn> createState() => _ScaleFadeInState();
}

class _ScaleFadeInState extends State<ScaleFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: widget.startScale,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.animate) {
      final delay = widget.staggerDelay * widget.index;
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1.0;
    }
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _fadeAnimation.value, child: widget.child),
        );
      },
    );
  }
}

// ===========================================
// PULSE GLOW ANIMATION
// ===========================================

/// Pulse glow effect for unlocked items
class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxBlurRadius;
  final Duration duration;
  final bool animate;

  const PulseGlow({
    super.key,
    required this.child,
    this.glowColor = PremiumColors.purple,
    this.maxBlurRadius = 20,
    this.duration = const Duration(milliseconds: 1500),
    this.animate = true,
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
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(
                  alpha: 0.3 * _animation.value,
                ),
                blurRadius: widget.maxBlurRadius * _animation.value,
                spreadRadius: 2 * _animation.value,
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
// PAGE TRANSITION WRAPPER
// ===========================================

// ===========================================
// FROSTED GLASS CONTAINER
// ===========================================

/// Frosted glass effect with customizable blur and tint
class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color tint;
  final double tintOpacity;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const FrostedGlass({
    super.key,
    required this.child,
    this.blur = 10,
    this.tint = Colors.white,
    this.tintOpacity = 0.1,
    this.borderRadius = 16,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: tintOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ===========================================
// GLASS MODAL BOTTOM SHEET
// ===========================================

/// Glass-styled modal bottom sheet wrapper
class GlassModalSheet extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color backgroundColor;
  final double topRadius;
  final EdgeInsets? padding;

  const GlassModalSheet({
    super.key,
    required this.child,
    this.blur = 20,
    this.backgroundColor = const Color(0xFF1A1625),
    this.topRadius = 24,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: 0.95),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(topRadius),
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ===========================================
// GLASS BUTTON
// ===========================================

/// Glass-styled button with blur effect
class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double blur;
  final double borderRadius;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  const GlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.blur = 10,
    this.borderRadius = 12,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: Container(
                  padding:
                      widget.padding ??
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        widget.backgroundColor ??
                        Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color:
                          widget.borderColor ??
                          Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: widget.boxShadow,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===========================================
// GLASS CHIP
// ===========================================

/// Glass-styled chip/tag
class GlassChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool selected;
  final double blur;

  const GlassChip({
    super.key,
    required this.label,
    this.icon,
    this.iconColor,
    this.onTap,
    this.selected = false,
    this.blur = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? PremiumColors.purple.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? PremiumColors.purple.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: iconColor ?? Colors.white70),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================
// NEON GLOW TEXT
// ===========================================

/// Text with neon glow effect
class NeonText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double blurRadius;

  const NeonText({
    super.key,
    required this.text,
    this.style,
    this.glowColor = PremiumColors.purple,
    this.blurRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glow layer
        Text(
          text,
          style: (style ?? const TextStyle()).copyWith(
            foreground: Paint()
              ..color = glowColor
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius),
          ),
        ),
        // Main text
        Text(text, style: style),
      ],
    );
  }
}

// ===========================================
// GLASS DIVIDER
// ===========================================

/// Frosted glass styled divider
class GlassDivider extends StatelessWidget {
  final double height;
  final double indent;
  final double endIndent;
  final Color? color;

  const GlassDivider({
    super.key,
    this.height = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent, right: endIndent),
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            (color ?? Colors.white).withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ===========================================
// PAGE TRANSITION WRAPPER
// ===========================================

/// Wrapper to trigger animations on page change
class AnimatedPageContent extends StatefulWidget {
  final Widget child;
  final bool shouldAnimate;
  final VoidCallback? onAnimationComplete;

  const AnimatedPageContent({
    super.key,
    required this.child,
    this.shouldAnimate = true,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedPageContent> createState() => AnimatedPageContentState();
}

class AnimatedPageContentState extends State<AnimatedPageContent> {
  Key _contentKey = UniqueKey();

  /// Call this to replay animations (e.g., on pull-to-refresh)
  void replayAnimations() {
    setState(() {
      _contentKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _contentKey, child: widget.child);
  }
}
