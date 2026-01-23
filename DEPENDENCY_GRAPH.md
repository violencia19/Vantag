# VANTAG DEPENDENCY GRAPH - MEGA PHASE 2
*Ultra Derin Mimari Analiz - Ocak 2026*

---

## IMPORT HIERARCHY

```
main.dart
├── screens/screens.dart
├── theme/theme.dart
├── providers/providers.dart
├── services/auth_service.dart
├── services/expense_history_service.dart
├── services/ai_service.dart
├── services/referral_service.dart
├── services/deep_link_service.dart
├── services/siri_service.dart
├── services/budget_service.dart
├── services/purchase_service.dart
├── services/haptic_service.dart
└── l10n/app_localizations.dart
```

---

## BARREL EXPORTS

### services/services.dart (58 export)
```dart
export 'auth_service.dart';
export 'budget_service.dart';
export 'calculation_service.dart';
export 'profile_service.dart';
export 'expense_history_service.dart';
export 'insight_service.dart';
export 'receipt_scanner_service.dart';
export 'currency_service.dart';
export 'connectivity_service.dart';
export 'offline_queue_service.dart';
export 'streak_service.dart';
export 'messages_service.dart';
export 'notification_service.dart';
export 'push_notification_service.dart';
export 'widget_service.dart';
export 'watch_service.dart';
export 'achievements_service.dart';
export 'subscription_service.dart';
export 'sub_category_service.dart';
export 'category_learning_service.dart';
export 'tour_service.dart';
export 'thinking_items_service.dart';
export 'sensory_feedback_service.dart';
export 'haptic_service.dart';
export 'accessibility_service.dart';
export 'performance_service.dart';
export 'sound_service.dart';
export 'victory_manager.dart';
export 'streak_manager.dart';
export 'subscription_manager.dart';
export 'share_service.dart';
export 'ai_service.dart';
export 'ai_memory_service.dart';
export 'export_service.dart';
export 'merchant_learning_service.dart';
export 'import_service.dart';
export 'voice_parser_service.dart';
export 'deep_link_service.dart';
export 'siri_service.dart';
export 'pursuit_service.dart';
export 'savings_pool_service.dart';
export 'analytics_service.dart';
export 'exchange_rate_service.dart';
export 'app_clip_service.dart';
export 'referral_service.dart';
```

### providers/providers.dart (8 export)
```dart
export 'finance_provider.dart';
export 'pro_provider.dart';
export 'currency_provider.dart';
export 'locale_provider.dart';
export 'pursuit_provider.dart';
export 'savings_pool_provider.dart';
export 'theme_provider.dart';
```

### models/models.dart (13 export)
```dart
export 'user_profile.dart';
export 'expense.dart';
export 'expense_result.dart';
export 'subscription.dart';
export 'achievement.dart';
export 'currency.dart';
export 'pursuit.dart';
export 'pursuit_transaction.dart';
export 'budget.dart';
export 'income_source.dart';
export 'savings_pool.dart';
export 'enums.dart';
```

### screens/screens.dart (27 export)
```dart
export 'user_profile_screen.dart';
export 'expense_screen.dart';
export 'main_screen.dart';
export 'report_screen.dart';
export 'achievements_screen.dart';
export 'settings_screen.dart';
export 'profile_modal.dart';
export 'currency_detail_screen.dart';
export 'notification_settings_screen.dart';
export 'onboarding_screen.dart';
export 'income_wizard_screen.dart';
export 'splash_screen.dart';
export 'laser_splash_screen.dart';
export 'subscription_screen.dart';
export 'habit_calculator_screen.dart';
export 'voice_input_screen.dart';
export 'assistant_setup_screen.dart';
export 'paywall_screen.dart';
export 'credit_purchase_screen.dart';
export 'pursuit_list_screen.dart';
export 'onboarding_try_screen.dart';
```

### theme/theme.dart (4 export)
```dart
export 'app_theme.dart';
export 'app_animations.dart';
export 'app_gradients.dart';
export 'quiet_luxury.dart';
```

---

## DEPENDENCY FLOW

```
                    ┌─────────────────────┐
                    │     main.dart       │
                    └──────────┬──────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Providers     │  │    Services     │  │    Screens      │
│  (8 files)      │  │  (58 files)     │  │  (27 files)     │
└────────┬────────┘  └────────┬────────┘  └────────┬────────┘
         │                    │                    │
         └────────────────────┴────────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │      Models         │
                    │    (13 files)       │
                    └─────────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │       Theme         │
                    │     (4 files)       │
                    └─────────────────────┘
```

---

## ORPHAN FILES CHECK

### Potansiyel Kullanılmayan Dosyalar

