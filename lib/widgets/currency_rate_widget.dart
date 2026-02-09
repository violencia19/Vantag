
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/currency.dart';
import '../providers/currency_provider.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../screens/currency_detail_screen.dart';

/// Rate item data model
class _RateItem {
  final String symbol;
  final String value;
  final bool showWarning;

  const _RateItem({
    required this.symbol,
    required this.value,
    this.showWarning = false,
  });
}

class CurrencyRateWidget extends StatelessWidget {
  final ExchangeRates? rates;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;

  const CurrencyRateWidget({
    super.key,
    this.rates,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
  });

  /// Main currencies to show in ticker (excluding selected one)
  static const _mainCurrencyCodes = ['USD', 'EUR', 'GBP'];

  String _formatRate(double rate, int decimals) {
    if (rate >= 1000) {
      return rate
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return rate.toStringAsFixed(decimals);
  }

  /// Get TRY value of a currency (how many TRY per 1 unit)
  double _getTryValue(String code, ExchangeRates rates) {
    switch (code) {
      case 'TRY':
        return 1.0;
      case 'USD':
        return rates.usdRate;
      case 'EUR':
        return rates.eurRate;
      case 'GBP':
        // GBP not from TCMB, approximate via USD
        return rates.usdRate * 1.27;
      case 'SAR':
        // SAR pegged to USD at 3.75
        return rates.usdRate / 3.75;
      default:
        return 1.0;
    }
  }

  /// Calculate exchange rate: how many units of [base] per 1 unit of [target]
  double _calculateRate(String targetCode, Currency base, ExchangeRates rates) {
    final targetInTry = _getTryValue(targetCode, rates);
    final baseInTry = _getTryValue(base.code, rates);

    if (baseInTry <= 0) return 0;
    return targetInTry / baseInTry;
  }

  /// Build currency item for ticker
  _RateItem _buildCurrencyItem(
    String targetCode,
    Currency base,
    ExchangeRates rates,
  ) {
    final target = getCurrencyByCode(targetCode);
    final rate = _calculateRate(targetCode, base, rates);

    // Use 2 decimals for TRY (large numbers), 4 for others
    final decimals = base.code == 'TRY' ? 2 : 4;

    return _RateItem(
      symbol: target.symbol,
      value: '${_formatRate(rate, decimals)} ${base.symbol}',
    );
  }

  /// Build gold item for ticker
  _RateItem _buildGoldItem(
    Currency base,
    ExchangeRates rates,
    AppLocalizations l10n,
  ) {
    final goldOzUsd = rates.goldOzUsd;
    final usdTry = rates.usdRate;
    final showWarning = !rates.goldFromApi;

    if (base.code == 'TRY') {
      // TRY: Show gold per gram
      final goldGramTry = (goldOzUsd ?? 0) * usdTry / 31.1035;
      return _RateItem(
        symbol: l10n.gold,
        value: '${_formatRate(goldGramTry, 0)} ₺/${base.goldUnit}',
        showWarning: showWarning,
      );
    } else {
      // Other currencies: Show gold per ounce in selected currency
      if (goldOzUsd == null) {
        return _RateItem(
          symbol: l10n.gold,
          value: '-',
          showWarning: showWarning,
        );
      }

      final baseInTry = _getTryValue(base.code, rates);
      final goldInBase = (goldOzUsd * usdTry) / baseInTry;

      return _RateItem(
        symbol: l10n.gold,
        value: '${_formatRate(goldInBase, 0)} ${base.symbol}/${base.goldUnit}',
        showWarning: showWarning,
      );
    }
  }

  /// Get rate items based on selected currency - DYNAMIC!
  /// Removes selected currency from list, shows remaining + gold
  List<_RateItem> _getRateItems(
    Currency selected,
    ExchangeRates rates,
    AppLocalizations l10n,
  ) {
    final items = <_RateItem>[];

    // Filter out selected currency from main list
    final currenciesToShow = _mainCurrencyCodes
        .where((code) => code != selected.code)
        .toList();

    // Build currency items
    for (final code in currenciesToShow) {
      items.add(_buildCurrencyItem(code, selected, rates));
    }

    // Gold always at the end
    items.add(_buildGoldItem(selected, rates, l10n));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();
    final selectedCurrency = currencyProvider.currency;

    return Semantics(
      button: true,
      label: l10n.currencyRatesDescription,
      child: GestureDetector(
        onTap: () {
          if (rates != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CurrencyDetailScreen(rates: rates!),
              ),
            );
          }
        },
        child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.vantColors.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
                // Subtle inner glow
                boxShadow: [
                  BoxShadow(
                    color: context.vantColors.primary.withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: _buildContent(context, l10n, selectedCurrency),
            ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    Currency selectedCurrency,
  ) {
    // Loading state
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.vantColors.textTertiary.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.ratesLoading,
            style: TextStyle(
              fontSize: 12,
              color: context.vantColors.textTertiary,
            ),
          ),
        ],
      );
    }

    // Error state
    if (hasError || rates == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 14,
            color: context.vantColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.ratesLoadFailed,
            style: TextStyle(
              fontSize: 12,
              color: context.vantColors.textTertiary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: l10n.retry,
              child: GestureDetector(
                onTap: onRetry,
                child: Text(
                  l10n.retry,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.vantColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Get currency-aware rate items
    final rateItems = _getRateItems(selectedCurrency, rates!, l10n);

    // Normal view with currency-aware rates - FittedBox prevents overflow
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < rateItems.length; i++) ...[
            if (i > 0) _buildDivider(context),
            _buildRateItem(context, rateItems[i], l10n),
          ],
          const SizedBox(width: 8),
          Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: context.vantColors.textTertiary.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildRateItem(
    BuildContext context,
    _RateItem item,
    AppLocalizations l10n,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.symbol,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.vantColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          item.value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.vantColors.textPrimary,
          ),
        ),
        if (item.showWarning) ...[
          const SizedBox(width: 4),
          Tooltip(
            message: l10n.goldPriceNotUpdated,
            child: Icon(
              CupertinoIcons.info_circle,
              size: 12,
              color: context.vantColors.warning.withValues(alpha: 0.8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '|',
        style: TextStyle(
          fontSize: 12,
          color: context.vantColors.textTertiary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
