import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../screens/paywall_screen.dart';

/// AI Limit Dialog Types
enum AILimitType {
  free, // 5/day limit reached
  proSubscription, // 500/month limit reached
  lifetime, // 200/month limit reached
  rateLimit, // 20/hour rate limit reached
}

/// Shows AI limit dialog based on user type
class AILimitDialog {
  /// Show the appropriate dialog based on user type
  static Future<void> show(
    BuildContext context, {
    required AILimitType type,
    int? daysUntilReset,
    DateTime? resetDate,
    int? minutesUntilReset,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      barrierDismissible: false,
      builder: (context) => _AILimitDialogContent(
        type: type,
        daysUntilReset: daysUntilReset,
        resetDate: resetDate,
        minutesUntilReset: minutesUntilReset,
      ),
    );
  }
}

class _AILimitDialogContent extends StatelessWidget {
  final AILimitType type;
  final int? daysUntilReset;
  final DateTime? resetDate;
  final int? minutesUntilReset;

  const _AILimitDialogContent({
    required this.type,
    this.daysUntilReset,
    this.resetDate,
    this.minutesUntilReset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: context.vantColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.vantColors.cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              _buildIcon(context),
              const SizedBox(height: 20),

              // Title
              Text(
                _getTitle(l10n),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.vantColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                _getMessage(l10n),
                style: TextStyle(
                  fontSize: 14,
                  color: context.vantColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // Reset date info (for Pro/Lifetime, not for rateLimit)
              if (type != AILimitType.free && type != AILimitType.rateLimit && resetDate != null) ...[
                const SizedBox(height: 16),
                _buildResetInfo(context, l10n),
              ],

              const SizedBox(height: 24),

              // Primary Button
              _buildPrimaryButton(context, l10n),

              // Secondary text/button
              const SizedBox(height: 12),
              _buildSecondaryAction(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final IconData icon;
    final Color color;

    switch (type) {
      case AILimitType.free:
        icon = CupertinoIcons.lock_fill;
        color = context.vantColors.warning;
      case AILimitType.proSubscription:
      case AILimitType.lifetime:
        icon = CupertinoIcons.hourglass;
        color = context.vantColors.primary;
      case AILimitType.rateLimit:
        icon = CupertinoIcons.timer;
        color = context.vantColors.warning;
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, size: 36, color: color),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    switch (type) {
      case AILimitType.free:
        return l10n.aiLimitFreeTitleEmoji;
      case AILimitType.proSubscription:
      case AILimitType.lifetime:
        return l10n.aiLimitProTitleEmoji;
      case AILimitType.rateLimit:
        return l10n.aiRateLimitTitle;
    }
  }

  String _getMessage(AppLocalizations l10n) {
    switch (type) {
      case AILimitType.free:
        return l10n.aiLimitFreeMessage;
      case AILimitType.proSubscription:
        return l10n.aiLimitProMessage;
      case AILimitType.lifetime:
        return l10n.aiLimitLifetimeMessage;
      case AILimitType.rateLimit:
        return l10n.aiRateLimitMessage;
    }
  }

  Widget _buildResetInfo(BuildContext context, AppLocalizations l10n) {
    final monthName = _getMonthName(resetDate!.month, l10n);
    final resetText = l10n.aiLimitResetDate(
      resetDate!.day.toString(),
      monthName,
      daysUntilReset ?? 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.vantColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.vantColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.calendar_badge_plus,
            size: 18,
            color: context.vantColors.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              resetText,
              style: TextStyle(
                fontSize: 13,
                color: context.vantColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, AppLocalizations l10n) {
    switch (type) {
      case AILimitType.free:
        return _GradientButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaywallScreen()),
            );
          },
          icon: CupertinoIcons.rocket_fill,
          label: l10n.aiLimitUpgradeToPro,
        );

      case AILimitType.proSubscription:
      case AILimitType.lifetime:
      case AILimitType.rateLimit:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.vantColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.ok,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        );
    }
  }

  Widget _buildSecondaryAction(BuildContext context, AppLocalizations l10n) {
    final String text;
    switch (type) {
      case AILimitType.free:
        text = l10n.aiLimitTryTomorrow;
      case AILimitType.proSubscription:
      case AILimitType.lifetime:
        text = l10n.aiLimitOrWaitDays(daysUntilReset ?? 0);
      case AILimitType.rateLimit:
        text = l10n.aiRateLimitWait(minutesUntilReset ?? 0);
    }

    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: context.vantColors.textTertiary),
      ),
    );
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    switch (month) {
      case 1:
        return l10n.monthJan;
      case 2:
        return l10n.monthFeb;
      case 3:
        return l10n.monthMar;
      case 4:
        return l10n.monthApr;
      case 5:
        return l10n.monthMay;
      case 6:
        return l10n.monthJun;
      case 7:
        return l10n.monthJul;
      case 8:
        return l10n.monthAug;
      case 9:
        return l10n.monthSep;
      case 10:
        return l10n.monthOct;
      case 11:
        return l10n.monthNov;
      case 12:
        return l10n.monthDec;
      default:
        return '';
    }
  }
}

/// Gradient button widget
class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.vantColors.primary, context.vantColors.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.vantColors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
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
      ),
    );
  }
}
