import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/achievement.dart';

/// Utility class for achievement localization
class AchievementUtils {
  /// Get localized tier label
  static String getTierLabel(BuildContext context, AchievementTier tier) {
    final l10n = AppLocalizations.of(context);

    switch (tier) {
      case AchievementTier.bronze:
        return l10n.tierBronze;
      case AchievementTier.silver:
        return l10n.tierSilver;
      case AchievementTier.gold:
        return l10n.tierGold;
      case AchievementTier.platinum:
        return l10n.tierPlatinum;
    }
  }

  /// Get localized category label
  static String getCategoryLabel(BuildContext context, AchievementCategory category) {
    final l10n = AppLocalizations.of(context);

    switch (category) {
      case AchievementCategory.streak:
        return l10n.achievementCategoryStreak;
      case AchievementCategory.savings:
        return l10n.achievementCategorySavings;
      case AchievementCategory.decision:
        return l10n.achievementCategoryDecision;
      case AchievementCategory.record:
        return l10n.achievementCategoryRecord;
      case AchievementCategory.hidden:
        return l10n.achievementCategoryHidden;
    }
  }

  /// Get localized difficulty label
  static String getDifficultyLabel(BuildContext context, HiddenDifficulty difficulty) {
    final l10n = AppLocalizations.of(context);

    switch (difficulty) {
      case HiddenDifficulty.easy:
        return l10n.difficultyEasy;
      case HiddenDifficulty.medium:
        return l10n.difficultyMedium;
      case HiddenDifficulty.hard:
        return l10n.difficultyHard;
      case HiddenDifficulty.legendary:
        return l10n.difficultyLegendary;
    }
  }

  /// Get localized achievement title by ID
  static String getTitle(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context);

