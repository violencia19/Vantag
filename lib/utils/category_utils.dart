import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:vantag/theme/app_theme.dart';

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

  /// Get category icon (Cupertino icon)
  static IconData getIcon(String internalKey) {
    switch (internalKey) {
      case 'Yiyecek':
        return CupertinoIcons.cart_fill;
      case 'Ulaşım':
        return CupertinoIcons.car_fill;
      case 'Giyim':
        return CupertinoIcons.tag_fill;
      case 'Elektronik':
        return CupertinoIcons.device_phone_portrait;
      case 'Eğlence':
        return CupertinoIcons.gamecontroller_fill;
      case 'Sağlık':
        return CupertinoIcons.heart_fill;
      case 'Eğitim':
        return CupertinoIcons.book_fill;
      case 'Faturalar':
        return CupertinoIcons.doc_text_fill;
      case 'Abonelik':
        return CupertinoIcons.bell_fill;
      case 'Alışveriş':
        return CupertinoIcons.bag_fill;
      case 'Dijital':
        return CupertinoIcons.desktopcomputer;
      case 'Spor':
        return CupertinoIcons.sportscourt_fill;
      case 'Haberleşme':
        return CupertinoIcons.phone_fill;
      case 'Diğer':
      default:
        return CupertinoIcons.cube_box_fill;
    }
  }

  /// Get category color
  static Color getColor(String internalKey) {
    switch (internalKey) {
      case 'Yiyecek':
        return AppColors.categoryFood;
      case 'Ulaşım':
        return AppColors.categoryTransport;
      case 'Giyim':
        return AppColors.categoryShopping;
      case 'Elektronik':
        return AppColors.categoryEntertainment;
      case 'Eğlence':
        return AppColors.categoryBills;
      case 'Sağlık':
        return AppColors.categoryHealth;
      case 'Eğitim':
        return AppColors.categoryEducation;
      case 'Faturalar':
        return AppColors.categoryOther;
      case 'Abonelik':
        return AppColors.primary;
      case 'Alışveriş':
        return AppColors.categoryShoppingPink;
      case 'Dijital':
        return AppColors.categoryDigitalCyan;
      case 'Spor':
        return AppColors.categorySportsGreen;
      case 'Haberleşme':
        return AppColors.categoryCommGray;
      case 'Diğer':
      default:
        return AppColors.categoryDefault;
    }
  }
}
