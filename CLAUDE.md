# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Vantag** is a Turkish-language personal finance awareness app that helps users understand how much work time is required to afford purchases based on their income and work schedule. The app focuses on mindful spending by showing the "time cost" of purchases.

**Package:** `com.vantag.app`
**Version:** 1.0.0+1
**Slogan:** "Finansal Üstünlüğün"

## Common Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d windows
flutter run -d chrome
flutter run -d android

# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Build release
flutter build apk
flutter build windows
flutter build web
```

## Architecture

```
lib/
├── main.dart                    # App entry + SplashScreen (onboarding/profile check)
├── models/
│   ├── models.dart              # Barrel export
│   ├── user_profile.dart        # User profile (income, hours, work days)
│   ├── expense.dart             # Expense model with decision tracking
│   ├── expense_result.dart      # Expense calculation result
│   ├── subscription.dart        # Recurring subscription model
│   └── achievement.dart         # Achievement/badge model
├── services/
│   ├── services.dart            # Barrel export
│   ├── profile_service.dart     # Profile + onboarding persistence
│   ├── calculation_service.dart # Work days and expense calculations
│   ├── expense_history_service.dart # Expense CRUD with locking
│   ├── currency_service.dart    # TCMB + Truncgil API for rates
│   ├── streak_service.dart      # Daily entry streak tracking
│   ├── subscription_service.dart # Recurring subscriptions
│   ├── achievements_service.dart # Badge/achievement logic
│   ├── notification_service.dart # Local notifications (Windows support)
│   ├── insight_service.dart     # Category insights
│   ├── messages_service.dart    # Emotional feedback messages
│   ├── connectivity_service.dart # Network status
│   ├── receipt_scanner_service.dart # OCR placeholder
│   ├── category_learning_service.dart # Smart Match + user learning
│   ├── sub_category_service.dart # Sub-category suggestions
│   ├── tour_service.dart        # Discovery Tour management
│   ├── streak_manager.dart      # Streak tracking singleton
│   ├── vampire_detector_manager.dart # Vampire subscription detection
│   ├── sensory_feedback_service.dart # Haptic feedback
│   └── victory_manager.dart     # Victory celebration animations
├── screens/
│   ├── screens.dart             # Barrel export
│   ├── splash_screen.dart       # Animated V logo splash (NEW)
│   ├── onboarding_screen.dart   # 3-page intro (first launch only)
│   ├── user_profile_screen.dart # Profile create/edit
│   ├── main_screen.dart         # Bottom nav container
│   ├── expense_screen.dart      # Main expense entry + history
│   ├── report_screen.dart       # Monthly/category reports
│   ├── achievements_screen.dart # Badges and stats
│   ├── profile_screen.dart      # Profile view + settings
│   ├── currency_detail_screen.dart # Detailed exchange rates
│   ├── notification_settings_screen.dart # Notification prefs
│   ├── subscription_screen.dart # Subscription management (replaces vampire)
│   ├── income_wizard_screen.dart # Income setup wizard
│   └── habit_calculator_screen.dart # Viral habit cost calculator (NEW)
├── widgets/
│   ├── widgets.dart             # Barrel export
│   ├── collapsible_saved_header.dart # Animated header with savings
│   ├── saved_money_counter.dart # Savings display (deprecated)
│   ├── currency_rate_widget.dart # USD/EUR/Gold rate bar
│   ├── decision_buttons.dart    # Yes/Thinking/No buttons
│   ├── expense_history_card.dart # Expense list item
│   ├── streak_widget.dart       # Flame streak indicator
│   ├── subscription_sheet.dart  # Subscription management
│   ├── profile_photo_widget.dart # Profile photo picker
│   ├── labeled_text_field.dart  # Reusable text input
│   ├── labeled_dropdown.dart    # Dropdown with labels
│   ├── result_card.dart         # Expense result display
│   ├── premium_nav_bar.dart     # Floating nav bar + Showcase version
│   ├── financial_snapshot_card.dart # Income/spent/saved summary
│   ├── quick_add_sheet.dart     # Quick expense entry modal
│   ├── shadow_dashboard.dart    # Shadow savings panel (Quiet Luxury)
│   ├── freedom_trajectory.dart  # Freedom progress widget
│   ├── renewal_warning_banner.dart # Subscription renewal warnings
│   ├── decision_stress_timer.dart # Decision timer visualization
│   ├── share_card_widget.dart   # Instagram story share cards (NEW)
│   ├── share_edit_sheet.dart    # Share card editor (NEW)
│   ├── subscription_calendar_view.dart # Calendar grid with dots (NEW)
│   ├── subscription_list_view.dart # List view for subscriptions (NEW)
│   ├── add_subscription_sheet.dart # Add/edit subscription modal (NEW)
│   └── subscription_detail_sheet.dart # Subscription details (NEW)
├── data/
│   └── store_categories.dart    # 200+ store→category mappings
└── theme/
    ├── theme.dart               # Barrel export
    ├── app_theme.dart           # Colors and theme config
    ├── app_animations.dart      # Animation constants
    └── quiet_luxury.dart        # Quiet Luxury design system
