import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VANTAG PSYCHOLOGY-BASED DESIGN SYSTEM 2026
/// Apple Liquid Glass + Color Psychology + Gamification
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// COLOR PSYCHOLOGY SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

/// Psychology-based color palette optimized for fintech
/// Each color is chosen based on psychological research
class PsychologyColors {
  PsychologyColors._();

  // ─────────────────────────────────────────────────────────────────────────
  // BACKGROUNDS - OLED optimized deep dark
  // Creates depth and premium feel, reduces eye strain
  // ─────────────────────────────────────────────────────────────────────────

  /// Ana arka plan - Ultra deep for OLED power saving
  static const Color background = Color(0xFF050508);

  /// Kart yüzeyi - Slight elevation
  static const Color surface = Color(0xFF0C0A12);

  /// Yükseltilmiş yüzey - Cards, elevated content
  static const Color surfaceElevated = Color(0xFF14111D);

  /// Overlay yüzey - Modals, sheets, popovers
  static const Color surfaceOverlay = Color(0xFF1C1828);

  /// Input alanları - Subtle distinction
  static const Color surfaceInput = Color(0xFF18151F);

  // ─────────────────────────────────────────────────────────────────────────
  // PRIMARY - Purple (Premium, Wisdom, Wealth)
  // Purple triggers feelings of luxury, wisdom, and financial success
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary brand color
  static const Color primary = Color(0xFF8B5CF6);

  /// Primary light variant - Hover states
  static const Color primaryLight = Color(0xFFA78BFA);

  /// Primary dark variant - Pressed states
  static const Color primaryDark = Color(0xFF7C3AED);

  /// Primary subtle - 8% opacity for backgrounds
  static const Color primarySubtle = Color(0x148B5CF6);

  /// Primary muted - 15% opacity
  static const Color primaryMuted = Color(0x268B5CF6);

  // ─────────────────────────────────────────────────────────────────────────
  // SECONDARY - Cyan (Fresh, Trust, Savings = Positive!)
  // Cyan represents freshness, trust, and positive savings
  // ─────────────────────────────────────────────────────────────────────────

  /// Secondary brand color
  static const Color secondary = Color(0xFF06B6D4);

  /// Secondary light variant
  static const Color secondaryLight = Color(0xFF22D3EE);

  /// Secondary dark variant
  static const Color secondaryDark = Color(0xFF0891B2);

  /// Secondary subtle
  static const Color secondarySubtle = Color(0x1406B6D4);

  // ─────────────────────────────────────────────────────────────────────────
  // SEMANTIC STATES
  // Standard semantic colors with psychological undertones
  // ─────────────────────────────────────────────────────────────────────────

  /// Success - Emerald green (growth, prosperity)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successSubtle = Color(0x1410B981);

  /// Warning - Amber (caution, attention)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningSubtle = Color(0x14F59E0B);

  /// Error - Rose red (urgency, importance)
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorSubtle = Color(0x14EF4444);

  /// Info - Blue (trust, stability)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoSubtle = Color(0x143B82F6);

  // ─────────────────────────────────────────────────────────────────────────
  // DECISION COLORS (Vantag specific)
  // Psychology: Make "Passed" feel positive (savings!)
  // ─────────────────────────────────────────────────────────────────────────

  /// Aldım - Soft rose (purchased, spent)
  static const Color decisionYes = Color(0xFFF87171);

  /// Düşünüyorum - Amber (contemplating)
  static const Color decisionThinking = Color(0xFFFBBF24);

  /// Vazgeçtim - CYAN (positive! money saved!)
  static const Color decisionNo = Color(0xFF06B6D4);

  // ─────────────────────────────────────────────────────────────────────────
  // BUDGET THRESHOLDS (Traffic light psychology)
  // Gradual color change triggers appropriate emotional response
  // ─────────────────────────────────────────────────────────────────────────

  /// 0-50% - Safe zone (green = go, prosperity)
  static const Color budgetSafe = Color(0xFF10B981);

  /// 50-70% - Caution zone (amber = slow down)
  static const Color budgetCaution = Color(0xFFF59E0B);

  /// 70-90% - Warning zone (orange = alert)
  static const Color budgetWarning = Color(0xFFEA580C);

  /// 90%+ - Danger zone (red = stop)
  static const Color budgetDanger = Color(0xFFEF4444);

  /// Dynamic budget color based on percentage
  static Color getBudgetColor(double percentage) {
    if (percentage < 50) return budgetSafe;
    if (percentage < 70) return budgetCaution;
    if (percentage < 90) return budgetWarning;
    return budgetDanger;
  }

