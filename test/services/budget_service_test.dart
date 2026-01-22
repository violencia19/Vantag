import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/services/budget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BudgetService', () {
    late BudgetService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = BudgetService();
    });

    group('setMonthlyBudget', () {
      test('sets budget successfully', () async {
        await service.setMonthlyBudget(10000);
        final budget = await service.getMonthlyBudget();
        expect(budget, 10000);
      });

      test('overwrites existing budget', () async {
        await service.setMonthlyBudget(10000);
        await service.setMonthlyBudget(15000);
        final budget = await service.getMonthlyBudget();
        expect(budget, 15000);
      });
    });

    group('getMonthlyBudget', () {
      test('returns null when no budget set', () async {
        final budget = await service.getMonthlyBudget();
        expect(budget, isNull);
      });

      test('returns saved budget', () async {
        await service.setMonthlyBudget(8000);
        final budget = await service.getMonthlyBudget();
        expect(budget, 8000);
      });
    });

    group('clearMonthlyBudget', () {
      test('clears budget successfully', () async {
        await service.setMonthlyBudget(10000);
        await service.clearMonthlyBudget();
        final budget = await service.getMonthlyBudget();
        expect(budget, isNull);
      });
    });

    group('setCategoryBudget', () {
      test('sets category budget successfully', () async {
        await service.setCategoryBudget('Yiyecek', 2000);
        final budget = await service.getCategoryBudget('Yiyecek');
        expect(budget, 2000);
      });

      test('handles multiple categories', () async {
        await service.setCategoryBudget('Yiyecek', 2000);
        await service.setCategoryBudget('Ulaşım', 1500);

        expect(await service.getCategoryBudget('Yiyecek'), 2000);
        expect(await service.getCategoryBudget('Ulaşım'), 1500);
      });
    });

    group('getCategoryBudget', () {
      test('returns null for non-existent category', () async {
        final budget = await service.getCategoryBudget('NonExistent');
        expect(budget, isNull);
      });
    });

    group('getAllCategoryBudgets', () {
      test('returns empty map when no budgets set', () async {
        final budgets = await service.getAllCategoryBudgets();
        expect(budgets, isEmpty);
      });

      test('returns all set category budgets', () async {
        await service.setCategoryBudget('Yiyecek', 2000);
        await service.setCategoryBudget('Ulaşım', 1500);
        await service.setCategoryBudget('Eğlence', 1000);

        final budgets = await service.getAllCategoryBudgets();
        expect(budgets.length, 3);
        expect(budgets['Yiyecek'], 2000);
        expect(budgets['Ulaşım'], 1500);
        expect(budgets['Eğlence'], 1000);
      });
    });

    group('clearAllBudgets', () {
      test('clears all budgets', () async {
        await service.setMonthlyBudget(10000);
        await service.setCategoryBudget('Yiyecek', 2000);

        await service.clearAllBudgets();

        expect(await service.getMonthlyBudget(), isNull);
        expect(await service.getCategoryBudget('Yiyecek'), isNull);
      });
    });
  });
}