```

## App Flow

```
SplashScreen (2.5s)
├── Onboarding not completed → OnboardingScreen (3 pages)
│   └── Complete → UserProfileScreen (create)
├── No profile → UserProfileScreen (create)
└── Profile exists → MainScreen

MainScreen (Bottom Navigation)
├── Tab 1: ExpenseScreen (Harcama)
│   ├── Collapsible header with saved money stats
│   ├── Currency rates bar (USD/EUR/Gold)
│   ├── Expense input with categories
│   ├── Decision buttons (Aldım/Düşünüyorum/Vazgeçtim)
│   └── Expense history list
├── Tab 2: ReportScreen (Rapor)
│   └── Monthly and category statistics
├── Tab 3: AchievementsScreen (Rozetler)
│   └── Earned badges and progress
└── Tab 4: ProfileScreen (Profil)
    ├── Profile photo and info
    ├── Notification settings
    └── Edit profile
```

## Key Features

### 1. Onboarding (New)
- 3-page intro shown on first launch
- Swipe navigation with page indicators
- Skip button and animated "Başla" button
- `onboarding_completed` flag in SharedPreferences

### 2. Expense Tracking
- Enter amount and select category
- See work hours/days required to afford it
- Make decision: Aldım (bought), Düşünüyorum (thinking), Vazgeçtim (passed)
- Simulations vs real entries (based on amount/time)
- **İptal button**: Returns to input screen keeping form data
- **Motivational SnackBar**: Shows "Para cebinde kaldı..." when user cancels

### 2.1 Smart Match Engine (New)
- Auto-detects category from store/product description
- 200+ built-in store→category mappings (Migros→Yiyecek, Netflix→Dijital, etc.)
- User preference learning via CategoryLearningService
- Visual feedback: green glow on auto-match
- Attention animation for unselected category

### 2.2 Time-Travel Input (New)
- Quick date selection chips: Dün, 2 Gün Önce, Calendar icon
- Default is today (no chip selected)
- Calendar picker for custom dates (up to 365 days back)
- Date comparison helper for year/month/day only

### 3. Collapsible Header (New)
- Animated header showing total savings
- Shrinks on scroll (80px → 40px icon, 32px → 20px font)
- Uses `FittedBox` for responsive sizing
- `SliverAppBar` with pinned behavior

### 4. Currency Rates
- TCMB API for USD/EUR rates
- Truncgil Finans API for gold prices (no API key needed)
- Daily cache for gold prices
- Fallback calculation if API fails
- Warning indicator when gold price is stale

### 5. Streak System
- Daily entry tracking with flame icon
- Streak count and best streak
- Weekly insights notification

### 6. Achievements
- Progress-based badges
- Categories: savings, streaks, categories, decisions

### 7. Subscriptions
- Track recurring expenses
- Calendar badge for upcoming renewals
- Auto-calculate monthly impact

### 8. Notifications
- Streak reminders
- Delayed awareness (after "bought" decision)
- Reinforcement (after "passed" decision)
- Weekly insights
- Windows platform support (WindowsInitializationSettings)

### 9. Discovery Tour (New)
- Guided tour for first-time users using showcaseview package
- 12 steps covering all main features:
  - Financial Snapshot Card
  - Currency Rates Widget
  - Streak Widget
  - Subscription Button
  - Time-Travel Date Chips
  - Amount Field
  - Description Field (Smart Match)
  - Category Field
  - Nav Bar: Reports, Achievements, Profile, Add Button
- Auto-starts on first launch
- Manual trigger from Profile → "Uygulama Turunu Tekrarla"
- SharedPreferences persistence (`has_seen_tour`, `tour_version`)

### 10. Vampire Detector (Vampir Dedektörü)
- Detects unused/underused subscriptions
- Three status levels: Active, Suspicious (30+ days), Ghost (60+ days)
- Access via Subscription Sheet → "🧛 Vampir Analizi" button
- Tab-based UI: All, Vampires, Ghosts
- Shows monthly cost and work time equivalent
- "Mark as used" action to reset status
- VampireDetectorManager singleton for stats

### 11. Quiet Luxury Design System
Premium banking-inspired design language (JPMorgan/Goldman Sachs style):

**Color Palette:**
- Background: Midnight Blue (#1A1A2E)
- Text Primary: Off-White (#F5F5F5)
- Text Secondary: Slate Grey (#4A4A5A)
- Positive: Subtle Green (0xB32ECC71 - 0.7 opacity)
- Negative: Subtle Red (0xB3E74C3C - 0.7 opacity)
- Warning: Subtle Amber (0xB3FF8C00 - 0.7 opacity)
- **Gold (#FFD700): ONLY for Victory, Achievement unlock, Streak milestones (5,10,30)**

**Typography:**
- Headings: w600, 20px
- Large Numbers: w300, letterSpacing 1.5 (displayLarge)
- Labels: w400, 12px, textTertiary

**Components:**
- GlassCard: BackdropFilter blur, subtle border, soft shadow
- AnimatedNumber: Fade transition on value change
- Pressable: Scale 0.98 on press
- SubtleDivider: Space instead of lines

**Animations:**
- Page transitions: 350ms easeInOutCubic
- Modals: 300ms easeOutCubic
- Number changes: 200ms

**Files Using Quiet Luxury:**
- `lib/theme/quiet_luxury.dart` - Design system constants
- `lib/widgets/shadow_dashboard.dart` - Savings panel
- `lib/widgets/freedom_trajectory.dart` - Progress widget
- `lib/screens/vampire_list_screen.dart` - Vampire detector
- `lib/widgets/subscription_sheet.dart` - Subscriptions modal

## Data Flow

1. **Profile**: `ProfileService` → SharedPreferences
2. **Expenses**: `ExpenseHistoryService` → SharedPreferences (with lock)
3. **Currency**: `CurrencyService` → TCMB XML + Truncgil JSON → cache
4. **Stats**: `DecisionStats.fromExpenses()` calculated in build()

## Technical Notes

- **State Management**: StatefulWidget with setState
- **Persistence**: SharedPreferences for all data
- **Theme**: Custom dark theme in `AppColors`
- **Language**: Full i18n support (TR/EN), system-aware
- **Barrel Exports**: Each folder has index file
- **API Endpoints**:
  - TCMB: `https://www.tcmb.gov.tr/kurlar/today.xml`
  - Truncgil: `https://finans.truncgil.com/v4/today.json`