| Dosya | Durum | Not |
|-------|-------|-----|
| `laser_splash_screen.dart` | ⚠️ Muhtemel orphan | splash_screen.dart kullanılıyor |
| `receipt_scanner_service.dart` | ⚠️ Muhtemel orphan | MLKit entegrasyonu eksik |
| `sound_service.dart` | ⚠️ Muhtemel orphan | Ses dosyaları yok |
| `watch_service.dart` | ⚠️ Muhtemel orphan | Apple Watch native gerekli |
| `widget_service.dart` | ⚠️ Muhtemel orphan | iOS widget gerekli |
| `app_clip_service.dart` | ⚠️ Muhtemel orphan | iOS App Clip gerekli |

### Kontrol Edilmesi Gereken
```bash
# Bu dosyaların import edilip edilmediğini kontrol et
grep -r "laser_splash_screen" lib/
grep -r "receipt_scanner_service" lib/
grep -r "SoundService" lib/
grep -r "WatchService" lib/
grep -r "WidgetService" lib/
grep -r "AppClipService" lib/
```

---

## CIRCULAR DEPENDENCY CHECK

### Potansiyel Döngüsel Bağımlılıklar

1. **finance_provider.dart ↔ expense_history_service.dart**
   - Provider service'i kullanıyor
   - Service bazen provider'a referans veriyor
   - **Risk:** Initialization order hatası

2. **savings_pool_provider.dart ↔ savings_pool_service.dart**
   - Benzer yapı
   - Stream subscription ile çözülmüş ✓

3. **pro_provider.dart ↔ purchase_service.dart**
   - Provider service'i sarmalıyor
   - Service stream yayınlıyor
   - **Çözüm:** Service singleton, provider listener

---

## EXTERNAL DEPENDENCIES

### Firebase
```
firebase_core ─────► Firebase.initializeApp()
firebase_auth ─────► AuthService, ProProvider
cloud_firestore ───► 8 service dosyası
firebase_crashlytics ► main.dart, runZonedGuarded
firebase_analytics ─► AnalyticsService
```

### RevenueCat
```
purchases_flutter ──► PurchaseService ──► ProProvider
```

### Google Sign-In
```
google_sign_in ────► AuthService (linkWithGoogle)
```

### Local Storage
```
shared_preferences ─► ProfileService, LocaleProvider, ThemeProvider
hive_flutter ──────► AIMemoryService (chat history)
```

---

## SERVICE DEPENDENCY MAP

```
AuthService
├── firebase_auth
├── google_sign_in
└── cloud_firestore

PurchaseService
├── purchases_flutter
└── ProProvider (listener)

ExpenseHistoryService
├── shared_preferences
├── cloud_firestore
└── FinanceProvider (injected)

SavingsPoolService
├── shared_preferences
├── cloud_firestore
└── BudgetShiftSource (enum)

ExchangeRateService
├── http
├── shared_preferences (cache)
└── xml (TCMB parsing)

AIService
├── http (OpenAI API)
├── flutter_dotenv (.env)
└── AIMemoryService (history)

ReferralService
├── http (ipify.org)
├── crypto (SHA256)
├── cloud_firestore
└── firebase_auth

NotificationService
├── flutter_local_notifications
├── timezone
└── shared_preferences
```

---

## PROVIDER DEPENDENCY CHAIN

```
main.dart initialization order:
1. LocaleProvider.initialize()
2. CurrencyProvider.loadCurrency()
3. Firebase.initializeApp()
4. AuthService.signInAnonymously()
5. ExpenseHistoryService.syncFromFirestore()
6. ProProvider.initialize()
7. SavingsPoolProvider.initialize()
8. ThemeProvider.initialize()

MultiProvider order:
1. FinanceProvider (independent)
2. BudgetService (depends on FinanceProvider)
3. LocaleProvider.value
4. CurrencyProvider.value
5. ProProvider.value
6. SavingsPoolProvider.value
7. ThemeProvider.value
8. PursuitProvider (independent)
```

---

## RECOMMENDATIONS

### 1. Barrel Export Cleanup
- `services.dart` 58 export fazla büyük
- Alt kategorilere bölünebilir:
  - `services/core_services.dart`
  - `services/ai_services.dart`
  - `services/feature_services.dart`

### 2. Orphan File Removal
- Kullanılmayan dosyaları kaldır veya TODO ile işaretle
- `laser_splash_screen.dart` özellikle kontrol edilmeli

### 3. Dependency Injection
- Service locator pattern (get_it) düşünülebilir
- Şu an singleton pattern kullanılıyor (kabul edilebilir)

### 4. Import Optimization
- Bazı dosyalar barrel export yerine direkt import kullanıyor
- Tutarlılık sağlanmalı

---

*Son güncelleme: Ocak 2026 - MEGA PHASE 2 Tamamlandı*
