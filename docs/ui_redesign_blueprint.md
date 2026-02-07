# VANTAG UI REDESIGN BLUEPRINT
## Unified Design System Migration Plan

**Version:** 2.0
**Date:** February 2026
**Status:** APPROVED FOR IMPLEMENTATION
**Branch:** `ui-liquid-glass-overhaul`

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [New Theme Architecture](#2-new-theme-architecture)
3. [Color System](#3-color-system)
4. [Typography System](#4-typography-system)
5. [Glass Effect System](#5-glass-effect-system)
6. [Component Design Specs](#6-component-design-specs)
7. [Screen-by-Screen Redesign Priority](#7-screen-by-screen-redesign-priority)
8. [Migration Plan](#8-migration-plan)
9. [Widget Consolidation](#9-widget-consolidation)
10. [Access Pattern Standardization](#10-access-pattern-standardization)

---

## 1. Executive Summary

### Current State Assessment: FRAGMENTED (4/10 health score)

The Vantag theme system has accumulated severe technical debt across 14 theme files totaling approximately 8,400 lines of code spread across two directories (`lib/theme/` and `lib/core/theme/`). The core problems:

- **5 separate color classes** define overlapping palettes: `AppColors` (265 lines, 150+ colors), `PsychologyColors` (80+ colors), `LiquidGlassColors` (52 colors), `PremiumColors` (33 colors), and `AppColorsLight` (78 colors).
- **3 duplicate widget sets**: `GlassCard` exists in `quiet_luxury.dart`, `PremiumGlassCard` in `premium_theme.dart`, and `LiquidGlassCard` in `liquid_glass.dart`. `BreathingGlow` exists in both `premium_effects.dart` and `psychology_effects.dart`.
- **5 incompatible access patterns**: `context.appColors.xxx` (2,963 usages across 96 files), `AppColors.xxx` (414 usages across 55 files), `PsychologyColors.xxx` (127 usages across 8 files), `PremiumTheme.xxx` (0 active -- already deprecated), `QuietLuxury.xxx` (via `quiet_luxury.dart` import in 18 files).
- **3 separate animation systems**: `AppAnimations` (133 lines), `AnimationDurations`/`AnimationCurves` in `app_spacing.dart`, and `PsychologyAnimations` in `psychology_design_system.dart`.
- **3 separate spacing systems**: `AppDesign` spacing tokens, `Spacing` class in `app_spacing.dart`, and `PsychologySpacing` in `psychology_design_system.dart`.
- **3 deprecated/alias files** that should have been deleted: `premium_theme.dart` (deprecated wrapper), `quiet_luxury.dart` (alias wrapper), `ai_finance_theme.dart` (legacy).

### Vision for Redesign

Consolidate 14 fragmented theme files into a clean **3+1 file architecture** that delivers:

1. **One source of truth** for every design token (color, type, spacing, effect).
2. **One access pattern** (`context.appColors.xxx` for theme-aware, `AppColors.xxx` for static) used consistently across all 96+ files.
3. **iOS 26 Liquid Glass** as the signature visual language, informed by competitor analysis of Revolut, N26, Cleo, Copilot Money, and Rocket Money.
4. **Zero duplicate widgets** -- every glass card, glow effect, and animation has exactly one canonical implementation.
5. **Dark-first, light-aware** -- OLED-optimized dark mode as the primary experience with a polished light mode counterpart.

### Key Principles

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | **Single Source of Truth** | All tokens in 3 files; no duplicates allowed |
| 2 | **Context-First Access** | `context.appColors.xxx` for all widget code |
| 3 | **Glass as Signature** | Liquid glass effects define the premium feel |
| 4 | **Psychology-Driven** | Colors chosen for emotional impact on financial decisions |
| 5 | **Performance Budget** | Max 2 BackdropFilters visible per screen; blur sigma capped at 30 |
| 6 | **Accessibility** | WCAG AA contrast ratios; 44px minimum touch targets; scalable text |
| 7 | **4px Grid** | All spacing values are multiples of 4px |
| 8 | **Localization-Ready** | No hardcoded strings; all text via `l10n.xxx` |

---

## 2. New Theme Architecture

### Target: 3+1 File System

```
lib/theme/
  app_colors.dart        # ALL colors (dark + light), gradients, glass fills
  app_typography.dart     # ALL text styles, font features, accessibility
  app_effects.dart        # Glass effects, shadows, animations, spacing, decorations
  theme.dart              # Barrel file: exports all 3 + accessible_text.dart
  accessible_text.dart    # KEEP as-is (unique accessibility utilities)
```

### File Responsibilities

#### `app_colors.dart` (~400 lines)

Absorbs colors from:
- `AppColors` (from current `app_theme.dart`)
- `AppColorsLight` (from current `app_theme.dart`)
- `PsychologyColors` (from `psychology_design_system.dart`)
- `LiquidGlassColors` (from `liquid_glass.dart`)
- `PremiumColors` (from `premium_effects.dart`)

Contains:
- `class AppColors` -- all dark mode static const colors
- `class AppColorsLight` -- all light mode static const colors
- `class AppGradients` -- all gradient definitions
- `extension AppColorsExtension on BuildContext` -- the `context.appColors` accessor
- `class _ThemeColors` -- theme-aware color container

#### `app_typography.dart` (~300 lines)

Absorbs typography from:
- `AppDesign` font sizes (from current `app_theme.dart`)
- `AppFonts` (from current `app_theme.dart`)
- `PsychologyTypography` (from `psychology_design_system.dart`)
- `QuietLuxury` text styles (from `quiet_luxury.dart`)
- `TypographySpacing` (from `app_spacing.dart`)
- `AppTheme.darkTheme.textTheme` and `AppTheme.lightTheme.textTheme`

Contains:
- `class AppTypography` -- all TextStyle definitions with tabular figures for numbers
- `class AppFonts` -- font family declarations with Turkish fallback
- `class AppTheme` -- ThemeData builders for dark and light mode
- `class PremiumModalRoute` -- page transition definitions

#### `app_effects.dart` (~600 lines)

Absorbs effects, spacing, animations, shadows, and decorations from:
- `AppDesign` spacing/radius/shadows (from current `app_theme.dart`)
- `PsychologySpacing`, `PsychologyRadius`, `PsychologyShadows`, `PsychologyGlass` (from `psychology_design_system.dart`)
- `PsychologyAnimations` (from `psychology_design_system.dart`)
- `AppAnimations` (from `app_animations.dart`)
- `AnimationDurations`, `AnimationCurves`, `Spacing` (from `app_spacing.dart`)
- `PremiumDecorations`, `PremiumShadows` (from `premium_effects.dart`)
- `LiquidGlassGradients` (from `liquid_glass.dart`)

Contains:
- `class AppSpacing` -- unified spacing constants (4px grid)
- `class AppRadius` -- unified border radius constants
- `class AppShadows` -- unified shadow definitions
- `class AppGlass` -- glass effect specs (blur, fill, border, highlight)
- `class AppAnimation` -- unified animation durations, curves, scales
- `class AppDecoration` -- card/sheet/button decoration builders

### Migration Path: 14 Files to 3+1 Files

```
PHASE 1: DELETE (3 files)
  lib/theme/premium_theme.dart       --> DELETE (deprecated wrapper, 0 direct imports)
  lib/theme/quiet_luxury.dart        --> DELETE (alias wrapper, 18 imports to migrate)
  lib/theme/ai_finance_theme.dart    --> DELETE (legacy, 0 active imports)

PHASE 2: MERGE then DELETE (4 files)
  lib/theme/app_spacing.dart         --> MERGE into app_effects.dart, then DELETE
  lib/theme/app_animations.dart      --> MERGE into app_effects.dart, then DELETE
  lib/core/theme/psychology_design_system.dart --> MERGE colors into app_colors.dart,
                                                   typography into app_typography.dart,
                                                   spacing/effects into app_effects.dart,
                                                   then DELETE
  lib/core/theme/premium_effects.dart --> MERGE colors into app_colors.dart,
                                          decorations into app_effects.dart,
                                          KEEP effect widgets in app_effects.dart,
                                          then DELETE

PHASE 3: CONSOLIDATE (3 files)
  lib/core/theme/liquid_glass.dart   --> MERGE colors/gradients into app_colors.dart,
                                         KEEP widget code in app_effects.dart,
                                         then DELETE
  lib/core/theme/psychology_effects.dart  --> KEEP effect widgets, move to app_effects.dart
  lib/core/theme/psychology_widgets.dart  --> REFACTOR: rename components to V-prefix convention
                                              (VDecisionButton, VGlassCard etc.) in Phase 3

PHASE 4: RESTRUCTURE (create new files)
  lib/theme/app_theme.dart           --> SPLIT into app_colors.dart + app_typography.dart
                                         + app_effects.dart (AppDesign portions)
  lib/theme/theme.dart               --> UPDATE barrel exports

FINAL STATE:
  lib/theme/app_colors.dart          # NEW: unified colors
  lib/theme/app_typography.dart       # NEW: unified typography + ThemeData
  lib/theme/app_effects.dart          # NEW: unified effects + widgets
  lib/theme/accessible_text.dart      # KEEP: unchanged
  lib/theme/theme.dart                # UPDATE: barrel file

  lib/core/theme/psychology_widgets.dart  # REFACTOR: V-prefix rename in Phase 3
  lib/core/theme/theme.dart              # UPDATE: re-export psychology_widgets only
```

### Barrel File (`lib/theme/theme.dart`)

```dart
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_effects.dart';
export 'accessible_text.dart';
```

---

## 3. Color System

### 3.1 Brand Colors

| Token | Dark Mode Hex | Light Mode Hex | Usage |
|-------|--------------|----------------|-------|
| `primary` | `#8B5CF6` | `#8B5CF6` | Brand purple, CTAs, accents |
| `primaryDark` | `#7C3AED` | `#7C3AED` | Pressed states, active indicators |
| `primaryLight` | `#A78BFA` | `#C4B5FD` | Hover states, subtle highlights |
| `primarySubtle` | `#148B5CF6` (8%) | `#0A8B5CF6` (4%) | Background tints |
| `primaryMuted` | `#268B5CF6` (15%) | `#148B5CF6` (8%) | Chip backgrounds |
| `secondary` | `#22D3EE` | `#22D3EE` | Savings/positive, secondary accent |
| `secondaryDark` | `#06B6D4` | `#06B6D4` | Pressed states |
| `secondaryLight` | `#67E8F9` | `#67E8F9` | Hover states |
| `secondarySubtle` | `#1422D3EE` (8%) | `#0A22D3EE` (4%) | Background tints |
| `accent` | `#F59E0B` | `#F59E0B` | Gold, premium, milestones |

### 3.2 Surface Colors

| Token | Dark Mode Hex | Light Mode Hex | Usage |
|-------|--------------|----------------|-------|
| `background` | `#050508` | `#F8FAFC` | App background (OLED-optimized dark) |
| `surface` | `#0F0D17` | `#FFFFFF` | Base card surface (Tier 1) |
| `surfaceElevated` | `#1A1726` | `#F1F5F9` | Elevated cards (Tier 2) |
| `surfaceOverlay` | `#252233` | `#E2E8F0` | Modals, sheets (Tier 3) |
| `surfaceInput` | `#18151F` | `#F1F5F9` | Text input backgrounds (Tier 2.5) |
| `cardBackground` | `#12101A` | `#FFFFFF` | Standard card fill |
| `surfaceLight` | `#1A1725` | `#F1F5F9` | Alias for elevated (legacy compat) |
| `surfaceLighter` | `#231F2E` | `#E2E8F0` | Alias for overlay (legacy compat) |

**Surface Elevation Ladder (Dark Mode):**
```
Background:  #050508  (base layer, OLED black)
     |
Surface:     #0F0D17  (Tier 1 - flat cards, list items)
     |
Elevated:    #1A1726  (Tier 2 - raised cards, input fields)
     |
Overlay:     #252233  (Tier 3 - sheets, modals, popovers)
     |
Input:       #18151F  (Tier 2.5 - form fields within cards)
```

**Gradient Colors:**

| Token | Hex | Usage |
|-------|-----|-------|
| `gradientStart` | `#0A0A0F` | Background gradient start (dark) |
| `gradientMid` | `#12101A` | Background gradient middle |
| `gradientEnd` | `#1A1725` | Background gradient end |

### 3.3 Text Colors

| Token | Dark Mode Hex | Light Mode Hex | Contrast | Usage |
|-------|--------------|----------------|----------|-------|
| `textPrimary` | `#FAFAFA` | `#0F172A` | 18.1:1 / 15.3:1 | Headlines, body text, amounts |
| `textSecondary` | `#A1A1AA` | `#475569` | 8.2:1 / 7.1:1 | Subtitles, labels, descriptions |
| `textTertiary` | `#71717A` | `#94A3B8` | 4.7:1 / 3.5:1 | Hints, placeholders, muted |
| `textMuted` | `#52525B` | `#CBD5E1` | 3.1:1 / 2.4:1 | Disabled text, decorative only |

### 3.4 Status Colors

| Token | Hex | Subtle (8%) | Usage |
|-------|-----|-------------|-------|
| `success` | `#10B981` | `#1410B981` | Positive amounts, savings, completion |
| `successLight` | `#34D399` | -- | Hover/highlight |
| `warning` | `#F59E0B` | `#14F59E0B` | Caution, pending, attention |
| `warningLight` | `#FBBF24` | -- | Hover/highlight |
| `error` | `#EF4444` | `#14EF4444` | Negative amounts, errors, alerts |
| `errorLight` | `#F87171` | -- | Hover/highlight |
| `info` | `#3B82F6` | `#143B82F6` | Informational, tips, links |
| `infoLight` | `#60A5FA` | -- | Hover/highlight |

### 3.5 Decision Colors (Vantag-Specific)

| Token | Hex | Psychology | Usage |
|-------|-----|-----------|-------|
| `decisionYes` | `#F87171` | Soft red -- signals spending/loss | "Bought" button |
| `decisionThinking` | `#FBBF24` | Amber -- caution/pause | "Thinking" button |
| `decisionNo` | `#22D3EE` | Cyan -- positive/fresh | "Passed" button (savings!) |

### 3.6 Glass Colors

| Token | Hex / Alpha | Usage |
|-------|-------------|-------|
| `glassWhite` | `#15FFFFFF` (8%) | Glass card fill |
| `glassBorder` | `#20FFFFFF` (12%) | Glass card border |
| `glassHighlight` | `#30FFFFFF` (19%) | Top-edge highlight |
| `cardBackgroundGlass` | `#0AFFFFFF` (4%) | Subtle glass card fill |
| `cardBorder` | `#15FFFFFF` (8%) | Standard card border |
| `cardShadow` | `#40000000` (25%) | Card drop shadow |

**Light Mode Glass:**

| Token | Hex / Alpha | Usage |
|-------|-------------|-------|
| `glassBlack` | `#08000000` (3%) | Glass card fill (inverted) |
| `glassBorder` | `#15000000` (8%) | Glass card border |
| `cardBackgroundGlass` | `#FFFFFF` | Solid white glass card |
| `cardBorder` | `#E2E8F0` | Slate border |
| `cardShadow` | `#15000000` (8%) | Subtle shadow |

### 3.7 Category Colors

| Token | Hex | Category |
|-------|-----|----------|
| `categoryFood` | `#FF6B6B` | Food & Dining |
| `categoryTransport` | `#4ECDC4` | Transportation |
| `categoryShopping` | `#9B59B6` | Shopping |
| `categoryEntertainment` | `#3498DB` | Entertainment |
| `categoryBills` | `#E74C3C` | Bills & Utilities |
| `categoryHealth` | `#2ECC71` | Health & Wellness |
| `categoryEducation` | `#F39C12` | Education |
| `categorySports` | `#8BC34A` | Sports & Fitness |
| `categoryDigital` | `#00BCD4` | Digital & Tech |
| `categoryShoppingPink` | `#E91E63` | Fashion & Beauty |
| `categoryComm` | `#607D8B` | Communication |
| `categoryOther` | `#95A5A6` | Other |
| `categoryDefault` | `#78909C` | Fallback |

### 3.8 Achievement & Gamification Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `achievementStreak` | `#FF6B35` | Streak fire |
| `achievementSavings` | `#2ECC71` | Savings milestone |
| `achievementGoals` | `#9B59B6` | Goal completion |
| `achievementTracker` | `#3498DB` | Tracking milestone |
| `achievementMystery` | `#E91E63` | Hidden achievement |
| `achievementYellow` | `#FBBF24` | Star rating |
| `achievementOrange` | `#F97316` | Flame effect |
| `achievementSkyBlue` | `#8ED1FC` | Cool achievement |
| `achievementLavender` | `#B4A7D6` | Premium achievement |

### 3.9 Medal Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `medalBronze` | `#CD7F32` | Tier 1 |
| `medalSilver` | `#C0C0C0` | Tier 2 |
| `medalGold` | `#FFD700` | Tier 3 |
| `medalPlatinum` | `#E5E4E2` | Tier 4 |

### 3.10 Social Brand Colors

| Token | Hex | Platform |
|-------|-----|----------|
| `instagram` | `#E4405F` | Instagram |
| `facebook` | `#1877F2` | Facebook |
| `twitter` | `#1DA1F2` | Twitter/X |
| `whatsapp` | `#25D366` | WhatsApp |
| `tiktok` | `#000000` | TikTok |
| `snapchat` | `#FFFC00` | Snapchat |
| `youtube` | `#FF0000` | YouTube |

### 3.11 Currency & Financial Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `currencyPositive` | `#4CAF50` | Positive movement |
| `currencyNegative` | `#E74C3C` | Negative movement |
| `currencyNeutral` | `#2196F3` | No change |
| `currencyGold` | `#FFB800` | Gold/premium |

### 3.12 Income Type Colors

| Token | Hex | Type |
|-------|-----|------|
| `incomeSalary` | `#6C63FF` | Salary |
| `incomeBonus` | `#FFD700` | Bonus |
| `incomeFreelance` | `#E91E63` | Freelance |
| `incomePassive` | `#4CAF50` | Passive |
| `incomeRental` | `#4ECDC4` | Rental |
| `incomeSideJob` | `#F39C12` | Side job |
| `incomeOther` | `#2ECC71` | Other |
| `incomeDefault` | `#95A5A6` | Default |

### 3.13 Heatmap Colors

| Token | Hex | Level |
|-------|-----|-------|
| `heatmapNone` | `#1E1E2E` | No activity |
| `heatmapLow` | `#2D5016` | Low |
| `heatmapMedium` | `#3D7017` | Medium |
| `heatmapHigh` | `#4CAF50` | High |

### 3.14 Chart Palette

```dart
static const List<Color> chartPalette = [
  Color(0xFF6C63FF), // Purple (primary brand)
  Color(0xFF4ECDC4), // Teal (secondary)
  Color(0xFFFF6B6B), // Coral
  Color(0xFFFFD93D), // Yellow
  Color(0xFF95E1D3), // Mint
  Color(0xFFF38181), // Salmon
  Color(0xFFAA96DA), // Lavender
  Color(0xFF3D5A80), // Navy
];
```

### 3.15 Subscription Colors

```dart
static const List<Color> subscriptionColors = [
  Color(0xFFFF6B6B), // Red
  Color(0xFF4ECDC4), // Turquoise
  Color(0xFF6C63FF), // Purple
  Color(0xFFFFD93D), // Yellow
  Color(0xFFFF8C42), // Orange
  Color(0xFF95E1D3), // Mint
  Color(0xFFF38181), // Pink
  Color(0xFF3D5A80), // Navy
];
```

### 3.16 Misc UI Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `divider` | `#2D2440` | Divider lines |
| `shimmer` | `#2D2440` | Shimmer loading |
| `overlay` | `#80000000` (50%) | Screen overlay |
| `urgentOrange` | `#FF8C42` | Urgent states |
| `dangerRed` | `#B71C1C` | Danger zone |
| `dangerRedDark` | `#C0392B` | Danger pressed |
| `dangerGradientStart` | `#4A1C1C` | Danger card start |
| `dangerGradientEnd` | `#2D1010` | Danger card end |
| `coffeeColor` | `#8B4513` | Coffee habit |
| `smokingGray` | `#607D8B` | Smoking habit |
| `premiumPurple` | `#8B5CF6` | Premium badge |
| `premiumPurpleLight` | `#A78BFA` | Premium highlight |
| `premiumPurpleDark` | `#6D28D9` | Premium pressed |
| `premiumCyan` | `#22D3EE` | Premium accent |
| `premiumGreen` | `#00C853` | Premium success |

### 3.17 Gradients

| Token | Colors | Usage |
|-------|--------|-------|
| `background` | `#0A0A0F` -> `#12101A` -> `#1A1725` | Screen background |
| `primaryButton` | `#8B5CF6` -> `#22D3EE` | Primary CTA buttons |
| `progress` | `#8B5CF6` -> `#22D3EE` | Progress bars |
| `success` | `#22D3EE` -> `#3DBDB5` | Success states |
| `error` | `#EF4444` -> `#FF6B81` | Error states |
| `warning` | `#F59E0B` -> `#FF9500` | Warning states |
| `premiumCard` | `#2A2545` -> `#1E293B` | Premium card background |
| `premiumCardLight` | `#3D3560` -> `#2D3A50` | Elevated premium card |
| `cardOverlay` | `#10FFFFFF` -> `#00FFFFFF` | Subtle card top shine |
| `expenseCard` | `#252540` -> `#1A1A2E` | Expense card gradient |
| `glass` | `#1FFFFFFF` -> `#0DFFFFFF` | Glass fill (12% -> 5%) |
| `glassHighlight` | `transparent` -> `#14FFFFFF` -> `transparent` | Glass edge highlight |
| `luminance` | `#33FFFFFF` -> `transparent` | Top-left light refraction |

---

## 4. Typography System

### 4.1 Font Stack

```dart
class AppFonts {
  // Primary: system fonts (SF Pro on iOS, Roboto on Android)
  static String? get heading => null;  // System default
  static String? get body => null;     // System default
  static String get mono => Platform.isIOS ? 'Menlo' : 'Roboto Mono';

  // Turkish character fallback chain
  static const List<String> fontFallback = [
    'SF Pro Display',
    'Roboto',
    'Segoe UI',
    'Apple Color Emoji',
    'Noto Sans',
  ];
}
```

**Rationale:** System fonts provide the best performance, native feel, and guaranteed Turkish character support (i, g, u, s, o, c, I). No need to bundle Inter or any custom font.

### 4.2 Type Scale

| Style | Size | Weight | Tracking | Line Height | Usage |
|-------|------|--------|----------|-------------|-------|
| `displayLarge` | 56px | w700 | -2.0 | 1.0 | Hero financial numbers |
| `displayMedium` | 48px | w700 | -1.0 | 1.05 | Large dashboard amounts |
| `displaySmall` | 32px | w600 | -0.5 | 1.1 | Card hero numbers |
| `headlineLarge` | 32px | w700 | -1.0 | 1.1 | Page titles |
| `headlineMedium` | 28px | w700 | -0.5 | 1.15 | Section headers |
| `headlineSmall` | 24px | w600 | 0 | 1.2 | Card titles |
| `titleLarge` | 18px | w600 | 0 | 1.3 | List item titles |
| `titleMedium` | 16px | w600 | 0 | 1.35 | Subtitle, row labels |
| `titleSmall` | 14px | w500 | 0 | 1.4 | Tertiary headings |
| `bodyLarge` | 16px | w400 | 0 | 1.5 | Primary body text |
| `bodyMedium` | 14px | w400 | 0 | 1.5 | Secondary body text |
| `bodySmall` | 13px | w400 | 0 | 1.5 | Captions, descriptions |
| `labelLarge` | 14px | w600 | 0 | 1.3 | Button text, strong labels |
| `labelMedium` | 12px | w500 | 1.5 | 1.3 | Uppercase section headers |
| `labelSmall` | 11px | w500 | 2.0 | 1.3 | Uppercase micro labels |

### 4.3 Financial Number Handling

```dart
/// Text style for financial amounts with tabular figures
static TextStyle financialAmount({
  required double fontSize,
  FontWeight fontWeight = FontWeight.w600,
  Color? color,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? AppColors.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
    letterSpacing: -0.5,
  );
}
```

**Key rules for financial numbers:**
- Always use `FontFeature.tabularFigures()` for amount displays (ensures digits are equal width)
- Negative tracking (-0.5) for large numbers to feel compact and premium
- Use `w300` for hero amounts (light weight = luxury aesthetic, following N26/Revolut pattern)
- Use `w600` for inline amounts (clear readability at smaller sizes)
- Currency code displayed at `labelMedium` size with `w400` and `letterSpacing: 1.0`
- Turkish number formatting: dot (`.`) for thousands separator, comma (`,`) for decimal

### 4.4 Accessibility Considerations

```dart
/// Scaled font size respecting system text scaling (max 1.5x)
static double scaledFontSize(BuildContext context, double baseSize, {
  double maxScale = 1.5,
  double minScale = 1.0,
}) {
  final scale = MediaQuery.of(context).textScaler.scale(1.0).clamp(minScale, maxScale);
  return baseSize * scale;
}
```

- `displayLarge` / `displayMedium`: maxScale 1.3 (prevents overflow on dashboard)
- `bodyLarge` / `bodyMedium` / `bodySmall`: maxScale 1.5 (full accessibility scaling)
- `labelMedium` / `labelSmall`: maxScale 1.4 (button text needs bounded scaling)
- All contrast ratios meet WCAG AA (4.5:1 for body text, 3:1 for large text)
- `ScalableText` widget wraps with `FittedBox` for overflow protection
- `AccessibleTouchTarget` ensures 44x44px minimum touch targets

---

## 5. Glass Effect System

### 5.1 Blur Tiers

| Tier | Sigma | Usage | Performance Impact |
|------|-------|-------|-------------------|
| **Light** | 12 | Chips, small tags, badges | Low |
| **Medium** | 20-24 | Standard cards, nav bar | Medium |
| **Heavy** | 30 max | Hero cards, bottom sheets, modals | High |

**Performance Rule:** Maximum 2 `BackdropFilter` widgets visible simultaneously on any screen. Use solid color fallback (surface color at 95% opacity) when blur would exceed budget.

### 5.2 Glass Card Specification

```
GLASS CARD ANATOMY:
+----------------------------------------------------------+
|  Top Highlight: LinearGradient                            |
|  white@15% -> transparent (60px height)                   |
|                                                           |
|  Fill: LinearGradient                                     |
|  white@8% (top-left) -> white@4% (bottom-right)          |
|                                                           |
|  Border: 1px solid white@8%                               |
|  Corner Radius: 20px (standard) / 24px (hero)            |
|                                                           |
|  Shadow: black@25% blur:20 offset:(0,10)                  |
|  + Optional colored glow: primary@25% blur:20 spread:-5   |
+----------------------------------------------------------+
```

### 5.3 Flutter Implementation Pattern

```dart
/// Canonical Glass Card implementation
class VGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blurSigma;
  final Color? glowColor;
  final double glowIntensity;

  const VGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.blurSigma = 20,        // Medium blur default
    this.glowColor,
    this.glowIntensity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Macro depth shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          // Optional colored glow
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: glowIntensity),
              blurRadius: 20,
              spreadRadius: -5,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // Glass fill gradient
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x15FFFFFF),  // 8% white
                  Color(0x0AFFFFFF),  // 4% white
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              // Glass border
              border: Border.all(
                color: const Color(0x20FFFFFF), // 12% white
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

### 5.4 Glass Effect Variants

| Variant | Fill | Border | Blur | Radius | Usage |
|---------|------|--------|------|--------|-------|
| **Standard Glass** | white@8%->4% | white@8% 1px | sigma 20 | 20px | Most cards |
| **Hero Glass** | white@10%->6% | white@12% 1px | sigma 30 | 24px | Financial snapshot, result card |
| **Subtle Glass** | white@4%->2% | white@6% 0.5px | sigma 12 | 16px | List items, chips |
| **Sheet Glass** | surface@95% | white@8% 1px | sigma 30 | 24px (top) | Bottom sheets |
| **Nav Glass** | surface@95% | white@6% 1px | sigma 20 | 32px (pill) | Navigation bar |
| **Input Glass** | surfaceInput@80% | white@6% 1px | none | 14px | Text fields |

### 5.5 Top Highlight Effect

```dart
/// Simulates light refraction on glass top edge
static BoxDecoration glassHighlightDecoration({double height = 60}) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0x25FFFFFF), // 15% white at top
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    ),
  );
}
```

### 5.6 Shadow System

| Shadow | Color | Blur | Spread | Offset | Usage |
|--------|-------|------|--------|--------|-------|
| `subtle` | black@12% | 20 | 0 | (0, 4) | Flat cards, list items |
| `medium` | black@20% | 20 | 0 | (0, 8) | Elevated cards |
| `card` | black@20% | 20 | 0 | (0, 10) | Premium cards |
| `heavy` | black@30% | 30 | 0 | (0, 10) | Hero elements |
| `glowPurple` | primary@40% | 24 | 2 | (0, 0) | Primary glow (intense) |
| `glowPurpleSoft` | primary@30% | 32 | 0 | (0, 0) | Primary glow (soft) |
| `glowSuccess` | success@30% | 20 | -5 | (0, 0) | Success state glow |
| `glowError` | error@30% | 20 | -5 | (0, 0) | Error state glow |

### 5.7 Animation Specs

| Token | Duration | Curve | Usage |
|-------|----------|-------|-------|
| `micro` | 100ms | `easeInOut` | Button press scale |
| `fast` | 150-200ms | `easeOutCubic` | Hover states, toggles |
| `standard` | 250-300ms | `easeOutCubic` | Card transitions, fades |
| `emphasis` | 400ms | `easeInOutCubic` | Page transitions |
| `counting` | 600-800ms | `easeOutCubic` | Number counting animations |
| `breathing` | 3000ms | `easeInOut` | Glow pulse (repeat) |
| `celebration` | 2500ms | `elasticOut` | Achievement celebrations |

**Scale values:**
- Button press: `0.95` (tactile feedback)
- Card focus: `1.02` (subtle lift)
- Achievement pulse: `1.03` (gentle throb)
- Header scroll: min `0.92` (shrink on scroll)

**Opacity values:**
- Disabled: `0.5`
- Locked: `0.6`
- Header min: `0.8`
- Backdrop: `0.7`

### 5.8 Spacing System (4px Grid)

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Micro gaps, icon-to-text |
| `sm` | 8px | Element gaps within rows |
| `md` | 12px | Item gaps in lists |
| `lg` | 16px | Standard card padding, section gaps |
| `xl` | 20px | Screen horizontal margin, card padding |
| `xxl` | 24px | Large card padding |
| `xxxl` | 32px | Section separators |
| `section` | 48px | Major section breaks |

**Semantic spacing:**

| Token | Value | Usage |
|-------|-------|-------|
| `screenPadding` | `EdgeInsets.symmetric(horizontal: 20)` | Screen content margin |
| `cardPadding` | `EdgeInsets.all(16)` | Standard card padding |
| `cardPaddingLarge` | `EdgeInsets.all(20)` | Hero/premium card padding |
| `cardPaddingHero` | `EdgeInsets.all(24)` | Financial snapshot padding |

### 5.9 Border Radius System

| Token | Value | Usage |
|-------|-------|-------|
| `radiusXs` | 6px | Badges, tiny chips |
| `radiusSm` | 8px | Small buttons, tags |
| `radiusMd` | 12px | Input fields, small cards |
| `radiusLg` | 16px | Standard cards |
| `radiusXl` | 20px | Large cards, hero cards |
| `radiusXxl` | 24px | Bottom sheets, modals |
| `radiusFull` | 999px | Pill shapes, nav bar |

---

## 6. Component Design Specs

### 6.1 Cards

#### Hero Card (Financial Snapshot)
```
Dimensions: Full width, padding 24px
Radius: 24px
Blur: sigma 30 (heavy)
Fill: glass gradient white@10% -> white@6%
Border: 1px white@12%
Shadow: black@25% blur:24 offset:(0,12) + primary@20% blur:20
Top highlight: white@15% -> transparent (80px)
Animation: Subtle breathing glow (3000ms, primary@15-25%)
```

#### Standard Card
```
Dimensions: Full width, padding 20px
Radius: 20px
Blur: sigma 20 (medium)
Fill: glass gradient white@8% -> white@4%
Border: 1px white@8%
Shadow: black@20% blur:20 offset:(0,8)
```

#### Compact Card
```
Dimensions: Full width, padding 16px
Radius: 16px
Blur: none (performance -- use solid surface color)
Fill: surface @ 100%
Border: 1px white@6%
Shadow: black@12% blur:20 offset:(0,4)
```

#### Glass Chip
```
Dimensions: Auto width, padding 8px 14px
Radius: 8px
Blur: sigma 12 (light) or none
Fill: white@5%
Border: 1px white@6%
Text: labelMedium, textSecondary
Selected: fill primary@15%, border primary@30%, text primary
```

### 6.2 Buttons

#### Primary Button (Gradient)
```
Height: 56px
Width: Full width
Radius: 14px
Fill: LinearGradient primary -> secondary
Shadow: primary@35% blur:16 offset:(0,8)
Text: 16px w600, white, letterSpacing: -0.2
Press: scale 0.97, duration 100ms
Loading: 24x24 white CircularProgressIndicator, strokeWidth 2
```

#### Secondary Button (Outlined)
```
Height: 56px
Width: Full width
Radius: 14px
Fill: transparent
Border: 1.5px white@12%
Text: 16px w600, textPrimary, letterSpacing: -0.2
Press: scale 0.97, duration 100ms
```

#### Ghost Button (Text Only)
```
Height: Auto (padding 12px 16px)
Fill: transparent
Text: 14px w500, textSecondary
Press: opacity 0.7, duration 100ms
```

#### Glass Button
```
Height: 48px
Radius: 12px
Blur: sigma 12
Fill: white@8%
Border: 1px white@8%
Text: 14px w600, textPrimary
Press: scale 0.97, fill white@12%
```

### 6.3 Navigation Bar

```
Position: Bottom, floating
Margin: 20px horizontal, 34px bottom (safe area)
Height: 64px
Radius: 32px (pill shape)
Blur: sigma 20
Fill: surface@95% (dark) / white@95% (light)
Border: 1px white@6%
Items: 5 (Home, Reports, [Add], Goals, Settings)
Active icon: primary, 24px
Inactive icon: textTertiary, 24px
Center FAB: 48x48, gradient primary->secondary, radius 14px
FAB shadow: primary@40% blur:20 offset:(0,8)
Label: 10px w500, active=primary, inactive=textTertiary
```

### 6.4 Bottom Sheets

```
Radius: 24px (top only)
Fill: surfaceOverlay@95% (with glass blur if hero sheet)
Blur: sigma 30 (optional, for hero sheets only)
Handle bar: 40x4px, radius 2px, textTertiary@30%
Max height: 90% of screen
Barrier: black@85%
Animation: 300ms easeOutCubic slide up + fade
Padding: 20px horizontal, 16px top (below handle), 34px bottom (safe area)
```

### 6.5 Input Fields

```
Height: Auto (padding 16px horizontal, 16px vertical)
Radius: 14px
Fill: surfaceInput (dark: #18151F, light: #F1F5F9)
Border enabled: 1px white@6%
Border focused: 1.5px primary@50%
Border error: 1px error
Label: 14px w500, textSecondary
Hint: 15px w400, textTertiary
Input text: 15px w400, textPrimary
Cursor: primary
```

### 6.6 Decision Buttons (Buy/Think/Pass)

```
Layout: Row, 3 equal-width buttons, 10px gap
Height: Auto (padding 14px vertical)
Radius: 14px
Fill: decision color @10%
Border: 1px decision color @20%
Icon: decision color, 20px, above text
Text: 13px w600, decision color, uppercase

Buy (decisionYes #F87171):
  Fill: #F87171 @10%, border #F87171 @20%
  Icon: CupertinoIcons.checkmark
  Label: l10n.bought

Think (decisionThinking #FBBF24):
  Fill: #FBBF24 @10%, border #FBBF24 @20%
  Icon: CupertinoIcons.clock
  Label: l10n.thinking

Pass (decisionNo #22D3EE):
  Fill: #22D3EE @15% (emphasized!)
  Border: 1.5px #22D3EE @30%
  Icon: CupertinoIcons.hand_raised
  Label: l10n.passed
  Note: Intentionally more prominent (psychology: encourage saving)

Press animation: scale 0.95, 100ms, haptic light impact
```

### 6.7 Streak Badge

```
Layout: Compact pill, horizontal
Height: 36px
Radius: 18px (full pill)
Fill: glass white@8% (active) / surface (inactive)
Border: 1px white@8%
Icon: CupertinoIcons.flame_fill, achievementStreak (#FF6B35), 16px
Text: 14px w600, textPrimary
Pulse animation: scale 1.0-1.03, 800ms easeInOut (active streak only)
Glow: achievementStreak@25% blur:12 (active only)
```

### 6.8 Chart & Graph Styling

```
Background: transparent (inherits card background)
Grid lines: white@6%, 0.5px
Axis labels: 11px w400, textTertiary
Value labels: 12px w500, textSecondary
Active segment: chartPalette colors at 100%
Inactive segment: chartPalette colors at 40%
Tooltip: surface@95%, radius 12px, border white@8%
Tooltip text: 13px w500, textPrimary
Selected highlight: primary@20% background glow
Animation: 600ms easeOutCubic on data change
```

---

## 7. Screen-by-Screen Redesign Priority

### Priority Definitions

| Priority | Meaning | Timeline |
|----------|---------|----------|
| **P0** | Critical path, daily-use screens | Phase 3 (Day 3-5) |
| **P1** | High-traffic feature screens | Phase 4a (Day 6-7) |
| **P2** | Secondary feature screens | Phase 4b (Day 8) |
| **P3** | Low-traffic or settings screens | Phase 5 (Day 9-10) |

### Screen Inventory

| # | Screen | File | Priority | Current State | What Changes | Effort |
|---|--------|------|----------|---------------|-------------|--------|
| 1 | **Expense Screen** (Home) | `lib/screens/expense_screen.dart` | **P0** | Uses PsychologyColors + psychology_widgets imports; mixed access patterns | Migrate all color refs to context.appColors; use VGlassCard for financial snapshot; standardize all imports | **XL** |
| 2 | **Main Screen** (Shell) | `lib/screens/main_screen.dart` | **P0** | Uses context.appColors; hosts nav bar | Update nav bar import, ensure background uses unified token | **S** |
| 3 | **Report Screen** | `lib/screens/report_screen.dart` | **P0** | 146 context.appColors usages -- heaviest user | Already well-migrated; update chart styling to unified tokens | **M** |
| 4 | **Paywall Screen** | `lib/screens/paywall_screen.dart` | **P0** | 62 context.appColors + AppColors mixed | Unify to context.appColors; premium card styling | **M** |
| 5 | **Pursuit List Screen** | `lib/screens/pursuit_list_screen.dart` | **P1** | 31 context.appColors usages | Update pursuit card styling, glass effects | **M** |
| 6 | **Settings Screen** | `lib/screens/settings_screen.dart` | **P1** | 133 context.appColors usages | Clean and extensive; minor token updates | **S** |
| 7 | **Subscription Screen** | `lib/screens/subscription_screen.dart` | **P1** | 28 context.appColors usages | Update card styling | **M** |
| 8 | **Onboarding V2 Screen** | `lib/screens/onboarding_v2_screen.dart` | **P1** | 70 context.appColors usages | Update to glass cards, premium feel | **L** |
| 9 | **Profile Screen** | `lib/screens/profile_screen.dart` | **P1** | 119 context.appColors usages | Heavy usage, update glass effects | **L** |
| 10 | **Profile Modal** | `lib/screens/profile_modal.dart` | **P1** | 114 context.appColors + AppColors imports | Mixed patterns; unify access | **L** |
| 11 | **Income Wizard** | `lib/screens/income_wizard_screen.dart` | **P1** | 88 context.appColors usages | Good state; update input styling | **M** |
| 12 | **User Profile Screen** | `lib/screens/user_profile_screen.dart` | **P2** | 105 context.appColors usages | Update card styling | **M** |
| 13 | **Achievements Screen** | `lib/screens/achievements_screen.dart` | **P2** | 41 context.appColors + premium_effects imports | Migrate premium_effects to unified; update badges | **L** |
| 14 | **Habit Calculator** | `lib/screens/habit_calculator_screen.dart` | **P2** | 74 context.appColors + AppColors mixed | Unify access pattern | **M** |
| 15 | **Splash Screen** | `lib/screens/splash_screen.dart` | **P2** | Uses AppColors directly | Update to context-aware if needed | **S** |
| 16 | **Onboarding Screen** | `lib/screens/onboarding_screen.dart` | **P2** | 22 context.appColors usages | Light usage; update styling | **S** |
| 17 | **Onboarding Salary Day** | `lib/screens/onboarding_salary_day_screen.dart` | **P2** | 17 context.appColors usages | Minor updates | **S** |
| 18 | **Onboarding Pursuit** | `lib/screens/onboarding_pursuit_screen.dart` | **P2** | 21 context.appColors usages | Minor updates | **S** |
| 19 | **Onboarding Try** | `lib/screens/onboarding_try_screen.dart` | **P2** | 31 context.appColors usages | Minor updates | **S** |
| 20 | **Credit Purchase** | `lib/screens/credit_purchase_screen.dart` | **P2** | 38 context.appColors usages | Update paywall styling | **M** |
| 21 | **Currency Detail** | `lib/screens/currency_detail_screen.dart` | **P2** | 23 context.appColors usages | Update chart styling | **S** |
| 22 | **Lock Screen** | `lib/screens/lock_screen.dart` | **P3** | 15 context.appColors usages | Minor update | **S** |
| 23 | **Pin Setup Screen** | `lib/screens/pin_setup_screen.dart` | **P3** | 16 context.appColors usages | Minor update | **S** |
| 24 | **Import Statement** | `lib/screens/import_statement_screen.dart` | **P3** | 39 context.appColors usages | Update form styling | **M** |
| 25 | **Voice Input Screen** | `lib/screens/voice_input_screen.dart` | **P3** | 44 context.appColors + AppColors | Unify access | **M** |
| 26 | **Notification Settings** | `lib/screens/notification_settings_screen.dart` | **P3** | 43 context.appColors usages | Clean; minor tokens | **S** |
| 27 | **Simple Main Screen** | `lib/screens/simple/simple_main_screen.dart` | **P3** | 11 context.appColors usages | Minimal updates | **S** |
| 28 | **Simple Settings** | `lib/screens/simple/simple_settings_screen.dart` | **P3** | 26 context.appColors usages | Minor updates | **S** |
| 29 | **Simple Statistics** | `lib/screens/simple/simple_statistics_screen.dart` | **P3** | 30 context.appColors usages | Update chart styling | **S** |
| 30 | **Simple Transactions** | `lib/screens/simple/simple_transactions_screen.dart` | **P3** | 20 context.appColors usages | Minor updates | **S** |

### Key Widget Inventory

| # | Widget | File | Priority | Usages | What Changes | Effort |
|---|--------|------|----------|--------|-------------|--------|
| 1 | **Financial Snapshot Card** | `lib/widgets/financial_snapshot_card.dart` | **P0** | Hero component | Migrate from PsychologyColors + premium_effects to unified | **L** |
| 2 | **Decision Buttons** | `lib/widgets/decision_buttons.dart` | **P0** | Core UX flow | Migrate PsychologyColors -> context.appColors | **M** |
| 3 | **Result Card** | `lib/widgets/result_card.dart` | **P0** | Core UX flow | Migrate PsychologyColors (32 refs!) to unified | **L** |
| 4 | **Premium Nav Bar** | `lib/widgets/premium_nav_bar.dart` | **P0** | Every screen | Mixed AppColors + PsychologyColors; unify | **M** |
| 5 | **Streak Widget** | `lib/widgets/streak_widget.dart` | **P0** | Home screen | Migrate PsychologyColors (15 refs) | **M** |
| 6 | **AI FAB** | `lib/widgets/ai_fab.dart` | **P0** | Every screen | Minor updates | **S** |
| 7 | **Budget Summary Card** | `lib/widgets/budget_summary_card.dart` | **P0** | Home screen | 25 context.appColors; standardize | **M** |
| 8 | **Expense Form Content** | `lib/widgets/expense_form_content.dart` | **P0** | Core UX flow | 56 context.appColors; input styling | **L** |
| 9 | **AI Chat Sheet** | `lib/widgets/ai_chat_sheet.dart` | **P1** | 67 context.appColors; heavy | Update glass styling | **L** |
| 10 | **Quick Add Sheet** | `lib/widgets/quick_add_sheet.dart` | **P1** | 97 context.appColors; heaviest widget | Already well-done; minor token updates | **M** |
| 11 | **Add Expense Sheet** | `lib/widgets/add_expense_sheet.dart` | **P1** | 163 context.appColors; absolute heaviest | Well-migrated; standardize remaining | **M** |
| 12 | **Expense History Card** | `lib/widgets/expense_history_card.dart` | **P1** | 34 refs | Update list item styling | **S** |
| 13 | **Savings Pool Card** | `lib/widgets/savings_pool_card.dart` | **P1** | 32 refs | Glass card migration | **M** |
| 14 | **Budget Breakdown Card** | `lib/widgets/budget_breakdown_card.dart` | **P1** | 25 refs + premium_effects import | Remove premium_effects dependency | **M** |
| 15 | **Installment Summary Card** | `lib/widgets/installment_summary_card.dart` | **P1** | 54 refs + premium_effects import | Remove premium_effects dependency | **M** |
| 16 | **Paywall Variants** | `lib/widgets/paywall_variants.dart` | **P1** | 28 refs | Premium card styling | **M** |
| 17 | **Subscription Detail Sheet** | `lib/widgets/subscription_detail_sheet.dart` | **P1** | 43 refs | Glass sheet styling | **M** |
| 18 | **Create Pursuit Sheet** | `lib/widgets/create_pursuit_sheet.dart` | **P1** | quiet_luxury import | Migrate from QuietLuxury to unified | **M** |
| 19 | **Add Savings Sheet** | `lib/widgets/add_savings_sheet.dart` | **P1** | quiet_luxury import | Migrate from QuietLuxury to unified | **M** |
| 20 | **Redirect Savings Sheet** | `lib/widgets/redirect_savings_sheet.dart` | **P1** | quiet_luxury import | Migrate from QuietLuxury to unified | **M** |

---

## 8. Migration Plan

### Phase 1: Delete Dead Files, Merge Tokens (Day 1)

**Goal:** Eliminate dead code and create the new unified files.

**Step 1.1: Delete deprecated files**
```
DELETE: lib/theme/ai_finance_theme.dart
  - 0 active imports (only re-exported in barrel)
  - All references were already migrated to AppColors

DELETE: lib/theme/premium_theme.dart
  - Marked @Deprecated
  - 0 direct imports found
  - PremiumGlassCard, CountingNumber, GradientButton, GlowingIcon,
    PremiumPressable, PremiumShimmer, PremiumStatCard, PremiumIcons
    need to be relocated FIRST:
    * PremiumGlassCard -> app_effects.dart (as VGlassCard)
    * CountingNumber -> keep in a separate widget file or app_effects.dart
    * GradientButton -> app_effects.dart (as VGradientButton)
    * GlowingIcon -> app_effects.dart (as VGlowingIcon)
    * PremiumPressable -> app_effects.dart (as VPressable)
    * PremiumShimmer -> app_effects.dart (as VShimmer)
    * PremiumStatCard -> keep in financial_snapshot_card.dart
    * PremiumIcons -> app_effects.dart

DELETE: lib/theme/quiet_luxury.dart
  - All colors delegate to AppColors
  - 18 file imports that need migration:
    * pursuit_progress_visual.dart -> use context.appColors + AppDecoration
    * add_savings_sheet.dart -> use context.appColors
    * redirect_savings_sheet.dart -> use context.appColors
    * create_pursuit_sheet.dart -> use context.appColors
    * pursuit_card.dart -> use context.appColors + AppDecoration
    * pursuit_completion_modal.dart -> use context.appColors
  - GlassCard widget -> replaced by VGlassCard
  - AnimatedNumber widget -> replaced by CountingNumber (from premium_theme.dart)
  - Pressable widget -> replaced by VPressable
  - SubtleDivider widget -> inline SizedBox (trivial)
```

**Step 1.2: Create new unified files (empty shells)**
```
CREATE: lib/theme/app_colors.dart
CREATE: lib/theme/app_typography.dart
CREATE: lib/theme/app_effects.dart
```

**Step 1.3: Update barrel file**
```dart
// lib/theme/theme.dart
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_effects.dart';
export 'accessible_text.dart';
```

### Phase 2: Build New Unified Theme (Day 2)

**Step 2.1: Build `app_colors.dart`**
- Copy `AppColors` class from current `app_theme.dart`
- Copy `AppColorsLight` class from current `app_theme.dart`
- Add missing `PsychologyColors` tokens:
  - `primarySubtle`, `primaryMuted`, `secondarySubtle`
  - `successLight`, `successSubtle`, `warningLight`, `warningSubtle`
  - `errorLight`, `errorSubtle`, `infoLight`, `infoSubtle`
  - `surfaceInput`
- Copy `AppGradients` class from current `app_theme.dart`
- Add `LiquidGlassGradients` entries
- Copy `AppColorsExtension` and `_ThemeColors` (the context.appColors system)
- Add missing _ThemeColors properties for new tokens

**Step 2.2: Build `app_typography.dart`**
- Copy `AppFonts` class
- Copy `AppTheme` class (with darkTheme/lightTheme)
- Copy `PremiumModalRoute` and page transition classes
- Define `AppTypography` class with semantic text style getters
- Include financial amount helper with tabular figures

**Step 2.3: Build `app_effects.dart`**
- Define `AppSpacing` (merge from `Spacing`, `AppDesign` spacing, `PsychologySpacing`)
- Define `AppRadius` (merge from `Spacing` radius, `AppDesign` radius, `PsychologyRadius`)
- Define `AppShadows` (merge from `AppDesign` shadows, `PremiumShadows`, `PsychologyShadows`)
- Define `AppGlass` (merge from `PsychologyGlass`, `LiquidGlassColors` glass tokens)
- Define `AppAnimation` (merge from `AppAnimations`, `AnimationDurations`, `AnimationCurves`, `PsychologyAnimations`)
- Define `AppDecoration` (merge from `AppDesign` decorations, `PremiumDecorations`, `QuietLuxury` decorations)
- Move key widgets: `VGlassCard`, `VGradientButton`, `VPressable`, `VGlowingIcon`, `VShimmer`
- Copy `AnimatedStateMixin` from `app_animations.dart`

**Step 2.4: Verify compilation**
```bash
flutter analyze
```

### Phase 3: Migrate High-Traffic Screens (Day 3-5)

**Day 3: Core widgets**
1. `decision_buttons.dart` -- Replace `PsychologyColors.xxx` with `AppColors.xxx` (3 refs)
2. `result_card.dart` -- Replace `PsychologyColors.xxx` with `AppColors.xxx` (32 refs)
3. `streak_widget.dart` -- Replace `PsychologyColors.xxx` and `PsychologyAnimations.xxx` (15 refs)
4. `financial_snapshot_card.dart` -- Replace PsychologyColors (4 refs) + remove premium_effects import
5. `premium_nav_bar.dart` -- Replace PsychologyColors (3 refs), verify AppColors usage

**Day 4: Core screens**
1. `expense_screen.dart` -- Update all imports, verify context.appColors usage
2. `main_screen.dart` -- Minimal changes (13 refs already on context.appColors)
3. `report_screen.dart` -- Verify all 146 refs are on context.appColors

**Day 5: Form widgets & sheets**
1. `expense_form_content.dart` -- Verify 56 refs
2. `budget_summary_card.dart` -- Verify 25 refs
3. `add_expense_sheet.dart` -- Verify 163 refs
4. `quick_add_sheet.dart` -- Verify 97 refs

### Phase 4: Migrate Remaining Screens (Day 6-8)

**Day 6: P1 screens**
- Pursuit list, subscription, settings, onboarding V2, profile screens
- Replace all `quiet_luxury.dart` imports (6 pursuit-related files)

**Day 7: P1 widgets**
- AI chat sheet, paywall variants, savings-related sheets
- Budget breakdown card, installment summary card (remove premium_effects imports)

**Day 8: P2 screens and widgets**
- All remaining screens and widgets
- Run `flutter analyze` to catch any remaining issues

### Phase 5: Polish, Delete, and Test (Day 9-10)

**Day 9: Cleanup**
1. Delete all old files:
   ```
   DELETE: lib/theme/app_spacing.dart
   DELETE: lib/theme/app_animations.dart
   DELETE: lib/core/theme/psychology_design_system.dart
   DELETE: lib/core/theme/psychology_effects.dart
   DELETE: lib/core/theme/premium_effects.dart
   DELETE: lib/core/theme/liquid_glass.dart
   ```
2. Update `lib/core/theme/theme.dart`:
   ```dart
   export 'psychology_widgets.dart';
   ```
3. Global search for any remaining references to deleted files
4. Run `flutter analyze` -- zero issues required
5. Run `flutter build apk --release` -- verify successful build

**Day 10: Visual QA**
1. Test all P0 screens on:
   - iPhone 15 Pro (iOS dark mode)
   - iPhone 15 Pro (iOS light mode)
   - Pixel 8 (Android dark mode)
   - Pixel 8 (Android light mode)
2. Test accessibility:
   - Large text mode (1.5x scale)
   - VoiceOver/TalkBack
   - Reduced motion
3. Performance profiling:
   - BackdropFilter count per screen (max 2 visible)
   - Frame rate during page transitions (target: 60fps)
   - Memory usage comparison vs. before migration
4. Fix any visual regressions

---

## 9. Widget Consolidation

### 9.1 Glass Card Variants -> Single `VGlassCard`

| Current Widget | File | Action |
|----------------|------|--------|
| `GlassCard` | `quiet_luxury.dart` | **DELETE** -- replaced by `VGlassCard` |
| `PremiumGlassCard` | `premium_theme.dart` | **DELETE** -- replaced by `VGlassCard` |
| `LiquidGlassCard` | `liquid_glass.dart` | **KEEP shimmer/light-tracking logic** -- becomes `VGlassCard` advanced mode |
| `PsychologyGlassCard` | `psychology_effects.dart` | **DELETE** -- replaced by `VGlassCard` |
| `GlassCard` (PremiumEffects) | `premium_effects.dart` | **DELETE** -- replaced by `VGlassCard` |

**Canonical implementation: `VGlassCard`** in `app_effects.dart`

```dart
class VGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;       // Default: EdgeInsets.all(20)
  final double borderRadius;      // Default: 20
  final double blurSigma;         // Default: 20 (0 = no blur, performance mode)
  final Color? glowColor;         // Optional colored glow
  final double glowIntensity;     // Default: 0.25
  final bool showHighlight;       // Top highlight effect
  final VoidCallback? onTap;      // Tap callback
  final EdgeInsets? margin;       // Outer margin
  // ...
}
```

### 9.2 Effect Widget Consolidation

| Current Widget | File | Action |
|----------------|------|--------|
| `BreathingGlow` (psychology) | `psychology_effects.dart` | **KEEP** as canonical |
| `BreatheGlow` (premium) | `premium_effects.dart` | **DELETE** -- duplicate |
| `PulseGlow` (psychology) | `psychology_effects.dart` | **KEEP** as canonical |
| `PulseGlow` (premium) | `premium_effects.dart` | **DELETE** -- duplicate |
| `ShimmerEffect` (premium) | `premium_effects.dart` | **KEEP** as canonical |
| `PsychologyShimmer` | `psychology_effects.dart` | **DELETE** -- duplicate of ShimmerEffect |
| `SuccessCelebration` | `psychology_effects.dart` | **KEEP** (unique) |

### 9.3 Button Widget Consolidation

| Current Widget | File | Action |
|----------------|------|--------|
| `GradientButton` | `premium_theme.dart` | **MOVE** to `app_effects.dart` as `VGradientButton` |
| `Pressable` | `quiet_luxury.dart` | **DELETE** -- replaced by `VPressable` |
| `PremiumPressable` | `premium_theme.dart` | **MOVE** to `app_effects.dart` as `VPressable` |
| `LiquidGlassButton` | `liquid_glass.dart` | **KEEP** specialized -- move to `app_effects.dart` |

### 9.4 Misc Widget Consolidation

| Current Widget | File | Action |
|----------------|------|--------|
| `CountingNumber` | `premium_theme.dart` | **MOVE** to `app_effects.dart` |
| `AnimatedNumber` | `quiet_luxury.dart` | **DELETE** -- replaced by `CountingNumber` |
| `GlowingIcon` | `premium_theme.dart` | **MOVE** to `app_effects.dart` as `VGlowingIcon` |
| `PremiumShimmer` | `premium_theme.dart` | **MOVE** to `app_effects.dart` as `VShimmer` |
| `SubtleDivider` | `quiet_luxury.dart` | **DELETE** -- inline `SizedBox(height: 16)` |
| `PremiumStatCard` | `premium_theme.dart` | **MOVE** to `financial_snapshot_card.dart` (co-locate) |
| `PremiumIcons` | `premium_theme.dart` | **MOVE** to `app_effects.dart` |

### 9.5 Psychology Widgets (KEEP)

These widgets in `lib/core/theme/psychology_widgets.dart` are **feature widgets** (not theme primitives) and should remain in their own file, with updated imports:

| Widget | Usage | Action |
|--------|-------|--------|
| `PremiumHeroCard` | Expense screen hero | **KEEP** -- update imports |
| `PremiumDecisionButtons` | Expense screen | **KEEP** -- update imports |
| `PremiumStreakBadge` | Home screen | **KEEP** -- update imports |
| `PremiumCategoryChip` | Form chips | **KEEP** -- update imports |
| `PremiumAmountDisplay` | Result display | **KEEP** -- update imports |
| `PremiumProgressRing` | Pursuit cards | **KEEP** -- update imports |
| `PremiumSectionHeader` | Section headers | **KEEP** -- update imports |
| `PremiumTimeDisplay` | Work hours display | **KEEP** -- update imports |

### 9.6 New Naming Convention

All canonical theme widgets use the `V` prefix (for Vantag):

| Old Name | New Name | Reason |
|----------|----------|--------|
| `PremiumGlassCard` | `VGlassCard` | Shorter, brand-specific |
| `GradientButton` | `VGradientButton` | Consistent namespace |
| `PremiumPressable` | `VPressable` | Consistent namespace |
| `GlowingIcon` | `VGlowingIcon` | Consistent namespace |
| `PremiumShimmer` | `VShimmer` | Consistent namespace |
| `CountingNumber` | `VCountingNumber` | Consistent namespace |
| `PremiumIcons` | `VIcons` | Consistent namespace |

Feature widgets in `psychology_widgets.dart` keep the `Premium` prefix as they represent premium-tier UI.

---

## 10. Access Pattern Standardization

### 10.1 The One True Pattern

**For theme-aware colors (in widget build methods):**
```dart
// CORRECT - always use this in widgets
final colors = context.appColors;
color: colors.primary
color: colors.textSecondary
color: colors.success
```

**For static colors (in models, services, constants):**
```dart
// CORRECT - when no BuildContext is available
color: AppColors.primary
color: AppColors.categoryFood
```

**NEVER use these patterns after migration:**
```dart
// WRONG - all of these are deprecated/deleted
PsychologyColors.primary        // -> AppColors.primary
PsychologyColors.decisionYes    // -> AppColors.decisionYes
PsychologyTypography.bodyMedium // -> Theme.of(context).textTheme.bodyMedium
PsychologyAnimations.pulseMin   // -> AppAnimation.pulseMin
PsychologySpacing.md            // -> AppSpacing.md
PremiumTheme.primary             // -> AppColors.primary (already deprecated)
QuietLuxury.textPrimary          // -> AppColors.textPrimary (already alias)
LiquidGlassColors.primary        // -> AppColors.primary (duplicate)
PremiumColors.purple              // -> AppColors.primary (duplicate)
```

### 10.2 Migration Strategy

**Step 1: Automated find-and-replace (safe patterns)**

These are direct 1:1 replacements where the color value is identical:

```
PsychologyColors.primary        -> AppColors.primary
PsychologyColors.primaryLight   -> AppColors.primaryLight
PsychologyColors.primaryDark    -> AppColors.primaryDark
PsychologyColors.primarySubtle  -> AppColors.primarySubtle
PsychologyColors.primaryMuted   -> AppColors.primaryMuted
PsychologyColors.secondary      -> AppColors.secondary
PsychologyColors.secondaryLight -> AppColors.secondaryLight
PsychologyColors.secondaryDark  -> AppColors.secondaryDark
PsychologyColors.secondarySubtle -> AppColors.secondarySubtle
PsychologyColors.success        -> AppColors.success
PsychologyColors.successLight   -> AppColors.successLight
PsychologyColors.warning        -> AppColors.warning
PsychologyColors.warningLight   -> AppColors.warningLight
PsychologyColors.error          -> AppColors.error
PsychologyColors.errorLight     -> AppColors.errorLight
PsychologyColors.info           -> AppColors.info
PsychologyColors.infoLight      -> AppColors.infoLight
PsychologyColors.decisionYes    -> AppColors.decisionYes
PsychologyColors.decisionThinking -> AppColors.decisionThinking
PsychologyColors.decisionNo     -> AppColors.decisionNo
PsychologyColors.textPrimary    -> AppColors.textPrimary
PsychologyColors.textSecondary  -> AppColors.textSecondary
PsychologyColors.textTertiary   -> AppColors.textTertiary
PsychologyColors.background     -> AppColors.background
PsychologyColors.surface        -> AppColors.surface
PsychologyColors.surfaceElevated -> AppColors.surfaceElevated
PsychologyColors.surfaceOverlay -> AppColors.surfaceOverlay
PsychologyColors.surfaceInput   -> AppColors.surfaceInput
```

**Note on surface value differences:** `PsychologyColors.surface` is `#0F0D17` while `AppColors.surface` is `#12101A`. These need to be reconciled. The `PsychologyColors` values define a 4-tier system (`#0F0D17` -> `#1A1726` -> `#252233` -> `#18151F`) while `AppColors` uses (`#12101A` -> `#1A1725` -> `#231F2E`).

**Resolution:** Adopt the `PsychologyColors` surface ladder as it provides finer gradation and darker base (better for OLED). Update `AppColors.surface` from `#12101A` to `#0F0D17`, and add the intermediate tiers.

**Step 2: Typography migration**

```
PsychologyTypography.displayLarge  -> Theme.of(context).textTheme.displayLarge!
PsychologyTypography.headlineLarge -> Theme.of(context).textTheme.headlineLarge!
PsychologyTypography.bodyMedium    -> Theme.of(context).textTheme.bodyMedium!
PsychologyTypography.labelSmall    -> Theme.of(context).textTheme.labelSmall!
// etc.
```

Or, for semantic shortcuts:
```dart
// In AppTypography
static TextStyle financialHero(BuildContext context) =>
    Theme.of(context).textTheme.displayLarge!.copyWith(
      fontFeatures: [FontFeature.tabularFigures()],
    );
```

**Step 3: Animation/spacing migration**

```
PsychologyAnimations.standardDuration -> AppAnimation.standard
PsychologyAnimations.fastDuration     -> AppAnimation.fast
PsychologyAnimations.pulseMin         -> AppAnimation.pulseMin
PsychologySpacing.md                  -> AppSpacing.md
PsychologyRadius.card                 -> AppRadius.lg
```

**Step 4: Import cleanup**

For each file being migrated:
1. Remove: `import '../core/theme/psychology_design_system.dart';`
2. Remove: `import '../core/theme/premium_effects.dart';`
3. Remove: `import '../theme/quiet_luxury.dart';`
4. Remove: `import '../theme/premium_theme.dart';`
5. Ensure: `import '../theme/theme.dart';` is present (barrel file)

**Step 5: Verification**

After all migrations, run:
```bash
# Verify no old imports remain
grep -r "psychology_design_system" lib/ --include="*.dart"
grep -r "premium_effects" lib/ --include="*.dart"
grep -r "quiet_luxury" lib/ --include="*.dart"
grep -r "premium_theme" lib/ --include="*.dart"
grep -r "ai_finance_theme" lib/ --include="*.dart"
grep -r "PsychologyColors\." lib/ --include="*.dart"
grep -r "PremiumTheme\." lib/ --include="*.dart"
grep -r "QuietLuxury\." lib/ --include="*.dart"
grep -r "LiquidGlassColors\." lib/ --include="*.dart"
grep -r "PremiumColors\." lib/ --include="*.dart"

# All should return 0 results (except psychology_widgets.dart which is kept)

# Verify build
flutter analyze
flutter build apk --release
```

### 10.3 Context.appColors Extension Enhancement

The current `_ThemeColors` class needs expansion to cover all new tokens:

```dart
class _ThemeColors {
  final bool _isDark;
  const _ThemeColors(this._isDark);

  // === Surfaces (full tier system) ===
  Color get background => _isDark ? AppColors.background : AppColorsLight.background;
  Color get surface => _isDark ? AppColors.surface : AppColorsLight.surface;
  Color get surfaceElevated => _isDark ? AppColors.surfaceElevated : AppColorsLight.surfaceElevated;
  Color get surfaceOverlay => _isDark ? AppColors.surfaceOverlay : AppColorsLight.surfaceOverlay;
  Color get surfaceInput => _isDark ? AppColors.surfaceInput : AppColorsLight.surfaceInput;
  Color get cardBackground => _isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;

  // === Brand (same in both themes) ===
  Color get primary => AppColors.primary;
  Color get primaryDark => AppColors.primaryDark;
  Color get primaryLight => _isDark ? AppColors.primaryLight : AppColorsLight.primaryLight;
  Color get primarySubtle => AppColors.primarySubtle;
  Color get primaryMuted => AppColors.primaryMuted;
  Color get secondary => AppColors.secondary;
  Color get secondaryDark => AppColors.secondaryDark;
  Color get secondaryLight => AppColors.secondaryLight;
  Color get secondarySubtle => AppColors.secondarySubtle;
  Color get accent => AppColors.accent;
  Color get gold => AppColors.gold;

  // === Text ===
  Color get textPrimary => _isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
  Color get textSecondary => _isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
  Color get textTertiary => _isDark ? AppColors.textTertiary : AppColorsLight.textTertiary;
  Color get textMuted => _isDark ? AppColors.textMuted : AppColorsLight.textMuted;

  // === Status ===
  Color get success => AppColors.success;
  Color get successLight => AppColors.successLight;
  Color get warning => AppColors.warning;
  Color get warningLight => AppColors.warningLight;
  Color get error => AppColors.error;
  Color get errorLight => AppColors.errorLight;
  Color get info => AppColors.info;
  Color get infoLight => AppColors.infoLight;

  // === Decision ===
  Color get decisionYes => AppColors.decisionYes;
  Color get decisionThinking => AppColors.decisionThinking;
  Color get decisionNo => AppColors.decisionNo;

  // === Glass ===
  Color get glassWhite => _isDark ? AppColors.glassWhite : AppColorsLight.glassBlack;
  Color get glassBorder => _isDark ? AppColors.glassBorder : AppColorsLight.glassBorder;
  Color get glassHighlight => AppColors.glassHighlight;
  Color get cardBackgroundGlass => _isDark ? AppColors.cardBackgroundGlass : AppColorsLight.cardBackgroundGlass;
  Color get cardBorder => _isDark ? AppColors.cardBorder : AppColorsLight.cardBorder;
  Color get cardShadow => _isDark ? AppColors.cardShadow : AppColorsLight.cardShadow;

  // === Gradients ===
  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMid, gradientEnd],
  );

  // Helper
  Color get gradientStart => _isDark ? AppColors.gradientStart : AppColorsLight.gradientStart;
  Color get gradientMid => _isDark ? AppColors.gradientMid : AppColorsLight.gradientMid;
  Color get gradientEnd => _isDark ? AppColors.gradientEnd : AppColorsLight.gradientEnd;

  // === Divider / Misc ===
  Color get divider => AppColors.divider;
  Color get shimmer => AppColors.shimmer;
  Color get overlay => AppColors.overlay;
}
```

---

## Appendix A: File Size Comparison

### Before (14 files, ~8,400 lines)

| File | Lines | Status |
|------|-------|--------|
| `app_theme.dart` | 1,362 | SPLIT |
| `psychology_design_system.dart` | 799 | DELETE (merge) |
| `liquid_glass.dart` | 1,164 | DELETE (merge) |
| `premium_effects.dart` | 1,581 | DELETE (merge) |
| `psychology_effects.dart` | 998 | DELETE (merge) |
| `psychology_widgets.dart` | 1,366 | REFACTOR (V-prefix rename) |
| `premium_theme.dart` | 683 | DELETE |
| `quiet_luxury.dart` | 292 | DELETE |
| `ai_finance_theme.dart` | 783 | DELETE |
| `app_spacing.dart` | 219 | DELETE (merge) |
| `app_animations.dart` | 133 | DELETE (merge) |
| `accessible_text.dart` | 213 | KEEP |
| `theme.dart` (lib/theme) | 8 | UPDATE |
| `theme.dart` (lib/core/theme) | 7 | UPDATE |

### After (3+2 files, ~2,700 lines estimated)

| File | Est. Lines | Content |
|------|------------|---------|
| `app_colors.dart` | ~400 | All colors + gradients + context extension |
| `app_typography.dart` | ~300 | Typography + ThemeData + page transitions |
| `app_effects.dart` | ~600 | Spacing + radius + shadows + glass + animations + decorations + canonical widgets |
| `accessible_text.dart` | ~213 | Unchanged |
| `psychology_widgets.dart` | ~1,200 | Feature widgets (updated imports) |

**Total: ~2,700 lines (68% reduction from 8,400)**

---

## Appendix B: Competitor Benchmark Summary

| Feature | Vantag (Current) | Vantag (Target) | Revolut | N26 | Cleo |
|---------|------------------|-----------------|---------|-----|------|
| Dark BG | `#050508` | `#050508` | `#191C1F` | `#1A1A1A` | `#0A0B0E` |
| Primary | `#8B5CF6` (purple) | `#8B5CF6` (purple) | `#7F84F6` (indigo) | `#36A18B` (teal) | `#AD6BFF` (purple) |
| Glass effects | Fragmented 3 impls | Unified VGlassCard | Native blur | Minimal | Moderate |
| Typography | System fonts | System fonts | Inter/custom | System | Custom |
| Financial nums | Basic | Tabular figures | Tabular figures | Tabular figures | Custom |
| Animation | 3 systems | 1 unified system | Polished | Minimal | Playful |
| Surface tiers | 3 levels | 4 levels | 3 levels | 2 levels | 3 levels |
| Accessibility | AccessibleText | AccessibleText | Basic | WCAG AA | Basic |

---

## Appendix C: Risk Register

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Visual regression on migration | High | Medium | Screen-by-screen QA; compare screenshots before/after |
| Performance degradation from glass effects | Medium | Low | Strict 2-BackdropFilter budget; fallback to solid colors |
| Breaking import during migration | High | High | Phase approach; compile-check after each file; keep old barrel exports temporarily |
| Turkish text rendering issues | Medium | Low | fontFamilyFallback chain preserved; test on real devices |
| Light mode inconsistencies | Medium | Medium | Test both modes in each phase; AppColorsLight parity check |
| Third-party package conflicts | Low | Low | `liquid_glass_widgets` package used on expense_screen; verify compatibility |

---

## Appendix D: Definition of Done

A screen/widget is considered "migrated" when:

1. All color references use `context.appColors.xxx` or `AppColors.xxx` only
2. No imports from deleted files (`psychology_design_system`, `premium_effects`, `quiet_luxury`, `premium_theme`, `ai_finance_theme`)
3. Glass cards use `VGlassCard` (not `GlassCard`, `PremiumGlassCard`, `PsychologyGlassCard`)
4. All text styles use `Theme.of(context).textTheme.xxx` or `AppTypography.xxx`
5. All spacing uses `AppSpacing.xxx` or `AppRadius.xxx`
6. All animations use `AppAnimation.xxx`
7. `flutter analyze` passes with zero issues
8. Visual diff shows no unintended changes
9. Both dark and light mode tested
10. Accessibility scaling tested at 1.5x

---

*This blueprint was synthesized from Theme Archaeologist and Competitor Analyst findings, grounded in actual codebase analysis of 14 theme files, 31 screens, and 78 widgets across the Vantag Flutter application.*
