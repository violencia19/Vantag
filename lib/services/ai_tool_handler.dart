import '../models/models.dart';
import '../models/currency.dart';
import '../providers/finance_provider.dart';
import '../utils/duplicate_checker.dart';
import 'calculation_service.dart';
import 'currency_service.dart';

/// AI tool çağrılarını işleyen handler
class AIToolHandler {
  final FinanceProvider _financeProvider;
  final CalculationService _calculationService = CalculationService();
  final CurrencyService _currencyService = CurrencyService();

  AIToolHandler(this._financeProvider);

  /// Tool çağrısını işle ve sonucu döndür
  Future<Map<String, dynamic>> handleToolCall(String toolName, Map<String, dynamic> args) async {
    switch (toolName) {
      // OKUMA
      case 'get_expenses_summary':
        return _getExpensesSummary();
      case 'get_category_breakdown':
        return _getCategoryBreakdown(args['category'] as String);
      case 'get_subscriptions':
        return await _getSubscriptions();
      case 'get_budget_status':
        return _getBudgetStatus();
      case 'get_thinking_items':
        return _getThinkingItems();
      case 'get_saved_items':
        return _getSavedItems();

      // YAZMA
      case 'add_expense':
        return await _addExpense(args);
      case 'update_expense_decision':
        return await _updateExpenseDecision(args);

      // HESAPLAMA
      case 'calculate_savings_plan':
        return _calculateSavingsPlan(args);
      case 'calculate_hourly_equivalent':
        return _calculateHourlyEquivalent(args['amount'] as double);
      case 'compare_with_alternative':
        return _compareWithAlternative(args);

      default:
        return {'error': 'Bilinmeyen tool: $toolName'};
    }
  }

  // ==========================================
  // OKUMA HANDLER'LARI
  // ==========================================

  Map<String, dynamic> _getExpensesSummary() {
    final now = DateTime.now();
    final expenses = _financeProvider.expenses;
    final user = _financeProvider.userProfile;

    // Bu ay - sadece ALDIM olanlar
    final thisMonth = expenses.where((e) =>
      e.date.month == now.month &&
      e.date.year == now.year &&
      e.decision == ExpenseDecision.yes
    ).toList();

    // Geçen ay
    final lastMonth = expenses.where((e) =>
      e.date.month == (now.month == 1 ? 12 : now.month - 1) &&
      e.date.year == (now.month == 1 ? now.year - 1 : now.year) &&
      e.decision == ExpenseDecision.yes
    ).toList();

    final thisMonthTotal = thisMonth.fold(0.0, (sum, e) => sum + e.amount);
    final lastMonthTotal = lastMonth.fold(0.0, (sum, e) => sum + e.amount);
    final changePercent = lastMonthTotal > 0
        ? ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100)
        : 0.0;

