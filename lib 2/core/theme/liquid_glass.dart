// iOS 26 Liquid Glass Design System for Vantag
// Advanced optical physics with real glass simulation

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════

class LiquidGlassColors {
  LiquidGlassColors._();

  // Primary
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF7C3AED);

  // Secondary
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color secondaryDark = Color(0xFF0891B2);

  // Backgrounds
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12101A);
  static const Color surfaceElevated = Color(0xFF1A1725);
  static const Color surfaceOverlay = Color(0xFF231F2E);

  // Glass
  static const Color glassBackground = Color(0x0AFFFFFF);
  static const Color glassBorder = Color(0x15FFFFFF);
  static const Color glassHighlight = Color(0x25FFFFFF);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);

  // Decision
  static const Color decisionYes = Color(0xFFF87171);
  static const Color decisionThinking = Color(0xFFFBBF24);
  static const Color decisionNo = Color(0xFF06B6D4);
}

// ═══════════════════════════════════════════════════════════════
// GRADIENTS
// ═══════════════════════════════════════════════════════════════

class LiquidGlassGradients {
  LiquidGlassGradients._();

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      LiquidGlassColors.primary,
      LiquidGlassColors.secondary,
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1FFFFFFF), // 12% white
      Color(0x0DFFFFFF), // 5% white
    ],
  );

  static const LinearGradient highlightGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Colors.transparent,
      Color(0x14FFFFFF), // 8% white
      Colors.transparent,
    ],
  );

  static const LinearGradient luminanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF), // 20% white
      Colors.transparent,
    ],
    stops: [0.0, 0.6],
  );

  static Gradient dynamicLuminanceGradient(Offset lightPosition) {
    return RadialGradient(
      center: Alignment(
        (lightPosition.dx * 2) - 1,
        (lightPosition.dy * 2) - 1,
      ),
      radius: 1.2,
      colors: const [
        Color(0x33FFFFFF),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7],
    );
  }

  static const LinearGradient dividerGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x26FFFFFF), // 15% white
      Colors.transparent,
    ],
  );

  static SweepGradient activeBorderGradient({double rotation = 0}) {
    return SweepGradient(
      startAngle: rotation,
      endAngle: rotation + math.pi * 2,
      colors: const [
        Color(0x26FFFFFF), // 15% white - top left
        Color(0x08FFFFFF), // 3% white
        Color(0x05FFFFFF), // 2% white - bottom right
        Color(0x08FFFFFF), // 3% white
        Color(0x26FFFFFF), // 15% white - back to start
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHADOWS
// ═══════════════════════════════════════════════════════════════

class LiquidGlassShadows {
  LiquidGlassShadows._();

  // Macro shadow - depth and glow
  static List<BoxShadow> macroShadow({Color? glowColor, double intensity = 0.15}) {
    final color = glowColor ?? LiquidGlassColors.primary;
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: 30,
        offset: const Offset(0, 10),
        spreadRadius: 0,
      ),
    ];
  }

  // Micro shadow - grounding
  static const List<BoxShadow> microShadow = [
    BoxShadow(
      color: Color(0x66000000), // 40% black
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  // Glow shadow - inner light emission
  static List<BoxShadow> glowShadow({Color? color, double intensity = 0.3}) {
    return [
      BoxShadow(
        color: (color ?? LiquidGlassColors.primary).withValues(alpha: intensity),
        blurRadius: 20,
        spreadRadius: -5,
      ),
    ];
  }

  // Combined dual shadow system
  static List<BoxShadow> dualShadow({Color? glowColor, double glowIntensity = 0.15}) {
    return [
      ...macroShadow(glowColor: glowColor, intensity: glowIntensity),
      ...microShadow,
    ];
  }

  // Text glow for high balances
  static List<Shadow> textGlow({Color? color, double blur = 8}) {
    return [
      Shadow(
        color: (color ?? LiquidGlassColors.primary).withValues(alpha: 0.3),
        blurRadius: blur,
      ),
    ];
  }
}

// ═══════════════════════════════════════════════════════════════
// TYPOGRAPHY
// ═══════════════════════════════════════════════════════════════

class LiquidGlassTypography {
  LiquidGlassTypography._();

  static const TextStyle display = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.84, // -0.02em
    color: LiquidGlassColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.56, // -0.02em
    color: LiquidGlassColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4, // -0.02em
    color: LiquidGlassColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: LiquidGlassColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: LiquidGlassColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle mono = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: LiquidGlassColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.5,
  );

  // High balance text with glow
  static TextStyle displayWithGlow({Color? glowColor}) {
    return display.copyWith(
      shadows: LiquidGlassShadows.textGlow(color: glowColor),
    );
  }

  static TextStyle headlineWithGlow({Color? glowColor}) {
    return headline.copyWith(
      shadows: LiquidGlassShadows.textGlow(color: glowColor),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ACOUSTIC UI - Haptic Patterns
// ═══════════════════════════════════════════════════════════════

class LiquidGlassHaptics {
  LiquidGlassHaptics._();

  static void cardTap() => HapticFeedback.lightImpact();
  static void buttonPress() => HapticFeedback.mediumImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void success() => HapticFeedback.heavyImpact();
  static void error() => HapticFeedback.vibrate();
}

// ═══════════════════════════════════════════════════════════════
// LIQUID GLASS CARD - Premium Widget with Optical Physics
// ═══════════════════════════════════════════════════════════════

class LiquidGlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enableLightTracking;
  final bool enableShimmer;
  final bool enableVariableBlur;
  final Color? glowColor;
  final double blurSigma;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.enableLightTracking = true,
    this.enableShimmer = true,
    this.enableVariableBlur = false,
    this.glowColor,
    this.blurSigma = 20,
  });

  @override
  State<LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<LiquidGlassCard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Offset _lightPosition = const Offset(0.3, 0.3);

  @override
  void initState() {
    super.initState();

    // Shimmer animation - 3.5 seconds sweep
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );
    if (widget.enableShimmer) {
      _shimmerController.repeat();
    }

    // Tap animation
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.30).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _tapController.forward();
    LiquidGlassHaptics.cardTap();

    if (widget.enableLightTracking) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final localPosition = details.localPosition;
      setState(() {
        _lightPosition = Offset(
          localPosition.dx / box.size.width,
          localPosition.dy / box.size.height,
        );
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    _tapController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(24);

    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _tapController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: LiquidGlassShadows.dualShadow(
                glowColor: widget.glowColor ?? LiquidGlassColors.primary,
                glowIntensity: _glowAnimation.value,
              ),
            ),
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  children: [
                    // Layer 1: Variable blur or standard blur
                    if (widget.enableVariableBlur)
                      _buildVariableBlur(radius)
                    else
                      _buildStandardBlur(),

                    // Layer 2: Glass gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LiquidGlassGradients.glassGradient,
                        borderRadius: radius,
                      ),
                    ),

                    // Layer 3: Dynamic luminance (light source)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LiquidGlassGradients.dynamicLuminanceGradient(
                          _lightPosition,
                        ),
                        borderRadius: radius,
                      ),
                    ),

                    // Layer 4: Specular highlights (micro shimmer)
                    if (widget.enableShimmer) _buildSpecularHighlights(),

                    // Layer 5: Animated highlight sweep
                    if (widget.enableShimmer) _buildAnimatedHighlight(radius),

                    // Layer 6: Active border with sweep gradient
                    _buildActiveBorder(radius),

                    // Layer 7: Content
                    Padding(
                      padding: widget.padding ?? const EdgeInsets.all(20),
                      child: widget.child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStandardBlur() {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: widget.blurSigma,
        sigmaY: widget.blurSigma,
      ),
      child: Container(color: Colors.transparent),
    );
  }

  Widget _buildVariableBlur(BorderRadius radius) {
    return Stack(
      children: [
        // Top section - less blur (sigma 15)
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 0.5,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        // Bottom section - more blur (sigma 25)
        ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 0.5,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecularHighlights() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _SpecularHighlightPainter(
          seed: _shimmerController.value,
        ),
      ),
    );
  }

  Widget _buildAnimatedHighlight(BorderRadius radius) {
    final sweepPosition = _shimmerController.value;
    return Positioned.fill(
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(-1 + (sweepPosition * 3), 0),
            end: Alignment(-0.5 + (sweepPosition * 3), 0),
            colors: const [
              Colors.transparent,
              Color(0x20FFFFFF),
              Colors.transparent,
            ],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcOver,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBorder(BorderRadius radius) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: Colors.transparent,
            width: 1.5,
          ),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: GradientBorder(
            gradient: LiquidGlassGradients.activeBorderGradient(
              rotation: _shimmerController.value * math.pi * 2,
            ),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// Custom painter for specular highlights
class _SpecularHighlightPainter extends CustomPainter {
  final double seed;
  final math.Random _random = math.Random(42);

  _SpecularHighlightPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x08FFFFFF)
      ..style = PaintingStyle.fill;

    // Generate subtle noise-like highlights
    for (int i = 0; i < 15; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 30 + 10;
      final opacity = (_random.nextDouble() * 0.03 + 0.01) *
          (1 + math.sin(seed * math.pi * 2 + i) * 0.3);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = Color.fromRGBO(255, 255, 255, opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_SpecularHighlightPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

// Gradient border decoration
class GradientBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBorder({
    required this.gradient,
    required this.width,
  });

  @override
  BorderSide get top => BorderSide.none;
  @override
  BorderSide get bottom => BorderSide.none;
  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    if (borderRadius != null) {
      canvas.drawRRect(
        borderRadius.toRRect(rect).deflate(width / 2),
        paint,
      );
    } else {
      canvas.drawRect(rect.deflate(width / 2), paint);
    }
  }

  @override
  ShapeBorder scale(double t) => this;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);
}

// ═══════════════════════════════════════════════════════════════
// LIQUID GLASS BUTTON
// ═══════════════════════════════════════════════════════════════

class LiquidGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? glowColor;
  final bool isLoading;

  const LiquidGlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.glowColor,
    this.isLoading = false,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Spring-like animation with damping 15, stiffness 150
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const _SpringCurve(damping: 15, stiffness: 150),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.1, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    LiquidGlassHaptics.buttonPress();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(16);
    final glowColor = widget.glowColor ?? LiquidGlassColors.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _onTapDown : null,
            onTapUp: widget.onPressed != null ? _onTapUp : null,
            onTapCancel: widget.onPressed != null ? _onTapCancel : null,
            child: Container(
              width: widget.width,
              height: widget.height ?? 56,
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: _glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: -2,
                  ),
                  ...LiquidGlassShadows.microShadow,
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LiquidGlassGradients.glassGradient,
                      borderRadius: radius,
                      border: Border.all(
                        color: LiquidGlassColors.glassBorder,
                        width: 1,
                      ),
                    ),
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  LiquidGlassColors.textPrimary,
                                ),
                              ),
                            )
                          : widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom spring curve
