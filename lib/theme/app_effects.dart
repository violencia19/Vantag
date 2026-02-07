import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'app_colors.dart';
import '../widgets/shimmer_effect.dart';

// ═══════════════════════════════════════════════════════════════════════════
// VANTAG UNIFIED EFFECTS SYSTEM v2.0
// Glass effects, shadows, animations, spacing, border radius, decorations
// ═══════════════════════════════════════════════════════════════════════════

// ── SPACING (4px Grid) ──

class VantSpacing {
  VantSpacing._();

  static const double xs2 = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xl2 = 48; // alias
  static const double xl3 = 64;
  static const double xxxl = 32;
  static const double section = 48;

  // Semantic spacing
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20);
  static const EdgeInsets cardPaddingHero = EdgeInsets.all(24);
}

// ── BORDER RADIUS ──

class VantRadius {
  VantRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;

  // Pre-built BorderRadius objects
  static final BorderRadius button = BorderRadius.circular(14);
  static const BorderRadius sheet = BorderRadius.vertical(top: Radius.circular(32));
  static final BorderRadius borderRadiusXs = BorderRadius.circular(xs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(sm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(md);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(lg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(xl);
  static final BorderRadius borderRadiusXxl = BorderRadius.circular(xxl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(full);
}

// ── BLUR TIERS ──

class VantBlur {
  VantBlur._();

  /// Light: chips, small tags, badges
  static const double light = 12;

  /// Medium: standard cards, nav bar
  static const double medium = 20;

  /// Medium-heavy: elevated cards
  static const double mediumHeavy = 24;

  /// Heavy (max): hero cards, bottom sheets, modals
  static const double heavy = 30;
}

// ── SHADOWS ──

class VantShadows {
  VantShadows._();

  static const BoxShadow subtle = BoxShadow(
    color: Color(0x1F000000), // black 12%
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color(0x33000000), // black 20%
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  static const BoxShadow card = BoxShadow(
    color: Color(0x33000000), // black 20%
    blurRadius: 20,
    offset: Offset(0, 10),
  );

  static const BoxShadow heavy = BoxShadow(
    color: Color(0x4D000000), // black 30%
    blurRadius: 30,
    offset: Offset(0, 10),
  );

  static BoxShadow glowPurple = BoxShadow(
    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
    blurRadius: 24,
    spreadRadius: 2,
  );

  static BoxShadow glowPurpleSoft = BoxShadow(
    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
    blurRadius: 32,
  );

  static BoxShadow glowSuccess = BoxShadow(
    color: const Color(0xFF10B981).withValues(alpha: 0.3),
    blurRadius: 20,
    spreadRadius: -5,
  );

  static BoxShadow glowError = BoxShadow(
    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
    blurRadius: 20,
    spreadRadius: -5,
  );

  /// Premium shadow - dark layered depth
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

  /// Colored glow (parametric)
  static List<BoxShadow> coloredGlow(Color color, {double intensity = 1.0}) => [
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

  /// Parametric glow shadow
  static List<BoxShadow> glow(Color color, {double intensity = 0.2, double blur = 24}) => [
    BoxShadow(
      color: color.withValues(alpha: intensity),
      blurRadius: blur,
      spreadRadius: -4,
    ),
  ];

  /// Parametric icon halo shadow
  static List<Shadow> iconHalo(Color color) => [
    Shadow(
      color: color.withValues(alpha: 0.4),
      blurRadius: 12,
    ),
  ];
}

// ── ANIMATIONS ──

class VantAnimation {
  VantAnimation._();

  // Durations
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration normal = Duration(milliseconds: 300); // alias for standard
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration emphasis = Duration(milliseconds: 400);
  static const Duration counting = Duration(milliseconds: 800);
  static const Duration breathing = Duration(milliseconds: 3000);
  static const Duration celebration = Duration(milliseconds: 2500);

  // Curves
  static const Curve curveStandard = Curves.easeOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSpring = Curves.easeOutBack;
  static const Curve curveSmooth = Curves.easeInOut;
  static const Curve curveSharp = Curves.easeOutQuart;

  // Glow intensity values
  static const double glowMin = 0.4;
  static const double glowMax = 1.0;
  static const double pulseMin = 0.97;
  static const double pulseMax = 1.03;

  // Scale values
  static const double scaleButtonPress = 0.95;
  static const double scaleCardFocus = 1.02;
  static const double scaleAchievement = 1.03;
  static const double scaleHeaderMin = 0.92;

  // Opacity values
  static const double opacityDisabled = 0.5;
  static const double opacityLocked = 0.6;
  static const double opacityHeaderMin = 0.8;
  static const double opacityBackdrop = 0.7;
}

// ── GLASS EFFECT VARIANTS ──

enum VantGlassVariant {
  /// Standard card glass: fill white@8%->4%, border white@8%, sigma 20, radius 20
  standard,

  /// Hero card glass: fill white@10%->6%, border white@12%, sigma 30, radius 24
  hero,

  /// Subtle glass: fill white@4%->2%, border white@6%, sigma 12, radius 16
  subtle,

  /// Sheet glass: solid surface@95%, border white@8%, sigma 30, radius 24 top
  sheet,

  /// Nav bar glass: solid surface@95%, border white@6%, sigma 20, pill radius
  nav,
}

// ── VGLASSCARD WIDGET ──

/// Canonical glass card - single implementation replacing all duplicates.
/// Replaces: GlassCard (quiet_luxury), PremiumGlassCard (premium_theme),
/// LiquidGlassCard (liquid_glass), PsychologyGlassCard (psychology_effects).
class VGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blurSigma;
  final Color? glowColor;
  final double glowIntensity;
  final VantGlassVariant variant;

  const VGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.blurSigma = 20,
    this.glowColor,
    this.glowIntensity = 0.25,
    this.variant = VantGlassVariant.standard,
  });

  /// Convenience constructor for hero variant
  const VGlassCard.hero({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.glowColor,
    this.glowIntensity = 0.20,
  })  : borderRadius = 24,
        blurSigma = 30,
        variant = VantGlassVariant.hero;

  /// Convenience constructor for subtle variant
  const VGlassCard.subtle({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.glowColor,
    this.glowIntensity = 0.0,
  })  : borderRadius = 16,
        blurSigma = 12,
        variant = VantGlassVariant.subtle;

  @override
  Widget build(BuildContext context) {
    final fill = _getFill();
    final border = _getBorder();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Macro depth shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          // Optional colored glow
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: glowIntensity),
              blurRadius: 20,
              spreadRadius: -5,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              gradient: fill,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border,
            ),
            child: Stack(
              children: [
                // Top highlight shine
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: variant == VantGlassVariant.hero ? 0.20 : 0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getFill() {
    switch (variant) {
      case VantGlassVariant.hero:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x30FFFFFF), // 19%
            Color(0x18FFFFFF), // 10%
          ],
        );
      case VantGlassVariant.subtle:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x18FFFFFF), // 10%
            Color(0x0DFFFFFF), // 5%
          ],
        );
      case VantGlassVariant.standard:
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x22FFFFFF), // 13%
            Color(0x12FFFFFF), // 7%
          ],
        );
    }
  }

  Border _getBorder() {
    switch (variant) {
      case VantGlassVariant.hero:
        return Border.all(
          color: const Color(0x35FFFFFF), // 21%
          width: 1.5,
        );
      case VantGlassVariant.subtle:
        return Border.all(
          color: const Color(0x18FFFFFF), // 10%
          width: 0.5,
        );
      case VantGlassVariant.standard:
      default:
        return Border.all(
          color: const Color(0x25FFFFFF), // 15%
          width: 1,
        );
    }
  }
}

