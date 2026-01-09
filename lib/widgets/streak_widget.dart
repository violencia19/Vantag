import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../services/services.dart';
import '../theme/theme.dart';

class StreakWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const StreakWidget({
    super.key,
    this.onTap,
  });

  @override
  State<StreakWidget> createState() => StreakWidgetState();
}

class StreakWidgetState extends State<StreakWidget> {
  final _streakService = StreakService();
  StreakData? _streakData;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final data = await _streakService.getStreakData();
    if (mounted) {
      setState(() => _streakData = data);
    }
  }

  /// Reloads streak (callable from outside)
  Future<void> refresh() async {
    await _loadStreak();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_streakData == null) {
      return const SizedBox.shrink();
    }

    final streak = _streakData!;
    final hasStreak = streak.displayStreak > 0;

    return GestureDetector(
      onTap: widget.onTap ?? () => _showStreakDetails(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasStreak
              ? AppColors.warning.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasStreak
                ? AppColors.warning.withValues(alpha: 0.3)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔥',
              style: TextStyle(
                fontSize: 16,
                color: hasStreak ? null : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              hasStreak ? l10n.streakDays(streak.displayStreak) : l10n.startToday,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: hasStreak ? AppColors.warning : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStreakDetails(BuildContext context) {
    if (_streakData == null) return;

    final l10n = AppLocalizations.of(context)!;
    final streak = _streakData!;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Big emoji
              Text(
                streak.hasStreak ? '🔥' : '💪',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                streak.hasStreak
                    ? l10n.dayStreak(streak.displayStreak)
                    : l10n.startStreak,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                streak.hasStreak
                    ? l10n.keepStreakMessage
                    : l10n.startStreakMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Statistics
              if (streak.longestStreak > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.trophy,
                        size: 20,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.longestStreak(streak.longestStreak),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              // New record notification
              if (streak.isNewRecord && streak.displayStreak > 1) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.partyPopper,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.newRecord,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
