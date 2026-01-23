# VANTAG FILE INVENTORY - MEGA PHASE 1
*Ultra Derin Mimari Analiz - Ocak 2026*

## Toplam Dosya Sayısı: ~168 .dart dosyası

---

## HARDCODED TURKISH STRINGS - CRITICAL FINDINGS

### CATEGORY: SERVICES (100% Turkish - En Kritik)

| Dosya | Satır | Sorun | Önem |
|-------|-------|-------|------|
| `insight_service.dart` | 10-58 | TÜM insights %100 Türkçe | P0 |
| `messages_service.dart` | 25-105 | 64 mesaj %100 Türkçe | P0 |
| `achievements_service.dart` | 18-563 | 57 achievement %100 Türkçe | P0 |
| `tour_service.dart` | 79-138 | 12 tour step %100 Türkçe | P0 |
| `notification_service.dart` | 29-486 | 50+ notification %100 Türkçe | P0 |
| `export_service.dart` | 91-658 | Sheet names, formats Türkçe | P1 |
| `thinking_items_service.dart` | 89-177 | Time formatting Türkçe | P1 |
| `voice_parser_service.dart` | 14-295 | Keywords, prompts Türkçe | P1 |
| `deep_link_service.dart` | 284-362 | UI strings Türkçe | P1 |
| `ai_service.dart` | 45-274 | System prompts Türkçe | P1 |

### CATEGORY: MODELS (Turkish Category Names)

| Dosya | Satır | Sorun | Önem |
|-------|-------|-------|------|
| `expense.dart` | 11-72 | Enum labels Türkçe | P0 |
| `expense.dart` | 77-117 | CategoryThresholds Turkish keys | P0 |
| `expense.dart` | 410-474 | ExpenseCategory.all Turkish | P0 |
| `income_source.dart` | 13-71 | IncomeCategory labels Türkçe | P1 |
| `income_source.dart` | 121 | 'Ana Maaş' hardcoded | P1 |
| `achievement.dart` | 10-107 | Tier/Category/Difficulty labels | P1 |
| `savings_pool.dart` | 131-221 | BudgetShiftSource Turkish | P1 |

### CATEGORY: UTILS (Hardcoded Formatting)

| Dosya | Satır | Sorun | Önem |
|-------|-------|-------|------|
| `currency_utils.dart` | 414-445 | 'Saat', 'Gün', 'Yıl' hardcoded | P1 |
| `habit_calculator.dart` | 59-131 | Category names, frequencies | P1 |
| `currency_helper.dart` | 4-8 | Currency names Türkçe | P2 |

### CATEGORY: WIDGETS (UI Strings)

| Dosya | Satır | Sorun | Önem |
|-------|-------|-------|------|
| `savings_pool_card.dart` | 304 | 'Borç' hardcoded | P2 |
| `create_pursuit_sheet.dart` | 117-437 | Multiple Turkish strings | P1 |
| `add_savings_sheet.dart` | 379 | 'Hata: $e' hardcoded | P2 |

### CATEGORY: SCREENS

| Dosya | Satır | Sorun | Önem |
|-------|-------|-------|------|
| `achievements_screen.dart` | 381-570 | 'Rozetler', 'Gün Seri', Level titles | P1 |
| `settings_screen.dart` | 401-465 | 'Türkçe', 'English' | P2 |
| `habit_calculator_screen.dart` | 1110-1117 | '₺' hardcoded symbol | P1 |

### CATEGORY: PROVIDERS

| Dosya | Satır | Sorun | Önem |
|-------|-------|-------|------|
| `finance_provider.dart` | 105, 373 | 'Abonelik', test categories | P2 |
| `locale_provider.dart` | 51-60 | Language names hardcoded | P2 |
| `theme_provider.dart` | 82-91 | Theme mode names | P2 |

---

## HARDCODED COLORS - FINDINGS

### Dosyalar Theme-Aware Extension Kullanmıyor

