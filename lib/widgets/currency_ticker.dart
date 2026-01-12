import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/currency.dart';
import '../providers/currency_provider.dart';
import '../services/currency_service.dart';
import '../theme/theme.dart';

/// Currency ticker data model
class _TickerData {
  final String flag;
  final String code;
  final String value;

  const _TickerData({
    required this.flag,
    required this.code,
    required this.value,
  });
}

/// Currency Ticker Widget
/// Shows relevant exchange rates based on selected currency
class CurrencyTicker extends StatelessWidget {
  final ExchangeRates? rates;
  final bool isLoading;

  const CurrencyTicker({
    super.key,
    this.rates,
    this.isLoading = false,
  });

  /// Get ticker items based on selected currency
  List<_TickerData> _getTickerItems(Currency selected, ExchangeRates? rates) {
    if (rates == null) {
      return [
        const _TickerData(flag: '🇺🇸', code: 'USD', value: '-'),
        const _TickerData(flag: '🇪🇺', code: 'EUR', value: '-'),
        const _TickerData(flag: '🪙', code: 'GOLD', value: '-'),
      ];
    }

    // Base rates from API (all TRY-based)
    final usdTry = rates.usdRate;
    final eurTry = rates.eurRate;
    final goldGramTry = rates.goldRate; // TRY per gram
    final goldOzUsd = rates.goldOzUsd; // USD per oz

    // Cross rates calculated from TRY rates
    final eurUsd = usdTry > 0 ? eurTry / usdTry : 0.0; // EUR/USD
    final usdEur = eurTry > 0 ? usdTry / eurTry : 0.0; // USD/EUR

    // GBP approximate rates (not available from TCMB)
    const gbpUsd = 1.27; // Approximate GBP/USD rate
    const gbpEur = 1.18; // Approximate GBP/EUR rate

    // SAR is pegged to USD at 3.75
    const sarUsd = 3.75;

    switch (selected.code) {
      case 'TRY':
        // TRY selected → USD/TRY, EUR/TRY, GOLD (₺/gr)
        return [
          _TickerData(
            flag: '🇺🇸',
            code: 'USD',
            value: '${_formatNumber(usdTry, 2)} ₺',
          ),
          _TickerData(
            flag: '🇪🇺',
            code: 'EUR',
            value: '${_formatNumber(eurTry, 2)} ₺',
          ),
          _TickerData(
            flag: '🪙',
            code: 'GOLD',
            value: '${_formatNumber(goldGramTry, 0)} ₺/gr',
          ),
        ];

      case 'USD':
        // USD selected → EUR/USD, TRY/USD, GOLD ($/oz)
        final tryUsd = usdTry > 0 ? 1 / usdTry : 0.0;
        return [
          _TickerData(
            flag: '🇪🇺',
            code: 'EUR',
            value: '${_formatNumber(eurUsd, 4)} \$',
          ),
          _TickerData(
            flag: '🇹🇷',
            code: 'TRY',
            value: '${_formatNumber(tryUsd, 4)} \$',
          ),
          _TickerData(
            flag: '🪙',
            code: 'GOLD',
            value: goldOzUsd != null ? '${_formatNumber(goldOzUsd, 0)} \$/oz' : '-',
          ),
        ];

      case 'EUR':
        // EUR selected → USD/EUR, TRY/EUR, GOLD (€/oz)
        final tryEur = eurTry > 0 ? 1 / eurTry : 0.0;
        final goldOzEur = goldOzUsd != null && eurUsd > 0 ? goldOzUsd / eurUsd : null;
        return [
          _TickerData(
            flag: '🇺🇸',
            code: 'USD',
            value: '${_formatNumber(usdEur, 4)} €',
          ),
          _TickerData(
            flag: '🇹🇷',
            code: 'TRY',
            value: '${_formatNumber(tryEur, 4)} €',
          ),
          _TickerData(
            flag: '🪙',
            code: 'GOLD',
            value: goldOzEur != null ? '${_formatNumber(goldOzEur, 0)} €/oz' : '-',
          ),
        ];

      case 'GBP':
        // GBP selected → USD/GBP, EUR/GBP, GOLD (£/oz)
        final usdGbp = 1 / gbpUsd; // How many GBP per USD
        final eurGbp = 1 / gbpEur; // How many GBP per EUR
        final goldOzGbp = goldOzUsd != null ? goldOzUsd / gbpUsd : null;
        return [
          _TickerData(
            flag: '🇺🇸',
            code: 'USD',
            value: '${_formatNumber(usdGbp, 4)} £',
          ),
          _TickerData(
            flag: '🇪🇺',
            code: 'EUR',
            value: '${_formatNumber(eurGbp, 4)} £',
          ),
          _TickerData(
            flag: '🪙',
            code: 'GOLD',
            value: goldOzGbp != null ? '${_formatNumber(goldOzGbp, 0)} £/oz' : '-',
          ),
        ];

      case 'SAR':
        // SAR selected → USD/SAR, EUR/SAR, GOLD (﷼/oz)
        final eurSar = eurUsd * sarUsd; // EUR in SAR
        final goldOzSar = goldOzUsd != null ? goldOzUsd * sarUsd : null;
        return [
          _TickerData(
            flag: '🇺🇸',
            code: 'USD',
            value: '${_formatNumber(sarUsd, 2)} ﷼',
          ),
          _TickerData(
            flag: '🇪🇺',
            code: 'EUR',
            value: '${_formatNumber(eurSar, 2)} ﷼',
          ),
          _TickerData(
            flag: '🪙',
            code: 'GOLD',
            value: goldOzSar != null ? '${_formatNumber(goldOzSar, 0)} ﷼/oz' : '-',
          ),
        ];

      default:
        // Default: Show USD and EUR in TRY
        return [
          _TickerData(
            flag: '🇺🇸',
            code: 'USD',
            value: '${_formatNumber(usdTry, 2)} ₺',
          ),
          _TickerData(
            flag: '🇪🇺',
            code: 'EUR',
            value: '${_formatNumber(eurTry, 2)} ₺',
          ),
          _TickerData(
            flag: '🪙',
            code: 'GOLD',
            value: '${_formatNumber(goldGramTry, 0)} ₺/gr',
          ),
        ];
    }
  }

  String _formatNumber(double value, int decimals) {
    if (value >= 1000) {
      return value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return value.toStringAsFixed(decimals);
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final selectedCurrency = currencyProvider.currency;
    final items = _getTickerItems(selectedCurrency, rates);

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textTertiary.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Loading rates...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) => _buildTickerItem(item)).toList(),
      ),
    );
  }

  Widget _buildTickerItem(_TickerData item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.flag,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 4),
        Text(
          item.value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
