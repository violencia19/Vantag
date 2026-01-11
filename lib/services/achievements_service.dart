import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'streak_service.dart';
import 'expense_history_service.dart';
import 'currency_service.dart';
import 'subscription_service.dart';

class AchievementsService {
  static const _keyPrefix = 'achievement_unlocked_';
  static const _keyFirstInstall = 'first_install_date';

  final _streakService = StreakService();
  final _historyService = ExpenseHistoryService();
  final _currencyService = CurrencyService();
  final _subscriptionService = SubscriptionService();

  // ========== STREAK ROZETLERİ (10 adet) ==========
  static const _streakAchievements = <_AchievementDef>[
    // Bronze
    _AchievementDef(
      id: 'streak_b1',
      title: 'Başlangıç',
      description: '3 gün üst üste kayıt yap',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
      subTier: 1,
      target: 3,
    ),
    _AchievementDef(
      id: 'streak_b2',
      title: 'Devam Ediyorum',
      description: '7 gün üst üste kayıt yap',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
      subTier: 2,
      target: 7,
    ),
    _AchievementDef(
      id: 'streak_b3',
      title: 'Rutin Oluşuyor',
      description: '14 gün üst üste kayıt yap',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
      subTier: 3,
      target: 14,
    ),
    // Silver
    _AchievementDef(
      id: 'streak_s1',
      title: 'Kararlılık',
      description: '30 gün üst üste kayıt yap',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      subTier: 1,
      target: 30,
    ),
    _AchievementDef(
      id: 'streak_s2',
      title: 'Alışkanlık',
      description: '60 gün üst üste kayıt yap',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      subTier: 2,
      target: 60,
    ),
    _AchievementDef(
      id: 'streak_s3',
      title: 'Disiplin',
      description: '90 gün üst üste kayıt yap',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      subTier: 3,
      target: 90,
    ),
    // Gold
    _AchievementDef(
      id: 'streak_g1',
      title: 'Güçlü İrade',
      description: '150 gün üst üste kayıt yap',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      subTier: 1,
      target: 150,
    ),
    _AchievementDef(
      id: 'streak_g2',
      title: 'Sarsılmaz',
      description: '250 gün üst üste kayıt yap',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      subTier: 2,
      target: 250,
    ),
    _AchievementDef(
      id: 'streak_g3',
      title: 'İstikrar',
      description: '365 gün üst üste kayıt yap',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      subTier: 3,
      target: 365,
    ),
    // Platinum
    _AchievementDef(
      id: 'streak_p',
      title: 'Süreklilik',
      description: '730 gün üst üste kayıt yap',
      category: AchievementCategory.streak,
      tier: AchievementTier.platinum,
      subTier: 1,
      target: 730,
    ),
  ];

  // ========== TASARRUF ROZETLERİ (12 adet) ==========
  static const _savingsAchievements = <_AchievementDef>[
    // Bronze
    _AchievementDef(
      id: 'savings_b1',
      title: 'İlk Tasarruf',
      description: '250 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.bronze,
      subTier: 1,
      target: 250,
    ),
    _AchievementDef(
      id: 'savings_b2',
      title: 'Birikime Başladım',
      description: '500 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.bronze,
      subTier: 2,
      target: 500,
    ),
    _AchievementDef(
      id: 'savings_b3',
      title: 'Yolun Başında',
      description: '1,000 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.bronze,
      subTier: 3,
      target: 1000,
    ),
    // Silver
    _AchievementDef(
      id: 'savings_s1',
      title: 'Bilinçli Harcama',
      description: '2,500 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.silver,
      subTier: 1,
      target: 2500,
    ),
    _AchievementDef(
      id: 'savings_s2',
      title: 'Kontrollü',
      description: '5,000 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.silver,
      subTier: 2,
      target: 5000,
    ),
    _AchievementDef(
      id: 'savings_s3',
      title: 'Tutarlı',
      description: '10,000 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.silver,
      subTier: 3,
      target: 10000,
    ),
    // Gold
    _AchievementDef(
      id: 'savings_g1',
      title: 'Güçlü Birikim',
      description: '25,000 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.gold,
      subTier: 1,
      target: 25000,
    ),
    _AchievementDef(
      id: 'savings_g2',
      title: 'Finansal Farkındalık',
      description: '50,000 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.gold,
      subTier: 2,
      target: 50000,
    ),
    _AchievementDef(
      id: 'savings_g3',
      title: 'Sağlam Zemin',
      description: '100,000 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.gold,
      subTier: 3,
      target: 100000,
    ),
    // Platinum
    _AchievementDef(
      id: 'savings_p1',
      title: 'Uzun Vadeli Düşünce',
      description: '250,000 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.platinum,
      subTier: 1,
      target: 250000,
    ),
    _AchievementDef(
      id: 'savings_p2',
      title: 'Finansal Netlik',
      description: '500,000 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.platinum,
      subTier: 2,
      target: 500000,
    ),
    _AchievementDef(
      id: 'savings_p3',
      title: 'Büyük Resim',
      description: '1,000,000 TL kurtardın',
      category: AchievementCategory.savings,
      tier: AchievementTier.platinum,
      subTier: 3,
      target: 1000000,
    ),
  ];

