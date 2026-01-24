import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Bottom sheet explaining Multi-Currency as a PRO feature
/// Shows lock icon with list of PRO benefits
class MultiCurrencyProSheet extends StatelessWidget {
  const MultiCurrencyProSheet({super.key});

  /// Show the Multi-Currency PRO sheet
  static void show(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const MultiCurrencyProSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Lock icon with crown
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.appColors.gold.withValues(alpha: 0.2),
                      context.appColors.gold.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      PhosphorIconsDuotone.lock,
                      size: 36,
                      color: context.appColors.gold,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.appColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsFill.crown,
                          size: 14,
                          color: context.appColors.background,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                l10n.multiCurrencyProTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                l10n.multiCurrencyProDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Divider
              Divider(color: context.appColors.cardBorder),
              const SizedBox(height: 16),

              // PRO benefits title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.premiumIncludes,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Benefits list
              _buildBenefitRow(
                context,
                PhosphorIconsDuotone.currencyCircleDollar,
                l10n.multiCurrencyBenefit,
              ),
              _buildBenefitRow(
                context,
                PhosphorIconsDuotone.chatCircle,
                l10n.unlimitedAiChat,
              ),
              _buildBenefitRow(
                context,
                PhosphorIconsDuotone.target,
                l10n.unlimitedPursuits,
              ),
              _buildBenefitRow(
                context,
                PhosphorIconsDuotone.export,
                l10n.exportFeature,
              ),
              _buildBenefitRow(
                context,
                PhosphorIconsDuotone.chartBar,
                l10n.fullReports,
              ),
              _buildBenefitRow(
                context,
                PhosphorIconsDuotone.shareFat,
                l10n.cleanShareCards,
              ),

              const SizedBox(height: 24),

              // Upgrade button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.appColors.primary,
                        context.appColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: context.appColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/paywall');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIconsDuotone.crown,
                          size: 20,
                          color: context.appColors.gold,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.upgradeToPro,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Maybe later button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.maybeLater,
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.appColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: context.appColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
