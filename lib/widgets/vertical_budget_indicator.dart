import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../core/theme/premium_effects.dart';

/// Vertical Budget Indicator - Premium UI Element
/// A distinctive vertical progress bar that fills from TOP to BOTTOM
/// Colors change based on budget usage:
/// - Purple gradient: < 70% spent (healthy)
/// - Red: >= 70% spent (danger)
class VerticalBudgetIndicator extends StatefulWidget {
  final double progress; // 0.0 - 1.0 (spent percentage)
  final double height;
  final double width;
  final bool showGlow;
  final bool animated;
  final bool showShimmer;
  final Duration animationDuration;

  const VerticalBudgetIndicator({
    super.key,
    required this.progress,
    this.height = 120,
    this.width = 8,
    this.showGlow = true,
    this.animated = true,
    this.showShimmer = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<VerticalBudgetIndicator> createState() =>
      _VerticalBudgetIndicatorState();
}

class _VerticalBudgetIndicatorState extends State<VerticalBudgetIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.4, end: 0.7).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  Color get _fillColor {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);
    // %70'te kırmızıya dön
    if (clampedProgress >= 0.7) {
      return AppColors.error;
    }
    return PremiumColors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);
    final fillColor = _fillColor;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(widget.width / 2),
      ),
      child: Stack(
        alignment: Alignment.topCenter, // Yukarıdan aşağı dol
        children: [
          // Fill bar
          widget.animated
              ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: clampedProgress),
                  duration: widget.animationDuration,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return _buildFillBar(value, fillColor);
                  },
                )
              : _buildFillBar(clampedProgress, fillColor),
        ],
      ),
    );
  }

  Widget _buildFillBar(double value, Color color) {
    final isRed = color == AppColors.error;

    Widget bar = AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height * value,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.width / 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isRed
                  ? [
                      AppColors.error,
                      AppColors.error.withOpacity(0.8),
                    ]
                  : [
                      PremiumColors.purple,
                      PremiumColors.purpleLight,
                    ],
            ),
            boxShadow: widget.showGlow
                ? [
                    BoxShadow(
                      color: color.withOpacity(_breatheAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: color.withOpacity(_breatheAnimation.value * 0.5),
                      blurRadius: 40,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
        );
      },
    );

    // Shimmer efekti ekle
    if (widget.showShimmer && value > 0) {
      bar = _ShimmerOverlay(child: bar);
    }

    return bar;
  }
}

/// Internal shimmer overlay for progress bar
class _ShimmerOverlay extends StatefulWidget {
  final Widget child;

  const _ShimmerOverlay({required this.child});

  @override
  State<_ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<_ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.4),
                Colors.transparent,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Horizontal version of the budget indicator
/// Used in cards and compact layouts
class HorizontalBudgetIndicator extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final double height;
  final double? width;
  final bool showGlow;
  final bool animated;
  final bool showShimmer;
  final Duration animationDuration;

  const HorizontalBudgetIndicator({
    super.key,
    required this.progress,
    this.height = 6,
    this.width,
    this.showGlow = true,
    this.animated = true,
    this.showShimmer = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<HorizontalBudgetIndicator> createState() =>
      _HorizontalBudgetIndicatorState();
}

class _HorizontalBudgetIndicatorState extends State<HorizontalBudgetIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.4, end: 0.7).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  Color get _fillColor {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);
    if (clampedProgress >= 0.7) {
      return AppColors.error;
    }
    return PremiumColors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);
    final fillColor = _fillColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = widget.width ?? constraints.maxWidth;

        return Container(
          width: totalWidth,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Fill bar
              widget.animated
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: clampedProgress),
                      duration: widget.animationDuration,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return _buildFillBar(value, fillColor, totalWidth);
                      },
                    )
                  : _buildFillBar(clampedProgress, fillColor, totalWidth),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFillBar(double value, Color color, double totalWidth) {
    final isRed = color == AppColors.error;

    Widget bar = AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Container(
          width: totalWidth * value,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isRed
                  ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                  : [
                      PremiumColors.purpleDark,
                      PremiumColors.purple,
                      PremiumColors.purpleLight,
                    ],
            ),
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: widget.showGlow
                ? [
                    BoxShadow(
                      color: color.withOpacity(_breatheAnimation.value),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
        );
      },
    );

    if (widget.showShimmer && value > 0) {
      bar = ShimmerEffect(child: bar);
    }

    return bar;
  }
}

/// Accent line - A small vertical accent used for section headers
/// Part of the signature design language
class AccentLine extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;
  final bool showGradient;

  const AccentLine({
    super.key,
    this.height = 20,
    this.width = 3,
    this.color,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: showGradient ? null : (color ?? AppColors.primary),
        gradient: showGradient ? AppGradients.primaryButton : null,
        borderRadius: BorderRadius.circular(width / 2),
      ),
    );
  }
}

/// Category accent line - Shows category color
class CategoryAccentLine extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const CategoryAccentLine({
    super.key,
    this.height = 60,
    this.width = 3,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width / 2),
      ),
    );
  }
}