  /// Get budget status text
  static String getBudgetStatus(double percentage) {
    if (percentage < 50) return 'Güvenli Bölge';
    if (percentage < 70) return 'Dikkatli Ol';
    if (percentage < 90) return 'Uyarı!';
    return 'Limit Aşıldı';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TEXT HIERARCHY
  // Clear hierarchy improves readability and comprehension
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary text - Full white
  static const Color textPrimary = Color(0xFFFAFAFA);

  /// Secondary text - 60% opacity
  static const Color textSecondary = Color(0xFFA1A1AA);

  /// Tertiary text - 45% opacity
  static const Color textTertiary = Color(0xFF71717A);

  /// Muted text - 30% opacity
  static const Color textMuted = Color(0xFF52525B);

  /// Disabled text
  static const Color textDisabled = Color(0xFF3F3F46);

  // ─────────────────────────────────────────────────────────────────────────
  // GLASS COLORS (Liquid Glass effect)
  // Creates depth and dimension while maintaining readability
  // ─────────────────────────────────────────────────────────────────────────

  /// Glass fill - 5% white
  static const Color glassFill = Color(0x0DFFFFFF);

  /// Glass border - 8% white
  static const Color glassBorder = Color(0x14FFFFFF);

  /// Glass highlight - 15% white (top edge reflection)
  static const Color glassHighlight = Color(0x26FFFFFF);

  /// Glass shadow
  static const Color glassShadow = Color(0x40000000);

  // ─────────────────────────────────────────────────────────────────────────
  // GAMIFICATION COLORS
  // Colors that trigger dopamine and engagement
  // ─────────────────────────────────────────────────────────────────────────

  /// Streak flame - Orange fire
  static const Color streakFlame = Color(0xFFFF6B35);

  /// Gold reward
  static const Color gold = Color(0xFFFFD700);

  /// Achievement purple
  static const Color achievement = Color(0xFF9333EA);

  /// Level up cyan
  static const Color levelUp = Color(0xFF22D3EE);

  // ─────────────────────────────────────────────────────────────────────────
  // GRADIENT PRESETS
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF059669)],
  );

  /// Background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surface],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// TYPOGRAPHY SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

/// Psychology-based typography for maximum readability and impact
class PsychologyTypography {
  PsychologyTypography._();

  // ─────────────────────────────────────────────────────────────────────────
  // DISPLAY - Hero numbers (financial data)
  // Large, bold numbers create impact and importance
  // ─────────────────────────────────────────────────────────────────────────

  /// Display large - 56px hero numbers
  static const TextStyle displayLarge = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    letterSpacing: -2.0,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
    color: PsychologyColors.textPrimary,
  );

  /// Display medium - 44px important numbers
  static const TextStyle displayMedium = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.1,
    fontFeatures: [FontFeature.tabularFigures()],
    color: PsychologyColors.textPrimary,
  );

  /// Display small - 32px secondary numbers
  static const TextStyle displaySmall = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.0,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
    color: PsychologyColors.textPrimary,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // HEADLINES - Section titles
  // ─────────────────────────────────────────────────────────────────────────

  /// Headline large - 28px
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: PsychologyColors.textPrimary,
  );

  /// Headline medium - 24px
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
    color: PsychologyColors.textPrimary,
  );

  /// Headline small - 20px
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: PsychologyColors.textPrimary,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // TITLE - Card titles, list headers
  // ─────────────────────────────────────────────────────────────────────────

  /// Title large - 18px
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: PsychologyColors.textPrimary,
  );

  /// Title medium - 16px
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: PsychologyColors.textPrimary,
  );

  /// Title small - 14px
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: PsychologyColors.textSecondary,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // BODY - Readable text
  // Line height 1.5 for optimal readability
  // ─────────────────────────────────────────────────────────────────────────

  /// Body large - 17px
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: PsychologyColors.textPrimary,
  );

  /// Body medium - 15px
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: PsychologyColors.textSecondary,
  );

  /// Body small - 13px
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: PsychologyColors.textSecondary,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // LABELS - Buttons, badges, chips
  // ─────────────────────────────────────────────────────────────────────────

  /// Label large - 15px
  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: PsychologyColors.textPrimary,
  );

  /// Label medium - 13px
  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: PsychologyColors.textSecondary,
  );

  /// Label small - 11px (uppercase for emphasis)
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
    color: PsychologyColors.textTertiary,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SPECIAL STYLES
  // ─────────────────────────────────────────────────────────────────────────

  /// Mono - For currency amounts
  static const TextStyle mono = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
    color: PsychologyColors.textPrimary,
  );

  /// Badge - Uppercase badge text
  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.0,
    color: PsychologyColors.textPrimary,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATION SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

