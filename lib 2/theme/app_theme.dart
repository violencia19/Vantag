import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium Color Palette - iOS 26 Liquid Glass
/// 2026 Fintech Standard - Revolut Ultra, N26 Metal seviyesi
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════
  // ARKA PLAN - Psychology-Based OLED Black
  // ═══════════════════════════════════════════════════════

  /// Ana arka plan - Ultra deep OLED black
  static const Color background = Color(0xFF050508);

  /// Kart arka planı
  static const Color cardBackground = Color(0xFF12101A);

  /// Yükseltilmiş yüzey
  static const Color surfaceElevated = Color(0xFF1A1725);

  /// Surface overlay - Modals, sheets
  static const Color surfaceOverlay = Color(0xFF231F2E);

  /// Gradient başlangıç
  static const Color gradientStart = Color(0xFF0A0A0F);

  /// Gradient orta
  static const Color gradientMid = Color(0xFF12101A);

  /// Gradient bitiş
  static const Color gradientEnd = Color(0xFF1A1725);

  // Surface colors (iOS 26 Liquid Glass style)
  static const Color surface = Color(0xFF12101A);
  static const Color surfaceLight = Color(0xFF1A1725);
  static const Color surfaceLighter = Color(0xFF231F2E);

  // ═══════════════════════════════════════════════════════
  // ANA RENKLER (iOS 26 Vibrant Purple)
  // ═══════════════════════════════════════════════════════

  /// Primary - Vibrant Purple (iOS 26 style)
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);

  /// Secondary - Cyan (Liquid Glass signature)
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color secondaryLight = Color(0xFF22D3EE);

  /// Accent - Gold
  static const Color accent = Color(0xFFF59E0B);
  static const Color gold = Color(0xFFF59E0B);

  // ═══════════════════════════════════════════════════════
  // METİN RENKLERİ (iOS 26 Style)
  // ═══════════════════════════════════════════════════════

  /// Primary text
  static const Color textPrimary = Color(0xFFFAFAFA);

  /// Secondary text
  static const Color textSecondary = Color(0xFFA1A1AA);

  /// Tertiary text
  static const Color textTertiary = Color(0xFF71717A);

  /// Muted text
  static const Color textMuted = Color(0xFF52525B);

  // ═══════════════════════════════════════════════════════
  // DURUM RENKLERİ (2026 Fintech Standard)
  // ═══════════════════════════════════════════════════════

  /// Success - Emerald
  static const Color success = Color(0xFF10B981);

  /// Warning - Amber
  static const Color warning = Color(0xFFF59E0B);

  /// Error - Rose
  static const Color error = Color(0xFFEF4444);

  /// Info - Blue
  static const Color info = Color(0xFF3B82F6);

  // ═══════════════════════════════════════════════════════
  // KARAR RENKLERİ (Vantag Decision)
  // ═══════════════════════════════════════════════════════

  /// Aldım/Harcandı - Soft red
  static const Color decisionYes = Color(0xFFF87171);

  /// Düşünüyorum - Amber
  static const Color decisionThinking = Color(0xFFFBBF24);

  /// Vazgeçtim/Kurtarılan - Cyan (pozitif!)
  static const Color decisionNo = Color(0xFF06B6D4);

  // ═══════════════════════════════════════════════════════
  // GLASS EFFECTS (Liquid Glass)
  // ═══════════════════════════════════════════════════════

  /// Glass background - 8% white
  static const Color glassWhite = Color(0x15FFFFFF);

  /// Glass border - 12% white
  static const Color glassBorder = Color(0x20FFFFFF);

  /// Glass highlight - 19% white
  static const Color glassHighlight = Color(0x30FFFFFF);

  /// Kart arka plan (glass effect)
  static const Color cardBackgroundGlass = Color(0x0AFFFFFF);

  /// Kart border
  static const Color cardBorder = Color(0x15FFFFFF);

  /// Kart gölge
  static const Color cardShadow = Color(0x40000000);

  // ═══════════════════════════════════════════════════════════════
  // CHART PALETTE - 8 colors for pie/bar charts
  // ═══════════════════════════════════════════════════════════════
  static const List<Color> chartPalette = [
    Color(0xFF6C63FF), // Purple (primary)
    Color(0xFF4ECDC4), // Teal (secondary)
    Color(0xFFFF6B6B), // Coral
    Color(0xFFFFD93D), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFF38181), // Salmon
    Color(0xFFAA96DA), // Lavender
    Color(0xFF3D5A80), // Navy
  ];

  // ═══════════════════════════════════════════════════════════════
  // CATEGORY COLORS - For expense categories
  // ═══════════════════════════════════════════════════════════════
  static const Color categoryFood = Color(0xFFFF6B6B);
  static const Color categoryTransport = Color(0xFF4ECDC4);
  static const Color categoryShopping = Color(0xFF9B59B6);
  static const Color categoryEntertainment = Color(0xFF3498DB);
  static const Color categoryBills = Color(0xFFE74C3C);
  static const Color categoryHealth = Color(0xFF2ECC71);
  static const Color categoryEducation = Color(0xFFF39C12);
  static const Color categoryOther = Color(0xFF95A5A6);
  static const Color categoryDefault = Color(0xFF78909C);

  // ═══════════════════════════════════════════════════════════════
  // ACHIEVEMENT COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color achievementStreak = Color(0xFFFF6B35); // Orange flame
  static const Color achievementSavings = Color(0xFF2ECC71); // Green money
  static const Color achievementGoals = Color(0xFF9B59B6); // Purple target
  static const Color achievementTracker = Color(0xFF3498DB); // Blue notepad
  static const Color achievementMystery = Color(0xFFE91E63); // Pink mystery

  // ═══════════════════════════════════════════════════════════════
  // INCOME TYPE COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color incomeSalary = Color(0xFF6C63FF);
  static const Color incomeBonus = Color(0xFFFFD700);
  static const Color incomeFreelance = Color(0xFFE91E63);
  static const Color incomePassive = Color(0xFF4CAF50);
  static const Color incomeRental = Color(0xFF4ECDC4);
  static const Color incomeSideJob = Color(0xFFF39C12);
  static const Color incomeOther = Color(0xFF2ECC71);
  static const Color incomeDefault = Color(0xFF95A5A6);

  // ═══════════════════════════════════════════════════════════════
  // SOCIAL BRAND COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color instagram = Color(0xFFE4405F);
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color tiktok = Color(0xFF000000);
  static const Color snapchat = Color(0xFFFFFC00);
  static const Color youtube = Color(0xFFFF0000);

  // ═══════════════════════════════════════════════════════════════
  // MEDAL COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color medalBronze = Color(0xFFCD7F32);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalGold = Color(0xFFFFD700);
  static const Color medalPlatinum = Color(0xFFE5E4E2);

  // ═══════════════════════════════════════════════════════════════
  // SUBSCRIPTION COLORS - 8 predefined colors
  // ═══════════════════════════════════════════════════════════════
  static const List<Color> subscriptionColors = [
    Color(0xFFFF6B6B), // 0: Red
    Color(0xFF4ECDC4), // 1: Turquoise
    Color(0xFF6C63FF), // 2: Purple
    Color(0xFFFFD93D), // 3: Yellow
    Color(0xFFFF8C42), // 4: Orange
    Color(0xFF95E1D3), // 5: Mint
    Color(0xFFF38181), // 6: Pink
    Color(0xFF3D5A80), // 7: Navy
  ];

  // ═══════════════════════════════════════════════════════════════
  // CURRENCY & FINANCIAL COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color currencyPositive = Color(0xFF4CAF50);
  static const Color currencyNegative = Color(0xFFE74C3C);
  static const Color currencyNeutral = Color(0xFF2196F3);
  static const Color currencyGold = Color(0xFFFFB800);

  // ═══════════════════════════════════════════════════════════════
  // HEATMAP COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color heatmapNone = Color(0xFF1E1E2E);
  static const Color heatmapLow = Color(0xFF2D5016);
  static const Color heatmapMedium = Color(0xFF3D7017);
  static const Color heatmapHigh = Color(0xFF4CAF50);

  // ═══════════════════════════════════════════════════════════════
  // PREMIUM THEME COLORS (for paywall, etc.)
  // ═══════════════════════════════════════════════════════════════
  static const Color premiumPurple = Color(0xFF8B5CF6);
  static const Color premiumPurpleLight = Color(0xFFA78BFA);
  static const Color premiumPurpleDark = Color(0xFF6D28D9);
  static const Color premiumCyan = Color(0xFF06B6D4);
  static const Color premiumGreen = Color(0xFF00C853);

  // ═══════════════════════════════════════════════════════════════
  // MISC UI COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color divider = Color(0xFF2D2440);
  static const Color shimmer = Color(0xFF2D2440);
  static const Color overlay = Color(0x80000000);

  // ═══════════════════════════════════════════════════════════════
  // ADDITIONAL UI COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color urgentOrange = Color(0xFFFF8C42);
  static const Color dangerRed = Color(0xFFB71C1C);
  static const Color dangerRedDark = Color(0xFFC0392B);
  static const Color dangerGradientStart = Color(0xFF4A1C1C);
  static const Color dangerGradientEnd = Color(0xFF2D1010);
  static const Color orange = Color(0xFFFFA500);
  static const Color coffeeColor = Color(0xFF8B4513);
  static const Color smokingGray = Color(0xFF607D8B);

  // ═══════════════════════════════════════════════════════════════
  // ADDITIONAL CATEGORY COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color categorySportsGreen = Color(0xFF8BC34A);
  static const Color categoryDigitalCyan = Color(0xFF00BCD4);
  static const Color categoryShoppingPink = Color(0xFFE91E63);
  static const Color categoryCommGray = Color(0xFF607D8B);

  // ═══════════════════════════════════════════════════════════════
  // ACHIEVEMENT ICON COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color achievementYellow = Color(0xFFFBBF24);
  static const Color achievementOrange = Color(0xFFF97316);
  static const Color achievementSkyBlue = Color(0xFF8ED1FC);
  static const Color achievementLavender = Color(0xFFB4A7D6);
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
    colors: [AppColors.primary, AppColors.secondary],
  );

  /// Progress bar gradienti
  static const LinearGradient progress = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
  );

  /// Success gradienti
  static const LinearGradient success = LinearGradient(
    colors: [AppColors.secondary, Color(0xFF3DBDB5)],
  );

  /// Premium Card Gradient (mor → mavi)
  static const LinearGradient premiumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2A2545), // Koyu mor
      Color(0xFF1E293B), // Koyu mavi
    ],
  );

  /// Premium Card Gradient Light variant
  static const LinearGradient premiumCardLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3D3560), // Orta mor
      Color(0xFF2D3A50), // Orta mavi
    ],
  );

  /// Subtle card overlay gradient
  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x10FFFFFF), // %6 beyaz
      Color(0x00FFFFFF), // Şeffaf
    ],
  );

  /// Expense card gradient
  static const LinearGradient expenseCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF252540), // Mor-gri
      Color(0xFF1A1A2E), // Koyu
    ],
  );

  /// Primary gradient alias (same as primaryButton)
  static const LinearGradient primary = primaryButton;

  /// Error gradient
  static const LinearGradient error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.error, Color(0xFFFF6B81)],
  );

  /// Warning gradient
  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.warning, Color(0xFFFF9500)],
  );

  /// Card gradient (glassmorphism)
  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x0DFFFFFF), Color(0x05FFFFFF)],
  );
}

