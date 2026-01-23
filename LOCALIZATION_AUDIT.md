# VANTAG LOCALIZATION AUDIT - MEGA PHASE 4
*Ultra Derin Mimari Analiz - Ocak 2026*

---

## MEVCUT DURUM

### ARB Dosyaları
- `lib/l10n/app_tr.arb` - ~530 key (Türkçe)
- `lib/l10n/app_en.arb` - ~530 key (English)

### Kullanım
```dart
import 'package:vantag/l10n/app_localizations.dart';
final l10n = AppLocalizations.of(context);
Text(l10n.expenses);  // "Harcamalar" veya "Expenses"
```

---

## %100 HARDCODED TÜRKÇE - CRITICAL

### 1. insight_service.dart (50+ mesaj)

**Dosya:** `lib/services/insight_service.dart`
**Satırlar:** 10-58

```dart
// TAMAMEN HARDCODED
static const _shortDurationInsights = [
  'Bu harcama hayatından $minutes dakika aldı.',
  'Sadece $minutes dakikalık bir iş. Değdi mi?',
  '$minutes dakika... Kahve molası kadar.',
  // ... 10+ more
];

static const _mediumDurationInsights = [
  'Bu harcama hayatından ${hours.toStringAsFixed(1)} saat aldı.',
  '${hours.toStringAsFixed(1)} saat çalışma = bu alışveriş.',
  // ... 10+ more
];

static const _longDurationInsights = [
  'Bu harcama için neredeyse bir gün çalıştın.',
  '$days iş günü! Büyük bir karar.',
  // ... 10+ more
];
```

**GEREKLİ KEY'LER:** ~50 yeni l10n key

---

### 2. messages_service.dart (64 mesaj)

**Dosya:** `lib/services/messages_service.dart`
**Satırlar:** 25-105

```dart
// TAMAMEN HARDCODED
static const _shortDurationMessages = [
  'Hızlı karar! Bazen en iyi kararlar anlıktır.',
  'Bu küçük bir harcama ama her şey küçük adımlarla başlar.',
  // ... 12 messages
];

static const _yesMessages = [
  'Bazen harcamak gerekir. Önemli olan bilinçli olmak.',
  'Bu sefer evet dedin, umarım değerlidir.',
  // ... 10 messages
];

static const _noMessages = [
  'Harika bir karar! Tasarruf hesabına bir şeyler eklendi.',
  'İrade gücünü gösterdin. Aferin!',
  // ... 10 messages
];

static const _thinkingMessages = [
  'Düşünmek akıllıca. Acele etme.',
  'Bir gece üstüne yat, sabah tekrar düşün.',
  // ... 10 messages
];

// + simulation messages, weekly insights...
```

**GEREKLİ KEY'LER:** ~64 yeni l10n key

---

### 3. achievements_service.dart (57 achievement)

**Dosya:** `lib/services/achievements_service.dart`
**Satırlar:** 18-563

```dart
// TAMAMEN HARDCODED
Achievement(
  id: 'streak_3',
  title: 'Başlangıç',
  description: '3 günlük seri',
  tier: AchievementTier.bronze,
  // ...
),
Achievement(
  id: 'streak_7',
  title: 'Devam Ediyorum',
  description: '7 günlük seri',
  // ...
),
Achievement(
  id: 'streak_30',
  title: 'Ay Ustası',
  description: '30 günlük seri',
  // ...
),
// ... 54 more achievements
```

**GEREKLİ KEY'LER:** ~114 yeni l10n key (title + description)

---

### 4. tour_service.dart (12 step)

**Dosya:** `lib/services/tour_service.dart`
**Satırlar:** 79-138

```dart
// TAMAMEN HARDCODED
TourStep(
  key: TourKeys.amountField,
  title: 'Tutar Girişi',
  description: 'Harcama tutarını buraya gir. Hesap makinesi kullanarak kolayca hesapla.',
),
TourStep(
  key: TourKeys.descriptionField,
  title: 'Açıklama',
  description: 'Ne için harcadığını yaz. "Kahve", "Market" gibi...',
),
// ... 10 more steps
```

**GEREKLİ KEY'LER:** ~24 yeni l10n key

---

### 5. notification_service.dart (50+ mesaj)

