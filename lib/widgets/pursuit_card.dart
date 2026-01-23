import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/pursuit.dart';
import '../theme/app_theme.dart';
import '../theme/quiet_luxury.dart';
import '../theme/accessible_text.dart';
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
      child: Pressable(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
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
                          style: QuietLuxury.heading.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getCategoryLabel(context, pursuit.category),
                          style: QuietLuxury.label,
                        ),
                      ],
                    ),
                  ),
                  // Progress badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(
                        pursuit.progressPercent,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getProgressColor(
                          pursuit.progressPercent,
                        ).withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${pursuit.progressPercentDisplay}%',
                      style: AccessibleText.scaled(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getProgressColor(pursuit.progressPercent),
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
                progressColor: _getProgressColor(pursuit.progressPercent),
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
                            children: [
                              Text(
                                formatAmount(pursuit.savedAmount),
                                style: AccessibleText.scaled(
                                  context,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: QuietLuxury.positive,
                                  maxScale: 1.3,
                                ).copyWith(letterSpacing: 0.5),
                              ),
                              Text(
                                ' / ${formatAmount(pursuit.targetAmount)}',
                                style: AccessibleText.scaled(
                                  context,
                                  fontSize: 14,
                                  color: QuietLuxury.textSecondary,
                                  maxScale: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.remainingAmount(
                            formatAmount(pursuit.remainingAmount),
                          ),
                          style: AccessibleText.scaled(
                            context,
                            fontSize: 12,
                            color: QuietLuxury.textTertiary,
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

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return QuietLuxury.gold;
    if (progress >= 0.7) return QuietLuxury.positive;
    if (progress >= 0.3) return AppColors.secondary;
    return QuietLuxury.textTertiary;
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
          borderRadius: BorderRadius.circular(10),
          child: Tooltip(
            message: l10n.addSavings,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: QuietLuxury.positive.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: QuietLuxury.positive.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsBold.plus,
                    size: 14,
                    color: QuietLuxury.positive,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.addSavings,
                    style: QuietLuxury.label.copyWith(
                      color: QuietLuxury.positive,
                      fontWeight: FontWeight.w600,
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
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: QuietLuxury.cardDecoration,
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
                style: QuietLuxury.body.copyWith(
                  color: QuietLuxury.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Progress
              Text(
                '${pursuit.progressPercentDisplay}%',
                style: QuietLuxury.label.copyWith(
                  color: QuietLuxury.positive,
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