  // ========== KARAR ROZETLERİ (10 adet) ==========
  static const _decisionAchievements = <_AchievementDef>[
    // Bronze
    _AchievementDef(
      id: 'decision_b1',
      title: 'İlk Karar',
      description: '3 kez vazgeçtin',
      category: AchievementCategory.decision,
      tier: AchievementTier.bronze,
      subTier: 1,
      target: 3,
    ),
    _AchievementDef(
      id: 'decision_b2',
      title: 'Direnç',
      description: '7 kez vazgeçtin',
      category: AchievementCategory.decision,
      tier: AchievementTier.bronze,
      subTier: 2,
      target: 7,
    ),
    _AchievementDef(
      id: 'decision_b3',
      title: 'Kontrol',
      description: '15 kez vazgeçtin',
      category: AchievementCategory.decision,
      tier: AchievementTier.bronze,
      subTier: 3,
      target: 15,
    ),
    // Silver
    _AchievementDef(
      id: 'decision_s1',
      title: 'Kararlılık',
      description: '30 kez vazgeçtin',
      category: AchievementCategory.decision,
      tier: AchievementTier.silver,
      subTier: 1,
      target: 30,
    ),
    _AchievementDef(
      id: 'decision_s2',
      title: 'Netlik',
      description: '60 kez vazgeçtin',
      category: AchievementCategory.decision,
      tier: AchievementTier.silver,
      subTier: 2,
      target: 60,
    ),
    _AchievementDef(
      id: 'decision_s3',
      title: 'Güçlü Seçimler',
      description: '100 kez vazgeçtin',
      category: AchievementCategory.decision,
      tier: AchievementTier.silver,
      subTier: 3,
      target: 100,
    ),
    // Gold
    _AchievementDef(
      id: 'decision_g1',
      title: 'İrade',
      description: '200 kez vazgeçtin',
      category: AchievementCategory.decision,
      tier: AchievementTier.gold,
      subTier: 1,
      target: 200,
    ),
    _AchievementDef(
      id: 'decision_g2',
      title: 'Soğukkanlılık',
      description: '400 kez vazgeçtin',
      category: AchievementCategory.decision,
      tier: AchievementTier.gold,
      subTier: 2,
      target: 400,
    ),
    _AchievementDef(
      id: 'decision_g3',
      title: 'Üst Seviye Kontrol',
      description: '700 kez vazgeçtin',
      category: AchievementCategory.decision,
      tier: AchievementTier.gold,
      subTier: 3,
      target: 700,
    ),
    // Platinum
    _AchievementDef(
      id: 'decision_p',
      title: 'Tam Hakimiyet',
      description: '1,000 kez vazgeçtin',
      category: AchievementCategory.decision,
      tier: AchievementTier.platinum,
      subTier: 1,
      target: 1000,
    ),
  ];

