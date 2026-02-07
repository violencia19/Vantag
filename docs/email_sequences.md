# Vantag Email Sequences & Triggers

Bu döküman, Vantag uygulamasının email marketing otomasyonlarını tanımlar. Backend entegrasyonu için referans olarak kullanılmalıdır.

---

## 1. Onboarding Email Sequence

### Trigger: `user_registered`
Kullanıcı hesap oluşturduğunda başlar.

| Email | Delay | Subject (TR) | Subject (EN) | Purpose |
|-------|-------|--------------|--------------|---------|
| Welcome | Hemen | Vantag'a Hoş Geldin! 🎉 | Welcome to Vantag! 🎉 | İlk değer sunumu |
| Quick Win | +1 gün | İlk harcamanı eklemeyi unutma | Don't forget to add your first expense | Aktivasyon |
| Value Reminder | +3 gün | Kaç saat çalıştığını biliyor musun? | Do you know how many hours you worked? | Değer hatırlatma |
| Feature Discovery | +7 gün | Vantag'ın gizli özellikleri ✨ | Hidden features of Vantag ✨ | Feature adoption |
| Streak Motivation | +14 gün | 14 günlük seri başlat! | Start a 14-day streak! | Retention |

### Email 1: Welcome
```
Trigger: user_registered
Delay: 0
Condition: None

Subject: Vantag'a Hoş Geldin! 🎉

Content:
- Kısa tanıtım (1-2 cümle)
- Temel değer önerisi: "Harcamalarını çalışma saatine çevir"
- CTA: "İlk Harcamanı Ekle" → deep link: vantag://expense/add
- Uygulamayı indirme linki (henüz indirmediyse)
```

### Email 2: Quick Win
```
Trigger: user_registered
Delay: 24 hours
Condition: has_expense_count < 1

Subject: İlk harcamanı eklemeyi unutma

Content:
- "Küçük başla, farkı gör"
- Örnek: "Bir kahve = 30 dakika çalışma"
- CTA: "Hemen Ekle" → deep link: vantag://expense/add
- Skip condition: Kullanıcı zaten harcama eklediyse gönderme
```

### Email 3: Value Reminder
```
Trigger: user_registered
Delay: 72 hours
Condition: has_expense_count < 3

Subject: Kaç saat çalıştığını biliyor musun?

Content:
- Değer hatırlatma
- Sosyal kanıt: "10.000+ kullanıcı tasarruf ediyor"
- CTA: "Harcama Ekle" → deep link: vantag://expense/add
```

### Email 4: Feature Discovery
```
Trigger: user_registered
Delay: 7 days
Condition: is_active = true

Subject: Vantag'ın gizli özellikleri ✨

Content:
- AI Sohbet tanıtımı
- Hedef (Pursuit) özelliği
- Haftalık raporlar
- CTA: "Keşfet" → deep link: vantag://home
```

### Email 5: Streak Motivation
```
Trigger: user_registered
Delay: 14 days
Condition: current_streak < 7

Subject: 14 günlük seri başlat!

Content:
- Streak sistemi açıklaması
- Faydaları
- CTA: "Seriyi Başlat" → deep link: vantag://expense/add
```

---

## 2. Re-engagement Email Sequence

### Trigger: `user_stalled`
Kullanıcı 3+ gün inaktif olduğunda başlar.

| Email | Delay | Subject (TR) | Subject (EN) | Condition |
|-------|-------|--------------|--------------|-----------|
| Miss You | +3 gün | Seni özledik! 👋 | We miss you! 👋 | days_inactive >= 3 |
| Streak Warning | +5 gün | Seriniz sıfırlanmak üzere! | Your streak is about to reset! | days_inactive >= 5, had_streak |
| Value Recap | +7 gün | Bu ay kaçırdıkların... | What you missed this month... | days_inactive >= 7 |
| Win Back | +14 gün | Yeni başlangıç zamanı | Time for a fresh start | days_inactive >= 14 |
| Final Attempt | +30 gün | Vantag seni bekliyor | Vantag is waiting for you | days_inactive >= 30 |

### Email 1: Miss You
```
Trigger: user_stalled
Delay: 3 days inactive
Condition: days_inactive >= 3

Subject: Seni özledik! 👋

Content:
- Kişiselleştirilmiş mesaj
- Son aktivite özeti
- CTA: "Geri Dön" → deep link: vantag://home
```

