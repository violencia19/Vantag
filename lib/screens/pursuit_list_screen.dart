import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/referral_service.dart';
import '../services/deep_link_service.dart';
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
      backgroundColor: context.appColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: context.appColors.background,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            floating: false,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                l10n.myPursuits,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.appColors.background.withValues(alpha: 0.0),
                      context.appColors.background,
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
                indicatorColor: context.appColors.success,
                indicatorWeight: 2,
                labelColor: context.appColors.success,
                unselectedLabelColor: context.appColors.textTertiary,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
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
                          _CountBadge(
                            count: pursuitProvider.activePursuitCount,
                          ),
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
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.appColors.success,
                  ),
                ),
              ),
            )
          else if (pursuits.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(l10n))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
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
                        onAddSavings: pursuit.isCompleted
                            ? null
                            : () => _addSavings(pursuit),
                      ),
                    ),
                  );
                }, childCount: pursuits.length),
              ),
            ),

          // "Add New Dream" card at bottom (only for active pursuits)
          if (!_showCompleted && pursuits.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverToBoxAdapter(
                child: _buildAddNewPursuitCard(l10n),
              ),
            ),
        ],
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
                color: context.appColors.surfaceLight,
                border: Border.all(
                  color: context.appColors.cardBorder,
                  width: 0.5,
                ),
              ),
              child: Icon(
                _showCompleted
                    ? PhosphorIconsDuotone.trophy
                    : PhosphorIconsDuotone.star,
                size: 64,
                color: context.appColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _showCompleted ? l10n.completedPursuits : l10n.emptyPursuitsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _showCompleted ? l10n.noTransactions : l10n.emptyPursuitsMessage,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!_showCompleted) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _createPursuit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.success,
                  foregroundColor: context.appColors.textPrimary,
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

  Widget _buildAddNewPursuitCard(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _createPursuit,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.appColors.success.withValues(alpha: 0.15),
              context.appColors.success.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.appColors.success.withValues(alpha: 0.3),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.appColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                PhosphorIconsDuotone.plus,
                color: context.appColors.success,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.createPursuit,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.emptyPursuitsMessage,
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
            Icon(
              PhosphorIconsDuotone.caretRight,
              color: context.appColors.success,
              size: 24,
            ),
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
        color: context.appColors.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(PhosphorIconsBold.trash, color: context.appColors.error),
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

    // Check pursuit limit for free users
    final proProvider = context.read<ProProvider>();
    final pursuitProvider = context.read<PursuitProvider>();
    final isPremium = proProvider.isPro;

    final canCreate = await pursuitProvider.canCreatePursuit(isPremium);
    if (!canCreate && mounted) {
      final l10n = AppLocalizations.of(context);
      UpgradeDialog.show(context, l10n.pursuitLimitReachedFree);
      return;
    }

    final result = await showCreatePursuitSheet(context);
    if (result == true && mounted) {
      // Refresh
    }
  }

  Future<void> _addSavings(Pursuit pursuit) async {
    HapticFeedback.selectionClick();
    final reachedTarget = await showAddSavingsSheet(context, pursuit: pursuit);

    if (reachedTarget == true && mounted) {
      // Show completion celebration
      final updatedPursuit = context.read<PursuitProvider>().getPursuitById(
        pursuit.id,
      );
      if (updatedPursuit != null) {
        await context.read<PursuitProvider>().completePursuit(pursuit.id);
        if (mounted) {
          showPursuitCelebration(
            context,
            updatedPursuit,
            onShare: () => _sharePursuitCompletion(updatedPursuit),
            onNewGoal: () => _openCreatePursuit(),
          );
        }
      }
    }
  }

  void _showPursuitDetail(Pursuit pursuit) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
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
    final colors = context.appColors;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deletePursuit,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          l10n.deletePursuitConfirm,
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete, style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }

  /// Share pursuit completion achievement
  Future<void> _sharePursuitCompletion(Pursuit pursuit) async {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.read<CurrencyProvider>();
    final symbol = currencyProvider.currency.symbol;

    // Get referral link for sharing
    String shareLink = 'vantag.app';
    try {
      final referralCode = await ReferralService().getOrCreateReferralCode();
      if (referralCode != null) {
        final referralLink = DeepLinkService.generateReferralLink(referralCode);
        shareLink = referralLink.toString();
      }
    } catch (e) {
      // Use default link if referral fails (graceful fallback)
      debugPrint('[PursuitListScreen] Referral link error, using default: $e');
    }

    final shareText =
        '🎉 ${l10n.pursuitCompleted}: ${pursuit.name}!\n'
        '💰 $symbol${pursuit.targetAmount.toStringAsFixed(0)} ${l10n.saved}\n\n'
        '${l10n.shareDefaultMessage(shareLink)}';

    await Share.share(shareText);
  }

  /// Open create pursuit sheet for new goal
  void _openCreatePursuit() {
    showCreatePursuitSheet(context);
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const _CountBadge({required this.count, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.appColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
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
    return Container(color: context.appColors.background, child: tabBar);
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
    final colors = context.appColors;
    final goldColor = AppColors.medalGold;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: colors.cardBorder,
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
                fillColor: pursuit.isCompleted ? goldColor : colors.success,
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                pursuit.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Progress text
              Text(
                '${formatAmount(pursuit.savedAmount)} / ${formatAmount(pursuit.targetAmount)}',
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
              ),
              const SizedBox(height: 4),

              // Progress percentage
              Text(
                l10n.pursuitProgress(pursuit.progressPercentDisplay),
                style: TextStyle(
                  fontSize: 12,
                  color: pursuit.isCompleted ? goldColor : colors.success,
                ),
              ),
              const SizedBox(height: 24),

              // Progress bar
              PursuitLinearProgress(
                progress: pursuit.progressPercent,
                height: 8,
                progressColor: pursuit.isCompleted ? goldColor : colors.success,
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
                          backgroundColor: colors.success,
                          foregroundColor: context.appColors.textPrimary,
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
                    tooltip: l10n.edit,
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colors.cardBorder),
                      ),
                    ),
                    icon: Icon(
                      PhosphorIconsRegular.pencilSimple,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  IconButton(
                    onPressed: onDelete,
                    tooltip: l10n.delete,
                    style: IconButton.styleFrom(
                      backgroundColor: colors.error.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: colors.error.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    icon: Icon(PhosphorIconsRegular.trash, color: colors.error),
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
