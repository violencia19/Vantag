import 'package:flutter/material.dart';
import '../theme/quiet_luxury.dart';

/// ShaderMask fill-from-bottom animation for pursuit progress
class PursuitProgressVisual extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String emoji;
  final String? imageUrl;
  final double size;
  final bool animate;
  final Color? fillColor;

  const PursuitProgressVisual({
    super.key,
    required this.progress,
    required this.emoji,
    this.imageUrl,
    this.size = 64,
    this.animate = true,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = fillColor ?? QuietLuxury.positive;

    if (!animate) {
      return _buildContent(progress, effectiveFillColor);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return _buildContent(value, effectiveFillColor);
      },
    );
  }

  Widget _buildContent(double value, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle (unfilled part)
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: QuietLuxury.cardBackground,
            border: Border.all(color: QuietLuxury.cardBorder, width: 1),
          ),
        ),
        // Filled part with ShaderMask
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white,
                Colors.white,
                Colors.transparent,
                Colors.transparent,
              ],
              stops: [0.0, value, value, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  color.withValues(alpha: 0.8),
                  color.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
        // Emoji or Image
        if (imageUrl != null)
          ClipOval(
            child: Image.network(
              imageUrl!,
              width: size * 0.6,
              height: size * 0.6,
              fit: BoxFit.cover,
              cacheWidth: 150,
              cacheHeight: 150,
              errorBuilder: (_, __, ___) => _buildEmoji(),
            ),
          )
        else
          _buildEmoji(),
      ],
    );
  }

  Widget _buildEmoji() {
    return Text(emoji, style: TextStyle(fontSize: size * 0.4));
  }
}

/// Circular progress indicator for pursuit (alternative style)
class PursuitCircularProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String emoji;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;

  const PursuitCircularProgress({
    super.key,
    required this.progress,
    required this.emoji,
    this.size = 80,
    this.strokeWidth = 4,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                backgroundColor ?? QuietLuxury.cardBorder,
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
          // Progress arc
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? QuietLuxury.positive,
                  ),
                  backgroundColor: Colors.transparent,
                ),
              );
            },
          ),
          // Emoji
          Text(emoji, style: TextStyle(fontSize: size * 0.35)),
        ],
      ),
    );
  }
}

/// Linear progress bar for pursuit list cards
class PursuitLinearProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const PursuitLinearProgress({
    super.key,
    required this.progress,
    this.height = 6,
    this.progressColor,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(height / 2);
    final effectiveProgressColor = progressColor ?? QuietLuxury.positive;
    final effectiveBackgroundColor = backgroundColor ?? QuietLuxury.cardBorder;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveRadius,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    effectiveProgressColor.withValues(alpha: 0.7),
                    effectiveProgressColor,
                  ],
                ),
                borderRadius: effectiveRadius,
                boxShadow: [
                  BoxShadow(
                    color: effectiveProgressColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
