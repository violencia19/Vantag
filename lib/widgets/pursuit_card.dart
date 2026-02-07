import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/pursuit.dart';
import '../theme/theme.dart';
import 'pursuit_progress_visual.dart';

/// Card widget for displaying a pursuit in a list
class PursuitCard extends StatelessWidget {
  final Pursuit pursuit;
  final VoidCallback? onTap;
  final VoidCallback? onAddSavings;
  final String Function(double amount) formatAmount;

  const PursuitCard({
    super.key,
    required this.pursuit,
    this.onTap,
    this.onAddSavings,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Accessibility: Semantic label for screen readers
    final semanticLabel = l10n.accessibilityPursuitCard(
      pursuit.name,
      formatAmount(pursuit.savedAmount),
      formatAmount(pursuit.targetAmount),
      pursuit.progressPercentDisplay,
    );

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: VPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.vantColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.vantColors.cardBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Emoji + Name + Progress badge
              Row(
                children: [
                  // Emoji with progress visual
                  PursuitProgressVisual(
                    progress: pursuit.progressPercent,
                    emoji: pursuit.emoji,
                    imageUrl: pursuit.imageUrl,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  // Name and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pursuit.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: Color(0xFFFAFAFA)).copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getCategoryLabel(context, pursuit.category),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF71717A)),
                        ),
                      ],
                    ),
                  ),
                  // Progress badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getProgressColor(context, pursuit.progressPercent)
                              .withValues(alpha: 0.25),
                          _getProgressColor(context, pursuit.progressPercent)
                              .withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getProgressColor(context, pursuit.progressPercent)
                            .withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${pursuit.progressPercentDisplay}%',
                      style: AccessibleText.scaled(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _getProgressColor(context, pursuit.progressPercent),
                        maxScale: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              PursuitLinearProgress(
                progress: pursuit.progressPercent,
                height: 6,
                progressColor: _getProgressColor(context, pursuit.progressPercent),
              ),
              const SizedBox(height: 12),
              // Bottom row: Amounts + Add button
              Row(
                children: [
                  // Saved / Target
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                formatAmount(pursuit.savedAmount),
                                style: AccessibleText.scaled(
                                  context,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: context.vantColors.success,
                                  maxScale: 1.3,
                                ).copyWith(letterSpacing: -0.5),
                              ),
                              Text(
                                ' / ${formatAmount(pursuit.targetAmount)}',
                                style: AccessibleText.scaled(
                                  context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.vantColors.textSecondary.withValues(alpha: 0.7),
                                  maxScale: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.remainingAmount(
                            formatAmount(pursuit.remainingAmount),
                          ),
                          style: AccessibleText.scaled(
                            context,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: context.vantColors.textTertiary.withValues(alpha: 0.6),
                            maxScale: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add savings button
                  if (!pursuit.isCompleted && onAddSavings != null)
                    _AddSavingsButton(onTap: onAddSavings!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(BuildContext context, PursuitCategory category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case PursuitCategory.tech:
        return l10n.pursuitCategoryTech;
      case PursuitCategory.travel:
        return l10n.pursuitCategoryTravel;
      case PursuitCategory.home:
        return l10n.pursuitCategoryHome;
      case PursuitCategory.fashion:
        return l10n.pursuitCategoryFashion;
      case PursuitCategory.vehicle:
        return l10n.pursuitCategoryVehicle;
      case PursuitCategory.education:
        return l10n.pursuitCategoryEducation;
      case PursuitCategory.health:
        return l10n.pursuitCategoryHealth;
      case PursuitCategory.other:
        return l10n.pursuitCategoryOther;
    }
  }

  Color _getProgressColor(BuildContext context, double progress) {
    if (progress >= 1.0) return context.vantColors.gold;
    if (progress >= 0.7) return context.vantColors.success;
    if (progress >= 0.3) return VantColors.secondary;
    return context.vantColors.textTertiary;
  }
}

class _AddSavingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddSavingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.addSavings,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Tooltip(
            message: l10n.addSavings,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.vantColors.success.withValues(alpha: 0.2),
                    context.vantColors.success.withValues(alpha: 0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.vantColors.success.withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.vantColors.success.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.plus,
                    size: 14,
                    color: context.vantColors.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.addSavings,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF71717A)).copyWith(
                      color: context.vantColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact pursuit card for horizontal lists
class PursuitCompactCard extends StatelessWidget {
  final Pursuit pursuit;
  final VoidCallback? onTap;
  final String Function(double amount) formatAmount;
  final double width;

  const PursuitCompactCard({
    super.key,
    required this.pursuit,
    this.onTap,
    required this.formatAmount,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Accessibility: Semantic label for screen readers
    final semanticLabel = l10n.accessibilityPursuitCard(
      pursuit.name,
      formatAmount(pursuit.savedAmount),
      formatAmount(pursuit.targetAmount),
      pursuit.progressPercentDisplay,
    );

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: VPressable(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: VantColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji
              PursuitCircularProgress(
                progress: pursuit.progressPercent,
                emoji: pursuit.emoji,
                size: 48,
                strokeWidth: 3,
              ),
              const SizedBox(height: 8),
              // Name
              Text(
                pursuit.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA1A1AA)).copyWith(
                  color: context.vantColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Progress
              Text(
                '${pursuit.progressPercentDisplay}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF71717A)).copyWith(
                  color: context.vantColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
