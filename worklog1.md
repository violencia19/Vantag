# Work Log - Bug Fix Session (January 2026)

Bu dosya, 12 bug fix'in detaylı kaydını içerir.

---

## Özet Tablo

| # | Priority | Sorun | Çözüm | Commit |
|---|----------|-------|-------|--------|
| 1 | P0 | Onboarding her seferinde gösteriliyor | `setOnboardingCompleted()` retry mekanizması eklendi | `82b38c7` |
| 2 | P0 | Para birimi değişince gelir dönüştürülmüyor | Fallback rates + fetch before convert | `ada6d25` |
| 3 | P0 | SavingsPool loading'de takılıyor | Local first, then stream | `35214b3` |
| 4 | P0 | Mindful Choice tasarruf eklemiyor | Smart choice detection + pool save | `3af2eea` |
| 5 | P1 | Share Card ortalama ve overlap | Centering fix + text removal | `c163688` |
| 6 | P1 | Light Mode UI eksik | AppColorsExtension theme system | `64b99d4` |
| 7 | P1 | HARC+AMA text split | maxLines: 1 + ellipsis | `131cb57` |
| 8 | P1 | Invite friend açıklama eksik | Localization update | `a5f3154` |
| 9 | P1 | Paywall badge overlap | Badge position left | `549442a` |
| 10 | P1 | Bottom sheet blur eksik | AnimatedBottomSheet.show() | `52e8d1c` |
| 11 | P1 | Profile edit butonları yok | Quick action buttons | `87f9fdd` |
| 12 | P2 | Referral IP control | ReferralService + SHA256 hash | `e322ce4` |

---

## P0-1: Onboarding Her Seferinde Gösteriliyor

**Sorun:** Uygulama her açıldığında onboarding ekranı gösteriliyordu.

**Dosya:** `lib/services/profile_service.dart`

**Çözüm:**
- `reload()` çağrısı kaldırıldı (sorun yaratıyordu)
- Retry mekanizması eklendi

```dart
Future<bool> setOnboardingCompleted() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setBool(_keyOnboardingCompleted, true);
    if (!success) {
      // Retry once if first attempt fails
      final retrySuccess = await prefs.setBool(_keyOnboardingCompleted, true);
      return retrySuccess;
    }
    return success;
  } catch (e) {
    debugPrint('[ProfileService] Error setting onboarding completed: $e');
    return false;
  }
}
```

---

## P0-2: Para Birimi Değişince Gelir Dönüştürülmüyor

**Sorun:** Kullanıcı para birimi değiştirdiğinde gelir değeri dönüştürülmüyordu.

**Dosyalar:**
- `lib/services/exchange_rate_service.dart`
- `lib/widgets/currency_selector.dart`

**Çözüm:**

1. Fallback rates eklendi:
```dart
static const Map<String, double> _fallbackRates = {
  'USD': 1.0,
  'EUR': 0.92,
  'GBP': 0.79,
  'TRY': 34.5,
  'SAR': 3.75,
};
```

2. Conversion öncesi rate fetch:
```dart
if (!currencyProvider.hasRates) {
  await currencyProvider.fetchRates();
}
```

---

## P0-3: SavingsPool Loading'de Takılıyor

**Sorun:** Savings Pool sürekli loading state'de kalıyordu.

**Dosyalar:**
- `lib/providers/savings_pool_provider.dart`
- `lib/services/savings_pool_service.dart`

**Çözüm:**

1. Provider'da local first yaklaşımı:
```dart
Future<void> initialize() async {
  _isLoading = true;
  notifyListeners();

  // İlk olarak local'den yükle (hızlı başlangıç için)
  _pool = await _service.getPool();
  _isLoading = false;
  notifyListeners();

  // Sonra stream'e abone ol
  _subscription = _service.poolStream.listen((pool) {
    _pool = pool;
    notifyListeners();
  });
}
```

2. Service'de cached pool emit:
```dart
Stream<SavingsPool> get poolStream async* {
  // İlk olarak cached pool'u emit et
  final cachedPool = await getPool();
  yield cachedPool;
  // ...
}
```

---

## P0-4: Mindful Choice Tasarruf Eklemiyor

**Sorun:** "Aldım ama daha ucuza" seçeneğinde fark SavingsPool'a eklenmiyordu.

**Dosya:** `lib/widgets/add_expense_sheet.dart`

**Çözüm:**
```dart
// Smart Choice savings (when user bought but spent less than intended)
if (decision == ExpenseDecision.yes &&
    expenseWithDecision.isSmartChoice &&
    expenseWithDecision.savedAmount > 0 &&
    !isSimulation) {
  final savingsPoolProvider = context.read<SavingsPoolProvider>();
  await savingsPoolProvider.addSavings(expenseWithDecision.savedAmount);
  debugPrint('[AddExpenseSheet] Smart choice savings added: ${expenseWithDecision.savedAmount}');
}
```

---

## P1-5: Share Card Ortalama ve Overlap

**Sorun:** Share Card'da içerik ortalı değildi ve textler üst üste biniyordu.

**Dosya:** `lib/widgets/premium_share_card.dart`

**Çözüm:**
- `crossAxisAlignment: CrossAxisAlignment.center` eklendi
- Overlapping text kaldırıldı
- Spacing düzenlendi

---

## P1-6: Light Mode UI Desteği

**Sorun:** Uygulama light mode'da düzgün görünmüyordu.

**Dosyalar:**
- `lib/theme/app_theme.dart`
- `lib/screens/expense_screen.dart`
- `lib/screens/main_screen.dart`
- `lib/widgets/premium_nav_bar.dart`

