# VANTAG SMOKE TEST CHECKLIST

Bu checklist, her release oncesi yapilmasi gereken temel testleri icerir.

---

## 1. APP LAUNCH & SPLASH

- [ ] Uygulama aciliyor mu?
- [ ] Splash video duzgun oynuyor mu?
- [ ] Onboarding tamamlanmis kullanici direkt MainScreen'e gidiyor mu?
- [ ] Onboarding tamamlanmamis kullanici OnboardingScreen'e gidiyor mu?
- [ ] Firebase baslatiyor mu? (Console'da log: "Firebase Core Basarili")
- [ ] Crashlytics baslatiyor mu? (Console'da log: "Crashlytics Basarili")

---

## 2. AUTHENTICATION

- [ ] Anonim giris calisiyor mu?
- [ ] Google Sign-In calisiyor mu?
- [ ] Cikis yap calisiyor mu?
- [ ] Google hesabi baglaninca profil fotografi/adi guncelleniyor mu?
- [ ] Hesap silme islemi calisiyor mu?

---

## 3. PROFILE & ONBOARDING

- [ ] Profil olusturma akisi tamamlaniyor mu?
- [ ] Gelir girisi calisiyor mu? (aylik/yillik/saatlik)
- [ ] Calisma gunleri seciliyor mu?
- [ ] Calisma saatleri seciliyor mu?
- [ ] Para birimi seciliyor mu?
- [ ] Profil duzenleme calisiyor mu?

---

## 4. EXPENSE (HARCAMA) SCREEN

- [ ] Tutar girisi calisiyor mu?
- [ ] Kategori secimi calisiyor mu?
- [ ] AI kategori tahmini calisiyor mu?
- [ ] "Aldim" butonu calisiyor mu?
- [ ] "Dusunuyorum" butonu calisiyor mu?
- [ ] "Vazgectim" butonu calisiyor mu?
- [ ] Sonuc karti duzgun gosteriliyor mu?
- [ ] Calisma saati hesaplamasi dogru mu?
- [ ] Para birimi cevirisi dogru mu?
- [ ] Gecmis harcamalar listeleniyor mu?
- [ ] Harcama silme calisiyor mu?

---

## 5. SUBSCRIPTION (ABONELIK) SCREEN

- [ ] Abonelik ekleme calisiyor mu?
- [ ] Abonelik listeleme calisiyor mu?
- [ ] Aylik toplam dogru hesaplaniyor mu?
- [ ] Abonelik duzenleme calisiyor mu?
- [ ] Abonelik silme calisiyor mu?
- [ ] Takvim gorunumu calisiyor mu?

---

## 6. PURSUIT (HAYALLERIM) SCREEN

- [ ] Hedef olusturma calisiyor mu?
- [ ] Hedef listeleme calisiyor mu?
- [ ] Birikim ekleme calisiyor mu?
- [ ] Progress bar dogru gosteriyor mu?
- [ ] Hedef tamamlama animasyonu calisiyor mu?
- [ ] Hedef silme calisiyor mu?
- [ ] FREE kullanici 1 hedef siniri calisiyor mu?

---

## 7. REPORT SCREEN

- [ ] Aylik rapor yukluyor mu?
- [ ] Kategori bazli dagilim dogru mu?
- [ ] Grafik render oluyor mu?
- [ ] Tarih filtresi calisiyor mu?

---

## 8. AI CHAT

- [ ] AI Chat aciliyor mu?
- [ ] FREE kullanici icin 4 buton gozukuyor mu?
- [ ] FREE kullanici text input kilitli mi?
- [ ] PRO kullanici text input acik mi?
- [ ] AI yanit aliyor mu?
- [ ] Typing animasyonu calisiyor mu?
- [ ] Kredi sayaci dogru mu?
- [ ] Kredi bitince uyari gosteriyor mu?

---

## 9. SETTINGS

- [ ] Tema degistirme calisiyor mu? (Dark/Light)
- [ ] Dil degistirme calisiyor mu? (TR/EN)
- [ ] Para birimi degistirme calisiyor mu?
- [ ] Bildirim ayarlari calisiyor mu?
- [ ] Gizlilik Politikasi aciliyor mu?
- [ ] Kullanim Kosullari aciliyor mu?

---

## 10. PREMIUM & PAYWALL

- [ ] Paywall aciliyor mu?
- [ ] "7 Gun Ucretsiz Dene" banner'i gorunuyor mu?
- [ ] Paketler listeleniyor mu? (Monthly, Yearly, Lifetime)
- [ ] Satin alma akisi calisiyor mu?
- [ ] "Restore Purchases" calisiyor mu?
- [ ] FREE -> PRO gecisi dogru calisiyor mu?

---

## 11. CURRENCY & EXCHANGE RATES

- [ ] Doviz kurlari yukleniyor mu?
- [ ] USD/TRY dogru gosteriliyor mu?
- [ ] EUR/TRY dogru gosteriliyor mu?
- [ ] Altin fiyati dogru gosteriliyor mu?
- [ ] Para birimi cevirisi dogru calisiyor mu?

---

## 12. OFFLINE MODE

- [ ] Internet kesildiginde banner gorunuyor mu?
- [ ] Offline'dayken harcama eklenebiliyor mu?
- [ ] Tekrar online olunca sync oluyor mu?
- [ ] "Back Online" mesaji gorunuyor mu?

---

## 13. NOTIFICATIONS

- [ ] Push notification permission isteniyor mu?
- [ ] Daily reminder calisiyor mu?
- [ ] Subscription renewal uyarisi calisiyor mu?

---

## 14. ACHIEVEMENTS

- [ ] Rozet listesi yukluyor mu?
- [ ] Rozet kazanma calisiyor mu?
- [ ] Konfeti animasyonu calisiyor mu?
- [ ] Share butonu calisiyor mu?

---

## 15. PERFORMANCE

- [ ] App < 3 saniyede aciliyor mu?
- [ ] Scroll akici mi? (60fps)
- [ ] Memory leak yok mu?
- [ ] Battery drain normal mi?

---

## 16. CRASH TESTING

- [ ] Bos form submit crash vermiyor mu?
- [ ] Negatif sayi girisi crash vermiyor mu?
- [ ] Cok uzun text girisi crash vermiyor mu?
- [ ] Hizli tab degistirme crash vermiyor mu?
- [ ] Back button spam crash vermiyor mu?

---

## 17. EDGE CASES

- [ ] 0 TL gelir girisi handle ediliyor mu?
- [ ] Cok yuksek tutar (999.999.999) crash vermiyor mu?
- [ ] Emoji iceren aciklama calisiyor mu?
- [ ] Turkce karakter (i, I, g, u, s, c, o) dogru gosteriliyor mu?

---

## 18. DARK MODE

- [ ] Tum ekranlar dark mode'da okunakli mi?
- [ ] Text contrast yeterli mi?
- [ ] Icon'lar gorunuyor mu?
- [ ] Gradient'lar dogru gozukuyor mu?

---

## 19. LOCALIZATION

- [ ] Turkce tum string'ler dogru mu?
- [ ] Ingilizce tum string'ler dogru mu?
- [ ] Tarih formati dile gore degisiyor mu?
- [ ] Para formati dile gore degisiyor mu?

---

## 20. DEVICE SPECIFIC

### Android
- [ ] Android 7+ destekleniyor mu?
- [ ] Notch/cutout handle ediliyor mu?
- [ ] Landscape mode crash vermiyor mu?
- [ ] Back gesture calisiyor mu?

### iOS
- [ ] iOS 12+ destekleniyor mu?
- [ ] Notch/Dynamic Island handle ediliyor mu?
- [ ] Safe area dogru mu?
- [ ] Face ID/Touch ID calisiyor mu?

---

## TEST SONUCLARI

| Tarih | Tester | Platform | Sonuc | Notlar |
|-------|--------|----------|-------|--------|
| | | | | |
| | | | | |
| | | | | |

---

## KNOWN ISSUES

1. **Firestore savings_pool permission-denied** - Rules update gerekli
2. **OnBackInvokedCallback warning** - AndroidManifest update gerekli
3. **Emulator GFXSTREAM errors** - Emulator-specific, gercek cihazda yok

---

*Son guncelleme: Ocak 2026*
