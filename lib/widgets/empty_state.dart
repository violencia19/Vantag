import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme.dart';

/// Empty state widget
/// Fade in + small icon pulse animation
class EmptyState extends StatefulWidget {
  final IconData icon;
  final String? title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon = LucideIcons.inbox,
    this.title,
    required this.message,
    this.action,
  });

  /// Empty state for expense list
  factory EmptyState.expenses({required String message}) {
    return EmptyState(
      icon: LucideIcons.receipt,
      message: message,
    );
  }

  /// Empty state for achievements list
  factory EmptyState.achievements({required String message}) {
    return EmptyState(
      icon: LucideIcons.trophy,
      message: message,
    );
  }

  /// Empty state for reports
  factory EmptyState.reports({required String message}) {
    return EmptyState(
      icon: LucideIcons.barChart3,
      message: message,
    );
  }

  /// Empty state for subscription list
  factory EmptyState.subscriptions({required String message}) {
    return EmptyState(
      icon: LucideIcons.calendar,
      message: message,
    );
  }

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Fade in animasyonu
    _fadeController = AnimationController(
      vsync: this,
      duration: AppAnimations.long,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.standardCurve,
    );

    // Pulse animasyonu
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animasyonları başlat
    Future.delayed(AppAnimations.initialDelay, () {
      if (mounted) {
        _fadeController.forward();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animasyonlu ikon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Başlık (opsiyonel)
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],

                // Mesaj
                Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Aksiyon butonu (opsiyonel)
                if (widget.action != null) ...[
                  const SizedBox(height: 24),
                  widget.action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Yükleniyor durumu için shimmer efektli placeholder
class LoadingPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const LoadingPlaceholder({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });

  @override
  State<LoadingPlaceholder> createState() => _LoadingPlaceholderState();
}

class _LoadingPlaceholderState extends State<LoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.surfaceLight,
                  AppColors.surfaceLighter,
                  AppColors.surfaceLight,
                ],
                stops: [
                  0.0,
                  _animation.value,
                  1.0,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Liste için shimmer placeholder
class ListLoadingPlaceholder extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const ListLoadingPlaceholder({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: LoadingPlaceholder(
            height: itemHeight,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }),
    );
  }
}