  // ========== KAYIT ROZETLERİ (10 adet) ==========
  static const _recordAchievements = <_AchievementDef>[
    // Bronze
    _AchievementDef(
      id: 'record_b1',
      title: 'Başladım',
      description: '5 harcama kaydı',
      category: AchievementCategory.record,
      tier: AchievementTier.bronze,
      subTier: 1,
      target: 5,
    ),
    _AchievementDef(
      id: 'record_b2',
      title: 'Takip Ediyorum',
      description: '15 harcama kaydı',
      category: AchievementCategory.record,
      tier: AchievementTier.bronze,
      subTier: 2,
      target: 15,
    ),
    _AchievementDef(
      id: 'record_b3',
      title: 'Düzen Oluştu',
      description: '30 harcama kaydı',
      category: AchievementCategory.record,
      tier: AchievementTier.bronze,
      subTier: 3,
      target: 30,
    ),
    // Silver
    _AchievementDef(
      id: 'record_s1',
      title: 'Detaylı Takip',
      description: '60 harcama kaydı',
      category: AchievementCategory.record,
      tier: AchievementTier.silver,
      subTier: 1,
      target: 60,
    ),
    _AchievementDef(
      id: 'record_s2',
      title: 'Analitik',
      description: '120 harcama kaydı',
      category: AchievementCategory.record,
      tier: AchievementTier.silver,
      subTier: 2,
      target: 120,
    ),
    _AchievementDef(
      id: 'record_s3',
      title: 'Sistemli',
      description: '200 harcama kaydı',
      category: AchievementCategory.record,
      tier: AchievementTier.silver,
      subTier: 3,
      target: 200,
    ),
    // Gold
    _AchievementDef(
      id: 'record_g1',
      title: 'Derinlik',
      description: '350 harcama kaydı',
      category: AchievementCategory.record,
      tier: AchievementTier.gold,
      subTier: 1,
      target: 350,
    ),
    _AchievementDef(
      id: 'record_g2',
      title: 'Uzmanlaşma',
      description: '600 harcama kaydı',
      category: AchievementCategory.record,
      tier: AchievementTier.gold,
      subTier: 2,
      target: 600,
    ),
    _AchievementDef(
      id: 'record_g3',
      title: 'Arşiv',
      description: '1,000 harcama kaydı',
      category: AchievementCategory.record,
      tier: AchievementTier.gold,
      subTier: 3,
      target: 1000,
    ),
    // Platinum
    _AchievementDef(
      id: 'record_p',
      title: 'Uzun Süreli Kayıt',
      description: '2,000 harcama kaydı',
      category: AchievementCategory.record,
      tier: AchievementTier.platinum,
      subTier: 1,
      target: 2000,
    ),
  ];

