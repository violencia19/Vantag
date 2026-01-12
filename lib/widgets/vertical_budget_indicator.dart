import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Vertical Budget Indicator - Signature UI Element
/// A distinctive vertical progress bar that fills from bottom to top
/// Colors change based on budget usage:
/// - Purple: < 70% spent (healthy)
/// - Amber: 70-90% spent (warning)
/// - Red: > 90% spent (danger)
class VerticalBudgetIndicator extends StatelessWidget {
  final double progress; // 0.0 - 1.0 (spent percentage)
  final double height;
  final double width;
  final bool showGlow;
  final bool animated;
  final Duration animationDuration;

  const VerticalBudgetIndicator({
    super.key,
    required this.progress,
    this.height = 120,
    this.width = 6,
    this.showGlow = true,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  Color get _fillColor {
    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress > 0.9) {
      return AppColors.error;
    } else if (clampedProgress > 0.7) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final fillColor = _fillColor;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(width / 2),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Fill bar
          animated
              ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: clampedProgress),
                  duration: animationDuration,
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
    return Container(
      width: width,
      height: height * value,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width / 2),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
    );
  }
}

/// Horizontal version of the budget indicator
/// Used in cards and compact layouts
class HorizontalBudgetIndicator extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double height;
  final double? width;
  final bool showGlow;
  final bool animated;
  final Duration animationDuration;

  const HorizontalBudgetIndicator({
    super.key,
    required this.progress,
    this.height = 6,
    this.width,
    this.showGlow = true,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  Color get _fillColor {
    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress > 0.9) {
      return AppColors.error;
    } else if (clampedProgress > 0.7) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final fillColor = _fillColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = width ?? constraints.maxWidth;

        return Container(
          width: totalWidth,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Fill bar
              animated
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: clampedProgress),
                      duration: animationDuration,
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
    return Container(
      width: totalWidth * value,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
    );
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
