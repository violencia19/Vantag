# Vantag UI Cheat Sheet

Hızlı referans için kullanın. Detaylar: `docs/ui_ux_guidelines.md`

---

## Colors (ASLA hardcode yapma!)

```dart
context.appColors.primary       // Mor - CTA, vurgu
context.appColors.accent        // Teal - İkincil aksiyon
context.appColors.success       // Yeşil - Başarı, tasarruf
context.appColors.error         // Kırmızı - Hata
context.appColors.warning       // Turuncu - Uyarı, saat
context.appColors.background    // Arkaplan
context.appColors.surface       // Kart arkaplanı
context.appColors.textPrimary   // Ana metin
context.appColors.textSecondary // İkincil metin
context.appColors.textTertiary  // Placeholder
```

---

## Localization (ASLA hardcode yapma!)

```dart
final l10n = AppLocalizations.of(context);

Text(l10n.addExpense)           // "Harcama Ekle"
Text(l10n.profileHours(hours))  // "{hours} Saat"
```

---

## Spacing

```
4   - xxs (icon-text gap)
8   - xs  (tight)
12  - sm  (related elements)
16  - md  (default padding)
20  - lg  (section spacing)
24  - xl  (card padding)
32  - xxl (screen padding)
48  - xxxl (major sections)
```

---

## Border Radius

```
8   - Badges, chips
12  - Inputs, small cards
16  - Cards, buttons
20  - Large cards
24  - Bottom sheets (top)
```

---

## Modal & Bottom Sheet (ZORUNLU!)

```dart
showModalBottomSheet(
  context: context,
  barrierColor: Colors.black.withOpacity(0.85), // ← ZORUNLU!
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (context) => MySheet(),
);

showDialog(
  context: context,
  barrierColor: Colors.black.withOpacity(0.85), // ← ZORUNLU!
  builder: (context) => MyDialog(),
);
```

---

## Overflow Prevention

```dart
// YANLIŞ
Row(children: [Text(longText), Icon()])

// DOĞRU
Row(children: [
  Expanded(child: Text(longText, overflow: TextOverflow.ellipsis)),
  Icon(),
])
```

---

## Primary Button

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
    child: Text('Button', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  ),
)
```

---

## Card

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

---

## Haptic Feedback

```dart
HapticFeedback.lightImpact();    // Hafif dokunma
HapticFeedback.selectionClick(); // Seçim değişikliği
HapticFeedback.mediumImpact();   // Başarı
HapticFeedback.heavyImpact();    // Kutlama
```

---

## Icons (Phosphor)

```dart
PhosphorIconsDuotone.receipt    // Duotone (varsayılan)
PhosphorIconsBold.plus          // Bold (vurgulu)
PhosphorIconsFill.house         // Fill (seçili)
PhosphorIconsRegular.x          // Regular (ikincil)
```

Boyutlar: `16, 20, 24, 32, 40`

---

## Animation Durations

```dart
Duration(milliseconds: 100)  // instant
Duration(milliseconds: 200)  // fast
Duration(milliseconds: 300)  // medium
Duration(milliseconds: 400)  // slow
Duration(milliseconds: 600)  // long (celebrations)

Curves.easeOutCubic          // Standard
Curves.elasticOut            // Bounce
```

---

## Empty State

```dart
EmptyState.expenses(
  message: l10n.emptyStateExpensesMessage,
  ctaText: l10n.emptyStateExpensesCta,
  onCtaTap: () => openAddExpense(),
)
```

---

## Loading

```dart
LoadingPlaceholder(
  width: double.infinity,
  height: 80,
  borderRadius: BorderRadius.circular(16),
)
```

---

## Error Snackbar

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
);
```

---

## Touch Target

Minimum boyut: **44x44 px**

---

## Pre-commit Checklist

- [ ] Theme colors kullandım (`context.appColors`)
- [ ] Localization kullandım (`l10n.key`)
- [ ] `barrierColor` ekledim (modal/dialog)
- [ ] Overflow kontrolü yaptım (`Expanded`)
- [ ] Haptic feedback ekledim
- [ ] Touch target >= 44px

---

*v1.0 - January 2025*