---

## Localization Architecture (i18n)

### System Language Detection

The app automatically detects and uses the device's system language:

```dart
// In main.dart - MaterialApp configuration
MaterialApp(
  locale: locale,  // From LocaleProvider
  supportedLocales: AppLocalizations.supportedLocales,  // [en, tr]
  localizationsDelegates: AppLocalizations.localizationsDelegates,
);

// System language detection in LocaleProvider
final systemLocale = PlatformDispatcher.instance.locale;
final langCode = systemLocale.languageCode;  // 'en', 'tr', etc.
```

### File Structure

```
lib/l10n/
├── l10n.yaml           # Localization config
├── app_en.arb          # English translations (~470 keys)
├── app_tr.arb          # Turkish translations (~470 keys)
└── generated/          # Auto-generated (do not edit)
    └── app_localizations.dart
```

### ARB File Format

```json
// app_en.arb
{
  "@@locale": "en",
  "expenses": "Expenses",
  "streakDays": "{count} days",
  "@streakDays": {
    "placeholders": {
      "count": {"type": "int"}
    }
  }
}
```

### Usage Pattern

```dart
// Import
import 'package:vantag/l10n/app_localizations.dart';

// In build method
final l10n = AppLocalizations.of(context)!;

// Simple string
Text(l10n.expenses);  // "Expenses" or "Harcamalar"

// Parameterized string
Text(l10n.streakDays(5));  // "5 days" or "5 gün"

// Pluralized string (uses ICU format in ARB)
Text(l10n.itemCount(count));
```

### Regenerating Translations

After editing ARB files:

```bash
flutter gen-l10n
```

### Key Categories (~470 keys)

| Category | Count | Examples |
|----------|-------|----------|
| Navigation | 15 | homePage, analysis, badges, profile |
| Forms | 45 | amount, category, description, save |
| Expenses | 60 | bought, thinking, gaveUp, workDays |
| Subscriptions | 40 | subscription, renewalDay, autoRecord |
| Achievements | 25 | badge, streak, progress, unlocked |
| Reports | 30 | monthly, weekly, categoryBreakdown |
| Calendar | 20 | weekdayMon...weekdaySun, monthJan...monthDec |
| Share Cards | 15 | shareCardDays, shareCardDescription |
| Risk Levels | 10 | riskLevelNone...riskLevelExtreme |
| Misc | 200+ | Various UI strings |