    switch (id) {
      // Streak achievements
      case 'streak_b1':
        return l10n.achievementStreakB1Title;
      case 'streak_b2':
        return l10n.achievementStreakB2Title;
      case 'streak_b3':
        return l10n.achievementStreakB3Title;
      case 'streak_s1':
        return l10n.achievementStreakS1Title;
      case 'streak_s2':
        return l10n.achievementStreakS2Title;
      case 'streak_s3':
        return l10n.achievementStreakS3Title;
      case 'streak_g1':
        return l10n.achievementStreakG1Title;
      case 'streak_g2':
        return l10n.achievementStreakG2Title;
      case 'streak_g3':
        return l10n.achievementStreakG3Title;
      case 'streak_p':
        return l10n.achievementStreakPTitle;
      // Savings achievements
      case 'savings_b1':
        return l10n.achievementSavingsB1Title;
      case 'savings_b2':
        return l10n.achievementSavingsB2Title;
      case 'savings_b3':
        return l10n.achievementSavingsB3Title;
      case 'savings_s1':
        return l10n.achievementSavingsS1Title;
      case 'savings_s2':
        return l10n.achievementSavingsS2Title;
      case 'savings_s3':
        return l10n.achievementSavingsS3Title;
      case 'savings_g1':
        return l10n.achievementSavingsG1Title;
      case 'savings_g2':
        return l10n.achievementSavingsG2Title;
      case 'savings_g3':
        return l10n.achievementSavingsG3Title;
      case 'savings_p1':
        return l10n.achievementSavingsP1Title;
      case 'savings_p2':
        return l10n.achievementSavingsP2Title;
      case 'savings_p3':
        return l10n.achievementSavingsP3Title;
      // Decision achievements
      case 'decision_b1':
        return l10n.achievementDecisionB1Title;
      case 'decision_b2':
        return l10n.achievementDecisionB2Title;
      case 'decision_b3':
        return l10n.achievementDecisionB3Title;
      case 'decision_s1':
        return l10n.achievementDecisionS1Title;
      case 'decision_s2':
        return l10n.achievementDecisionS2Title;
      case 'decision_s3':
        return l10n.achievementDecisionS3Title;
      case 'decision_g1':
        return l10n.achievementDecisionG1Title;
      case 'decision_g2':
        return l10n.achievementDecisionG2Title;
      case 'decision_g3':
        return l10n.achievementDecisionG3Title;
      case 'decision_p':
        return l10n.achievementDecisionPTitle;
      // Record achievements
      case 'record_b1':
        return l10n.achievementRecordB1Title;
      case 'record_b2':
        return l10n.achievementRecordB2Title;
      case 'record_b3':
        return l10n.achievementRecordB3Title;
      case 'record_s1':
        return l10n.achievementRecordS1Title;
      case 'record_s2':
        return l10n.achievementRecordS2Title;
      case 'record_s3':
        return l10n.achievementRecordS3Title;
      case 'record_g1':
        return l10n.achievementRecordG1Title;
      case 'record_g2':
        return l10n.achievementRecordG2Title;
      case 'record_g3':
        return l10n.achievementRecordG3Title;
      case 'record_p':
        return l10n.achievementRecordPTitle;
      // Hidden achievements
      case 'hidden_night':
        return l10n.achievementHiddenNightTitle;
      case 'hidden_early':
        return l10n.achievementHiddenEarlyTitle;
      case 'hidden_weekend':
        return l10n.achievementHiddenWeekendTitle;
      case 'hidden_first_scan':
        return l10n.achievementHiddenOcrTitle;
      case 'hidden_balanced_week':
        return l10n.achievementHiddenBalancedTitle;
      case 'hidden_all_categories':
        return l10n.achievementHiddenCategoriesTitle;
      case 'hidden_gold_equiv':
        return l10n.achievementHiddenGoldTitle;
      case 'hidden_usd_equiv':
        return l10n.achievementHiddenUsdTitle;
      case 'hidden_subscriptions':
        return l10n.achievementHiddenSubsTitle;
      case 'hidden_no_spend_month':
        return l10n.achievementHiddenNoSpendTitle;
      case 'hidden_gold_kg':
        return l10n.achievementHiddenGoldKgTitle;
      case 'hidden_usd_10k':
        return l10n.achievementHiddenUsd10kTitle;
      case 'hidden_anniversary':
        return l10n.achievementHiddenAnniversaryTitle;
      case 'hidden_early_adopter':
        return l10n.achievementHiddenEarlyAdopterTitle;
      case 'hidden_ultimate':
        return l10n.achievementHiddenUltimateTitle;
      case 'hidden_collector':
        return l10n.achievementHiddenCollectorTitle;
      case 'curious_cat':
        return l10n.curiousCatTitle;
      default:
        return id;
    }
  }

  /// Get localized achievement description by ID
  static String getDescription(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context);

    switch (id) {
      // Streak achievements
      case 'streak_b1':
        return l10n.achievementStreakB1Desc;
      case 'streak_b2':
        return l10n.achievementStreakB2Desc;
      case 'streak_b3':
        return l10n.achievementStreakB3Desc;
      case 'streak_s1':
        return l10n.achievementStreakS1Desc;
      case 'streak_s2':
        return l10n.achievementStreakS2Desc;
      case 'streak_s3':
        return l10n.achievementStreakS3Desc;
      case 'streak_g1':
        return l10n.achievementStreakG1Desc;
      case 'streak_g2':
        return l10n.achievementStreakG2Desc;
      case 'streak_g3':
        return l10n.achievementStreakG3Desc;
      case 'streak_p':
        return l10n.achievementStreakPDesc;
      // Savings achievements
      case 'savings_b1':
        return l10n.achievementSavingsB1Desc;
      case 'savings_b2':
        return l10n.achievementSavingsB2Desc;
      case 'savings_b3':
        return l10n.achievementSavingsB3Desc;
      case 'savings_s1':
        return l10n.achievementSavingsS1Desc;
      case 'savings_s2':
        return l10n.achievementSavingsS2Desc;
      case 'savings_s3':
        return l10n.achievementSavingsS3Desc;
      case 'savings_g1':
        return l10n.achievementSavingsG1Desc;
      case 'savings_g2':
        return l10n.achievementSavingsG2Desc;
      case 'savings_g3':
        return l10n.achievementSavingsG3Desc;
      case 'savings_p1':
        return l10n.achievementSavingsP1Desc;
      case 'savings_p2':
        return l10n.achievementSavingsP2Desc;
      case 'savings_p3':
        return l10n.achievementSavingsP3Desc;
      // Decision achievements
      case 'decision_b1':
        return l10n.achievementDecisionB1Desc;
      case 'decision_b2':
        return l10n.achievementDecisionB2Desc;
      case 'decision_b3':
        return l10n.achievementDecisionB3Desc;
      case 'decision_s1':
        return l10n.achievementDecisionS1Desc;
      case 'decision_s2':
        return l10n.achievementDecisionS2Desc;
      case 'decision_s3':
        return l10n.achievementDecisionS3Desc;
      case 'decision_g1':
        return l10n.achievementDecisionG1Desc;
      case 'decision_g2':
        return l10n.achievementDecisionG2Desc;
      case 'decision_g3':
        return l10n.achievementDecisionG3Desc;
      case 'decision_p':
        return l10n.achievementDecisionPDesc;
      // Record achievements
      case 'record_b1':
        return l10n.achievementRecordB1Desc;
      case 'record_b2':
        return l10n.achievementRecordB2Desc;
      case 'record_b3':
        return l10n.achievementRecordB3Desc;
      case 'record_s1':
        return l10n.achievementRecordS1Desc;
      case 'record_s2':
        return l10n.achievementRecordS2Desc;
      case 'record_s3':
        return l10n.achievementRecordS3Desc;
      case 'record_g1':
        return l10n.achievementRecordG1Desc;
      case 'record_g2':
        return l10n.achievementRecordG2Desc;
      case 'record_g3':
        return l10n.achievementRecordG3Desc;
      case 'record_p':
        return l10n.achievementRecordPDesc;
      // Hidden achievements
      case 'hidden_night':
        return l10n.achievementHiddenNightDesc;
      case 'hidden_early':
        return l10n.achievementHiddenEarlyDesc;
      case 'hidden_weekend':
        return l10n.achievementHiddenWeekendDesc;
      case 'hidden_first_scan':
        return l10n.achievementHiddenOcrDesc;
      case 'hidden_balanced_week':
        return l10n.achievementHiddenBalancedDesc;
      case 'hidden_all_categories':
        return l10n.achievementHiddenCategoriesDesc;
      case 'hidden_gold_equiv':
        return l10n.achievementHiddenGoldDesc;
      case 'hidden_usd_equiv':
        return l10n.achievementHiddenUsdDesc;
      case 'hidden_subscriptions':
        return l10n.achievementHiddenSubsDesc;
      case 'hidden_no_spend_month':
        return l10n.achievementHiddenNoSpendDesc;
      case 'hidden_gold_kg':
        return l10n.achievementHiddenGoldKgDesc;
      case 'hidden_usd_10k':
        return l10n.achievementHiddenUsd10kDesc;
      case 'hidden_anniversary':
        return l10n.achievementHiddenAnniversaryDesc;
      case 'hidden_early_adopter':
        return l10n.achievementHiddenEarlyAdopterDesc;
      case 'hidden_ultimate':
        return l10n.achievementHiddenUltimateDesc;
      case 'hidden_collector':
        return l10n.achievementHiddenCollectorDesc;
      case 'curious_cat':
        return l10n.curiousCatDescription;
      default:
        return id;
    }
  }

  /// Get full tier label with subTier (e.g., "Bronze 1", "Silver 2")
  static String getFullTierLabel(BuildContext context, AchievementTier tier, int subTier) {
    final tierLabel = getTierLabel(context, tier);
    if (tier == AchievementTier.platinum) {
      return tierLabel;
    }
    return '$tierLabel $subTier';
  }
}