// ── VGLASSSHEET — Reusable Bottom Sheet Glass Wrapper ──

/// Canonical glass bottom sheet wrapper with frosted blur, glass border, and handle bar.
/// Use as the direct child of a `showModalBottomSheet` builder.
class VGlassSheet extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final double topRadius;

  const VGlassSheet({
    super.key,
    required this.child,
    this.blurSigma = VantBlur.heavy,
    this.topRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: VantColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
            border: Border.all(
              color: const Color(0x15FFFFFF), // 8% white
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: VantColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

// ── VGLASSSTYLEDCONTAINER — Glass Look Without BackdropFilter ──

/// Glass-styled container that mimics the frosted look with gradients and borders
/// but does NOT use BackdropFilter. Use in scrolling lists and perf-sensitive areas.
class VGlassStyledContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? glowColor;
  final double glowIntensity;

  const VGlassStyledContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.glowColor,
    this.glowIntensity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x18FFFFFF), // 10%
            Color(0x0DFFFFFF), // 5%
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color(0x20FFFFFF), // 12%
          width: 1,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0x33000000), // black 20%
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
          if (glowColor != null && glowIntensity > 0)
            BoxShadow(
              color: glowColor!.withValues(alpha: glowIntensity),
              blurRadius: 16,
              spreadRadius: -4,
            ),
        ],
      ),
      child: Stack(
        children: [
          // Top highlight shine
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

// ── GLASS HIGHLIGHT DECORATION ──

/// Simulates light refraction on glass top edge
class VantGlassHighlight {
  VantGlassHighlight._();

  static BoxDecoration decoration({double height = 60}) {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x25FFFFFF), // 15% white at top
          Colors.transparent,
        ],
      ),
    );
  }
}