---

## Laser Splash Screen Technical Details

### File: `lib/screens/laser_splash_screen.dart`

### Animation Timeline (4.5s total)

```
0.0s ──────────── Laser Drawing Start
│
│  PathMetrics.extractPath(0 → 1)
│  Neon tip sparkle follows path
│  4-layer blur glow effect
│
3.0s ──────────── Drawing Complete
│
│  Logo fade-in (800ms)
│  Opacity: 0 → 1
│
3.8s ──────────── Logo Visible
│
│  Text fade-in (600ms)
│  "VANTAG" + slogan
│
4.4s ──────────── Navigate
```

### SVG Path Processing

```dart
// Using path_drawing package
import 'package:path_drawing/path_drawing.dart';

// Parse SVG path data (from Adobe Illustrator export)
final path = parseSvgPathData(pathData);  // ~5120x5120 original

// Calculate bounds for scaling
final bounds = path.getBounds();
final scale = targetSize / max(bounds.width, bounds.height);

// Transform to screen coordinates
canvas.translate(centerX, centerY);
canvas.scale(scale);
canvas.translate(-bounds.center.dx, -bounds.center.dy);
```

### PathMetrics for Laser Animation

```dart
// Extract partial path for animation
final metrics = path.computeMetrics().first;
final totalLength = metrics.length;

// At animation progress 0.5 → draw first 50% of path
final extractedPath = metrics.extractPath(0, totalLength * progress);
```

### 4-Layer Neon Glow Effect

```dart
// Outer glow (widest, most transparent)
final outerPaint = Paint()
  ..color = laserColor.withOpacity(0.2)
  ..strokeWidth = 20
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15);

// Mid glow
final midPaint = Paint()
  ..color = laserColor.withOpacity(0.4)
  ..strokeWidth = 10
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

// Inner glow
final innerPaint = Paint()
  ..color = laserColor.withOpacity(0.7)
  ..strokeWidth = 4
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

// Core (solid line)
final corePaint = Paint()
  ..color = Colors.white
  ..strokeWidth = 2;
```

### Laser Tip Sparkle

```dart
// Get position at current progress
final tangent = metrics.getTangentForOffset(currentLength);
final tipPosition = tangent?.position ?? Offset.zero;

// Draw 4-directional rays
for (var i = 0; i < 4; i++) {
  final angle = (i * pi / 2) + rotation;
  final endPoint = Offset(
    tipPosition.dx + cos(angle) * rayLength,
    tipPosition.dy + sin(angle) * rayLength,
  );
  canvas.drawLine(tipPosition, endPoint, rayPaint);
}
```

### Color Scheme

```dart
const laserColor = Color(0xFF00FFFF);  // Cyan neon
const backgroundColor = AppGradients.background;  // Purple → Blue gradient
const textGradient = LinearGradient(
  colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],  // Purple → Teal
);
```

## Recent Changes (This Session)

### Session: Quiet Luxury Design System & Vampire Detector

