import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/l10n/app_localizations.dart';

/// Discovery Tour management service
class TourService {
  static const _keyHasSeenTour = 'has_seen_tour';
  static const _keyTourVersion = 'tour_version';

  // Tour version - increment when new features are added
  static const int currentTourVersion = 1;

  /// Has the user seen the tour before?
  static Future<bool> hasSeenTour() async {
    final prefs = await SharedPreferences.getInstance();
    final seenVersion = prefs.getInt(_keyTourVersion) ?? 0;
    return seenVersion >= currentTourVersion;
  }

  /// Mark tour as complete
  static Future<void> markTourComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenTour, true);
    await prefs.setInt(_keyTourVersion, currentTourVersion);
  }

  /// Reset tour (to restart from settings)
  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasSeenTour);
    await prefs.setInt(_keyTourVersion, 0);
  }
}

/// Tour GlobalKeys
class TourKeys {
  // Expense Screen
  static final amountField = GlobalKey();
  static final descriptionField = GlobalKey();
  static final categoryField = GlobalKey();
  static final dateChips = GlobalKey();
  static final calculateButton = GlobalKey();

  // Main Screen - Nav Bar
  static final navBarExpense = GlobalKey();
  static final navBarReport = GlobalKey();
  static final navBarAchievements = GlobalKey();
  static final navBarProfile = GlobalKey();
  static final navBarAddButton = GlobalKey();

  // Header
  static final streakWidget = GlobalKey();
  static final subscriptionButton = GlobalKey();

  // Financial Snapshot
  static final financialSnapshot = GlobalKey();

  // Currency Rates
  static final currencyRates = GlobalKey();
}

/// Tour step information
class TourStep {
  final GlobalKey key;
  final String title;
  final String description;
  final ShapeBorder? shapeBorder;

  const TourStep({
    required this.key,
    required this.title,
    required this.description,
    this.shapeBorder,
  });
}

/// Tour steps list builder
class TourSteps {
  static List<TourStep> getAll(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      TourStep(
        key: TourKeys.amountField,
        title: l10n.tourAmountTitle,
        description: l10n.tourAmountDesc,
      ),
      TourStep(
        key: TourKeys.descriptionField,
        title: l10n.tourDescriptionTitle,
        description: l10n.tourDescriptionDesc,
      ),
      TourStep(
        key: TourKeys.categoryField,
        title: l10n.tourCategoryTitle,
        description: l10n.tourCategoryDesc,
      ),
      TourStep(
        key: TourKeys.dateChips,
        title: l10n.tourDateTitle,
        description: l10n.tourDateDesc,
      ),
      TourStep(
        key: TourKeys.financialSnapshot,
        title: l10n.tourSnapshotTitle,
        description: l10n.tourSnapshotDesc,
      ),
      TourStep(
        key: TourKeys.currencyRates,
        title: l10n.tourCurrencyTitle,
        description: l10n.tourCurrencyDesc,
      ),
      TourStep(
        key: TourKeys.streakWidget,
        title: l10n.tourStreakTitle,
        description: l10n.tourStreakDesc,
      ),
      TourStep(
        key: TourKeys.subscriptionButton,
        title: l10n.tourSubscriptionTitle,
        description: l10n.tourSubscriptionDesc,
      ),
      TourStep(
        key: TourKeys.navBarReport,
        title: l10n.tourReportTitle,
        description: l10n.tourReportDesc,
      ),
      TourStep(
        key: TourKeys.navBarAchievements,
        title: l10n.tourAchievementsTitle,
        description: l10n.tourAchievementsDesc,
      ),
      TourStep(
        key: TourKeys.navBarProfile,
        title: l10n.tourProfileTitle,
        description: l10n.tourProfileDesc,
      ),
      TourStep(
        key: TourKeys.navBarAddButton,
        title: l10n.tourQuickAddTitle,
        description: l10n.tourQuickAddDesc,
      ),
    ];
  }
}
