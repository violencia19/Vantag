import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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

class StreakWidgetState extends State<StreakWidget>
    with SingleTickerProviderStateMixin {
  final _streakService = StreakService();
  StreakData? _streakData;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _loadStreak();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
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
    final l10n = AppLocalizations.of(context);
    if (_streakData == null) {
      return const SizedBox.shrink();
    }

    final streak = _streakData!;
    final hasStreak = streak.displayStreak > 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        (widget.onTap ?? () => _showStreakDetails(context))();
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
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
              boxShadow: hasStreak
                  ? [
                      BoxShadow(
                        color: AppColors.warning
                            .withValues(alpha: _glowAnimation.value),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhosphorIcon(
                  PhosphorIconsDuotone.flame,
                  size: 18,
                  color: hasStreak ? AppColors.warning : AppColors.textTertiary,
                  duotoneSecondaryColor: hasStreak
                      ? AppColors.warning.withValues(alpha: 0.5)
                      : AppColors.textTertiary.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 6),
                Text(
                  hasStreak
                      ? l10n.streakDays(streak.displayStreak)
                      : l10n.startToday,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasStreak ? AppColors.warning : AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStreakDetails(BuildContext context) {
    if (_streakData == null) return;

    final l10n = AppLocalizations.of(context);
    final streak = _streakData!;

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
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

              // Big icon with glow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: streak.hasStreak
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (streak.hasStreak
                              ? AppColors.warning
                              : AppColors.primary)
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Center(
                  child: PhosphorIcon(
                    streak.hasStreak
                        ? PhosphorIconsDuotone.flame
                        : PhosphorIconsDuotone.barbell,
                    size: 40,
                    color: streak.hasStreak
                        ? AppColors.warning
                        : AppColors.primary,
                    duotoneSecondaryColor: (streak.hasStreak
                            ? AppColors.warning
                            : AppColors.primary)
                        .withValues(alpha: 0.4),
                  ),
                ),
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
                      PhosphorIcon(
                        PhosphorIconsDuotone.trophy,
                        size: 20,
                        color: AppColors.warning,
                        duotoneSecondaryColor:
                            AppColors.warning.withValues(alpha: 0.4),
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
                      PhosphorIcon(
                        PhosphorIconsDuotone.confetti,
                        size: 16,
                        color: AppColors.success,
                        duotoneSecondaryColor:
                            AppColors.success.withValues(alpha: 0.4),
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
