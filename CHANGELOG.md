# Changelog

All notable changes to Vantag will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-01-26

### Added
- Comprehensive project documentation (VANTAG_COMPLETE_ANALYSIS.md)
- Marketing roadmap and strategy document (VANTAG_ROADMAP.md)
- Store listing content for Google Play and App Store (STORE_LISTING.md)
- CLAUDE.md for AI assistant guidance

### Changed
- AI now responds in user's selected language (Turkish/English)
- AI greeting cache now includes language in key to prevent wrong language responses
- Upgraded AI model to GPT-4o for better quality responses

### Fixed
- AI chat language detection - responses now match app language
- Modal/bottom sheet transparency issues with proper barrierColor
- AI greeting appearing in wrong language after language switch

## [1.0.2] - 2026-01-25

### Added
- Google account linking in profile modal
- Currency conversion with TCMB API rates

### Fixed
- FAB (Floating Action Button) visibility issues
- AI language response consistency
- Currency selection in non-TRY income scenarios
- ResultCard currency conversion for non-TRY income

## [1.0.1] - 2026-01-24

### Added
- Firebase Crashlytics integration for crash reporting
- Firebase Analytics for user behavior tracking
- Light mode theme support with ThemeProvider
- Security hardening with SecurityUtils
- Legal compliance: Privacy Policy, Terms of Service
- Account deletion functionality
- Purchase restoration feature

### Changed
- Improved localization coverage (~530 keys per language)
- Enhanced error handling throughout the app

### Fixed
- Share Card generation issues
- Habit Calculator edge cases
- Category localization in reports
- Various UI overflow issues

## [1.0.0] - 2026-01-20

### Added
- **Core Features**
  - Expense tracking with work-hour conversion
  - Income and work schedule configuration
  - Decision tracking: "Bought", "Thinking", "Passed"
  - Expense history with filtering and search

- **AI Features**
  - AI financial assistant powered by GPT-4o
  - Voice input for expense entry (GPT-4o-mini)
  - Bank statement import with AI parsing
  - Personalized financial insights

- **Savings Goals (Hayallerim)**
  - Create savings goals with emoji/image
  - Progress tracking with visual fill animation
  - Automatic savings from "Passed" decisions
  - Celebration animations on goal completion

- **Subscription Tracking**
  - Track recurring subscriptions
  - Renewal reminders
  - Auto-record expenses on renewal

- **Reports & Analytics**
  - Weekly, monthly, yearly reports
  - Category breakdown charts
  - Spending trends analysis
  - Export to Excel and PDF (Pro)

- **Gamification**
  - Achievement badges system
  - Daily streak tracking
  - Milestone celebrations

- **Multi-Currency**
  - 5 currencies: TRY, USD, EUR, GBP, SAR
  - Real-time exchange rates from TCMB
  - Gold price tracking

- **Premium Features**
  - Unlimited AI chat
  - Unlimited savings goals
  - Full report access
  - Data export
  - Multi-currency support

- **Security**
  - App lock with PIN/biometric
  - Firebase Authentication
  - Encrypted data storage

- **Localization**
  - Full Turkish support
  - Full English support
  - ~1,750 translation keys

### Technical
- Flutter 3.x with Provider state management
- Firebase backend (Auth, Firestore, Storage, Functions)
- RevenueCat for subscriptions
- OpenAI GPT-4o and GPT-4o-mini integration
- Google Gemini for fact extraction

---

## Version History Summary

| Version | Date | Highlights |
|---------|------|------------|
| 1.0.3 | 2026-01-26 | AI language fix, documentation |
| 1.0.2 | 2026-01-25 | Google account linking, currency fixes |
| 1.0.1 | 2026-01-24 | Crashlytics, Analytics, Light mode |
| 1.0.0 | 2026-01-20 | Initial release |

---

## Upcoming

### v1.1.0 (Planned)
- Push notifications for budget alerts
- Android widget for quick expense add
- Receipt scanner (basic OCR)
- Improved onboarding experience

### v1.2.0 (Planned)
- Recurring expense templates
- Enhanced referral program
- Budget category alerts
- Export improvements
