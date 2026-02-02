import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/subscription_manager.dart';
import '../theme/theme.dart';

/// Yaklaşan Yenileme Uyarı Banner'ı
/// Yaklaşan abonelik yenilemelerini gösteren banner
class RenewalWarningBanner extends StatefulWidget {
  final int withinHours;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const RenewalWarningBanner({
    super.key,
    this.withinHours = 24,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<RenewalWarningBanner> createState() => _RenewalWarningBannerState();
}

class _RenewalWarningBannerState extends State<RenewalWarningBanner>
    with SingleTickerProviderStateMixin {
  List<Subscription> _upcomingRenewals = [];
  bool _isLoading = true;
  bool _isDismissed = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadRenewals();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadRenewals() async {
    try {
      // withinHours'u gün cinsine çevir (24 saat = 1 gün)
      final days = (widget.withinHours / 24).ceil();
      final renewals = await subscriptionManager.getUpcomingRenewals(days);

      setState(() {
        _upcomingRenewals = renewals;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[RenewalWarningBanner] Error loading renewals: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading || _isDismissed || _upcomingRenewals.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalAmount = _upcomingRenewals.fold<double>(
      0,
      (sum, s) => sum + s.amount,
    );

    final isUrgent = _upcomingRenewals.any((s) => s.hoursUntilRenewal <= 6);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isUrgent ? AppColors.urgentOrange : AppColors.secondary)
                  .withValues(alpha: 0.5 * _pulseAnimation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isUrgent ? AppColors.urgentOrange : AppColors.secondary)
                    .withValues(alpha: 0.2 * _pulseAnimation.value),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: context.appColors.surface.withValues(alpha: 0.9),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onTap?.call();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isUrgent
                                    ? [AppColors.urgentOrange, AppColors.error]
                                    : [AppColors.secondary, AppColors.primary],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isUrgent
                                  ? CupertinoIcons.exclamationmark_circle
                                  : CupertinoIcons.bell,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isUrgent
                                      ? l10n.urgentRenewalWarning
                                      : l10n.upcomingRenewals,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isUrgent
                                        ? AppColors.urgentOrange
                                        : AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _buildDescription(l10n),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.appColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Amount
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isUrgent
                                          ? AppColors.urgentOrange
                                          : AppColors.secondary)
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${totalAmount.toStringAsFixed(0)} ₺',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isUrgent
                                    ? AppColors.urgentOrange
                                    : AppColors.secondary,
                              ),
                            ),
                          ),

                          // Dismiss button
                          if (widget.onDismiss != null) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _isDismissed = true);
                                widget.onDismiss?.call();
                              },
                              child: Icon(
                                CupertinoIcons.xmark,
                                size: 18,
                                color: context.appColors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildDescription(AppLocalizations l10n) {
    if (_upcomingRenewals.length == 1) {
      final sub = _upcomingRenewals.first;
      final hours = sub.hoursUntilRenewal;

      if (hours <= 1) {
        return l10n.renewsWithinOneHour(sub.name);
      } else if (hours <= 6) {
        return l10n.renewsWithinHours(sub.name, hours);
      } else if (sub.isRenewalToday) {
        return l10n.renewsToday(sub.name);
      } else {
        return l10n.renewsTomorrow(sub.name);
      }
    }

    return l10n.subscriptionsRenewingSoon(_upcomingRenewals.length);
  }
}

/// Kompakt Yenileme Uyarısı (Header için)
class CompactRenewalBadge extends StatelessWidget {
  final int count;
  final double totalAmount;
  final VoidCallback? onTap;

  const CompactRenewalBadge({
    super.key,
    required this.count,
    required this.totalAmount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.bell,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 1,
              height: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              '${totalAmount.toStringAsFixed(0)}₺',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// FutureBuilder ile Renewal Badge
class RenewalBadgeLoader extends StatelessWidget {
  final int withinDays;
  final VoidCallback? onTap;

  const RenewalBadgeLoader({super.key, this.withinDays = 1, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Subscription>>(
      future: subscriptionManager.getUpcomingRenewals(withinDays),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final renewals = snapshot.data!;
        final total = renewals.fold<double>(0, (sum, s) => sum + s.amount);

        return CompactRenewalBadge(
          count: renewals.length,
          totalAmount: total,
          onTap: onTap,
        );
      },
    );
  }
}

/// Abonelik Özet Kartı (Dashboard için)
class SubscriptionSummaryCard extends StatefulWidget {
  final VoidCallback? onTap;

  const SubscriptionSummaryCard({super.key, this.onTap});

  @override
  State<SubscriptionSummaryCard> createState() =>
      _SubscriptionSummaryCardState();
}

class _SubscriptionSummaryCardState extends State<SubscriptionSummaryCard> {
  SubscriptionStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await subscriptionManager.getStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[SubscriptionSummaryCard] Error loading stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading || _stats == null || _stats!.totalCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stats!.statusColor.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: context.appColors.surface.withValues(alpha: 0.8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap?.call();
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _stats!.statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _stats!.statusIcon,
                          color: _stats!.statusColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.subscriptions,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _stats!.statusColor,
                              ),
                            ),
                            Text(
                              _stats!.statusText,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        l10n.amountPerMonth(
                          _stats!.totalMonthlyCost.toStringAsFixed(0),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 14,
                        color: context.appColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
