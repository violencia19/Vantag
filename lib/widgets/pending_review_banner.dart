import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Banner widget shown when there are pending expenses to review
class PendingReviewBanner extends StatelessWidget {
  /// Number of expenses pending categorization
  final int pendingCount;

  /// Number of expenses with suggestions
  final int suggestionCount;

  /// Callback when banner is tapped
  final VoidCallback onTap;

  /// Optional callback for dismiss
  final VoidCallback? onDismiss;

  const PendingReviewBanner({
    super.key,
    required this.pendingCount,
    required this.suggestionCount,
    required this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalCount = pendingCount + suggestionCount;

    if (totalCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon with pulse animation
                  _buildPulsingIcon(),
                  const SizedBox(width: 12),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.pendingCategorization(totalCount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (suggestionCount > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            l10n.suggestionsAvailable(suggestionCount),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Arrow
                  const PhosphorIcon(
                    PhosphorIconsFill.caretRight,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),

            // Dismiss button (if provided)
            if (onDismiss != null)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.x,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onDismiss!();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.05),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsFill.warning,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
      onEnd: () {},
    );
  }
}

/// Compact version for smaller spaces
class PendingReviewChip extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const PendingReviewChip({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              PhosphorIconsFill.warning,
              color: AppColors.warning,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