/// Premium Design Tokens (Revolut Style)
class AppDesign {
  AppDesign._();

  // Border Radius (8pt Grid)
  static const double radiusSmall = 8.0; // Küçük butonlar, chips
  static const double radiusMedium = 12.0; // Input fields, küçük kartlar
  static const double radiusLarge = 16.0; // Normal kartlar
  static const double radiusXLarge = 20.0; // Büyük kartlar
  static const double radiusXXLarge = 24.0; // Modal, bottom sheet
  static const double radiusFull = 999.0; // Pill shape

  // Spacing (8pt Grid System)
  static const double spacing4 = 4.0; // Micro
  static const double spacingXs = 8.0; // Small
  static const double spacingSm = 12.0; // Medium-small
  static const double spacingMd = 16.0; // Medium (default card padding)
  static const double spacingLg = 20.0; // Medium-large
  static const double spacingXl = 24.0; // Large
  static const double spacingXxl = 32.0; // XL
  static const double spacing48 = 48.0; // XXL

  // Screen & Card Padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20);

  // Transaction Item Dimensions
  static const double iconContainerSize = 44.0;
  static const double iconContainerRadius = 14.0;
  static const double iconSize = 22.0;

  // Subtle Shadow (kartlar için - Revolut style)
  static List<BoxShadow> get shadowSubtle => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  // Medium Shadow (elevated cards - soft)
  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // Card Shadow (premium cards)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  // Premium Card Shadow (with purple glow)
  static List<BoxShadow> get premiumCardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  // ========== CARD DECORATIONS ==========