1. **Quiet Luxury Design System Implementation**:
   - Created `lib/theme/quiet_luxury.dart` with design constants
   - Color palette: Midnight Blue, Slate Grey, Off-White, subtle opacity colors
   - Typography hierarchy: w600 headings, w300 large numbers with letterSpacing
   - Reusable widgets: GlassCard, AnimatedNumber, Pressable, SubtleDivider
   - **Critical Rule**: Gold (#FFD700) ONLY for Victory, Achievement, Streak milestones

2. **Vampire Detector (Vampir Dedektörü)**:
   - `VampireDetectorManager` singleton for tracking unused subscriptions
   - `VampireListScreen` with tab-based UI (All/Vampires/Ghosts)
   - `SubscriptionStatus` enum: active, suspicious, ghost
   - Access via Subscription Sheet → "🧛 Vampir Analizi" button
   - Shows work time equivalent and monthly cost

3. **Widget Updates with Quiet Luxury**:
   - `FreedomTrajectory`: Elegant progress bar, subtle colors, no gold except milestones
   - `ShadowDashboard`: Glassmorphism cards, AnimatedNumber for values
   - `VampireListScreen`: Removed gold from tabs/stats, gradient icon backgrounds
   - `SubscriptionSheet`: Subtle buttons, gradient card backgrounds, space instead of dividers

4. **Design Principles Applied**:
   - Glassmorphism: BackdropFilter blur(10,10) on all cards
   - Subtle borders: 0.5px width, 0.2 opacity colors
   - No dividers: Replaced with spacing (SizedBox)
   - Haptic feedback: lightImpact() on interactions
   - Press effect: scale 0.98 via Pressable widget

### Previous Session: Smart Match, Time-Travel & Discovery Tour

1. **Smart Match Engine**: Auto-category prediction from description
   - 200+ store→category mappings in `store_categories.dart`
   - CategoryLearningService for user preference learning
   - Visual feedback (green glow, attention animation)

2. **Form UX Improvements**:
   - Reordered fields: Amount → Description → Category
   - Category default changed to null (must select)
   - İptal button below decision buttons
   - Motivational SnackBar on cancel

3. **Time-Travel Input**: Past date selection
   - Quick chips: Dün, 2 Gün Önce, Calendar
   - Changed `_selectedMonth/Year` to single `DateTime _selectedDate`
   - Helper methods: `_isSameDay()`, `_selectedDateChip` getter

4. **Discovery Tour**: Guided first-time user experience
   - `showcaseview: ^3.0.0` package integration
   - TourService for state management
   - TourKeys for GlobalKey references
   - 12-step tour covering all main features
   - Profile settings button to restart tour

5. **Package Upgrades**:
   - `flutter_local_notifications: ^19.5.0`
   - Added `WindowsInitializationSettings` for Windows support
   - Removed deprecated `uiLocalNotificationDateInterpretation`

6. **Bug Fixes**:
   - Windows notification settings initialization error
   - const EdgeInsets.symmetric with runtime values

## Known Issues / TODO

- [ ] Lottie animations for onboarding (placeholder icons used)
- [ ] Receipt scanner OCR integration
- [ ] Web platform notification support
- [ ] Unit tests needed
- [ ] Store hazırlık (screenshots, açıklama, privacy policy)
- [x] ~~Smart Match category prediction~~ (Implemented)
- [x] ~~Time-Travel past date entry~~ (Implemented)
- [x] ~~Discovery Tour for new users~~ (Implemented)
- [x] ~~Vampire Detector for unused subscriptions~~ (Removed - simplified)
- [x] ~~Quiet Luxury Design System~~ (Implemented)
- [x] ~~Vantag rebranding~~ (Completed)
- [x] ~~Animated splash screen~~ (Completed)
- [x] ~~Subscription system redesign~~ (Completed)
- [x] ~~Habit Calculator viral feature~~ (Completed)
- [x] ~~Share cards system~~ (Completed)

---

## Son Güncelleme: 8 Ocak 2026

### Session: Vantag V1.0 Release Hazırlığı

#### Tamamlanan Özellikler:

1. **Marka Değişikliği: Gumtanım → Vantag**
   - Package: `com.vantag.app`
   - Android/iOS manifest ve config güncellemeleri
   - main.dart: VantagApp class
   - Slogan: "Finansal Üstünlüğün"

2. **Animated Splash Screen (V Logo)**
   - `lib/screens/splash_screen.dart` - VantagSplashScreen
   - 5 aşamalı animasyon (2.5 saniye):
     1. Yıldız hareketi (sol alt → sağ üst)
     2. V harfi sağ bacak çizimi
     3. V harfi sol bacak çizimi
     4. Glow pulse efekti
     5. Fade geçişi
   - Gradient: Mor (#6C63FF) → Turkuaz (#4ECDC4)
   - CustomPainter ile çizim

3. **Abonelik Sistemi Yeniden Tasarımı**
   - Vampir terminolojisi tamamen kaldırıldı
   - `subscription_screen.dart` - Ana ekran
   - `subscription_calendar_view.dart` - Takvim grid görünümü
   - `subscription_list_view.dart` - Liste görünümü
   - `add_subscription_sheet.dart` - Ekleme/düzenleme
   - `subscription_detail_sheet.dart` - Detay görünümü
   - Renk paleti sistemi (8 renk, round-robin)
   - Ay navigasyonu ile takvim görünümü

4. **Lucide Icons Entegrasyonu**
   - Tüm Material Icons → LucideIcons değiştirildi
   - `lucide_icons: ^0.275.0` paketi eklendi
   - piggyBank → shieldCheck değişikliği

5. **ÖP (Özgürlük Puanı) Sistemi Kaldırıldı**
   - Tüm ÖP referansları temizlendi
   - FreedomTrajectory widget'ı basitleştirildi

6. **Alışkanlık Hesaplayıcı (Viral Hook)**
   - `habit_calculator_screen.dart` - 3 adımlı wizard
   - Adım 1: Alışkanlık seçimi (kahve, sigara, vb.)
   - Adım 2: Miktar girişi
   - Adım 3: Sonuç kartı (yıllık maliyet, iş günü karşılığı)
   - Paylaşılabilir kart oluşturma

7. **Paylaşım Kartları Sistemi**
   - `share_card_widget.dart` - Instagram story formatı (1080x1920)
   - `share_edit_sheet.dart` - Düzenleme arayüzü
   - Gizlilik toggle'ları (tutar, kategori gizleme)
   - Screenshot + share_plus entegrasyonu

8. **Multi-Income Bug Fix**
   - FinanceProvider state yönetimi düzeltildi
   - Gelir kaynakları doğru hesaplanıyor

9. **Kod Temizliği**
   - Tüm debugPrint ifadeleri kaldırıldı
   - Unused imports temizlendi
   - flutter analyze hatasız geçiyor

10. **Onboarding Optimizasyonu**
    - const widget'lar kullanıldı
    - RepaintBoundary eklendi
    - SingleTickerProviderStateMixin

#### Teknik Detaylar:

| Özellik | Değer |
|---------|-------|
| Package | com.vantag.app |
| Version | 1.0.0+1 |
| Min SDK | 24 (Android 7.0) |
| Target SDK | 34 (Android 14) |
| Compile SDK | 36 |
| APK Boyutu | 84.3 MB |
| Architectures | arm64-v8a, armeabi-v7a, x86_64 |

#### Kullanılan Paketler:
- `lucide_icons: ^0.275.0` - İkon seti
- `share_plus: ^7.2.2` - Paylaşım
- `screenshot: ^2.5.0` - Ekran görüntüsü
- `path_provider: ^2.1.2` - Dosya yolu
- `confetti: ^0.7.0` - Kutlama animasyonları
- `showcaseview: ^3.0.0` - Discovery tour

#### Silinen/Yeniden Adlandırılan Dosyalar:
- ~~vampire_list_screen.dart~~ → subscription_screen.dart
- ~~vampire_detector_manager.dart~~ → subscription_manager.dart (simplified)

#### Bekleyen İşler:
- [ ] Store screenshots
- [ ] Privacy policy
- [ ] App store açıklaması
- [ ] Feature graphic

---

## Son Güncelleme: 9 Ocak 2026

### Session: Internationalization (i18n) & Premium Laser Splash

#### 1. Premium Laser Splash Screen

**Dosya:** `lib/screens/laser_splash_screen.dart`

**Teknik Detaylar:**
- `path_drawing: ^1.0.1` paketi ile SVG path parsing
- `parseSvgPathData()` fonksiyonu ile logo path verisi işleniyor
- `PathMetrics` ile 0-1 arası lazer çizim animasyonu
- `Curves.easeInOutQuart` ile akıcı animasyon eğrisi
- 3 saniye çizim süresi

**Animasyon Sahneleri:**
1. **Lazer Çizimi (3s):** SVG path verisi segment segment çiziliyor
2. **Neon Glow Efekti:** 4 katmanlı blur efekti (outer, mid, inner, core)
3. **Lazer Ucu Yıldızı:** Parlayan neon nokta + 4 yönlü ışın efekti
4. **Logo Fade-in (800ms):** `assets/icon/app_icon.png` görünür oluyor
5. **Text Fade-in (600ms):** "VANTAG" gradient text + slogan
6. **Navigasyon:** Toplam ~4-5 saniye sonra ana sayfaya yönlendirme

**Renkler:**
- Lazer: Cyan (#00FFFF)
- Arka Plan: Mevcut tema gradyanı (AppGradients.background)
- Text: Primary → Secondary gradient

**Path Verisi:**
- Orijinal koordinatlar: ~5120x5120
- `canvas.scale()` ve `canvas.translate()` ile ekrana sığdırma
- `path.getBounds()` ile otomatik merkez hesaplama

#### 2. Full Internationalization (i18n) Architecture

**Kurulum:**
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  path_drawing: ^1.0.1  # SVG path parsing
```

**Dosya Yapısı:**
```
lib/
├── l10n/
│   ├── app_en.arb          # English translations (~450 keys)
│   ├── app_tr.arb          # Turkish translations (~450 keys)
│   └── generated/          # Auto-generated l10n classes
├── providers/
│   └── locale_provider.dart # Language state management
```

**Özellikler:**
- Sistem dili otomatik algılama (`PlatformDispatcher.instance.locale`)
- SharedPreferences ile dil tercihi kaydetme
- `LocaleProvider` ile reaktif dil değişikliği
- TR ve EN tam destek (DE, AR gelecekte eklenebilir)

**Kullanım:**
```dart
// Import
import '../l10n/generated/app_localizations.dart';

// Widget içinde
final l10n = AppLocalizations.of(context)!;
Text(l10n.expenses);  // "Expenses" veya "Harcamalar"

// Parametreli string
Text(l10n.streakDays(count));  // "5 days" veya "5 gün"
```

**ARB Dosyası Yapısı:**
- 450+ çeviri key'i
- Parametreli stringler için placeholder desteği
- Ay isimleri, hafta günleri, kategori isimleri dahil

#### 3. Hardcoded String Audit

**Tarama Sonuçları:**

| Klasör | Dosya Sayısı | Hardcoded String |
|--------|--------------|------------------|
| lib/screens | 10 | ~160 string |
| lib/widgets | 14 | ~130 string |
| **Toplam** | **24** | **~290 string** |

**Lokalize Edilmiş Dosyalar:**
- [x] expense_screen.dart
- [x] report_screen.dart
- [x] user_profile_screen.dart
- [x] main_screen.dart

**Localization Complete:**
All widget files have been converted to use localized strings:
- [x] shadow_dashboard.dart
- [x] share_card_widget.dart
- [x] share_edit_sheet.dart
- [x] wealth_modal.dart
- [x] decision_stress_timer.dart
- [x] saved_money_counter.dart
- [x] premium_nav_bar.dart
- [x] subscription_calendar_view.dart
- [x] subscription_detail_sheet.dart
- [x] subscription_sheet.dart
- [x] renewal_warning_banner.dart
- [x] empty_state.dart
- [x] expense_form_content.dart

---

## 5K MRR Analysis Report

### Executive Summary

VANTAG, Türkiye pazarı için güçlü bir değer önerisi sunan kişisel finans farkındalık uygulaması. Premium lazer splash screen, quiet luxury tasarım dili ve zaman-maliyet hesaplama yaklaşımı ile rakiplerden ayrışıyor.

### Technical Debt Analysis

**Güçlü Yönler:**
- ✅ Clean architecture (screens/widgets/services/models ayrımı)
- ✅ SharedPreferences ile basit ve güvenilir persistence
- ✅ TCMB API entegrasyonu (kurlar)
- ✅ Firebase Auth + Firestore hazırlığı
- ✅ Responsive UI (farklı ekran boyutları)

**Zayıf Yönler (Technical Debt):**
- ⚠️ State management: StatefulWidget yerine Riverpod/BLoC önerilir
- ⚠️ Veritabanı: SharedPreferences 5000+ kullanıcıda yavaşlayabilir → SQLite/Hive
- ⚠️ Test coverage: Hiç unit/integration test yok
- ⚠️ Error handling: Global error boundary eksik
- ⚠️ Offline-first: Sınırlı offline destek

**5K Kullanıcı Scaling Önerileri:**
1. SQLite/Hive'a geçiş (veri katmanı)
2. Riverpod state management
3. Firebase Analytics entegrasyonu
4. Crashlytics error tracking
5. CI/CD pipeline (GitHub Actions)

### Premium Feel vs UX Analysis

**Premium Dokunuşlar:**
- ✨ Laser drawing splash screen (3s, path_drawing)
- ✨ Quiet Luxury design system (glassmorphism, subtle borders)
- ✨ Neon glow effects (cyan #00FFFF)
- ✨ Gradient text (mor → turkuaz)
- ✨ 4-layer blur effects on cards
- ✨ Haptic feedback on interactions

**UX Güçlü Yönleri:**
- Basit "zaman = para" konsepti
- 3 seçenekli karar mekanizması (Aldım/Düşünüyorum/Vazgeçtim)
- Smart Match ile otomatik kategori
- Streak sistemi (gamification)
- Viral Habit Calculator

**UX İyileştirme Alanları:**
- Onboarding biraz uzun (3 sayfa)
- İlk kullanımda gelir girişi zorunlu
- Grafikler basit kalıyor

### Market Fit Analysis

**Türkiye Pazarı (TR):**
- ✅ TL enflasyonu → "kaç saat çalışmalıyım" konsepti çok güçlü
- ✅ Genç nüfus (18-35) finansal farkındalık arıyor
- ✅ Rakipler: Moka (karmaşık), Param Nerede (eski)
- ✅ TCMB/altın entegrasyonu yerel değer

**Global Pazar (EN):**
- ⚠️ "Time = Money" konsepti evrensel ama rekabet yoğun
- ⚠️ Mint, YNAB, Copilot gibi devler var
- ✅ Diferansiyasyon: Mindful spending + Turkish niche

**Dil Stratejisi:**
- Phase 1: TR + EN (mevcut)
- Phase 2: DE (Almanya'daki Türkler)
- Phase 3: AR (Körfez ülkeleri)

### Monetization Strategy

**Freemium Model Önerisi:**

| Özellik | Free | Pro (₺49.99/ay) |
|---------|------|-----------------|
| Temel harcama takibi | ✅ | ✅ |
| Streak sistemi | ✅ | ✅ |
| Aylık raporlar | ✅ | ✅ |
| Sınırsız geçmiş | 30 gün | Sınırsız |
| Kategori insights | - | ✅ |
| Excel export | - | ✅ |
| Widget | - | ✅ |
| Ad-free | - | ✅ |

**5K MRR Senaryoları:**

| Model | Fiyat | Gerekli Kullanıcı |
|-------|-------|-------------------|
| Pro Monthly | ₺49.99 | ~100 |
| Pro Yearly | ₺399.99 | ~150 |
| Hybrid (60/40) | - | ~120 |

**Hedef:** 50K+ indirme, %2.5 conversion rate → ~125 Pro user → 5K MRR

### SWOT Analysis

**Strengths (Güçlü):**
- Unique value proposition ("zaman = para")
- Premium UI/UX (quiet luxury)
- Local API integrations (TCMB)
- Gamification (streaks, badges)
- Viral potential (habit calculator)

**Weaknesses (Zayıf):**
- No unit tests
- Limited offline support
- No cloud sync (kullanıcı verisi kaybı riski)
- SharedPreferences scalability
- Manual localization (tedious)

**Opportunities (Fırsat):**
- Turkish fintech boom
- Inflation awareness
- Gen-Z financial literacy trend
- Social sharing features
- B2B potential (şirket wellness)

**Threats (Tehdit):**
- Big players entering Turkish market
- Economic instability (subscription churn)
- App Store visibility competition
- Privacy regulations (KVKK)

### Action Items for 5K MRR

**Immediate (Week 1-2):**
1. ✅ Premium splash screen
2. ✅ Full TR/EN localization
3. [ ] App Store listing preparation
4. [ ] Privacy policy

**Short-term (Month 1):**
1. [ ] Pro subscription implementation
2. [ ] Firebase Analytics
3. [ ] Crashlytics
4. [ ] ASO optimization

**Medium-term (Month 2-3):**
1. [ ] Cloud sync (Firestore)
2. [ ] Widget support
3. [ ] German localization
4. [ ] Referral system

---

## Paket Versiyonları (Güncel)

```yaml
dependencies:
  flutter_localizations: sdk
  provider: ^6.1.2
  shared_preferences: ^2.2.2
  firebase_core: ^4.3.0
  firebase_auth: ^6.1.3
  cloud_firestore: ^6.1.1
  google_sign_in: 6.2.1
  fl_chart: ^1.1.1
  intl: ^0.20.2
  path_drawing: ^1.0.1
  lucide_icons: ^0.257.0
  phosphor_flutter: ^2.1.0
  confetti: ^0.7.0
  flutter_animate: ^4.5.0
  showcaseview: ^3.0.0
  share_plus: ^7.2.1
  screenshot: ^2.1.0
  video_player: ^2.8.2
  fvp: ^0.35.2  # Windows/Linux video support
```

---

## Son Güncelleme: 12 Ocak 2026

### Session: Video Splash Screen Fix

#### Problem
- `video_player` paketi Windows'ta asset videoları oynatamıyordu
- Flutter'ın resmi video_player eklentisi Windows/Linux için sınırlı destek sunuyor

#### Çözüm
1. **fvp paketi eklendi** (`pubspec.yaml`):
   ```yaml
   fvp: ^0.35.2
   ```

2. **fvp registration eklendi** (`main.dart`):
   ```dart
   import 'package:fvp/fvp.dart' as fvp;

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     fvp.registerWith();  // Windows/Linux video support
     // ...
   }
   ```

#### Test Sonuçları
- Windows: ✅ Video oynatma başarılı (8s, 24fps)
- Android: ✅ Video oynatma başarılı

#### Teknik Detaylar
- fvp paketi tüm platformları destekliyor (Windows, Linux, macOS, iOS, Android)
- video_player API'si ile uyumlu çalışıyor
- MDK (Multimedia Development Kit) tabanlı

#### Kaynaklar
- [fvp package](https://pub.dev/packages/fvp)
- [Flutter video_player Windows issue](https://github.com/flutter/flutter/issues/37673)

---