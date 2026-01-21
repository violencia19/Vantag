import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';

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
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF6C63FF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 24),

          // Main number
          Text(
            l10n.shareCardDays(yearlyDays),
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            l10n.shareCardDescription(categoryName),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),

          // Optional: Amount
          if (yearlyAmount != null) ...[
            const SizedBox(height: 12),
            Text(
              '\$${_formatCurrency(yearlyAmount!)}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0x88FFFFFF),
              ),
            ),
          ],

          // Optional: Frequency
          if (frequency != null) ...[
            const SizedBox(height: 8),
            Text(
              frequency!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0x60FFFFFF),
              ),
            ),
          ],

          const SizedBox(height: 48),

          // Divider
          Container(
            width: 100,
            height: 1,
            color: const Color(0x40FFFFFF),
          ),
          const SizedBox(height: 24),

          // CTA
          Text(
            l10n.shareCardQuestion,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // Logo/URL
          const Text(
            'vantag.app',
            style: TextStyle(
              fontSize: 14,
              color: Color(0x88FFFFFF),
              letterSpacing: 1,
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
