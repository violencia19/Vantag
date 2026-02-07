import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Enhanced empty state widget with CTA and value propositions
/// Features:
/// - Illustration/icon with pulse animation
/// - Value proposition (1 line)
/// - CTA button
/// - Optional example data preview
class EmptyState extends StatefulWidget {
  final IconData icon;
  final Color? iconColor;
  final String? title;
  final String message;
  final Widget? action;
  final bool useLottie;
  final String? ctaText;
  final VoidCallback? onCtaTap;
  final bool showExampleData;
  final Widget? exampleDataWidget;

  const EmptyState({
    super.key,
    this.icon = CupertinoIcons.tray,
    this.iconColor,
    this.title,
    required this.message,
    this.action,
    this.useLottie = false,
    this.ctaText,
    this.onCtaTap,
    this.showExampleData = false,
    this.exampleDataWidget,
  });

  /// Empty state for expense list - engaging CTA
  factory EmptyState.expenses({
    required String message,
    required String ctaText,
    required VoidCallback onCtaTap,
    bool useLottie = true,
  }) {
    return EmptyState(
      icon: CupertinoIcons.doc_text,
      iconColor: const Color(0xFF6C63FF),
      message: message,
      useLottie: useLottie,
      ctaText: ctaText,
      onCtaTap: onCtaTap,
    );
  }

  /// Empty state for achievements list
  factory EmptyState.achievements({
    required String message,
    String? ctaText,
    VoidCallback? onCtaTap,
  }) {
    return EmptyState(
      icon: CupertinoIcons.rosette,
      iconColor: const Color(0xFFF59E0B),
      message: message,
      ctaText: ctaText,
      onCtaTap: onCtaTap,
    );
  }

  /// Empty state for reports
  factory EmptyState.reports({
    required String message,
    String? ctaText,
    VoidCallback? onCtaTap,
  }) {
    return EmptyState(
      icon: CupertinoIcons.chart_bar,
      iconColor: const Color(0xFF2DD4BF),
      message: message,
      ctaText: ctaText,
      onCtaTap: onCtaTap,
    );
  }

  /// Empty state for subscription list
  factory EmptyState.subscriptions({
    required String message,
    String? ctaText,
    VoidCallback? onCtaTap,
  }) {
    return EmptyState(
      icon: CupertinoIcons.calendar_badge_plus,
      iconColor: const Color(0xFF8B5CF6),
      message: message,
      ctaText: ctaText,
      onCtaTap: onCtaTap,
    );
  }

  /// Empty state for pursuits with Lottie animation
  factory EmptyState.pursuits({
    required String message,
    required String ctaText,
    required VoidCallback onCtaTap,
    bool useLottie = true,
  }) {
    return EmptyState(
      icon: CupertinoIcons.scope,
      iconColor: const Color(0xFF10B981),
      message: message,
      useLottie: useLottie,
      ctaText: ctaText,
      onCtaTap: onCtaTap,
    );
  }

  /// Empty state for AI chat history
  factory EmptyState.aiChat({
    required String message,
    String? ctaText,
    VoidCallback? onCtaTap,
  }) {
    return EmptyState(
      icon: CupertinoIcons.sparkles,
      iconColor: const Color(0xFF6C63FF),
      message: message,
      ctaText: ctaText,
      onCtaTap: onCtaTap,
    );
  }

  /// Empty state for savings pool
  factory EmptyState.savingsPool({
    required String message,
    String? ctaText,
    VoidCallback? onCtaTap,
  }) {
    return EmptyState(
      icon: CupertinoIcons.money_dollar_circle,
      iconColor: const Color(0xFF10B981),
      message: message,
      ctaText: ctaText,
      onCtaTap: onCtaTap,
    );
  }

