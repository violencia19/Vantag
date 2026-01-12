import 'package:flutter/material.dart';

/// Spacing System - 8px Grid
/// All spacing values should be multiples of 8px
/// Inspired by Material Design & Tailwind CSS spacing scale
class Spacing {
  Spacing._();

  // ═══════════════════════════════════════════════════════
  // BASE SPACING VALUES (8px grid)
  // ═══════════════════════════════════════════════════════

  /// 4px - Extra small (half step)
  static const double xs = 4;

  /// 8px - Small
  static const double sm = 8;

  /// 12px - Medium small (1.5 step)
  static const double md = 12;

  /// 16px - Medium (2 steps)
  static const double lg = 16;

  /// 20px - Medium large (2.5 steps)
  static const double xl = 20;

  /// 24px - Large (3 steps)
  static const double xxl = 24;

  /// 32px - Extra large (4 steps)
  static const double xxxl = 32;

  /// 40px - 2XL (5 steps)
  static const double x4l = 40;

  /// 48px - 3XL (6 steps)
  static const double x5l = 48;

  // ═══════════════════════════════════════════════════════
  // SEMANTIC SPACING
  // ═══════════════════════════════════════════════════════

  /// Screen horizontal padding
  static const double screenHorizontal = 24;

  /// Screen vertical padding
  static const double screenVertical = 16;

  /// Card internal padding
  static const double cardPadding = 20;

  /// Section spacing (between major sections)
  static const double sectionGap = 32;

  /// Item spacing (between list items)
  static const double itemGap = 12;

  /// Element spacing (between elements in a row)
  static const double elementGap = 8;

  /// Button padding horizontal
  static const double buttonPaddingH = 24;

  /// Button padding vertical
  static const double buttonPaddingV = 16;

  // ═══════════════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════════════

  /// Small radius (chips, badges)
  static const double radiusXs = 6;

  /// Medium radius (buttons, inputs)
  static const double radiusSm = 8;

  /// Default radius (inputs, small cards)
  static const double radiusMd = 12;

  /// Large radius (cards)
  static const double radiusLg = 16;

  /// Extra large radius (main cards)
  static const double radiusXl = 20;

  /// Full round (nav bars, pills)
  static const double radiusFull = 28;

  // ═══════════════════════════════════════════════════════
  // ICON SIZES
  // ═══════════════════════════════════════════════════════

  /// Small icon
  static const double iconSm = 16;

  /// Default icon
  static const double iconMd = 20;

  /// Large icon
  static const double iconLg = 24;

  /// Extra large icon
  static const double iconXl = 32;

  /// Hero icon
  static const double iconHero = 48;

  // ═══════════════════════════════════════════════════════
  // EDGE INSETS HELPERS
  // ═══════════════════════════════════════════════════════

  /// No padding
  static const EdgeInsets zero = EdgeInsets.zero;

  /// All sides xs (4px)
  static const EdgeInsets allXs = EdgeInsets.all(xs);

  /// All sides sm (8px)
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// All sides md (12px)
  static const EdgeInsets allMd = EdgeInsets.all(md);

  /// All sides lg (16px)
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// All sides xl (20px)
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// All sides xxl (24px)
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  /// Screen padding (horizontal 24, vertical 16)
  static const EdgeInsets screen = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: screenVertical,
  );

  /// Horizontal padding for screen content
  static const EdgeInsets screenH = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
  );

  /// Card padding (20px all sides)
  static const EdgeInsets card = EdgeInsets.all(cardPadding);

  /// Button padding
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: buttonPaddingH,
    vertical: buttonPaddingV,
  );

  /// List item padding
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
}

/// Typography Spacing - Line Heights & Letter Spacing
class TypographySpacing {
  TypographySpacing._();

  // Letter spacing
  static const double tightLetterSpacing = -2.0;
  static const double normalLetterSpacing = -0.5;
  static const double wideLetterSpacing = 1.2;
  static const double extraWideLetterSpacing = 2.0;

  // Line heights
  static const double tightLineHeight = 1.0;
  static const double normalLineHeight = 1.2;
  static const double relaxedLineHeight = 1.5;
}

/// Animation Durations
class AnimationDurations {
  AnimationDurations._();

  /// Fast animations (hover states, micro-interactions)
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animations (most transitions)
  static const Duration normal = Duration(milliseconds: 250);

  /// Slow animations (page transitions, complex animations)
  static const Duration slow = Duration(milliseconds: 400);

  /// Counting/number animations
  static const Duration counting = Duration(milliseconds: 800);

  /// Stagger delay (for list animations)
  static const Duration stagger = Duration(milliseconds: 50);
}

/// Animation Curves
class AnimationCurves {
  AnimationCurves._();

  /// Default curve for most animations
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Entrance animations
  static const Curve entrance = Curves.easeOutCubic;

  /// Exit animations
  static const Curve exit = Curves.easeInCubic;

  /// Page transitions
  static const Curve page = Curves.easeInOutCubic;

  /// Bounce effect (for celebratory animations)
  static const Curve bounce = Curves.elasticOut;

  /// Sharp curve (for quick responses)
  static const Curve sharp = Curves.easeOutQuart;
}
