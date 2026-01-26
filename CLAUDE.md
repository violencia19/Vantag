# CLAUDE.md - Vantag Project Guide

## Project Overview

**Vantag** is a Turkish personal finance app built with Flutter that converts expenses into work hours, helping users understand the true cost of their purchases in terms of time worked.

| Key | Value |
|-----|-------|
| Package | `com.vantag.app` |
| Version | 1.0.3+5 |
| Min SDK | Android 7.0 (API 24) |
| Languages | Turkish (primary), English |

## Code Rules

### Localization (CRITICAL)

**NEVER use hardcoded strings. Always use localization keys.**

```dart
// WRONG
Text('Harcama Ekle')
Text('Add Expense')

// CORRECT
Text(AppLocalizations.of(context)!.addExpense)
// or
Text(l10n.addExpense)
```

Localization files: `lib/l10n/app_en.arb`, `lib/l10n/app_tr.arb`

### Colors & Theme

**Always use context.appColors, never hardcode colors.**

```dart
// WRONG
color: Color(0xFF6C63FF)
color: Colors.purple

// CORRECT
color: context.appColors.primary
color: context.appColors.textSecondary
```

**Brand Colors:**
| Name | Hex | Usage |
|------|-----|-------|
| Primary | `#6C63FF` | Buttons, accents |
| Primary Dark | `#5B54E8` | Pressed states |
| Background | `#1A1A2E` | App background |
| Surface | `#25253A` | Cards |
| Teal | `#2DD4BF` | Secondary accent |
| Success | `#10B981` | Positive states |
| Error | `#EF4444` | Errors |
| Warning | `#F59E0B` | Warnings |

### Modal & Bottom Sheet Transparency

**Always set barrierColor for modals to prevent transparency issues.**

```dart
// CORRECT - Dark barrier
showModalBottomSheet(
  context: context,
  barrierColor: Colors.black.withOpacity(0.85),
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (context) => MySheet(),
);

// CORRECT - For dialogs
showDialog(
  context: context,
  barrierColor: Colors.black.withOpacity(0.85),
  builder: (context) => MyDialog(),
);
```

### Overflow Prevention

**Always use Flexible/Expanded for dynamic content.**

```dart
// WRONG - Will overflow
Row(
  children: [
    Text(veryLongText),
    Icon(Icons.check),
  ],
)

// CORRECT
Row(
  children: [
    Expanded(
      child: Text(veryLongText, overflow: TextOverflow.ellipsis),
    ),
    Icon(Icons.check),
  ],
)
```

### State Management

Using **Provider** with ChangeNotifier pattern.

```dart
// Reading
final finance = context.read<FinanceProvider>();
final isPro = context.watch<ProProvider>().isPro;

// Key Providers
ProProvider        // Premium status, RevenueCat
FinanceProvider    // Expenses, profile, subscriptions
PursuitProvider    // Savings goals
CurrencyProvider   // Selected currency, rates
LocaleProvider     // Language (en/tr)
ThemeProvider      // Dark/Light/System
```

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── screens/                  # Full-page screens (30 files)
│   ├── expense_screen.dart   # Main expense entry
│   ├── report_screen.dart    # Reports & analytics
│   ├── pursuit_list_screen.dart # Savings goals
│   └── ...
├── widgets/                  # Reusable components (69 files)
│   ├── ai_chat_sheet.dart    # AI chat bottom sheet
│   ├── expense_form_content.dart
│   └── ...
├── services/                 # Business logic (55 files)
│   ├── ai_service.dart       # OpenAI GPT-4o
│   ├── expense_history_service.dart
│   ├── pursuit_service.dart
│   └── ...
├── providers/                # State management (9 files)
│   ├── pro_provider.dart     # RevenueCat
│   ├── finance_provider.dart
│   └── ...
├── models/                   # Data models (15 files)
│   ├── expense.dart
│   ├── pursuit.dart
│   └── ...
├── theme/                    # Design system
│   └── app_theme.dart
├── l10n/                     # Localization
│   ├── app_en.arb
│   └── app_tr.arb
└── utils/                    # Helpers
```

## Common Patterns

### Adding a New Screen

```dart
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(l10n.myScreenTitle),
      ),
      body: ...
    );
  }
}
```

### Adding Localization Keys

1. Add to `lib/l10n/app_en.arb`:
```json
"myNewKey": "English text",
"@myNewKey": { "description": "Description for translators" }
```

2. Add to `lib/l10n/app_tr.arb`:
```json
"myNewKey": "Türkçe metin"
```

3. Run: `flutter gen-l10n`

4. Use: `l10n.myNewKey`

### AI Service Usage

```dart
final response = await AIService().getResponse(
  message: userMessage,
  financeProvider: context.read<FinanceProvider>(),
  isPremium: context.read<ProProvider>().isPro,
  languageCode: Localizations.localeOf(context).languageCode,
);
```

## Common Mistakes & Fixes

| Mistake | Fix |
|---------|-----|
| Text overflow | Wrap with `Expanded` or `Flexible` |
| Modal transparency | Add `barrierColor: Colors.black.withOpacity(0.85)` |
| Hardcoded strings | Use `l10n.keyName` |
| Hardcoded colors | Use `context.appColors.colorName` |
| Missing null check | Use `?.` or `!` appropriately |
| Keyboard overflow | Wrap in `SingleChildScrollView` |

## Build Commands

```bash
# Development
flutter run -d android

# Release APK
flutter build apk --release

# Release Bundle (Play Store)
flutter build appbundle --release

# Clean build
flutter clean && flutter pub get

# Generate localizations
flutter gen-l10n

# Analyze code
flutter analyze
```

## Key Files

| Purpose | File |
|---------|------|
| App entry | `lib/main.dart` |
| Theme colors | `lib/theme/app_theme.dart` |
| AI chat | `lib/services/ai_service.dart` |
| Premium | `lib/providers/pro_provider.dart` |
| Expenses | `lib/services/expense_history_service.dart` |
| Pursuits | `lib/services/pursuit_service.dart` |

## API Keys

Stored in `.env` (never commit):
```
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=AIza...
REVENUECAT_API_KEY=goog_...
```

## Contact

- Email: vantagfinance@gmail.com
- Developer: Gencay Alla
