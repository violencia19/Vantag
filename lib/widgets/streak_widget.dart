import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../services/services.dart';

class StreakWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const StreakWidget({super.key, this.onTap});

  @override
  State<StreakWidget> createState() => StreakWidgetState();
}

class StreakWidgetState extends State<StreakWidget>
    with SingleTickerProviderStateMixin {
  final _streakService = StreakService();
  StreakData? _streakData;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadStreak();
    // Pulse animation (800ms cycle for active streak)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(
      begin: VantAnimation.pulseMin,
      end: VantAnimation.pulseMax,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadStreak() async {
    final data = await _streakService.getStreakData();
    if (mounted) {
      setState(() => _streakData = data);
      // Start pulse animation only when streak is active
      if (data.displayStreak > 0) {
        _pulseController.repeat(reverse: true);
      }
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
    final color = hasStreak
        ? VantColors.achievementStreak
        : VantColors.textTertiary;

    // Accessibility: Semantic label for screen readers
    final semanticLabel = l10n.accessibilityStreakInfo(
      streak.displayStreak,
      streak.longestStreak,
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          (widget.onTap ?? () => _showStreakDetails(context))();
        },
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(VantRadius.full),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                ),
                boxShadow: hasStreak
                    ? VantShadows.glow(color, intensity: 0.3)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: hasStreak ? _pulseAnimation.value : 1.0,
                    child: Icon(
                      CupertinoIcons.flame_fill,
                      size: 18,
                      color: color,
                      shadows: hasStreak
                          ? VantShadows.iconHalo(color)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasStreak
                        ? l10n.streakDays(streak.displayStreak)
                        : l10n.startToday,
                    style: VantTypography.labelMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showStreakDetails(BuildContext context) {
    if (_streakData == null) return;

    final l10n = AppLocalizations.of(context);
    final streak = _streakData!;
    final color = streak.hasStreak
        ? VantColors.achievementStreak
        : VantColors.primary;

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.vantColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(VantRadius.xxl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: VantSpacing.cardPaddingLarge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: VantColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Big icon with glow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  boxShadow: VantShadows.glow(color, intensity: 0.4),
                ),
                child: Center(
                  child: Icon(
                    streak.hasStreak
                        ? CupertinoIcons.flame_fill
                        : CupertinoIcons.sportscourt_fill,
                    size: 40,
                    color: color,
                    shadows: VantShadows.iconHalo(color),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                streak.hasStreak
                    ? l10n.dayStreak(streak.displayStreak)
                    : l10n.startStreak,
                style: VantTypography.headlineMedium,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                streak.hasStreak
                    ? l10n.keepStreakMessage
                    : l10n.startStreakMessage,
                textAlign: TextAlign.center,
                style: VantTypography.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Statistics
              if (streak.longestStreak > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: VantColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(VantRadius.lg),
                    border: Border.all(
                      color: VantColors.achievementStreak.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.rosette,
                        size: 20,
                        color: VantColors.achievementStreak,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.longestStreak(streak.longestStreak),
                        style: VantTypography.labelMedium.copyWith(
                          color: VantColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              // New record notification with success glow
              if (streak.isNewRecord && streak.displayStreak > 1) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: VantColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(VantRadius.full),
                    border: Border.all(
                      color: VantColors.success.withValues(alpha: 0.3),
                    ),
                    boxShadow: VantShadows.glow(
                      VantColors.success,
                      intensity: 0.25,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.star_circle_fill,
                        size: 16,
                        color: VantColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.newRecord,
                        style: VantTypography.labelMedium.copyWith(
                          color: VantColors.success,
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