  /// Empty state for search results
  factory EmptyState.searchResults({required String message}) {
    return EmptyState(
      icon: CupertinoIcons.search,
      iconColor: const Color(0xFF6B7280),
      message: message,
    );
  }

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with TickerProviderStateMixin {
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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

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
    final iconColor = widget.iconColor ?? context.appColors.primary;

    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animasyonlu ikon veya Lottie
                if (widget.useLottie)
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Lottie.asset(
                      'assets/animations/empty.json',
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                iconColor.withValues(alpha: 0.15),
                                iconColor.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: iconColor.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 40,
                            color: iconColor,
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],

                // Mesaj - değer önerisi (1 satır)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.appColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // CTA Button
                if (widget.ctaText != null && widget.onCtaTap != null) ...[
                  const SizedBox(height: 24),
                  _buildCtaButton(context, iconColor),
                ],

                // Eski aksiyon butonu (geriye uyumluluk)
                if (widget.action != null && widget.ctaText == null) ...[
                  const SizedBox(height: 24),
                  widget.action!,
                ],

                // Örnek veri gösterimi
                if (widget.showExampleData && widget.exampleDataWidget != null) ...[
                  const SizedBox(height: 32),
                  _buildExampleDataSection(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context, Color iconColor) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onCtaTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.plus,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              widget.ctaText!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleDataSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 1,
              color: context.appColors.cardBorder,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                l10n.emptyStateExampleTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.textTertiary,
                ),
              ),
            ),
            Container(
              width: 40,
              height: 1,
              color: context.appColors.cardBorder,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Opacity(
          opacity: 0.6,
          child: widget.exampleDataWidget!,
        ),
      ],
    );
  }
}

/// Contextual empty state builder with localized messages
/// Use this for quick access to properly configured empty states
class ContextualEmptyState {
  /// Expenses empty state with localized message and CTA
  static Widget expenses(BuildContext context, {required VoidCallback onAdd}) {
    final l10n = AppLocalizations.of(context);
    return EmptyState.expenses(
      message: l10n.emptyStateExpensesMessage,
      ctaText: l10n.emptyStateExpensesCta,
      onCtaTap: onAdd,
    );
  }

  /// Pursuits empty state with localized message and CTA
  static Widget pursuits(BuildContext context, {required VoidCallback onAdd}) {
    final l10n = AppLocalizations.of(context);
    return EmptyState.pursuits(
      message: l10n.emptyStatePursuitsMessage,
      ctaText: l10n.emptyStatePursuitsCta,
      onCtaTap: onAdd,
    );
  }

  /// Reports empty state with localized message
  static Widget reports(BuildContext context, {VoidCallback? onAddExpense}) {
    final l10n = AppLocalizations.of(context);
    return EmptyState.reports(
      message: l10n.emptyStateReportsMessage,
      ctaText: onAddExpense != null ? l10n.emptyStateReportsCta : null,
      onCtaTap: onAddExpense,
    );
  }

  /// Subscriptions empty state with localized message and CTA
  static Widget subscriptions(BuildContext context, {required VoidCallback onAdd}) {
    final l10n = AppLocalizations.of(context);
    return EmptyState.subscriptions(
      message: l10n.emptyStateSubscriptionsMessage,
      ctaText: l10n.emptyStateSubscriptionsCta,
      onCtaTap: onAdd,
    );
  }

  /// Achievements empty state with localized message
  static Widget achievements(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState.achievements(
      message: l10n.emptyStateAchievementsMessage,
    );
  }

  /// Savings pool empty state with localized message
  static Widget savingsPool(BuildContext context, {VoidCallback? onAdd}) {
    final l10n = AppLocalizations.of(context);
    return EmptyState.savingsPool(
      message: l10n.emptyStateSavingsPoolMessage,
      onCtaTap: onAdd,
    );
  }

  /// Search results empty state
  static Widget searchResults(BuildContext context, String query) {
    return EmptyState.searchResults(
      message: '"$query" için sonuç bulunamadı',
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

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
                  context.appColors.surfaceLight,
                  context.appColors.surfaceLighter,
                  context.appColors.surfaceLight,
                ],
                stops: [0.0, _animation.value, 1.0],
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
