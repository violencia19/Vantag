import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                        child: Image.asset(
                          'assets/icons/google_icon.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (_, __, ___) => Icon(
                            CupertinoIcons.globe,
                            size: 24,
                            color: context.vantColors.textPrimary,
                          ),
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
                        icon: CupertinoIcons.globe,
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
                          icon: Icons.apple,
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
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required VoidCallback onTap,
    required bool isLoading,
    required IconData icon,
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
                      Icon(
                        icon,
                        size: 18,
                        color: isPrimary
                            ? context.vantColors.textPrimary
                            : context.vantColors.textPrimary,
                      ),
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
