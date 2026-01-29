# VANTAG - Final Technical Analysis Report

**Version:** 1.0.1+3
**Date:** January 2026
**Package:** com.vantag.app

---

## Executive Summary

Vantag is a comprehensive personal finance awareness app built with Flutter, targeting Turkish-speaking users. The app helps users understand how much work time is required to afford purchases based on their income and work schedule.

---

## Codebase Statistics

| Metric | Value |
|--------|-------|
| Total Dart Files | 205 |
| Total Lines of Code | 111,131 |
| Screens | 30 |
| Widgets | 71 |
| Services | 55 |
| Providers | 9 |
| Models | 15 |
| Localization Keys (EN) | ~2,990 lines |
| Localization Keys (TR) | ~2,624 lines |
| TODOs/FIXMEs | 0 |

---

## Architecture Overview

### Directory Structure
```
lib/
├── main.dart                    # App entry + providers setup
├── models/          (15 files)  # Data models
├── services/        (55 files)  # Business logic
├── providers/       (9 files)   # State management (Provider)
├── screens/         (30 files)  # UI screens
├── widgets/         (71 files)  # Reusable components
├── theme/           (4 files)   # Design system
├── l10n/            (2 files)   # Localization (EN/TR)
├── constants/       (2 files)   # App limits & constants
├── utils/           (6 files)   # Utility functions
└── data/            (1 file)    # Store categories
```

---

## Dependencies Summary

### Core Framework
- Flutter 3.x (SDK ^3.10.4)
- Dart 3.x

### State Management
- `provider: ^6.1.2`

### Firebase Stack
- `firebase_core: ^4.3.0`
- `firebase_auth: ^6.1.3`
- `cloud_firestore: ^6.1.1`
- `firebase_crashlytics: ^5.0.6`
- `firebase_analytics: ^12.0.0`
- `firebase_messaging: ^16.1.0`
- `firebase_storage: ^13.0.5`

### Monetization
- `purchases_flutter: ^8.1.0` (RevenueCat)

### AI Integration
- `http: ^1.2.0` (OpenAI API via Cloud Function)
- `google_generative_ai: ^0.4.7` (Gemini fallback)

### UI Components
- `phosphor_flutter: ^2.1.0` (Icons)
- `fl_chart: ^1.1.1` (Charts)
- `flutter_animate: ^4.5.0` (Animations)
- `confetti: ^0.7.0` (Celebrations)
- `shimmer: ^3.0.0` (Loading effects)

### Media & Sharing
- `video_player: ^2.8.2`
- `share_plus: ^7.2.1`
- `screenshot: ^2.1.0`
- `image_gallery_saver_plus: ^4.0.1`

### Security
- `local_auth: ^2.1.8` (Biometric/PIN)

### Voice & AI
- `speech_to_text: ^7.0.0`
- Voice parsing: OpenAI gpt-4o-mini (client-side)
- Statement parsing: OpenAI gpt-4o-mini (client-side)
- AI Chat: OpenAI gpt-4o (Cloud Function)

### Export & Import
- `excel: ^4.0.2`
- `syncfusion_flutter_pdf: ^28.2.4`
- `file_picker: ^8.0.0+1`
- `csv: ^6.0.0`

---

## Screens Inventory (30 total)

### Main Navigation
1. `main_screen.dart` - Bottom navigation container
2. `expense_screen.dart` - Expense entry (main)
3. `report_screen.dart` - Analytics & reports
4. `pursuit_list_screen.dart` - Savings goals
5. `profile_screen.dart` - User profile

### Onboarding & Auth
6. `splash_screen.dart` - Video splash
7. `onboarding_screen.dart` - 3-page intro
8. `onboarding_try_screen.dart` - Aha moment
9. `onboarding_salary_day_screen.dart` - Salary setup
10. `onboarding_pursuit_screen.dart` - First pursuit
11. `user_profile_screen.dart` - Profile creation/edit

### Settings & Configuration
12. `settings_screen.dart` - App settings
13. `profile_modal.dart` - Quick profile view
14. `notification_settings_screen.dart` - Notifications
15. `income_wizard_screen.dart` - Income setup wizard

### Features
16. `subscription_screen.dart` - Subscription tracking
17. `achievements_screen.dart` - Badges & achievements
18. `habit_calculator_screen.dart` - Viral habit cost calculator
19. `voice_input_screen.dart` - Voice expense entry
20. `import_statement_screen.dart` - PDF/CSV import
21. `currency_detail_screen.dart` - Exchange rates

### Premium
22. `paywall_screen.dart` - RevenueCat paywall
23. `credit_purchase_screen.dart` - AI credit purchase

### Security
24. `lock_screen.dart` - PIN/Biometric unlock
25. `pin_setup_screen.dart` - PIN configuration

### Simple Mode (5)
26. `simple_main_screen.dart`
27. `simple_settings_screen.dart`
28. `simple_statistics_screen.dart`
29. `simple_transactions_screen.dart`

---

## Services Inventory (55 total)

