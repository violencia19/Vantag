import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';
import '../services/budget_service.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

/// Bütçe dağılımını gösteren kart
/// Zorunlu giderler vs İsteğe bağlı harcamalar
class BudgetBreakdownCard extends StatelessWidget {
  final BudgetService budgetService;

  const BudgetBreakdownCard({
    super.key,
    required this.budgetService,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyProvider = context.watch<CurrencyProvider>();

    final mandatory = budgetService.mandatoryExpenses;
    final discretionary = budgetService.discretionaryExpenses;
    final total = mandatory + discretionary;
    final mandatoryHours = budgetService.mandatoryHours;
    final discretionaryHours = budgetService.usedHours;

    // Hiç harcama yoksa gösterme
    if (total <= 0) return const SizedBox.shrink();

    final mandatoryPercent = total > 0 ? (mandatory / total * 100) : 0.0;
    final discretionaryPercent = total > 0 ? (discretionary / total * 100) : 0.0;

    // Currency conversion
    final mandatoryConverted = currencyProvider.convertFromTRY(mandatory);
    final discretionaryConverted = currencyProvider.convertFromTRY(discretionary);
    final remainingConverted = currencyProvider.convertFromTRY(budgetService.remainingBudget.abs());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                PhosphorIconsDuotone.chartPie,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.monthlySpendingBreakdown,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar (stacked)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  // Zorunlu (mavi)
                  if (mandatoryPercent > 0)
                    Expanded(
                      flex: mandatoryPercent.round().clamp(1, 100),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                          ),
                        ),
                      ),
                    ),
                  // İsteğe bağlı (turuncu)
                  if (discretionaryPercent > 0)
                    Expanded(
                      flex: discretionaryPercent.round().clamp(1, 100),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade400,
                              Colors.orange.shade600,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Detaylar
          Row(
            children: [
              // Zorunlu giderler
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: PhosphorIconsDuotone.lock,
                  iconColor: Colors.blue,
                  label: l10n.mandatoryExpenses,
                  amount: mandatoryConverted,
                  hours: mandatoryHours,
                  percent: mandatoryPercent,
                  currencySymbol: currencyProvider.symbol,
                  l10n: l10n,
                ),
              ),
              const SizedBox(width: 16),
              // İsteğe bağlı
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: PhosphorIconsDuotone.shoppingBag,
                  iconColor: Colors.orange,
                  label: l10n.discretionaryExpenses,
                  amount: discretionaryConverted,
                  hours: discretionaryHours,
                  percent: discretionaryPercent,
                  currencySymbol: currencyProvider.symbol,
                  l10n: l10n,
                ),
              ),
            ],
          ),

          // Kalan bütçe bilgisi
          if (budgetService.remainingBudget > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsDuotone.checkCircle,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.remainingHoursToSpend(
                        budgetService.remainingHours.toStringAsFixed(0),
                      ),
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Bütçe aşıldı uyarısı
          if (budgetService.isOverBudget) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsDuotone.warning,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.budgetExceeded(
                        formatTurkishCurrency(
                          remainingConverted,
                          decimalDigits: 0,
                          showDecimals: false,
                        ),
                      ),
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required double amount,
    required double hours,
    required double percent,
    required String currencySymbol,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatTurkishCurrency(amount, decimalDigits: 0, showDecimals: false),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${hours.toStringAsFixed(1)} ${l10n.hourAbbreviation} · %${percent.toStringAsFixed(0)}',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