**Dosya:** `lib/services/notification_service.dart`
**Satırlar:** 29-486

```dart
// TAMAMEN HARDCODED
static const _delayedAwarenessMessages = [
  'Hey! Daha demin bir şey almayı düşünüyordun. Hâlâ istiyor musun?',
  'O ürün aklında mı hâlâ? Bir daha düşün...',
  // ... 12 messages
];

static const _reinforceDecisionMessages = [
  'Tebrikler! Bugün {amount} tasarruf ettin. Devam et!',
  'Bu hafta {count} kez hayır dedin. Harikasın!',
  // ... 13 messages
];

static const _streakReminderMessages = [
  'Serini kaybetme! Bugün henüz kayıt yapmadın.',
  '{streak} günlük serin tehlikede. Hemen bir kayıt yap!',
  // ... 12 messages
];

// + subscription reminders, weekly insights...
```

**GEREKLİ KEY'LER:** ~50 yeni l10n key

---

### 6. expense.dart - Category System

**Dosya:** `lib/models/expense.dart`
**Satırlar:** 11-474

```dart
// ENUM LABELS HARDCODED
enum ExpenseDecision {
  yes('Aldım'),
  thinking('Düşünüyorum'),
  no('Vazgeçtim');
}

enum RecordType {
  real('Gerçek'),
  simulation('Simülasyon');
}

enum ExpenseType {
  oneTime('Tek Seferlik'),
  recurring('Tekrarlayan'),
  installment('Taksitli');
}

enum ExpenseStatus {
  active('Aktif'),
  pending('Karar Aşamasında'),
  declined('İrade Zaferi');
}

// CATEGORY NAMES HARDCODED
static const List<String> all = [
  'Yiyecek', 'Ulaşım', 'Eğlence', 'Alışveriş',
  'Faturalar', 'Sağlık', 'Eğitim', 'Seyahat',
  'Abonelik', 'Diğer',
];
```

**GEREKLİ KEY'LER:** ~30 yeni l10n key

**NOT:** `ExpenseCategory.getLocalizedName()` zaten l10n kullanıyor (lines 478-502) ama diğer yerler kullanmıyor!

---

## P1 HARDCODED - HIGH PRIORITY

### 7. export_service.dart

**Satırlar:** 91-658
```dart
'Vantag Finansal Rapor'  // Line 91
'Özet'                   // Line 104
'Harcamalar'             // Line 165
'Kategoriler'            // Line 272
'Aylık Trendler'         // Line 364
'Abonelikler'            // Line 467
'h/ay'                   // Line 533
'Başarılar'              // Line 553
'₺'                      // Line 658
```

**GEREKLİ KEY'LER:** ~15 yeni l10n key

---

### 8. voice_parser_service.dart

**Satırlar:** 14-295
```dart
// CATEGORY KEYWORDS TURKISH
static const _categoryKeywords = {
  'food': ['yemek', 'kahve', 'market', 'restoran', ...],
  'transport': ['uber', 'taksi', 'benzin', 'otopark', ...],
  // ...
};

// GPT PROMPT TURKISH
static const _gptPrompt = '''
Kullanıcının söylediği harcamayı analiz et.
Kategori: Yiyecek, Ulaşım, Eğlence, Alışveriş...
''';
```

**GEREKLİ KEY'LER:** ~20 yeni l10n key + locale-aware keyword mapping

---

### 9. deep_link_service.dart

**Satırlar:** 284-362
```dart
'${expense.amount.toStringAsFixed(0)}₺ $displayText eklendi'  // 284
'Geri Al'                                                       // 295
'Harcamayı Onayla'                                             // 315
'Tutar'                                                         // 332
'Açıklama'                                                      // 337
'İptal'                                                         // 344
'Ekle'                                                          // 362
```

**GEREKLİ KEY'LER:** ~10 yeni l10n key

---

### 10. ai_service.dart - System Prompts

**Satırlar:** 45-274
```dart
static const _systemPromptPremium = '''
Sen Vantag'ın finansal asistanısın. Premium kullanıcıya yardım ediyorsun.
Kullanıcının finansal verilerini analiz et ve kişiselleştirilmiş öneriler sun.
- Harcama alışkanlıklarını değerlendir
- Tasarruf fırsatlarını belirle
- Hedeflere ulaşmak için stratejiler öner
''';

static const _systemPromptFree = '''
Sen Vantag'ın finansal asistanısın. Ücretsiz kullanıcıya kısa yanıtlar ver.
- 2-3 cümle ile yanıt ver
- Genel önerilerde bulun
- Detaylı analiz için Premium öner
''';
```

