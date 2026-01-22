import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Color Palette - Wealth Coach
/// Hobi projesi değil, 1000 kişilik ekip arkasında varmış gibi
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════
  // ARKA PLAN - PREMIUM DARK MOR
  // ═══════════════════════════════════════════════════════

  /// Ana arka plan - koyu mor (siyah değil!)
  static const Color background = Color(0xFF0D0B14);

  /// Kart arka planı
  static const Color cardBackground = Color(0xFF1A1625);

  /// Yükseltilmiş yüzey
  static const Color surfaceElevated = Color(0xFF2D2440);

  /// Gradient başlangıç - Koyu mor
  static const Color gradientStart = Color(0xFF0D0B14);

  /// Gradient orta - Orta mor
  static const Color gradientMid = Color(0xFF1A1625);

  /// Gradient bitiş - Açık mor
  static const Color gradientEnd = Color(0xFF2D2440);

  // Surface colors (glass effect)
  static const Color surface = Color(0x08FFFFFF); // rgba(255,255,255,0.03)
  static const Color surfaceLight = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const Color surfaceLighter = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // ═══════════════════════════════════════════════════════
  // ANA RENKLER
  // ═══════════════════════════════════════════════════════

  /// Primary - Soft mor (butonlar, aktif elementler)
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52E0);
  static const Color primaryLight = Color(0xFF8B85FF);

  /// Secondary - Turkuaz (pozitif değerler, başarı)
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryDark = Color(0xFF3DBDB5);
  static const Color secondaryLight = Color(0xFF6EDDD6);

  /// Accent - Altın (SADECE önemli başarılar)
  static const Color accent = Color(0xFFFFD93D);
  static const Color gold = Color(0xFFFFD93D);

  // ═══════════════════════════════════════════════════════
  // METİN RENKLERİ
  // ═══════════════════════════════════════════════════════

  /// Primary text - Beyaz
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text - Soluk gri-mor
  static const Color textSecondary = Color(0xFF8B8B9E);

  /// Tertiary text - Daha soluk
  static const Color textTertiary = Color(0xFF5A5A6E);

  // ═══════════════════════════════════════════════════════
  // DURUM RENKLERİ
  // ═══════════════════════════════════════════════════════

  /// Success - Turkuaz (yeşil yerine)
  static const Color success = Color(0xFF4ECDC4);

  /// Warning - Altın
  static const Color warning = Color(0xFFFFD93D);

  /// Error/Danger - Soft kırmızı
  static const Color error = Color(0xFFFF6B6B);

  /// Info - Primary mor
  static const Color info = Color(0xFF6C63FF);

  // ═══════════════════════════════════════════════════════
  // KARAR RENKLERİ
  // ═══════════════════════════════════════════════════════

  /// Aldım/Harcandı - Soft kırmızı
  static const Color decisionYes = Color(0xFFFF6B6B);

  /// Düşünüyorum - Altın
  static const Color decisionThinking = Color(0xFFFFD93D);

  /// Vazgeçtim/Kurtarılan - Turkuaz
  static const Color decisionNo = Color(0xFF4ECDC4);

  // ═══════════════════════════════════════════════════════
  // KART RENKLERİ
  // ═══════════════════════════════════════════════════════

  /// Kart arka plan (glass effect) - rgba(255,255,255,0.03)
  static const Color cardBackgroundGlass = Color(0x08FFFFFF);

  /// Kart border - rgba(255,255,255,0.08)
  static const Color cardBorder = Color(0x14FFFFFF);

  /// Kart gölge
  static const Color cardShadow = Color(0x4D000000); // rgba(0,0,0,0.3)
}

/// Premium Gradients
class AppGradients {
  AppGradients._();

  /// Sayfa arka plan gradienti
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientStart,
      AppColors.gradientMid,
      AppColors.gradientEnd,
    ],
  );

  /// Primary buton gradienti (mor → turkuaz)
  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
  );

  /// Progress bar gradienti
  static const LinearGradient progress = LinearGradient(
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
  );

  /// Success gradienti
  static const LinearGradient success = LinearGradient(
    colors: [
      AppColors.secondary,
      Color(0xFF3DBDB5),
    ],
  );
}

/// Premium Font Families
/// Headings/Numbers: Space Grotesk (modern fintech feel)
/// Body: DM Sans (clean, readable)
class AppFonts {
  AppFonts._();

  static String get heading => GoogleFonts.spaceGrotesk().fontFamily!;
  static String get body => GoogleFonts.dmSans().fontFamily!;
  static String get mono => GoogleFonts.jetBrainsMono().fontFamily!;
}

