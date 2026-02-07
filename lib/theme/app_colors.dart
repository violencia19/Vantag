import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// VANTAG UNIFIED COLOR SYSTEM v2.0
// Single source of truth for all design tokens
// Access: context.vantColors.xxx (theme-aware) or VantColors.xxx (static)
// ═══════════════════════════════════════════════════════════════════════════

/// Dark mode color tokens
class VantColors {
  VantColors._();

  // ── Brand ──
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primarySubtle = Color(0x148B5CF6); // 8%
  static const Color primaryMuted = Color(0x268B5CF6);  // 15%

  static const Color secondary = Color(0xFF22D3EE);
  static const Color secondaryDark = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF67E8F9);
  static const Color secondarySubtle = Color(0x1422D3EE); // 8%

  static const Color accent = Color(0xFFF59E0B);
  static const Color gold = Color(0xFFF59E0B);

  // ── Surface (4-tier elevation ladder) ──
  static const Color background = Color(0xFF050508);
  static const Color surface = Color(0xFF0F0D17);           // Tier 1
  static const Color surfaceElevated = Color(0xFF1A1726);    // Tier 2
  static const Color surfaceOverlay = Color(0xFF252233);     // Tier 3
  static const Color surfaceInput = Color(0xFF18151F);       // Tier 2.5
  static const Color cardBackground = Color(0xFF12101A);
  static const Color surfaceLight = Color(0xFF1A1725);       // Legacy alias
  static const Color surfaceLighter = Color(0xFF231F2E);     // Legacy alias

  // ── Gradients ──
  static const Color gradientStart = Color(0xFF0A0A0F);
  static const Color gradientMid = Color(0xFF12101A);
  static const Color gradientEnd = Color(0xFF1A1725);

  // ── Text ──
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);
  static const Color textMuted = Color(0xFF52525B);
  static const Color textDisabled = Color(0xFF3F3F46);

  // ── Status ──
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successSubtle = Color(0x1410B981);  // 8%
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningSubtle = Color(0x14F59E0B);  // 8%
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorSubtle = Color(0x14EF4444);    // 8%
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoSubtle = Color(0x143B82F6);     // 8%

  // ── Decision (Psychology-driven) ──
  static const Color decisionYes = Color(0xFFF87171);       // Bought - soft red
  static const Color decisionThinking = Color(0xFFFBBF24);  // Thinking - amber
  static const Color decisionNo = Color(0xFF22D3EE);        // Passed - cyan (reward!)

  // ── Glass ──
  static const Color glassWhite = Color(0x15FFFFFF);        // 8%
  static const Color glassBorder = Color(0x20FFFFFF);       // 12%
  static const Color glassHighlight = Color(0x30FFFFFF);    // 19%
  static const Color cardBackgroundGlass = Color(0x0AFFFFFF); // 4%
  static const Color cardBorder = Color(0x15FFFFFF);        // 8%
  static const Color cardShadow = Color(0x40000000);        // 25%

  // ── Categories ──
  static const Color categoryFood = Color(0xFFFF6B6B);
  static const Color categoryTransport = Color(0xFF4ECDC4);
  static const Color categoryShopping = Color(0xFF9B59B6);
  static const Color categoryEntertainment = Color(0xFF3498DB);
  static const Color categoryBills = Color(0xFFE74C3C);
  static const Color categoryHealth = Color(0xFF2ECC71);
  static const Color categoryEducation = Color(0xFFF39C12);
  static const Color categorySports = Color(0xFF8BC34A);
  static const Color categoryDigital = Color(0xFF00BCD4);
  static const Color categoryShoppingPink = Color(0xFFE91E63);
  static const Color categoryComm = Color(0xFF607D8B);
  static const Color categoryOther = Color(0xFF95A5A6);
  static const Color categoryDefault = Color(0xFF78909C);

  // ── Achievements ──
  static const Color achievementStreak = Color(0xFFFF6B35);
  static const Color achievementSavings = Color(0xFF2ECC71);
  static const Color achievementGoals = Color(0xFF9B59B6);
  static const Color achievementTracker = Color(0xFF3498DB);
  static const Color achievementMystery = Color(0xFFE91E63);
  static const Color achievementYellow = Color(0xFFFBBF24);
  static const Color achievementOrange = Color(0xFFF97316);
  static const Color achievementSkyBlue = Color(0xFF8ED1FC);
  static const Color achievementLavender = Color(0xFFB4A7D6);

  // ── Medals ──
  static const Color medalBronze = Color(0xFFCD7F32);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalGold = Color(0xFFFFD700);
  static const Color medalPlatinum = Color(0xFFE5E4E2);

  // ── Social ──
  static const Color instagram = Color(0xFFE4405F);
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color tiktok = Color(0xFF000000);
  static const Color snapchat = Color(0xFFFFFC00);
  static const Color youtube = Color(0xFFFF0000);

  // ── Currency ──
  static const Color currencyPositive = Color(0xFF4CAF50);
  static const Color currencyNegative = Color(0xFFE74C3C);
  static const Color currencyNeutral = Color(0xFF2196F3);
  static const Color currencyGold = Color(0xFFFFB800);

  // ── Income Types ──
  static const Color incomeSalary = Color(0xFF6C63FF);
  static const Color incomeBonus = Color(0xFFFFD700);
  static const Color incomeFreelance = Color(0xFFE91E63);
  static const Color incomePassive = Color(0xFF4CAF50);
  static const Color incomeRental = Color(0xFF4ECDC4);
  static const Color incomeSideJob = Color(0xFFF39C12);
  static const Color incomeOther = Color(0xFF2ECC71);
  static const Color incomeDefault = Color(0xFF95A5A6);

  // ── Heatmap ──
  static const Color heatmapNone = Color(0xFF1E1E2E);
  static const Color heatmapLow = Color(0xFF2D5016);
  static const Color heatmapMedium = Color(0xFF3D7017);
  static const Color heatmapHigh = Color(0xFF4CAF50);

  // ── Chart Palettes ──
  static const List<Color> chartPalette = [
    Color(0xFF6C63FF),
    Color(0xFF4ECDC4),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFFAA96DA),
    Color(0xFF3D5A80),
  ];

  static const List<Color> subscriptionColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF6C63FF),
    Color(0xFFFFD93D),
    Color(0xFFFF8C42),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFF3D5A80),
  ];

  // ── Misc UI ──
  static const Color divider = Color(0xFF2D2440);
  static const Color shimmer = Color(0xFF2D2440);
  static const Color overlay = Color(0x80000000);        // 50%
  static const Color urgentOrange = Color(0xFFFF8C42);
  static const Color dangerRed = Color(0xFFB71C1C);
  static const Color dangerRedDark = Color(0xFFC0392B);
  static const Color dangerGradientStart = Color(0xFF4A1C1C);
  static const Color dangerGradientEnd = Color(0xFF2D1010);
  static const Color coffeeColor = Color(0xFF8B4513);
  static const Color smokingGray = Color(0xFF607D8B);
  static const Color premiumPurple = Color(0xFF8B5CF6);
  static const Color premiumPurpleLight = Color(0xFFA78BFA);
  static const Color premiumPurpleDark = Color(0xFF6D28D9);
  static const Color premiumCyan = Color(0xFF22D3EE);
  static const Color premiumGreen = Color(0xFF00C853);
  static const Color orange = Color(0xFFFFA500);
}

