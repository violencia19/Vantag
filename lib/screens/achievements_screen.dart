import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../theme/theme.dart' hide GlassCard;
import '../providers/providers.dart';
import '../utils/achievement_utils.dart';
import '../core/theme/premium_effects.dart';

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

  Future<void> _checkNewAchievements() async {
    final financeProvider = context.read<FinanceProvider>();
    await financeProvider.refreshAchievements(context);
    if (!mounted) return;
    final achievements = financeProvider.achievements;

    // Start animation for newly unlocked achievements
    final newlyUnlocked = achievements
        .where((a) => a.isNewlyUnlocked && !_celebratedIds.contains(a.id))
        .toList();

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
        backgroundColor: context.appColors.background,
        body: Center(
          child: CircularProgressIndicator(color: context.appColors.primary),
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
      groupedAchievements[category]!.sort(
        (a, b) => a.sortKey.compareTo(b.sortKey),
      );
    }

    return Scaffold(
      backgroundColor: context.appColors.background,
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
                          AppLocalizations.of(context).badges,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSummaryCard(
                          unlockedCount,
                          totalCount,
                          overallProgress,
                        ),
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
                            Icon(
                              category.icon,
                              size: 22,
                              color: category.iconColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AchievementUtils.getCategoryLabel(
                                context,
                                category,
                              ),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: context.appColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${groupedAchievements[category]!.where((a) => a.isUnlocked).length}/${groupedAchievements[category]!.length}',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.appColors.textSecondary,
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
                            final achievement =
                                groupedAchievements[category]![index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ScaleFadeIn(
                                index: index,
                                duration: const Duration(milliseconds: 400),
                                staggerDelay: const Duration(milliseconds: 80),
                                child: achievement.isUnlocked
                                    ? PulseGlow(
                                        glowColor: _getTierColor(
                                          achievement.tier,
                                        ),
                                        animate: achievement.isNewlyUnlocked,
                                        child: _buildAchievementCard(
                                          achievement,
                                        ),
                                      )
                                    : _buildAchievementCard(achievement),
                              ),
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
                          Icon(
                            AchievementCategory.hidden.icon,
                            size: 22,
                            color: AchievementCategory.hidden.iconColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).hiddenBadges,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${hiddenAchievements.where((a) => a.isUnlocked).length}/${hiddenAchievements.length}',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.appColors.textSecondary,
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
                            child: ScaleFadeIn(
                              index: index,
                              duration: const Duration(milliseconds: 400),
                              staggerDelay: const Duration(milliseconds: 80),
                              child: achievement.isUnlocked
                                  ? PulseGlow(
                                      glowColor: context.appColors.gold,
                                      animate: achievement.isNewlyUnlocked,
                                      child: _buildHiddenAchievementCard(
                                        achievement,
                                      ),
                                    )
                                  : _buildHiddenAchievementCard(achievement),
                            ),
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
    // Calculate XP and Level
    final totalXP = unlockedCount * 100; // Each badge = 100 XP
    final level = _calculateLevel(totalXP);
    final levelInfo = _getLevelInfo(level);
    final currentLevelXP = totalXP - _getXPForLevel(level);
    final nextLevelXP = _getXPForLevel(level + 1) - _getXPForLevel(level);
    final levelProgress = nextLevelXP > 0 ? currentLevelXP / nextLevelXP : 1.0;

    // Get streak from provider
    final financeProvider = context.read<FinanceProvider>();
    final streak = financeProvider.streakData.currentStreak;

    return Column(
      children: [
        // Stats Grid (3 cards)
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: PhosphorIconsBold.star,
                iconColor: const Color(0xFFFBBF24),
                value: '$totalXP',
                label: 'Total XP',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: PhosphorIconsBold.trophy,
                iconColor: PremiumColors.purple,
                value: '$unlockedCount/$totalCount',
                label: 'Rozetler',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: PhosphorIconsBold.flame,
                iconColor: const Color(0xFFF97316),
                value: '$streak',
                label: 'Gün Seri',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Level Progress Card
        BreatheGlow(
          glowColor: PremiumColors.purple,
          blurRadius: 20,
          minOpacity: 0.2,
          maxOpacity: 0.4,
          child: GradientBorder(
            borderRadius: 20,
            borderWidth: 1.5,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PremiumColors.cardBackground,
                borderRadius: BorderRadius.circular(18.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Level badge
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              PremiumColors.purple,
                              PremiumColors.gradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: PremiumShadows.glowPurpleSoft,
                        ),
                        child: Center(
                          child: Text(
                            '$level',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level $level',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: context.appColors.textPrimary,
                              ),
                            ),
                            Text(
                              levelInfo['title']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: PremiumColors.purple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // XP Progress
                  Text(
                    '$currentLevelXP / $nextLevelXP XP',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LevelProgressBar(
                    progress: levelProgress.clamp(0.0, 1.0),
                    height: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level ${level + 1} için ${nextLevelXP - currentLevelXP} XP daha',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      boxShadow: PremiumShadows.coloredGlow(iconColor, intensity: 0.3),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor,
            shadows: PremiumShadows.iconHalo(iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateLevel(int xp) {
    // Level thresholds: 0, 200, 500, 1000, 2000, 3500, 5000...
    if (xp < 200) return 1;
    if (xp < 500) return 2;
    if (xp < 1000) return 3;
    if (xp < 2000) return 4;
    if (xp < 3500) return 5;
    if (xp < 5000) return 6;
    if (xp < 7000) return 7;
    if (xp < 10000) return 8;
    if (xp < 15000) return 9;
    return 10;
  }

  int _getXPForLevel(int level) {
    const thresholds = [
      0,
      0,
      200,
      500,
      1000,
      2000,
      3500,
      5000,
      7000,
      10000,
      15000,
    ];
    if (level < thresholds.length) return thresholds[level];
    return 15000;
  }

  Map<String, String> _getLevelInfo(int level) {
    const levels = {
      1: {'title': 'Novice Saver', 'emoji': '🌱'},
      2: {'title': 'Budget Beginner', 'emoji': '📊'},
      3: {'title': 'Money Tracker', 'emoji': '💰'},
      4: {'title': 'Savings Star', 'emoji': '⭐'},
      5: {'title': 'Finance Fighter', 'emoji': '🥊'},
      6: {'title': 'Budget Master', 'emoji': '🎯'},
      7: {'title': 'Wealth Builder', 'emoji': '🏗️'},
      8: {'title': 'Money Guru', 'emoji': '🧘'},
      9: {'title': 'Finance Legend', 'emoji': '🏆'},
      10: {'title': 'Ultimate Saver', 'emoji': '👑'},
    };
    return levels[level] ?? {'title': 'Unknown', 'emoji': '❓'};
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
            ? context.appColors.surface
            : context.appColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? (isPlatinum
                    ? Colors.transparent
                    : tierColor.withValues(alpha: 0.5))
              : context.appColors.cardBorder,
          width: isUnlocked ? 2 : 1,
        ),
        gradient: isUnlocked && isPlatinum
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getPlatinumGradient()
                    .map((c) => c.withValues(alpha: 0.3))
                    .toList(),
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
                      : context.appColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked
                        ? tierColor
                        : context.appColors.cardBorder,
                    width: 2,
                  ),
                  gradient: isUnlocked && isPlatinum
                      ? SweepGradient(colors: _getPlatinumGradient())
                      : null,
                ),
                child: Center(
                  child: isUnlocked
                      ? Icon(
                          achievement.category.icon,
                          size: 26,
                          color: achievement.category.iconColor,
                        )
                      : Icon(
                          PhosphorIconsDuotone.lock,
                          size: 24,
                          color: context.appColors.textTertiary,
                        ),
                ),
              ),
              // Tier badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? tierColor
                        : context.appColors.textTertiary,
                    borderRadius: BorderRadius.circular(8),
                    gradient: isUnlocked && isPlatinum
                        ? LinearGradient(colors: _getPlatinumGradient())
                        : null,
                  ),
                  child: Text(
                    AchievementUtils.getFullTierLabel(
                      context,
                      achievement.tier,
                      achievement.subTier,
                    ),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? context.appColors.background
                          : context.appColors.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            AchievementUtils.getTitle(context, achievement.id),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? context.appColors.textPrimary
                  : context.appColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Description
          Text(
            AchievementUtils.getDescription(context, achievement.id),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isUnlocked
                  ? context.appColors.textSecondary
                  : context.appColors.textTertiary.withValues(alpha: 0.8),
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
                backgroundColor: context.appColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(tierColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatProgress(achievement),
              style: TextStyle(
                fontSize: 10,
                color: context.appColors.textTertiary,
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
    final l10n = AppLocalizations.of(context);
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
        difficultyColor = context.appColors.textTertiary;
        difficultyLabel = '';
    }

    Widget card = Container(
      width: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked
            ? context.appColors.surface
            : context.appColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? difficultyColor.withValues(alpha: 0.5)
              : context.appColors.cardBorder.withValues(alpha: 0.5),
          width: isUnlocked ? 2 : 1,
        ),
        gradient: isUnlocked && isPlatinum
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getPlatinumGradient()
                    .map((c) => c.withValues(alpha: 0.3))
                    .toList(),
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
                      : context.appColors.surfaceLight.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked
                        ? difficultyColor
                        : context.appColors.cardBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isUnlocked
                      ? Icon(
                          PhosphorIconsDuotone.sparkle,
                          size: 26,
                          color: difficultyColor,
                        )
                      : Icon(
                          PhosphorIconsDuotone.question,
                          size: 24,
                          color: context.appColors.textTertiary,
                        ),
                ),
              ),
              // Difficulty badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? difficultyColor
                        : context.appColors.textTertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    difficultyLabel[0],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? context.appColors.textPrimary
                          : context.appColors.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            isUnlocked
                ? AchievementUtils.getTitle(context, achievement.id)
                : l10n.hiddenBadge,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? context.appColors.textPrimary
                  : context.appColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Description
          Text(
            isUnlocked
                ? AchievementUtils.getDescription(context, achievement.id)
                : l10n.discoverHowToUnlock,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontStyle: isUnlocked ? FontStyle.normal : FontStyle.italic,
              color: isUnlocked
                  ? context.appColors.textSecondary
                  : context.appColors.textTertiary.withValues(alpha: 0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Difficulty label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:
                  (isUnlocked
                          ? difficultyColor
                          : context.appColors.textTertiary)
                      .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              difficultyLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isUnlocked
                    ? difficultyColor
                    : context.appColors.textTertiary,
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
    final l10n = AppLocalizations.of(context);
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
