import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Share card widget
/// Instagram story size: 1080x1920 (3:1 scale = 360x640)
class ShareCardWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String categoryName;
  final int yearlyDays;
  final double? yearlyAmount;
  final String? frequency;

  const ShareCardWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.categoryName,
    required this.yearlyDays,
    this.yearlyAmount,
    this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: 360,
      height: 640,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [VantColors.cardBackground, VantColors.primary],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 52, color: iconColor),
          ),
          const SizedBox(height: 20),

          // Main number
          Text(
            l10n.shareCardDays(yearlyDays),
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            l10n.shareCardDescription(categoryName),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Color(0xCCFFFFFF)),
          ),

          // Optional: Amount
          if (yearlyAmount != null) ...[
            const SizedBox(height: 12),
            Text(
              '\$${_formatCurrency(yearlyAmount!)}',
              style: const TextStyle(fontSize: 16, color: Color(0x88FFFFFF)),
            ),
          ],

          // Optional: Frequency
          if (frequency != null) ...[
            const SizedBox(height: 8),
            Text(
              frequency!,
              style: const TextStyle(fontSize: 14, color: Color(0x60FFFFFF)),
            ),
          ],

          const SizedBox(height: 32),

          // Divider
          Container(width: 100, height: 1, color: const Color(0x40FFFFFF)),
          const SizedBox(height: 16),

          // CTA
          Text(
            l10n.shareCardQuestion,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Logo/URL
          const Text(
            'vantag.app',
            style: TextStyle(
              fontSize: 14,
              color: Color(0x88FFFFFF),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)},000';
    }
    return amount.toStringAsFixed(0);
  }
}