### Email 2: Streak Warning
```
Trigger: user_stalled
Delay: 5 days inactive
Condition: days_inactive >= 5 AND had_streak = true

Subject: Seriniz sıfırlanmak üzere!

Content:
- Streak kaybı uyarısı
- Kurtarma bonusu teklifi
- CTA: "Seriyi Kurtar" → deep link: vantag://expense/add
```

### Email 3: Value Recap
```
Trigger: user_stalled
Delay: 7 days inactive
Condition: days_inactive >= 7

Subject: Bu ay kaçırdıkların...

Content:
- Kaçırılan tasarruf potansiyeli
- Diğer kullanıcıların başarıları
- CTA: "Hemen Başla" → deep link: vantag://home
```

### Email 4: Win Back
```
Trigger: user_stalled
Delay: 14 days inactive
Condition: days_inactive >= 14

Subject: Yeni başlangıç zamanı

Content:
- Yeniden başlama motivasyonu
- Yeni özellikler (varsa)
- CTA: "Yeniden Başla" → deep link: vantag://home
```

### Email 5: Final Attempt
```
Trigger: user_stalled
Delay: 30 days inactive
Condition: days_inactive >= 30

Subject: Vantag seni bekliyor

Content:
- Son şans mesajı
- Değer özetitop
- CTA: "Geri Dön" → deep link: vantag://home
- Unsubscribe seçeneği belirgin
```

---

## 3. Milestone Celebration Emails

### Trigger: `milestone_achieved`
Kullanıcı bir milestone'a ulaştığında gönderilir.

| Milestone | Subject (TR) | Subject (EN) |
|-----------|--------------|--------------|
| first_expense | İlk harcamanı ekledin! 🎉 | You added your first expense! 🎉 |
| streak_7 | 7 günlük seri! 🔥 | 7-day streak! 🔥 |
| streak_30 | 30 günlük seri! 🏆 | 30-day streak! 🏆 |
| streak_100 | 100 günlük seri! 👑 | 100-day streak! 👑 |
| saved_1000 | 1.000₺ tasarruf ettin! | You saved ₺1,000! |
| saved_10000 | 10.000₺ tasarruf ettin! | You saved ₺10,000! |
| first_pursuit_completed | İlk hedefe ulaştın! 🎯 | You reached your first goal! 🎯 |
| pro_anniversary | Pro üyeliğinin 1. yılı! | 1 year of Pro membership! |

### Template: Milestone Email
```
Trigger: milestone_achieved
Delay: 0 (immediate)
Condition: milestone_type = {type}

Subject: {milestone_subject}

Content:
- Kutlama mesajı
- Başarı detayı
- Sosyal paylaşım teşviki
- Sonraki hedef önerisi
- CTA: "Devam Et" → deep link: vantag://home
```

---

## 4. Weekly Digest Email

### Trigger: `weekly_digest`
Her Pazar sabahı 10:00'da gönderilir.

```
Trigger: cron (Sunday 10:00 AM user_timezone)
Condition: has_expense_count > 0 in last 30 days

Subject: Haftalık Özetin Hazır 📊

Content:
- Bu hafta toplam harcama
- Çalışma saati karşılığı
- Kategori dağılımı (top 3)
- Önceki haftayla karşılaştırma
- Tasarruf edilen miktar (varsa)
- CTA: "Detaylı Raporu Gör" → deep link: vantag://reports
```

---

## 5. Subscription Emails

### 5.1 Trial Ending
```
Trigger: trial_ending
Delay: 3 days before trial ends
Condition: is_trial = true

Subject: Deneme süreniz bitiyor

Content:
- Kalan gün sayısı
- Pro özellikleri özeti
- Özel indirim (varsa)
- CTA: "Pro'ya Geç" → deep link: vantag://subscription
```

### 5.2 Subscription Confirmed
```
Trigger: subscription_started
Delay: 0 (immediate)

Subject: Vantag Pro'ya hoş geldin! 🌟

Content:
- Teşekkür
- Pro özellikleri listesi
- Destek kanalları
- CTA: "Özellikleri Keşfet" → deep link: vantag://home
```

### 5.3 Subscription Renewal Reminder
```
Trigger: subscription_renewing
Delay: 7 days before renewal
Condition: is_subscription = true

Subject: Aboneliğiniz yenilenecek

Content:
- Yenileme tarihi
- Tutar bilgisi
- İptal/değiştirme linki
```

