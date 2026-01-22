# CLAUDE.md - Vantag Project Documentation

This file provides guidance to Claude Code when working with this repository.

---

## Project Overview

**Vantag** is a Turkish-language personal finance awareness app that helps users understand how much work time is required to afford purchases based on their income and work schedule.

| Key | Value |
|-----|-------|
| Package | `com.vantag.app` |
| Version | 1.0.0+1 |
| Slogan | "Finansal Üstünlüğün" |
| Min SDK | 24 (Android 7.0) |
| Target SDK | 34 |

---

## Tech Stack

```yaml
# Core
flutter: 3.x
dart: 3.x

# State Management
provider: ^6.1.2

# Backend & Auth
firebase_core: ^4.3.0
firebase_auth: ^6.1.3
cloud_firestore: ^6.1.1
firebase_crashlytics: ^5.0.6
firebase_analytics: ^12.0.0
google_sign_in: 6.2.1

# Monetization
purchases_flutter: ^8.0.0  # RevenueCat

# AI
http: ^1.2.0  # OpenAI API calls

# Storage
shared_preferences: ^2.2.2

# UI
phosphor_flutter: ^2.1.0
fl_chart: ^1.1.1
flutter_animate: ^4.5.0
confetti: ^0.7.0
showcaseview: ^3.0.0

# Localization
flutter_localizations: sdk
intl: ^0.20.2

# Media
video_player: ^2.8.2
fvp: ^0.35.2
share_plus: ^7.2.1
screenshot: ^2.1.0

# Utils
path_drawing: ^1.0.1
flutter_dotenv: ^5.1.0
uuid: ^4.3.3
```

---

## Common Commands

```bash
# Dependencies
flutter pub get

# Run
flutter run -d windows
flutter run -d chrome
flutter run -d android

# Build
flutter build apk --release
flutter build windows

# Analyze & Test
flutter analyze
flutter test

# Localization
flutter gen-l10n
```

---

## Project Structure

```
lib/
├── main.dart                           # App entry + providers setup
├── models/                             # Data models (12 files)
│   ├── models.dart                     # Barrel export
│   ├── user_profile.dart               # User profile model
│   ├── expense.dart                    # Expense with decision tracking
│   ├── expense_result.dart             # Calculation result
│   ├── subscription.dart               # Recurring subscriptions
│   ├── achievement.dart                # Badges/achievements
│   ├── currency.dart                   # Currency model
│   ├── pursuit.dart                    # Savings goals
│   ├── pursuit_transaction.dart        # Pursuit savings transactions
│   ├── budget.dart                     # Budget model
│   ├── income_source.dart              # Income source model
│   └── enums.dart                      # Shared enums
├── services/                           # Business logic (13 files)
│   ├── services.dart                   # Barrel export
│   ├── ai_service.dart                 # OpenAI GPT-4.1 integration
│   ├── ai_tools.dart                   # AI function calling tools
│   ├── ai_tool_handler.dart            # Tool execution handler
│   ├── ai_memory_service.dart          # Chat history persistence
│   ├── purchase_service.dart           # RevenueCat integration
│   ├── pursuit_service.dart            # Pursuit CRUD
│   ├── expense_history_service.dart    # Expense CRUD with locking
│   ├── profile_service.dart            # Profile persistence
│   ├── currency_service.dart           # TCMB + Gold API
│   ├── subscription_service.dart       # Subscription management
│   ├── notification_service.dart       # Local notifications
│   ├── streak_service.dart             # Daily streak tracking
│   ├── calculation_service.dart        # Work time calculations
│   ├── auth_service.dart               # Firebase Auth
│   ├── budget_service.dart             # Budget CRUD
│   └── achievements_service.dart       # Badge logic
├── providers/                          # State management (5 files)
│   ├── providers.dart                  # Barrel export
│   ├── pro_provider.dart               # Premium status (RevenueCat)
│   ├── finance_provider.dart           # Core finance state
│   ├── pursuit_provider.dart           # Pursuit state
│   ├── currency_provider.dart          # Selected currency
│   └── locale_provider.dart            # Language selection
├── screens/                            # UI screens (22 files)
│   ├── screens.dart                    # Barrel export
│   ├── splash_screen.dart              # Video splash
│   ├── onboarding_screen.dart          # 3-page intro
│   ├── main_screen.dart                # Bottom nav container
│   ├── expense_screen.dart             # Main expense entry
│   ├── report_screen.dart              # Monthly reports
│   ├── pursuit_list_screen.dart        # Savings goals
│   ├── profile_screen.dart             # User profile
│   ├── subscription_screen.dart        # Subscriptions
│   ├── settings_screen.dart            # App settings
│   └── ...                             # Other screens
├── widgets/                            # Reusable widgets (55 files)
│   ├── widgets.dart                    # Barrel export
│   ├── ai_chat_sheet.dart              # AI chat bottom sheet
│   ├── pursuit_card.dart               # Pursuit list item
│   ├── pursuit_progress_visual.dart    # Progress animation
│   ├── add_savings_sheet.dart          # Add savings modal
│   ├── create_pursuit_sheet.dart       # Create pursuit modal
│   ├── premium_nav_bar.dart            # Bottom navigation
│   └── ...                             # Other widgets
├── theme/                              # Design system
│   ├── theme.dart                      # Barrel export
│   ├── app_theme.dart                  # Colors, typography
│   ├── app_gradients.dart              # Gradient definitions
│   └── quiet_luxury.dart               # Premium design system
├── l10n/                               # Localization
│   ├── app_en.arb                      # English (~500 keys)
│   └── app_tr.arb                      # Turkish (~500 keys)
└── data/
    └── store_categories.dart           # 200+ store→category mappings
```

