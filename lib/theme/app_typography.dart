import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// VANTAG UNIFIED TYPOGRAPHY SYSTEM v2.0
// Type scale, font handling, financial numbers, ThemeData builders
// ═══════════════════════════════════════════════════════════════════════════

/// Font family declarations
class VantFonts {
  VantFonts._();

  /// Primary: system fonts (SF Pro on iOS, Roboto on Android)
  static String? get heading => null;
  static String? get body => null;
  static String get mono => Platform.isIOS ? 'Menlo' : 'Roboto Mono';

  /// Turkish character fallback chain
  static const List<String> fontFallback = [
    'SF Pro Display',
    'Roboto',
    'Segoe UI',
    'Apple Color Emoji',
    'Noto Sans',
  ];
}

/// Complete type scale from the blueprint
class VantTypography {
  VantTypography._();

  // ── Display (hero numbers) ──
  static const TextStyle displayLarge = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    letterSpacing: -2.0,
    height: 1.0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.05,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.1,
  );

  // ── Headlines ──
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.2,
  );

  // ── Titles ──
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  // ── Body ──
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  // ── Labels ──
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    height: 1.3,
  );

  // ── Financial Numbers ──

  /// Text style for financial amounts with tabular figures.
  /// All financial data MUST use this to ensure equal-width digits.
  static TextStyle financialAmount({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: -0.5,
    );
  }

  /// Hero balance number (light weight = luxury)
  static TextStyle heroAmount({Color? color}) {
    return TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w300,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: -2.0,
      height: 1.0,
    );
  }

  /// Card-level amount
  static TextStyle cardAmount({Color? color}) {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: -0.5,
      height: 1.1,
    );
  }

  /// Inline transaction amount
  static TextStyle inlineAmount({Color? color}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: -0.3,
    );
  }

  // ── Accessibility ──

  /// Scaled font size respecting system text scaling (max 1.5x)
  static double scaledFontSize(
    BuildContext context,
    double baseSize, {
    double maxScale = 1.5,
    double minScale = 1.0,
  }) {
    final scale = MediaQuery.of(context)
        .textScaler
        .scale(1.0)
        .clamp(minScale, maxScale);
    return baseSize * scale;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// THEME DATA BUILDERS
// ═══════════════════════════════════════════════════════════════════════════

class VantTheme {
  VantTheme._();

  /// Complete dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF050508),
      fontFamily: VantFonts.heading,
      fontFamilyFallback: VantFonts.fontFallback,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8B5CF6),
        secondary: Color(0xFF22D3EE),
        surface: Color(0xFF0F0D17),
        error: Color(0xFFEF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFAFAFA),
          letterSpacing: 0,
        ),
        iconTheme: IconThemeData(color: Color(0xFFFAFAFA)),
      ),
      textTheme: _buildTextTheme(const Color(0xFFFAFAFA)),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Complete light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      fontFamily: VantFonts.heading,
      fontFamilyFallback: VantFonts.fontFallback,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8B5CF6),
        secondary: Color(0xFF22D3EE),
        surface: Color(0xFFFFFFFF),
        error: Color(0xFFEF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
          letterSpacing: 0,
        ),
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      ),
      textTheme: _buildTextTheme(const Color(0xFF0F172A)),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: VantTypography.displayLarge.copyWith(color: baseColor),
      displayMedium: VantTypography.displayMedium.copyWith(color: baseColor),
      displaySmall: VantTypography.displaySmall.copyWith(color: baseColor),
      headlineLarge: VantTypography.headlineLarge.copyWith(color: baseColor),
      headlineMedium: VantTypography.headlineMedium.copyWith(color: baseColor),
      headlineSmall: VantTypography.headlineSmall.copyWith(color: baseColor),
      titleLarge: VantTypography.titleLarge.copyWith(color: baseColor),
      titleMedium: VantTypography.titleMedium.copyWith(color: baseColor),
      titleSmall: VantTypography.titleSmall.copyWith(color: baseColor),
      bodyLarge: VantTypography.bodyLarge.copyWith(color: baseColor),
      bodyMedium: VantTypography.bodyMedium.copyWith(color: baseColor),
      bodySmall: VantTypography.bodySmall.copyWith(color: baseColor),
      labelLarge: VantTypography.labelLarge.copyWith(color: baseColor),
      labelMedium: VantTypography.labelMedium.copyWith(color: baseColor),
      labelSmall: VantTypography.labelSmall.copyWith(color: baseColor),
    );
  }
}