  /// Standard card border
  static Border get cardBorder => Border.all(
        color: Colors.white.withValues(alpha: 0.06),
        width: 1,
      );

  /// Small card decoration (borderRadius: 16)
  static BoxDecoration cardDecorationSmall(Color surfaceColor) => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: cardBorder,
        boxShadow: shadowMedium,
      );

  /// Large card decoration (borderRadius: 20)
  static BoxDecoration cardDecorationLarge(Color surfaceColor) => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: cardBorder,
        boxShadow: shadowMedium,
      );

  // Primary Glow Effect
  static List<BoxShadow> primaryGlow(Color primary) => [
        BoxShadow(
          color: primary.withValues(alpha: 0.25),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ];

  // Primary Button Shadow (for elevated buttons)
  static List<BoxShadow> primaryButtonShadow(Color primary) => [
        BoxShadow(
          color: primary.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // Typography (Revolut Style)
  static const double fontSizeCaption = 12.0;
  static const double fontSizeBody = 15.0;
  static const double fontSizeSectionTitle = 13.0;
  static const double fontSizeTitle = 16.0;
  static const double fontSizeHeadline = 24.0;
  static const double fontSizeLargeNumber = 48.0;

  // Legacy support
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeXxl = 28.0;
  static const double fontSizeDisplay = 32.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);

  // Standard Curve
  static const Curve animationCurve = Curves.easeOutCubic;

  // ========== MODAL/SHEET STYLING ==========

  /// Sheet border radius
  static const double sheetBorderRadius = 24.0;

  /// Sheet handle bar dimensions
  static const double handleBarWidth = 40.0;
  static const double handleBarHeight = 4.0;
  static const double handleBarRadius = 2.0;

  /// Standard sheet decoration
  static BoxDecoration sheetDecoration(Color surfaceColor) => BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      );

  /// Standard handle bar decoration
  static BoxDecoration handleBarDecoration(Color textTertiaryColor) =>
      BoxDecoration(
        color: textTertiaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      );
}