### Core Business Logic
- `calculation_service.dart` - Work time calculations
- `expense_history_service.dart` - Expense CRUD
- `profile_service.dart` - Profile persistence
- `pursuit_service.dart` - Savings goals CRUD
- `subscription_service.dart` - Subscription management
- `budget_service.dart` - Budget CRUD
- `category_budget_service.dart` - Category budgets

### AI & Intelligence
- `ai_service.dart` - OpenAI Cloud Function integration
- `ai_tools.dart` - AI function calling definitions
- `ai_tool_handler.dart` - Tool execution handler
- `ai_memory_service.dart` - Chat history persistence
- `insight_service.dart` - Financial insights
- `voice_parser_service.dart` - Voice to expense parsing
- `statement_parse_service.dart` - PDF/CSV AI parsing

### Monetization
- `purchase_service.dart` - RevenueCat integration
- `free_tier_service.dart` - Free/Pro limit enforcement

### External APIs
- `currency_service.dart` - TCMB exchange rates
- `exchange_rate_service.dart` - Multi-currency conversion
- `connectivity_service.dart` - Network status

### Learning & Intelligence
- `merchant_learning_service.dart` - Store recognition
- `category_learning_service.dart` - Category suggestions

### Notifications & Feedback
- `notification_service.dart` - Local notifications
- `push_notification_service.dart` - Firebase FCM
- `sound_service.dart` - Audio feedback
- `haptic_service.dart` - Vibration feedback
- `sensory_feedback_service.dart` - Combined feedback

### Analytics & Tracking
- `analytics_service.dart` - Firebase Analytics events
- `streak_service.dart` - Daily streak tracking
- `achievements_service.dart` - Badge unlocking
- `victory_manager.dart` - Celebration triggers

### Security
- `lock_service.dart` - Biometric/PIN management
- `auth_service.dart` - Firebase Auth
- `device_service.dart` - Single device policy

### Export & Import
- `export_service.dart` - Excel export (6 sheets)
- `import_service.dart` - CSV/PDF import
- `share_service.dart` - Social sharing

### Utilities
- `accessibility_service.dart` - A11y features
- `deep_link_service.dart` - App links handling
- `widget_service.dart` - Home screen widgets
- `tour_service.dart` - Showcase/tutorial
- `offline_queue_service.dart` - Offline sync
- `simple_mode_service.dart` - Simplified UI mode

---

## Providers Inventory (9 total)

| Provider | Purpose |
|----------|---------|
| `FinanceProvider` | Core finance state (expenses, profile) |
| `ProProvider` | Premium status (RevenueCat) |
| `PursuitProvider` | Savings goals state |
| `CurrencyProvider` | Selected currency |
| `LocaleProvider` | Language selection |
| `ThemeProvider` | Dark/Light/System theme |
| `SavingsPoolProvider` | General savings pool |
| `CategoryBudgetProvider` | Category budgets |

---

## Models Inventory (15 total)

| Model | Description |
|-------|-------------|
| `UserProfile` | User data with income sources |
| `Expense` | Expense with decision tracking |
| `ExpenseResult` | Calculation result |
| `Subscription` | Recurring subscriptions |
| `Pursuit` | Savings goals |
| `PursuitTransaction` | Savings transactions |
| `Achievement` | Badges/achievements |
| `Currency` | Currency model |
| `IncomeSource` | Individual income source |
| `Income` | Legacy income model |
| `CategoryBudget` | Category budget |
| `SavingsPool` | General savings |
| `VoiceParseResult` | Voice input result |
| `PersonalityMode` | UI personality |

---

## FREE vs PRO Feature Comparison

### FREE Tier Limits (AppLimits)
| Feature | Limit |
|---------|-------|
| AI Chat | 4 preset buttons/day (no free text) |
| Voice Input | 3/day |
| Active Pursuits | 1 |
| Expense History | 30 days |
| Currency | TRY only |
| Reports | Weekly only |
| Export | Not available |
| Statement Import | 1/month |

### PRO Features
| Feature | Pro Monthly | Pro Lifetime |
|---------|-------------|--------------|
| AI Chat | Unlimited free text | Unlimited free text |
| Voice Input | 10/day (shown as unlimited) | 10/day |
| Pursuits | Unlimited | Unlimited |
| Expense History | Full | Full |
| Currency | 5 currencies | 5 currencies |
| Reports | All periods | All periods |
| Export | Excel/PDF | Excel/PDF |
| Statement Import | 10/month | 10/month |
| Watermark | None | None |

### Reports Screen - PRO Locked Features
- Expense Heatmap
- Category Breakdown (detailed)
- Spending Trends (chart)
- Time Analysis
- Budget Breakdown
- Advanced Filters
- Excel Export

---

## API Usage & Costs

### AI Chat (Cloud Function)
- **Model:** gpt-4o
- **Deployment:** Firebase Cloud Functions
- **Estimated cost:** ~$0.015/1K input tokens, ~$0.06/1K output tokens
- **Average per message:** ~$0.001-0.003
- **FREE limit:** 4 preset buttons/day
- **PRO:** Unlimited

