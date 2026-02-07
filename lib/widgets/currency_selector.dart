import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/currency.dart';
import '../providers/currency_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/pro_provider.dart';
import '../services/free_tier_service.dart';
import '../theme/theme.dart';
import 'upgrade_dialog.dart';

/// Show currency selector bottom sheet
void showCurrencySelector(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final currencyProvider = context.read<CurrencyProvider>();
  final financeProvider = context.read<FinanceProvider>();
  final proProvider = context.read<ProProvider>();
  final isPremium = proProvider.isPro;
  final freeTierService = FreeTierService();

  showModalBottomSheet(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    backgroundColor: context.vantColors.surface,
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
                color: context.vantColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.selectCurrency,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textPrimary,
                ),
              ),
            ),
            // Free tier note
            if (!isPremium)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.vantColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.vantColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.info_circle_fill,
                        size: 16,
                        color: context.vantColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.freeUserCurrencyNote(l10n.allCurrencies),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.vantColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Currency options
            ...supportedCurrencies.map((currency) {
              final isSelected =
                  currencyProvider.currency.code == currency.code;
              final isLocked = !freeTierService.isCurrencyAvailable(
                isPremium,
                currency.code,
              );

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
                        color: isLocked
                            ? context.vantColors.textTertiary
                            : context.vantColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currency.symbol,
                      style: TextStyle(
                        color: isLocked
                            ? context.vantColors.textTertiary.withValues(
                                alpha: 0.5,
                              )
                            : context.vantColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  isLocked ? l10n.currencyLocked : currency.name,
                  style: TextStyle(
                    color: isLocked
                        ? context.vantColors.textTertiary.withValues(alpha: 0.7)
                        : context.vantColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
                trailing: isLocked
                    ? Icon(
                        CupertinoIcons.lock,
                        size: 20,
                        color: context.vantColors.textTertiary,
                      )
                    : isSelected
                    ? Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: context.vantColors.primary,
                      )
                    : null,
                onTap: () async {
                  if (isLocked) {
                    Navigator.pop(context);
                    UpgradeDialog.show(context, l10n.multiCurrencyPremium);
                    return;
                  }

                  Navigator.pop(context);

                  // Para birimi değiştir
                  await currencyProvider.setCurrency(currency);

                  // Gelir kaynaklarını yeni para birimine convert et
                  await _convertIncomeSources(
                    currencyProvider,
                    financeProvider,
                    currency.code,
                  );

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

/// Gelir kaynaklarını yeni para birimine convert et
Future<void> _convertIncomeSources(
  CurrencyProvider currencyProvider,
  FinanceProvider financeProvider,
  String targetCurrency,
) async {
  final currentSources = financeProvider.incomeSources;
  if (currentSources.isEmpty) return;

  // Önce kurların yüklü olduğundan emin ol
  if (!currencyProvider.hasRates) {
    await currencyProvider.fetchRates();
  }

  // Tüm gelir kaynaklarını convert et
  final convertedSources = currencyProvider.convertIncomeSources(
    currentSources,
    targetCurrency,
  );

  if (convertedSources != null) {
    await financeProvider.updateIncomeSourcesWithConversion(convertedSources);
  } else {
    // Conversion failed - log for debugging
    debugPrint(
      '[CurrencySelector] Income conversion failed - rates not available',
    );
  }
}