// ── PRESSABLE WIDGET ──

/// Universal press animation widget with scale + haptic feedback.
/// Replaces: PremiumPressable (premium_theme), Pressable (quiet_luxury).
// ── BACKWARD-COMPATIBLE AppAnimations SHIM ──
// Preserves OLD timing values from app_animations.dart to avoid behavior changes.
// New code should use VantAnimation directly.

class AppAnimations {
  AppAnimations._();

  // Curves (identical to VantAnimation)
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve decelerateCurve = Curves.decelerate;

  // Durations (OLD values preserved)
  static const Duration micro = Duration(milliseconds: 160);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration counter = Duration(milliseconds: 600);
  static const Duration long = Duration(milliseconds: 500);
  static const Duration extraLong = Duration(milliseconds: 2500);

  // Delays
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration initialDelay = Duration(milliseconds: 150);
  static const Duration decisionDelay = Duration(milliseconds: 80);

  // Scales
  static const double buttonPressScale = 0.95;
  static const double headerMinScale = 0.92;
  static const double achievementPulseScale = 1.03;
  static const double cardFocusScale = 1.02;

  // Opacities
  static const double headerMinOpacity = 0.8;
  static const double lockedOpacity = 0.6;
  static const double disabledOpacity = 0.5;
  static const double backdropOpacity = 0.7;

  // Offsets
  static const Offset cardSlideOffset = Offset(0, 30);
  static const Offset sheetSlideOffset = Offset(0, 50);

  // Blur
  static const double backdropBlur = 20.0;
  static const double lockedBlur = 2.0;

  // Helper methods
  static Duration staggeredDelay(int index) {
    return Duration(milliseconds: staggerDelay.inMilliseconds * index);
  }

  static Duration pageEntryDelay(int index) {
    return Duration(
      milliseconds:
          initialDelay.inMilliseconds + staggerDelay.inMilliseconds * index,
    );
  }
}

/// Animasyon yardımcı extension'ları
extension AnimationExtensions on Duration {
  ({Duration duration, Curve curve}) withCurve([Curve? curve]) {
    return (duration: this, curve: curve ?? AppAnimations.standardCurve);
  }
}

/// Widget animasyon mixin'i
mixin AnimatedStateMixin<T extends StatefulWidget> on State<T> {
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  Future<void> delayed(Duration duration, VoidCallback callback) async {
    await Future.delayed(duration);
    if (mounted) callback();
  }
}

// ── PRESSABLE WIDGET ──

/// Universal press animation widget with scale + haptic feedback.
/// Replaces: PremiumPressable (premium_theme), Pressable (quiet_luxury).
class VPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const VPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
  });

  @override
  State<VPressable> createState() => _VPressableState();
}

class _VPressableState extends State<VPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: VantAnimation.micro,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: VantAnimation.curveSmooth),
    );
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BREATHE GLOW - Pulse Animation
// ═══════════════════════════════════════════════════════════════════════════

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
    this.glowColor = VantColors.primary,
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

// ═══════════════════════════════════════════════════════════════════════════
// GRADIENT BORDER
// ═══════════════════════════════════════════════════════════════════════════

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
                VantColors.primary.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            color: VantColors.cardBackground,
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ROTATING GRADIENT BORDER - For Avatar
// ═══════════════════════════════════════════════════════════════════════════

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
                    VantColors.primary,
                    VantColors.primaryLight,
                    VantColors.primaryDark,
                    VantColors.primary,
                  ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: VantColors.cardBackground,
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEVEL PROGRESS BAR
// ═══════════════════════════════════════════════════════════════════════════

