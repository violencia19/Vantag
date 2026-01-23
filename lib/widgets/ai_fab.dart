import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

class AIFloatingButton extends StatefulWidget {
  final VoidCallback onTap;
  const AIFloatingButton({super.key, required this.onTap});

  @override
  State<AIFloatingButton> createState() => _AIFloatingButtonState();
}

class _AIFloatingButtonState extends State<AIFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Semantics(
          label: l10n.featureAiChat,
          button: true,
          child: Tooltip(
            message: l10n.featureAiChat,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.appColors.primary,
                      context.appColors.primaryDark,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.primary.withValues(
                        alpha: 0.4 * _animation.value,
                      ),
                      blurRadius: 16 * _animation.value,
                      spreadRadius: 2 * _animation.value,
                    ),
                  ],
                ),
                child: const Icon(
                  PhosphorIconsDuotone.sparkle,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