---

## Key Models

### UserProfile (`lib/models/user_profile.dart`)
```dart
class UserProfile {
  final String? id;
  final String name;
  final String? photoUrl;
  final List<IncomeSource> incomeSources;  // Multiple income support
  final int workDaysPerWeek;               // 1-7
  final double workHoursPerDay;            // 1-24
  final String currency;                   // TRY, USD, EUR, GBP, SAR
  final DateTime createdAt;
  final DateTime updatedAt;

  double get totalMonthlyIncome;           // Sum of all sources
  double get hourlyRate;                   // Calculated from income/hours
}
```

### Expense (`lib/models/expense.dart`)
```dart
enum ExpenseDecision { yes, thinking, no }

class Expense {
  final String id;
  final double amount;
  final String category;
  final String? description;
  final ExpenseDecision decision;
  final DateTime createdAt;
  final double? originalAmount;      // If entered in different currency
  final String? originalCurrency;    // Original currency code
  final bool isSimulation;           // vs real expense
}
```

### Pursuit (`lib/models/pursuit.dart`)
```dart
enum PursuitCategory { tech, travel, home, fashion, vehicle, education, health, other }

class Pursuit {
  final String id;
  final String name;
  final double targetAmount;
  final String currency;
  final double savedAmount;
  final String? imageUrl;
  final String emoji;
  final PursuitCategory category;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isArchived;
  final int sortOrder;

  double get progressPercent;        // 0.0 - 1.0
  bool get isCompleted;
  double get remainingAmount;
}
```

### Subscription (`lib/models/subscription.dart`)
```dart
enum BillingCycle { weekly, monthly, yearly }

class Subscription {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final BillingCycle cycle;
  final int renewalDay;              // 1-31
  final String category;
  final String? colorHex;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final bool isActive;

  double get monthlyEquivalent;      // Normalized to monthly
}
```

---

## Key Providers

### ProProvider (`lib/providers/pro_provider.dart`)
RevenueCat integration for premium status.

```dart
class ProProvider extends ChangeNotifier {
  // RevenueCat API Key
  static const String _apiKey = 'goog_eaqbqIavIhPNWQubIRPgqVzUjrg';

  bool _isPremium = false;
  bool _isLifetime = false;
  int _creditsRemaining = 0;

  bool get isPremium;
  bool get isLifetime;
  int get creditsRemaining;

  Future<void> initialize();
  Future<void> checkPremiumStatus();
  Future<bool> purchasePackage(Package package);
  Future<void> restorePurchases();
  Future<bool> useCredit();          // Deduct 1 AI credit
}
```

**Entitlements:**
- `pro` - Pro monthly/yearly (500 credits/month)
- `lifetime` - Lifetime access (200 credits/month base)