/// Light mode color tokens
class VantColorsLight {
  VantColorsLight._();

  // ── Surface ──
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF1F5F9);
  static const Color surfaceOverlay = Color(0xFFE2E8F0);
  static const Color surfaceInput = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color surfaceLighter = Color(0xFFE2E8F0);

  // ── Gradients ──
  static const Color gradientStart = Color(0xFFF8FAFC);
  static const Color gradientMid = Color(0xFFF1F5F9);
  static const Color gradientEnd = Color(0xFFE2E8F0);

  // ── Text ──
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFFCBD5E1);

  // ── Status ──
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Decision ──
  static const Color decisionYes = Color(0xFFF87171);
  static const Color decisionThinking = Color(0xFFFBBF24);
  static const Color decisionNo = Color(0xFF22D3EE);

  // ── Glass (light mode inverted) ──
  static const Color glassBlack = Color(0x08000000);       // 3%
  static const Color glassBorder = Color(0x15000000);      // 8%
  static const Color cardBackgroundGlass = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardShadow = Color(0x15000000);       // 8%
}

// ═══════════════════════════════════════════════════════════════════════════
// GRADIENTS
// ═══════════════════════════════════════════════════════════════════════════

class VantGradients {
  VantGradients._();

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A0A0F),
      Color(0xFF12101A),
      Color(0xFF1A1725),
    ],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  );

  static const LinearGradient progress = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  );

  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );

  static const LinearGradient error = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFFF6B81)],
  );

  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFF9500)],
  );

  static const LinearGradient premiumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A2545), Color(0xFF1E293B)],
  );

  static const LinearGradient premiumCardLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D3560), Color(0xFF2D3A50)],
  );

  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x10FFFFFF), Color(0x00FFFFFF)],
  );

  static const LinearGradient expenseCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF252540), Color(0xFF1A1A2E)],
  );

  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1FFFFFFF), Color(0x0DFFFFFF)],
  );

  static const LinearGradient glassHighlight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x14FFFFFF), Colors.transparent],
  );

  static const LinearGradient luminance = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Colors.transparent],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// THEME-AWARE EXTENSION
