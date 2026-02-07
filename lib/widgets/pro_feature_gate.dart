import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:vantag/providers/pro_provider.dart';
import 'package:vantag/screens/paywall_screen.dart';
import 'package:vantag/services/purchase_service.dart';
import 'package:vantag/theme/theme.dart';

/// Types of Pro features that can be gated
enum ProFeature { aiChat, fullHistory, export, widgets }

/// A widget that gates Pro features with soft paywall
class ProFeatureGate extends StatelessWidget {
  final ProFeature feature;
  final Widget child;
  final Widget? lockedChild;

  const ProFeatureGate({
    super.key,
    required this.feature,
    required this.child,
    this.lockedChild,
  });

  @override
  Widget build(BuildContext context) {
    final proProvider = context.watch<ProProvider>();

    if (proProvider.isPro) {
      return child;
    }

    return lockedChild ?? _buildLockedState(context);
  }

  Widget _buildLockedState(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => showPaywall(context, feature: feature),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.vantColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.vantColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.vantColors.primary.withValues(alpha: 0.2),
                    context.vantColors.secondary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                CupertinoIcons.star_fill,
                color: context.vantColors.gold,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFeatureTitle(l10n),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.paywallSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.vantColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: context.vantColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _getFeatureTitle(AppLocalizations l10n) {
    switch (feature) {
      case ProFeature.aiChat:
        return l10n.featureAiChat;
      case ProFeature.fullHistory:
        return l10n.featureHistory;
      case ProFeature.export:
        return l10n.featureExport;
      case ProFeature.widgets:
        return l10n.featureWidgets;
    }
  }

  /// Show paywall screen
  static Future<bool> showPaywall(
    BuildContext context, {
    ProFeature? feature,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(featureName: feature?.name),
        fullscreenDialog: true,
      ),
    );
    return result ?? false;
  }

  /// Check if AI chat is available (with limit check for free users)
  static Future<bool> canUseAiChat(BuildContext context) async {
    final proProvider = context.read<ProProvider>();

    if (proProvider.isPro) return true;

    final canUse = await PurchaseService().canUseAiChat(false);

    if (!canUse && context.mounted) {
      _showAiLimitDialog(context);
      return false;
    }

    return true;
  }

  /// Increment AI usage and check if limit reached
  static Future<bool> useAiChat(BuildContext context) async {
    final proProvider = context.read<ProProvider>();

    if (proProvider.isPro) return true;

    final canUse = await PurchaseService().canUseAiChat(false);

    if (!canUse && context.mounted) {
      _showAiLimitDialog(context);
      return false;
    }

    // Increment usage
    await PurchaseService().incrementAiUsage();
    return true;
  }

  /// Show AI limit reached dialog
  static void _showAiLimitDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.vantColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(CupertinoIcons.sparkles, color: context.vantColors.primary),
            const SizedBox(width: 12),
            Text(l10n.aiLimitReached),
          ],
        ),
        content: Text(
          l10n.aiLimitMessage(
            PurchaseService.freeAiChatLimit,
            PurchaseService.freeAiChatLimit,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              showPaywall(context, feature: ProFeature.aiChat);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.vantColors.primary,
            ),
            child: Text(l10n.subscribeToPro),
          ),
        ],
      ),
    );
  }

  /// Show history limit dialog
  static void showHistoryLimitDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.vantColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(CupertinoIcons.clock, color: context.vantColors.primary),
            const SizedBox(width: 12),
            Text(l10n.historyLimitReached),
          ],
        ),
        content: Text(l10n.historyLimitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              showPaywall(context, feature: ProFeature.fullHistory);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.vantColors.primary,
            ),
            child: Text(l10n.subscribeToPro),
          ),
        ],
      ),
    );
  }

  /// Show export Pro-only dialog
  static void showExportProDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.vantColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(CupertinoIcons.doc_text, color: context.vantColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.exportProOnly)),
          ],
        ),
        content: Text(l10n.upgradeForExport),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              showPaywall(context, feature: ProFeature.export);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.vantColors.primary,
            ),
            child: Text(l10n.subscribeToPro),
          ),
        ],
      ),
    );
  }
}

/// AI usage indicator widget (shows remaining uses for free users)
class AiUsageIndicator extends StatelessWidget {
  const AiUsageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final proProvider = context.watch<ProProvider>();
    final l10n = AppLocalizations.of(context);

    if (proProvider.isPro) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<int>(
      future: PurchaseService().getRemainingAiUses(false),
      builder: (context, snapshot) {
        final remaining = snapshot.data ?? PurchaseService.freeAiChatLimit;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: remaining <= 3
                ? context.vantColors.error.withValues(alpha: 0.2)
                : context.vantColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: remaining <= 3
                  ? context.vantColors.error.withValues(alpha: 0.5)
                  : context.vantColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.sparkles,
                size: 14,
                color: remaining <= 3
                    ? context.vantColors.error
                    : context.vantColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.remainingAiUses(remaining),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: remaining <= 3
                      ? context.vantColors.error
                      : context.vantColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
