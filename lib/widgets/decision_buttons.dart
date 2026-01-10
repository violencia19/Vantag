import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          l10n.whatIsYourDecision,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _AnimatedDecisionButton(
                label: l10n.bought,
                icon: PhosphorIconsDuotone.check,
                color: AppColors.decisionYes,
                decision: ExpenseDecision.yes,
                onTap: enabled ? () => onDecision(ExpenseDecision.yes) : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnimatedDecisionButton(
                label: l10n.thinking,
                icon: PhosphorIconsDuotone.clock,
                color: AppColors.decisionThinking,
                decision: ExpenseDecision.thinking,
                onTap: enabled ? () => onDecision(ExpenseDecision.thinking) : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnimatedDecisionButton(
                label: l10n.passed,
                icon: PhosphorIconsDuotone.x,
                color: AppColors.decisionNo,
                decision: ExpenseDecision.no,
                onTap: enabled ? () => onDecision(ExpenseDecision.no) : null,
                isEmphasis: true, // Passed button with heavier animation
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
  State<_AnimatedDecisionButton> createState() => _AnimatedDecisionButtonState();
}

class _AnimatedDecisionButtonState extends State<_AnimatedDecisionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _colorAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.isEmphasis
          ? const Duration(milliseconds: 200)
          : AppAnimations.short,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.buttonPressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standardCurve,
    ));

    _colorAnimation = Tween<double>(
      begin: 0.1,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standardCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
    // Light haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.onTap == null) return;

    // Haptic feedback based on decision type
    switch (widget.decision) {
      case ExpenseDecision.yes:
        HapticFeedback.mediumImpact();
        break;
      case ExpenseDecision.thinking:
        HapticFeedback.lightImpact();
        break;
      case ExpenseDecision.no:
        HapticFeedback.heavyImpact();
        break;
    }

    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onTap != null;

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedOpacity(
                opacity: isEnabled ? 1.0 : AppAnimations.disabledOpacity,
                duration: AppAnimations.short,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: _colorAnimation.value),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.color.withValues(
                        alpha: _isPressed ? 0.6 : 0.3,
                      ),
                      width: _isPressed ? 1.5 : 1,
                    ),
                    boxShadow: _isPressed
                        ? [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      // Icon container
                      AnimatedContainer(
                        duration: AppAnimations.micro,
                        curve: AppAnimations.standardCurve,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(
                            alpha: _isPressed ? 0.3 : 0.15,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 22,
                          color: widget.color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Label
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
      duration: AppAnimations.micro,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.buttonPressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standardCurve,
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
                duration: AppAnimations.short,
                curve: AppAnimations.standardCurve,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.color.withValues(alpha: 0.2)
                      : widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.color
                        : widget.color.withValues(alpha: 0.3),
                    width: widget.isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 14,
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
