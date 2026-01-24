import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

/// Service for managing currency preferences
class CurrencyPreferenceService {
  static const String _key = 'selected_currency';
  static const String _firstLaunchKey = 'currency_first_launch_done';

  /// Save selected currency code
  static Future<void> setCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  /// Get saved currency code
  /// On first launch: Turkish phone → TRY, otherwise → USD
  static Future<String> getCurrencyCode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_key);
    final firstLaunchDone = prefs.getBool(_firstLaunchKey) ?? false;

    if (savedCode != null) {
      // User has a saved preference
      return savedCode;
    }

    if (!firstLaunchDone) {
      // First launch - set based on phone language
      final defaultCurrency = _isPhoneTurkish() ? 'TRY' : 'USD';
      await prefs.setString(_key, defaultCurrency);
      await prefs.setBool(_firstLaunchKey, true);
      debugPrint('[CurrencyPreference] First launch - default currency: $defaultCurrency');
      return defaultCurrency;
    }

    // Fallback (shouldn't happen normally)
    return 'USD';
  }

  /// Check if phone language is Turkish
  static bool _isPhoneTurkish() {
    try {
      final localeName = Platform.localeName; // e.g., "tr_TR", "en_US"
      return localeName.toLowerCase().startsWith('tr');
    } catch (e) {
      debugPrint('[CurrencyPreference] Error detecting phone locale: $e');
      return false;
    }
  }

  /// Get Currency object
  static Future<Currency> getCurrency() async {
    final code = await getCurrencyCode();
    return getCurrencyByCode(code);
  }

  /// Format amount with currency
  /// Supports both integer format and decimal format
  static String format(
    Currency currency,
    double amount, {
    int decimalDigits = 0,
  }) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String formatted;
    if (decimalDigits > 0) {
      // With decimals
      final parts = absAmount.toStringAsFixed(decimalDigits).split('.');
      final intPart = _addThousandSeparators(
        parts[0],
        currency.thousandSeparator,
      );
      final decPart = parts.length > 1 ? parts[1] : '0' * decimalDigits;
      formatted = '$intPart${currency.decimalSeparator}$decPart';
    } else {
      // Integer only
      formatted = _addThousandSeparators(
        absAmount.truncate().toString(),
        currency.thousandSeparator,
      );
    }

    // Add negative sign if needed
    if (isNegative) {
      formatted = '-$formatted';
    }

    // Add symbol
    if (currency.symbolBefore) {
      return '${currency.symbol}$formatted';
    } else {
      return '$formatted ${currency.symbol}';
    }
  }

  /// Format amount without symbol
  static String formatWithoutSymbol(
    Currency currency,
    double amount, {
    int decimalDigits = 0,
  }) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String formatted;
    if (decimalDigits > 0) {
      final parts = absAmount.toStringAsFixed(decimalDigits).split('.');
      final intPart = _addThousandSeparators(
        parts[0],
        currency.thousandSeparator,
      );
      final decPart = parts.length > 1 ? parts[1] : '0' * decimalDigits;
      formatted = '$intPart${currency.decimalSeparator}$decPart';
    } else {
      formatted = _addThousandSeparators(
        absAmount.truncate().toString(),
        currency.thousandSeparator,
      );
    }

    return isNegative ? '-$formatted' : formatted;
  }

  /// Add thousand separators to a number string
  static String _addThousandSeparators(String number, String separator) {
    if (number.length <= 3) return number;

    final buffer = StringBuffer();
    final length = number.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(number[i]);
    }

    return buffer.toString();
  }
}