### Voice Parser (Client-Side)
- **Model:** gpt-4o-mini
- **Estimated cost:** ~$0.00015/1K input, ~$0.0006/1K output
- **Average per parse:** ~$0.0001-0.0003
- **FREE limit:** 3/day
- **PRO limit:** 10/day (shown as unlimited)

### Statement Parser (Client-Side)
- **Model:** gpt-4o-mini
- **Average per document:** ~$0.001-0.005
- **FREE limit:** 1/month
- **PRO limit:** 10/month

### Estimated Monthly Cost per Active User
| User Type | Estimated Cost |
|-----------|---------------|
| FREE | ~$0.01-0.02/month |
| PRO | ~$0.10-0.30/month |

---

## Localization Status

### Supported Languages
- English (app_en.arb) - ~2,990 lines
- Turkish (app_tr.arb) - ~2,624 lines

### Key Categories
- Navigation & Common: ~50 keys
- Expense Entry: ~80 keys
- Reports & Analytics: ~60 keys
- Subscriptions: ~40 keys
- Pursuits (Hayallerim): ~70 keys
- AI Chat: ~30 keys
- Achievements: ~40 keys
- Settings: ~50 keys
- Errors & Validation: ~40 keys
- PRO Features: ~20 keys
- Voice Input: ~15 keys

### Generation Command
```bash
flutter gen-l10n
```

---

## Security Features

### Authentication
- Firebase Auth with Google Sign-In
- Single device policy (DeviceService)
- Session management

### App Lock
- Biometric authentication (Face ID/Fingerprint)
- PIN code fallback
- Auto-lock on background

### Data Protection
- Local encryption via SharedPreferences
- Secure storage for API keys (.env)
- Input sanitization (SecurityUtils)

### Privacy
- GDPR compliance ready
- Account deletion flow
- Data export capability

---

## Performance Optimizations

### UI Performance
- Lazy loading for lists
- Image caching
- Animation optimizations
- Shimmer loading states

### Data Performance
- Locking mechanism for concurrent writes
- Offline queue for sync
- Cached calculations

### Memory Management
- Singleton services
- Provider-based state
- Proper dispose patterns

---

## Recent Updates (January 2026)

### Night Work Edition - Phases 1-10
1. Bug fixes (Share Card, Habit Calculator, Category Localization)
2. Full test coverage (199 tests)
3. Code audit & cleanup
4. Firebase Crashlytics & Analytics integration
5. Legal & Compliance (Privacy, ToS, Delete Account)
6. Light mode theme support
7. Security hardening
8. Localization complete (~530 keys/language)

### Latest Changes
- FREE/PRO Reports screen separation with blur effect
- AI model updates (gpt-4o for chat, gpt-4o-mini for parsing)
- Voice input limit increased (1 -> 3/day for FREE)
- Usage indicators (used/total format)
- Modal barrier color standardization (0.85 opacity)

---

## Recommendations

### Short-term
1. Add unit test coverage for new FREE/PRO logic
2. Implement rate limiting on Cloud Functions
3. Add retry logic for AI API failures
4. Cache AI responses for similar queries

### Medium-term
1. Implement cloud sync for expense data
2. Add widget customization options
3. Implement receipt OCR scanning
4. Add budget alerts/notifications

### Long-term
1. Multi-user/family accounts
2. Investment tracking integration
3. Bank account linking (Open Banking)
4. AI-powered financial advisor
5. Cross-platform desktop app

---

## Technical Debt

### Current Issues: 0
All TODOs and FIXMEs have been resolved.

### Areas for Improvement
1. Some widgets exceed 500 lines - consider splitting
2. Service layer could benefit from interface abstraction
3. Test coverage for edge cases in currency conversion
4. Documentation for complex calculation algorithms

---

## Deployment Checklist

### Android
- [x] google-services.json configured
- [x] Release signing configured
- [x] ProGuard rules for Firebase
- [x] Min SDK 24 (Android 7.0)
- [x] Target SDK 34

### iOS
- [ ] GoogleService-Info.plist (if needed)
- [ ] Provisioning profiles
- [ ] App Store metadata
- [ ] Privacy policy URL

### Firebase
- [x] Firestore rules configured
- [x] Analytics enabled
- [x] Crashlytics enabled
- [x] Cloud Functions deployed (aiChat)
- [x] Authentication providers (Google)

### RevenueCat
- [x] API key configured
- [x] Products created (monthly, yearly, lifetime, credits)
- [x] Entitlements (pro, lifetime)

---

## File Counts Summary

| Category | Count |
|----------|-------|
| Screens | 30 |
| Widgets | 71 |
| Services | 55 |
| Providers | 9 |
| Models | 15 |
| Theme files | 4 |
| Utility files | 6 |
| Constant files | 2 |
| Data files | 1 |
| Localization files | 2 |
| **Total Dart Files** | **205** |
| **Total LOC** | **111,131** |

---

*Generated: January 2026*
*Vantag - Finansal Ustunlugun*
