# VANTAG COMPLETE VISUAL OVERHAUL — Master Prompt Document
## For Claude Code Agent Teams Execution

---

## CONTEXT FOR CLAUDE CODE

You are redesigning a fintech app called Vantag. The app converts spending into work hours (money = time philosophy). It's a Flutter app targeting iOS App Store featuring and Apple Design Awards level quality.

**Current state:** The app has severe visual bugs and inconsistent design. Every screen has different color language, letter spacing is broken everywhere (text looks like "R a p o r l a r" instead of "Raporlar"), glass effects are invisible, and there's no cohesive visual identity.

**Target state:** A premium fintech app that looks like it was built by a 50-person design team at a top bank. Think Revolut's dark mode meets Apple's Liquid Glass. Every screen should feel like it belongs to the same app.

**Design philosophy reference:** Apple Design Awards Visuals & Graphics winners share these traits:
- Stunning but CONSISTENT imagery across all screens
- Skillfully drawn interfaces with purposeful contrast
- High-quality animations that serve function, not decoration
- A distinctive and COHESIVE theme throughout

---

## PHASE 0: CRITICAL GLOBAL FIXES (Do FIRST, before anything else)

### FIX A: LETTER SPACING — #1 PRIORITY

This is the most visible bug. Every screen shows broken text with huge gaps between letters.

```bash
grep -rn "letterSpacing" lib/ --include="*.dart" | grep -v "lib 2/" | grep -v "//"
```

**Rules — apply to EVERY occurrence found:**

| Text Type | Font Size | letterSpacing Value |
|-----------|-----------|-------------------|
| Display/Hero numbers | 36-52px | -1.5 to -2.0 |
| Large titles | 24-34px | -0.5 to -1.0 |
| Section titles | 18-22px | -0.3 to -0.5 |
| Body text | 14-17px | 0 (or REMOVE property) |
| Small body | 12-13px | 0 (or REMOVE property) |
| ALL-CAPS micro labels | 10-11px | 0.8 to 1.2 (ONLY exception) |
| Financial numbers | any size | -0.5 to -1.5 |
| Button text | any size | 0 to 0.3 |

**Also check lib/theme/app_typography.dart** — if there's a base TextTheme with letterSpacing set globally on bodyLarge, bodyMedium, titleLarge etc., REMOVE those letterSpacing values. Only individual ALL-CAPS labels should have positive letterSpacing.

**Also check for `fontFeatures: [FontFeature.tabularFigures()]`** — this is fine to keep for number alignment, but make sure it's paired with negative letterSpacing (-0.5 to -1.5) so numbers don't look spaced out.

### FIX B: REMOVE liquid_glass_widgets PACKAGE

The `liquid_glass_widgets` package is configured with ALL parameters at zero (thickness:0, blur:0, glassColor:transparent). It adds visual noise and complexity for zero benefit.

1. In `pubspec.yaml`: Remove `liquid_glass_widgets: ^0.1.5-dev.11` and `liquid_glass_renderer: ^0.2.0-dev.4`
2. Run `flutter pub get`
3. Find ALL files importing liquid_glass_widgets: `grep -rn "liquid_glass" lib/ --include="*.dart"`
4. In each file, replace:
   - `lg.LiquidGlassLayer(settings: ..., child: X)` → just `X` (unwrap the child)
   - `lg.GlassContainer(width: W, height: H, shape: ..., child: X)` → `Container(width: W, height: H, decoration: BoxDecoration(color: VantColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.08))), child: X)`
   - `lg.GlassCard(shape: ..., child: X)` → `VGlassCard(child: X)` or `VGlassStyledContainer(child: X)`
   - `lg.GlassButton.custom(...)` → normal `GestureDetector` + `Container` with Vant styling
   - Remove ALL `lg.` prefixed widget usage
5. `flutter analyze` — must be 0 errors

### FIX C: UNIFIED COLOR LANGUAGE

The app currently uses: orange in reports, cyan/teal in settings and paywall, green in hero card, yellow in achievements. This is chaos. 

