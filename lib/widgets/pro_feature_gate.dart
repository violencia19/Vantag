import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:vantag/providers/pro_provider.dart';
import 'package:vantag/screens/paywall_screen.dart';
import 'package:vantag/services/purchase_service.dart';
import 'package:vantag/theme/app_theme.dart';

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
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.appColors.primary.withValues(alpha: 0.2),
                    context.appColors.secondary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.crown,
                color: context.appColors.gold,
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
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: context.appColors.textSecondary,
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
        backgroundColor: context.appColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(LucideIcons.sparkles, color: context.appColors.primary),
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
              backgroundColor: context.appColors.primary,
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
        backgroundColor: context.appColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(LucideIcons.history, color: context.appColors.primary),
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
              backgroundColor: context.appColors.primary,
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
        backgroundColor: context.appColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(LucideIcons.fileSpreadsheet, color: context.appColors.primary),
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
              backgroundColor: context.appColors.primary,
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
                ? context.appColors.error.withValues(alpha: 0.2)
                : context.appColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: remaining <= 3
                  ? context.appColors.error.withValues(alpha: 0.5)
                  : context.appColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.sparkles,
                size: 14,
                color: remaining <= 3
                    ? context.appColors.error
                    : context.appColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.remainingAiUses(remaining),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: remaining <= 3
                      ? context.appColors.error
                      : context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