**Products:**
- `vantag_pro_monthly` - ₺49.99/month
- `vantag_pro_yearly` - ₺399.99/year
- `vantag_lifetime` - ₺999.99 one-time
- `vantag_credits_100` - ₺29.99 (100 credits)
- `vantag_credits_500` - ₺99.99 (500 credits)

### FinanceProvider (`lib/providers/finance_provider.dart`)
Core finance state management.

```dart
class FinanceProvider extends ChangeNotifier {
  UserProfile? _profile;
  List<Expense> _expenses = [];
  List<Subscription> _subscriptions = [];

  // Getters
  UserProfile? get profile;
  List<Expense> get expenses;
  List<Expense> get recentExpenses;      // Last 30 days
  double get totalSaved;                  // "Vazgeçtim" decisions
  double get totalSpent;                  // "Aldım" decisions

  // Actions
  Future<void> initialize();
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<void> updateProfile(UserProfile profile);
}
```

### PursuitProvider (`lib/providers/pursuit_provider.dart`)
Savings goals state management.

```dart
class PursuitProvider extends ChangeNotifier {
  List<Pursuit> _pursuits = [];

  List<Pursuit> get activePursuits;       // Not completed, not archived
  List<Pursuit> get completedPursuits;
  double get totalSaved;                   // Sum of all savedAmount

  Future<void> initialize();
  Future<bool> createPursuit(Pursuit pursuit);
  Future<void> addSavings(String pursuitId, double amount, {TransactionSource? source});
  Future<void> completePursuit(String pursuitId);
  Future<void> deletePursuit(String pursuitId);
}
```

---

## Key Services

### AIService (`lib/services/ai_service.dart`)
OpenAI GPT-4.1 integration with function calling.

```dart
class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4.1';

  Future<void> initialize();             // Load API key from .env

  Future<String> getResponse({
    required String message,
    required FinanceProvider financeProvider,
    bool isPremium = true,               // Affects system prompt
  });

  // Available AI Tools (function calling):
  // - get_expenses_summary: Monthly spending by category
  // - get_recent_expenses: Last N expenses
  // - add_expense: Add new expense via chat
}
```

**System Prompt Behavior:**
- Premium: Detailed analysis, specific advice, savings plans
- Free: Short responses (2-3 sentences), no specific advice

### PurchaseService (`lib/services/purchase_service.dart`)
RevenueCat SDK wrapper.

```dart
class PurchaseService {
  Future<void> initialize();
  Future<CustomerInfo> getCustomerInfo();
  Future<Offerings> getOfferings();
  Future<CustomerInfo> purchasePackage(Package package);
  Future<CustomerInfo> restorePurchases();
}
```

### CurrencyService (`lib/services/currency_service.dart`)
Exchange rate fetching.

```dart
class CurrencyService {
  // APIs
  static const _tcmbUrl = 'https://www.tcmb.gov.tr/kurlar/today.xml';
  static const _goldUrl = 'https://finans.truncgil.com/v4/today.json';

  Future<Map<String, double>> getRates();  // USD, EUR, GBP rates in TRY
  Future<double> getGoldPrice();           // Per gram in TRY
  double convert(double amount, String from, String to);
}
```

### PursuitService (`lib/services/pursuit_service.dart`)
Pursuit CRUD with locking mechanism.

```dart
class PursuitService {
  static const _keyPursuits = 'pursuits_v1';
  static const _keyTransactions = 'pursuit_transactions_v1';

  // Lock mechanism prevents race conditions
  Future<T> _withLock<T>(Future<T> Function() operation);

  Future<List<Pursuit>> getActivePursuits();
  Future<void> createPursuit(Pursuit pursuit);
  Future<void> addSavings(String pursuitId, double amount, TransactionSource source);
  Future<bool> canCreatePursuit(bool isPremium);  // Free: 1, Premium: unlimited
}
```

---

## Monetization

### Free Tier Limits
| Feature | Limit |
|---------|-------|
| AI Chat | 4 predefined buttons only |
| AI Credits | 5/day |
| Pursuits | 1 active |
| Expense History | 30 days |
| Reports | Basic |