**The rule: Violet (#8B5CF6) is the ONLY brand accent color.** All other colors are functional only:
- Success/positive: #10B981 (green) — ONLY for positive financial indicators
- Warning: #F59E0B (amber) — ONLY for caution states
- Error/spending: #EF4444 (red) — ONLY for negative indicators, overspending
- Info: #3B82F6 (blue) — ONLY for informational badges

**Specifically fix:**
- Settings "Davet Et" banner: cyan/teal gradient → violet gradient using VantGradients.primaryButton
- Report stat cards icon backgrounds: random orange/cyan/yellow → all use VantColors.primary variations
- Paywall "7 GÜN ÜCRETSİZ" badge: green → VantColors.primary
- Paywall free trial card border: green → VantColors.primary  
- Achievements stat boxes: gold/purple/orange tops → all VantColors.primary with varying opacity
- Profile "Kurtarılan Zaman" card: teal gradient → violet gradient
- Category icons in report: keep category-specific colors, they're functional

---

## PHASE 1: GLASS CARD VISIBILITY

### Update VGlassCard in app_effects.dart

The current glass cards are nearly invisible. Increase fill and border opacity:

**_getFill() changes:**
```dart
case VantGlassVariant.hero:
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x30FFFFFF), // was 0x1A (10%) → now 19%
      Color(0x18FFFFFF), // was 0x0F (6%) → now 10%
    ],
  );
case VantGlassVariant.standard:
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x22FFFFFF), // was 0x15 (8%) → now 13%
      Color(0x12FFFFFF), // was 0x0A (4%) → now 7%
    ],
  );
case VantGlassVariant.subtle:
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x18FFFFFF), // was 0x0A (4%) → now 10%
      Color(0x0DFFFFFF), // was 0x05 (2%) → now 5%
    ],
  );
```

**_getBorder() changes:**
```dart
case VantGlassVariant.hero:
  return Border.all(color: Color(0x35FFFFFF), width: 1.5); // was 0x20, 1px
case VantGlassVariant.standard:
  return Border.all(color: Color(0x25FFFFFF), width: 1); // was 0x15
case VantGlassVariant.subtle:
  return Border.all(color: Color(0x18FFFFFF), width: 0.5); // was 0x0F
```

**Add top highlight to VGlassCard.build():**
Change the child of BackdropFilter from just `Container(padding: padding, child: child)` to:
```dart
Container(
  decoration: BoxDecoration(/* existing gradient + border */),
  child: Stack(
    children: [
      // Top highlight shine — makes glass look like GLASS
      Positioned(
        top: 0, left: 0, right: 0, height: 50,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: variant == VantGlassVariant.hero ? 0.20 : 0.14),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      Padding(padding: padding, child: child),
    ],
  ),
)
```

**Also update VGlassStyledContainer** (the non-blur version):
- Fill: `Color(0x0A) → Color(0x18)` and `Color(0x05) → Color(0x0D)`
- Border: `Color(0x0F), 0.5px → Color(0x20FFFFFF), 1px`
- Add the same top highlight gradient as a Stack child

---

## PHASE 2: SCREEN-BY-SCREEN DESIGN SPEC

### 2.1 EXPENSE SCREEN (Home) — expense_screen.dart

**Background:** Pure OLED black (#050508) — KEEP as-is, this is correct.

**Hero Card (PremiumHeroCard in app_effects.dart):**
- Outer glow: ALWAYS violet-first. Add permanent `BoxShadow(color: VantColors.primary.withValues(alpha: 0.35), blurRadius: 40, spreadRadius: -2)` as the FIRST shadow.
- Budget glow becomes secondary and softer: `budgetColor.withValues(alpha: _breathingAnimation.value * 0.4)` (reduce from 1.0 to 0.4)
- Card gradient: Increase primary alpha from 0.12 to 0.25 for first stop, 0.04 to 0.10 for second stop
- Result: Card always reads as "violet glass" with a subtle budget-color accent, not the other way around

**Recent Expenses list items:**
- Each expense card: use VGlassStyledContainer with subtle variant
- Category icon: 40x40 circle with category color at 15% opacity background
- Amount text: financial number style, right-aligned, white, -1 letterSpacing
- Time conversion ("1.2 saat"): VantColors.textTertiary, small text below amount

**Navigation bar (premium_nav_bar.dart):**
- Glass blur background: sigma 20
- Active tab: VantColors.primary icon + subtle purple glow underneath
- Inactive tabs: VantColors.textTertiary
- Center "+" button: Solid VantColors.primary, circular, elevated with purple glow shadow
- NO cyan, NO teal anywhere in the nav bar

### 2.2 REPORT SCREEN — report_screen.dart

**Header:** "Raporlar" large title, white, letterSpacing: -0.5

**Time filter chips (Bu Hafta / Bu Ay / Tüm Zamanlar):**
- Container: VGlassStyledContainer style
- Active chip: VantColors.primary fill at 25%, white text
- Inactive: transparent, textTertiary
- NO purple/violet solid fill — too loud. Just subtle glass with primary tint.

**Stat cards (4-grid: Toplam Harcama, Toplam Tasarruf, Harcama Sayısı, Vazgeçme Oranı):**
- Each card: VGlassStyledContainer
- Icon: 40x40 rounded rect, VantColors.primary at 15% background, icon in VantColors.primary
- ALL four cards use the SAME icon treatment (just different icons) — NOT different colors per card
- Large number: 28px, w700, letterSpacing: -1.0, VantColors.textPrimary
- Unit/currency: same line as number, 16px, VantColors.textSecondary
- Sub-label: 12px, VantColors.textTertiary

**Month comparison card:**
- VGlassCard.hero variant with violet glow
- "Bu Ay" / "Geçen Ay" as two columns
- Numbers: large financial style

### 2.3 SETTINGS SCREEN — settings_screen.dart

**"Arkadaşlarını Davet Et" banner:**
- REMOVE cyan/teal gradient completely
- Replace with: `VantGradients.primaryButton` (violet gradient)
- Or a subtle glass card with violet tint: VGlassCard with glowColor: VantColors.primary

**Section headers ("GENEL", "BİLDİRİMLER", "GÜVENLİK"):**
- Small vertical bar: VantColors.primary (not random colors)
- Text: ALL-CAPS, 11px, w600, letterSpacing: 1.0, VantColors.primary

**Settings rows:**
- Grouped in VGlassStyledContainer sections
- Each row: icon (VantColors.primary tint), label, value/chevron on right
- Dividers: 0.5px, Colors.white at 5% opacity
- Toggle switches: when ON = VantColors.primary fill

### 2.4 PROFILE SCREEN — profile_screen.dart + profile_modal.dart

**Avatar area:**
- Circle border: VantColors.primary (currently correct)
- Camera icon badge: VantColors.primary background

**Quick action chips (Fotoğraf, Maaş, Çalışma Saati):**
- VGlassStyledContainer style with subtle variant
- Icon + text in VantColors.textSecondary
- On tap: violet highlight

**"Kurtarılan Zaman" hero card:**
- REMOVE teal/cyan gradient
- Use VGlassCard.hero with glowColor: VantColors.primary
- Number: large, violet glow shadow
- Label: textTertiary

**Stat cards (Üyelik Süresi, Kazanılan Rozet):**
- VGlassStyledContainer
- Icon: VantColors.primary
- Number: large, textPrimary

**Auth buttons (Google ile Bağla, Apple ile Bağla):**
- VGlassStyledContainer
- Button: outlined style with VantColors.primary border

### 2.5 PAYWALL SCREEN — paywall_screen.dart

**"VANTAG PRO" badge:**
- Violet/purple background pill — KEEP, this is correct

**Free trial card:**
- Border: VantColors.primary (NOT green)
- Badge "7 GÜN ÜCRETSİZ": VantColors.primary background (NOT green)
- Checkmark icon: VantColors.primary (NOT green)
- Card background: VGlassCard.hero with violet tint

**Feature comparison table:**
- Container: VGlassStyledContainer
- "Pro" header: VantColors.primary
- Checkmarks: VantColors.primary (NOT green/teal)
- X marks: VantColors.error (red) — this is correct

**CTA button:**
- Full width, VantGradients.primaryButton
- Text: white, bold
- Purple glow shadow underneath

**Trust badges (Güvenli Ödeme, Şifreli, İptal):**
- Icons: VantColors.textTertiary
- Text: VantColors.textMuted

### 2.6 ACHIEVEMENTS SCREEN — achievements_screen.dart

**Top stat boxes (Total XP, Rozetler, Gün Seri):**
- ALL three: VGlassStyledContainer with same style
- Icon on top: VantColors.primary (star, medal, flame — all same violet tint, NOT gold/purple/orange)
- Number: large, w700, textPrimary
- Label: small, textTertiary

**Level card:**
- VGlassCard.hero with violet gradient
- Level badge: VantColors.primary circle
- XP bar: VantColors.primary fill with VantColors.primary glow
- NOT purple solid — violet glass style

**Badge cards grid:**
- Locked: VGlassStyledContainer, dimmed (opacity 0.5), lock icon centered
- Unlocked: VGlassStyledContainer with subtle primary glow
- Badge level label ("Bronz 1"): small, textTertiary
- Progress bar under each: VantColors.primary (NOT orange)
- All badges same visual treatment — CONSISTENCY

### 2.7 ADD EXPENSE SHEET — add_expense_sheet.dart

**Sheet background:** VGlassSheet (blur 30, dark surface)

**Amount input:**
- Large number: 44px, w700, letterSpacing: -1.5, textPrimary
- Cursor: VantColors.primary
- Currency badge: VGlassStyledContainer.subtle

**Camera/Mic buttons:**
- VGlassStyledContainer circles
- Icon color: VantColors.primary (NOT teal/cyan)

**Toggle options (Bilinçli Tercih, Zorunlu Gider, Taksitli Alım):**
- Each row: VGlassStyledContainer
- Toggle OFF: neutral dark
- Toggle ON: VantColors.primary fill

**Category dropdown:**
- VGlassStyledContainer for the field
- Dropdown items: same glass style

**Submit button:**
- Full width, VantGradients.primaryButton
- Purple glow

### 2.8 ONBOARDING — onboarding_screen.dart, onboarding_v2_screen.dart

**All 3 pages:**
- Background: OLED black
- Center icon: large circle with VantColors.primary at 10% fill, VantColors.primary border, icon inside
- Title: 28px, w700, letterSpacing: -0.5, textPrimary
- Subtitle: 16px, textSecondary
- Page dots: active = VantColors.primary, inactive = textMuted

**Decision buttons (Vazgeçtim/Düşünüyorum/Aldım):**
- These use the psychology colors (cyan, amber, red) — this is INTENTIONAL and CORRECT. Keep these.
- BUT the icon backgrounds should be glass-styled, not flat solid colors
- Each: VGlassStyledContainer with the respective decision color as glowColor at 0.15 intensity

**"Başla" button (last page):**
- VantGradients.primaryButton — currently correct
- Purple glow — KEEP

**Onboarding V2 (Hoş geldin form):**
- Input fields: VGlassStyledContainer with surfaceInput background
- Day selector chips: VGlassStyledContainer, active = VantColors.primary fill
- "Ek Gelir Ekle" button: outlined, VantColors.primary border

### 2.9 ALL BOTTOM SHEETS (add_income, add_savings, add_subscription, quick_add, subscription_detail, etc.)

**Universal sheet pattern:**
- Wrap with VGlassSheet (blur 30)
- Handle bar: white 20% opacity, 40x4px, centered
- Title: 20px, w700, letterSpacing: -0.3
- Input fields: VGlassStyledContainer with surfaceInput fill
- Buttons: VantGradients.primaryButton for primary, VGlassStyledContainer for secondary
- Close button (X): VGlassStyledContainer circle, textSecondary icon

### 2.10 NAVIGATION BAR — premium_nav_bar.dart

- Background: VGlassCard.nav variant (glass blur, dark surface 95%)
- Labels: 10px, w500
- Active: VantColors.primary icon + label, subtle glow dot underneath
- Inactive: VantColors.textTertiary
- Center FAB (+): 56x56 circle, VantColors.primary solid fill, white icon, purple glow shadow
- NO gradient on nav bar background, NO purple/violet solid bar — glass only

---

## PHASE 3: MICRO-INTERACTION & ANIMATION POLISH

### 3.1 Transitions
- Page transitions: 300ms ease-out-cubic slide-up
- Sheet opens: 400ms with slight bounce (easeOutBack)
- Card press: scale to 0.97, 100ms

### 3.2 Number Animations
- All financial numbers: count-up animation on appear (800ms, easeOutCubic)
- Use tabular figures for number alignment
- Negative letterSpacing (-1 to -1.5) for premium tight look

### 3.3 Glow Animations
- Hero card: breathing glow (3s cycle) using VantColors.primary — already exists, just ensure violet
- Achievement unlock: pulse + scale (1.03x) with confetti
- Streak counter: subtle pulse when active

---

## EXECUTION INSTRUCTIONS

### Agent Team Split (3 agents):

**Agent 1: Global Fixes (Phase 0)**
- Fix ALL letterSpacing across entire codebase (grep + fix every file)
- Remove liquid_glass_widgets package completely
- Fix color consistency (replace all cyan/teal/green brand usage with violet)
- Verify: `flutter analyze` = 0 errors

**Agent 2: Glass & Components (Phase 1 + nav bar)**
- Update VGlassCard fill/border/highlight as specified
- Update VGlassStyledContainer to match
- Fix PremiumHeroCard violet dominance
- Fix premium_nav_bar.dart
- Verify: `flutter analyze` = 0 errors

**Agent 3: Screen-by-Screen Polish (Phase 2)**
- Apply design spec to: report_screen, settings_screen, profile_screen/profile_modal, paywall_screen, achievements_screen, add_expense_sheet, onboarding screens
- Ensure every screen follows the Vant* color/glass system
- No hardcoded colors — everything through VantColors
- Verify: `flutter analyze` = 0 errors

### Final Verification (after all agents):
```bash
# No legacy color references
grep -rn "0xFF06B6D4\|0xFF4ECDC4\|0xFF00BCD4\|teal\|cyan" lib/ --include="*.dart" | grep -v "lib 2/" | grep -v "//"

# No broken letterSpacing
grep -rn "letterSpacing: [1-9]" lib/ --include="*.dart" | grep -v "lib 2/" | grep -v "letterSpacing: 1\." | grep -v "CAPS"

# Build check
flutter analyze
```

Expected result: 0 errors, consistent violet glass identity across every screen.
