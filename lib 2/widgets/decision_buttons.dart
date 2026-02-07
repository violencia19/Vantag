import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../core/theme/psychology_design_system.dart';
import '../models/models.dart';

/// iOS 26 Liquid Glass Decision Buttons
/// Premium fintech-style decision interface with psychology-based emphasis
/// "Vazgeçtim" (Passed) button is emphasized with CYAN - positive for savings!
class DecisionButtons extends StatelessWidget {
  final Function(ExpenseDecision) onDecision;
  final bool enabled;

  const DecisionButtons({
    super.key,
    required this.onDecision,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l10n.whatIsYourDecision,
          style: PsychologyTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _AnimatedDecisionButton(
                label: l10n.bought,
                icon: CupertinoIcons.checkmark,
                color: PsychologyColors.decisionYes,
                decision: ExpenseDecision.yes,
                onTap: enabled ? () => onDecision(ExpenseDecision.yes) : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnimatedDecisionButton(
                label: l10n.thinking,
                icon: CupertinoIcons.clock,
                color: PsychologyColors.decisionThinking,
                decision: ExpenseDecision.thinking,
                onTap: enabled
                    ? () => onDecision(ExpenseDecision.thinking)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnimatedDecisionButton(
                label: l10n.passed,
                icon: CupertinoIcons.xmark,
                color: PsychologyColors.decisionNo, // CYAN - positive savings!
                decision: ExpenseDecision.no,
                onTap: enabled ? () => onDecision(ExpenseDecision.no) : null,
                isEmphasis: true, // Positive action = emphasized with glow
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedDecisionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final ExpenseDecision decision;
  final VoidCallback? onTap;
  final bool isEmphasis;

  const _AnimatedDecisionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.decision,
    required this.onTap,
    this.isEmphasis = false,
  });

  @override
  State<_AnimatedDecisionButton> createState() =>
      _AnimatedDecisionButtonState();
}

class _AnimatedDecisionButtonState extends State<_AnimatedDecisionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Scale animation using psychology timing
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

    // Emphasis glow for "Vazgeçtim" button (2s cycle)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isEmphasis) {
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

    // Psychology-based haptic feedback
    switch (widget.decision) {
      case ExpenseDecision.yes:
        HapticFeedback.mediumImpact();
        break;
      case ExpenseDecision.thinking:
        HapticFeedback.lightImpact();
        break;
      case ExpenseDecision.no:
        HapticFeedback.heavyImpact(); // Celebration for saving!
        break;
    }

    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onTap != null;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: _handleTap,
              child: AnimatedOpacity(
                opacity: isEnabled ? 1.0 : 0.5,
                duration: PsychologyAnimations.quick,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(PsychologyRadius.lg),
                    boxShadow: widget.isEmphasis
                        ? [
                            BoxShadow(
                              color: widget.color.withValues(
                                alpha: _glowAnimation.value,
                              ),
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
                        constraints: const BoxConstraints(minHeight: 88),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color.withValues(
                                alpha: _isPressed ? 0.2 : 0.12,
                              ),
                              widget.color.withValues(
                                alpha: _isPressed ? 0.15 : 0.06,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(PsychologyRadius.lg),
                          border: Border.all(
                            color: widget.color.withValues(
                              alpha: widget.isEmphasis ? 0.4 : 0.2,
                            ),
                            width: widget.isEmphasis ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon container with psychology glow
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
            ),
          );
        },
      ),
    );
  }
}

/// Single decision button (for separate usage)
class SingleDecisionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isSelected;

  const SingleDecisionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<SingleDecisionButton> createState() => _SingleDecisionButtonState();
}

class _SingleDecisionButtonState extends State<SingleDecisionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PsychologyAnimations.micro,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: PsychologyAnimations.buttonPressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PsychologyAnimations.standardCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.onTap != null) {
            _controller.forward();
            HapticFeedback.selectionClick();
          }
        },
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          if (widget.onTap != null) {
            HapticFeedback.lightImpact();
            widget.onTap!();
          }
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: PsychologyAnimations.standardDuration,
                curve: PsychologyAnimations.standardCurve,
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.color.withValues(alpha: 0.2)
                      : widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(PsychologyRadius.md),
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.color
                        : widget.color.withValues(alpha: 0.3),
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: widget.isSelected
                      ? PsychologyShadows.glow(widget.color, intensity: 0.2)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.color,
                      shadows: widget.isSelected
                          ? PsychologyShadows.iconHalo(widget.color)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: PsychologyTypography.labelMedium.copyWith(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
