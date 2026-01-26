import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/pro_provider.dart';
import '../screens/paywall_screen.dart';
import '../theme/theme.dart';

/// A widget that blurs content and shows a lock icon for PRO-only features.
/// Tapping opens a PRO features sheet with paywall access.
class LockedProFeature extends StatelessWidget {
  /// The widget to display (will be blurred if not PRO)
  final Widget child;

  /// Feature name to highlight in the PRO sheet
  final String featureName;

  /// Whether to show the lock badge
  final bool showLockBadge;

  /// Blur intensity (default 8.0)
  final double blurSigma;

  const LockedProFeature({
    super.key,
    required this.child,
    required this.featureName,
    this.showLockBadge = true,
    this.blurSigma = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<ProProvider>().isPro;

    // PRO users see the content normally
    if (isPro) {
      return child;
    }

    // FREE users see blurred content with lock
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showProFeaturesSheet(context);
      },
      child: Stack(
        children: [
          // Blurred content
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: child,
            ),
          ),

          // Overlay with lock icon
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon with glow
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.primary.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      PhosphorIconsFill.lock,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // PRO badge
                  if (showLockBadge)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.appColors.primary,
                            context.appColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: context.appColors.primary.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            PhosphorIconsFill.crown,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).lockedFeatureTapToUnlock,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProFeaturesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => ProFeaturesSheet(highlightedFeature: featureName),
    );
  }
}

/// Bottom sheet that shows all PRO features and opens paywall
class ProFeaturesSheet extends StatelessWidget {
  final String? highlightedFeature;

  const ProFeaturesSheet({super.key, this.highlightedFeature});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final proFeatures = [
      _ProFeatureItem(
        icon: PhosphorIconsDuotone.chartLine,
        title: l10n.proFeatureHeatmap,
        description: l10n.proFeatureHeatmapDesc,
        color: context.appColors.primary,
      ),
      _ProFeatureItem(
        icon: PhosphorIconsDuotone.chartPie,
        title: l10n.proFeatureCategoryBreakdown,
        description: l10n.proFeatureCategoryBreakdownDesc,
        color: context.appColors.warning,
      ),
      _ProFeatureItem(
        icon: PhosphorIconsDuotone.trendUp,
        title: l10n.proFeatureSpendingTrends,
        description: l10n.proFeatureSpendingTrendsDesc,
        color: context.appColors.success,
      ),
      _ProFeatureItem(
        icon: PhosphorIconsDuotone.clock,
        title: l10n.proFeatureTimeAnalysis,
        description: l10n.proFeatureTimeAnalysisDesc,
        color: context.appColors.info,
      ),
      _ProFeatureItem(
        icon: PhosphorIconsDuotone.wallet,
        title: l10n.proFeatureBudgetBreakdown,
        description: l10n.proFeatureBudgetBreakdownDesc,
        color: context.appColors.error,
      ),
      _ProFeatureItem(
        icon: PhosphorIconsDuotone.funnel,
        title: l10n.proFeatureAdvancedFilters,
        description: l10n.proFeatureAdvancedFiltersDesc,
        color: context.appColors.primary,
      ),
      _ProFeatureItem(
        icon: PhosphorIconsDuotone.fileXls,
        title: l10n.proFeatureExcelExport,
        description: l10n.proFeatureExcelExportDesc,
        color: context.appColors.success,
      ),
      _ProFeatureItem(
        icon: PhosphorIconsDuotone.clockCounterClockwise,
        title: l10n.proFeatureUnlimitedHistory,
        description: l10n.proFeatureUnlimitedHistoryDesc,
        color: context.appColors.warning,
      ),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.appColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              children: [
                // Crown icon with glow
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.appColors.primary,
                        context.appColors.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.appColors.primary.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    PhosphorIconsFill.crown,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.proFeaturesSheetTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.proFeaturesSheetSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Features list
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.proFeaturesIncluded,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...proFeatures.map(
                    (feature) => _buildFeatureItem(
                      context,
                      feature,
                      isHighlighted: feature.title == highlightedFeature,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Go PRO button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to paywall screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaywallScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(PhosphorIconsFill.crown, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.goProButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    _ProFeatureItem feature, {
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? context.appColors.primary.withValues(alpha: 0.1)
            : context.appColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: isHighlighted
            ? Border.all(
                color: context.appColors.primary.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: feature.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        feature.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isHighlighted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          PhosphorIconsBold.star,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProFeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _ProFeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
