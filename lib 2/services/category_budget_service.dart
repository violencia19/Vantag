import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_budget.dart';
import '../models/expense.dart';

/// Service for managing per-category budget limits
class CategoryBudgetService {
  static const String _storageKey = 'category_budgets_v1';

  /// Get all category budgets
  Future<List<CategoryBudget>> getBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => CategoryBudget.fromJson(e as Map<String, dynamic>))
          .where((b) => b.isActive)
          .toList();
    } catch (e) {
      debugPrint('Error loading category budgets: $e');
      return [];
    }
  }

  /// Get all budgets including inactive
  Future<List<CategoryBudget>> getAllBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => CategoryBudget.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading all category budgets: $e');
      return [];
    }
  }

  /// Save a new budget
  Future<void> saveBudget(CategoryBudget budget) async {
    final budgets = await getAllBudgets();

    // Check if budget already exists for this category
    final existingIndex = budgets.indexWhere(
      (b) => b.category == budget.category,
    );

    if (existingIndex >= 0) {
      // Update existing
      budgets[existingIndex] = budget.copyWith(updatedAt: DateTime.now());
    } else {
      // Add new
      budgets.add(budget);
    }

    await _saveBudgets(budgets);
  }

  /// Update an existing budget
  Future<void> updateBudget(CategoryBudget budget) async {
    final budgets = await getAllBudgets();
    final index = budgets.indexWhere((b) => b.id == budget.id);

    if (index >= 0) {
      budgets[index] = budget.copyWith(updatedAt: DateTime.now());
      await _saveBudgets(budgets);
    }
  }

  /// Delete a budget (soft delete - sets isActive to false)
  Future<void> deleteBudget(String id) async {
    final budgets = await getAllBudgets();
    final index = budgets.indexWhere((b) => b.id == id);

    if (index >= 0) {
      budgets[index] = budgets[index].copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      await _saveBudgets(budgets);
    }
  }

  /// Hard delete a budget
  Future<void> permanentlyDeleteBudget(String id) async {
    final budgets = await getAllBudgets();
    budgets.removeWhere((b) => b.id == id);
    await _saveBudgets(budgets);
  }

  /// Get budget for a specific category
  Future<CategoryBudget?> getBudgetForCategory(String category) async {
    final budgets = await getBudgets();
    try {
      return budgets.firstWhere((b) => b.category == category);
    } catch (_) {
      return null;
    }
  }

  /// Calculate spent amount for a category in a specific month
  double calculateSpentAmount(
    List<Expense> expenses,
    String category,
    int month,
    int year,
  ) {
    return expenses
        .where(
          (e) =>
              e.category == category &&
              e.date.month == month &&
              e.date.year == year &&
              e.decision == ExpenseDecision.yes,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get all budgets with calculated spent amounts
  Future<List<CategoryBudgetWithSpent>> getBudgetsWithSpent(
    List<Expense> expenses,
    int month,
    int year,
  ) async {
    final budgets = await getBudgets();

    return budgets.map((budget) {
      final spent = calculateSpentAmount(
        expenses,
        budget.category,
        month,
        year,
      );
      return CategoryBudgetWithSpent(
        budget: budget,
        spent: spent,
        month: month,
        year: year,
      );
    }).toList();
  }

  /// Get budgets that are over limit
  Future<List<CategoryBudgetWithSpent>> getOverBudgetCategories(
    List<Expense> expenses,
    int month,
    int year,
  ) async {
    final budgetsWithSpent = await getBudgetsWithSpent(expenses, month, year);
    return budgetsWithSpent.where((b) => b.isOverBudget).toList();
  }

  /// Get budgets near limit (80%+)
  Future<List<CategoryBudgetWithSpent>> getNearLimitCategories(
    List<Expense> expenses,
    int month,
    int year,
  ) async {
    final budgetsWithSpent = await getBudgetsWithSpent(expenses, month, year);
    return budgetsWithSpent.where((b) => b.isNearLimit).toList();
  }

  /// Get budgets that need attention (80%+)
  Future<List<CategoryBudgetWithSpent>> getWarningBudgets(
    List<Expense> expenses,
    int month,
    int year,
  ) async {
    final budgetsWithSpent = await getBudgetsWithSpent(expenses, month, year);
    return budgetsWithSpent.where((b) => b.percentUsed >= 80).toList()
      ..sort((a, b) => b.percentUsed.compareTo(a.percentUsed));
  }

  /// Check if adding an expense would exceed budget
  Future<BudgetCheckResult> checkBudgetOnExpense(
    List<Expense> expenses,
    String category,
    double amount,
    int month,
    int year,
  ) async {
    final budget = await getBudgetForCategory(category);
    if (budget == null) {
      return BudgetCheckResult(
        hasBudget: false,
        budget: null,
        currentSpent: 0,
        newSpent: amount,
        wouldExceed: false,
        wouldBeNearLimit: false,
      );
    }

    final currentSpent = calculateSpentAmount(expenses, category, month, year);
    final newSpent = currentSpent + amount;
    final newPercent = newSpent / budget.monthlyLimit * 100;

    return BudgetCheckResult(
      hasBudget: true,
      budget: budget,
      currentSpent: currentSpent,
      newSpent: newSpent,
      wouldExceed: newSpent > budget.monthlyLimit,
      wouldBeNearLimit: newPercent >= 80 && newSpent <= budget.monthlyLimit,
    );
  }

  /// Get summary stats
  Future<BudgetSummary> getSummary(
    List<Expense> expenses,
    int month,
    int year,
  ) async {
    final budgetsWithSpent = await getBudgetsWithSpent(expenses, month, year);

    if (budgetsWithSpent.isEmpty) {
      return BudgetSummary(
        totalBudget: 0,
        totalSpent: 0,
        categoriesOnTrack: 0,
        categoriesNearLimit: 0,
        categoriesOverBudget: 0,
        totalCategories: 0,
      );
    }

    return BudgetSummary(
      totalBudget: budgetsWithSpent.fold(
        0.0,
        (sum, b) => sum + b.budget.monthlyLimit,
      ),
      totalSpent: budgetsWithSpent.fold(0.0, (sum, b) => sum + b.spent),
      categoriesOnTrack: budgetsWithSpent.where((b) => b.isOnTrack).length,
      categoriesNearLimit: budgetsWithSpent.where((b) => b.isNearLimit).length,
      categoriesOverBudget: budgetsWithSpent
          .where((b) => b.isOverBudget)
          .length,
      totalCategories: budgetsWithSpent.length,
    );
  }

  // Private helper to save budgets
  Future<void> _saveBudgets(List<CategoryBudget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(budgets.map((b) => b.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}

/// Result of checking if expense would affect budget
class BudgetCheckResult {
  final bool hasBudget;
  final CategoryBudget? budget;
  final double currentSpent;
  final double newSpent;
  final bool wouldExceed;
  final bool wouldBeNearLimit;

  BudgetCheckResult({
    required this.hasBudget,
    required this.budget,
    required this.currentSpent,
    required this.newSpent,
    required this.wouldExceed,
    required this.wouldBeNearLimit,
  });

  double get percentAfter =>
      budget != null ? (newSpent / budget!.monthlyLimit * 100) : 0;

  double get amountOver =>
      wouldExceed && budget != null ? newSpent - budget!.monthlyLimit : 0;
}

/// Budget summary statistics
class BudgetSummary {
  final double totalBudget;
  final double totalSpent;
  final int categoriesOnTrack;
  final int categoriesNearLimit;
  final int categoriesOverBudget;
  final int totalCategories;

  BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.categoriesOnTrack,
    required this.categoriesNearLimit,
    required this.categoriesOverBudget,
    required this.totalCategories,
  });

  double get totalRemaining => totalBudget - totalSpent;
  double get overallPercentUsed =>
      totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0;
  bool get hasWarnings => categoriesNearLimit > 0 || categoriesOverBudget > 0;
}
