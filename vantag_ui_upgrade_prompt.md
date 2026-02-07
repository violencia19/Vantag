# VANTAG PREMIUM UI UPGRADE - CLAUDE CODE PROMPT

## 🎯 HEDEF
Vantag'ı Revolut/N26 kalitesinde premium fintech uygulamasına dönüştür. 
Mevcut yapıyı koru, sadece görsel kaliteyi artır.

---

## 📐 DESIGN TOKENS (Revolut Style)

### Renkler (Dark Mode - Primary)
```dart
// Background
background: Color(0xFF0D0D0D)  // Saf siyaha yakın
surface: Color(0xFF1A1A1A)     // Kartlar için
surfaceLight: Color(0xFF252525) // Elevated surfaces

// Primary - Mor yerine Mavi tonları (Revolut style)
// VEYA mevcut mor palette'i koru ama daha sofistike:
primary: Color(0xFF6C5CE7)      // Soft purple
primaryLight: Color(0xFFA29BFE) // Light purple
primaryDark: Color(0xFF5B4ED9)  // Dark purple

// Accent Colors  
success: Color(0xFF00D26A)      // Yeşil - pozitif
error: Color(0xFFFF4757)        // Kırmızı - negatif  
warning: Color(0xFFFFB800)      // Sarı - uyarı
info: Color(0xFF54A0FF)         // Mavi - bilgi

// Text
textPrimary: Color(0xFFFFFFFF)   // %100 beyaz
textSecondary: Color(0xFF8E8E93) // iOS gray
textTertiary: Color(0xFF636366)  // Dimmed text
```

### Tipografi (Inter veya SF Pro Display)
```dart
// Büyük Rakamlar (Bakiye, Ana değerler)
largeNumber: TextStyle(
  fontFamily: 'Inter',
  fontSize: 48,
  fontWeight: FontWeight.w700,
  letterSpacing: -1.5,
  height: 1.0,
)

// Başlıklar
headline: TextStyle(
  fontFamily: 'Inter', 
  fontSize: 24,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
)

// Section Title
sectionTitle: TextStyle(
  fontFamily: 'Inter',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.2,
  color: textSecondary,
)

// Body
body: TextStyle(
  fontFamily: 'Inter',
  fontSize: 15,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.2,
)

// Caption
caption: TextStyle(
  fontFamily: 'Inter',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.2,
  color: textTertiary,
)
```

### Spacing (8pt Grid System)
```dart
spacing4: 4.0   // Micro
spacing8: 8.0   // Small
spacing12: 12.0 // Medium-small
spacing16: 16.0 // Medium (default card padding)
spacing20: 20.0 // Medium-large
spacing24: 24.0 // Large
spacing32: 32.0 // XL
spacing48: 48.0 // XXL

// Screen padding
screenPadding: EdgeInsets.symmetric(horizontal: 20)

// Card padding
cardPadding: EdgeInsets.all(16)
cardPaddingLarge: EdgeInsets.all(20)
```

### Border Radius
```dart
radiusSmall: 8.0    // Küçük butonlar, chips
radiusMedium: 12.0  // Input fields, küçük kartlar
radiusLarge: 16.0   // Normal kartlar
radiusXL: 20.0      // Büyük kartlar
radiusXXL: 24.0     // Modal, bottom sheet
radiusFull: 999.0   // Pill shape
```

### Shadows
```dart
// Subtle shadow (kartlar için)
shadowSubtle: BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 10,
  offset: Offset(0, 4),
)

// Medium shadow (elevated cards)
shadowMedium: BoxShadow(
  color: Color(0x14000000),
  blurRadius: 20,
  offset: Offset(0, 8),
)

// Glow effect (primary color için)
primaryGlow: BoxShadow(
  color: primary.withOpacity(0.25),
  blurRadius: 20,
  spreadRadius: -5,
)
```

---

## 🎨 COMPONENT SPECIFICATIONS

### 1. Premium Card (Ana Kart Stili)
```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.06),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
  child: ...
)
```

