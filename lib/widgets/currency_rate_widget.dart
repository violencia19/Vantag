import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../screens/currency_detail_screen.dart';

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

  String _formatRate(double rate) {
    if (rate >= 1000) {
      return rate.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return rate.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: _buildContent(l10n),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
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
                AppColors.textTertiary.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.ratesLoading,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
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
          const Icon(
            LucideIcons.alertCircle,
            size: 14,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.ratesLoadFailed,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                l10n.retry,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Normal view
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRateItem('\$', _formatRate(rates!.usdRate)),
        _buildDivider(),
        _buildRateItem('\u20AC', _formatRate(rates!.eurRate)),
        _buildDivider(),
        _buildGoldRateItem(l10n),
        const SizedBox(width: 8),
        Icon(
          LucideIcons.chevronRight,
          size: 16,
          color: AppColors.textTertiary.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  Widget _buildGoldRateItem(AppLocalizations l10n) {
    final showWarning = rates != null && !rates!.goldFromApi;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.gold,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${_formatRate(rates!.goldRate)} \u20BA',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (showWarning) ...[
          const SizedBox(width: 4),
          Tooltip(
            message: l10n.goldPriceNotUpdated,
            child: Icon(
              LucideIcons.info,
              size: 12,
              color: AppColors.warning.withValues(alpha: 0.8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRateItem(String symbol, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '|',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
