# VANTAG - Complete Project Analysis

> **Last Updated:** January 2026
> **Version:** 1.0.2+4
> **Document Purpose:** Single source of truth for the entire Vantag project

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technical Architecture](#2-technical-architecture)
3. [Screens and User Flows](#3-screens-and-user-flows)
4. [Features (Detailed)](#4-features-detailed)
5. [Free vs Pro Comparison](#5-free-vs-pro-comparison)
6. [APIs and Services](#6-apis-and-services)
7. [Data Models](#7-data-models)
8. [Localization](#8-localization)
9. [Security](#9-security)
10. [Known Issues and TODOs](#10-known-issues-and-todos)
11. [Deployment](#11-deployment)
12. [Project Statistics](#12-project-statistics)

---

## 1. Project Overview

### Basic Information

| Property | Value |
|----------|-------|
| **App Name** | Vantag |
| **Package Name** | `com.vantag.app` |
| **Version** | 1.0.2+4 |
| **Slogan** | "Finansal Ustunlugun" (Your Financial Superiority) |
| **Min SDK** | Android 7.0 (API 24) |
| **Target SDK** | Android 14 (API 34) |

### One-Line Description

**Vantag is a Turkish personal finance awareness app that helps users understand how much work time is required to afford purchases based on their income and work schedule.**

### Target Audience

- Turkish-speaking users (primary)
- English-speaking users (secondary)
- Age: 18-45 working professionals
- Goal: Improve spending awareness and savings habits

### Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Android | Production Ready | Primary platform |
| iOS | Ready | Pending App Store submission |
| Windows | Development Only | Mock mode for testing |
| Web | Not Supported | - |

---

## 2. Technical Architecture

### 2.1 Folder Structure

```
lib/
├── main.dart                           # App entry point, providers setup
├── firebase_options.dart               # Firebase configuration
│
├── models/                             # Data models (15 files)
│   ├── models.dart                     # Barrel export
│   ├── user_profile.dart               # User profile with income sources
│   ├── income_source.dart              # Multiple income support
│   ├── income.dart                     # One-time income records
│   ├── expense.dart                    # Expense with decision tracking
│   ├── expense_result.dart             # Calculation result
│   ├── subscription.dart               # Recurring subscriptions
│   ├── pursuit.dart                    # Savings goals (Hayallerim)
│   ├── pursuit_transaction.dart        # Pursuit savings history
│   ├── savings_pool.dart               # Savings pool management
│   ├── category_budget.dart            # Category-based budgets
│   ├── achievement.dart                # Badges/achievements
│   ├── currency.dart                   # Currency definitions
│   ├── personality_mode.dart           # AI personality enum
│   └── voice_parse_result.dart         # Voice input parsing result
│
├── services/                           # Business logic (55 files)
│   ├── services.dart                   # Barrel export
│   │
│   │ # Core Services
│   ├── profile_service.dart            # Profile persistence
│   ├── expense_history_service.dart    # Expense CRUD with sync
│   ├── calculation_service.dart        # Work time calculations
│   ├── budget_service.dart             # Budget management
│   ├── subscription_service.dart       # Subscription management
│   ├── pursuit_service.dart            # Pursuit/savings CRUD
│   │
│   │ # AI Services
│   ├── ai_service.dart                 # OpenAI GPT-4o integration
│   ├── ai_tools.dart                   # AI function calling tools
│   ├── ai_tool_handler.dart            # Tool execution handler
│   ├── ai_memory_service.dart          # Gemini-based fact extraction
│   ├── voice_parser_service.dart       # Voice-to-expense parsing
│   ├── statement_parse_service.dart    # Bank statement parsing
│   │
│   │ # Monetization
│   ├── purchase_service.dart           # RevenueCat integration
│   ├── free_tier_service.dart          # Free tier limits
│   │
│   │ # External APIs
│   ├── currency_service.dart           # TCMB + Gold rates
│   ├── exchange_rate_service.dart      # Rate caching
│   │
│   │ # System Services
│   ├── auth_service.dart               # Firebase Auth
│   ├── analytics_service.dart          # Firebase Analytics
│   ├── notification_service.dart       # Local notifications
│   ├── push_notification_service.dart  # FCM integration
│   ├── streak_service.dart             # Daily streak tracking
│   ├── achievements_service.dart       # Badge unlocking
│   ├── tour_service.dart               # Onboarding tutorial
│   ├── merchant_learning_service.dart  # Smart category learning
│   ├── deep_link_service.dart          # Deep link handling
│   ├── connectivity_service.dart       # Network status
│   ├── export_service.dart             # Excel/PDF export
│   ├── import_service.dart             # Data import
│   └── ... (27 more services)
│
├── providers/                          # State management (9 files)
│   ├── providers.dart                  # Barrel export
│   ├── pro_provider.dart               # Premium status (RevenueCat)
│   ├── finance_provider.dart           # Core finance state
│   ├── pursuit_provider.dart           # Savings goals state
│   ├── currency_provider.dart          # Selected currency
│   ├── locale_provider.dart            # Language selection
│   ├── theme_provider.dart             # Dark/Light/System theme
│   ├── category_budget_provider.dart   # Budget management
│   └── savings_pool_provider.dart      # Savings pool state
│
├── screens/                            # UI screens (30 files)
│   ├── screens.dart                    # Barrel export
│   │
│   │ # Onboarding
│   ├── splash_screen.dart              # Video splash
│   ├── onboarding_screen.dart          # 3-page intro
│   ├── onboarding_pursuit_screen.dart  # Pursuit intro
│   ├── onboarding_salary_day_screen.dart
│   ├── onboarding_try_screen.dart      # Trial offer
│   │
│   │ # Main Navigation
│   ├── main_screen.dart                # Bottom nav container
│   ├── expense_screen.dart             # Main expense entry
│   ├── report_screen.dart              # Monthly reports
│   ├── pursuit_list_screen.dart        # Savings goals
│   ├── profile_screen.dart             # User profile
│   │
│   │ # Features
│   ├── subscription_screen.dart        # Subscriptions list
│   ├── voice_input_screen.dart         # Voice expense entry
│   ├── habit_calculator_screen.dart    # Habit cost calculator
│   ├── income_wizard_screen.dart       # Income setup wizard
│   ├── import_statement_screen.dart    # Bank statement import
│   ├── currency_detail_screen.dart     # Currency rates detail
│   ├── achievements_screen.dart        # Badges gallery
│   │
│   │ # Settings & Profile
│   ├── settings_screen.dart            # App settings
│   ├── user_profile_screen.dart        # Profile edit
│   ├── profile_modal.dart              # Profile quick view
│   ├── notification_settings_screen.dart
│   │
│   │ # Security
│   ├── lock_screen.dart                # App lock
│   ├── pin_setup_screen.dart           # PIN configuration
│   │
│   │ # Premium
│   ├── paywall_screen.dart             # Subscription offers
│   ├── credit_purchase_screen.dart     # AI credit packs
│   │
│   │ # Simple Mode
│   └── simple/
│       ├── simple_main_screen.dart
│       ├── simple_settings_screen.dart
│       ├── simple_statistics_screen.dart
│       └── simple_transactions_screen.dart
│
├── widgets/                            # Reusable widgets (69 files)
│   ├── widgets.dart                    # Barrel export
│   ├── ai_chat_sheet.dart              # AI chat bottom sheet
│   ├── ai_fab.dart                     # Floating AI button
│   ├── premium_nav_bar.dart            # Bottom navigation
│   ├── pursuit_card.dart               # Pursuit list item
│   ├── pursuit_progress_visual.dart    # Progress animation
│   ├── add_savings_sheet.dart          # Add savings modal
│   ├── create_pursuit_sheet.dart       # Create pursuit modal
│   ├── subscription_detail_sheet.dart  # Subscription details
│   ├── expense_form_content.dart       # Expense entry form
│   ├── decision_buttons.dart           # Yes/Thinking/No buttons
│   ├── result_card.dart                # Expense calculation result
│   ├── currency_rate_bar.dart          # Live rates display
│   ├── streak_widget.dart              # Streak counter
│   ├── upgrade_dialog.dart             # Premium upsell
│   └── ... (54 more widgets)
│
├── theme/                              # Design system (8 files)
│   ├── theme.dart                      # Barrel export
│   ├── app_theme.dart                  # Colors, typography
│   ├── app_spacing.dart                # Spacing constants
│   ├── app_animations.dart             # Animation definitions
│   ├── quiet_luxury.dart               # Premium design system
│   ├── premium_theme.dart              # Premium UI elements
│   ├── ai_finance_theme.dart           # AI chat theming
│   └── accessible_text.dart            # A11y text styles
│
├── utils/                              # Utilities (11 files)
│   ├── utils.dart                      # Barrel export
│   ├── currency_helper.dart            # Currency formatting
│   ├── currency_utils.dart             # Currency calculations
│   ├── finance_utils.dart              # Financial calculations
│   ├── achievement_utils.dart          # Achievement helpers
│   ├── security_utils.dart             # Input sanitization
│   ├── emoji_helper.dart               # Emoji utilities
│   ├── duplicate_checker.dart          # Duplicate detection
│   └── global_merchants.dart           # Global merchant database
│
├── constants/                          # Constants
│   └── app_limits.dart                 # Free tier limits
│
├── core/
│   └── theme/
│       └── premium_effects.dart        # Premium visual effects
│
├── data/
│   └── store_categories.dart           # 200+ store->category mappings
│
├── l10n/                               # Localization
│   ├── app_en.arb                      # English (~1,761 keys)
│   └── app_tr.arb                      # Turkish (~1,754 keys)
│
└── assets/
    ├── videos/                         # Splash video
    ├── icon/                           # App icons
    ├── sounds/                         # Sound effects
    └── animations/                     # Lottie animations
```

### 2.2 Dependencies

#### Core Framework
```yaml
flutter: 3.x
dart: ^3.10.4
```

#### State Management
```yaml
provider: ^6.1.2
```

#### Firebase Suite
```yaml
firebase_core: ^4.3.0
firebase_auth: ^6.1.3
cloud_firestore: ^6.1.1
firebase_crashlytics: ^5.0.6
firebase_analytics: ^12.0.0
firebase_messaging: ^16.1.0
firebase_storage: ^13.0.5
```

#### Authentication
```yaml
google_sign_in: 6.2.1
local_auth: ^2.1.8
```

#### Monetization
```yaml
purchases_flutter: ^8.1.0  # RevenueCat
```

#### AI & ML
```yaml
google_generative_ai: ^0.4.7  # Gemini
flutter_dotenv: ^5.1.0        # API keys
google_mlkit_text_recognition: ^0.15.0
speech_to_text: ^7.0.0
```

#### Networking
```yaml
http: ^1.2.0
connectivity_plus: ^7.0.0
xml: ^6.5.0
```

#### UI & Animations
```yaml
phosphor_flutter: ^2.1.0
lucide_icons: ^0.257.0
google_fonts: ^6.1.0
flutter_animate: ^4.5.0
confetti: ^0.7.0
lottie: ^3.1.0
shimmer: ^3.0.0
fl_chart: ^1.1.1
showcaseview: ^3.0.0
```

#### Storage
```yaml
shared_preferences: ^2.2.2
hive_flutter: ^1.1.0
path_provider: ^2.1.2
```

#### Data Export
```yaml
excel: ^4.0.2
csv: ^6.0.0
syncfusion_flutter_pdf: ^28.2.4
```

#### Media
```yaml
image_picker: ^1.0.7
video_player: ^2.8.2
fvp: ^0.35.2
share_plus: ^7.2.1
screenshot: ^2.1.0
audioplayers: ^5.2.1
```

#### Utilities
```yaml
intl: ^0.20.2
crypto: ^3.0.3
uuid: (implicit)
fuzzy: ^0.5.1
fuzzywuzzy: ^1.1.6
timezone: ^0.10.0
url_launcher: ^6.2.1
file_picker: ^8.0.0+1
permission_handler: ^11.3.0
app_links: ^6.1.1
home_widget: ^0.6.0
flutter_slidable: ^3.1.1
```

### 2.3 State Management

**Pattern:** Provider with ChangeNotifier

| Provider | Purpose | Key State |
|----------|---------|-----------|
| `ProProvider` | Premium status | `isPro`, `isLifetime`, `creditsRemaining` |
| `FinanceProvider` | Core finance | `userProfile`, `expenses`, `subscriptions` |
| `PursuitProvider` | Savings goals | `pursuits`, `activePursuits`, `totalSaved` |
| `CurrencyProvider` | Currency | `selectedCurrency`, `rates` |
| `LocaleProvider` | Language | `locale` (en/tr) |
| `ThemeProvider` | Theme | `themeMode` (dark/light/system) |
| `CategoryBudgetProvider` | Budgets | `budgets`, `budgetsWithSpent` |
| `SavingsPoolProvider` | Pool | `pool`, `available`, `shadowDebt` |

### 2.4 Backend Services

```
Firebase (flutter-ai-playground-b188b)
├── Authentication
│   ├── Anonymous (auto on first launch)
│   └── Google Sign-In (account linking)
│
├── Firestore (Database)
│   ├── users/{uid}/expenses
│   ├── users/{uid}/pursuits
│   ├── users/{uid}/pursuit_transactions
│   ├── users/{uid}/ai_usage/current
│   ├── promo_users/{uid}
│   └── app_data/exchange_rates
│
├── Cloud Storage
│   └── profile_photos/{fileName}
│
├── Cloud Functions (europe-west1)
│   ├── aiChat - AI chat processing
│   ├── updateExchangeRates - Hourly scheduler
│   ├── manualUpdateRates - Manual trigger
│   ├── getRates - Public API
│   ├── addPromoUser - Admin endpoint
│   └── addAICredits - Credit purchases
│
├── Analytics - Event tracking
├── Crashlytics - Crash reporting
└── Cloud Messaging - Push notifications
```

---

## 3. Screens and User Flows

### 3.1 All Screens (30)

| # | Screen | File | Purpose |
|---|--------|------|---------|
| 1 | Splash | `splash_screen.dart` | Video intro (2-3s) |
| 2 | Onboarding | `onboarding_screen.dart` | 3-page intro |
| 3 | Onboarding Pursuit | `onboarding_pursuit_screen.dart` | Pursuit intro |
| 4 | Onboarding Salary Day | `onboarding_salary_day_screen.dart` | Salary day setup |
| 5 | Onboarding Try | `onboarding_try_screen.dart` | Trial offer |
| 6 | Main | `main_screen.dart` | Bottom nav container |
| 7 | Expense | `expense_screen.dart` | Main expense entry |
| 8 | Report | `report_screen.dart` | Monthly statistics |
| 9 | Pursuit List | `pursuit_list_screen.dart` | Savings goals |
| 10 | Profile | `profile_screen.dart` | User profile view |
| 11 | Profile Modal | `profile_modal.dart` | Quick profile view |
| 12 | Subscription | `subscription_screen.dart` | Subscriptions list |
| 13 | Settings | `settings_screen.dart` | App settings |
| 14 | User Profile Edit | `user_profile_screen.dart` | Profile editing |
| 15 | Achievements | `achievements_screen.dart` | Badges gallery |
| 16 | Voice Input | `voice_input_screen.dart` | Voice expense entry |
| 17 | Habit Calculator | `habit_calculator_screen.dart` | Habit cost analysis |
| 18 | Income Wizard | `income_wizard_screen.dart` | Income setup |
| 19 | Currency Detail | `currency_detail_screen.dart` | Exchange rates |
| 20 | Import Statement | `import_statement_screen.dart` | Bank import |
| 21 | Notification Settings | `notification_settings_screen.dart` | Notification prefs |
| 22 | Lock Screen | `lock_screen.dart` | App lock |
| 23 | PIN Setup | `pin_setup_screen.dart` | PIN configuration |
| 24 | Paywall | `paywall_screen.dart` | Premium offers |
| 25 | Credit Purchase | `credit_purchase_screen.dart` | AI credit packs |
| 26 | Simple Main | `simple/simple_main_screen.dart` | Simple mode home |
| 27 | Simple Settings | `simple/simple_settings_screen.dart` | Simple settings |
| 28 | Simple Statistics | `simple/simple_statistics_screen.dart` | Simple stats |
| 29 | Simple Transactions | `simple/simple_transactions_screen.dart` | Simple history |
| 30 | Screens Barrel | `screens.dart` | Export file |

### 3.2 User Flows

#### First Launch Flow
```
SplashScreen (Video, 2-3s)
    │
    ├─→ First Launch?
    │   └─→ OnboardingScreen (3 pages)
    │       └─→ UserProfileScreen (create profile)
    │           └─→ OnboardingPursuitScreen
    │               └─→ OnboardingSalaryDayScreen
    │                   └─→ OnboardingTryScreen (trial)
    │                       └─→ MainScreen
    │
    └─→ Returning User?
        └─→ LockScreen (if enabled)
            └─→ MainScreen
```

#### Main App Navigation
```
MainScreen (Bottom Navigation)
├── Tab 1: ExpenseScreen (Harcama)
│   ├── Currency rates bar
│   ├── Expense input form
│   ├── Decision buttons (Aldim/Dusunuyorum/Vazgectim)
│   ├── Result card (work hours)
│   └── Recent expenses list
│
├── Tab 2: ReportScreen (Rapor)
│   ├── Period selector (weekly/monthly/yearly)
│   ├── Spending chart
│   ├── Category breakdown
│   └── Insights
│
├── Tab 3: PursuitListScreen (Hayallerim)
│   ├── Active pursuits
│   ├── Add pursuit button
│   └── Completed pursuits
│
└── Tab 4: ProfileScreen (Profil)
    ├── Profile info
    ├── Streak widget
    ├── Achievements preview
    ├── Subscriptions link
    └── Settings link
```

#### Expense Entry Flow
```
ExpenseScreen
    │
    ├─→ Enter Amount
    │   └─→ Select Category
    │       └─→ View Work Hours Result
    │           │
    │           ├─→ "Aldim" (Yes)
    │           │   └─→ Expense saved
    │           │
    │           ├─→ "Dusunuyorum" (Thinking)
    │           │   └─→ Saved as pending (72h)
    │           │
    │           └─→ "Vazgectim" (No)
    │               └─→ Amount added to savings pool
    │                   └─→ Can allocate to pursuit
```

#### AI Chat Flow
```
AI FAB Tap
    │
    └─→ AIChatSheet
        │
        ├─→ Free User
        │   ├─→ 4 Preset Buttons only
        │   ├─→ Text input locked
        │   └─→ 5 chats/day limit
        │
        └─→ Premium User
            ├─→ Free text input
            ├─→ 500 chats/month
            └─→ Full AI analysis
```

---

## 4. Features (Detailed)

### 4.1 Expense Tracking

**Description:** Core feature allowing users to log expenses and see how many work hours they represent.

**How it works:**
1. User enters expense amount
2. Selects category from 10 predefined categories
3. System calculates: `hours = amount / hourlyRate`
4. User makes decision: Yes (bought), Thinking (pending), No (skipped)

**Files:**
- `lib/screens/expense_screen.dart`
- `lib/widgets/expense_form_content.dart`
- `lib/widgets/decision_buttons.dart`
- `lib/widgets/result_card.dart`
- `lib/services/expense_history_service.dart`
- `lib/services/calculation_service.dart`

**Categories:**
1. Yiyecek (Food)
2. Ulasim (Transport)
3. Giyim (Clothing)
4. Elektronik (Electronics)
5. Eglence (Entertainment)
6. Saglik (Health)
7. Egitim (Education)
8. Faturalar (Bills)
9. Abonelik (Subscription)
10. Diger (Other)

### 4.2 AI Financial Assistant

**Description:** GPT-4o powered chat assistant that analyzes spending and provides personalized advice.

**How it works:**
1. User opens AI chat via floating button
2. AI has access to user's expense data via function calling
3. Provides insights based on spending patterns
4. Can add expenses via chat

**Files:**
- `lib/widgets/ai_chat_sheet.dart`
- `lib/widgets/ai_fab.dart`
- `lib/services/ai_service.dart`
- `lib/services/ai_tools.dart`
- `lib/services/ai_tool_handler.dart`
- `functions/index.js` (aiChat function)

**AI Tools (Function Calling):**
- `get_expenses_summary` - Monthly spending summary
- `get_category_breakdown` - Category details
- `add_expense` - Add expense via chat
- `get_budget_status` - Budget status
- `calculate_hourly_equivalent` - Work hours calculation

### 4.3 Savings Goals (Hayallerim/Pursuits)

**Description:** Visual savings goals with progress tracking and emoji/image customization.

**How it works:**
1. User creates a pursuit with name, target amount, emoji
2. Money from "Vazgectim" decisions goes to savings pool
3. User can allocate pool money to pursuits
4. Visual progress with fill-from-bottom animation
5. Celebration on completion

**Files:**
- `lib/screens/pursuit_list_screen.dart`
- `lib/widgets/pursuit_card.dart`
- `lib/widgets/pursuit_progress_visual.dart`
- `lib/widgets/create_pursuit_sheet.dart`
- `lib/widgets/add_savings_sheet.dart`
- `lib/widgets/pursuit_completion_modal.dart`
- `lib/services/pursuit_service.dart`
- `lib/providers/pursuit_provider.dart`

**Categories:**
- Tech, Travel, Home, Fashion, Vehicle, Education, Health, Other

### 4.4 Subscription Tracking

**Description:** Track recurring subscriptions with renewal reminders and cost analysis.

**How it works:**
1. Add subscription with name, amount, renewal day
2. System shows next renewal date
3. Optional auto-record: automatically creates expense on renewal
4. Calculates total annual cost

**Files:**
- `lib/screens/subscription_screen.dart`
- `lib/widgets/subscription_detail_sheet.dart`
- `lib/widgets/subscription_sheet.dart`
- `lib/services/subscription_service.dart`

### 4.5 Voice Input

**Description:** Add expenses using voice with AI-powered parsing.

**How it works:**
1. User taps voice button and speaks
2. Speech-to-text converts to text
3. GPT-4o-mini parses amount, category, description
4. User confirms and saves

**Files:**
- `lib/screens/voice_input_screen.dart`
- `lib/services/voice_parser_service.dart`

### 4.6 Bank Statement Import

**Description:** Import expenses from bank statement PDF/CSV files.

**How it works:**
1. User uploads bank statement file
2. AI parses transactions
3. User reviews and confirms
4. Expenses bulk-imported

**Files:**
- `lib/screens/import_statement_screen.dart`
- `lib/services/statement_parse_service.dart`
- `lib/services/import_service.dart`

### 4.7 Habit Calculator

**Description:** Calculate long-term cost of daily habits (coffee, cigarettes, etc.)

**How it works:**
1. User enters daily expense amount
2. System calculates weekly/monthly/yearly cost
3. Shows equivalent in work hours
4. Motivates behavior change

**Files:**
- `lib/screens/habit_calculator_screen.dart`

### 4.8 Reports & Analytics

**Description:** Visual reports of spending patterns with charts and insights.

**How it works:**
1. Select time period (weekly/monthly/yearly)
2. View spending breakdown by category
3. Compare with previous periods
4. Get AI-powered insights

**Files:**
- `lib/screens/report_screen.dart`
- `lib/widgets/financial_snapshot_card.dart`
- `lib/widgets/budget_breakdown_card.dart`
- `lib/widgets/expense_history_card.dart`

### 4.9 Achievements System

**Description:** Gamification with badges for financial milestones.

**How it works:**
1. Track progress on various achievements
2. Unlock badges for reaching milestones
3. Tiers: Bronze, Silver, Gold, Platinum
4. Hidden achievements for extra engagement

**Files:**
- `lib/screens/achievements_screen.dart`
- `lib/services/achievements_service.dart`
- `lib/utils/achievement_utils.dart`
- `lib/models/achievement.dart`

**Achievement Categories:**
- Streak (consecutive days)
- Savings (money saved)
- Decision (good financial decisions)
- Record (expense recording milestones)
- Hidden (secret achievements)

### 4.10 Multi-Currency Support

**Description:** Support for 5 currencies with real-time exchange rates.

**How it works:**
1. Income can be in any currency
2. Expenses converted to base currency
3. Rates from TCMB (Turkish Central Bank)
4. Gold prices from Truncgil API

**Files:**
- `lib/services/currency_service.dart`
- `lib/services/exchange_rate_service.dart`
- `lib/widgets/currency_rate_bar.dart`
- `lib/widgets/currency_selector.dart`
- `lib/providers/currency_provider.dart`

**Supported Currencies:**
| Code | Symbol | Name | Gold Unit |
|------|--------|------|-----------|
| TRY | ₺ | Turkish Lira | gram |
| USD | $ | US Dollar | ounce |
| EUR | € | Euro | ounce |
| GBP | £ | British Pound | ounce |
| SAR | ر.س | Saudi Riyal | ounce |

### 4.11 Streak Tracking

**Description:** Daily engagement tracking with streak counter.

**How it works:**
1. Record any expense = day counted
2. Consecutive days build streak
3. Missing a day resets streak
4. Milestones at 5, 10, 30, 60, 100 days

**Files:**
- `lib/widgets/streak_widget.dart`
- `lib/services/streak_service.dart`

### 4.12 App Lock

**Description:** Security feature with PIN/biometric lock.

**How it works:**
1. Enable in settings
2. Set 4-digit PIN
3. Optionally enable biometric
4. Required on app launch

**Files:**
- `lib/screens/lock_screen.dart`
- `lib/screens/pin_setup_screen.dart`

### 4.13 Data Export

**Description:** Export expense data to Excel or PDF.

**How it works:**
1. Select date range
2. Choose format (Excel/PDF)
3. Generate and share file

**Files:**
- `lib/services/export_service.dart`

### 4.14 Simple Mode

**Description:** Simplified UI for users who want basic functionality only.

**How it works:**
1. Toggle in settings
2. Reduced UI complexity
3. Basic expense tracking only
4. No advanced features

**Files:**
- `lib/screens/simple/simple_main_screen.dart`
- `lib/screens/simple/simple_settings_screen.dart`
- `lib/screens/simple/simple_statistics_screen.dart`
- `lib/screens/simple/simple_transactions_screen.dart`

---

## 5. Free vs Pro Comparison

### 5.1 Feature Comparison

| Feature | FREE | PRO |
|---------|------|-----|
| **AI Chat** | 4 preset buttons | Free text input |
| **AI Credits** | 5/day | 500/month |
| **Voice Input** | 3/day | 10/day |
| **Pursuits** | 1 active | Unlimited |
| **Expense History** | 30 days | Full history |
| **Currency** | TRY only | 5 currencies |
| **Reports** | Weekly only | All periods |
| **Export** | - | Excel & PDF |
| **Bank Import** | - | Full access |
| **Themes** | Dark only | Dark & Light |
| **Ad-free** | No | Yes |

### 5.2 Limits Detail

#### Free Tier Limits (from `app_limits.dart`)
```dart
static const int freeAiChatsPerDay = 5;
static const int freeVoiceInputsPerDay = 3;
static const int freeMaxPursuits = 1;
static const int freeExpenseHistoryDays = 30;
static const int freeMaxExpenses = 100;
```

#### Pro Tier Limits
```dart
static const int proAiCreditsPerMonth = 500;
static const int proVoiceInputsPerDay = 10;
// Pursuits: Unlimited
// History: Full
// Expenses: Unlimited (Firestore)
```

### 5.3 Pricing (TRY)

| Product | Price | Credits |
|---------|-------|---------|
| Pro Monthly | ₺49.99/mo | 500/mo |
| Pro Yearly | ₺399.99/yr | 500/mo |
| Lifetime | ₺999.99 | 200/mo base |
| Credit Pack 50 | ₺19.99 | 50 |
| Credit Pack 150 | ₺49.99 | 150 |
| Credit Pack 500 | ₺149.99 | 500 |

### 5.4 RevenueCat Configuration

**Entitlements:**
- `pro` - Pro subscription active
- `lifetime` - Lifetime purchase

**Product IDs:**
- `vantag_pro_monthly`
- `vantag_pro_yearly`
- `vantag-pro-lifetime`
- `credit_pack_50`
- `credit_pack_150`
- `credit_pack_500`

---

## 6. APIs and Services

### 6.1 OpenAI (GPT-4o)

| Aspect | Details |
|--------|---------|
| **Purpose** | Main AI chat, financial analysis |
| **Model** | GPT-4o |
| **Endpoint** | Cloud Function: `aiChat` |
| **Cost** | ~$0.03/1K input, $0.06/1K output tokens |
| **Timeout** | 60 seconds |

**Used In:**
- AI chat responses
- Expense analysis
- Financial advice
- Function calling for data access

### 6.2 OpenAI (GPT-4o-mini)

| Aspect | Details |
|--------|---------|
| **Purpose** | Voice parsing, statement parsing |
| **Model** | GPT-4o-mini |
| **Endpoint** | Direct HTTP call |
| **Cost** | ~$0.0005/1K input, $0.0015/1K output tokens |
| **Timeout** | 30 seconds |

**Used In:**
- Voice-to-expense parsing
- Bank statement parsing

### 6.3 Google Gemini (2.0 Flash)

| Aspect | Details |
|--------|---------|
| **Purpose** | Fact extraction from chat |
| **Model** | gemini-2.0-flash |
| **Package** | `google_generative_ai` |
| **Cost** | ~$0.075/1M tokens |
| **Frequency** | Every 5 chat messages |

**Used In:**
- User fact learning (habits, preferences)
- Chat context building

### 6.4 TCMB (Turkish Central Bank)

| Aspect | Details |
|--------|---------|
| **Purpose** | Official TRY exchange rates |
| **Endpoint** | `https://www.tcmb.gov.tr/kurlar/today.xml` |
| **Format** | XML |
| **Cost** | Free |
| **Cache** | 1 hour |

**Rates Provided:**
- USD/TRY
- EUR/TRY
- GBP/TRY

### 6.5 Truncgil API

| Aspect | Details |
|--------|---------|
| **Purpose** | Turkish gold prices |
| **Endpoint** | `https://finans.truncgil.com/v4/today.json` |
| **Format** | JSON |
| **Cost** | Free |
| **Cache** | 1 day |

**Data Provided:**
- Gram gold buying/selling prices (TRY)

### 6.6 RevenueCat

| Aspect | Details |
|--------|---------|
| **Purpose** | Subscription & IAP management |
| **SDK** | `purchases_flutter: ^8.1.0` |
| **Platform** | Android, iOS |
| **Features** | Purchase, restore, entitlement check |

### 6.7 Firebase Services

| Service | Purpose |
|---------|---------|
| **Auth** | User authentication |
| **Firestore** | Cloud database |
| **Storage** | Profile photos |
| **Analytics** | Event tracking |
| **Crashlytics** | Crash reporting |
| **Messaging** | Push notifications |
| **Functions** | Backend logic |

### 6.8 Estimated Monthly Costs

| Service | Free User | Pro User |
|---------|-----------|----------|
| AI Chat | $0.01-0.02 | $0.10-0.30 |
| Voice Parse | $0.001 | $0.005 |
| Gemini | $0.001 | $0.005 |
| Firebase | Included | Included |
| **Total** | ~$0.02 | ~$0.35 |

---

## 7. Data Models

### 7.1 UserProfile

```dart
class UserProfile {
  List<IncomeSource> incomeSources;  // Multiple income support
  double dailyHours;                  // Work hours/day (1-24)
  int workDaysPerWeek;                // Work days/week (1-7)
  double? monthlyBudget;              // Spending limit
  double? monthlySavingsGoal;         // Savings target
  String? referralCode;               // VANTAG-XXXXX
  String? referredBy;                 // Who referred
  int referralCount;                  // Referral count
  int? salaryDay;                     // Day of month (1-31)
  double? currentBalance;             // Bank balance
  DateTime? lastSalaryConfirmedDate;
  String? baseCurrency;               // TRY, USD, etc.

  // Computed
  double get monthlyIncome;           // Sum of sources
  double get hourlyRate;              // Income / hours
  bool get isPayday;
  int get daysUntilPayday;
}
```

### 7.2 Expense

```dart
class Expense {
  double amount;
  String category;                    // 10 categories
  String? subCategory;
  DateTime date;
  double hoursRequired;               // Calculated
  double daysRequired;                // Calculated
  ExpenseDecision? decision;          // yes, thinking, no
  DateTime? decisionDate;
  RecordType recordType;              // real, simulation
  ExpenseStatus status;               // active, thinking, archived
  double? savedFrom;                  // Smart Choice
  bool isSmartChoice;
  String? originalCurrency;           // For conversion
  double? originalAmount;
  ExpenseType type;                   // single, recurring, installment
  bool isMandatory;
  int? installmentCount;
  int? currentInstallment;
  double? cashPrice;
  double? installmentTotal;
  bool isAutoRecorded;                // From subscription
  String? subscriptionId;
}
```

### 7.3 Pursuit

```dart
class Pursuit {
  String id;                          // UUID
  String name;
  double targetAmount;
  String currency;
  double savedAmount;
  String? imageUrl;
  String emoji;
  PursuitCategory category;           // 8 categories
  DateTime createdAt;
  DateTime? completedAt;
  bool isArchived;
  int sortOrder;

  // Computed
  double get progressPercent;         // 0.0 - 1.0
  bool get isCompleted;
  double get remainingAmount;
}
```

### 7.4 Subscription

```dart
class Subscription {
  String id;
  String name;
  double amount;
  int renewalDay;                     // 1-31
  String category;
  bool isActive;
  bool autoRecord;                    // Auto-create expense
  DateTime createdAt;
  int colorIndex;                     // Color palette
  String? notes;

  // Computed
  DateTime get nextRenewalDate;
  int get daysUntilRenewal;
  double get totalPaid;               // Estimated total
}
```

### 7.5 Achievement

```dart
class Achievement {
  String id;
  String title;
  String description;
  AchievementCategory category;       // streak, savings, decision, record, hidden
  AchievementTier tier;               // bronze, silver, gold, platinum
  int subTier;                        // 1, 2, 3
  double progress;                    // 0.0 - 1.0
  int currentValue;
  int targetValue;
  DateTime? unlockedAt;
  bool isHidden;
  HiddenDifficulty? hiddenDifficulty;
}
```

### 7.6 Firestore Structure

```
firestore/
├── users/
│   └── {uid}/
│       ├── expenses/
│       │   └── {expenseId}           # Expense documents
│       ├── pursuits/
│       │   └── {pursuitId}           # Pursuit documents
│       ├── pursuit_transactions/
│       │   └── {transactionId}       # Transaction records
│       └── ai_usage/
│           └── current               # Daily/monthly quotas
│
├── promo_users/
│   └── {uid}                         # Promo access grants
│
└── app_data/
    └── exchange_rates                # Cached rates
```

---

## 8. Localization

### 8.1 Supported Languages

| Language | Code | Status | Keys |
|----------|------|--------|------|
| English | `en` | Complete | 1,761 |
| Turkish | `tr` | Complete | 1,754 |

### 8.2 Key Statistics

| Metric | Count |
|--------|-------|
| Total English Keys | 1,761 |
| Total Turkish Keys | 1,754 |
| Missing in Turkish | 7 (placeholders) |
| Missing in English | 0 |

### 8.3 Key Categories

| Category | Keys | Purpose |
|----------|------|---------|
| achievement* | 124 | Badge system |
| excel* | 77 | Excel export |
| msg* | 56 | General messages |
| pursuit* | 32 | Savings goals |
| income* | 31 | Income tracking |
| ai* | 30 | AI chat |
| accessibility* | 30 | A11y labels |
| import* | 29 | Data import |
| settings* | 28 | App settings |
| pro* | 26 | Premium features |
| tour* | 25 | Onboarding |
| category* | 24 | Expense categories |

### 8.4 Files

```
lib/l10n/
├── app_en.arb    # English translations
└── app_tr.arb    # Turkish translations
```

### 8.5 Usage

```dart
import 'package:vantag/l10n/app_localizations.dart';

// In widget
final l10n = AppLocalizations.of(context)!;
Text(l10n.expenses);              // "Expenses" or "Harcamalar"
Text(l10n.streakDays(5));         // "5 days" or "5 gun"
```

### 8.6 Regenerate

```bash
flutter gen-l10n
```

---

## 9. Security

### 9.1 Authentication

| Method | Description |
|--------|-------------|
| **Anonymous** | Auto-created on first launch |
| **Google Sign-In** | Account linking for backup |
| **Firebase Auth** | Backend authentication |

### 9.2 Data Protection

| Feature | Implementation |
|---------|----------------|
| **Local Storage** | SharedPreferences (encrypted on device) |
| **Cloud Storage** | Firestore with security rules |
| **API Keys** | Environment variables (.env) |
| **Network** | HTTPS only |

### 9.3 App Lock

| Feature | Implementation |
|---------|----------------|
| **PIN Lock** | 4-digit code |
| **Biometric** | Fingerprint/Face ID |
| **Auto-lock** | On app background |
| **Max Attempts** | 5 before lockout |

### 9.4 Input Sanitization

```dart
// SecurityUtils class
static String sanitizeInput(String input);
static bool isValidAmount(String amount);
static bool isValidEmail(String email);
static String maskSensitiveData(String data);
```

### 9.5 Firebase Security Rules

```javascript
// Firestore Rules
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

match /users/{userId}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

match /promo_users/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if false; // Admin only via Cloud Functions
}
```

### 9.6 GDPR/KVKK Compliance

| Feature | Status |
|---------|--------|
| Privacy Policy | Complete (EN/TR) |
| Terms of Service | Complete (EN/TR) |
| Data Export | Implemented |
| Account Deletion | Implemented |
| Data Portability | Via export feature |

---

## 10. Known Issues and TODOs

### 10.1 Open Issues

| Issue | Severity | Status |
|-------|----------|--------|
| None critical | - | - |

### 10.2 Future Features

| Feature | Priority | Description |
|---------|----------|-------------|
| Receipt Scanner | High | OCR-based expense entry |
| Budget Alerts | High | Push notifications for budget limits |
| Shared Expenses | Medium | Split expenses with others |
| Investment Tracking | Medium | Track investment portfolio |
| Desktop App | Low | macOS/Windows native app |
| Web App | Low | PWA version |

### 10.3 Technical Debt

| Item | Description | Priority |
|------|-------------|----------|
| Test Coverage | Add more unit/widget tests | Medium |
| Code Documentation | Add dartdoc comments | Low |
| Performance | Profile and optimize | Low |

### 10.4 Deprecation Warnings

```
Firebase functions.config() - Migrate to params package before March 2026
```

---

## 11. Deployment

### 11.1 Android Build

```bash
# Debug
flutter run -d android

# Release APK
flutter build apk --release

# Release Bundle (Play Store)
flutter build appbundle --release
```

**Signing:**
- Keystore: `android/app/upload-keystore.jks`
- Key alias: `upload`
- Configured in: `android/key.properties`

### 11.2 iOS Build

```bash
# Debug
flutter run -d ios

# Release
flutter build ios --release

# Archive (Xcode)
# Open ios/Runner.xcworkspace
# Product > Archive
```

### 11.3 Firebase Configuration

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Deploy functions
cd functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:aiChat
```

### 11.4 RevenueCat Configuration

1. Create app in RevenueCat dashboard
2. Add products in Google Play Console
3. Configure entitlements: `pro`, `lifetime`
4. Add API key to `.env`

### 11.5 Environment Variables

```env
# .env file (root)
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=AIza...
REVENUECAT_API_KEY=goog_...
```

### 11.6 Firebase Functions Config

```bash
# Set OpenAI key
firebase functions:config:set openai.key="sk-..."

# Deploy with config
firebase deploy --only functions
```

---

## 12. Project Statistics

### 12.1 File Counts

| Category | Count |
|----------|-------|
| **Total Dart Files** | 218 |
| **Screens** | 30 |
| **Widgets** | 69 |
| **Services** | 55 |
| **Providers** | 9 |
| **Models** | 15 |
| **Theme Files** | 8 |
| **Utility Files** | 11 |
| **Test Files** | 13 |

### 12.2 Lines of Code

| Category | Lines |
|----------|-------|
| **Total (lib/)** | 112,096 |
| **Widgets** | 34,245 (30.6%) |
| **Screens** | 25,707 (22.9%) |
| **Services** | 17,146 (15.3%) |
| **Theme** | 3,415 (3.1%) |
| **Models** | 2,787 (2.5%) |
| **Providers** | 2,242 (2.0%) |
| **Utils** | 1,872 (1.7%) |

### 12.3 Dependencies

| Category | Count |
|----------|-------|
| **Total Dependencies** | 50+ |
| **Firebase Packages** | 7 |
| **UI Packages** | 10 |
| **Storage Packages** | 3 |
| **Export Packages** | 3 |
| **Dev Dependencies** | 3 |

### 12.4 Localization

| Metric | Count |
|--------|-------|
| **Languages** | 2 (EN, TR) |
| **Total Keys** | ~3,500 |
| **Key Categories** | 188 |

### 12.5 Code Quality

| Metric | Value |
|--------|-------|
| **TODOs/FIXMEs** | 0 |
| **Dart Analyze Issues** | 27 (non-critical) |
| **Test Coverage** | 13 test files |
| **Tests Passing** | 199 |

---

## Quick Reference

### Common Commands

```bash
# Run app
flutter run -d android
flutter run -d windows

# Build
flutter build apk --release
flutter build appbundle --release

# Test
flutter test
flutter analyze

# Localization
flutter gen-l10n

# Dependencies
flutter pub get
flutter pub upgrade

# Firebase
firebase deploy --only functions
firebase deploy --only functions:aiChat
```

### Key Files

| Purpose | File |
|---------|------|
| Entry Point | `lib/main.dart` |
| Firebase Config | `lib/firebase_options.dart` |
| App Theme | `lib/theme/app_theme.dart` |
| Main Screen | `lib/screens/main_screen.dart` |
| AI Service | `lib/services/ai_service.dart` |
| Pro Provider | `lib/providers/pro_provider.dart` |
| Cloud Functions | `functions/index.js` |
| Localization EN | `lib/l10n/app_en.arb` |
| Localization TR | `lib/l10n/app_tr.arb` |
| Environment | `.env` |

### Support

- **Email:** vantagfinance@gmail.com
- **Developer:** Gencay Alla
- **Location:** Istanbul, Turkey

---

*Document generated: January 2026*
*Vantag v1.0.2+4*
