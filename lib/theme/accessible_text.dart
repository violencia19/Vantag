import 'package:flutter/material.dart';

/// Helper class for accessible text that respects system text scaling
/// while preventing layout breakage at extreme scales
class AccessibleText {
  /// Returns a font size that respects system text scaling
  /// but with a maximum scale to prevent layout breaking
  static double scaledFontSize(
    BuildContext context,
    double baseSize, {
    double maxScale = 1.5,
    double minScale = 1.0,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final scale = mediaQuery.textScaler.scale(1.0).clamp(minScale, maxScale);
    return baseSize * scale;
  }

  /// Text style that scales with system settings
  static TextStyle scaled(
    BuildContext context, {
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    double maxScale = 1.5,
    double minScale = 1.0,
  }) {
    return TextStyle(
      fontSize: scaledFontSize(context, fontSize, maxScale: maxScale, minScale: minScale),
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// Large display text (for dashboard numbers, etc.)
  /// Uses lower maxScale to prevent overflow
  static TextStyle largeDisplay(
    BuildContext context, {
    Color? color,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return scaled(
      context,
      fontSize: 32,
      fontWeight: fontWeight,
      color: color,
      maxScale: 1.3, // Lower scale for large numbers
    );
  }

  /// Medium display text (for card amounts, time displays)
  static TextStyle mediumDisplay(
    BuildContext context, {
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return scaled(
      context,
      fontSize: 24,
      fontWeight: fontWeight,
      color: color,
      maxScale: 1.4,
    );
  }

  /// Title text (section headers)
  static TextStyle title(
    BuildContext context, {
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return scaled(
      context,
      fontSize: 18,
      fontWeight: fontWeight,
      color: color,
      maxScale: 1.5,
    );
  }

  /// Body text (descriptions, labels)
  static TextStyle body(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return scaled(
      context,
      fontSize: 16,
      fontWeight: fontWeight,
      color: color,
      maxScale: 1.5,
    );
  }

  /// Caption text (small labels, hints)
  static TextStyle caption(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return scaled(
      context,
      fontSize: 12,
      fontWeight: fontWeight,
      color: color,
      maxScale: 1.4,
    );
  }

  /// Button text
  static TextStyle button(
    BuildContext context, {
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return scaled(
      context,
      fontSize: 16,
      fontWeight: fontWeight,
      color: color,
      maxScale: 1.3,
    );
  }
}

/// Extension for easy access to scaled fonts
extension AccessibleTextExtension on BuildContext {
  /// Get scaled font size with optional max scale
  double scaledFont(double size, {double maxScale = 1.5}) {
    return AccessibleText.scaledFontSize(this, size, maxScale: maxScale);
  }

  /// Check if user has accessibility text scaling enabled
  bool get hasLargeText {
    final scale = MediaQuery.of(this).textScaler.scale(1.0);
    return scale > 1.2;
  }

  /// Get the current text scale factor
  double get textScale {
    return MediaQuery.of(this).textScaler.scale(1.0);
  }
}

/// Widget that wraps text with FittedBox for overflow protection
class ScalableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final double maxScale;

  const ScalableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.maxScale = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: textAlign == TextAlign.center
          ? Alignment.center
          : textAlign == TextAlign.right
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
      ),
    );
  }
}

/// Minimum touch target size for accessibility (44x44 per WCAG)
class AccessibleTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minSize;

  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minSize = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: Center(child: child),
      ),
    );
  }
}
