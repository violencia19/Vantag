import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';

/// Utility class for category localization
class CategoryUtils {
  /// Internal category keys (stored in database)
  static const List<String> internalKeys = [
    'Yiyecek',
    'Ulaşım',
    'Giyim',
    'Elektronik',
    'Eğlence',
    'Sağlık',
    'Eğitim',
    'Faturalar',
    'Abonelik',
    'Diğer',
  ];

  /// Get localized category name from internal key
  static String getLocalizedName(BuildContext context, String internalKey) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return internalKey;

    switch (internalKey) {
      case 'Yiyecek':
        return l10n.categoryFood;
      case 'Ulaşım':
        return l10n.categoryTransport;
      case 'Giyim':
        return l10n.categoryClothing;
      case 'Elektronik':
        return l10n.categoryElectronics;
      case 'Eğlence':
        return l10n.categoryEntertainment;
      case 'Sağlık':
        return l10n.categoryHealth;
      case 'Eğitim':
        return l10n.categoryEducation;
      case 'Faturalar':
        return l10n.categoryBills;
      case 'Abonelik':
        return l10n.categorySubscription;
      case 'Diğer':
        return l10n.categoryOther;
      // Additional categories
      case 'Alışveriş':
        return l10n.categoryShopping;
      case 'Dijital':
        return l10n.categoryDigital;
      case 'Spor':
        return l10n.categorySports;
      case 'Haberleşme':
        return l10n.categoryCommunication;
      default:
        return internalKey;
    }
  }

  /// Get all categories as localized list
  static List<String> getLocalizedCategories(BuildContext context) {
    return internalKeys.map((key) => getLocalizedName(context, key)).toList();
  }

  /// Get localized full weekday name
  static String getLocalizedWeekday(BuildContext context, int weekday) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return '';

    switch (weekday) {
      case 1:
        return l10n.weekdayMonday;
      case 2:
        return l10n.weekdayTuesday;
      case 3:
        return l10n.weekdayWednesday;
      case 4:
        return l10n.weekdayThursday;
      case 5:
        return l10n.weekdayFriday;
      case 6:
        return l10n.weekdaySaturday;
      case 7:
        return l10n.weekdaySunday;
      default:
        return '';
    }
  }

  /// Get category icon (emoji)
  static String getIcon(String internalKey) {
    switch (internalKey) {
      case 'Yiyecek':
        return '🍕';
      case 'Ulaşım':
        return '🚗';
      case 'Giyim':
        return '👕';
      case 'Elektronik':
        return '📱';
      case 'Eğlence':
        return '🎮';
      case 'Sağlık':
        return '💊';
      case 'Eğitim':
        return '📚';
      case 'Faturalar':
        return '📄';
      case 'Abonelik':
        return '🔔';
      case 'Alışveriş':
        return '🛒';
      case 'Dijital':
        return '💻';
      case 'Spor':
        return '⚽';
      case 'Haberleşme':
        return '📞';
      case 'Diğer':
      default:
        return '📦';
    }
  }
}