  // ========== GİZLİ ROZETLERİ (15 adet) ==========
  static const _hiddenAchievements = <_HiddenAchievementDef>[
    // KOLAY (4 adet)
    _HiddenAchievementDef(
      id: 'hidden_night',
      title: 'Gece Kaydı',
      description: '00:00-05:00 arası kayıt yap',
      difficulty: HiddenDifficulty.easy,
      checkType: HiddenCheckType.nightRecord,
    ),
    _HiddenAchievementDef(
      id: 'hidden_early',
      title: 'Erken Saat',
      description: '05:00-07:00 arası kayıt yap',
      difficulty: HiddenDifficulty.easy,
      checkType: HiddenCheckType.earlyRecord,
    ),
    _HiddenAchievementDef(
      id: 'hidden_weekend',
      title: 'Hafta Sonu Rutini',
      description: 'Cumartesi-Pazar 5 kayıt',
      difficulty: HiddenDifficulty.easy,
      checkType: HiddenCheckType.weekendRecords,
      target: 5,
    ),
    _HiddenAchievementDef(
      id: 'hidden_first_scan',
      title: 'İlk Tarama',
      description: 'İlk fiş OCR kullanımı',
      difficulty: HiddenDifficulty.easy,
      checkType: HiddenCheckType.firstOcrScan,
    ),
    _HiddenAchievementDef(
      id: 'curious_cat',
      title: 'Çok Meraklı',
      description: 'Gizli Easter Egg\'i buldun!',
      difficulty: HiddenDifficulty.easy,
      checkType: HiddenCheckType.manualUnlock,
    ),
    // ORTA (5 adet)
    _HiddenAchievementDef(
      id: 'hidden_balanced_week',
      title: 'Dengeli Hafta',
      description: '7 gün üst üste 0 "Aldım"',
      difficulty: HiddenDifficulty.medium,
      checkType: HiddenCheckType.balancedWeek,
      target: 7,
    ),
    _HiddenAchievementDef(
      id: 'hidden_all_categories',
      title: 'Kategori Tamamlama',
      description: 'Tüm 6 kategoride kayıt',
      difficulty: HiddenDifficulty.medium,
      checkType: HiddenCheckType.allCategories,
      target: 6,
    ),
    _HiddenAchievementDef(
      id: 'hidden_gold_equiv',
      title: 'Altın Denkliği',
      description: 'Kurtarılan para 1 gram altın değerinde',
      difficulty: HiddenDifficulty.medium,
      checkType: HiddenCheckType.goldEquivalent,
      target: 1,
    ),
    _HiddenAchievementDef(
      id: 'hidden_usd_equiv',
      title: 'Döviz Denkliği',
      description: 'Kurtarılan para 100\$ değerinde',
      difficulty: HiddenDifficulty.medium,
      checkType: HiddenCheckType.usdEquivalent,
      target: 100,
    ),
    _HiddenAchievementDef(
      id: 'hidden_subscriptions',
      title: 'Abonelik Kontrolü',
      description: '5 abonelik takibi',
      difficulty: HiddenDifficulty.medium,
      checkType: HiddenCheckType.subscriptionCount,
      target: 5,
    ),
    // ZOR (4 adet)
    _HiddenAchievementDef(
      id: 'hidden_no_spend_month',
      title: 'Harcamasız Ay',
      description: '1 ay boyunca 0 "Aldım"',
      difficulty: HiddenDifficulty.hard,
      checkType: HiddenCheckType.noSpendMonth,
      target: 30,
    ),
    _HiddenAchievementDef(
      id: 'hidden_gold_kg',
      title: 'Yüksek Değer Birikim',
      description: 'Kurtarılan para 1 kg altın değerinde',
      difficulty: HiddenDifficulty.hard,
      checkType: HiddenCheckType.goldKgEquivalent,
      target: 1000,
    ),
    _HiddenAchievementDef(
      id: 'hidden_usd_10k',
      title: 'Büyük Döviz Denkliği',
      description: 'Kurtarılan para 10,000\$ değerinde',
      difficulty: HiddenDifficulty.hard,
      checkType: HiddenCheckType.usd10kEquivalent,
      target: 10000,
    ),
    _HiddenAchievementDef(
      id: 'hidden_anniversary',
      title: 'Kullanım Yıldönümü',
      description: '365 gün kullanım',
      difficulty: HiddenDifficulty.hard,
      checkType: HiddenCheckType.usageAnniversary,
      target: 365,
    ),
    // EFSANEVİ (3 adet)
    _HiddenAchievementDef(
      id: 'hidden_early_adopter',
      title: 'İlk Nesil Kullanıcı',
      description: 'Uygulamayı 2 yıl önce indirdi',
      difficulty: HiddenDifficulty.legendary,
      checkType: HiddenCheckType.earlyAdopter,
      target: 730,
    ),
    _HiddenAchievementDef(
      id: 'hidden_ultimate',
      title: 'Uzun Vadeli Disiplin',
      description: '1,000,000 TL + 365 gün streak aynı anda',
      difficulty: HiddenDifficulty.legendary,
      checkType: HiddenCheckType.ultimateCombo,
    ),
    _HiddenAchievementDef(
      id: 'hidden_collector',
      title: 'Koleksiyoncu',
      description: 'Platinum hariç tüm rozetleri topladı',
      difficulty: HiddenDifficulty.legendary,
      checkType: HiddenCheckType.collector,
    ),
  ];

