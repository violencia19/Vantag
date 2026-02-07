import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';

class InsightService {
  String getExpenseInsight(BuildContext context, ExpenseResult result) {
    final l10n = AppLocalizations.of(context);
    final hours = result.hoursRequired;
    final days = result.daysRequired;

    if (hours < 1) {
      final minutes = (hours * 60).round();
      return l10n.insightMinutes(minutes);
    } else if (hours < 8) {
      return l10n.insightHours(hours.toStringAsFixed(1));
    } else if (days < 1) {
      return l10n.insightAlmostDay;
    } else if (days < 5) {
      return l10n.insightDays(days.toStringAsFixed(1));
    } else if (days < 20) {
      return l10n.insightDaysWorked(days.toStringAsFixed(0));
    } else {
      return l10n.insightAlmostMonth;
    }
  }

  String? getCategoryInsight(
    BuildContext context,
    List<Expense> expenses,
    String category,
    int month,
    int year,
  ) {
    final l10n = AppLocalizations.of(context);
    final categoryExpenses = expenses
        .where(
          (e) =>
              e.category == category &&
              e.date.month == month &&
              e.date.year == year,
        )
        .toList();

    if (categoryExpenses.length < 2) return null;

    final totalHours = categoryExpenses.fold<double>(
      0,
      (sum, e) => sum + e.hoursRequired,
    );
    final totalDays = categoryExpenses.fold<double>(
      0,
      (sum, e) => sum + e.daysRequired,
    );

    if (totalDays >= 1) {
      return l10n.insightCategoryDays(category, totalDays.toStringAsFixed(1));
    } else {
      return l10n.insightCategoryHours(category, totalHours.toStringAsFixed(1));
    }
  }

  String? getMonthlyInsight(
    BuildContext context,
    List<Expense> expenses,
    int month,
    int year,
  ) {
    final l10n = AppLocalizations.of(context);
    final monthExpenses = expenses
        .where((e) => e.date.month == month && e.date.year == year)
        .toList();

    if (monthExpenses.isEmpty) return null;

    final totalDays = monthExpenses.fold<double>(
      0,
      (sum, e) => sum + e.daysRequired,
    );

    if (totalDays >= 20) {
      return l10n.insightMonthlyAlmost;
    } else if (totalDays >= 10) {
      return l10n.insightMonthlyDays(totalDays.toStringAsFixed(0));
    }

    return null;
  }
}