/// Premium Font Families - iOS HIG Compliant
/// Uses system fonts (SF Pro on iOS, Roboto on Android)
class AppFonts {
  AppFonts._();

  /// System font for headings (SF Pro Display on iOS)
  static String? get heading => null; // Uses system default

  /// System font for body text (SF Pro Text on iOS)
  static String? get body => null; // Uses system default

  /// System monospace font (Menlo on iOS, Roboto Mono on Android)
  static String get mono => Platform.isIOS ? 'Menlo' : 'Roboto Mono';

  /// Font fallback list for Turkish character support
  /// These system fonts are used when characters (ı, ğ, ü, ş, ö, ç, İ) are missing
  static const List<String> fontFallback = [
    'SF Pro Display', // iOS
    'Roboto', // Android
    'Segoe UI', // Windows
    'Apple Color Emoji', // Emoji support
    'Noto Sans', // Universal fallback
  ];

  /// Create TextStyle with Turkish character fallback
  static TextStyle withFallback(TextStyle style) {
    return style.copyWith(fontFamilyFallback: fontFallback);
  }

  /// Apply font fallback to entire TextTheme
  static TextTheme applyFallbackToTextTheme(TextTheme textTheme) {
    return TextTheme(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      displayMedium: textTheme.displayMedium?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontFamilyFallback: fontFallback,
      ),
    );
  }
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
        iconTheme: IconThemeData(color: AppColorsLight.textPrimary, size: 24),
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
          side: const BorderSide(color: AppColorsLight.cardBorder, width: 1),
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
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
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
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
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
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.5,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 15),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic));

    // Secondary animation for existing page (slight fade)
    final secondaryFade = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOutCubic),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(opacity: secondaryFade, child: child),
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

// ═══════════════════════════════════════════════════════════════════════════
// THEME-AWARE COLOR HELPER
// ═══════════════════════════════════════════════════════════════════════════

/// Extension to get theme-aware colors from BuildContext
/// Usage: context.appColors.background, context.appColors.textPrimary, etc.
extension AppColorsExtension on BuildContext {
  /// Get colors based on current theme (dark/light)
  _ThemeColors get appColors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return _ThemeColors(isDark);
  }

  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

/// Theme-aware color container
class _ThemeColors {
  final bool _isDark;
  const _ThemeColors(this._isDark);

  // Backgrounds
  Color get background =>
      _isDark ? AppColors.background : AppColorsLight.background;
  Color get cardBackground =>
      _isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;
  Color get surfaceElevated =>
      _isDark ? AppColors.surfaceElevated : AppColorsLight.surfaceElevated;
  Color get surface => _isDark ? AppColors.surface : AppColorsLight.surface;
  Color get surfaceLight =>
      _isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight;
  Color get surfaceLighter =>
      _isDark ? AppColors.surfaceLighter : AppColorsLight.surfaceLighter;

