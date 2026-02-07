import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'psychology_design_system.dart';
import 'psychology_effects.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PREMIUM PSYCHOLOGY WIDGETS
/// Apple Liquid Glass + Gamification + Dopamine Triggers
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET 1: PREMIUM HERO CARD
// Main dashboard card showing work hours
// ═══════════════════════════════════════════════════════════════════════════

/// Premium hero card displaying work hours with animated glow
class PremiumHeroCard extends StatefulWidget {
  final double hoursWorked;
  final double daysWorked;
  final double budgetPercentage;
  final VoidCallback? onTap;

  const PremiumHeroCard({
    super.key,
    required this.hoursWorked,
    required this.daysWorked,
    required this.budgetPercentage,
    this.onTap,
  });

  @override
  State<PremiumHeroCard> createState() => _PremiumHeroCardState();
}

class _PremiumHeroCardState extends State<PremiumHeroCard>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _countController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _countAnimation;

  double _previousHours = 0;
  double _previousDays = 0;

  @override
  void initState() {
    super.initState();

    // Breathing glow animation (3s cycle)
    _breathingController = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.breathingCycle,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(
      begin: PsychologyAnimations.glowMin,
      end: PsychologyAnimations.glowMax,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: PsychologyAnimations.smooth,
    ));

    // Count-up animation (800ms)
    _countController = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.countUp,
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: PsychologyAnimations.standardCurve,
    );
    _countController.forward();
  }

  @override
  void didUpdateWidget(PremiumHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hoursWorked != widget.hoursWorked ||
        oldWidget.daysWorked != widget.daysWorked) {
      _previousHours = oldWidget.hoursWorked;
      _previousDays = oldWidget.daysWorked;
      _countController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _countController.dispose();
    super.dispose();
  }

  double _lerp(double begin, double end, double t) {
    return begin + (end - begin) * t;
  }

  @override
  Widget build(BuildContext context) {
    final budgetColor = PsychologyColors.getBudgetColor(widget.budgetPercentage);

    return AnimatedBuilder(
      animation: Listenable.merge([_breathingAnimation, _countAnimation]),
      builder: (context, child) {
        final animatedHours = _lerp(_previousHours, widget.hoursWorked, _countAnimation.value);
        final animatedDays = _lerp(_previousDays, widget.daysWorked, _countAnimation.value);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap?.call();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PsychologyRadius.xxl),
              boxShadow: [
                // Animated breathing glow
                BoxShadow(
                  color: budgetColor.withValues(alpha: _breathingAnimation.value),
                  blurRadius: 40,
                  spreadRadius: -4,
                ),
                // Depth shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PsychologyRadius.xxl),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: PsychologyGlass.heroBlurSigma,
                  sigmaY: PsychologyGlass.heroBlurSigma,
                ),
                child: Container(
                  padding: PsychologySpacing.cardPadding,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        PsychologyColors.primary.withValues(alpha: 0.12),
                        PsychologyColors.primary.withValues(alpha: 0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(PsychologyRadius.xxl),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: PsychologyGlass.borderOpacity),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Top highlight
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(PsychologyRadius.xxl),
                            ),
                            gradient: PsychologyGlass.topHighlight,
                          ),
                        ),
                      ),
                      // Content
                      Column(
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: PsychologyColors.primarySubtle,
                              borderRadius: BorderRadius.circular(PsychologyRadius.full),
                              border: Border.all(
                                color: PsychologyColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.clock_fill,
                                  size: 14,
                                  color: PsychologyColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ÇALIŞMA KARŞILIĞI',
                                  style: PsychologyTypography.badge.copyWith(
                                    color: PsychologyColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Hero numbers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Hours
                              _buildTimeBlock(
                                value: animatedHours.toStringAsFixed(0),
                                label: 'SAAT',
                                icon: CupertinoIcons.clock_fill,
                                color: PsychologyColors.primary,
                              ),
                              // Divider
                              Container(
                                width: 2,
                                height: 70,
                                margin: const EdgeInsets.symmetric(horizontal: 28),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withValues(alpha: 0),
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              // Days
                              _buildTimeBlock(
                                value: animatedDays.toStringAsFixed(0),
                                label: 'GÜN',
                                icon: CupertinoIcons.sun_max_fill,
                                color: PsychologyColors.secondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Progress bar
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Bütçe Kullanımı',
                                    style: PsychologyTypography.labelSmall,
                                  ),
                                  Text(
                                    '%${widget.budgetPercentage.toStringAsFixed(0)}',
                                    style: PsychologyTypography.labelMedium.copyWith(
                                      color: budgetColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LevelProgressBar(
                                progress: widget.budgetPercentage / 100,
                                height: 8,
                                color: budgetColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeBlock({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        // Icon container
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.25),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
            boxShadow: PsychologyShadows.glow(color, intensity: 0.3, blur: 16),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 14),
        // Value
        Text(
          value,
          style: PsychologyTypography.displayMedium.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: [
              Shadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Label
        Text(
          label,
          style: PsychologyTypography.labelSmall.copyWith(
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET 2: PREMIUM DECISION BUTTONS
// ═══════════════════════════════════════════════════════════════════════════

enum ExpenseDecisionType { bought, thinking, passed }

/// Premium decision buttons with psychology-based emphasis
class PremiumDecisionButtons extends StatelessWidget {
  final Function(ExpenseDecisionType) onDecision;
  final bool enabled;

  const PremiumDecisionButtons({
    super.key,
    required this.onDecision,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Kararın ne oldu?',
          style: PsychologyTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DecisionButton(
                label: 'Aldım',
                icon: CupertinoIcons.checkmark,
                color: PsychologyColors.decisionYes,
                type: ExpenseDecisionType.bought,
                onTap: enabled ? () => onDecision(ExpenseDecisionType.bought) : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DecisionButton(
                label: 'Düşünüyorum',
                icon: CupertinoIcons.clock,
                color: PsychologyColors.decisionThinking,
                type: ExpenseDecisionType.thinking,
                onTap: enabled ? () => onDecision(ExpenseDecisionType.thinking) : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DecisionButton(
                label: 'Vazgeçtim',
                icon: CupertinoIcons.xmark,
                color: PsychologyColors.decisionNo,
                type: ExpenseDecisionType.passed,
                onTap: enabled ? () => onDecision(ExpenseDecisionType.passed) : null,
                isEmphasized: true, // Positive action = emphasized
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DecisionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final ExpenseDecisionType type;
  final VoidCallback? onTap;
  final bool isEmphasized;

  const _DecisionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
    this.onTap,
    this.isEmphasized = false,
  });

  @override
  State<_DecisionButton> createState() => _DecisionButtonState();
}

class _DecisionButtonState extends State<_DecisionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.quick,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: PsychologyAnimations.buttonPressScale,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: PsychologyAnimations.standardCurve,
    ));

    // Emphasis glow for "Vazgeçtim" button
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isEmphasized) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTap() {
    if (widget.onTap == null) return;

    switch (widget.type) {
      case ExpenseDecisionType.bought:
        HapticFeedback.mediumImpact();
        break;
      case ExpenseDecisionType.thinking:
        HapticFeedback.lightImpact();
        break;
      case ExpenseDecisionType.passed:
        HapticFeedback.heavyImpact(); // Celebration!
        break;
    }

    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 88),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PsychologyRadius.lg),
                boxShadow: widget.isEmphasized
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: _glowAnimation.value),
                          blurRadius: 20,
                          spreadRadius: -4,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PsychologyRadius.lg),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withValues(alpha: _isPressed ? 0.2 : 0.12),
                          widget.color.withValues(alpha: _isPressed ? 0.15 : 0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(PsychologyRadius.lg),
                      border: Border.all(
                        color: widget.color.withValues(
                          alpha: widget.isEmphasized ? 0.4 : 0.2,
                        ),
                        width: widget.isEmphasized ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.color.withValues(alpha: 0.25),
                                widget.color.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.3),
                            ),
                            boxShadow: PsychologyShadows.glow(
                              widget.color,
                              intensity: 0.25,
                              blur: 12,
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 22,
                            color: widget.color,
                            shadows: PsychologyShadows.iconHalo(widget.color),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Label
                        Text(
                          widget.label,
                          style: PsychologyTypography.labelMedium.copyWith(
                            color: widget.color,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET 3: VERTICAL BUDGET BAR
// Fills from top to bottom (weight metaphor)
// ═══════════════════════════════════════════════════════════════════════════

/// Vertical budget bar that fills from top (weight/gravity metaphor)
class PremiumVerticalBudgetBar extends StatefulWidget {
  final double percentage;
  final double height;
  final double width;
  final bool showLabel;

  const PremiumVerticalBudgetBar({
    super.key,
    required this.percentage,
    this.height = 160,
    this.width = 32,
    this.showLabel = true,
  });

  @override
  State<PremiumVerticalBudgetBar> createState() => _PremiumVerticalBudgetBarState();
}

class _PremiumVerticalBudgetBarState extends State<PremiumVerticalBudgetBar>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _pulseController;
  late Animation<double> _fillAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Fill animation
    _fillController = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.countUp,
    );
    _fillAnimation = CurvedAnimation(
      parent: _fillController,
      curve: PsychologyAnimations.standardCurve,
    );
    _fillController.forward();

    // Pulse animation for warning state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.percentage >= 70) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PremiumVerticalBudgetBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _fillController.forward(from: 0);
      if (widget.percentage >= 70 && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      } else if (widget.percentage < 70 && _pulseController.isAnimating) {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = PsychologyColors.getBudgetColor(widget.percentage);
    final status = PsychologyColors.getBudgetStatus(widget.percentage);

    return AnimatedBuilder(
      animation: Listenable.merge([_fillAnimation, _pulseAnimation]),
      builder: (context, child) {
        final animatedPercentage = widget.percentage * _fillAnimation.value;
        final fillHeight = (animatedPercentage / 100) * widget.height;
        final glowIntensity = widget.percentage >= 70
            ? _pulseAnimation.value
            : 0.3;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bar container
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: PsychologyColors.surfaceElevated,
                borderRadius: BorderRadius.circular(widget.width / 2),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                ),
                boxShadow: PsychologyShadows.glow(color, intensity: glowIntensity),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.width / 2),
                child: Stack(
                  children: [
                    // Fill from top
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: fillHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              color,
                              color.withValues(alpha: 0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(widget.width / 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.showLabel) ...[
              const SizedBox(height: 12),
              // Percentage
              Text(
                '%${widget.percentage.toStringAsFixed(0)}',
                style: PsychologyTypography.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              // Status text
              Text(
                status,
                style: PsychologyTypography.labelSmall.copyWith(
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET 4: STREAK BADGE
// ═══════════════════════════════════════════════════════════════════════════

/// Animated streak badge for gamification
class PremiumStreakBadge extends StatefulWidget {
  final int streakCount;
  final VoidCallback? onTap;

  const PremiumStreakBadge({
    super.key,
    required this.streakCount,
    this.onTap,
  });

  @override
  State<PremiumStreakBadge> createState() => _PremiumStreakBadgeState();
}

class _PremiumStreakBadgeState extends State<PremiumStreakBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(
      begin: PsychologyAnimations.pulseMin,
      end: PsychologyAnimations.pulseMax,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.streakCount > 0) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PremiumStreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streakCount > 0 && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.streakCount == 0 && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.streakCount > 0;
    final color = isActive
        ? PsychologyColors.streakFlame
        : PsychologyColors.textTertiary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(PsychologyRadius.full),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
              ),
              boxShadow: isActive
                  ? PsychologyShadows.glow(color, intensity: 0.3)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: isActive ? _scaleAnimation.value : 1.0,
                  child: Icon(
                    CupertinoIcons.flame_fill,
                    size: 18,
                    color: color,
                    shadows: isActive
                        ? PsychologyShadows.iconHalo(color)
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.streakCount} gün',
                  style: PsychologyTypography.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET 5: STAT CARD
// ═══════════════════════════════════════════════════════════════════════════

/// Small stat card for bento grid layouts
class PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const PremiumStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PsychologyGlassCard(
      glowColor: color,
      glowIntensity: 0.15,
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
      padding: PsychologySpacing.cardPaddingCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: PsychologyTypography.labelSmall,
          ),
          const SizedBox(height: 4),
          // Value
          Text(
            value,
            style: PsychologyTypography.headlineMedium.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: PsychologyTypography.bodySmall.copyWith(
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET 6: SUCCESS BANNER
// ═══════════════════════════════════════════════════════════════════════════

/// Dopamine trigger success banner
class PremiumSuccessBanner extends StatefulWidget {
  final String message;
  final String? subtitle;
  final VoidCallback? onDismiss;

  const PremiumSuccessBanner({
    super.key,
    required this.message,
    this.subtitle,
    this.onDismiss,
  });

  @override
  State<PremiumSuccessBanner> createState() => _PremiumSuccessBannerState();
}

class _PremiumSuccessBannerState extends State<PremiumSuccessBanner>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.slow,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: PsychologyAnimations.bounce),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    HapticFeedback.mediumImpact();
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _glowController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PsychologyColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(PsychologyRadius.lg),
                border: Border.all(
                  color: PsychologyColors.success.withValues(alpha: 0.3),
                ),
                boxShadow: PsychologyShadows.glow(
                  PsychologyColors.success,
                  intensity: _glowAnimation.value,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PsychologyColors.success.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: PsychologyColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message,
                          style: PsychologyTypography.titleMedium.copyWith(
                            color: PsychologyColors.success,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: PsychologyTypography.bodySmall.copyWith(
                              color: PsychologyColors.success.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Dismiss
                  if (widget.onDismiss != null)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onDismiss!();
                      },
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 20,
                        color: PsychologyColors.success.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET 7: FLOATING TAB BAR
// ═══════════════════════════════════════════════════════════════════════════

class PremiumTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const PremiumTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Floating navigation bar that shrinks on scroll
class PremiumFloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<PremiumTabItem> items;
  final bool isExpanded;

  const PremiumFloatingTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PsychologyAnimations.standardDuration,
      curve: PsychologyAnimations.standardCurve,
      margin: EdgeInsets.symmetric(
        horizontal: isExpanded ? 20 : 40,
        vertical: isExpanded ? 20 : 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isExpanded ? 24 : 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 8 : 4,
              vertical: isExpanded ? 8 : 4,
            ),
            decoration: BoxDecoration(
              color: PsychologyColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(isExpanded ? 24 : 20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(index);
                    },
                    child: AnimatedContainer(
                      duration: PsychologyAnimations.quick,
                      padding: EdgeInsets.symmetric(
                        vertical: isExpanded ? 12 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? PsychologyColors.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(isExpanded ? 16 : 12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: isExpanded ? 24 : 20,
                            color: isSelected
                                ? PsychologyColors.primary
                                : PsychologyColors.textTertiary,
                          ),
                          if (isExpanded && isSelected) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: PsychologyTypography.labelSmall.copyWith(
                                color: PsychologyColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET 8: QUICK ACTION BUTTON
// ═══════════════════════════════════════════════════════════════════════════

/// FAB-style quick action button
class PremiumQuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PremiumQuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<PremiumQuickActionButton> createState() => _PremiumQuickActionButtonState();
}

class _PremiumQuickActionButtonState extends State<PremiumQuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.quick,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: PsychologyAnimations.standardCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _controller.reverse();
            },
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onTap();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color,
                    Color.lerp(widget.color, Colors.black, 0.2)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(PsychologyRadius.lg),
                boxShadow: [
                  // Color glow
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  // Depth shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: PsychologyTypography.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