### Premium Features
| Feature | Pro | Lifetime |
|---------|-----|----------|
| AI Chat | Free text input | Free text input |
| AI Credits | 500/month | 200/month + purchasable |
| Pursuits | Unlimited | Unlimited |
| Expense History | Full | Full |
| Reports | Advanced | Advanced |
| Export | Excel/PDF | Excel/PDF |

### RevenueCat Setup
```dart
// ProProvider initialization
await Purchases.configure(
  PurchasesConfiguration(_apiKey)
    ..appUserID = userId
);

// Check entitlements
final info = await Purchases.getCustomerInfo();
_isPremium = info.entitlements.all['pro']?.isActive ?? false;
_isLifetime = info.entitlements.all['lifetime']?.isActive ?? false;
```

---

## Localization

### File Structure
```
lib/l10n/
├── app_en.arb    # English (~500 keys)
└── app_tr.arb    # Turkish (~500 keys)
```

### Usage
```dart
import 'package:vantag/l10n/app_localizations.dart';

// In widget
final l10n = AppLocalizations.of(context)!;
Text(l10n.expenses);           // "Expenses" or "Harcamalar"
Text(l10n.streakDays(5));      // "5 days" or "5 gün"
```

### Key Categories
- Navigation: 15 keys
- Forms: 45 keys
- Expenses: 60 keys
- Subscriptions: 40 keys
- Achievements: 25 keys
- Reports: 30 keys
- AI Chat: 15 keys
- Pursuits: 50 keys

### Regenerate
```bash
flutter gen-l10n
```

---

## UI/UX Design System

### Quiet Luxury Theme
Premium banking-inspired design (JPMorgan/Goldman Sachs style).

**Colors (`lib/theme/app_theme.dart`):**
```dart
class AppColors {
  static const background = Color(0xFF1A1A2E);      // Midnight Blue
  static const surface = Color(0xFF25253A);         // Card background
  static const textPrimary = Color(0xFFF5F5F5);     // Off-White
  static const textSecondary = Color(0xFFB0B0B0);   // Grey
  static const textTertiary = Color(0xFF6A6A7A);    // Muted
  static const positive = Color(0xFF2ECC71);        // Green
  static const negative = Color(0xFFE74C3C);        // Red
  static const warning = Color(0xFFFF8C00);         // Amber
  static const accent = Color(0xFF6C63FF);          // Purple
  static const accentSecondary = Color(0xFF4ECDC4); // Teal

  // GOLD ONLY FOR: Victory, Achievement unlock, Streak milestones (5,10,30)
  static const gold = Color(0xFFFFD700);
}
```

**Gradients:**
```dart
class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  static const accent = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
  );
}
```

**Components:**
- GlassCard: `BackdropFilter` blur(10), subtle border 0.5px
- Pressable: Scale 0.98 on press
- AnimatedNumber: Fade transition on value change

---

## App Flow

```
SplashScreen (Video, 2-3s)
├── First launch → OnboardingScreen (3 pages)
│   └── Complete → UserProfileScreen (create)
├── No profile → UserProfileScreen (create)
└── Profile exists → MainScreen

MainScreen (Bottom Navigation)
├── Tab 1: ExpenseScreen (Harcama)
│   ├── Header with saved money stats
│   ├── Currency rates bar
│   ├── Expense input
│   ├── Decision buttons (Aldım/Düşünüyorum/Vazgeçtim)
│   └── Recent expenses list
├── Tab 2: ReportScreen (Rapor)
│   └── Monthly/category statistics
├── Tab 3: PursuitListScreen (Hayallerim)
│   └── Savings goals with progress
└── Tab 4: ProfileScreen (Profil)
    ├── Profile info
    ├── Settings
    └── Premium status
```

---

## AI Chat System

### Free User Flow
1. 4 predefined suggestion buttons only
2. TextField `readOnly: true` with lock icon
3. Tapping TextField → Paywall modal
4. 5 AI credits/day limit

### Premium User Flow
1. Free text input
2. Typing effect animation (50ms/word)
3. Full conversation history
4. 500 credits/month

