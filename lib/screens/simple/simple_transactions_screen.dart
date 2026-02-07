import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/theme.dart';
import '../../utils/currency_utils.dart';

/// Simple Mode - Transactions Screen (Excel/Accounting style)
class SimpleTransactionsScreen extends StatefulWidget {
  const SimpleTransactionsScreen({super.key});

  @override
  State<SimpleTransactionsScreen> createState() =>
      _SimpleTransactionsScreenState();
}

class _SimpleTransactionsScreenState extends State<SimpleTransactionsScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _previousMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() {
        _selectedMonth = nextMonth;
      });
    }
  }

  List<Expense> _getMonthExpenses(List<Expense> allExpenses) {
    return allExpenses.where((e) {
      return e.date.year == _selectedMonth.year &&
          e.date.month == _selectedMonth.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final financeProvider = context.watch<FinanceProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final expenses = financeProvider.realExpenses;
    final monthExpenses = _getMonthExpenses(expenses);

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;
    for (final expense in monthExpenses) {
      if (expense.decision == ExpenseDecision.yes) {
        totalExpense += expense.amount;
      }
    }
    // For now, income is from profile
    totalIncome = financeProvider.userProfile?.monthlyIncome ?? 0;
    final balance = totalIncome - totalExpense;

    final currencySymbol = currencyProvider.currency.symbol;

    return Scaffold(
      backgroundColor: context.vantColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Month Selector
            _buildMonthSelector(l10n),

            // Summary Row
            _buildSummaryRow(
              l10n,
              currencySymbol,
              totalIncome,
              totalExpense,
              balance,
            ),

            // Divider
            Divider(color: context.vantColors.cardBorder, height: 1),

            // Transaction List
            Expanded(
              child: monthExpenses.isEmpty
                  ? _buildEmptyState(l10n)
                  : _buildTransactionList(monthExpenses, currencySymbol, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(AppLocalizations l10n) {
    final now = DateTime.now();
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;

    final locale = Localizations.localeOf(context).languageCode;
    final monthFormat = DateFormat.yMMMM(locale);
    final monthName = monthFormat.format(_selectedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: Icon(
              CupertinoIcons.chevron_left,
              color: context.vantColors.textPrimary,
            ),
          ),
          Text(
            monthName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.vantColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: isCurrentMonth ? null : _nextMonth,
            icon: Icon(
              CupertinoIcons.chevron_right,
              color: isCurrentMonth
                  ? context.vantColors.textTertiary
                  : context.vantColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    AppLocalizations l10n,
    String currencySymbol,
    double income,
    double expense,
    double balance,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Income
          Expanded(
            child: _buildSummaryItem(
              label: l10n.simpleIncome,
              amount: income,
              currencySymbol: currencySymbol,
              color: context.vantColors.success,
            ),
          ),
          Container(width: 1, height: 40, color: context.vantColors.cardBorder),
          // Expense
          Expanded(
            child: _buildSummaryItem(
              label: l10n.simpleExpense,
              amount: expense,
              currencySymbol: currencySymbol,
              color: context.vantColors.error,
            ),
          ),
          Container(width: 1, height: 40, color: context.vantColors.cardBorder),
          // Balance
          Expanded(
            child: _buildSummaryItem(
              label: l10n.simpleBalance,
              amount: balance,
              currencySymbol: currencySymbol,
              color: context.vantColors.textPrimary,
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required String currencySymbol,
    required Color color,
    bool isBold = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.vantColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$currencySymbol${formatTurkishCurrency(amount, decimalDigits: 0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.doc_text,
            size: 64,
            color: context.vantColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.simpleNoTransactions,
            style: TextStyle(
              fontSize: 16,
              color: context.vantColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    List<Expense> expenses,
    String currencySymbol,
    AppLocalizations l10n,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => Divider(
        color: context.vantColors.cardBorder,
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildTransactionRow(expense, currencySymbol, l10n);
      },
    );
  }

  Widget _buildTransactionRow(
    Expense expense,
    String currencySymbol,
    AppLocalizations l10n,
  ) {
    final dateFormat = DateFormat('dd/MM');
    final dateStr = dateFormat.format(expense.date);

    final isExpense = expense.decision == ExpenseDecision.yes;
    final amountColor = isExpense
        ? context.vantColors.error
        : context.vantColors.success;
    final amountPrefix = isExpense ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 50,
            child: Text(
              dateStr,
              style: TextStyle(
                fontSize: 13,
                color: context.vantColors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          // Category
          SizedBox(
            width: 80,
            child: Text(
              expense.category,
              style: TextStyle(
                fontSize: 13,
                color: context.vantColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Description (subCategory)
          Expanded(
            child: Text(
              expense.subCategory ?? '',
              style: TextStyle(
                fontSize: 14,
                color: context.vantColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Amount
          Text(
            '$amountPrefix$currencySymbol${formatTurkishCurrency(expense.amount, decimalDigits: 0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amountColor,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
