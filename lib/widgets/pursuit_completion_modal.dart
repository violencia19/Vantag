import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/pursuit.dart';
import 'package:vantag/theme/theme.dart';

/// Celebration modal shown when a pursuit reaches 100%
class PursuitCompletionModal extends StatefulWidget {
  final Pursuit pursuit;
  final String Function(double amount) formatAmount;
  final VoidCallback? onShare;
  final VoidCallback? onDismiss;

  const PursuitCompletionModal({
    super.key,
    required this.pursuit,
    required this.formatAmount,
    this.onShare,
    this.onDismiss,
  });

  @override
  State<PursuitCompletionModal> createState() => _PursuitCompletionModalState();
}

class _PursuitCompletionModalState extends State<PursuitCompletionModal>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Animation controller for modal entrance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      _animationController.forward();
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final daysSinceCreation = widget.pursuit.daysSinceCreation;

    return Stack(
      children: [
        // Background overlay
        GestureDetector(
          onTap: _dismiss,
          child: AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, child) => Container(
              color: Colors.black.withValues(
                alpha: 0.7 * _opacityAnimation.value,
              ),
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 20,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.2,
            shouldLoop: false,
            colors: [
              context.vantColors.gold,
              VantColors.secondary,
              VantColors.primary,
              context.vantColors.success,
              Colors.white,
            ],
          ),
        ),

        // Modal content
        Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(opacity: _opacityAnimation.value, child: child),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.vantColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: context.vantColors.gold.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.vantColors.gold.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji with gold glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          context.vantColors.gold.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.pursuit.emoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Congratulations text
                  Text(
                    l10n.congratulations,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: Color(0xFFFAFAFA)).copyWith(
                      fontSize: 28,
                      color: context.vantColors.gold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dream came true
                  Text(
                    l10n.pursuitCompleted,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFA1A1AA)).copyWith(
                      color: context.vantColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.vantColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.vantColors.cardBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.pursuit.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA1A1AA)).copyWith(
                            color: context.vantColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.pursuitCompletedMessage(
                            daysSinceCreation,
                            widget.formatAmount(widget.pursuit.savedAmount),
                          ),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF71717A)).copyWith(
                            color: context.vantColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      // Share button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            widget.onShare?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.vantColors.textPrimary,
                            side: BorderSide(color: context.vantColors.cardBorder),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: Icon(
                            CupertinoIcons.share,
                            size: 18,
                          ),
                          label: Text(l10n.shareProgress),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Done button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _dismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.vantColors.gold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.great,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _dismiss() {
    widget.onDismiss?.call();
    Navigator.of(context).pop();
  }
}

/// Show the pursuit completion modal
Future<void> showPursuitCompletionModal(
  BuildContext context, {
  required Pursuit pursuit,
  required String Function(double amount) formatAmount,
  VoidCallback? onShare,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (_) => PursuitCompletionModal(
      pursuit: pursuit,
      formatAmount: formatAmount,
      onShare: onShare,
    ),
  );
}
