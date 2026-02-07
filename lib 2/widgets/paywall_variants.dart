import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Paywall Variant A: Feature-focused
class PaywallVariantA extends StatelessWidget {
  final VoidCallback onSubscribe;
  final String price;
  final bool isYearly;

  const PaywallVariantA({
    super.key,
    required this.onSubscribe,
    required this.price,
    this.isYearly = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final features = [
      (CupertinoIcons.infinite, l10n.unlimitedAiChat),
      (CupertinoIcons.mic, l10n.voiceInput),
      (CupertinoIcons.scope, l10n.unlimitedPursuits),
      (CupertinoIcons.chart_bar_alt_fill, 'Gelismis Raporlar'),
      (CupertinoIcons.doc_on_doc_fill, l10n.statementImport),
      (CupertinoIcons.money_dollar_circle, 'Coklu Para Birimi'),
    ];

    return Column(
      children: [
        // Header
        Text(
          'Vantag Pro',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tüm özelliklerin kilidini aç',
          style: TextStyle(
            fontSize: 16,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),

        // Feature list
        ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(f.$1, size: 20, color: context.appColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.checkmark_circle,
                    size: 20,
                    color: context.appColors.success,
                  ),
                ],
              ),
            )),

        const SizedBox(height: 32),

        // CTA
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              '$price / ${isYearly ? l10n.year : l10n.month}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paywall Variant B: Price-focused with discount emphasis
class PaywallVariantB extends StatelessWidget {
  final VoidCallback onSubscribe;
  final String monthlyPrice;
  final String yearlyPrice;
  final int discountPercent;

  const PaywallVariantB({
    super.key,
    required this.onSubscribe,
    required this.monthlyPrice,
    required this.yearlyPrice,
    this.discountPercent = 50,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Discount banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.appColors.primary,
                context.appColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            '%$discountPercent İndirim',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Price comparison
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              monthlyPrice,
              style: TextStyle(
                fontSize: 24,
                color: context.appColors.textTertiary,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              CupertinoIcons.arrow_right,
              color: context.appColors.success,
            ),
            const SizedBox(width: 16),
            Text(
              yearlyPrice,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.appColors.success,
              ),
            ),
          ],
        ),
        Text(
          l10n.perMonth,
          style: TextStyle(
            fontSize: 14,
            color: context.appColors.textSecondary,
          ),
        ),

        const SizedBox(height: 32),

        // Urgency text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.appColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.appColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                color: context.appColors.warning,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sınırlı süreli teklif!',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // CTA
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'İndirimimi Al',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paywall Variant C: Social proof
class PaywallVariantC extends StatelessWidget {
  final VoidCallback onSubscribe;
  final String price;
  final int userCount;
  final double rating;

  const PaywallVariantC({
    super.key,
    required this.onSubscribe,
    required this.price,
    this.userCount = 50000,
    this.rating = 4.8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // User count
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person_2,
              size: 24,
              color: context.appColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '${_formatNumber(userCount)}+',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: context.appColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          'Mutlu kullanıcı',
          style: TextStyle(
            fontSize: 16,
            color: context.appColors.textSecondary,
          ),
        ),

        const SizedBox(height: 24),

        // Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              5,
              (i) => Icon(
                i < rating.floor()
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.star,
                size: 24,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.appColors.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Testimonials
        _buildTestimonial(
          context,
          'Ayda 2000₺ biriktirdim!',
          'Ahmet K.',
          '⭐⭐⭐⭐⭐',
        ),
        const SizedBox(height: 12),
        _buildTestimonial(
          context,
          'En iyi finans uygulaması',
          'Zeynep T.',
          '⭐⭐⭐⭐⭐',
        ),

        const SizedBox(height: 32),

        // CTA
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Binlerce Kullanıcıya Katıl',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          price,
          style: TextStyle(
            fontSize: 14,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonial(
    BuildContext context,
    String text,
    String author,
    String stars,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stars, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            '"$text"',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '— $author',
            style: TextStyle(
              fontSize: 12,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
