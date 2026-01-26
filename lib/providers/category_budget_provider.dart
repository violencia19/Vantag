import 'package:flutter/foundation.dart';
import '../models/category_budget.dart';
import '../models/expense.dart';
import '../services/category_budget_service.dart';

/// Provider for managing category budget state
class CategoryBudgetProvider extends ChangeNotifier {
  final CategoryBudgetService _service = CategoryBudgetService();

  List<CategoryBudgetWithSpent> _budgets = [];
  BudgetSummary? _summary;
  bool _isLoading = false;
  String? _error;

  // Current month context
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  // Cached expenses reference
  List<Expense> _expenses = [];

  // Getters
  List<CategoryBudgetWithSpent> get budgets => _budgets;
  BudgetSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentMonth => _currentMonth;
  int get currentYear => _currentYear;

  /// All active budgets
  List<CategoryBudget> get activeBudgets =>
      _budgets.map((b) => b.budget).toList();

  /// Budgets that need attention (80%+)
  List<CategoryBudgetWithSpent> get warningBudgets =>
      _budgets.where((b) => b.percentUsed >= 80).toList();

  /// Budgets over limit
  List<CategoryBudgetWithSpent> get overBudgets =>
      _budgets.where((b) => b.isOverBudget).toList();

  /// Budgets near limit (80-100%)
  List<CategoryBudgetWithSpent> get nearLimitBudgets =>
      _budgets.where((b) => b.isNearLimit).toList();

  /// Budgets on track (<80%)
  List<CategoryBudgetWithSpent> get onTrackBudgets =>
      _budgets.where((b) => b.isOnTrack).toList();

  /// Has any budgets configured
  bool get hasBudgets => _budgets.isNotEmpty;

  /// Has any warnings
  bool get hasWarnings => warningBudgets.isNotEmpty;

  /// Initialize/load budgets
  Future<void> initialize(List<Expense> expenses) async {
    _expenses = expenses;
    await loadBudgets();
  }

  /// Update expenses reference and refresh
  Future<void> updateExpenses(List<Expense> expenses) async {
    _expenses = expenses;
    await _refreshBudgets();
  }

  /// Set month context
  Future<void> setMonth(int month, int year) async {
    _currentMonth = month;
    _currentYear = year;
    await _refreshBudgets();
  }

  /// Load all budgets with spent amounts
  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _service.getBudgetsWithSpent(
        _expenses,
        _currentMonth,
        _currentYear,
      );

      _summary = await _service.getSummary(
        _expenses,
        _currentMonth,
        _currentYear,
      );

      // Sort by percent used (highest first)
      _budgets.sort((a, b) => b.percentUsed.compareTo(a.percentUsed));

      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading category budgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh budgets (internal)
  Future<void> _refreshBudgets() async {
    try {
      _budgets = await _service.getBudgetsWithSpent(
        _expenses,
        _currentMonth,
        _currentYear,
      );

      _summary = await _service.getSummary(
        _expenses,
        _currentMonth,
        _currentYear,
      );

      _budgets.sort((a, b) => b.percentUsed.compareTo(a.percentUsed));
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing category budgets: $e');
    }
  }

  /// Add a new budget
  Future<bool> addBudget(CategoryBudget budget) async {
    try {
      await _service.saveBudget(budget);
      await _refreshBudgets();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update an existing budget
  Future<bool> updateBudget(CategoryBudget budget) async {
    try {
      await _service.updateBudget(budget);
      await _refreshBudgets();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a budget
  Future<bool> deleteBudget(String id) async {
    try {
      await _service.deleteBudget(id);
      await _refreshBudgets();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get budget for a specific category
  CategoryBudgetWithSpent? getBudgetForCategory(String category) {
    try {
      return _budgets.firstWhere((b) => b.budget.category == category);
    } catch (_) {
      return null;
    }
  }

  /// Check if category has a budget
  bool hasBudgetForCategory(String category) {
    return _budgets.any((b) => b.budget.category == category);
  }

  /// Check if adding expense would affect budget
  Future<BudgetCheckResult> checkExpenseImpact(
    String category,
    double amount,
  ) async {
    return await _service.checkBudgetOnExpense(
      _expenses,
      category,
      amount,
      _currentMonth,
      _currentYear,
    );
  }

  /// Get categories without budgets
  List<String> getCategoriesWithoutBudget(List<String> allCategories) {
    final budgetedCategories = _budgets.map((b) => b.budget.category).toSet();
    return allCategories.where((c) => !budgetedCategories.contains(c)).toList();
  }
}
