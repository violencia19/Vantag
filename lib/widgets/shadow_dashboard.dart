import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../services/streak_manager.dart';
import '../theme/theme.dart';

/// Wealth Coach: Shadow Dashboard
/// Quiet Luxury design - elegant and minimal
class ShadowDashboard extends StatelessWidget {
  final String totalTime;
  final String totalAmount;
  final int currentStreak;

  const ShadowDashboard({
    super.key,
    required this.totalTime,
    required this.totalAmount,
    this.currentStreak = 0,
  });

  /// Create directly from StreakManager
  factory ShadowDashboard.fromStreakManager() {
    return ShadowDashboard(
      totalTime: streakManager.formattedTotalTime,
      totalAmount: streakManager.formattedTotalAmount,
      currentStreak: streakManager.currentStreak,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Hide if no data
    if (totalTime == l10n.zeroMinutes && totalAmount == l10n.zeroAmount) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: QuietLuxury.cardDecoration,
      child: ClipRRect(
        borderRadius: QuietLuxury.cardRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Left: Freed time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time - large, light font, breathing space
                      AnimatedNumber(
                        value: totalTime,
                        style: QuietLuxury.displayLarge.copyWith(
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Sub text
                      Row(
                        children: [
                          Text(
                            l10n.freedTime,
                            style: QuietLuxury.label,
                          ),
                          // Streak badge - gold only at milestones
                          if (currentStreak > 0) ...[
                            const SizedBox(width: 10),
                            _StreakChip(streak: currentStreak),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Right: Total saved
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedNumber(
                      value: totalAmount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: QuietLuxury.positive,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.savedAmountLabel,
                      style: QuietLuxury.label,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small streak chip widget - Quiet Luxury
class _StreakChip extends StatelessWidget {
  final int streak;

  const _StreakChip({required this.streak});

  // Gold only at milestones (10+), others subtle
  Color get _chipColor {
    if (streak >= 10) return QuietLuxury.gold;      // Milestone - Gold
    if (streak >= 5) return QuietLuxury.positive;   // Good - Subtle green
    return QuietLuxury.textTertiary;                // Normal - Subtle grey
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _chipColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsDuotone.flame,
            size: 12,
            color: _chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _chipColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standalone streak chip (for main screen) - Quiet Luxury
class StreakChip extends StatelessWidget {
  final int streak;
  final bool showLabel;

  const StreakChip({
    super.key,
    required this.streak,
    this.showLabel = false,
  });

  Color get _chipColor {
    if (streak >= 10) return QuietLuxury.gold;
    if (streak >= 5) return QuietLuxury.positive;
    if (streak >= 3) return const Color(0xB33498DB); // Subtle blue
    return QuietLuxury.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _chipColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsDuotone.flame,
            size: 14,
            color: _chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _chipColor,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              l10n.dayLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: _chipColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
