import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/expense.dart';
import '../providers/currency_provider.dart';
import '../services/budget_service.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

/// Aktif taksitleri gösteren kart
class InstallmentSummaryCard extends StatelessWidget {
  final BudgetService budgetService;

  const InstallmentSummaryCard({
    super.key,
    required this.budgetService,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyProvider = context.watch<CurrencyProvider>();
    final installments = budgetService.activeInstallments;

    // Taksit yoksa gösterme
    if (installments.isEmpty) return const SizedBox.shrink();

    final monthlyBurden = budgetService.monthlyInstallmentBurden;
    final totalDebt = budgetService.totalRemainingDebt;
    final totalInterest = budgetService.totalInterestAmount;
    final interestHours = budgetService.totalInterestHours;

    // Currency conversion
    final monthlyBurdenConverted = currencyProvider.convertFromTRY(monthlyBurden);
    final totalDebtConverted = currencyProvider.convertFromTRY(totalDebt);
    final totalInterestConverted = currencyProvider.convertFromTRY(totalInterest);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsDuotone.creditCard,
                    color: Colors.orange.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.activeInstallments,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.installmentCount(installments.length),
                  style: TextStyle(
                    color: Colors.orange.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Taksit listesi (max 3 göster)
          ...installments.take(3).map(
                (e) => _buildInstallmentRow(context, e, currencyProvider, l10n),
              ),

          // Daha fazla varsa
          if (installments.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.moreInstallments(installments.length - 3),
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),

          Divider(
            color: Colors.white.withOpacity(0.1),
            height: 24,
          ),

          // Özet
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  label: l10n.monthlyBurden,
                  value: formatTurkishCurrency(
                    monthlyBurdenConverted,
                    decimalDigits: 0,
                    showDecimals: false,
                  ),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  label: l10n.remainingDebt,
                  value: formatTurkishCurrency(
                    totalDebtConverted,
                    decimalDigits: 0,
                    showDecimals: false,
                  ),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          // Vade farkı uyarısı
          if (totalInterest > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsDuotone.trendUp,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.totalInterestCost(
                        formatTurkishCurrency(
                          totalInterestConverted,
                          decimalDigits: 0,
                          showDecimals: false,
                        ),
                        interestHours.toStringAsFixed(0),
                      ),
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstallmentRow(
    BuildContext context,
    Expense expense,
    CurrencyProvider currencyProvider,
    AppLocalizations l10n,
  ) {
    final currentInstallment = expense.currentInstallment ?? 1;
    final totalInstallments = expense.installmentCount ?? 1;
    final progress = currentInstallment / totalInstallments;
    final installmentAmount = currencyProvider.convertFromTRY(expense.installmentAmount);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  expense.subCategory?.isNotEmpty == true
                      ? '${expense.category} - ${expense.subCategory}'
                      : expense.category,
                  style: const TextStyle(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${formatTurkishCurrency(installmentAmount, decimalDigits: 0, showDecimals: false)}/${l10n.monthAbbreviation}',
                style: TextStyle(
                  color: Colors.orange.shade300,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(
                      progress > 0.8 ? AppColors.success : Colors.orange,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currentInstallment/$totalInstallments',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
