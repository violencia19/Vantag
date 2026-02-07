# Vantag UI/UX Guidelines

Bu döküman, Vantag uygulamasının tutarlı ve kullanıcı dostu bir deneyim sunması için uyulması gereken UI/UX kurallarını tanımlar.

---

## 1. Design Principles

### 1.1 Core Values
| Principle | Description |
|-----------|-------------|
| **Clarity** | Kullanıcı her zaman nerede olduğunu ve ne yapması gerektiğini bilmeli |
| **Speed** | İşlemler hızlı, animasyonlar akıcı olmalı |
| **Delight** | Micro-interactions ve kutlamalar ile pozitif deneyim |
| **Trust** | Finansal veri = güvenlik hissi önemli |

### 1.2 Design Philosophy
- **Value-First**: Önce değeri göster, sonra sor
- **Progressive Disclosure**: Karmaşıklığı kademeli olarak göster
- **Forgiveness**: Hatalar geri alınabilir olmalı
- **Feedback**: Her eylem anında geri bildirim vermeli

---

## 2. Color System

### 2.1 Brand Colors
```dart
// Primary Palette
primary:       #6C63FF  // Ana marka rengi, CTA'lar
primaryDark:   #5B54E8  // Pressed states
primaryLight:  #8B85FF  // Hover, highlights

// Secondary
accent:        #2DD4BF  // Teal, secondary actions
accentDark:    #14B8A6  // Pressed state

// Semantic Colors
success:       #10B981  // Yeşil - pozitif, tasarruf
error:         #EF4444  // Kırmızı - hata, uyarı
warning:       #F59E0B  // Turuncu - dikkat, saat
info:          #3B82F6  // Mavi - bilgi
```

### 2.2 Background Colors (Dark Theme)
```dart
background:      #1A1A2E  // Ana arkaplan
surface:         #25253A  // Kartlar
surfaceLight:    #2F2F4A  // Elevated surfaces
surfaceLighter:  #3A3A5C  // Hover states
```

### 2.3 Text Colors
```dart
textPrimary:    #FFFFFF  // Ana metin (opacity: 1.0)
textSecondary:  #A0A0B8  // İkincil metin (opacity: 0.7)
textTertiary:   #6B6B80  // Placeholder, disabled (opacity: 0.5)
```

### 2.4 Usage Rules
```dart
// DOĞRU - Theme'den al
color: context.appColors.primary
color: context.appColors.textSecondary

// YANLIŞ - Hardcoded
color: Color(0xFF6C63FF)
color: Colors.purple
```

---

## 3. Typography

### 3.1 Font Family
- **Primary**: System default (San Francisco on iOS, Roboto on Android)
- **Monospace**: For numbers and currency

### 3.2 Type Scale
| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Display | 32px | Bold (700) | Hero numbers, amounts |
| H1 | 28px | Bold (700) | Screen titles |
| H2 | 24px | SemiBold (600) | Section headers |
| H3 | 20px | SemiBold (600) | Card titles |
| Body Large | 16px | Regular (400) | Primary content |
| Body | 15px | Regular (400) | Default text |
| Body Small | 14px | Regular (400) | Secondary content |
| Caption | 12px | Medium (500) | Labels, hints |
| Overline | 11px | SemiBold (600) | Badges, tags |

### 3.3 Text Rules
```dart
// Sayılar her zaman tabular figures kullan
Text(
  amount,
  style: TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
  ),
)

// Overflow handling
Text(
  longText,
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
)
```

---

## 4. Spacing System

### 4.1 Base Unit
Base unit: **4px**

### 4.2 Spacing Scale
| Token | Value | Usage |
|-------|-------|-------|
| xxs | 4px | Icon-text gap |
| xs | 8px | Tight spacing |
| sm | 12px | Related elements |
| md | 16px | Default padding |
| lg | 20px | Section spacing |
| xl | 24px | Card padding |
| xxl | 32px | Screen padding |
| xxxl | 48px | Major sections |