/// Research-based animation timings for optimal UX
class PsychologyAnimations {
  PsychologyAnimations._();

  // ─────────────────────────────────────────────────────────────────────────
  // DURATIONS (research-based)
  // Timings based on UX research for perceived performance
  // ─────────────────────────────────────────────────────────────────────────

  /// Instant - Button press feedback (50ms)
  static const Duration instant = Duration(milliseconds: 50);

  /// Micro - Ultra-fast transitions (100ms)
  static const Duration micro = Duration(milliseconds: 100);

  /// Quick - State changes, micro-interactions (150ms)
  static const Duration quick = Duration(milliseconds: 150);

  /// Standard - Normal transitions (300ms)
  static const Duration standardDuration = Duration(milliseconds: 300);

  /// Emphasis - Important transitions (400ms)
  static const Duration emphasis = Duration(milliseconds: 400);

  /// Slow - Dramatic reveals (600ms)
  static const Duration slow = Duration(milliseconds: 600);

  /// Count up - Number animations (800ms)
  static const Duration countUp = Duration(milliseconds: 800);

  /// Page transition (350ms)
  static const Duration pageTransition = Duration(milliseconds: 350);

  /// Breathing cycle - Glow pulse (3000ms)
  static const Duration breathingCycle = Duration(milliseconds: 3000);

  /// Shimmer cycle (1500ms)
  static const Duration shimmerCycle = Duration(milliseconds: 1500);

  // ─────────────────────────────────────────────────────────────────────────
  // CURVES
  // Different curves for different emotional responses
  // ─────────────────────────────────────────────────────────────────────────

  /// Standard curve - General purpose
  static const Curve standardCurve = Curves.easeOutCubic;

  /// Decelerate - Coming to rest
  static const Curve decelerate = Curves.decelerate;

  /// Bounce - Playful feedback
  static const Curve bounce = Curves.elasticOut;

  /// Spring - Snappy return
  static const Curve spring = Curves.easeOutBack;

  /// Smooth - Breathing animations
  static const Curve smooth = Curves.easeInOut;

  /// Sharp - Quick micro-interactions
  static const Curve sharp = Curves.easeOutQuart;

  // ─────────────────────────────────────────────────────────────────────────
  // SCALE VALUES
  // Subtle scale changes for tactile feedback
  // ─────────────────────────────────────────────────────────────────────────

  /// Button press scale (96%)
  static const double buttonPressScale = 0.96;

  /// Card press scale (98%)
  static const double cardPressScale = 0.98;

  /// Emphasis scale (105%)
  static const double emphasisScale = 1.05;

  /// Celebration scale (115%)
  static const double celebrationScale = 1.15;

  /// Icon pulse min (90%)
  static const double pulseMin = 0.9;

  /// Icon pulse max (110%)
  static const double pulseMax = 1.1;

  // ─────────────────────────────────────────────────────────────────────────
  // GLOW INTENSITY VALUES
  // ─────────────────────────────────────────────────────────────────────────

  /// Glow min opacity
  static const double glowMin = 0.15;

  /// Glow max opacity
  static const double glowMax = 0.45;

  /// Subtle glow
  static const double glowSubtle = 0.1;

  /// Strong glow
  static const double glowStrong = 0.6;
}

// ═══════════════════════════════════════════════════════════════════════════
// SPACING SYSTEM (4px grid)
// ═══════════════════════════════════════════════════════════════════════════

/// Consistent spacing based on 4px grid
class PsychologySpacing {
  PsychologySpacing._();

  /// Extra small - 4px
  static const double xs = 4.0;

  /// Small - 8px
  static const double sm = 8.0;

  /// Medium - 12px
  static const double md = 12.0;

  /// Large - 16px
  static const double lg = 16.0;

  /// Extra large - 20px
  static const double xl = 20.0;

  /// XXL - 24px
  static const double xxl = 24.0;

  /// XXXL - 32px
  static const double xxxl = 32.0;

  /// Section spacing - 48px
  static const double section = 48.0;

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);

  /// Card padding compact
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(16.0);

  /// Screen horizontal padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20.0);

  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );

  /// Sheet padding - Bottom sheets and modals
  static const EdgeInsets sheetPadding = EdgeInsets.all(24.0);

  /// Sheet padding horizontal
  static const EdgeInsets sheetPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: 24.0,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// RADIUS SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