### Suggestion Buttons
```dart
final suggestions = [
  ('📊', l10n.aiSuggestion1),  // "Bu ay nereye harcadım?"
  ('💡', l10n.aiSuggestion2),  // "Nereden tasarruf edebilirim?"
  ('🔥', l10n.aiSuggestion3),  // "En pahalı alışkanlığım ne?"
  ('🎯', l10n.aiSuggestion4),  // "Hedefime ne kadar kaldı?"
];
```

### Upsell Widget
After each AI response (for free users):
- 500ms delay
- FadeIn animation
- "Premium'a Geç" button

---

## Pursuit System

### Categories
```dart
enum PursuitCategory {
  tech,      // 📱 Teknoloji
  travel,    // ✈️ Seyahat
  home,      // 🏠 Ev
  fashion,   // 👗 Moda
  vehicle,   // 🚗 Araç
  education, // 📚 Eğitim
  health,    // 💊 Sağlık
  other,     // 📦 Diğer
}
```

### Progress Visual
ShaderMask fill-from-bottom animation:
```dart
ShaderMask(
  shaderCallback: (bounds) {
    return LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Colors.white, Colors.white.withOpacity(0.3)],
      stops: [progress, progress],
    ).createShader(bounds);
  },
  child: emojiOrImage,
)
```

### Free Tier Limit
```dart
Future<bool> canCreatePursuit(bool isPremium) async {
  if (isPremium) return true;
  final pursuits = await getActivePursuits();
  return pursuits.isEmpty;  // Free: 1 pursuit max
}
```

---

## Currency System

### Supported Currencies
```dart
final supportedCurrencies = [
  Currency(code: 'TRY', symbol: '₺', flag: '🇹🇷', goldUnit: 'gr'),
  Currency(code: 'USD', symbol: '\$', flag: '🇺🇸', goldUnit: 'oz'),
  Currency(code: 'EUR', symbol: '€', flag: '🇪🇺', goldUnit: 'oz'),
  Currency(code: 'GBP', symbol: '£', flag: '🇬🇧', goldUnit: 'oz'),
  Currency(code: 'SAR', symbol: 'ر.س', flag: '🇸🇦', goldUnit: 'oz'),
];
```

### Rate Sources
- **TCMB:** TRY-based rates (official Turkish Central Bank)
- **Truncgil:** Gold prices (no API key needed)

### Currency Toggle in Expense Entry
When income currency ≠ display currency:
- Toggle shown: `₺ TRY / $ USD`
- Auto-conversion applied
- Original amount/currency stored in expense

---

## Firebase Integration

### Auth
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();
  User? get currentUser;
  Stream<User?> get authStateChanges;
}
```

### Firestore Paths
```
users/{uid}/
├── profile              # UserProfile document
├── expenses/{expenseId} # Expense documents
├── subscriptions/{id}   # Subscription documents
├── pursuits/{pursuitId} # Pursuit documents
└── pursuit_transactions/{id}
```

---

## Environment Variables

`.env` file required:
```
OPENAI_API_KEY=sk-...
```

Load in `main.dart`:
```dart
await dotenv.load(fileName: '.env');
```

---

## Known Issues / TODO

- [ ] Unit test coverage needed
- [ ] Web platform notification support
- [ ] Receipt scanner OCR integration
- [ ] Cloud sync conflict resolution
- [ ] Store preparation (screenshots, descriptions)

---

## Recent Updates

### January 2026 - Night Work Edition
**Phase 1-10 Complete:**
- Bug fixes (Share Card, Habit Calculator, Category Localization)
- Full test coverage (199 tests passing)
- Code audit & cleanup (41→27 issues)
- Firebase Crashlytics & Analytics integration
- Legal & Compliance (Privacy, ToS, Delete Account, Restore)
- Light mode theme support (ThemeProvider)
- Security hardening (SecurityUtils)
- Localization complete (~530 keys per language)

**New Services:**
- `AnalyticsService` - Event tracking for key user actions
- `ThemeProvider` - Dark/Light/System theme management
- `SecurityUtils` - Input validation, sanitization, data masking

**Previous Updates:**
- AI Chat free user 4-button system
- Pursuit system (Hayallerim) implementation
- RevenueCat premium integration
- Multi-currency support (5 currencies)
- Video splash screen
- Full TR/EN localization

---

*Last updated: January 2026*