**GEREKLİ KEY'LER:** ~5 yeni l10n key (veya locale-aware prompt selection)

---

### 11. income_source.dart

**Satırlar:** 13-121
```dart
enum IncomeCategory {
  salary('Maaş', 'Ana gelir kaynağınız'),
  freelance('Freelance', 'Serbest çalışma gelirleri'),
  rental('Kira Geliri', 'Gayrimenkul kira gelirleri'),
  passive('Pasif Gelir', 'Yatırım ve temettü gelirleri'),
  other('Diğer', 'Diğer gelir kaynakları');
}

static const defaultName = 'Ana Maaş';  // Line 121
```

**GEREKLİ KEY'LER:** ~12 yeni l10n key

---

### 12. achievement.dart - Labels

**Satırlar:** 10-107
```dart
enum AchievementTier {
  bronze('Bronz'),
  silver('Gümüş'),
  gold('Altın'),
  platinum('Platin');
}

enum AchievementCategory {
  streak('Seri'),
  savings('Tasarruf'),
  decision('Karar'),
  record('Kayıt'),
  hidden('Gizli');
}

enum HiddenDifficulty {
  easy('Kolay'),
  medium('Orta'),
  hard('Zor'),
  legendary('Efsanevi');
}
```

**GEREKLİ KEY'LER:** ~15 yeni l10n key

---

### 13. achievements_screen.dart - Level System

**Satırlar:** 381-570
```dart
// HARDCODED LABELS
value: '$unlockedCount/$totalCount',
label: 'Rozetler',  // Line 382

value: '$streak',
label: 'Gün Seri',  // Line 391

// ENGLISH LEVEL TITLES
const levels = {
  1: {'title': 'Novice Saver', 'emoji': '🌱'},
  2: {'title': 'Budget Beginner', 'emoji': '📊'},
  // ... 10 levels
};

// MIXED TURKISH
'Level ${level + 1} için ${nextLevelXP - currentLevelXP} XP daha'  // Line 481
```

**GEREKLİ KEY'LER:** ~15 yeni l10n key

---

## P2 HARDCODED - MEDIUM PRIORITY

### 14. currency_utils.dart
- Lines 414-445: 'Saat', 'Gün', 'Yıl'

### 15. habit_calculator.dart
- Lines 59-131: Category names, frequencies

### 16. settings_screen.dart
- Lines 401-465: 'Türkçe', 'English'

### 17. thinking_items_service.dart
- Lines 122-133: 'Süre doldu', 'gün kaldı', 'saat kaldı'

---

## SUMMARY

### Total New Keys Required

| Öncelik | Dosya Sayısı | Key Sayısı |
|---------|--------------|------------|
| P0 | 6 | ~330 |
| P1 | 7 | ~92 |
| P2 | 4 | ~20 |
| **TOPLAM** | **17** | **~442** |

### Current Key Count
- `app_tr.arb`: ~530 keys
- `app_en.arb`: ~530 keys

### After Fix
- Target: ~970 keys per language

---

## MIGRATION STRATEGY

### Phase 1: Critical Services
1. `insight_service.dart` → `InsightService.getInsight(context, ...)`
2. `messages_service.dart` → `MessagesService.getMessage(context, ...)`
3. `achievements_service.dart` → Use `AchievementUtils.getTitle(context, id)`
4. `notification_service.dart` → Pass l10n to notification methods

### Phase 2: Models
5. `expense.dart` → Consistent use of `ExpenseCategory.getLocalizedName()`
6. `income_source.dart` → Add `getLocalizedLabel(context)` method
7. `achievement.dart` → Use existing utils

### Phase 3: Screens & Widgets
8. Fix all remaining hardcoded strings in UI

### Phase 4: Validation
9. Run `flutter gen-l10n`
10. Verify all keys exist in both languages

---

*Son güncelleme: Ocak 2026 - MEGA PHASE 4 Tamamlandı*