// ═══════════════════════════════════════════════════════════════════════════

/// Access via: context.vantColors.primary, context.vantColors.background, etc.
extension VantColorsExtension on BuildContext {
  _VantThemeColors get vantColors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return _VantThemeColors(isDark);
  }

  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

class _VantThemeColors {
  final bool _isDark;
  const _VantThemeColors(this._isDark);

  // ── Brand (same both themes) ──
  Color get primary => VantColors.primary;
  Color get primaryDark => VantColors.primaryDark;
  Color get primaryLight => VantColors.primaryLight;
  Color get primarySubtle => VantColors.primarySubtle;
  Color get primaryMuted => VantColors.primaryMuted;
  Color get secondary => VantColors.secondary;
  Color get secondaryDark => VantColors.secondaryDark;
  Color get secondaryLight => VantColors.secondaryLight;
  Color get secondarySubtle => VantColors.secondarySubtle;
  Color get accent => VantColors.accent;
  Color get gold => VantColors.gold;

  // ── Surface ──
  Color get background => _isDark ? VantColors.background : VantColorsLight.background;
  Color get surface => _isDark ? VantColors.surface : VantColorsLight.surface;
  Color get surfaceElevated => _isDark ? VantColors.surfaceElevated : VantColorsLight.surfaceElevated;
  Color get surfaceOverlay => _isDark ? VantColors.surfaceOverlay : VantColorsLight.surfaceOverlay;
  Color get surfaceInput => _isDark ? VantColors.surfaceInput : VantColorsLight.surfaceInput;
  Color get cardBackground => _isDark ? VantColors.cardBackground : VantColorsLight.cardBackground;
  Color get surfaceLight => _isDark ? VantColors.surfaceLight : VantColorsLight.surfaceLight;
  Color get surfaceLighter => _isDark ? VantColors.surfaceLighter : VantColorsLight.surfaceLighter;

  // ── Gradients ──
  Color get gradientStart => _isDark ? VantColors.gradientStart : VantColorsLight.gradientStart;
  Color get gradientMid => _isDark ? VantColors.gradientMid : VantColorsLight.gradientMid;
  Color get gradientEnd => _isDark ? VantColors.gradientEnd : VantColorsLight.gradientEnd;

  // ── Text ──
  Color get textPrimary => _isDark ? VantColors.textPrimary : VantColorsLight.textPrimary;
  Color get textSecondary => _isDark ? VantColors.textSecondary : VantColorsLight.textSecondary;
  Color get textTertiary => _isDark ? VantColors.textTertiary : VantColorsLight.textTertiary;
  Color get textMuted => _isDark ? VantColors.textMuted : VantColorsLight.textMuted;

  // ── Status ──
  Color get success => _isDark ? VantColors.success : VantColorsLight.success;
  Color get warning => _isDark ? VantColors.warning : VantColorsLight.warning;
  Color get error => _isDark ? VantColors.error : VantColorsLight.error;
  Color get info => _isDark ? VantColors.info : VantColorsLight.info;
  Color get successLight => VantColors.successLight;
  Color get warningLight => VantColors.warningLight;
  Color get errorLight => VantColors.errorLight;
  Color get infoLight => VantColors.infoLight;
  Color get successSubtle => VantColors.successSubtle;
  Color get warningSubtle => VantColors.warningSubtle;
  Color get errorSubtle => VantColors.errorSubtle;
  Color get infoSubtle => VantColors.infoSubtle;

  // ── Decision ──
  Color get decisionYes => _isDark ? VantColors.decisionYes : VantColorsLight.decisionYes;
  Color get decisionThinking => _isDark ? VantColors.decisionThinking : VantColorsLight.decisionThinking;
  Color get decisionNo => _isDark ? VantColors.decisionNo : VantColorsLight.decisionNo;

  // ── Glass ──
  Color get cardBackgroundGlass => _isDark ? VantColors.cardBackgroundGlass : VantColorsLight.cardBackgroundGlass;
  Color get cardBorder => _isDark ? VantColors.cardBorder : VantColorsLight.cardBorder;
  Color get cardShadow => _isDark ? VantColors.cardShadow : VantColorsLight.cardShadow;

  // ── Misc ──
  Color get divider => VantColors.divider;
  Color get shimmer => VantColors.shimmer;
  Color get overlay => VantColors.overlay;
}
