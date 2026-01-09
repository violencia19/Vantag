import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../providers/providers.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  final Set<String> _celebratedIds = {};

  // Animation controllers
  final Map<String, AnimationController> _pulseControllers = {};

  // Confetti controller
  AnimationController? _confettiController;
  List<_ConfettiParticle> _confettiParticles = [];

  @override
  void initState() {
    super.initState();
    // Check for new achievements after initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNewAchievements();
    });
  }

  @override
  void dispose() {
    for (final controller in _pulseControllers.values) {
      controller.dispose();
    }
    _confettiController?.dispose();
    super.dispose();
  }

  void _checkNewAchievements() {
    final financeProvider = context.read<FinanceProvider>();
    final achievements = financeProvider.achievements;

    // Start animation for newly unlocked achievements
    final newlyUnlocked = achievements.where(
      (a) => a.isNewlyUnlocked && !_celebratedIds.contains(a.id),
    ).toList();

    if (newlyUnlocked.isNotEmpty) {
      _startConfettiAnimation();
      for (final achievement in newlyUnlocked) {
        _startCelebrationAnimation(achievement.id);
        _celebratedIds.add(achievement.id);
      }
    }
  }

  void _startConfettiAnimation() {
    _confettiController?.dispose();
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Create confetti particles
    final random = Random();
    _confettiParticles = List.generate(50, (index) {
      return _ConfettiParticle(
        x: random.nextDouble(),
        y: -random.nextDouble() * 0.3,
        color: [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.purple,
          Colors.orange,
          Colors.pink,
        ][random.nextInt(7)],
        size: 8 + random.nextDouble() * 8,
        rotation: random.nextDouble() * 360,
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY: 2 + random.nextDouble() * 3,
      );
    });

    _confettiController!.forward().then((_) {
      if (mounted) {
        setState(() {
          _confettiParticles = [];
        });
        _confettiController?.dispose();
        _confettiController = null;
      }
    });

    _confettiController!.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _startCelebrationAnimation(String achievementId) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseControllers[achievementId] = controller;

    controller.forward().then((_) {
      if (mounted) {
        controller.dispose();
        _pulseControllers.remove(achievementId);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get data reactively from Provider
    final financeProvider = context.watch<FinanceProvider>();
    final achievements = financeProvider.achievements;
    final isLoading = financeProvider.isLoading;

    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Group by category (excluding hidden)
    final visibleAchievements = achievements.where((a) => !a.isHidden).toList();
    final hiddenAchievements = achievements.where((a) => a.isHidden).toList();

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final overallProgress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    final groupedAchievements = <AchievementCategory, List<Achievement>>{};
    for (final achievement in visibleAchievements) {
      groupedAchievements.putIfAbsent(achievement.category, () => []);
      groupedAchievements[achievement.category]!.add(achievement);
    }

    // Sort each category by tier
    for (final category in groupedAchievements.keys) {
      groupedAchievements[category]!.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.badges,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSummaryCard(unlockedCount, totalCount, overallProgress),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Categories and badges
                for (final category in [
                  AchievementCategory.streak,
                  AchievementCategory.savings,
                  AchievementCategory.decision,
                  AchievementCategory.record,
                ]) ...[
                  if (groupedAchievements.containsKey(category)) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Row(
                          children: [
                            Text(
                              category.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.label,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${groupedAchievements[category]!.where((a) => a.isUnlocked).length}/${groupedAchievements[category]!.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 190,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: groupedAchievements[category]!.length,
                          itemBuilder: (context, index) {
                            final achievement = groupedAchievements[category]![index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildAchievementCard(achievement),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ],

                // Hidden Badges
                if (hiddenAchievements.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        children: [
                          Text(
                            AchievementCategory.hidden.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.hiddenBadges,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${hiddenAchievements.where((a) => a.isUnlocked).length}/${hiddenAchievements.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: hiddenAchievements.length,
                        itemBuilder: (context, index) {
                          final achievement = hiddenAchievements[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildHiddenAchievementCard(achievement),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),

          // Confetti overlay
          if (_confettiController != null && _confettiParticles.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _confettiParticles,
                    progress: _confettiController!.value,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int unlockedCount, int totalCount, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.trophy,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.badgesEarned(unlockedCount, totalCount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMotivationalMessage(context, unlockedCount, totalCount),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.warning : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.percentComplete((progress * 100).toStringAsFixed(0)),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              if (unlockedCount == totalCount)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.star, size: 12, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.completed,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(BuildContext context, int unlocked, int total) {
    final l10n = AppLocalizations.of(context)!;
    final ratio = unlocked / total;
    if (ratio == 0) {
      return l10n.startRecordingForFirstBadge;
    } else if (ratio < 0.25) {
      return l10n.greatStartKeepGoing;
    } else if (ratio < 0.5) {
      return l10n.halfwayThere;
    } else if (ratio < 0.75) {
      return l10n.doingVeryWell;
    } else if (ratio < 1) {
      return l10n.almostDone;
    } else {
      return l10n.allBadgesEarned;
    }
  }

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  List<Color> _getPlatinumGradient() {
    return const [
      Color(0xFFE5E4E2),
      Color(0xFF8ED1FC),
      Color(0xFFB4A7D6),
      Color(0xFFE5E4E2),
    ];
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final hasCelebration = _pulseControllers.containsKey(achievement.id);
    final tierColor = _getTierColor(achievement.tier);
    final isPlatinum = achievement.tier == AchievementTier.platinum;

    Widget card = Container(
      width: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.surface
            : AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? (isPlatinum ? Colors.transparent : tierColor.withValues(alpha: 0.5))
              : AppColors.cardBorder,
          width: isUnlocked ? 2 : 1,
        ),
        gradient: isUnlocked && isPlatinum
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getPlatinumGradient().map((c) => c.withValues(alpha: 0.3)).toList(),
              )
            : null,
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: tierColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? tierColor.withValues(alpha: 0.2)
                      : AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked ? tierColor : AppColors.cardBorder,
                    width: 2,
                  ),
                  gradient: isUnlocked && isPlatinum
                      ? SweepGradient(
                          colors: _getPlatinumGradient(),
                        )
                      : null,
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          achievement.category.emoji,
                          style: const TextStyle(fontSize: 24),
                        )
                      : const Icon(
                          LucideIcons.lock,
                          size: 24,
                          color: AppColors.textTertiary,
                        ),
                ),
              ),
              // Tier badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUnlocked ? tierColor : AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(8),
                    gradient: isUnlocked && isPlatinum
                        ? LinearGradient(colors: _getPlatinumGradient())
                        : null,
                  ),
                  child: Text(
                    achievement.tierLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? (isPlatinum ? Colors.black87 : Colors.black87)
                          : AppColors.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? AppColors.textPrimary
                  : Colors.white.withValues(alpha: 0.5), // Readable grey
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Description
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isUnlocked
                  ? AppColors.textSecondary
                  : Colors.white.withValues(alpha: 0.4), // Readable grey
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Progress or date
          if (!isUnlocked) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievement.progress,
                minHeight: 4,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(tierColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatProgress(achievement),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ] else ...[
            Text(
              _formatDate(context, achievement.unlockedAt!),
              style: TextStyle(
                fontSize: 10,
                color: tierColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );

    // Celebration animation
    if (hasCelebration) {
      final controller = _pulseControllers[achievement.id]!;
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final scale = 1.0 + (0.1 * (1 - controller.value));
          final glow = (1 - controller.value) * 0.5;
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: tierColor.withValues(alpha: glow),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: card,
            ),
          );
        },
      );
    }

    return card;
  }

  Widget _buildHiddenAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final hasCelebration = _pulseControllers.containsKey(achievement.id);
    final isPlatinum = achievement.tier == AchievementTier.platinum;

    // Difficulty color
    final l10n = AppLocalizations.of(context)!;
    Color difficultyColor;
    String difficultyLabel;
    switch (achievement.hiddenDifficulty) {
      case HiddenDifficulty.easy:
        difficultyColor = Colors.green;
        difficultyLabel = l10n.difficultyEasy;
        break;
      case HiddenDifficulty.medium:
        difficultyColor = Colors.orange;
        difficultyLabel = l10n.difficultyMedium;
        break;
      case HiddenDifficulty.hard:
        difficultyColor = Colors.red;
        difficultyLabel = l10n.difficultyHard;
        break;
      case HiddenDifficulty.legendary:
        difficultyColor = Colors.purple;
        difficultyLabel = l10n.difficultyLegendary;
        break;
      case null:
        difficultyColor = Colors.grey;
        difficultyLabel = '';
    }

    Widget card = Container(
      width: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.surface
            : AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? difficultyColor.withValues(alpha: 0.5)
              : AppColors.cardBorder.withValues(alpha: 0.5),
          width: isUnlocked ? 2 : 1,
        ),
        gradient: isUnlocked && isPlatinum
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getPlatinumGradient().map((c) => c.withValues(alpha: 0.3)).toList(),
              )
            : null,
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: difficultyColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? difficultyColor.withValues(alpha: 0.2)
                      : AppColors.surfaceLight.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked ? difficultyColor : AppColors.cardBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isUnlocked
                      ? const Text('🔮', style: TextStyle(fontSize: 24))
                      : const Text(
                          '???',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textTertiary,
                          ),
                        ),
                ),
              ),
              // Difficulty badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUnlocked ? difficultyColor : AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    difficultyLabel[0],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.white : AppColors.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            isUnlocked ? achievement.title : l10n.hiddenBadge,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? AppColors.textPrimary
                  : Colors.white.withValues(alpha: 0.5), // Readable grey
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Description
          Text(
            isUnlocked ? achievement.description : l10n.discoverHowToUnlock,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontStyle: isUnlocked ? FontStyle.normal : FontStyle.italic,
              color: isUnlocked
                  ? AppColors.textSecondary
                  : Colors.white.withValues(alpha: 0.4), // Readable grey
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Difficulty label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (isUnlocked ? difficultyColor : AppColors.textTertiary)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              difficultyLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isUnlocked ? difficultyColor : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );

    // Celebration animation
    if (hasCelebration) {
      final controller = _pulseControllers[achievement.id]!;
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final scale = 1.0 + (0.1 * (1 - controller.value));
          final glow = (1 - controller.value) * 0.5;
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: difficultyColor.withValues(alpha: glow),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: card,
            ),
          );
        },
      );
    }

    return card;
  }

  String _formatProgress(Achievement achievement) {
    // Abbreviation for large numbers
    if (achievement.targetValue >= 1000000) {
      final current = (achievement.currentValue / 1000000).toStringAsFixed(1);
      final target = (achievement.targetValue / 1000000).toStringAsFixed(0);
      return '${current}M / ${target}M';
    } else if (achievement.targetValue >= 1000) {
      final current = (achievement.currentValue / 1000).toStringAsFixed(1);
      final target = (achievement.targetValue / 1000).toStringAsFixed(0);
      return '${current}K / ${target}K';
    }
    return '${achievement.currentValue}/${achievement.targetValue}';
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return l10n.earnedToday;
    }

    final difference = today.difference(dateOnly).inDays;
    if (difference == 1) {
      return l10n.earnedYesterday;
    } else if (difference < 7) {
      return l10n.daysAgoEarned(difference);
    } else if (difference < 30) {
      return l10n.weeksAgoEarned((difference / 7).floor());
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ========== CONFETTI ANIMATION ==========

class _ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  double rotation;
  final double velocityX;
  final double velocityY;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.velocityX,
    required this.velocityY,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.fill;

      final x = (particle.x + particle.velocityX * progress) * size.width;
      final y = (particle.y + particle.velocityY * progress) * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((particle.rotation + progress * 360) * 3.14159 / 180);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 0.6,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