**Çözüm:**

1. Theme-aware color extension:
```dart
extension AppColorsExtension on BuildContext {
  _ThemeColors get appColors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return _ThemeColors(isDark);
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

class _ThemeColors {
  final bool _isDark;
  const _ThemeColors(this._isDark);

  Color get background => _isDark ? AppColors.background : AppColorsLight.background;
  Color get surface => _isDark ? AppColors.surface : AppColorsLight.surface;
  Color get textPrimary => _isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
  // ...
}
```

2. Kullanım:
```dart
final colors = context.appColors;
Container(color: colors.background)
```

---

## P1-7: HARC+AMA Text Split

**Sorun:** "HARCAMA" ve "GELİR" yazıları iki satıra bölünüyordu.

**Dosya:** `lib/widgets/financial_snapshot_card.dart`

**Çözüm:**
```dart
Text(
  l10n.income.toUpperCase(),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    color: AppColors.textTertiary,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  ),
),
```

---

## P1-8: Invite Friend Açıklama Eksik

**Sorun:** Arkadaş davet et özelliğinin açıklaması eksikti.

**Dosyalar:**
- `lib/l10n/app_tr.arb`
- `lib/l10n/app_en.arb`

**Çözüm:**
```json
// app_tr.arb
"settingsGrowth": "Arkadaşını davet et, 3 gün Premium kazan"

// app_en.arb
"settingsGrowth": "Invite friends, earn 3 days Premium"
```

---

## P1-9: Paywall Badge Overlap

**Sorun:** "En Popüler" badge'i fiyatla üst üste biniyordu.

**Dosya:** `lib/screens/paywall_screen.dart`

**Çözüm:**
```dart
Positioned(
  top: -10,
  left: 40,  // Önceden: right: -8
  child: Container(
    // Badge content
  ),
),
```

---

## P1-10: Bottom Sheet Blur Eksik

**Sorun:** AI Chat bottom sheet'te blur/backdrop efekti yoktu.

**Dosya:** `lib/screens/main_screen.dart`

**Çözüm:**
```dart
void _openAIChat() {
  AnimatedBottomSheet.show(
    context: context,
    builder: (context) => AIChatSheet(
      financeProvider: context.read<FinanceProvider>(),
    ),
  );
}
```

`AnimatedBottomSheet.show()` zaten blur desteği içeriyordu, sadece kullanılması gerekiyordu.

---

## P1-11: Profile Edit Butonları Eksik

**Sorun:** Profil ekranında hızlı düzenleme butonları yoktu.

**Dosyalar:**
- `lib/screens/profile_screen.dart`
- `lib/l10n/app_tr.arb`
- `lib/l10n/app_en.arb`

**Çözüm:**

1. Quick action buttons eklendi:
```dart
Row(
  children: [
    _buildQuickActionButton(
      icon: PhosphorIconsDuotone.camera,
      label: l10n.changePhoto,
      onTap: () => _showPhotoOptions(l10n),
    ),
    const SizedBox(width: 12),
    _buildQuickActionButton(
      icon: PhosphorIconsDuotone.wallet,
      label: l10n.editIncome,
      onTap: _editProfile,
    ),
    const SizedBox(width: 12),
    _buildQuickActionButton(
      icon: PhosphorIconsDuotone.plusCircle,
      label: l10n.addIncome,
      onTap: _editProfile,
      highlight: true,
    ),
  ],
),
```

2. Yeni localization key'leri:
```json
"editIncome": "Geliri Düzenle" / "Edit Income"
"changePhoto": "Fotoğraf Değiştir" / "Change Photo"
"takePhoto": "Fotoğraf Çek" / "Take Photo"
"chooseFromGallery": "Galeriden Seç" / "Choose from Gallery"
```

---

## P2-12: Referral IP Control

**Sorun:** Aynı IP'den birden fazla hesap açılarak referral bonusu kötüye kullanılabiliyordu.

**Dosyalar:**
- `lib/services/referral_service.dart` (YENİ)
- `lib/services/services.dart`
- `lib/main.dart`
- `pubspec.yaml`

**Çözüm:**

1. Yeni ReferralService oluşturuldu:
```dart
class ReferralService {
  static const int _maxAccountsPerIP = 3;

  /// Get current user's IP address
  Future<String?> _getIPAddress() async {
    final response = await http.get(
      Uri.parse('https://api.ipify.org?format=json'),
    );
    return json.decode(response.body)['ip'];
  }

  /// Hash an IP address for privacy
  String _hashIP(String ip) {
    final bytes = utf8.encode(ip);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if a referral bonus can be granted
  Future<bool> canGrantReferralBonus() async {
    final ip = await _getIPAddress();
    final ipHash = _hashIP(ip!);

    final query = await _firestore
        .collection(_ipHashCollection)
        .where('ipHash', isEqualTo: ipHash)
        .get();

    return query.docs.length < _maxAccountsPerIP;
  }
}
```

2. crypto package eklendi:
```yaml
crypto: ^3.0.3
```

3. main.dart'ta IP kaydı:
```dart
if (result.success) {
  ReferralService().registerUserIP();
}
```

**Özellikler:**
- IP adresi SHA256 ile hash'leniyor (gizlilik)
- Firestore `ip_hashes` collection'da saklanıyor
- 3+ hesap aynı IP'den = bonus yok
- Referral code üretme ve takip

---

## Sonraki Adımlar

```bash
# Build almak için:
flutter build apk --release

# Test için:
flutter test
```

---

*Son güncelleme: Ocak 2026*
