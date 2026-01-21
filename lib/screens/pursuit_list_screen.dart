import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/quiet_luxury.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Main screen for managing pursuits (savings goals)
/// Replaces the Achievements tab (tab index 2)
class PursuitListScreen extends StatefulWidget {
  const PursuitListScreen({super.key});

  @override
  State<PursuitListScreen> createState() => _PursuitListScreenState();
}

class _PursuitListScreenState extends State<PursuitListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _showCompleted = _tabController.index == 1;
      });
    });

    // Initialize pursuits if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PursuitProvider>();
      if (!provider.isInitialized) {
        provider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pursuitProvider = context.watch<PursuitProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    final pursuits = _showCompleted
        ? pursuitProvider.completedPursuits
        : pursuitProvider.activePursuits;

    return Scaffold(
      backgroundColor: QuietLuxury.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: QuietLuxury.background,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            floating: false,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                l10n.myPursuits,
                style: QuietLuxury.heading.copyWith(fontSize: 20),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      QuietLuxury.background.withValues(alpha: 0.0),
                      QuietLuxury.background,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: QuietLuxury.positive,
                indicatorWeight: 2,
                labelColor: QuietLuxury.positive,
                unselectedLabelColor: QuietLuxury.textTertiary,
                labelStyle: QuietLuxury.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: QuietLuxury.body,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIconsRegular.target, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.activePursuits),
                        if (pursuitProvider.activePursuitCount > 0) ...[
                          const SizedBox(width: 6),
                          _CountBadge(count: pursuitProvider.activePursuitCount),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIconsRegular.check, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.completedPursuits),
                        if (pursuitProvider.completedPursuitCount > 0) ...[
                          const SizedBox(width: 6),
                          _CountBadge(
                            count: pursuitProvider.completedPursuitCount,
                            color: QuietLuxury.gold,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Savings Pool Card - only show on active tab
          if (!_showCompleted)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SavingsPoolCard(compact: true),
              ),
            ),

          // Content
          if (pursuitProvider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(QuietLuxury.positive),
                ),
              ),
            )
          else if (pursuits.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(l10n),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final pursuit = pursuits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: Key(pursuit.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _confirmDelete(pursuit),
                        background: _buildDismissBackground(),
                        child: PursuitCard(
                          pursuit: pursuit,
                          formatAmount: (amount) => _formatAmount(
                            amount,
                            currencyProvider.currency.symbol,
                          ),
                          onTap: () => _showPursuitDetail(pursuit),
                          onAddSavings:
                              pursuit.isCompleted ? null : () => _addSavings(pursuit),
                        ),
                      ),
                    );
                  },
                  childCount: pursuits.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _showCompleted
          ? null
          : FloatingActionButton(
              onPressed: _createPursuit,
              backgroundColor: QuietLuxury.positive,
              foregroundColor: Colors.white,
              child: Icon(PhosphorIconsBold.plus),
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QuietLuxury.cardBackground,
                border: Border.all(
                  color: QuietLuxury.cardBorder,
                  width: 0.5,
                ),
              ),
              child: Icon(
                _showCompleted
                    ? PhosphorIconsDuotone.trophy
                    : PhosphorIconsDuotone.star,
                size: 64,
                color: QuietLuxury.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _showCompleted
                  ? l10n.completedPursuits
                  : l10n.emptyPursuitsTitle,
              style: QuietLuxury.heading.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _showCompleted
                  ? l10n.noTransactions
                  : l10n.emptyPursuitsMessage,
              style: QuietLuxury.body,
              textAlign: TextAlign.center,
            ),
            if (!_showCompleted) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _createPursuit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuietLuxury.positive,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(PhosphorIconsBold.plus, size: 18),
                label: Text(l10n.addFirstPursuit),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: QuietLuxury.negative.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        PhosphorIconsBold.trash,
        color: QuietLuxury.negative,
      ),
    );
  }

  String _formatAmount(double amount, String symbol) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  Future<void> _createPursuit() async {
    HapticFeedback.selectionClick();
    final result = await showCreatePursuitSheet(context);
    if (result == true && mounted) {
      // Refresh
    }
  }

  Future<void> _addSavings(Pursuit pursuit) async {
    HapticFeedback.selectionClick();
    final reachedTarget = await showAddSavingsSheet(
      context,
      pursuit: pursuit,
    );

    if (reachedTarget == true && mounted) {
      // Show completion modal
      final updatedPursuit =
          context.read<PursuitProvider>().getPursuitById(pursuit.id);
      if (updatedPursuit != null) {
        await context.read<PursuitProvider>().completePursuit(pursuit.id);
        if (mounted) {
          await showPursuitCompletionModal(
            context,
            pursuit: updatedPursuit,
            formatAmount: (amount) => _formatAmount(
              amount,
              context.read<CurrencyProvider>().currency.symbol,
            ),
          );
        }
      }
    }
  }

  void _showPursuitDetail(Pursuit pursuit) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PursuitDetailSheet(
        pursuit: pursuit,
        formatAmount: (amount) => _formatAmount(
          amount,
          context.read<CurrencyProvider>().currency.symbol,
        ),
        onEdit: () async {
          Navigator.of(context).pop();
          await showCreatePursuitSheet(context, pursuit: pursuit);
        },
        onDelete: () async {
          Navigator.of(context).pop();
          final confirmed = await _confirmDelete(pursuit);
          if (confirmed == true) {
            await context.read<PursuitProvider>().deletePursuit(pursuit.id);
          }
        },
        onAddSavings: pursuit.isCompleted
            ? null
            : () async {
                Navigator.of(context).pop();
                await _addSavings(pursuit);
              },
      ),
    );
  }

  Future<bool?> _confirmDelete(Pursuit pursuit) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: QuietLuxury.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.deletePursuit,
          style: QuietLuxury.heading,
        ),
        content: Text(
          l10n.deletePursuitConfirm,
          style: QuietLuxury.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: QuietLuxury.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: QuietLuxury.negative),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const _CountBadge({
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? QuietLuxury.positive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: QuietLuxury.label.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: QuietLuxury.background,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class _PursuitDetailSheet extends StatelessWidget {
  final Pursuit pursuit;
  final String Function(double amount) formatAmount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddSavings;

  const _PursuitDetailSheet({
    required this.pursuit,
    required this.formatAmount,
    this.onEdit,
    this.onDelete,
    this.onAddSavings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: QuietLuxury.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: QuietLuxury.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Progress visual
              PursuitProgressVisual(
                progress: pursuit.progressPercent,
                emoji: pursuit.emoji,
                imageUrl: pursuit.imageUrl,
                size: 80,
                fillColor:
                    pursuit.isCompleted ? QuietLuxury.gold : QuietLuxury.positive,
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                pursuit.name,
                style: QuietLuxury.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Progress text
              Text(
                '${formatAmount(pursuit.savedAmount)} / ${formatAmount(pursuit.targetAmount)}',
                style: QuietLuxury.subheading,
              ),
              const SizedBox(height: 4),

              // Progress percentage
              Text(
                l10n.pursuitProgress(pursuit.progressPercentDisplay),
                style: QuietLuxury.label.copyWith(
                  color: pursuit.isCompleted
                      ? QuietLuxury.gold
                      : QuietLuxury.positive,
                ),
              ),
              const SizedBox(height: 24),

              // Progress bar
              PursuitLinearProgress(
                progress: pursuit.progressPercent,
                height: 8,
                progressColor:
                    pursuit.isCompleted ? QuietLuxury.gold : QuietLuxury.positive,
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  if (onAddSavings != null) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAddSavings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: QuietLuxury.positive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(PhosphorIconsBold.plus, size: 18),
                        label: Text(l10n.addSavings),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Edit button
                  IconButton(
                    onPressed: onEdit,
                    style: IconButton.styleFrom(
                      backgroundColor: QuietLuxury.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: QuietLuxury.cardBorder),
                      ),
                    ),
                    icon: Icon(
                      PhosphorIconsRegular.pencilSimple,
                      color: QuietLuxury.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  IconButton(
                    onPressed: onDelete,
                    style: IconButton.styleFrom(
                      backgroundColor: QuietLuxury.negative.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: QuietLuxury.negative.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    icon: Icon(
                      PhosphorIconsRegular.trash,
                      color: QuietLuxury.negative,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