### 4.3 Layout Rules
```dart
// Screen padding
padding: EdgeInsets.all(16) // Standard
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24) // With more vertical

// Card padding
padding: EdgeInsets.all(20)

// List item spacing
SizedBox(height: 12) // Between items
```

---

## 5. Component Library

### 5.1 Buttons

#### Primary Button
```dart
SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: context.appColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
    ),
    child: Text(
      'Button Text',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)
```

#### Secondary Button
```dart
OutlinedButton(
  onPressed: onTap,
  style: OutlinedButton.styleFrom(
    foregroundColor: context.appColors.primary,
    side: BorderSide(color: context.appColors.primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: Text('Secondary'),
)
```

#### Text Button
```dart
TextButton(
  onPressed: onTap,
  child: Text(
    'Text Button',
    style: TextStyle(
      color: context.appColors.textSecondary,
    ),
  ),
)
```

### 5.2 Cards
```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: context.appColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: context.appColors.cardBorder),
  ),
  child: content,
)
```

### 5.3 Input Fields
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Placeholder',
    filled: true,
    fillColor: context.appColors.surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.appColors.primary),
    ),
  ),
)
```

### 5.4 Bottom Sheets
```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  barrierColor: Colors.black.withOpacity(0.85), // ZORUNLU!
  isScrollControlled: true,
  builder: (context) => Container(
    decoration: BoxDecoration(
      color: context.appColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: content,
  ),
)
```

### 5.5 Dialogs
```dart
showDialog(
  context: context,
  barrierColor: Colors.black.withOpacity(0.85), // ZORUNLU!
  builder: (context) => Dialog(
    backgroundColor: context.appColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: content,
  ),
)
```

---

## 6. Animation Guidelines

### 6.1 Duration Constants
```dart
class AppAnimations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration long = Duration(milliseconds: 600);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
}
```

### 6.2 Animation Types
| Type | Duration | Curve | Usage |
|------|----------|-------|-------|
| Fade | 200-300ms | easeOut | Appear/disappear |
| Slide | 300-400ms | easeOutCubic | Screen transitions |
| Scale | 200-300ms | easeOutBack | Buttons, cards |
| Bounce | 600ms | elasticOut | Celebrations |

### 6.3 Micro-interactions
```dart
// Button press
Transform.scale(
  scale: isPressed ? 0.95 : 1.0,
  child: button,
)

// Success checkmark
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: isSuccess ? Icon(Icons.check) : null,
)

// Number counter
AnimatedCounter(
  value: amount,
  duration: Duration(milliseconds: 500),
)
```

### 6.4 Haptic Feedback
```dart
// Light tap
HapticFeedback.lightImpact();

// Selection change
HapticFeedback.selectionClick();

// Success/completion
HapticFeedback.mediumImpact();

