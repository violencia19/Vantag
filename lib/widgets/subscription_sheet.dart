import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/currency_provider.dart';
import '../services/services.dart';
import '../screens/subscription_screen.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';

class SubscriptionSheet extends StatefulWidget {
  final VoidCallback? onChanged;

  const SubscriptionSheet({super.key, this.onChanged});

  @override
  State<SubscriptionSheet> createState() => _SubscriptionSheetState();
}

class _SubscriptionSheetState extends State<SubscriptionSheet> {
  final _subscriptionService = SubscriptionService();
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;
  double _totalMonthly = 0;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    final subs = await _subscriptionService.getActiveSubscriptions();
    final total = await _subscriptionService.getTotalMonthlyAmount();
    if (mounted) {
      setState(() {
        _subscriptions = subs
          ..sort((a, b) => a.daysUntilRenewal.compareTo(b.daysUntilRenewal));
        _totalMonthly = total;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSubscription(String id) async {
    await _subscriptionService.deleteSubscription(id);
    await _loadSubscriptions();
    widget.onChanged?.call();
  }

  void _showAddEditDialog({Subscription? existing}) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      isScrollControlled: true,
      backgroundColor: context.vantColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddEditSubscriptionSheet(
        existing: existing,
        onSaved: () {
          _loadSubscriptions();
          widget.onChanged?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: VantBlur.heavy, sigmaY: VantBlur.heavy),
          child: Container(
            decoration: BoxDecoration(
              color: VantColors.surface.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: const Color(0x15FFFFFF),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VantColors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.vantColors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.vantColors.cardBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.calendar,
                      color: context.vantColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.subscriptions, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: Color(0xFFFAFAFA))),
                        const SizedBox(height: 2),
                        Text(
                          l10n.monthlyTotalAmount(
                            formatTurkishCurrency(
                              _totalMonthly,
                              decimalDigits: 2,
                            ),
                          ),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF71717A)),
                        ),
                      ],
                    ),
                  ),
                  // Add button
                  VPressable(
                    onTap: () => _showAddEditDialog(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.vantColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.vantColors.success.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.plus,
                        color: context.vantColors.success,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Abonelik Yönetimi Butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _SubscriptionManageButton(
                onTap: () {
                  Navigator.pop(context); // Sheet'i kapat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionScreen(),
                    ),
                  );
                },
              ),
            ),

            // Subtle space instead of divider
            const SizedBox(height: 8),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: context.vantColors.textSecondary,
                        strokeWidth: 2,
                      ),
                    )
                  : _subscriptions.isEmpty
                  ? _buildEmptyState(l10n)
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _subscriptions.length,
                      itemBuilder: (context, index) {
                        final sub = _subscriptions[index];
                        return _SubscriptionCard(
                          subscription: sub,
                          onEdit: () => _showAddEditDialog(existing: sub),
                          onDelete: () => _deleteSubscription(sub.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.vantColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.vantColors.cardBorder, width: 0.5),
            ),
            child: Icon(
              CupertinoIcons.repeat,
              size: 26,
              color: context.vantColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noSubscriptionsYet,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: context.vantColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(l10n.addSubscriptionsLikeNetflix, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: context.vantColors.textSecondary)),
          const SizedBox(height: 24),
          VPressable(
            onTap: () => _showAddEditDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: context.vantColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.vantColors.success.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.plus,
                    size: 18,
                    color: context.vantColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.addSubscription,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.vantColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubscriptionCard({
    required this.subscription,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatNextRenewal(AppLocalizations l10n) {
    final days = subscription.daysUntilRenewal;
    if (days == 0) return l10n.today;
    if (days == 1) return l10n.tomorrow;
    if (days < 7) return l10n.daysLater(days);
    return '${subscription.nextRenewalDate.day}/${subscription.nextRenewalDate.month}';
  }

  Color _getRenewalColor(BuildContext context) {
    final days = subscription.daysUntilRenewal;
    if (days <= 1) return context.vantColors.warning;
    if (days <= 3) {
      return VantColors.categoryEntertainment.withValues(
        alpha: 0.7,
      ); // Subtle blue
    }
    return context.vantColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dismissible(
      key: Key(subscription.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        _showOptionsMenu(context, l10n);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: context.vantColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(CupertinoIcons.trash, color: context.vantColors.error),
      ),
      child: VPressable(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: VGlassStyledContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            child: Row(
            children: [
              // Icon - Gradient background
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.vantColors.textSecondary.withValues(alpha: 0.15),
                      context.vantColors.textSecondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.vantColors.cardBorder, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    _getEmoji(subscription.name),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.vantColors.textPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.vantColors.textTertiary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subscription.category,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: context.vantColors.textTertiary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          CupertinoIcons.clock,
                          size: 11,
                          color: _getRenewalColor(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatNextRenewal(l10n),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getRenewalColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.read<CurrencyProvider>().formatWithDecimals(subscription.amount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      color: context.vantColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(l10n.perMonth, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: context.vantColors.textTertiary)),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  String _getEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('netflix')) return '🎬';
    if (lower.contains('spotify')) return '🎵';
    if (lower.contains('youtube')) return '▶️';
    if (lower.contains('amazon')) return '📦';
    if (lower.contains('disney')) return '🏰';
    if (lower.contains('apple')) return '🍎';
    if (lower.contains('gym') || lower.contains('spor')) return '💪';
    if (lower.contains('game') || lower.contains('oyun')) return '🎮';
    if (lower.contains('cloud') || lower.contains('drive')) return '☁️';
    if (lower.contains('music') || lower.contains('müzik')) return '🎵';
    if (lower.contains('news') || lower.contains('haber')) return '📰';
    return '📅';
  }

  void _showOptionsMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.vantColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.vantColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuTile(
                context: context,
                icon: CupertinoIcons.pencil,
                label: l10n.edit,
                color: VantColors.categoryEntertainment.withValues(
                  alpha: 0.7,
                ), // Subtle blue
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                context: context,
                icon: CupertinoIcons.trash,
                label: l10n.delete,
                color: context.vantColors.error,
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return VPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color.withValues(alpha: 0.8), size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEditSubscriptionSheet extends StatefulWidget {
  final Subscription? existing;
  final VoidCallback onSaved;

  const _AddEditSubscriptionSheet({this.existing, required this.onSaved});

  @override
  State<_AddEditSubscriptionSheet> createState() =>
      _AddEditSubscriptionSheetState();
}

class _AddEditSubscriptionSheetState extends State<_AddEditSubscriptionSheet> {
  final _subscriptionService = SubscriptionService();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  int _renewalDay = 1;
  String _category = ExpenseCategory.all.first;
  bool _isActive = true;
  bool _autoRecord = false;
  bool _isSaving = false;

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _amountController.text = formatTurkishCurrency(
        widget.existing!.amount,
        decimalDigits: 2,
      );
      _renewalDay = widget.existing!.renewalDay;
      _category = widget.existing!.category;
      _isActive = widget.existing!.isActive;
      _autoRecord = widget.existing!.autoRecord;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (name.isEmpty) {
      _showError(l10n.enterSubscriptionName);
      return;
    }

    if (amount == null || amount <= 0) {
      _showError(l10n.enterValidAmount);
      return;
    }

    setState(() => _isSaving = true);

    final subscription = Subscription(
      id: widget.existing?.id ?? _subscriptionService.generateId(),
      name: name,
      amount: amount,
      renewalDay: _renewalDay,
      category: _category,
      isActive: _isActive,
      autoRecord: _autoRecord,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (_isEditMode) {
      await _subscriptionService.updateSubscription(
        widget.existing!.id,
        subscription,
      );
    } else {
      await _subscriptionService.addSubscription(subscription);
    }

    if (!mounted) return;

    widget.onSaved();
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.vantColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.vantColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _isEditMode ? l10n.editSubscription : l10n.newSubscription,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.vantColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Name
            Text(
              l10n.subscriptionName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.vantColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.subscriptionNameHint,
                filled: true,
                fillColor: context.vantColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: context.vantColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // Amount and Day
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.monthlyAmount,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.vantColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          suffixText: currencyProvider.code,
                          filled: true,
                          fillColor: context.vantColors.surfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: context.vantColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.renewalDay,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.vantColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: context.vantColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _renewalDay,
                            isExpanded: true,
                            dropdownColor: context.vantColors.surface,
                            items: List.generate(31, (i) => i + 1)
                                .map(
                                  (day) => DropdownMenuItem(
                                    value: day,
                                    child: Text(
                                      l10n.dayOfMonth(day),
                                      style: TextStyle(
                                        color: context.vantColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _renewalDay = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category
            Text(
              l10n.category,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.vantColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.vantColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  dropdownColor: context.vantColors.surface,
                  items: ExpenseCategory.all
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(
                            ExpenseCategory.getLocalizedName(cat, l10n),
                            style: TextStyle(
                              color: context.vantColors.textPrimary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Toggles
            _buildToggle(
              title: l10n.active,
              subtitle: l10n.passivesNotIncluded,
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            const SizedBox(height: 12),
            _buildToggle(
              title: l10n.autoRecord,
              subtitle: l10n.autoRecordDescription,
              value: _autoRecord,
              onChanged: (val) => setState(() => _autoRecord = val),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.vantColors.primary,
                  foregroundColor: context.vantColors.background,
                  disabledBackgroundColor: context.vantColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.vantColors.background,
                          ),
                        ),
                      )
                    : Text(
                        _isEditMode ? l10n.update : l10n.add,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.vantColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.vantColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.vantColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: context.vantColors.primary,
            activeThumbColor: context.vantColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

/// Abonelik Yönetimi Butonu
/// Tüm abonelikleri yönetmek için ana ekrana yönlendirir
class _SubscriptionManageButton extends StatefulWidget {
  final VoidCallback onTap;

  const _SubscriptionManageButton({required this.onTap});

  @override
  State<_SubscriptionManageButton> createState() =>
      _SubscriptionManageButtonState();
}

class _SubscriptionManageButtonState extends State<_SubscriptionManageButton> {
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
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[SubscriptionManageButton] Error loading stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accentColor = _stats?.statusColor ?? context.vantColors.textSecondary;

    return VPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: VGlassStyledContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 16,
        glowColor: accentColor,
        glowIntensity: 0.1,
        child: Row(
          children: [
            // Icon
            Icon(CupertinoIcons.calendar, size: 20, color: accentColor),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.calendarView,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: accentColor,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isLoading
                        ? l10n.loading
                        : _stats != null && _stats!.totalCount > 0
                        ? l10n.subscriptionCount(
                            _stats!.totalCount,
                            _stats!.totalMonthlyCost.toStringAsFixed(0),
                          )
                        : l10n.viewSubscriptionsInCalendar,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: context.vantColors.textTertiary),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              CupertinoIcons.chevron_right,
              size: 12,
              color: accentColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
