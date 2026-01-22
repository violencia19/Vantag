import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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

  /// Get category icon (Phosphor icon)
  static IconData getIcon(String internalKey) {
    switch (internalKey) {
      case 'Yiyecek':
        return PhosphorIconsFill.forkKnife;
      case 'Ulaşım':
        return PhosphorIconsFill.car;
      case 'Giyim':
        return PhosphorIconsFill.tShirt;
      case 'Elektronik':
        return PhosphorIconsFill.deviceMobile;
      case 'Eğlence':
        return PhosphorIconsFill.gameController;
      case 'Sağlık':
        return PhosphorIconsFill.pill;
      case 'Eğitim':
        return PhosphorIconsFill.graduationCap;
      case 'Faturalar':
        return PhosphorIconsFill.fileText;
      case 'Abonelik':
        return PhosphorIconsFill.bellRinging;
      case 'Alışveriş':
        return PhosphorIconsFill.shoppingCart;
      case 'Dijital':
        return PhosphorIconsFill.laptop;
      case 'Spor':
        return PhosphorIconsFill.barbell;
      case 'Haberleşme':
        return PhosphorIconsFill.phone;
      case 'Diğer':
      default:
        return PhosphorIconsFill.package;
    }
  }

  /// Get category color
  static Color getColor(String internalKey) {
    switch (internalKey) {
      case 'Yiyecek':
        return const Color(0xFFFF6B6B);
      case 'Ulaşım':
        return const Color(0xFF4ECDC4);
      case 'Giyim':
        return const Color(0xFF9B59B6);
      case 'Elektronik':
        return const Color(0xFF3498DB);
      case 'Eğlence':
        return const Color(0xFFE74C3C);
      case 'Sağlık':
        return const Color(0xFF2ECC71);
      case 'Eğitim':
        return const Color(0xFFF39C12);
      case 'Faturalar':
        return const Color(0xFF95A5A6);
      case 'Abonelik':
        return const Color(0xFF6C63FF);
      case 'Alışveriş':
        return const Color(0xFFE91E63);
      case 'Dijital':
        return const Color(0xFF00BCD4);
      case 'Spor':
        return const Color(0xFF8BC34A);
      case 'Haberleşme':
        return const Color(0xFF607D8B);
      case 'Diğer':
      default:
        return const Color(0xFF78909C);
    }
  }
}
