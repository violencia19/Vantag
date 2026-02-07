import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';
import '../theme/theme.dart';

/// Shows a celebration overlay for pursuit completion
void showPursuitCelebration(
  BuildContext context,
  Pursuit completedPursuit, {
  required VoidCallback onShare,
  required VoidCallback onNewGoal,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black87,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return PursuitCelebrationOverlay(
        completedPursuit: completedPursuit,
        onShare: onShare,
        onNewGoal: onNewGoal,
        onDismiss: () => Navigator.of(context).pop(),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Full-screen celebration overlay for pursuit completion
class PursuitCelebrationOverlay extends StatefulWidget {
  final Pursuit completedPursuit;
  final VoidCallback onShare;
  final VoidCallback onNewGoal;
  final VoidCallback onDismiss;

  const PursuitCelebrationOverlay({
    super.key,
    required this.completedPursuit,
    required this.onShare,
    required this.onNewGoal,
    required this.onDismiss,
  });

  @override
  State<PursuitCelebrationOverlay> createState() =>
      _PursuitCelebrationOverlayState();
}

class _PursuitCelebrationOverlayState extends State<PursuitCelebrationOverlay>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _iconController;
  late Animation<double> _iconScale;

  // Animation timing
  bool _showIcon = false;
  bool _showTitle = false;
  bool _showSubtitle = false;
  bool _showStats = false;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Icon bounce animation
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_iconController);

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 200ms - Confetti starts
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _confettiController.play();
    haptics.celebrate();
    soundService.playCelebration();

    // 400ms - Icon bounces in
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _showIcon = true);
    _iconController.forward();
    haptics.light();

    // 600ms - Title fades in
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _showTitle = true);
    haptics.tap();

    // 800ms - Subtitle fades in
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _showSubtitle = true);
    haptics.tap();

    // 1000ms - Stats card slides up
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _showStats = true);
    haptics.light();

    // 1500ms - Buttons fade in
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _showButtons = true);
    haptics.tap();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  /// Calculate duration in days
  int get _durationDays {
    final now = widget.completedPursuit.completedAt ?? DateTime.now();
    return now.difference(widget.completedPursuit.createdAt).inDays;
  }

  /// Format saved hours
  String get _savedHoursFormatted {
    // Calculate hours based on saved amount
    // This is simplified - in real implementation you'd calculate based on hourly rate
    final hours =
        widget.completedPursuit.savedAmount / 100; // Placeholder calculation
    return hours.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.vantColors;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Lottie celebration background
          if (_showIcon)
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/animations/celebration.json',
                  repeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
              shouldLoop: false,
              colors: [
                VantColors.primary,
                VantColors.gold,
                Colors.white,
                VantColors.secondary,
                VantColors.accent, // Light gold
              ],
              createParticlePath: (size) => _drawStar(size),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    if (_showIcon)
                      ScaleTransition(
                        scale: _iconScale,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [VantColors.primary, VantColors.primaryLight],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: VantColors.primary.withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.completedPursuit.emoji,
                              style: const TextStyle(fontSize: 56),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Title
                    if (_showTitle)
                      Text(
                            '🎉 ${l10n.celebrationTitle}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOut,
                          ),

                    const SizedBox(height: 12),

                    // Subtitle
                    if (_showSubtitle)
                      Text(
                            l10n.celebrationSubtitle(
                              widget.completedPursuit.name,
                            ),
                            style: TextStyle(
                              fontSize: 18,
                              color: colors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOut,
                          ),

                    const SizedBox(height: 32),

                    // Stats Card
                    if (_showStats)
                      Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: colors.cardBorder,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildStatRow(
                                  icon: CupertinoIcons.clock_fill,
                                  label: l10n.celebrationTotalSaved(
                                    _savedHoursFormatted,
                                  ),
                                  colors: colors,
                                ),
                                const SizedBox(height: 12),
                                _buildStatRow(
                                  icon: CupertinoIcons.calendar,
                                  label: l10n.celebrationDuration(
                                    _durationDays,
                                  ),
                                  colors: colors,
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOut,
                          ),

                    const SizedBox(height: 40),

                    // Buttons
                    if (_showButtons) ...[
                      // Share Button (Primary)
                      SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                haptics.buttonPress();
                                widget.onDismiss();
                                widget.onShare();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VantColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.share,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.celebrationShare,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: 12),

                      // New Goal Button (Secondary)
                      SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                                haptics.buttonPress();
                                widget.onDismiss();
                                widget.onNewGoal();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.textPrimary,
                                side: BorderSide(
                                  color: colors.cardBorder,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.scope,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.celebrationNewGoal,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 100.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 300.ms,
                            delay: 100.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: 16),

                      // Dismiss Button
                      TextButton(
                        onPressed: () {
                          haptics.tap();
                          widget.onDismiss();
                        },
                        child: Text(
                          l10n.celebrationDismiss,
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required dynamic colors,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: VantColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: VantColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Draw a star shape for confetti
  Path _drawStar(Size size) {
    final path = Path();
    final double halfWidth = size.width / 2;
    final double halfHeight = size.height / 2;
    final double outerRadius = halfWidth;
    final double innerRadius = halfWidth * 0.4;

    for (int i = 0; i < 5; i++) {
      final double angle = (i * 72 - 90) * pi / 180;
      final double nextAngle = ((i * 72) + 36 - 90) * pi / 180;

      final outerX = halfWidth + outerRadius * cos(angle);
      final outerY = halfHeight + outerRadius * sin(angle);
      final innerX = halfWidth + innerRadius * cos(nextAngle);
      final innerY = halfHeight + innerRadius * sin(nextAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }

    path.close();
    return path;
  }
}