  /// Tüm rozetleri hesapla ve döndür
  Future<List<Achievement>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();

    // İlk kurulum tarihini kaydet
    await _ensureFirstInstallDate(prefs);

    // Verileri topla
    final streakData = await _streakService.getStreakData();
    final expenses = await _historyService.getRealExpenses();
    final stats = DecisionStats.fromExpenses(expenses);

    // Döviz ve altın kurlarını al
    double? usdRate;
    double? goldGramRate;
    try {
      final rates = await _currencyService.fetchRates();
      if (rates != null) {
        usdRate = rates.usdRate;
        goldGramRate = rates.goldRate;
      }
    } catch (_) {
      // Döviz kurları alınamazsa null kalır
    }

    // Abonelik sayısını al
    int subscriptionCount = 0;
    try {
      final subs = await _subscriptionService.getSubscriptions();
      subscriptionCount = subs.length;
    } catch (_) {}

    final achievements = <Achievement>[];

    // Normal rozetler
    final allDefs = [
      ..._streakAchievements,
      ..._savingsAchievements,
      ..._decisionAchievements,
      ..._recordAchievements,
    ];

    for (final def in allDefs) {
      final currentValue = _getCurrentValue(def, streakData, stats, expenses.length);
      final progress = (currentValue / def.target).clamp(0.0, 1.0);
      final isComplete = currentValue >= def.target;

      DateTime? unlockedAt;
      final savedDate = prefs.getString('$_keyPrefix${def.id}');

      if (savedDate != null) {
        unlockedAt = DateTime.tryParse(savedDate);
      } else if (isComplete) {
        unlockedAt = DateTime.now();
        await prefs.setString('$_keyPrefix${def.id}', unlockedAt.toIso8601String());
      }

      achievements.add(Achievement(
        id: def.id,
        title: def.title,
        description: def.description,
        category: def.category,
        tier: def.tier,
        subTier: def.subTier,
        progress: progress,
        currentValue: currentValue,
        targetValue: def.target,
        unlockedAt: unlockedAt,
      ));
    }

    // Gizli rozetler
    for (final def in _hiddenAchievements) {
      final checkResult = await _checkHiddenAchievement(
        def,
        prefs,
        expenses,
        stats,
        streakData,
        usdRate,
        goldGramRate,
        subscriptionCount,
        achievements,
      );

      DateTime? unlockedAt;
      final savedDate = prefs.getString('$_keyPrefix${def.id}');

      if (savedDate != null) {
        unlockedAt = DateTime.tryParse(savedDate);
      } else if (checkResult.isComplete) {
        unlockedAt = DateTime.now();
        await prefs.setString('$_keyPrefix${def.id}', unlockedAt.toIso8601String());
      }

      achievements.add(Achievement(
        id: def.id,
        title: def.title,
        description: def.description,
        category: AchievementCategory.hidden,
        tier: _difficultyToTier(def.difficulty),
        subTier: 1,
        progress: checkResult.progress,
        currentValue: checkResult.currentValue,
        targetValue: def.target ?? 1,
        unlockedAt: unlockedAt,
        isHidden: true,
        hiddenDifficulty: def.difficulty,
      ));
    }