class LevelProgressBar extends StatefulWidget {
  final double progress;
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
    final color = widget.color ?? VantColors.primary;
    final bgColor = widget.backgroundColor ?? VantColors.surfaceElevated;

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
// SMART BADGE
// ═══════════════════════════════════════════════════════════════════════════

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
          colors: [VantColors.primary, VantColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: VantColors.primary.withValues(alpha: 0.4),
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

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED COUNT-UP
// ═══════════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════════════
// SCALE FADE ANIMATION
// ═══════════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════════════
// PULSE GLOW ANIMATION
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// BUDGET COLOR HELPER
// ═══════════════════════════════════════════════════════════════════════════

Color getBudgetColor(double percentage) {
  if (percentage < 50) return VantColors.success;
  if (percentage < 70) return VantColors.warning;
  if (percentage < 90) return const Color(0xFFEA580C);
  return VantColors.error;
}

// ═══════════════════════════════════════════════════════════════════════════
// PULSE GLOW ANIMATION
// ═══════════════════════════════════════════════════════════════════════════

class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxBlurRadius;
  final Duration duration;
  final bool animate;

  const PulseGlow({
    super.key,
    required this.child,
    this.glowColor = VantColors.primary,
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

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM HERO CARD
// Main dashboard card showing work hours
// ═══════════════════════════════════════════════════════════════════════════

class PremiumHeroCard extends StatefulWidget {
  final double hoursWorked;
  final double daysWorked;
  final double budgetPercentage;
  final VoidCallback? onTap;

  const PremiumHeroCard({
    super.key,
    required this.hoursWorked,
    required this.daysWorked,
    required this.budgetPercentage,
    this.onTap,
  });

  @override
  State<PremiumHeroCard> createState() => _PremiumHeroCardState();
}

class _PremiumHeroCardState extends State<PremiumHeroCard>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _countController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _countAnimation;

  double _previousHours = 0;
  double _previousDays = 0;

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      vsync: this,
      duration: VantAnimation.breathing,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(
      begin: VantAnimation.glowMin,
      end: VantAnimation.glowMax,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: VantAnimation.curveSmooth,
    ));

    _countController = AnimationController(
      vsync: this,
      duration: VantAnimation.counting,
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: VantAnimation.curveStandard,
    );
    _countController.forward();
  }

  @override
  void didUpdateWidget(PremiumHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hoursWorked != widget.hoursWorked ||
        oldWidget.daysWorked != widget.daysWorked) {
      _previousHours = oldWidget.hoursWorked;
      _previousDays = oldWidget.daysWorked;
      _countController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _countController.dispose();
    super.dispose();
  }

  double _lerp(double begin, double end, double t) {
    return begin + (end - begin) * t;
  }

  @override
  Widget build(BuildContext context) {
    final budgetColor = getBudgetColor(widget.budgetPercentage);

    return AnimatedBuilder(
      animation: Listenable.merge([_breathingAnimation, _countAnimation]),
      builder: (context, child) {
        final animatedHours = _lerp(_previousHours, widget.hoursWorked, _countAnimation.value);
        final animatedDays = _lerp(_previousDays, widget.daysWorked, _countAnimation.value);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap?.call();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VantRadius.xxl),
              boxShadow: [
                // Permanent violet outer glow
                BoxShadow(
                  color: VantColors.primary.withValues(alpha: 0.35),
                  blurRadius: 40,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: budgetColor.withValues(alpha: _breathingAnimation.value * 0.4),
                  blurRadius: 40,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(VantRadius.xxl),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: VantBlur.heavy,
                  sigmaY: VantBlur.heavy,
                ),
                child: Container(
                  padding: VantSpacing.cardPaddingLarge,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        VantColors.primary.withValues(alpha: 0.25),
                        VantColors.primary.withValues(alpha: 0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(VantRadius.xxl),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0, left: 0, right: 0, height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: VantColors.primarySubtle,
                              borderRadius: BorderRadius.circular(VantRadius.full),
                              border: Border.all(
                                color: VantColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.clock_fill, size: 14, color: VantColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  AppLocalizations.of(context).workEquivalentBadge,
                                  style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0, color: VantColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTimeBlock(
                                value: animatedHours.toStringAsFixed(0),
                                label: AppLocalizations.of(context).hoursUnitUpper,
                                icon: CupertinoIcons.clock_fill,
                                color: VantColors.primary,
                              ),
                              Container(
                                width: 2, height: 70,
                                margin: const EdgeInsets.symmetric(horizontal: 28),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withValues(alpha: 0),
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              _buildTimeBlock(
                                value: animatedDays.toStringAsFixed(0),
                                label: AppLocalizations.of(context).daysUnitUpper,
                                icon: CupertinoIcons.sun_max_fill,
                                color: VantColors.primaryLight,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).budgetUsageLabel,
                                    style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w500,
                                      letterSpacing: 1.0, color: VantColors.textTertiary,
                                    ),
                                  ),
                                  Text(
                                    '%${widget.budgetPercentage.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700, color: budgetColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LevelProgressBar(
                                progress: widget.budgetPercentage / 100,
                                height: 8,
                                color: budgetColor,
                              ),
                            ],
                          ),
                        ],
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
  }

  Widget _buildTimeBlock({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.1)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: VantShadows.glow(color, intensity: 0.3, blur: 16),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 14),
        Text(
          value,
          style: TextStyle(
            fontSize: 44, fontWeight: FontWeight.w700, letterSpacing: -1.5, height: 1.1,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: VantColors.textPrimary,
            shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 20)],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.0,
            color: VantColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