/// Consistent border radius values
class PsychologyRadius {
  PsychologyRadius._();

  /// Small - 8px (buttons, chips)
  static const double sm = 8.0;

  /// Medium - 12px (inputs, small cards)
  static const double md = 12.0;

  /// Large - 16px (cards)
  static const double lg = 16.0;

  /// Extra large - 20px (large cards)
  static const double xl = 20.0;

  /// XXL - 24px (hero cards)
  static const double xxl = 24.0;

  /// Sheet - 32px (bottom sheets, modals)
  static const double sheet = 32.0;

  /// Full - Pill shape
  static const double full = 999.0;

  /// Card border radius
  static const BorderRadius card = BorderRadius.all(Radius.circular(20.0));

  /// Button border radius
  static const BorderRadius button = BorderRadius.all(Radius.circular(14.0));

  /// Sheet border radius
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(32.0),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SHADOW SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

/// Psychology-based shadow system for depth and hierarchy
class PsychologyShadows {
  PsychologyShadows._();

  /// Subtle shadow - Minimal elevation
  static List<BoxShadow> subtle(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Medium shadow - Cards
  static List<BoxShadow> medium(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Strong shadow - Elevated elements
  static List<BoxShadow> strong(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.2),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Glow shadow - Breathing effect
  static List<BoxShadow> glow(Color color, {double intensity = 0.2, double blur = 24}) => [
    BoxShadow(
      color: color.withValues(alpha: intensity),
      blurRadius: blur,
      spreadRadius: -4,
    ),
  ];

  /// Double shadow - Depth + glow
  static List<BoxShadow> glowWithDepth(Color glowColor, {double intensity = 0.3}) => [
    // Glow layer
    BoxShadow(
      color: glowColor.withValues(alpha: intensity),
      blurRadius: 32,
      spreadRadius: -4,
    ),
    // Depth layer
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  /// Card shadow - Standard card elevation
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Icon halo - Subtle glow around icons
  static List<Shadow> iconHalo(Color color) => [
    Shadow(
      color: color.withValues(alpha: 0.4),
      blurRadius: 12,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// GLASS EFFECT SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

/// Liquid Glass effect parameters
class PsychologyGlass {
  PsychologyGlass._();

  /// Default blur sigma
  static const double blurSigma = 24.0;

  /// Hero card blur sigma
  static const double heroBlurSigma = 30.0;

  /// Light blur sigma (for smaller elements)
  static const double lightBlurSigma = 16.0;

  /// Heavy blur sigma (for prominent elements)
  static const double heavyBlurSigma = 40.0;

  /// Glass fill opacity
  static const double fillOpacity = 0.05;

  /// Glass border opacity
  static const double borderOpacity = 0.08;

  /// Glass highlight opacity
  static const double highlightOpacity = 0.15;

  /// Create glass decoration
  static BoxDecoration decoration({
    Color? glowColor,
    double glowIntensity = 0.2,
    double borderRadius = 20.0,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.04),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: borderOpacity),
        width: 1,
      ),
      boxShadow: glowColor != null
          ? PsychologyShadows.glow(glowColor, intensity: glowIntensity)
          : null,
    );
  }

  /// Create glass gradient for specific color
  static LinearGradient gradient(Color color, {double intensity = 0.12}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withValues(alpha: intensity),
        color.withValues(alpha: intensity * 0.3),
      ],
    );
  }

  /// Top highlight gradient (light refraction effect)
  static LinearGradient get topHighlight => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white.withValues(alpha: highlightOpacity),
      Colors.white.withValues(alpha: 0),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Extension for easy access to psychology colors from BuildContext
extension PsychologyColorsExtension on BuildContext {
  /// Get psychology colors
  PsychologyColors get psychologyColors => PsychologyColors._();
}

/// Extension for TextStyle with psychology color
extension PsychologyTextStyleExtension on TextStyle {
  /// Apply primary color
  TextStyle get primary => copyWith(color: PsychologyColors.textPrimary);

  /// Apply secondary color
  TextStyle get secondary => copyWith(color: PsychologyColors.textSecondary);

  /// Apply tertiary color
  TextStyle get tertiary => copyWith(color: PsychologyColors.textTertiary);

  /// Apply muted color
  TextStyle get muted => copyWith(color: PsychologyColors.textMuted);

  /// Apply custom color
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Add glow shadow
  TextStyle withGlow(Color color, {double intensity = 0.4}) => copyWith(
    shadows: [Shadow(color: color.withValues(alpha: intensity), blurRadius: 12)],
  );
}