class _SpringCurve extends Curve {
  final double damping;
  final double stiffness;

  const _SpringCurve({
    required this.damping,
    required this.stiffness,
  });

  @override
  double transformInternal(double t) {
    final omega = math.sqrt(stiffness);
    final zeta = damping / (2 * math.sqrt(stiffness));

    if (zeta < 1) {
      // Underdamped
      final omegaD = omega * math.sqrt(1 - zeta * zeta);
      return 1 -
          math.exp(-zeta * omega * t) *
              (math.cos(omegaD * t) +
                  (zeta * omega / omegaD) * math.sin(omegaD * t));
    } else {
      // Critically damped or overdamped
      return 1 - (1 + omega * t) * math.exp(-omega * t);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// LIQUID GLASS CONTAINER - Lightweight
// ═══════════════════════════════════════════════════════════════

class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma = 15,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? LiquidGlassColors.glassBackground,
              borderRadius: radius,
              border: Border.all(
                color: borderColor ?? LiquidGlassColors.glassBorder,
                width: 1,
              ),
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LIQUID GLASS CHIP - Selectable Tag
// ═══════════════════════════════════════════════════════════════

class LiquidGlassChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;

  const LiquidGlassChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? LiquidGlassColors.primary;

    return GestureDetector(
      onTap: () {
        LiquidGlassHaptics.selection();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : LiquidGlassColors.glassBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? color : LiquidGlassColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: LiquidGlassTypography.caption.copyWith(
                color: isSelected ? color : LiquidGlassColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LIQUID GLASS DIVIDER
// ═══════════════════════════════════════════════════════════════

class LiquidGlassDivider extends StatelessWidget {
  final double? width;
  final EdgeInsetsGeometry? margin;

  const LiquidGlassDivider({
    super.key,
    this.width,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        gradient: LiquidGlassGradients.dividerGradient,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LIQUID GLASS TEXT FIELD
// ═══════════════════════════════════════════════════════════════

class LiquidGlassTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final FocusNode? focusNode;
  final bool autofocus;

  const LiquidGlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<LiquidGlassTextField> createState() => _LiquidGlassTextFieldState();
}

class _LiquidGlassTextFieldState extends State<LiquidGlassTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: LiquidGlassColors.glassBackground,
        border: Border.all(
          color: _isFocused
              ? LiquidGlassColors.primary.withValues(alpha: 0.5)
              : LiquidGlassColors.glassBorder,
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: LiquidGlassColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: LiquidGlassTypography.body,
            cursorColor: LiquidGlassColors.primary,
            decoration: InputDecoration(
              hintText: widget.hintText,
              labelText: widget.labelText,
              hintStyle: LiquidGlassTypography.body.copyWith(
                color: LiquidGlassColors.textTertiary,
              ),
              labelStyle: LiquidGlassTypography.caption.copyWith(
                color: _isFocused
                    ? LiquidGlassColors.primary
                    : LiquidGlassColors.textSecondary,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? LiquidGlassColors.primary
                          : LiquidGlassColors.textTertiary,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.onSuffixTap,
                      child: Icon(
                        widget.suffixIcon,
                        color: LiquidGlassColors.textTertiary,
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EXTENSIONS
// ═══════════════════════════════════════════════════════════════

extension LiquidGlassContext on BuildContext {
  // Access to liquid glass design tokens
  Color get liquidPrimary => LiquidGlassColors.primary;
  Color get liquidBackground => LiquidGlassColors.background;
  Color get liquidSurface => LiquidGlassColors.surface;
  Color get liquidTextPrimary => LiquidGlassColors.textPrimary;
  Color get liquidTextSecondary => LiquidGlassColors.textSecondary;
}

// ═══════════════════════════════════════════════════════════════
// ANIMATED BUILDER WRAPPER (to avoid name collision)
// ═══════════════════════════════════════════════════════════════

class AnimatedBuilder extends StatelessWidget {
  final Listenable animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: animation,
      builder: builder,
      child: child,
    );
  }
}