// Major celebration
HapticFeedback.heavyImpact();
```

---

## 7. Iconography

### 7.1 Icon Library
Primary: **Phosphor Icons** (phosphor_flutter package)

### 7.2 Icon Styles
| Style | Usage |
|-------|-------|
| Duotone | Primary icons, navigation |
| Bold | Emphasis, selected state |
| Regular | Secondary icons |
| Fill | Active/selected state |

### 7.3 Icon Sizes
| Size | Usage |
|------|-------|
| 16px | Inline, badges |
| 20px | List items, buttons |
| 24px | Navigation, cards |
| 32px | Empty states |
| 40px | Hero sections |

### 7.4 Usage
```dart
// Navigation icon
Icon(
  isSelected
    ? PhosphorIconsFill.house
    : PhosphorIconsDuotone.house,
  size: 24,
  color: isSelected
    ? context.appColors.primary
    : context.appColors.textSecondary,
)
```

---

## 8. Empty States

### 8.1 Structure
```
┌─────────────────────────────────┐
│                                 │
│         [Animated Icon]         │
│              88x88              │
│                                 │
│     Value Proposition (1 line)  │
│                                 │
│        [ CTA Button ]           │
│                                 │
└─────────────────────────────────┘
```

### 8.2 Rules
- Icon: Pulse animation, gradient background
- Message: Max 1-2 satır, değer odaklı
- CTA: Primary button, action-oriented text
- No sad faces or negative language

### 8.3 Example
```dart
EmptyState.expenses(
  message: l10n.emptyStateExpensesMessage, // "Harcamalarını saat olarak gör"
  ctaText: l10n.emptyStateExpensesCta,     // "İlk Harcamayı Ekle"
  onCtaTap: () => openAddExpense(),
)
```

---

## 9. Loading States

### 9.1 Types
| Type | Usage |
|------|-------|
| Shimmer | Lists, cards loading |
| Spinner | Button loading, quick operations |
| Progress | File uploads, long operations |
| Skeleton | Full screen loading |

### 9.2 Shimmer Implementation
```dart
LoadingPlaceholder(
  width: double.infinity,
  height: 80,
  borderRadius: BorderRadius.circular(16),
)
```

### 9.3 Rules
- Skeleton should match actual content layout
- Never show spinner for < 300ms
- Show progress percentage when possible
- Allow cancellation for long operations

---

## 10. Error Handling UI

### 10.1 Error Types
| Type | UI Pattern |
|------|------------|
| Validation | Inline error below field |
| Network | Snackbar with retry |
| Server | Full screen with retry |
| Permission | Dialog with settings link |

### 10.2 Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(errorMessage),
    backgroundColor: context.appColors.error,
    action: SnackBarAction(
      label: 'Tekrar Dene',
      textColor: Colors.white,
      onPressed: onRetry,
    ),
  ),
)
```

### 10.3 Error Messages
- Be specific about what went wrong
- Suggest how to fix it
- Never blame the user
- Provide actionable next step

```
// DOĞRU
"İnternet bağlantısı yok. Wi-Fi veya mobil veriyi kontrol et."

// YANLIŞ
"Bir hata oluştu."
```

---

## 11. Accessibility

### 11.1 Touch Targets
- Minimum size: 44x44 px
- Spacing between targets: 8px minimum

### 11.2 Contrast
- Text on background: 4.5:1 minimum
- Large text: 3:1 minimum
- Icons: 3:1 minimum

### 11.3 Screen Reader
```dart
Semantics(
  label: 'Harcama ekle butonu',
  button: true,
  child: AddButton(),
)
```

### 11.4 Dynamic Type
- Support system font scaling
- Test with 200% font size
- Use Flexible/Expanded for text containers

---

## 12. Localization Rules

### 12.1 Never Hardcode Strings
```dart
// DOĞRU
Text(l10n.addExpense)

// YANLIŞ
Text('Harcama Ekle')
```

### 12.2 Pluralization
```dart
// app_tr.arb
"itemCount": "{count, plural, =0{Öğe yok} =1{1 öğe} other{{count} öğe}}",

// Usage
Text(l10n.itemCount(count))
```

### 12.3 Number Formatting
```dart
// Currency
currencyProvider.format(amount) // "₺1.234,56"

// Percentage
NumberFormat.percentPattern('tr').format(0.75) // "%75"
```

---

## 13. Navigation Patterns

### 13.1 Primary Navigation
- Bottom navigation bar with 4-5 items
- FAB for primary action (add expense)

### 13.2 Secondary Navigation
- Back button for detail screens
- Close button for modals
- Swipe to go back (iOS)

### 13.3 Transitions
```dart
// Push (forward)
PageRouteBuilder(
  pageBuilder: (_, __, ___) => NewScreen(),
  transitionsBuilder: (_, animation, __, child) {
    return SlideTransition(
      position: Tween(
        begin: Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  },
)

// Modal (bottom)
showModalBottomSheet(...)

// Dialog (center)
showDialog(...)
```

---

## 14. Feedback & Celebrations