| Dosya | Sorun |
|-------|-------|
| Birçok widget | `AppColors.xxx` direkt kullanım (light mode'da çalışmıyor) |
| **Çözüm mevcut:** | `context.appColors.xxx` extension kullanılmalı |

---

## DOSYA YAPISI ÖZET

### lib/services/ (30 dosya)
- `services.dart` - Barrel export
- `auth_service.dart` - Firebase Auth ✓
- `ai_service.dart` - GPT API (hardcoded prompts) ⚠️
- `ai_memory_service.dart` - Hive storage ✓
- `purchase_service.dart` - RevenueCat ✓
- `profile_service.dart` - SharedPreferences ✓
- `expense_history_service.dart` - Firestore + Local ✓
- `savings_pool_service.dart` - Hybrid storage ✓
- `insight_service.dart` - %100 HARDCODED ⛔
- `messages_service.dart` - %100 HARDCODED ⛔
- `achievements_service.dart` - %100 HARDCODED ⛔
- `tour_service.dart` - %100 HARDCODED ⛔
- `notification_service.dart` - %100 HARDCODED ⛔
- `export_service.dart` - Excel export (TR) ⚠️
- `thinking_items_service.dart` - Timer formatting ⚠️
- `voice_parser_service.dart` - Voice parsing ⚠️
- `deep_link_service.dart` - Deep links ⚠️
- ... (diğerleri temiz)

### lib/models/ (13 dosya)
- `models.dart` - Barrel export ✓
- `expense.dart` - CRITICAL hardcoded ⛔
- `user_profile.dart` - CLEAN ✓
- `income_source.dart` - hardcoded labels ⚠️
- `subscription.dart` - CLEAN ✓
- `pursuit.dart` - Has TR/EN labels ✓
- `achievement.dart` - hardcoded labels ⚠️
- `savings_pool.dart` - Has TR/EN labels ✓
- ... (diğerleri temiz)

### lib/providers/ (8 dosya)
- `providers.dart` - Barrel export ✓
- `finance_provider.dart` - Minor issues ⚠️
- `pro_provider.dart` - CLEAN ✓
- `currency_provider.dart` - CLEAN ✓
- `locale_provider.dart` - Minor hardcoded ⚠️
- `pursuit_provider.dart` - CLEAN ✓
- `savings_pool_provider.dart` - CLEAN ✓
- `theme_provider.dart` - Minor hardcoded ⚠️

### lib/screens/ (27 dosya)
- `screens.dart` - Barrel export ✓
- Çoğu ekran l10n kullanıyor ✓
- `achievements_screen.dart` - hardcoded level titles ⚠️
- `habit_calculator_screen.dart` - hardcoded currency ⚠️
- `settings_screen.dart` - minor hardcoded ⚠️

### lib/widgets/ (55+ dosya)
- Çoğu widget l10n kullanıyor ✓
- `savings_pool_card.dart` - minor ⚠️
- `create_pursuit_sheet.dart` - multiple issues ⚠️
- `add_savings_sheet.dart` - error string ⚠️

### lib/theme/ (5 dosya)
- `app_theme.dart` - Light/Dark theme tanımlı ✓
- `app_gradients.dart` - Gradient tanımları ✓
- `quiet_luxury.dart` - Premium design ✓
- `AppColorsExtension` - Theme-aware colors ✓

### lib/utils/ (10+ dosya)
- `currency_utils.dart` - Time formatting issues ⚠️
- `habit_calculator.dart` - Category/frequency ⚠️
- `category_utils.dart` - Uses l10n ✓
- `achievement_utils.dart` - Uses l10n ✓

### lib/l10n/ (2 dosya)
- `app_tr.arb` - ~530 keys ✓
- `app_en.arb` - ~530 keys ✓

### lib/core/ (5 dosya)
- `premium_effects.dart` - Animation widgets ✓
- Glass card, glow effects ✓

---

## BAĞIMLILIK ANALİZİ

### Firebase Dependencies
- `firebase_core: ^4.3.0`
- `firebase_auth: ^6.1.3`
- `cloud_firestore: ^6.1.1`
- `firebase_crashlytics: ^5.0.6`
- `firebase_analytics: ^12.0.0`

### Third Party
- `provider: ^6.1.2` - State management
- `purchases_flutter: ^8.1.0` - RevenueCat
- `google_sign_in: 6.2.1` - Google auth
- `http: ^1.2.0` - API calls
- `crypto: ^3.0.3` - SHA256 for referral
- `shared_preferences: ^2.2.2` - Local storage
- `hive_flutter: ^1.1.0` - AI memory

---

## SONUÇ: LOCALIZATION TECHNICAL DEBT

### P0 (Critical - %100 Hardcoded Türkçe)
1. `insight_service.dart` - 50+ insight mesajı
2. `messages_service.dart` - 64 motivasyon mesajı
3. `achievements_service.dart` - 57 achievement
4. `tour_service.dart` - 12 tour step
5. `notification_service.dart` - 50+ notification
6. `expense.dart` - Category system core

### P1 (High - Hardcoded Strings)
7. `export_service.dart` - Excel sheet names
8. `voice_parser_service.dart` - Voice commands
9. `deep_link_service.dart` - UI strings
10. `ai_service.dart` - System prompts
11. `income_source.dart` - Category labels
12. `achievement.dart` - Tier labels
13. `achievements_screen.dart` - Level system
14. `create_pursuit_sheet.dart` - Form labels

### P2 (Medium - Minor Issues)
15. `currency_utils.dart` - Time units
16. `habit_calculator.dart` - Frequencies
17. `settings_screen.dart` - Language names
18. `finance_provider.dart` - Test data

---

## TAHMİNİ İŞ YÜKÜ

| Öncelik | Dosya Sayısı | Tahmini Key Sayısı |
|---------|--------------|-------------------|
| P0 | 6 dosya | ~300 yeni l10n key |
| P1 | 8 dosya | ~150 yeni l10n key |
| P2 | 5 dosya | ~30 yeni l10n key |
| **TOPLAM** | **19 dosya** | **~480 yeni key** |

---

*Son güncelleme: Ocak 2026 - MEGA PHASE 1 Tamamlandı*