### 2. Glass Card (Şeffaf Kart)
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: ...
    ),
  ),
)
```

### 3. Transaction List Item (Harcama Satırı)
```dart
// Revolut style - temiz, minimal
Container(
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  child: Row(
    children: [
      // Kategori ikonu - yuvarlak, renkli arka plan
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: categoryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(categoryIcon, color: categoryColor, size: 22),
      ),
      SizedBox(width: 14),
      
      // Açıklama + alt bilgi
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            )),
            SizedBox(height: 2),
            Text(subtitle, style: TextStyle(
              fontSize: 13,
              color: textTertiary,
            )),
          ],
        ),
      ),
      
      // Tutar
      Text(amount, style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isExpense ? textPrimary : success,
      )),
    ],
  ),
)
```

### 4. Bottom Navigation Bar
```dart
// Floating, glass effect
Container(
  margin: EdgeInsets.fromLTRB(20, 0, 20, 34),
  height: 64,
  decoration: BoxDecoration(
    color: surface.withOpacity(0.95),
    borderRadius: BorderRadius.circular(32),
    border: Border.all(
      color: Colors.white.withOpacity(0.06),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 30,
        offset: Offset(0, 10),
      ),
    ],
  ),
)
```

### 5. Butonlar

#### Primary Button
```dart
Container(
  height: 56,
  decoration: BoxDecoration(
    color: primary,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.35),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: Center(
    child: Text('Button', style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    )),
  ),
)
```

#### Secondary Button (Outline)
```dart
Container(
  height: 56,
  decoration: BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: Colors.white.withOpacity(0.12),
      width: 1.5,
    ),
  ),
)
```

### 6. Input Field
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.06),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: primary.withOpacity(0.5),
        width: 1.5,
      ),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
)
```

---

## 🔧 DOSYA DEĞİŞİKLİKLERİ

### 1. lib/theme/app_theme.dart
- Design token'ları güncelle
- Yeni spacing ve radius sabitleri ekle
- Light mode için de aynı kaliteyi uygula

### 2. lib/theme/premium_theme.dart
- Glass card component'ini geliştir
- Yeni shadow ve glow efektleri ekle

### 3. lib/widgets/expense_history_card.dart
- Transaction list item'ı Revolut style yap
- İkon container'larını güzelleştir
- Spacing'leri düzenle

### 4. lib/widgets/premium_nav_bar.dart
- Bottom nav'ı floating glass style yap
- İkon boyutlarını ve spacing'i ayarla
- Aktif durumda subtle glow ekle

### 5. lib/screens/profile_modal.dart
- Google/Apple kartlarını premium yap
- Resmi logolar kullan (Google renkli, Apple beyaz)
- Bağlı/bağlı değil durumu için görsel fark

### 6. lib/widgets/premium_fintech_dashboard.dart
- Balance card'ı daha premium yap
- Counting animation'ı smooth'laştır
- Stat kartlarını küçük ama etkili yap

---

## ⚠️ ÖNEMLİ KURALLAR

1. **Mevcut işlevselliği bozma** - Sadece görsel değişiklik
2. **Tutarlılık** - Tüm ekranlarda aynı design language
3. **Performans** - Gereksiz animasyon/efekt ekleme
4. **Erişilebilirlik** - Contrast oranlarını koru (min 4.5:1)
5. **iOS/Android** - Her iki platformda test et

---

## 📱 ÖNCELİK SIRASI

1. ✅ Ana ekran kartları (Balance, Stats)
2. ✅ Transaction list (Harcama listesi)
3. ✅ Bottom navigation
4. ✅ Butonlar ve input'lar
5. ✅ Modal/Sheet tasarımları
6. ✅ Profile sayfası kartları

---

## 🎬 ANIMASYONLAR

```dart
// Standard curve
curve: Curves.easeOutCubic

// Duration'lar
fast: Duration(milliseconds: 150)
normal: Duration(milliseconds: 250)  
slow: Duration(milliseconds: 400)

// Page transition
SlideTransition + FadeTransition combined
```

---

Bu rehberi kullanarak Vantag'ı premium kaliteye yükselt!
