import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/currency_provider.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Subscription management screen
/// Allows switching between list and calendar views
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _subscriptionService = SubscriptionService();
  final _subscriptionManager = SubscriptionManager();

  List<Subscription> _subscriptions = [];
  SubscriptionStats? _stats;
  bool _isLoading = true;
  bool _isCalendarView = false; // false = list, true = calendar

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final subs = await _subscriptionService.getActiveSubscriptions();
      final stats = await _subscriptionManager.getStats();

      if (mounted) {
        setState(() {
          _subscriptions = subs
            ..sort((a, b) => a.renewalDay.compareTo(b.renewalDay));
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[SubscriptionScreen] Error loading subscriptions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoadingSubscriptions),
            backgroundColor: context.vantColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleView() {
    HapticFeedback.selectionClick();
    setState(() => _isCalendarView = !_isCalendarView);
  }

  void _showAddSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSubscriptionSheet(
        onAdd: (subscription) async {
          await _subscriptionService.addSubscription(subscription);
          _subscriptionManager.clearCache();
          _loadData();
        },
      ),
    );
  }

  void _showDetailSheet(Subscription subscription) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubscriptionDetailSheet(
        subscription: subscription,
        onUpdate: (updated) async {
          await _subscriptionService.updateSubscription(
            subscription.id,
            updated,
          );
          _subscriptionManager.clearCache();
          _loadData();
        },
        onDelete: () async {
          await _subscriptionService.deleteSubscription(subscription.id);
          _subscriptionManager.clearCache();
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.vantColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: context.vantColors.background,
            pinned: true,
            expandedHeight: 0,
            leading: IconButton(
              icon: Icon(CupertinoIcons.arrow_left),
              onPressed: () => Navigator.pop(context),
              tooltip: AppLocalizations.of(context).accessibilityBackButton,
            ),
            title: Text(
              AppLocalizations.of(context).subscriptions,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            actions: [
              // View toggle
              IconButton(
                icon: Icon(
                  _isCalendarView
                      ? CupertinoIcons.list_bullet
                      : CupertinoIcons.calendar,
                ),
                onPressed: _toggleView,
                tooltip: _isCalendarView
                    ? AppLocalizations.of(context).listView
                    : AppLocalizations.of(context).calendarView,
              ),
            ],
          ),

          // Stats card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _buildStatsCard(),
            ),
          ),

          // Content
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: context.vantColors.primary,
                ),
              ),
            )
          else if (_subscriptions.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else if (_isCalendarView)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SubscriptionCalendarView(
                  subscriptions: _subscriptions,
                  onDayTap: _showDaySubscriptions,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == _subscriptions.length) {
                    return const SizedBox(height: 100); // Space for FAB
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSubscriptionCard(_subscriptions[index]),
                  );
                }, childCount: _subscriptions.length + 1),
              ),
            ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: context.vantColors.primary,
        tooltip: AppLocalizations.of(context).addSubscription,
        child: Icon(
          CupertinoIcons.add,
          color: context.vantColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.vantColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.vantColors.textPrimary.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              // Monthly total
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).monthlyTotal,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.read<CurrencyProvider>().format(_stats!.totalMonthlyCost),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 50,
                color: context.vantColors.textPrimary.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 20),
              // Subscription count and work days
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _stats!.statusIcon,
                          size: 14,
                          color: _stats!.statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_stats!.totalCount} ${AppLocalizations.of(context).subscription}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.vantColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_stats!.totalWorkDays.toStringAsFixed(1)} ${AppLocalizations.of(context).workDaysPerMonth}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(Subscription subscription) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.accessibilitySubscriptionCard(
        subscription.name,
        formatTurkishCurrency(subscription.amount, decimalDigits: 0),
        l10n.monthly,
        subscription.renewalDay,
      ),
      child: GestureDetector(
        onTap: () => _showDetailSheet(subscription),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.vantColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: subscription.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Color dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: subscription.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: subscription.color.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Name and category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subscription.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vantColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount and renewal day
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.read<CurrencyProvider>().format(subscription.amount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.vantColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).everyMonthDay(subscription.renewalDay),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.vantColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Arrow
              Icon(
                CupertinoIcons.chevron_right,
                size: 20,
                color: context.vantColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.vantColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              CupertinoIcons.repeat,
              size: 40,
              color: context.vantColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).noSubscriptionsYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.vantColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).addSubscriptionHint,
            style: TextStyle(
              fontSize: 13,
              color: context.vantColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDaySubscriptions(int day, List<Subscription> subs) {
    if (subs.isEmpty) return;

    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.vantColors.gradientMid,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: context.vantColors.textPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).everyMonthDay(day),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.vantColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...subs.map(
                    (sub) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Semantics(
                        button: true,
                        label: AppLocalizations.of(context)
                            .accessibilitySubscriptionCard(
                              sub.name,
                              formatTurkishCurrency(
                                sub.amount,
                                decimalDigits: 0,
                              ),
                              AppLocalizations.of(context).monthly,
                              sub.renewalDay,
                            ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showDetailSheet(sub);
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: sub.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  sub.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.vantColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                context.read<CurrencyProvider>().format(sub.amount),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.vantColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