### 14.1 Positive Feedback
| Event | Feedback |
|-------|----------|
| Expense added | Success toast + haptic |
| Streak continued | Confetti (streak milestones) |
| Goal completed | Full celebration modal |
| Achievement unlocked | Badge animation + sound |

### 14.2 Confetti Usage
```dart
ConfettiWidget(
  confettiController: controller,
  blastDirectionality: BlastDirectionality.explosive,
  particleDrag: 0.05,
  emissionFrequency: 0.05,
  numberOfParticles: 30,
  gravity: 0.1,
  colors: [
    context.appColors.primary,
    context.appColors.accent,
    context.appColors.success,
    context.appColors.warning,
  ],
)
```

### 14.3 Sound Effects
- Success: Short positive chime
- Achievement: Celebratory fanfare
- Error: Soft negative tone
- Tap: Subtle click (optional)

---

## 15. Performance Guidelines

### 15.1 Image Optimization
- Use WebP format when possible
- Lazy load images below fold
- Provide placeholder during load
- Cache network images

### 15.2 List Optimization
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => Item(items[index]),
)

// NOT ListView(children: items.map(...))
```

### 15.3 Animation Performance
```dart
// Use RepaintBoundary for complex animations
RepaintBoundary(
  child: AnimatedWidget(),
)

// Avoid rebuilding entire tree
const StaticWidget(), // Use const when possible
```

---

## 16. Checklist for New Features

### Before Development
- [ ] UX flow documented
- [ ] Edge cases identified
- [ ] Error states defined
- [ ] Loading states defined
- [ ] Empty states defined

### During Development
- [ ] Using theme colors (context.appColors)
- [ ] Using localization (l10n.key)
- [ ] Haptic feedback added
- [ ] Animations smooth (60fps)
- [ ] Touch targets >= 44px

### Before Release
- [ ] Tested on small screens (iPhone SE)
- [ ] Tested on large screens (iPad)
- [ ] Tested with large fonts
- [ ] Tested offline behavior
- [ ] Tested with slow network
- [ ] Dark theme verified
- [ ] Screen reader tested

---

## 17. Common Mistakes

| Mistake | Fix |
|---------|-----|
| Text overflow | Wrap with `Expanded` + `overflow: ellipsis` |
| Modal transparency | Add `barrierColor: Colors.black.withOpacity(0.85)` |
| Hardcoded strings | Use `l10n.keyName` |
| Hardcoded colors | Use `context.appColors.colorName` |
| Missing haptics | Add `HapticFeedback.lightImpact()` |
| Keyboard overflow | Wrap in `SingleChildScrollView` |
| Small touch targets | Minimum 44x44 px |
| No loading state | Add shimmer/spinner |
| Generic error | Provide specific, actionable message |

---

## 18. Quick Reference

### Colors
```dart
context.appColors.primary      // #6C63FF
context.appColors.accent       // #2DD4BF
context.appColors.success      // #10B981
context.appColors.error        // #EF4444
context.appColors.warning      // #F59E0B
context.appColors.background   // #1A1A2E
context.appColors.surface      // #25253A
context.appColors.textPrimary  // #FFFFFF
context.appColors.textSecondary // #A0A0B8
```

### Spacing
```dart
4, 8, 12, 16, 20, 24, 32, 48
```

### Border Radius
```dart
8   // Small elements (badges, chips)
12  // Inputs, small cards
16  // Cards, buttons
20  // Large cards, sheets
24  // Bottom sheets (top corners)
```

### Shadows
```dart
// Subtle
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 2),
)

// Medium
BoxShadow(
  color: Colors.black.withOpacity(0.15),
  blurRadius: 16,
  offset: Offset(0, 4),
)

// Strong (glow)
BoxShadow(
  color: context.appColors.primary.withOpacity(0.3),
  blurRadius: 20,
  spreadRadius: 2,
)
```

---

*Last Updated: January 2025*
*Version: 1.0*
