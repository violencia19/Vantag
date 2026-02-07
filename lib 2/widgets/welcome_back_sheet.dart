import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/services/reengagement_service.dart';
import 'package:vantag/theme/theme.dart';

/// Welcome back bottom sheet for returning stalled users
/// Shows personalized message based on days inactive
class WelcomeBackSheet extends StatefulWidget {
  final int daysSinceActive;
  final int? recoveredStreakPercent;
  final VoidCallback? onAddExpense;
  final VoidCallback? onDismiss;

  const WelcomeBackSheet({
    super.key,
    required this.daysSinceActive,
    this.recoveredStreakPercent,
    this.onAddExpense,
    this.onDismiss,
  });

  /// Show the welcome back sheet
  static Future<void> show(
    BuildContext context, {
    required int daysSinceActive,
    int? recoveredStreakPercent,
    VoidCallback? onAddExpense,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      isScrollControlled: true,
      builder: (context) => WelcomeBackSheet(
        daysSinceActive: daysSinceActive,
        recoveredStreakPercent: recoveredStreakPercent,
        onAddExpense: onAddExpense,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );

    // Mark as shown
    await ReengagementService().markWelcomeBackShown();
  }

  @override
  State<WelcomeBackSheet> createState() => _WelcomeBackSheetState();
}

class _WelcomeBackSheetState extends State<WelcomeBackSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = ReengagementService().getWelcomeBackMessage(
      context,
      widget.daysSinceActive,
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: message.color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: message.color.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onDismiss?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.appColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: context.appColors.textTertiary,
                  ),
                ),
              ),
            ),

            // Icon with glow
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    message.color.withValues(alpha: 0.2),
                    message.color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: message.color.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                message.icon,
                size: 40,
                color: message.color,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              message.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Days badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: message.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${widget.daysSinceActive} gün sonra',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: message.color,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              message.subtitle,
              style: TextStyle(
                fontSize: 15,
                color: context.appColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Streak recovery info (if applicable)
            if (widget.recoveredStreakPercent != null &&
                widget.recoveredStreakPercent! > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Serinin %${widget.recoveredStreakPercent}\'i kurtarıldı!',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // CTA Button
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onDismiss?.call();
                widget.onAddExpense?.call();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: message.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: message.color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      message.ctaText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Secondary action
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onDismiss?.call();
              },
              child: Text(
                'Sonra hatırlat',
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