### 5.4 Subscription Cancelled
```
Trigger: subscription_cancelled
Delay: 0 (immediate)

Subject: Üzgünüz, gidiyorsunuz 😢

Content:
- Geri bildirim anketi
- Erişimin ne zaman sona ereceği
- Geri dönüş teklifi
- CTA: "Geri Bildirim Ver" → survey link
```

### 5.5 Subscription Expired (Win-back)
```
Trigger: subscription_expired
Delay: 7 days after expiry
Condition: was_subscriber = true

Subject: Pro özelliklerini özledin mi?

Content:
- Kaybedilen özellikler listesi
- Özel geri dönüş indirimi
- CTA: "Tekrar Abone Ol" → deep link: vantag://subscription
```

---

## 6. Transactional Emails

### 6.1 Password Reset
```
Trigger: password_reset_requested
Delay: 0 (immediate)

Subject: Şifre sıfırlama

Content:
- Sıfırlama linki (6 saat geçerli)
- Güvenlik notu
```

### 6.2 Account Verification
```
Trigger: email_verification_requested
Delay: 0 (immediate)

Subject: Email adresini doğrula

Content:
- Doğrulama linki
- Neden gerekli açıklaması
```

### 6.3 Data Export Ready
```
Trigger: data_export_completed
Delay: 0 (immediate)

Subject: Verileriniz hazır

Content:
- İndirme linki (48 saat geçerli)
- İçerik açıklaması
```

---

## 7. Analytics Events for Email

Backend'in email gönderimlerini takip etmesi için app'ten gönderilecek event'ler:

```dart
// Kullanıcı stalled oldu
AnalyticsService().logEvent('trigger_reengagement_email', {
  'days_inactive': daysSinceActive,
  'email_type': 'miss_you',
});

// Milestone reached
AnalyticsService().logEvent('trigger_milestone_email', {
  'milestone_type': 'streak_7',
  'user_id': userId,
});

// Email CTA clicked (deep link opened)
AnalyticsService().logEvent('email_cta_clicked', {
  'email_type': 'onboarding_day3',
  'cta_action': 'add_expense',
});
```

---

## 8. Email Preferences

Kullanıcı email tercihlerini yönetebilmelidir:

| Preference | Default | Description |
|------------|---------|-------------|
| marketing_emails | true | Pazarlama emailleri |
| weekly_digest | true | Haftalık özet |
| milestone_emails | true | Milestone kutlamaları |
| streak_reminders | true | Seri hatırlatmaları |
| product_updates | true | Ürün güncellemeleri |

### Unsubscribe Handling
- Her emailde unsubscribe linki olmalı
- Tek tıkla unsubscribe (CAN-SPAM uyumu)
- Preference center linki
- Tamamen çıkış seçeneği (tüm emailleri durdur)

---

## 9. Deep Link Specifications

| Deep Link | Target Screen |
|-----------|---------------|
| `vantag://home` | Ana ekran |
| `vantag://expense/add` | Harcama ekleme |
| `vantag://reports` | Raporlar |
| `vantag://pursuits` | Hedefler |
| `vantag://subscription` | Abonelik ekranı |
| `vantag://settings` | Ayarlar |
| `vantag://profile` | Profil |

---

## 10. Implementation Notes

### Backend Requirements
1. Email service provider (SendGrid, Mailgun, etc.)
2. User segmentation based on:
   - `days_since_last_activity`
   - `expense_count`
   - `current_streak`
   - `is_pro`
   - `subscription_status`
3. Timezone-aware scheduling
4. A/B testing capability
5. Email analytics (open rate, click rate)

### App-side Requirements
1. Deep link handling for all email CTAs
2. Analytics events for email triggers
3. Email preference sync with backend
4. Push notification vs email coordination

### Compliance
- GDPR/KVKK uyumu
- CAN-SPAM uyumu
- Unsubscribe zorunluluğu
- Data retention policies
- User consent tracking

---

## 11. A/B Testing Suggestions

### Subject Lines
- Emoji vs no emoji
- Question vs statement
- Personal vs generic
- Urgency vs benefit

### Content
- Short vs long
- Image vs text-only
- Single CTA vs multiple
- Social proof vs no proof

### Timing
- Morning vs evening
- Weekday vs weekend
- Delay variations

---

## 12. Success Metrics

| Metric | Target |
|--------|--------|
| Open Rate | > 25% |
| Click Rate | > 5% |
| Unsubscribe Rate | < 0.5% |
| Reactivation Rate (re-engagement) | > 15% |
| Conversion Rate (trial to paid) | > 8% |

---

*Last Updated: January 2025*
*Version: 1.0*
