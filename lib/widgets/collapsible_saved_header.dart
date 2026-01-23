import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart';
import 'animated_counter.dart';

/// Kaydırılabilir header widget'ı
/// Scroll edince küçülür, opacity azalır, scale değişir
class CollapsibleSavedHeader extends StatelessWidget {
  final DecisionStats stats;
  final double expandRatio; // 1.0 = tam açık, 0.0 = tam kapalı

  const CollapsibleSavedHeader({
    super.key,
    required this.stats,
    required this.expandRatio,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();

    // Animasyon değerleri
    final opacity = AppAnimations.headerMinOpacity +
        ((1.0 - AppAnimations.headerMinOpacity) * expandRatio);
    final scale = AppAnimations.headerMinScale +
        ((1.0 - AppAnimations.headerMinScale) * expandRatio);

    // Boyutları expandRatio'ya göre hesapla
    final iconSize = 40.0 + (40.0 * expandRatio); // 40px -> 80px
    final iconContainerSize = 48.0 + (48.0 * expandRatio); // 48px -> 96px
    final amountFontSize = 20.0 + (12.0 * expandRatio); // 20px -> 32px
    final labelFontSize = 12.0 + (4.0 * expandRatio); // 12px -> 16px

    // Parallax offset (yukarı kayma efekti)
    final parallaxOffset = (1.0 - expandRatio) * -10;

    // Hiç kurtarılan para yoksa küçük placeholder göster
    if (stats.noCount == 0) {
      return RepaintBoundary(
        child: Transform.translate(
          offset: Offset(0, parallaxOffset),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildEmptyState(context, expandRatio, l10n),
              ),
            ),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: Transform.translate(
        offset: Offset(0, parallaxOffset),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: Opacity(
            opacity: opacity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 8 + (12 * expandRatio),
                  horizontal: 12 + (8 * expandRatio),
                ),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(12 + (4 * expandRatio)),
                  border: Border.all(
                    color: context.appColors.primary.withValues(alpha: 0.2 + (0.1 * expandRatio)),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.primary.withValues(alpha: 0.05 * expandRatio),
                      blurRadius: 20 * expandRatio,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Animated Icon
                    _AnimatedSavingsIcon(
                      size: iconContainerSize,
                      iconSize: iconSize,
                      expandRatio: expandRatio,
                    ),
                    SizedBox(width: 10 + (6 * expandRatio)),

                    // Amount ve Label
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Slot-machine style counter
                        NumberTicker(
                          value: stats.savedAmount,
                          style: TextStyle(
                            fontSize: amountFontSize,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.primary,
                            letterSpacing: -1,
                            height: 1.2,
                          ),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 2 + (2 * expandRatio), bottom: 2),
                          child: Text(
                            currencyProvider.symbol,
                            style: TextStyle(
                              fontSize: 10 + (4 * expandRatio),
                              fontWeight: FontWeight.w600,
                              color: context.appColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6 + (4 * expandRatio)),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            l10n.youSaved,
                            style: TextStyle(
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.w500,
                              color: context.appColors.textSecondary,
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
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, double expandRatio, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 + (8 * expandRatio),
        vertical: 8 + (8 * expandRatio),
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.appColors.cardBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsDuotone.shieldCheck,
            size: 20 + (12 * expandRatio),
            color: context.appColors.textTertiary,
          ),
          SizedBox(width: 6 + (4 * expandRatio)),
          Text(
            l10n.noSavingsYet,
            style: TextStyle(
              fontSize: 12 + (2 * expandRatio),
              fontWeight: FontWeight.w500,
              color: context.appColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animasyonlu tasarruf ikonu
class _AnimatedSavingsIcon extends StatefulWidget {
  final double size;
  final double iconSize;
  final double expandRatio;

  const _AnimatedSavingsIcon({
    required this.size,
    required this.iconSize,
    required this.expandRatio,
  });

  @override
  State<_AnimatedSavingsIcon> createState() => _AnimatedSavingsIconState();
}

class _AnimatedSavingsIconState extends State<_AnimatedSavingsIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Sürekli yumuşak pulse
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        // Sadece açık durumda pulse efekti
        final scale = widget.expandRatio > 0.5 ? _pulseAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12 + (8 * widget.expandRatio)),
            ),
            child: Icon(
              PhosphorIconsDuotone.shieldCheck,
              size: widget.iconSize,
              color: context.appColors.primary,
            ),
          ),
        );
      },
    );
  }
}

/// SliverAppBar için delegasyon widget'ı
class CollapsibleSavedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DecisionStats stats;
  final double minHeight;
  final double maxHeight;

  CollapsibleSavedHeaderDelegate({
    required this.stats,
    this.minHeight = 60,
    this.maxHeight = 120,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final expandRatio = 1.0 - (shrinkOffset / (maxHeight - minHeight)).clamp(0.0, 1.0);

    return Container(
      color: context.appColors.background,
      alignment: Alignment.center,
      child: CollapsibleSavedHeader(
        stats: stats,
        expandRatio: expandRatio,
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant CollapsibleSavedHeaderDelegate oldDelegate) {
    return stats.savedAmount != oldDelegate.stats.savedAmount ||
        stats.noCount != oldDelegate.stats.noCount;
  }
}
