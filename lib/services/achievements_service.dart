import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/currency_provider.dart';
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

  // ========== ACHIEVEMENT DEFINITIONS (ID, category, tier, target only) ==========

  static const _streakAchievements = <_AchievementDef>[
    _AchievementDef(
      id: 'streak_b1',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
      subTier: 1,
      target: 3,
    ),
    _AchievementDef(
      id: 'streak_b2',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
      subTier: 2,
      target: 7,
    ),
    _AchievementDef(
      id: 'streak_b3',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
      subTier: 3,
      target: 14,
    ),
    _AchievementDef(
      id: 'streak_s1',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      subTier: 1,
      target: 30,
    ),
    _AchievementDef(
      id: 'streak_s2',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      subTier: 2,
      target: 60,
    ),
    _AchievementDef(
      id: 'streak_s3',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      subTier: 3,
      target: 90,
    ),
    _AchievementDef(
      id: 'streak_g1',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      subTier: 1,
      target: 150,
    ),
    _AchievementDef(
      id: 'streak_g2',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      subTier: 2,
      target: 250,
    ),
    _AchievementDef(
      id: 'streak_g3',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      subTier: 3,
      target: 365,
    ),
    _AchievementDef(
      id: 'streak_p',
      category: AchievementCategory.streak,
      tier: AchievementTier.platinum,
      subTier: 1,
      target: 730,
    ),
  ];

  static const _savingsAchievements = <_AchievementDef>[
    _AchievementDef(
      id: 'savings_b1',
      category: AchievementCategory.savings,
      tier: AchievementTier.bronze,
      subTier: 1,
      target: 250,
    ),
    _AchievementDef(
      id: 'savings_b2',
      category: AchievementCategory.savings,
      tier: AchievementTier.bronze,
      subTier: 2,
      target: 500,
    ),
    _AchievementDef(
      id: 'savings_b3',
      category: AchievementCategory.savings,
      tier: AchievementTier.bronze,
      subTier: 3,
      target: 1000,
    ),
    _AchievementDef(
      id: 'savings_s1',
      category: AchievementCategory.savings,
      tier: AchievementTier.silver,
      subTier: 1,
      target: 2500,
    ),
    _AchievementDef(
      id: 'savings_s2',
      category: AchievementCategory.savings,
      tier: AchievementTier.silver,
      subTier: 2,
      target: 5000,
    ),
    _AchievementDef(
      id: 'savings_s3',
      category: AchievementCategory.savings,
      tier: AchievementTier.silver,
      subTier: 3,
      target: 10000,
    ),
    _AchievementDef(
      id: 'savings_g1',
      category: AchievementCategory.savings,
      tier: AchievementTier.gold,
      subTier: 1,
      target: 25000,
    ),
    _AchievementDef(
      id: 'savings_g2',
      category: AchievementCategory.savings,
      tier: AchievementTier.gold,
      subTier: 2,
      target: 50000,
    ),
    _AchievementDef(
      id: 'savings_g3',
      category: AchievementCategory.savings,
      tier: AchievementTier.gold,
      subTier: 3,
      target: 100000,
    ),
    _AchievementDef(
      id: 'savings_p1',
      category: AchievementCategory.savings,
      tier: AchievementTier.platinum,
      subTier: 1,
      target: 250000,
    ),
    _AchievementDef(
      id: 'savings_p2',
      category: AchievementCategory.savings,
      tier: AchievementTier.platinum,
      subTier: 2,
      target: 500000,
    ),
    _AchievementDef(
      id: 'savings_p3',
      category: AchievementCategory.savings,
      tier: AchievementTier.platinum,
      subTier: 3,
      target: 1000000,
    ),
  ];

  static const _decisionAchievements = <_AchievementDef>[
    _AchievementDef(
      id: 'decision_b1',
      category: AchievementCategory.decision,
      tier: AchievementTier.bronze,
      subTier: 1,
      target: 3,
    ),
    _AchievementDef(
      id: 'decision_b2',
      category: AchievementCategory.decision,
      tier: AchievementTier.bronze,
      subTier: 2,
      target: 7,
    ),
    _AchievementDef(
      id: 'decision_b3',
      category: AchievementCategory.decision,
      tier: AchievementTier.bronze,
      subTier: 3,
      target: 15,
    ),
    _AchievementDef(
      id: 'decision_s1',
      category: AchievementCategory.decision,
      tier: AchievementTier.silver,
      subTier: 1,
      target: 30,
    ),
    _AchievementDef(
      id: 'decision_s2',
      category: AchievementCategory.decision,
      tier: AchievementTier.silver,
      subTier: 2,
      target: 60,
    ),
    _AchievementDef(
      id: 'decision_s3',
      category: AchievementCategory.decision,
      tier: AchievementTier.silver,
      subTier: 3,
      target: 100,
    ),
    _AchievementDef(
      id: 'decision_g1',
      category: AchievementCategory.decision,
      tier: AchievementTier.gold,
      subTier: 1,
      target: 200,
    ),
    _AchievementDef(
      id: 'decision_g2',
      category: AchievementCategory.decision,
      tier: AchievementTier.gold,
      subTier: 2,
      target: 400,
    ),
    _AchievementDef(
      id: 'decision_g3',
      category: AchievementCategory.decision,
      tier: AchievementTier.gold,
      subTier: 3,
      target: 700,
    ),
    _AchievementDef(
      id: 'decision_p',
      category: AchievementCategory.decision,
      tier: AchievementTier.platinum,
      subTier: 1,
      target: 1000,
    ),
  ];

  static const _recordAchievements = <_AchievementDef>[
    _AchievementDef(
      id: 'record_b1',
      category: AchievementCategory.record,
      tier: AchievementTier.bronze,
      subTier: 1,
      target: 5,
    ),
    _AchievementDef(
      id: 'record_b2',
      category: AchievementCategory.record,
      tier: AchievementTier.bronze,
      subTier: 2,
      target: 15,
    ),
    _AchievementDef(
      id: 'record_b3',
      category: AchievementCategory.record,
      tier: AchievementTier.bronze,
      subTier: 3,
      target: 30,
    ),
    _AchievementDef(
      id: 'record_s1',
      category: AchievementCategory.record,
      tier: AchievementTier.silver,
      subTier: 1,
      target: 60,
    ),
    _AchievementDef(
      id: 'record_s2',
      category: AchievementCategory.record,
      tier: AchievementTier.silver,
      subTier: 2,
      target: 120,
    ),
    _AchievementDef(
      id: 'record_s3',
      category: AchievementCategory.record,
      tier: AchievementTier.silver,
      subTier: 3,
      target: 200,
    ),
    _AchievementDef(
      id: 'record_g1',
      category: AchievementCategory.record,
      tier: AchievementTier.gold,
      subTier: 1,
      target: 350,
    ),
    _AchievementDef(
      id: 'record_g2',
      category: AchievementCategory.record,
      tier: AchievementTier.gold,
      subTier: 2,
      target: 600,
    ),
    _AchievementDef(
      id: 'record_g3',
      category: AchievementCategory.record,
      tier: AchievementTier.gold,
      subTier: 3,
      target: 1000,
    ),
    _AchievementDef(
      id: 'record_p',
      category: AchievementCategory.record,
      tier: AchievementTier.platinum,
      subTier: 1,
      target: 2000,
    ),
  ];

  static const _hiddenAchievements = <_HiddenAchievementDef>[
    // EASY
    _HiddenAchievementDef(
      id: 'hidden_night',
      difficulty: HiddenDifficulty.easy,
      checkType: HiddenCheckType.nightRecord,
    ),
    _HiddenAchievementDef(
      id: 'hidden_early',
      difficulty: HiddenDifficulty.easy,
      checkType: HiddenCheckType.earlyRecord,
    ),
    _HiddenAchievementDef(
      id: 'hidden_weekend',
      difficulty: HiddenDifficulty.easy,
      checkType: HiddenCheckType.weekendRecords,
      target: 5,
    ),
    _HiddenAchievementDef(
      id: 'hidden_first_scan',
      difficulty: HiddenDifficulty.easy,
      checkType: HiddenCheckType.firstOcrScan,
    ),
    _HiddenAchievementDef(
      id: 'curious_cat',
      difficulty: HiddenDifficulty.easy,
      checkType: HiddenCheckType.manualUnlock,
    ),
    // MEDIUM
    _HiddenAchievementDef(
      id: 'hidden_balanced_week',
      difficulty: HiddenDifficulty.medium,
      checkType: HiddenCheckType.balancedWeek,
      target: 7,
    ),
    _HiddenAchievementDef(
      id: 'hidden_all_categories',
      difficulty: HiddenDifficulty.medium,
      checkType: HiddenCheckType.allCategories,
      target: 6,
    ),
    _HiddenAchievementDef(
      id: 'hidden_gold_equiv',
      difficulty: HiddenDifficulty.medium,
      checkType: HiddenCheckType.goldEquivalent,
      target: 1,
    ),
    _HiddenAchievementDef(
      id: 'hidden_usd_equiv',
      difficulty: HiddenDifficulty.medium,
      checkType: HiddenCheckType.usdEquivalent,
      target: 100,
    ),
    _HiddenAchievementDef(
      id: 'hidden_subscriptions',
      difficulty: HiddenDifficulty.medium,
      checkType: HiddenCheckType.subscriptionCount,
      target: 5,
    ),
    // HARD
    _HiddenAchievementDef(
      id: 'hidden_no_spend_month',
      difficulty: HiddenDifficulty.hard,
      checkType: HiddenCheckType.noSpendMonth,
      target: 30,
    ),
    _HiddenAchievementDef(
      id: 'hidden_gold_kg',
      difficulty: HiddenDifficulty.hard,
      checkType: HiddenCheckType.goldKgEquivalent,
      target: 1000,
    ),
    _HiddenAchievementDef(
      id: 'hidden_usd_10k',
      difficulty: HiddenDifficulty.hard,
      checkType: HiddenCheckType.usd10kEquivalent,
      target: 10000,
    ),
    _HiddenAchievementDef(
      id: 'hidden_anniversary',
      difficulty: HiddenDifficulty.hard,
      checkType: HiddenCheckType.usageAnniversary,
      target: 365,
    ),
    // LEGENDARY
    _HiddenAchievementDef(
      id: 'hidden_early_adopter',
      difficulty: HiddenDifficulty.legendary,
      checkType: HiddenCheckType.earlyAdopter,
      target: 730,
    ),
    _HiddenAchievementDef(
      id: 'hidden_ultimate',
      difficulty: HiddenDifficulty.legendary,
      checkType: HiddenCheckType.ultimateCombo,
    ),
    _HiddenAchievementDef(
      id: 'hidden_collector',
      difficulty: HiddenDifficulty.legendary,
      checkType: HiddenCheckType.collector,
    ),
  ];

  // ========== LOCALIZATION HELPERS ==========

  String _getAchievementTitle(AppLocalizations l10n, String id) {
    return switch (id) {
      // Streak
      'streak_b1' => l10n.achievementStreakB1Title,
      'streak_b2' => l10n.achievementStreakB2Title,
      'streak_b3' => l10n.achievementStreakB3Title,
      'streak_s1' => l10n.achievementStreakS1Title,
      'streak_s2' => l10n.achievementStreakS2Title,
      'streak_s3' => l10n.achievementStreakS3Title,
      'streak_g1' => l10n.achievementStreakG1Title,
      'streak_g2' => l10n.achievementStreakG2Title,
      'streak_g3' => l10n.achievementStreakG3Title,
      'streak_p' => l10n.achievementStreakPTitle,
      // Savings
      'savings_b1' => l10n.achievementSavingsB1Title,
      'savings_b2' => l10n.achievementSavingsB2Title,
      'savings_b3' => l10n.achievementSavingsB3Title,
      'savings_s1' => l10n.achievementSavingsS1Title,
      'savings_s2' => l10n.achievementSavingsS2Title,
      'savings_s3' => l10n.achievementSavingsS3Title,
      'savings_g1' => l10n.achievementSavingsG1Title,
      'savings_g2' => l10n.achievementSavingsG2Title,
      'savings_g3' => l10n.achievementSavingsG3Title,
      'savings_p1' => l10n.achievementSavingsP1Title,
      'savings_p2' => l10n.achievementSavingsP2Title,
      'savings_p3' => l10n.achievementSavingsP3Title,
      // Decision
      'decision_b1' => l10n.achievementDecisionB1Title,
      'decision_b2' => l10n.achievementDecisionB2Title,
      'decision_b3' => l10n.achievementDecisionB3Title,
      'decision_s1' => l10n.achievementDecisionS1Title,
      'decision_s2' => l10n.achievementDecisionS2Title,
      'decision_s3' => l10n.achievementDecisionS3Title,
      'decision_g1' => l10n.achievementDecisionG1Title,
      'decision_g2' => l10n.achievementDecisionG2Title,
      'decision_g3' => l10n.achievementDecisionG3Title,
      'decision_p' => l10n.achievementDecisionPTitle,
      // Record
      'record_b1' => l10n.achievementRecordB1Title,
      'record_b2' => l10n.achievementRecordB2Title,
      'record_b3' => l10n.achievementRecordB3Title,
      'record_s1' => l10n.achievementRecordS1Title,
      'record_s2' => l10n.achievementRecordS2Title,
      'record_s3' => l10n.achievementRecordS3Title,
      'record_g1' => l10n.achievementRecordG1Title,
      'record_g2' => l10n.achievementRecordG2Title,
      'record_g3' => l10n.achievementRecordG3Title,
      'record_p' => l10n.achievementRecordPTitle,
      // Hidden
      'hidden_night' => l10n.achievementHiddenNightTitle,
      'hidden_early' => l10n.achievementHiddenEarlyTitle,
      'hidden_weekend' => l10n.achievementHiddenWeekendTitle,
      'hidden_first_scan' => l10n.achievementHiddenOcrTitle,
      'curious_cat' => l10n.achievementHiddenCuriousCatTitle,
      'hidden_balanced_week' => l10n.achievementHiddenBalancedTitle,
      'hidden_all_categories' => l10n.achievementHiddenCategoriesTitle,
      'hidden_gold_equiv' => l10n.achievementHiddenGoldTitle,
      'hidden_usd_equiv' => l10n.achievementHiddenUsdTitle,
      'hidden_subscriptions' => l10n.achievementHiddenSubsTitle,
      'hidden_no_spend_month' => l10n.achievementHiddenNoSpendTitle,
      'hidden_gold_kg' => l10n.achievementHiddenGoldKgTitle,
      'hidden_usd_10k' => l10n.achievementHiddenUsd10kTitle,
      'hidden_anniversary' => l10n.achievementHiddenAnniversaryTitle,
      'hidden_early_adopter' => l10n.achievementHiddenEarlyAdopterTitle,
      'hidden_ultimate' => l10n.achievementHiddenUltimateTitle,
      'hidden_collector' => l10n.achievementHiddenCollectorTitle,
      _ => id,
    };
  }

  String _getAchievementDescription(AppLocalizations l10n, String id) {
    return switch (id) {
      // Streak
      'streak_b1' => l10n.achievementStreakB1Desc,
      'streak_b2' => l10n.achievementStreakB2Desc,
      'streak_b3' => l10n.achievementStreakB3Desc,
      'streak_s1' => l10n.achievementStreakS1Desc,
      'streak_s2' => l10n.achievementStreakS2Desc,
      'streak_s3' => l10n.achievementStreakS3Desc,
      'streak_g1' => l10n.achievementStreakG1Desc,
      'streak_g2' => l10n.achievementStreakG2Desc,
      'streak_g3' => l10n.achievementStreakG3Desc,
      'streak_p' => l10n.achievementStreakPDesc,
      // Savings
      'savings_b1' => l10n.achievementSavingsB1Desc,
      'savings_b2' => l10n.achievementSavingsB2Desc,
      'savings_b3' => l10n.achievementSavingsB3Desc,
      'savings_s1' => l10n.achievementSavingsS1Desc,
      'savings_s2' => l10n.achievementSavingsS2Desc,
      'savings_s3' => l10n.achievementSavingsS3Desc,
      'savings_g1' => l10n.achievementSavingsG1Desc,
      'savings_g2' => l10n.achievementSavingsG2Desc,
      'savings_g3' => l10n.achievementSavingsG3Desc,
      'savings_p1' => l10n.achievementSavingsP1Desc,
      'savings_p2' => l10n.achievementSavingsP2Desc,
      'savings_p3' => l10n.achievementSavingsP3Desc,
      // Decision
      'decision_b1' => l10n.achievementDecisionB1Desc,
      'decision_b2' => l10n.achievementDecisionB2Desc,
      'decision_b3' => l10n.achievementDecisionB3Desc,
      'decision_s1' => l10n.achievementDecisionS1Desc,
      'decision_s2' => l10n.achievementDecisionS2Desc,
      'decision_s3' => l10n.achievementDecisionS3Desc,
      'decision_g1' => l10n.achievementDecisionG1Desc,
      'decision_g2' => l10n.achievementDecisionG2Desc,
      'decision_g3' => l10n.achievementDecisionG3Desc,
      'decision_p' => l10n.achievementDecisionPDesc,
      // Record
      'record_b1' => l10n.achievementRecordB1Desc,
      'record_b2' => l10n.achievementRecordB2Desc,
      'record_b3' => l10n.achievementRecordB3Desc,
      'record_s1' => l10n.achievementRecordS1Desc,
      'record_s2' => l10n.achievementRecordS2Desc,
      'record_s3' => l10n.achievementRecordS3Desc,
      'record_g1' => l10n.achievementRecordG1Desc,
      'record_g2' => l10n.achievementRecordG2Desc,
      'record_g3' => l10n.achievementRecordG3Desc,
      'record_p' => l10n.achievementRecordPDesc,
      // Hidden
      'hidden_night' => l10n.achievementHiddenNightDesc,
      'hidden_early' => l10n.achievementHiddenEarlyDesc,
      'hidden_weekend' => l10n.achievementHiddenWeekendDesc,
      'hidden_first_scan' => l10n.achievementHiddenOcrDesc,
      'curious_cat' => l10n.achievementHiddenCuriousCatDesc,
      'hidden_balanced_week' => l10n.achievementHiddenBalancedDesc,
      'hidden_all_categories' => l10n.achievementHiddenCategoriesDesc,
      'hidden_gold_equiv' => l10n.achievementHiddenGoldDesc,
      'hidden_usd_equiv' => l10n.achievementHiddenUsdDesc,
      'hidden_subscriptions' => l10n.achievementHiddenSubsDesc,
      'hidden_no_spend_month' => l10n.achievementHiddenNoSpendDesc,
      'hidden_gold_kg' => l10n.achievementHiddenGoldKgDesc,
      'hidden_usd_10k' => l10n.achievementHiddenUsd10kDesc,
      'hidden_anniversary' => l10n.achievementHiddenAnniversaryDesc,
      'hidden_early_adopter' => l10n.achievementHiddenEarlyAdopterDesc,
      'hidden_ultimate' => l10n.achievementHiddenUltimateDesc,
      'hidden_collector' => l10n.achievementHiddenCollectorDesc,
      _ => id,
    };
  }

  /// Calculate and return all achievements
  Future<List<Achievement>> getAchievements(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final prefs = await SharedPreferences.getInstance();

    // Save first install date
    await _ensureFirstInstallDate(prefs);

    // Collect data
    final streakData = await _streakService.getStreakData();
    final expenses = await _historyService.getRealExpenses();
    final stats = DecisionStats.fromExpenses(expenses);

    // Convert savedAmount to TRY for threshold comparison
    // Savings thresholds are defined in TRY, so we need amounts in TRY
    final currencyProvider = context.read<CurrencyProvider>();
    final savedAmountInTRY = currencyProvider.convertToTRY(stats.savedAmount);

    // Get exchange rates
    double? usdRate;
    double? goldGramRate;
    try {
      final rates = await _currencyService.fetchRates();
      if (rates != null) {
        usdRate = rates.usdRate;
        goldGramRate = rates.goldRate;
      }
    } catch (_) {}

    // Get subscription count
    int subscriptionCount = 0;
    try {
      final subs = await _subscriptionService.getSubscriptions();
      subscriptionCount = subs.length;
    } catch (_) {}

    final achievements = <Achievement>[];

    // Regular achievements
    final allDefs = [
      ..._streakAchievements,
      ..._savingsAchievements,
      ..._decisionAchievements,
      ..._recordAchievements,
    ];

    for (final def in allDefs) {
      final currentValue = _getCurrentValue(
        def,
        streakData,
        stats,
        expenses.length,
        savedAmountInTRY: savedAmountInTRY,
      );
      final progress = (currentValue / def.target).clamp(0.0, 1.0);
      final isComplete = currentValue >= def.target;

      DateTime? unlockedAt;
      final savedDate = prefs.getString('$_keyPrefix${def.id}');

      if (savedDate != null) {
        unlockedAt = DateTime.tryParse(savedDate);
      } else if (isComplete) {
        unlockedAt = DateTime.now();
        await prefs.setString(
          '$_keyPrefix${def.id}',
          unlockedAt.toIso8601String(),
        );
      }

      achievements.add(
        Achievement(
          id: def.id,
          title: _getAchievementTitle(l10n, def.id),
          description: _getAchievementDescription(l10n, def.id),
          category: def.category,
          tier: def.tier,
          subTier: def.subTier,
          progress: progress,
          currentValue: currentValue,
          targetValue: def.target,
          unlockedAt: unlockedAt,
        ),
      );
    }

    // Hidden achievements
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
        savedAmountInTRY: savedAmountInTRY,
      );

      DateTime? unlockedAt;
      final savedDate = prefs.getString('$_keyPrefix${def.id}');

      if (savedDate != null) {
        unlockedAt = DateTime.tryParse(savedDate);
      } else if (checkResult.isComplete) {
        unlockedAt = DateTime.now();
        await prefs.setString(
          '$_keyPrefix${def.id}',
          unlockedAt.toIso8601String(),
        );
      }

      achievements.add(
        Achievement(
          id: def.id,
          title: _getAchievementTitle(l10n, def.id),
          description: _getAchievementDescription(l10n, def.id),
          category: AchievementCategory.hidden,
          tier: _difficultyToTier(def.difficulty),
          subTier: 1,
          progress: checkResult.progress,
          currentValue: checkResult.currentValue,
          targetValue: def.target ?? 1,
          unlockedAt: unlockedAt,
          isHidden: true,
          hiddenDifficulty: def.difficulty,
        ),
      );
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
    int totalExpenses, {
    required double savedAmountInTRY,
  }) {
    switch (def.category) {
      case AchievementCategory.streak:
        return streakData.longestStreak;
      case AchievementCategory.savings:
        // Thresholds are in TRY, so use TRY-converted amount
        return savedAmountInTRY.toInt();
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
    List<Achievement> currentAchievements, {
    required double savedAmountInTRY,
  }) async {
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
          return _HiddenCheckResult(
            isComplete: false,
            currentValue: 0,
            progress: 0.0,
          );
        }
        // goldGramRate is TRY per gram, so use TRY-converted amount
        final goldGrams = savedAmountInTRY / goldGramRate;
        final target = def.target ?? 1;
        return _HiddenCheckResult(
          isComplete: goldGrams >= target,
          currentValue: goldGrams.toInt(),
          progress: (goldGrams / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.usdEquivalent:
        if (usdRate == null || usdRate <= 0) {
          return _HiddenCheckResult(
            isComplete: false,
            currentValue: 0,
            progress: 0.0,
          );
        }
        // usdRate is TRY per USD, so use TRY-converted amount
        final usdAmount = savedAmountInTRY / usdRate;
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
          return _HiddenCheckResult(
            isComplete: false,
            currentValue: 0,
            progress: 0.0,
          );
        }
        // goldGramRate is TRY per gram, so use TRY-converted amount
        final goldGramsKg = savedAmountInTRY / goldGramRate;
        final target = def.target ?? 1000;
        return _HiddenCheckResult(
          isComplete: goldGramsKg >= target,
          currentValue: goldGramsKg.toInt(),
          progress: (goldGramsKg / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.usd10kEquivalent:
        if (usdRate == null || usdRate <= 0) {
          return _HiddenCheckResult(
            isComplete: false,
            currentValue: 0,
            progress: 0.0,
          );
        }
        // usdRate is TRY per USD, so use TRY-converted amount
        final usdAmount10k = savedAmountInTRY / usdRate;
        final target = def.target ?? 10000;
        return _HiddenCheckResult(
          isComplete: usdAmount10k >= target,
          currentValue: usdAmount10k.toInt(),
          progress: (usdAmount10k / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.usageAnniversary:
        final firstInstall = prefs.getString(_keyFirstInstall);
        if (firstInstall == null) {
          return _HiddenCheckResult(
            isComplete: false,
            currentValue: 0,
            progress: 0.0,
          );
        }
        final installDate = DateTime.tryParse(firstInstall);
        if (installDate == null) {
          return _HiddenCheckResult(
            isComplete: false,
            currentValue: 0,
            progress: 0.0,
          );
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
          return _HiddenCheckResult(
            isComplete: false,
            currentValue: 0,
            progress: 0.0,
          );
        }
        final installDate = DateTime.tryParse(firstInstall);
        if (installDate == null) {
          return _HiddenCheckResult(
            isComplete: false,
            currentValue: 0,
            progress: 0.0,
          );
        }
        final daysSinceInstall = DateTime.now().difference(installDate).inDays;
        final target = def.target ?? 730;
        return _HiddenCheckResult(
          isComplete: daysSinceInstall >= target,
          currentValue: daysSinceInstall,
          progress: (daysSinceInstall / target).clamp(0.0, 1.0),
        );

      case HiddenCheckType.ultimateCombo:
        // 1,000,000 TRY threshold - compare against TRY-converted amount
        final hasMillion = savedAmountInTRY >= 1000000;
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
        final nonPlatinumNonHidden = currentAchievements
            .where((a) => a.tier != AchievementTier.platinum && !a.isHidden)
            .toList();
        final unlockedCount = nonPlatinumNonHidden
            .where((a) => a.isUnlocked)
            .length;
        final totalCount = nonPlatinumNonHidden.length;
        final isComplete = unlockedCount >= totalCount && totalCount > 0;
        return _HiddenCheckResult(
          isComplete: isComplete,
          currentValue: unlockedCount,
          progress: totalCount > 0
              ? (unlockedCount / totalCount).clamp(0.0, 1.0)
              : 0.0,
        );

      case HiddenCheckType.manualUnlock:
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

    final buyDates = expenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();

    if (buyDates.isEmpty) {
      final firstRecord = expenses
          .map((e) => e.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      return DateTime.now().difference(firstRecord).inDays;
    }

    int consecutive = 0;
    var checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    while (!buyDates.contains(checkDate)) {
      consecutive++;
      checkDate = checkDate.subtract(const Duration(days: 1));
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

  /// Total achievement count
  int get totalCount =>
      _streakAchievements.length +
      _savingsAchievements.length +
      _decisionAchievements.length +
      _recordAchievements.length +
      _hiddenAchievements.length;

  /// Visible (non-hidden) achievement count
  int get visibleCount =>
      _streakAchievements.length +
      _savingsAchievements.length +
      _decisionAchievements.length +
      _recordAchievements.length;

  /// Check for newly unlocked achievements (unlocked today)
  Future<List<Achievement>> getNewlyUnlockedAchievements(
    BuildContext context,
  ) async {
    final achievements = await getAchievements(context);
    return achievements.where((a) => a.isNewlyUnlocked).toList();
  }

  /// Mark OCR as used
  Future<void> markOcrUsed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ocr_used', true);
  }

  /// Manually unlock an achievement (for Easter Eggs, etc.)
  Future<bool> unlockManualAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$achievementId';

    if (prefs.getString(key) != null) {
      return false; // Already unlocked
    }

    await prefs.setString(key, DateTime.now().toIso8601String());
    return true;
  }

  /// Check if an achievement is unlocked
  Future<bool> isAchievementUnlocked(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyPrefix$achievementId') != null;
  }

  /// Reset all achievement data (for testing)
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

// ========== HELPER CLASSES ==========

class _AchievementDef {
  final String id;
  final AchievementCategory category;
  final AchievementTier tier;
  final int subTier;
  final int target;

  const _AchievementDef({
    required this.id,
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
  final HiddenDifficulty difficulty;
  final HiddenCheckType checkType;
  final int? target;

  const _HiddenAchievementDef({
    required this.id,
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
