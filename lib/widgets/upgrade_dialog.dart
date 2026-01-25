import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Reusable upgrade dialog for free tier limits
/// Shows consistent premium upsell messaging
class UpgradeDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onUpgrade;

  const UpgradeDialog({super.key, required this.message, this.onUpgrade});

  /// Show the upgrade dialog
  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onUpgrade,
  }) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => UpgradeDialog(message: message, onUpgrade: onUpgrade),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: context.appColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.appColors.gold.withValues(alpha: 0.2),
                  context.appColors.gold.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              PhosphorIconsDuotone.crown,
              color: context.appColors.gold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.upgradeToPremium,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.premiumIncludes,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
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
            PhosphorIconsDuotone.currencyCircleDollar,
            l10n.allCurrencies,
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
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
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
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.appColors.primary,
                context.appColors.primaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.appColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onUpgrade != null) {
                onUpgrade!();
              } else {
                Navigator.of(context).pushNamed('/paywall');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.seePremium,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.appColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact upgrade banner for inline display
class UpgradeBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const UpgradeBanner({super.key, required this.message, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pushNamed('/paywall'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.appColors.primary.withValues(alpha: 0.15),
              context.appColors.primaryDark.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.appColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.appColors.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIconsDuotone.crown,
                size: 18,
                color: context.appColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.seePremium,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              size: 18,
              color: context.appColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
