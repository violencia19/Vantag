# Vantag - Finansal Ustunlugun

Personal finance awareness app that helps users understand how much work time is required to afford purchases based on their income and work schedule.

## Features

### Core Features
- **Expense Tracking** - Log expenses with categories and decision tracking (bought/thinking/skipped)
- **Work Time Calculator** - Shows how many hours you need to work to afford a purchase
- **Pursuits** - Set and track savings goals with visual progress
- **Subscriptions** - Manage recurring subscriptions with renewal reminders
- **Reports** - Monthly and category-based spending analytics

### Premium Features
- **AI Financial Assistant** - GPT-4 powered chat for financial insights
- **Voice Input** - Add expenses using speech-to-text
- **Multi-Currency** - Support for TRY, USD, EUR, GBP, SAR with live rates
- **Statement Import** - Import bank statements (PDF/CSV)
- **Unlimited Pursuits** - Create unlimited savings goals
- **Data Export** - Export to Excel/PDF

### Technical Features
- **Home Screen Widget** - Quick expense entry from home screen (Android/iOS)
- **Deep Links** - Navigate directly to expense/pursuit screens
- **Biometric Lock** - Secure app with fingerprint/face ID
- **Offline Support** - Full functionality without internet
- **Force Update** - Firebase Remote Config for version management
- **A/B Testing** - Built-in experiment infrastructure
- **Crashlytics** - Firebase crash reporting

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x / Dart 3.x |
| State Management | Provider |
| Backend | Firebase (Auth, Firestore, Crashlytics, Analytics, Remote Config) |
| AI | OpenAI GPT-4, Google Gemini |
| Payments | RevenueCat |
| Localization | Flutter Intl (TR/EN) |

## Getting Started

### Prerequisites
- Flutter SDK 3.10.4+
- Dart SDK 3.x
- Android Studio / VS Code
- Firebase project configured

### Installation

1. Clone the repository
```bash
git clone https://github.com/your-org/vantag.git
cd vantag
```

2. Install dependencies
```bash
flutter pub get
```

3. Set up environment variables
```bash
cp .env.example .env
# Edit .env and add your API keys
```

4. Run the app
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
├── services/              # Business logic & API clients
├── providers/             # State management
├── screens/               # UI screens
├── widgets/               # Reusable widgets
├── theme/                 # Design system
├── l10n/                  # Localization files
└── data/                  # Static data (categories, etc.)
```

## Testing

```bash
# Unit & Widget tests
flutter test

# Integration tests with screenshots
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## API Documentation

See [docs/API.md](docs/API.md) for API documentation.

## License

This project is proprietary software. All rights reserved.

## Links

- [App Store](https://apps.apple.com/app/id6740157696)
- [Play Store](https://play.google.com/store/apps/details?id=com.vantag.app)