    return achievements;
  }

  Future<void> _ensureFirstInstallDate(SharedPreferences prefs) async {
    if (prefs.getString(_keyFirstInstall) == null) {
      await prefs.setString(_keyFirstInstall, DateTime.now().toIso8601String());
    }
  }

  int _getCurrentValue(
    _AchievementDef def,
    StreakData streakData,
    DecisionStats stats,
    int totalExpenses,
  ) {
    switch (def.category) {
      case AchievementCategory.streak:
        return streakData.longestStreak;
      case AchievementCategory.savings:
        return stats.savedAmount.toInt();
      case AchievementCategory.decision:
        return stats.noCount;
      case AchievementCategory.record:
        return totalExpenses;
      case AchievementCategory.hidden:
        return 0;
    }
  }

  Future<_HiddenCheckResult> _checkHiddenAchievement(
    _HiddenAchievementDef def,
    SharedPreferences prefs,
    List<Expense> expenses,
    DecisionStats stats,
    StreakData streakData,
    double? usdRate,
    double? goldGramRate,
    int subscriptionCount,
    List<Achievement> currentAchievements,
  ) async {
    switch (def.checkType) {
      case HiddenCheckType.nightRecord:
        final hasNightRecord = expenses.any((e) {
          final hour = e.date.hour;
          return hour >= 0 && hour < 5;
        });
        return _HiddenCheckResult(
          isComplete: hasNightRecord,
          currentValue: hasNightRecord ? 1 : 0,
          progress: hasNightRecord ? 1.0 : 0.0,
        );

      case HiddenCheckType.earlyRecord:
        final hasEarlyRecord = expenses.any((e) {
          final hour = e.date.hour;
          return hour >= 5 && hour < 7;
        });
        return _HiddenCheckResult(
          isComplete: hasEarlyRecord,
          currentValue: hasEarlyRecord ? 1 : 0,
          progress: hasEarlyRecord ? 1.0 : 0.0,
        );

      case HiddenCheckType.weekendRecords:
        final weekendCount = expenses.where((e) {
          final weekday = e.date.weekday;
          return weekday == DateTime.saturday || weekday == DateTime.sunday;
        }).length;
        final target = def.target ?? 5;
        return _HiddenCheckResult(
          isComplete: weekendCount >= target,
          currentValue: weekendCount,
          progress: (weekendCount / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.firstOcrScan:
        final hasOcrScan = prefs.getBool('ocr_used') ?? false;
        return _HiddenCheckResult(
          isComplete: hasOcrScan,
          currentValue: hasOcrScan ? 1 : 0,
          progress: hasOcrScan ? 1.0 : 0.0,
        );

      case HiddenCheckType.balancedWeek:
        final consecutiveNoBuy = _getConsecutiveNoBuyDays(expenses);
        final target = def.target ?? 7;
        return _HiddenCheckResult(
          isComplete: consecutiveNoBuy >= target,
          currentValue: consecutiveNoBuy,
          progress: (consecutiveNoBuy / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.allCategories:
        final usedCategories = expenses.map((e) => e.category).toSet();
        final target = def.target ?? 6;
        return _HiddenCheckResult(
          isComplete: usedCategories.length >= target,
          currentValue: usedCategories.length,
          progress: (usedCategories.length / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.goldEquivalent:
        if (goldGramRate == null || goldGramRate <= 0) {
          return _HiddenCheckResult(isComplete: false, currentValue: 0, progress: 0.0);
        }
        final goldGrams = stats.savedAmount / goldGramRate;
        final target = def.target ?? 1;
        return _HiddenCheckResult(
          isComplete: goldGrams >= target,
          currentValue: goldGrams.toInt(),
          progress: (goldGrams / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.usdEquivalent:
        if (usdRate == null || usdRate <= 0) {
          return _HiddenCheckResult(isComplete: false, currentValue: 0, progress: 0.0);
        }
        final usdAmount = stats.savedAmount / usdRate;
        final target = def.target ?? 100;
        return _HiddenCheckResult(
          isComplete: usdAmount >= target,
          currentValue: usdAmount.toInt(),
          progress: (usdAmount / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.subscriptionCount:
        final target = def.target ?? 5;
        return _HiddenCheckResult(
          isComplete: subscriptionCount >= target,
          currentValue: subscriptionCount,
          progress: (subscriptionCount / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.noSpendMonth:
        final consecutiveNoBuy = _getConsecutiveNoBuyDays(expenses);
        final target = def.target ?? 30;
        return _HiddenCheckResult(
          isComplete: consecutiveNoBuy >= target,
          currentValue: consecutiveNoBuy,
          progress: (consecutiveNoBuy / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.goldKgEquivalent:
        if (goldGramRate == null || goldGramRate <= 0) {
          return _HiddenCheckResult(isComplete: false, currentValue: 0, progress: 0.0);
        }
        final goldGrams = stats.savedAmount / goldGramRate;
        final target = def.target ?? 1000;
        return _HiddenCheckResult(
          isComplete: goldGrams >= target,
          currentValue: goldGrams.toInt(),
          progress: (goldGrams / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.usd10kEquivalent:
        if (usdRate == null || usdRate <= 0) {
          return _HiddenCheckResult(isComplete: false, currentValue: 0, progress: 0.0);
        }
        final usdAmount = stats.savedAmount / usdRate;
        final target = def.target ?? 10000;
        return _HiddenCheckResult(
          isComplete: usdAmount >= target,
          currentValue: usdAmount.toInt(),
          progress: (usdAmount / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.usageAnniversary:
        final firstInstall = prefs.getString(_keyFirstInstall);
        if (firstInstall == null) {
          return _HiddenCheckResult(isComplete: false, currentValue: 0, progress: 0.0);
        }
        final installDate = DateTime.tryParse(firstInstall);
        if (installDate == null) {
          return _HiddenCheckResult(isComplete: false, currentValue: 0, progress: 0.0);
        }
        final daysSinceInstall = DateTime.now().difference(installDate).inDays;
        final target = def.target ?? 365;
        return _HiddenCheckResult(
          isComplete: daysSinceInstall >= target,
          currentValue: daysSinceInstall,
          progress: (daysSinceInstall / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.earlyAdopter:
        final firstInstall = prefs.getString(_keyFirstInstall);
        if (firstInstall == null) {
          return _HiddenCheckResult(isComplete: false, currentValue: 0, progress: 0.0);
        }
        final installDate = DateTime.tryParse(firstInstall);
        if (installDate == null) {
          return _HiddenCheckResult(isComplete: false, currentValue: 0, progress: 0.0);
        }
        final daysSinceInstall = DateTime.now().difference(installDate).inDays;
        final target = def.target ?? 730;
        return _HiddenCheckResult(
          isComplete: daysSinceInstall >= target,
          currentValue: daysSinceInstall,
          progress: (daysSinceInstall / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.ultimateCombo:
        final hasMillion = stats.savedAmount >= 1000000;
        final hasYearStreak = streakData.longestStreak >= 365;
        final isComplete = hasMillion && hasYearStreak;
        double progress = 0.0;
        if (hasMillion && hasYearStreak) {
          progress = 1.0;
        } else if (hasMillion || hasYearStreak) {
          progress = 0.5;
        }
        return _HiddenCheckResult(
          isComplete: isComplete,
          currentValue: isComplete ? 1 : 0,
          progress: progress,
        );

      case HiddenCheckType.collector:
        // Platinum ve hidden hariç tüm rozetleri kontrol et
        final nonPlatinumNonHidden = currentAchievements.where((a) =>
            a.tier != AchievementTier.platinum && !a.isHidden).toList();
        final unlockedCount = nonPlatinumNonHidden.where((a) => a.isUnlocked).length;
        final totalCount = nonPlatinumNonHidden.length;
        final isComplete = unlockedCount >= totalCount && totalCount > 0;
        return _HiddenCheckResult(
          isComplete: isComplete,
          currentValue: unlockedCount,
          progress: totalCount > 0 ? (unlockedCount / totalCount).clamp(0.0, 1.0) : 0.0,
        );

      case HiddenCheckType.manualUnlock:
        // Manuel olarak unlock edilen rozetler için SharedPreferences kontrol et
        final isUnlocked = prefs.getString('$_keyPrefix${def.id}') != null;
        return _HiddenCheckResult(
          isComplete: isUnlocked,
          currentValue: isUnlocked ? 1 : 0,
          progress: isUnlocked ? 1.0 : 0.0,
        );
    }
  }

  int _getConsecutiveNoBuyDays(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;

    // Tarihe göre grupla ve "Aldım" kararları filtrele
    final buyDates = expenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();

    if (buyDates.isEmpty) {
      // Hiç satın alma yoksa, ilk kayıttan bugüne kadar say
      final firstRecord = expenses
          .map((e) => e.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      return DateTime.now().difference(firstRecord).inDays;
    }

    // Bugünden geriye doğru ardışık "satın almasız" günleri say
    int consecutive = 0;
    var checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    while (!buyDates.contains(checkDate)) {
      consecutive++;
      checkDate = checkDate.subtract(const Duration(days: 1));
      // Makul bir üst sınır
      if (consecutive > 365) break;
    }

    return consecutive;
  }

  AchievementTier _difficultyToTier(HiddenDifficulty difficulty) {
    switch (difficulty) {
      case HiddenDifficulty.easy:
        return AchievementTier.bronze;
      case HiddenDifficulty.medium:
        return AchievementTier.silver;
      case HiddenDifficulty.hard:
        return AchievementTier.gold;
      case HiddenDifficulty.legendary:
        return AchievementTier.platinum;
    }
  }

  /// Toplam rozet sayısı
  int get totalCount =>
      _streakAchievements.length +
      _savingsAchievements.length +
      _decisionAchievements.length +
      _recordAchievements.length +
      _hiddenAchievements.length;

  /// Normal (gizli olmayan) rozet sayısı
  int get visibleCount =>
      _streakAchievements.length +
      _savingsAchievements.length +
      _decisionAchievements.length +
      _recordAchievements.length;

  /// Yeni kazanılan rozetleri kontrol et (bugün kazanılanlar)
  Future<List<Achievement>> getNewlyUnlockedAchievements() async {
    final achievements = await getAchievements();
    return achievements.where((a) => a.isNewlyUnlocked).toList();
  }

  /// OCR kullanıldığını işaretle
  Future<void> markOcrUsed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ocr_used', true);
  }

  /// Manuel olarak bir rozeti unlock et (Easter Egg gibi durumlar için)
  Future<bool> unlockManualAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$achievementId';

    // Zaten unlock edilmiş mi kontrol et
    if (prefs.getString(key) != null) {
      return false; // Zaten unlock edilmiş
    }

    // Unlock et
    await prefs.setString(key, DateTime.now().toIso8601String());
    return true;
  }

  /// Bir rozetin unlock durumunu kontrol et
  Future<bool> isAchievementUnlocked(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyPrefix$achievementId') != null;
  }

  /// Tüm rozet verilerini sıfırla (test için)
  Future<void> resetAllAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final allDefs = [
      ..._streakAchievements,
      ..._savingsAchievements,
      ..._decisionAchievements,
      ..._recordAchievements,
    ];
    for (final def in allDefs) {
      await prefs.remove('$_keyPrefix${def.id}');
    }
    for (final def in _hiddenAchievements) {
      await prefs.remove('$_keyPrefix${def.id}');
    }
    await prefs.remove('ocr_used');
  }
}

// ========== YARDIMCI SINIFLAR ==========

class _AchievementDef {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final AchievementTier tier;
  final int subTier;
  final int target;

  const _AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tier,
    required this.subTier,
    required this.target,
  });
}

enum HiddenCheckType {
  nightRecord,
  earlyRecord,
  weekendRecords,
  firstOcrScan,
  balancedWeek,
  allCategories,
  goldEquivalent,
  usdEquivalent,
  subscriptionCount,
  noSpendMonth,
  goldKgEquivalent,
  usd10kEquivalent,
  usageAnniversary,
  earlyAdopter,
  ultimateCombo,
  collector,
  manualUnlock,
}

class _HiddenAchievementDef {
  final String id;
  final String title;
  final String description;
  final HiddenDifficulty difficulty;
  final HiddenCheckType checkType;
  final int? target;

  const _HiddenAchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.checkType,
    this.target,
  });
}

class _HiddenCheckResult {
  final bool isComplete;
  final int currentValue;
  final double progress;

  const _HiddenCheckResult({
    required this.isComplete,
    required this.currentValue,
    required this.progress,
  });
}