class AppTheme {
  /// Light theme for the app
  static ThemeData get lightTheme {
    final headingFont = AppFonts.heading;
    final bodyFont = AppFonts.body;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: bodyFont,
      scaffoldBackgroundColor: AppColorsLight.background,
      colorScheme: const ColorScheme.light(
        surface: AppColorsLight.background,
        primary: AppColorsLight.primary,
        secondary: AppColorsLight.secondary,
        error: AppColorsLight.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColorsLight.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: AppColorsLight.textPrimary,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColorsLight.background,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColorsLight.cardBackground,
        elevation: 2,
        shadowColor: AppColorsLight.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColorsLight.cardBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsLight.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsLight.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColorsLight.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColorsLight.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColorsLight.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColorsLight.error),
        ),
        labelStyle: const TextStyle(
          color: AppColorsLight.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: AppColorsLight.textTertiary,
          fontSize: 16,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColorsLight.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsLight.textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColorsLight.cardBorder,
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 56,
          fontWeight: FontWeight.w700,
          color: AppColorsLight.textPrimary,
          letterSpacing: -2,
        ),
        displayMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: AppColorsLight.textPrimary,
          letterSpacing: -1,
        ),
        displaySmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColorsLight.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColorsLight.textPrimary,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColorsLight.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColorsLight.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColorsLight.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColorsLight.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColorsLight.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColorsLight.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColorsLight.textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColorsLight.textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColorsLight.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColorsLight.textSecondary,
          letterSpacing: 1.5,
        ),
        labelSmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColorsLight.textSecondary,
          letterSpacing: 2,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _PremiumPageTransitionsBuilder(),
          TargetPlatform.iOS: _PremiumPageTransitionsBuilder(),
          TargetPlatform.windows: _PremiumPageTransitionsBuilder(),
          TargetPlatform.macOS: _PremiumPageTransitionsBuilder(),
          TargetPlatform.linux: _PremiumPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    final headingFont = AppFonts.heading;
    final bodyFont = AppFonts.body;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: bodyFont, // DM Sans as default
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.background,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.cardBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 16,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.gradientMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceLighter,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
      ),
      // Premium TextTheme with Space Grotesk for numbers/headings, DM Sans for body
      textTheme: TextTheme(
        // Display styles - Space Grotesk (for large numbers)
        displayLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 56,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -2,
        ),
        displayMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -1,
        ),
        displaySmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        // Headline styles - Space Grotesk
        headlineLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // Title styles - Space Grotesk (for section headers)
        titleLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        // Body styles - DM Sans (for readable text)
        bodyLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        // Label styles - DM Sans
        labelLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        ),
        labelSmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 2,
        ),
      ),
      // Premium page transitions - 350ms easeInOutCubic
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _PremiumPageTransitionsBuilder(),
          TargetPlatform.iOS: _PremiumPageTransitionsBuilder(),
          TargetPlatform.windows: _PremiumPageTransitionsBuilder(),
          TargetPlatform.macOS: _PremiumPageTransitionsBuilder(),
          TargetPlatform.linux: _PremiumPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Premium Page Transition Builder
/// 350ms easeInOutCubic slide + fade transition
class _PremiumPageTransitionsBuilder extends PageTransitionsBuilder {
  const _PremiumPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _PremiumPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class _PremiumPageTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _PremiumPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Fade + Slide transition
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    ));

    // Secondary animation for existing page (slight fade)
    final secondaryFade = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOutCubic,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: secondaryFade,
          child: child,
        ),
      ),
    );
  }
}

/// Premium modal route for bottom sheets and dialogs
/// 300ms easeOutCubic shared axis transition
class PremiumModalRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  PremiumModalRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

// ═══════════════════════════════════════════════════════════════════════════
// LIGHT MODE COLORS
// ═══════════════════════════════════════════════════════════════════════════

/// Light Mode Color Palette - Clean, Modern Finance App
class AppColorsLight {
  AppColorsLight._();

  // ─────────────────────────────────────────────────────────────────
  // BACKGROUNDS
  // ─────────────────────────────────────────────────────────────────

  /// Main background - Off-white
  static const Color background = Color(0xFFF8F9FA);

  /// Card background - Pure white
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Elevated surface - Light gray
  static const Color surfaceElevated = Color(0xFFF0F2F5);

  /// Gradient colors
  static const Color gradientStart = Color(0xFFF8F9FA);
  static const Color gradientMid = Color(0xFFFFFFFF);
  static const Color gradientEnd = Color(0xFFF0F2F5);

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF0F2F5);
  static const Color surfaceLighter = Color(0xFFE8EAED);

  // ─────────────────────────────────────────────────────────────────
  // PRIMARY COLORS
  // ─────────────────────────────────────────────────────────────────

  /// Primary - Soft purple (same as dark mode for consistency)
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52E0);
  static const Color primaryLight = Color(0xFF8B85FF);

  /// Secondary - Turquoise
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryDark = Color(0xFF3DBDB5);
  static const Color secondaryLight = Color(0xFF6EDDD6);

  /// Accent - Gold
  static const Color accent = Color(0xFFFFD93D);
  static const Color gold = Color(0xFFFFD93D);

  // ─────────────────────────────────────────────────────────────────
  // TEXT COLORS
  // ─────────────────────────────────────────────────────────────────

  /// Primary text - Dark gray (almost black)
  static const Color textPrimary = Color(0xFF1A1A2E);

  /// Secondary text - Medium gray
  static const Color textSecondary = Color(0xFF6B7280);

  /// Tertiary text - Light gray
  static const Color textTertiary = Color(0xFF9CA3AF);

  // ─────────────────────────────────────────────────────────────────
  // STATUS COLORS
  // ─────────────────────────────────────────────────────────────────

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF6C63FF);

  // ─────────────────────────────────────────────────────────────────
  // DECISION COLORS
  // ─────────────────────────────────────────────────────────────────

  static const Color decisionYes = Color(0xFFEF4444);
  static const Color decisionThinking = Color(0xFFF59E0B);
  static const Color decisionNo = Color(0xFF10B981);

  // ─────────────────────────────────────────────────────────────────
  // CARD COLORS
  // ─────────────────────────────────────────────────────────────────

  static const Color cardBackgroundGlass = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color cardShadow = Color(0x1A000000);
}
