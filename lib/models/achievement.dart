import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/theme/app_theme.dart';

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum;

  String get label {
    switch (this) {
      case AchievementTier.bronze:
        return 'Bronz';
      case AchievementTier.silver:
        return 'Gümüş';
      case AchievementTier.gold:
        return 'Altın';
      case AchievementTier.platinum:
        return 'Platin';
    }
  }

  int get sortOrder {
    switch (this) {
      case AchievementTier.bronze:
        return 0;
      case AchievementTier.silver:
        return 1;
      case AchievementTier.gold:
        return 2;
      case AchievementTier.platinum:
        return 3;
    }
  }
}

enum AchievementCategory {
  streak,
  savings,
  decision,
  record,
  hidden;

  String get label {
    switch (this) {
      case AchievementCategory.streak:
        return 'Seri';
      case AchievementCategory.savings:
        return 'Tasarruf';
      case AchievementCategory.decision:
        return 'Karar';
      case AchievementCategory.record:
        return 'Kayıt';
      case AchievementCategory.hidden:
        return 'Gizli';
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementCategory.streak:
        return PhosphorIconsDuotone.flame;
      case AchievementCategory.savings:
        return PhosphorIconsDuotone.currencyCircleDollar;
      case AchievementCategory.decision:
        return PhosphorIconsDuotone.target;
      case AchievementCategory.record:
        return PhosphorIconsDuotone.notepad;
      case AchievementCategory.hidden:
        return PhosphorIconsDuotone.eyeSlash;
    }
  }

  Color get iconColor {
    switch (this) {
      case AchievementCategory.streak:
        return AppColors.achievementStreak;
      case AchievementCategory.savings:
        return AppColors.achievementSavings;
      case AchievementCategory.decision:
        return AppColors.achievementGoals;
      case AchievementCategory.record:
        return AppColors.achievementTracker;
      case AchievementCategory.hidden:
        return AppColors.achievementMystery;
    }
  }
}

enum HiddenDifficulty {
  easy,
  medium,
  hard,
  legendary;

  String get label {
    switch (this) {
      case HiddenDifficulty.easy:
        return 'Kolay';
      case HiddenDifficulty.medium:
        return 'Orta';
      case HiddenDifficulty.hard:
        return 'Zor';
      case HiddenDifficulty.legendary:
        return 'Efsanevi';
    }
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final AchievementTier tier;
  final int subTier; // 1, 2, or 3 for Bronze 1, Bronze 2, etc.
  final double progress; // 0.0 - 1.0
  final int currentValue;
  final int targetValue;
  final DateTime? unlockedAt;
  final bool isHidden;
  final HiddenDifficulty? hiddenDifficulty;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tier,
    this.subTier = 1,
    required this.progress,
    required this.currentValue,
    required this.targetValue,
    this.unlockedAt,
    this.isHidden = false,
    this.hiddenDifficulty,
  });

  bool get isUnlocked => unlockedAt != null;

  bool get isNewlyUnlocked {
    if (unlockedAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final unlockDate = DateTime(
      unlockedAt!.year,
      unlockedAt!.month,
      unlockedAt!.day,
    );
    return unlockDate == today;
  }

  Achievement copyWith({
    double? progress,
    int? currentValue,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      category: category,
      tier: tier,
      subTier: subTier,
      progress: progress ?? this.progress,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isHidden: isHidden,
      hiddenDifficulty: hiddenDifficulty,
    );
  }

  /// Tier ve subTier'a göre sıralama için kullanılır
  int get sortKey => tier.sortOrder * 10 + subTier;

  /// Görüntülenecek tier etiketi (örn: "Bronz 1", "Gümüş 2")
  String get tierLabel {
    if (tier == AchievementTier.platinum) {
      return tier.label;
    }
    return '${tier.label} $subTier';
  }
}
