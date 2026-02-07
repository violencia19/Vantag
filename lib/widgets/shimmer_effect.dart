import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Shimmer efekti widget'ı
/// Platinum rozetler ve yükleme durumları için kullanılır
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final Duration duration;
  final bool enabled;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.colors,
    this.duration = const Duration(milliseconds: 2000),
    this.enabled = true,
  });

  /// Platinum gradient için
  factory ShimmerEffect.platinum({
    Key? key,
    required Widget child,
    bool enabled = true,
  }) {
    return ShimmerEffect(
      key: key,
      colors: const [
        Color(0xFFE5E4E2),
        Color(0xFF8ED1FC),
        Color(0xFFB4A7D6),
        Color(0xFFE5E4E2),
      ],
      enabled: enabled,
      child: child,
    );
  }

  /// Yükleme placeholder için
  factory ShimmerEffect.loading({Key? key, required Widget child}) {
    return ShimmerEffect(
      key: key,
      colors: const [
        Color(0xFF2A2A40), // VantColors.surfaceLight hardcoded for const factory
        Color(
          0xFF35354D,
        ), // VantColors.surfaceLighter hardcoded for const factory
        Color(0xFF2A2A40), // VantColors.surfaceLight hardcoded for const factory
      ],
      child: child,
    );
  }

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
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

    final colors =
        widget.colors ?? const [Colors.white24, Colors.white54, Colors.white24];

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(-1.0 + 2 * _animation.value, 0),
                end: Alignment(0.0 + 2 * _animation.value, 0),
                colors: colors,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Gradient border ile shimmer efekti
class ShimmerBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final List<Color>? colors;
  final Duration duration;
  final bool enabled;

  const ShimmerBorder({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.borderWidth = 2,
    this.colors,
    this.duration = const Duration(milliseconds: 2000),
    this.enabled = true,
  });

  @override
  State<ShimmerBorder> createState() => _ShimmerBorderState();
}

class _ShimmerBorderState extends State<ShimmerBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
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

    final colors =
        widget.colors ??
        const [
          Color(0xFFE5E4E2),
          Color(0xFF8ED1FC),
          Color(0xFFB4A7D6),
          Color(0xFFE5E4E2),
        ];

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: SweepGradient(
                startAngle: _animation.value * 6.28,
                colors: colors,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(widget.borderWidth),
              decoration: BoxDecoration(
                color: context.vantColors.surface,
                borderRadius: BorderRadius.circular(
                  widget.borderRadius - widget.borderWidth,
                ),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Blur + opacity ile kilitli görünüm
class LockedOverlay extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final double blurAmount;
  final double opacity;

  const LockedOverlay({
    super.key,
    required this.child,
    this.isLocked = true,
    this.blurAmount = AppAnimations.lockedBlur,
    this.opacity = AppAnimations.lockedOpacity,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) {
      return child;
    }

    return Stack(
      children: [
        // Blur yapılmış içerik
        Opacity(
          opacity: opacity,
          child: ImageFiltered(
            imageFilter: blurAmount > 0
                ? ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3),
                    BlendMode.darken,
                  )
                : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
            child: child,
          ),
        ),
      ],
    );
  }
}
