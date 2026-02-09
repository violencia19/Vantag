import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';

/// Paints the official Google "G" logo using SVG paths with brand colors
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Scale to fit the canvas (paths are based on 48x48 viewBox)
    final scale = size.width / 48.0;
    canvas.scale(scale, scale);

    // Blue section (right side + crossbar)
    final bluePath = Path()
      ..moveTo(43.611, 20.083)
      ..lineTo(43.611, 20.083)
      ..cubicTo(43.611, 18.683, 43.492, 17.329, 43.265, 16.025)
      ..lineTo(24.0, 16.025)
      ..lineTo(24.0, 23.648)
      ..lineTo(35.012, 23.648)
      ..cubicTo(34.504, 26.357, 32.914, 28.657, 30.565, 30.168)
      ..lineTo(30.565, 35.568)
      ..cubicTo(37.392, 32.768, 43.611, 27.168, 43.611, 20.083)
      ..close();
    canvas.drawPath(bluePath, Paint()..color = const Color(0xFF4285F4));

    // Green section (bottom-right)
    final greenPath = Path()
      ..moveTo(24.0, 44.0)
      ..cubicTo(30.48, 44.0, 35.944, 41.843, 30.565, 35.568)
      ..lineTo(30.565, 35.568)
      ..cubicTo(28.216, 37.079, 26.316, 37.925, 24.0, 37.925)
      ..cubicTo(17.836, 37.925, 12.62, 33.527, 10.906, 27.735)
      ..lineTo(4.0, 27.735)
      ..lineTo(4.0, 33.335)
      ..cubicTo(8.443, 40.182, 15.664, 44.0, 24.0, 44.0)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF34A853));

    // Yellow section (bottom-left)
    final yellowPath = Path()
      ..moveTo(10.906, 27.735)
      ..cubicTo(10.406, 26.235, 10.125, 24.644, 10.125, 23.0)
      ..cubicTo(10.125, 21.356, 10.406, 19.765, 10.906, 18.265)
      ..lineTo(10.906, 18.265)
      ..lineTo(4.0, 12.665)
      ..cubicTo(2.328, 16.0, 1.375, 19.394, 1.375, 23.0)
      ..cubicTo(1.375, 26.606, 2.328, 30.0, 4.0, 33.335)
      ..lineTo(10.906, 27.735)
      ..close();
    canvas.drawPath(yellowPath, Paint()..color = const Color(0xFFFBBC05));

    // Red section (top)
    final redPath = Path()
      ..moveTo(24.0, 8.075)
      ..cubicTo(27.444, 8.075, 30.08, 9.231, 32.485, 11.219)
      ..lineTo(37.564, 6.14)
      ..cubicTo(34.744, 3.533, 30.48, 2.0, 24.0, 2.0)
      ..cubicTo(15.664, 2.0, 8.443, 5.818, 4.0, 12.665)
      ..lineTo(10.906, 18.265)
      ..cubicTo(12.62, 12.473, 17.836, 8.075, 24.0, 8.075)
      ..close();
    canvas.drawPath(redPath, Paint()..color = const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Login prompt card shown to users who haven't linked their account
/// Glassmorphism design with Google + Apple sign-in options
class LoginPromptCard extends StatefulWidget {
  final VoidCallback? onDismiss;
  final VoidCallback? onLoginSuccess;

  const LoginPromptCard({
    super.key,
    this.onDismiss,
    this.onLoginSuccess,
  });

  @override
  State<LoginPromptCard> createState() => _LoginPromptCardState();
}

class _LoginPromptCardState extends State<LoginPromptCard> {
  final _authService = AuthService();
  bool _isLoadingGoogle = false;
  bool _isLoadingApple = false;

  Future<void> _signInWithGoogle() async {
    if (_isLoadingGoogle || _isLoadingApple) return;

    setState(() => _isLoadingGoogle = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (result.success) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.googleLinkedSuccess),
            backgroundColor: context.vantColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onLoginSuccess?.call();
      } else if (result.errorMessage != null &&
          result.errorMessage != 'Giriş iptal edildi') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: context.vantColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingGoogle = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    if (_isLoadingGoogle || _isLoadingApple) return;

    setState(() => _isLoadingApple = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await _authService.signInWithApple();

      if (!mounted) return;

      if (result.success) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appleLinkedSuccess),
            backgroundColor: context.vantColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onLoginSuccess?.call();
      } else if (result.errorMessage != null &&
          result.errorMessage != 'Giriş iptal edildi') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: context.vantColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingApple = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showApple = Platform.isIOS;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.vantColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.vantColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.vantColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.vantColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(24, 24),
                          painter: _GoogleLogoPainter(),
                        ),
                      ),
                    ),
                    if (showApple) ...[
                      const SizedBox(width: 12),
                      // Apple icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.vantColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.apple,
                            size: 24,
                            color: context.vantColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  l10n.loginPromptTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.vantColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  l10n.loginPromptSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.vantColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons row
                Row(
                  children: [
                    // Google button
                    Expanded(
                      child: _buildLoginButton(
                        onTap: _signInWithGoogle,
                        isLoading: _isLoadingGoogle,
                        iconWidget: CustomPaint(
                          size: const Size(18, 18),
                          painter: _GoogleLogoPainter(),
                        ),
                        label: l10n.linkWithGoogle,
                        isPrimary: true,
                      ),
                    ),
                    if (showApple) ...[
                      const SizedBox(width: 12),
                      // Apple button
                      Expanded(
                        child: _buildLoginButton(
                          onTap: _signInWithApple,
                          isLoading: _isLoadingApple,
                          iconWidget: Icon(
                            Icons.apple,
                            size: 18,
                            color: context.vantColors.textPrimary,
                          ),
                          label: l10n.linkWithApple,
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Dismiss link
                TextButton(
                  onPressed: widget.onDismiss,
                  style: TextButton.styleFrom(
                    foregroundColor: context.vantColors.textTertiary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    l10n.loginPromptLater,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildLoginButton({
    required VoidCallback onTap,
    required bool isLoading,
    required Widget iconWidget,
    required String label,
    required bool isPrimary,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isPrimary
                ? context.vantColors.primary
                : context.vantColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(color: context.vantColors.cardBorder),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isPrimary
                          ? context.vantColors.textPrimary
                          : context.vantColors.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconWidget,
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isPrimary
                                ? context.vantColors.textPrimary
                                : context.vantColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