    // Kategori dağılımı
    final categoryTotals = <String, double>{};
    for (final e in thisMonth) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    return {
      'this_month_total': thisMonthTotal,
      'last_month_total': lastMonthTotal,
      'change_percent': changePercent.roundToDouble(),
      'expense_count': thisMonth.length,
      'category_breakdown': categoryTotals,
      'monthly_income': user?.monthlyIncome ?? 0,
      'remaining': (user?.monthlyIncome ?? 0) - thisMonthTotal,
    };
  }

  Map<String, dynamic> _getCategoryBreakdown(String category) {
    final now = DateTime.now();
    final expenses = _financeProvider.expenses;

    final categoryExpenses = expenses.where((e) =>
      e.date.month == now.month &&
      e.date.year == now.year &&
      e.category == category &&
      e.decision == ExpenseDecision.yes
    ).toList();

    final total = categoryExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final items = categoryExpenses.map((e) => {
      'amount': e.amount,
      'description': e.subCategory ?? e.category,
      'date': e.date.day,
    }).toList();

    return {
      'category': category,
      'total': total,
      'count': categoryExpenses.length,
      'items': items,
    };
  }

  Future<Map<String, dynamic>> _getSubscriptions() async {
    final subscriptions = await _financeProvider.getActiveSubscriptions();
    final total = subscriptions.fold(0.0, (sum, s) => sum + s.amount);

    final items = subscriptions.map((s) => {
      'name': s.name,
      'amount': s.amount,
      'renewal_day': s.renewalDay,
      'days_until_renewal': s.daysUntilRenewal,
    }).toList();

    return {
      'total_monthly': total,
      'count': subscriptions.length,
      'subscriptions': items,
    };
  }

  Map<String, dynamic> _getBudgetStatus() {
    final user = _financeProvider.userProfile;
    final now = DateTime.now();
    final expenses = _financeProvider.expenses;

    final thisMonthTotal = expenses.where((e) =>
      e.date.month == now.month &&
      e.date.year == now.year &&
      e.decision == ExpenseDecision.yes
    ).fold(0.0, (sum, e) => sum + e.amount);

    final income = user?.monthlyIncome ?? 0;
    final remaining = income - thisMonthTotal;
    final usedPercent = income > 0 ? (thisMonthTotal / income * 100) : 0;

    // Saatlik kazanç
    final hourlyRate = user != null
        ? income / (user.dailyHours * user.workDaysPerWeek * 4.33)
        : 0.0;

    return {
      'monthly_income': income,
      'total_spent': thisMonthTotal,
      'remaining': remaining,
      'used_percent': usedPercent.roundToDouble(),
      'hourly_rate': hourlyRate.roundToDouble(),
      'status': usedPercent > 80 ? 'critical' : usedPercent > 50 ? 'warning' : 'healthy',
    };
  }

  Map<String, dynamic> _getThinkingItems() {
    final now = DateTime.now();
    final expenses = _financeProvider.expenses;

    final thinking = expenses.where((e) =>
      e.date.month == now.month &&
      e.date.year == now.year &&
      e.decision == ExpenseDecision.thinking
    ).toList();

    final total = thinking.fold(0.0, (sum, e) => sum + e.amount);
    final items = thinking.map((e) => {
      'amount': e.amount,
      'category': e.category,
      'description': e.subCategory ?? e.category,
    }).toList();

    return {
      'total': total,
      'count': thinking.length,
      'items': items,
    };
  }

  Map<String, dynamic> _getSavedItems() {
    final now = DateTime.now();
    final expenses = _financeProvider.expenses;

    // Vazgeçilenler
    final rejected = expenses.where((e) =>
      e.date.month == now.month &&
      e.date.year == now.year &&
      e.decision == ExpenseDecision.no
    ).toList();

    // Smart Choice tasarrufları
    final smartChoice = expenses.where((e) =>
      e.date.month == now.month &&
      e.date.year == now.year &&
      e.isSmartChoice &&
      e.savedAmount > 0
    ).toList();

    final rejectedTotal = rejected.fold(0.0, (sum, e) => sum + e.amount);
    final smartChoiceTotal = smartChoice.fold(0.0, (sum, e) => sum + e.savedAmount);

    return {
      'rejected_total': rejectedTotal,
      'rejected_count': rejected.length,
      'smart_choice_total': smartChoiceTotal,
      'smart_choice_count': smartChoice.length,
      'total_saved': rejectedTotal + smartChoiceTotal,
    };
  }

  // ==========================================
  // YAZMA HANDLER'LARI
  // ==========================================

  Future<Map<String, dynamic>> _addExpense(Map<String, dynamic> args) async {
    final user = _financeProvider.userProfile;
    if (user == null) {
      return {'error': 'Kullanıcı profili bulunamadı'};
    }

    final enteredAmount = (args['amount'] as num).toDouble();
    final category = args['category'] as String;
    final description = args['description'] as String?;
    final decisionStr = args['decision'] as String;
    final currencyCode = args['currency'] as String?;
    final force = args['force'] as bool? ?? false;

    // Get user's income currency
    final incomeCurrencyCode = user.incomeSources.isNotEmpty
        ? user.incomeSources.first.currencyCode
        : 'TRY';
    final expenseCurrencyCode = currencyCode ?? incomeCurrencyCode;
    final isDifferentCurrency = expenseCurrencyCode != incomeCurrencyCode;

    // Convert to income currency if needed
    double amountInIncomeCurrency = enteredAmount;
    if (isDifferentCurrency) {
      final rates = await _currencyService.getRates();
      if (rates != null) {
        amountInIncomeCurrency = _convertCurrency(
          enteredAmount,
          expenseCurrencyCode,
          incomeCurrencyCode,
          rates,
        );
      }
    }

    // Duplicate kontrolü (force değilse)
    if (!force) {
      final duplicates = DuplicateChecker.findDuplicates(
        expenses: _financeProvider.expenses,
        amount: amountInIncomeCurrency,
        category: category,
      );

      if (duplicates.isNotEmpty) {
        final match = duplicates.first;
        final timeDiff = match.timeSinceEntry;
        String timeAgo;
        if (timeDiff.inMinutes < 1) {
          timeAgo = 'just now';
        } else if (timeDiff.inMinutes < 60) {
          timeAgo = '${timeDiff.inMinutes} minutes ago';
        } else if (timeDiff.inHours < 24) {
          timeAgo = '${timeDiff.inHours} hours ago';
        } else {
          timeAgo = '${timeDiff.inDays} days ago';
        }

        return {
          'duplicate_found': true,
          'amount': enteredAmount,
          'currency': expenseCurrencyCode,
          'category': category,
          'existing_amount': match.expense.amount,
          'existing_category': match.expense.category,
          'time_ago': timeAgo,
          'message': 'Similar expense found: ${match.expense.amount.toStringAsFixed(0)} $category ($timeAgo). Add anyway?',
        };
      }
    }

    ExpenseDecision decision;
    switch (decisionStr) {
      case 'yes':
        decision = ExpenseDecision.yes;
        break;
      case 'thinking':
        decision = ExpenseDecision.thinking;
        break;
      case 'no':
        decision = ExpenseDecision.no;
        break;
      default:
        decision = ExpenseDecision.yes;
    }

    // Hesaplama (income currency üzerinden)
    final result = _calculationService.calculateExpense(
      userProfile: user,
      expenseAmount: amountInIncomeCurrency,
      month: DateTime.now().month,
      year: DateTime.now().year,
    );

    final expense = Expense(
      amount: amountInIncomeCurrency,
      category: category,
      subCategory: description,
      date: DateTime.now(),
      hoursRequired: result.hoursRequired,
      daysRequired: result.daysRequired,
      decision: decision,
      decisionDate: DateTime.now(),
      recordType: RecordType.real,
      originalAmount: isDifferentCurrency ? enteredAmount : null,
      originalCurrency: isDifferentCurrency ? expenseCurrencyCode : null,
    );

    await _financeProvider.addExpense(expense);

    final currency = getCurrencyByCode(expenseCurrencyCode);
    return {
      'success': true,
      'amount': enteredAmount,
      'currency': expenseCurrencyCode,
      'currency_symbol': currency.symbol,
      'converted_amount': isDifferentCurrency ? amountInIncomeCurrency : null,
      'category': category,
      'description': description,
      'decision': decisionStr,
      'hours_required': result.hoursRequired.roundToDouble(),
      'message': isDifferentCurrency
          ? 'Harcama kaydedildi (${currency.symbol}$enteredAmount → ₺${amountInIncomeCurrency.toStringAsFixed(0)})'
          : 'Harcama kaydedildi',
    };
  }

  /// Convert amount between currencies using exchange rates
  double _convertCurrency(double amount, String from, String to, ExchangeRates rates) {
    // Get TRY values for each currency
    double getTryValue(String code) {
      switch (code) {
        case 'TRY':
          return 1.0;
        case 'USD':
          return rates.usdRate;
        case 'EUR':
          return rates.eurRate;
        case 'GBP':
          return rates.usdRate * 1.27; // Approximate GBP/USD
        case 'SAR':
          return rates.usdRate / 3.75; // SAR pegged to USD
        default:
          return 1.0;
      }
    }

    final fromTry = getTryValue(from);
    final toTry = getTryValue(to);

    // Convert: from -> TRY -> to
    final amountInTry = amount * fromTry;
    return amountInTry / toTry;
  }

  Future<Map<String, dynamic>> _updateExpenseDecision(Map<String, dynamic> args) async {
    final expenseDesc = args['expense_description'] as String;
    final newDecisionStr = args['new_decision'] as String;

    ExpenseDecision newDecision;
    switch (newDecisionStr) {
      case 'yes':
        newDecision = ExpenseDecision.yes;
        break;
      case 'no':
        newDecision = ExpenseDecision.no;
        break;
      default:
        return {'error': 'Geçersiz karar: $newDecisionStr'};
    }

    // Düşünüyorum listesinde ara
    final expenses = _financeProvider.expenses;
    final index = expenses.indexWhere((e) =>
      e.decision == ExpenseDecision.thinking &&
      (e.subCategory?.toLowerCase().contains(expenseDesc.toLowerCase()) == true ||
       e.category.toLowerCase().contains(expenseDesc.toLowerCase()))
    );

    if (index == -1) {
      return {'error': 'Düşünüyorum listesinde "$expenseDesc" bulunamadı'};
    }

    await _financeProvider.updateExpenseDecision(index, newDecision);

    return {
      'success': true,
      'expense': expenseDesc,
      'new_decision': newDecisionStr,
      'message': newDecisionStr == 'no' ? 'İrade zaferi! Tebrikler!' : 'Karar güncellendi',
    };
  }

  // ==========================================
  // HESAPLAMA HANDLER'LARI
  // ==========================================

  Map<String, dynamic> _calculateSavingsPlan(Map<String, dynamic> args) {
    final targetAmount = (args['target_amount'] as num).toDouble();
    final targetMonths = args['target_months'] as int;
    final purpose = args['purpose'] as String?;

    final user = _financeProvider.userProfile;
    final income = user?.monthlyIncome ?? 0;

    final monthlySavingNeeded = targetAmount / targetMonths;
    final percentOfIncome = income > 0 ? (monthlySavingNeeded / income * 100) : 0;

    // Mevcut harcamaları kontrol et
    final now = DateTime.now();
    final thisMonthSpent = _financeProvider.expenses.where((e) =>
      e.date.month == now.month &&
      e.date.year == now.year &&
      e.decision == ExpenseDecision.yes
    ).fold(0.0, (sum, e) => sum + e.amount);

    final currentMonthlySavings = income - thisMonthSpent;
    final isRealistic = currentMonthlySavings >= monthlySavingNeeded;

    // Alternatif süre hesapla
    final realisticMonths = currentMonthlySavings > 0
        ? (targetAmount / currentMonthlySavings).ceil()
        : 0;

    return {
      'target_amount': targetAmount,
      'target_months': targetMonths,
      'purpose': purpose,
      'monthly_saving_needed': monthlySavingNeeded.roundToDouble(),
      'percent_of_income': percentOfIncome.roundToDouble(),
      'is_realistic': isRealistic,
      'current_monthly_savings': currentMonthlySavings.roundToDouble(),
      'realistic_months': realisticMonths,
      'recommendation': isRealistic
          ? 'Hedefe ulaşılabilir görünüyor'
          : 'Hedef için $realisticMonths ay daha gerçekçi',
    };
  }

  Map<String, dynamic> _calculateHourlyEquivalent(double amount) {
    final user = _financeProvider.userProfile;
    if (user == null) {
      return {'error': 'Kullanıcı profili bulunamadı'};
    }

    final hourlyRate = user.monthlyIncome / (user.dailyHours * user.workDaysPerWeek * 4.33);
    final hours = amount / hourlyRate;
    final days = hours / user.dailyHours;
    final weeks = days / user.workDaysPerWeek;

    return {
      'amount': amount,
      'hourly_rate': hourlyRate.roundToDouble(),
      'hours': hours.roundToDouble(),
      'days': days.roundToDouble(),
      'weeks': weeks.roundToDouble(),
      'description': '${amount.toStringAsFixed(0)} TL = ${hours.toStringAsFixed(1)} saat çalışman',
    };
  }

  Map<String, dynamic> _compareWithAlternative(Map<String, dynamic> args) {
    final amount = (args['amount'] as num).toDouble();
    final alternative = args['alternative'] as String;
    final periodMonths = args['period_months'] as int;

    double returnRate;
    String alternativeName;

    switch (alternative) {
      case 'gold':
        returnRate = 0.03; // Aylık ortalama %3 (yıllık ~%40)
        alternativeName = 'Altın';
        break;
      case 'interest':
        returnRate = 0.035; // Aylık ortalama %3.5
        alternativeName = 'Mevduat Faizi';
        break;
      case 'savings':
        returnRate = 0.02; // Aylık ortalama %2
        alternativeName = 'Birikim Hesabı';
        break;
      default:
        returnRate = 0.025;
        alternativeName = 'Yatırım';
    }

    // Bileşik getiri hesapla
    final futureValue = amount * (1 + returnRate * periodMonths);
    final profit = futureValue - amount;
    final totalReturnPercent = (profit / amount * 100);

    return {
      'amount': amount,
      'alternative': alternativeName,
      'period_months': periodMonths,
      'future_value': futureValue.roundToDouble(),
      'profit': profit.roundToDouble(),
      'total_return_percent': totalReturnPercent.roundToDouble(),
      'monthly_return_percent': (returnRate * 100).roundToDouble(),
      'description': '$periodMonths ay sonra ${futureValue.toStringAsFixed(0)} TL olur, ${profit.toStringAsFixed(0)} TL kar',
    };
  }
}