  // Gradient colors
  Color get gradientStart =>
      _isDark ? AppColors.gradientStart : AppColorsLight.gradientStart;
  Color get gradientMid =>
      _isDark ? AppColors.gradientMid : AppColorsLight.gradientMid;
  Color get gradientEnd =>
      _isDark ? AppColors.gradientEnd : AppColorsLight.gradientEnd;

  // Primary colors (same in both themes)
  Color get primary => AppColors.primary;
  Color get primaryDark => AppColors.primaryDark;
  Color get primaryLight => AppColors.primaryLight;
  Color get secondary => AppColors.secondary;
  Color get accent => AppColors.accent;
  Color get gold => AppColors.gold;

  // Text colors
  Color get textPrimary =>
      _isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
  Color get textSecondary =>
      _isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
  Color get textTertiary =>
      _isDark ? AppColors.textTertiary : AppColorsLight.textTertiary;

  // Status colors
  Color get success => _isDark ? AppColors.success : AppColorsLight.success;
  Color get warning => _isDark ? AppColors.warning : AppColorsLight.warning;
  Color get error => _isDark ? AppColors.error : AppColorsLight.error;
  Color get info => _isDark ? AppColors.info : AppColorsLight.info;

  // Decision colors
  Color get decisionYes =>
      _isDark ? AppColors.decisionYes : AppColorsLight.decisionYes;
  Color get decisionThinking =>
      _isDark ? AppColors.decisionThinking : AppColorsLight.decisionThinking;
  Color get decisionNo =>
      _isDark ? AppColors.decisionNo : AppColorsLight.decisionNo;

  // Card colors
  Color get cardBackgroundGlass => _isDark
      ? AppColors.cardBackgroundGlass
      : AppColorsLight.cardBackgroundGlass;
  Color get cardBorder =>
      _isDark ? AppColors.cardBorder : AppColorsLight.cardBorder;
  Color get cardShadow =>
      _isDark ? AppColors.cardShadow : AppColorsLight.cardShadow;

  // Background gradient
  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMid, gradientEnd],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// LIGHT MODE COLORS
// ═══════════════════════════════════════════════════════════════════════════

/// Light Mode Color Palette - iOS 26 Liquid Glass Premium White
class AppColorsLight {
  AppColorsLight._();

  // ─────────────────────────────────────────────────────────────────
  // BACKGROUNDS (Premium White)
  // ─────────────────────────────────────────────────────────────────

  /// Main background
  static const Color background = Color(0xFFF8FAFC);

  /// Card background - Pure white
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Elevated surface
  static const Color surfaceElevated = Color(0xFFF1F5F9);

  /// Gradient colors
  static const Color gradientStart = Color(0xFFF8FAFC);
  static const Color gradientMid = Color(0xFFFFFFFF);
  static const Color gradientEnd = Color(0xFFF1F5F9);

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color surfaceLighter = Color(0xFFE2E8F0);

  // ─────────────────────────────────────────────────────────────────
  // PRIMARY COLORS (Same purple for consistency)
  // ─────────────────────────────────────────────────────────────────

  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFC4B5FD);

  /// Secondary - Cyan
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color secondaryLight = Color(0xFF22D3EE);

  /// Accent - Gold
  static const Color accent = Color(0xFFF59E0B);
  static const Color gold = Color(0xFFF59E0B);

  // ─────────────────────────────────────────────────────────────────
  // TEXT COLORS
  // ─────────────────────────────────────────────────────────────────

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  // ─────────────────────────────────────────────────────────────────
  // STATUS COLORS
  // ─────────────────────────────────────────────────────────────────

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─────────────────────────────────────────────────────────────────
  // DECISION COLORS
  // ─────────────────────────────────────────────────────────────────

  static const Color decisionYes = Color(0xFFF87171);
  static const Color decisionThinking = Color(0xFFFBBF24);
  static const Color decisionNo = Color(0xFF06B6D4);

  // ─────────────────────────────────────────────────────────────────
  // GLASS EFFECTS (for light mode)
  // ─────────────────────────────────────────────────────────────────

  static const Color glassBlack = Color(0x08000000);
  static const Color glassBorder = Color(0x15000000);
  static const Color cardBackgroundGlass = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardShadow = Color(0x15000000);
}
