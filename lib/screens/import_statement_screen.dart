import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/pro_provider.dart';
import '../providers/finance_provider.dart';
import '../services/statement_parse_service.dart';
import '../services/free_tier_service.dart';
import '../services/expense_history_service.dart';
import '../services/sound_service.dart';
import '../models/expense.dart';
import '../theme/theme.dart';
import 'paywall_screen.dart';

/// Screen for importing bank statements (PDF/CSV)
class ImportStatementScreen extends StatefulWidget {
  const ImportStatementScreen({super.key});

  @override
  State<ImportStatementScreen> createState() => _ImportStatementScreenState();
}

class _ImportStatementScreenState extends State<ImportStatementScreen> {
  bool _isProcessing = false;
  bool _isImporting = false;
  List<ParsedTransaction>? _transactions;
  Set<int> _selectedIndices = {};
  String? _error;
  int _remainingImports = 0;
  bool _limitChecked = false;

  @override
  void initState() {
    super.initState();
    _checkLimit();
  }

  Future<void> _checkLimit() async {
    final isPro = context.read<ProProvider>().isPro;
    final remaining = await FreeTierService().getRemainingStatementImports(
      isPro,
    );
    if (mounted) {
      setState(() {
        _remainingImports = remaining;
        _limitChecked = true;
      });
    }
  }

  Future<void> _pickFile() async {
    final l10n = AppLocalizations.of(context);
    final isPro = context.read<ProProvider>().isPro;

    // Check limit first
    final limitResult = await FreeTierService().canImportStatement(isPro);
    if (!limitResult.canUse) {
      _showLimitReachedDialog(l10n);
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'csv'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      await _processFile(file);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = l10n.importStatementError;
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processFile(File file) async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isProcessing = true;
      _error = null;
      _transactions = null;
    });

    try {
      final parseService = StatementParseService();
      final result = await parseService.parseFile(file);

      if (!mounted) return;

      if (result.hasError) {
        setState(() {
          _error = result.error;
          _isProcessing = false;
        });
        return;
      }

      if (result.isEmpty) {
        setState(() {
          _error = l10n.importStatementNoTransactions;
          _isProcessing = false;
        });
        return;
      }

      // All transactions selected by default
      setState(() {
        _transactions = result.transactions;
        _selectedIndices = Set<int>.from(
          List.generate(result.transactions.length, (i) => i),
        );
        _isProcessing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = l10n.importStatementError;
          _isProcessing = false;
        });
      }
    }
  }

  void _showLimitReachedDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.vantColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: context.vantColors.warning,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.importStatementLimitReached,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.vantColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.importStatementLimitReachedDesc,
          style: TextStyle(color: context.vantColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.vantColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.vantColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.upgradeToPro),
          ),
        ],
      ),
    );
  }

  Future<void> _importSelected() async {
    if (_transactions == null || _selectedIndices.isEmpty) return;

    final l10n = AppLocalizations.of(context);

    setState(() => _isImporting = true);

    try {
      final expenseService = ExpenseHistoryService();
      int importedCount = 0;

      for (final index in _selectedIndices) {
        final transaction = _transactions![index];

        // Only import expenses
        if (transaction.isExpense) {
          final expense = Expense(
            amount: transaction.amount.abs(),
            category: transaction.category,
            date: transaction.date,
            hoursRequired: 0, // Not calculated for imported transactions
            daysRequired: 0, // Not calculated for imported transactions
            decision: ExpenseDecision.yes,
          );

          await expenseService.addExpense(expense);
          importedCount++;
        }
      }

      // Increment usage count after successful import
      await FreeTierService().incrementStatementImportCount();

      // Refresh finance provider
      if (mounted) {
        context.read<FinanceProvider>().refresh();
      }

      soundService.playSuccess();
      HapticFeedback.mediumImpact();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importStatementSuccess(importedCount)),
            backgroundColor: context.vantColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isImporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importStatementError),
            backgroundColor: context.vantColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleSelection(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _selectAll() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndices = Set<int>.from(
        List.generate(_transactions!.length, (i) => i),
      );
    });
  }

  void _deselectAll() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.vantColors.background,
      appBar: AppBar(
        backgroundColor: context.vantColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.arrow_left,
            color: context.vantColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.importStatementTitle,
          style: TextStyle(
            color: context.vantColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_limitChecked)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.vantColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.importStatementMonthlyLimit(_remainingImports),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.vantColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _transactions == null
          ? _buildFilePickerView(l10n)
          : _buildReviewView(l10n),
    );
  }

  Widget _buildFilePickerView(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: _isProcessing
                  ? _buildProcessingState(l10n)
                  : _buildPickerCard(l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: context.vantColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.importStatementProcessing,
          style: TextStyle(
            fontSize: 16,
            color: context.vantColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerCard(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60),
            decoration: BoxDecoration(
              color: context.vantColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.vantColors.primary.withValues(alpha: 0.3),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.vantColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_up_doc_fill,
                    size: 40,
                    color: context.vantColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.importStatementDragDrop,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.vantColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.importStatementSupportedFormats,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.vantColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.vantColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: context.vantColors.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: context.vantColors.error),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(CupertinoIcons.folder_open),
            label: Text(l10n.importStatementSelectFile),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.vantColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewView(AppLocalizations l10n) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: context.vantColors.surface,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.importStatementReviewTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.importStatementReviewDesc,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _selectedIndices.length == _transactions!.length
                    ? _deselectAll
                    : _selectAll,
                child: Text(
                  _selectedIndices.length == _transactions!.length
                      ? l10n.importStatementDeselectAll
                      : l10n.importStatementSelectAll,
                ),
              ),
            ],
          ),
        ),

        // Transaction list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _transactions!.length,
            itemBuilder: (context, index) {
              final transaction = _transactions![index];
              final isSelected = _selectedIndices.contains(index);

              // Skip non-expense transactions in UI (we only import expenses)
              if (!transaction.isExpense) {
                return const SizedBox.shrink();
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: context.vantColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: context.vantColors.primary, width: 2)
                      : null,
                ),
                child: ListTile(
                  onTap: () => _toggleSelection(index),
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(index),
                    activeColor: context.vantColors.primary,
                  ),
                  title: Text(
                    transaction.description,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.vantColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        transaction.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.vantColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.vantColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '-${transaction.amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.vantColors.error,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.vantColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedIndices.isEmpty || _isImporting
                    ? null
                    : _importSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.vantColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: context.vantColors.primary.withValues(
                    alpha: 0.3,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isImporting
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      )
                    : Text(
                        l10n.importStatementImportSelected(
                          _selectedIndices.length,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
