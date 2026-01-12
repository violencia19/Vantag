import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/currency.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart';

/// Show currency selector bottom sheet
void showCurrencySelector(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final currencyProvider = context.read<CurrencyProvider>();

  showModalBottomSheet(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.95),
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.selectCurrency,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Currency options
            ...supportedCurrencies.map((currency) {
              final isSelected = currencyProvider.currency.code == currency.code;
              return ListTile(
                leading: Text(
                  currency.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Row(
                  children: [
                    Text(
                      currency.code,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currency.symbol,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  currency.name,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
                trailing: isSelected
                    ? Icon(PhosphorIconsDuotone.checkCircle, color: AppColors.primary)
                    : null,
                onTap: () async {
                  Navigator.pop(context);
                  await currencyProvider.setCurrency(currency);
                  HapticFeedback.lightImpact();
                },
              );
            }),
          ],
        ),
      ),
    ),
  );
}
