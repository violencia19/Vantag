import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/expense.dart';
import '../providers/currency_provider.dart';
import '../services/budget_service.dart';
import '../theme/theme.dart' hide GlassCard;
import '../core/theme/premium_effects.dart';
import '../utils/currency_utils.dart';

/// Aktif taksitleri gösteren kart
/// Premium animasyonlar: slide-up, count-up, progress bar
class InstallmentSummaryCard extends StatefulWidget {
  final BudgetService budgetService;
  final int animationIndex;
  final VoidCallback? onSeeAll;

  const InstallmentSummaryCard({
    super.key,
    required this.budgetService,
    this.animationIndex = 0,
    this.onSeeAll,
  });

  @override
  State<InstallmentSummaryCard> createState() => _InstallmentSummaryCardState();
}

class _InstallmentSummaryCardState extends State<InstallmentSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Staggered delay based on index
    Future.delayed(Duration(milliseconds: 100 * widget.animationIndex), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAllInstallmentsSheet(
    BuildContext context,
    List<Expense> installments,
    CurrencyProvider currencyProvider,
  ) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => _AllInstallmentsSheet(
        installments: installments,
        currencyProvider: currencyProvider,
        l10n: l10n,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();
    final installments = widget.budgetService.activeInstallments;

    // Taksit yoksa gösterme
    if (installments.isEmpty) return const SizedBox.shrink();

    final monthlyBurden = widget.budgetService.monthlyInstallmentBurden;
    final totalDebt = widget.budgetService.totalRemainingDebt;
    final totalInterest = widget.budgetService.totalInterestAmount;
    final interestHours = widget.budgetService.totalInterestHours;

    // Currency conversion
    final monthlyBurdenConverted = currencyProvider.convertFromTRY(
      monthlyBurden,
    );
    final totalDebtConverted = currencyProvider.convertFromTRY(totalDebt);
    final totalInterestConverted = currencyProvider.convertFromTRY(
      totalInterest,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              boxShadow: PremiumShadows.coloredGlow(
                Colors.orange,
                intensity: 0.2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: PremiumShadows.coloredGlow(
                                Colors.orange,
                                intensity: 0.3,
                              ),
                            ),
                            child: Icon(
                              PhosphorIconsDuotone.creditCard,
                              color: Colors.orange.shade300,
                              size: 18,
                              shadows: PremiumShadows.iconHalo(Colors.orange),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.activeInstallments,
                            style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          l10n.installmentCount(installments.length),
                          style: TextStyle(
                            color: Colors.orange.shade300,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Taksit listesi (max 3 göster) with staggered animation
                  ...installments
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => _AnimatedInstallmentRow(
                          index: entry.key,
                          expense: entry.value,
                          currencyProvider: currencyProvider,
                          l10n: l10n,
                        ),
                      ),

                  // Daha fazla varsa - "Tümünü Gör" butonu
                  if (installments.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: widget.onSeeAll ?? () => _showAllInstallmentsSheet(context, installments, currencyProvider),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.moreInstallments(installments.length - 3),
                              style: TextStyle(
                                color: context.appColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.viewAll,
                                    style: TextStyle(
                                      color: Colors.orange.shade300,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    PhosphorIconsBold.caretRight,
                                    color: Colors.orange.shade300,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    height: 24,
                  ),

                  // Özet with count-up animations
                  Row(
                    children: [
                      Expanded(
                        child: _AnimatedSummaryItem(
                          index: 0,
                          label: l10n.monthlyBurden,
                          value: monthlyBurdenConverted,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AnimatedSummaryItem(
                          index: 1,
                          label: l10n.remainingDebt,
                          value: totalDebtConverted,
                          color: context.appColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // Vade farkı uyarısı
                  if (totalInterest > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.appColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.appColors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIconsDuotone.trendUp,
                            color: context.appColors.error,
                            size: 16,
                            shadows: PremiumShadows.iconHalo(
                              context.appColors.error,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.totalInterestCost(
                                formatTurkishCurrency(
                                  totalInterestConverted,
                                  decimalDigits: 0,
                                  showDecimals: false,
                                ),
                                interestHours.toStringAsFixed(0),
                              ),
                              style: TextStyle(
                                color: context.appColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated installment row with progress bar
class _AnimatedInstallmentRow extends StatefulWidget {
  final int index;
  final Expense expense;
  final CurrencyProvider currencyProvider;
  final AppLocalizations l10n;

  const _AnimatedInstallmentRow({
    required this.index,
    required this.expense,
    required this.currencyProvider,
    required this.l10n,
  });

  @override
  State<_AnimatedInstallmentRow> createState() =>
      _AnimatedInstallmentRowState();
}

class _AnimatedInstallmentRowState extends State<_AnimatedInstallmentRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );

    // Staggered delay: 200ms base + 100ms per index
    Future.delayed(Duration(milliseconds: 200 + (100 * widget.index)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentInstallment = widget.expense.currentInstallment ?? 1;
    final totalInstallments = widget.expense.installmentCount ?? 1;
    final progress = currentInstallment / totalInstallments;
    final installmentAmount = widget.currencyProvider.convertFromTRY(
      widget.expense.installmentAmount,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animatedProgress = progress * _progressAnimation.value;

        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.expense.subCategory?.isNotEmpty == true
                              ? '${widget.expense.category} - ${widget.expense.subCategory}'
                              : widget.expense.category,
                          style: TextStyle(
                            color: context.appColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${formatTurkishCurrency(installmentAmount, decimalDigits: 0, showDecimals: false)}/${widget.l10n.monthAbbreviation}',
                        style: TextStyle(
                          color: Colors.orange.shade300,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: animatedProgress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: progress > 0.8
                                      ? [
                                          context.appColors.success,
                                          context.appColors.success.withValues(
                                            alpha: 0.8,
                                          ),
                                        ]
                                      : [Colors.orange, Colors.orange.shade600],
                                ),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (progress > 0.8
                                                ? context.appColors.success
                                                : Colors.orange)
                                            .withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$currentInstallment/$totalInstallments',
                        style: TextStyle(
                          color: context.appColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated summary item with count-up
class _AnimatedSummaryItem extends StatefulWidget {
  final int index;
  final String label;
  final double value;
  final Color color;

  const _AnimatedSummaryItem({
    required this.index,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  State<_AnimatedSummaryItem> createState() => _AnimatedSummaryItemState();
}

class _AnimatedSummaryItemState extends State<_AnimatedSummaryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Staggered delay: 400ms base + 100ms per index
    Future.delayed(Duration(milliseconds: 400 + (100 * widget.index)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedCountUp(
                    value: widget.value,
                    duration: const Duration(milliseconds: 800),
                    formatter: (value) => formatTurkishCurrency(
                      value,
                      decimalDigits: 0,
                      showDecimals: false,
                    ),
                    style: TextStyle(
                      color: widget.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: widget.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bottom sheet showing all installments
class _AllInstallmentsSheet extends StatelessWidget {
  final List<Expense> installments;
  final CurrencyProvider currencyProvider;
  final AppLocalizations l10n;

  const _AllInstallmentsSheet({
    required this.installments,
    required this.currencyProvider,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.appColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            PhosphorIconsDuotone.creditCard,
                            color: Colors.orange.shade300,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.activeInstallments,
                          style: TextStyle(
                            color: context.appColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.installmentCount(installments.length),
                        style: TextStyle(
                          color: Colors.orange.shade300,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.white.withValues(alpha: 0.1)),

              // Installments list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: installments.length,
                  itemBuilder: (context, index) {
                    final expense = installments[index];
                    return _InstallmentListItem(
                      expense: expense,
                      currencyProvider: currencyProvider,
                      l10n: l10n,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Single installment item in the full list
class _InstallmentListItem extends StatelessWidget {
  final Expense expense;
  final CurrencyProvider currencyProvider;
  final AppLocalizations l10n;

  const _InstallmentListItem({
    required this.expense,
    required this.currencyProvider,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final currentInstallment = expense.currentInstallment ?? 1;
    final totalInstallments = expense.installmentCount ?? 1;
    final progress = currentInstallment / totalInstallments;
    final installmentAmount = currencyProvider.convertFromTRY(
      expense.installmentAmount,
    );
    final totalAmount = currencyProvider.convertFromTRY(expense.amount);
    final remainingAmount = installmentAmount * (totalInstallments - currentInstallment + 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  expense.subCategory?.isNotEmpty == true
                      ? '${expense.category} - ${expense.subCategory}'
                      : expense.category,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${formatTurkishCurrency(installmentAmount, decimalDigits: 0, showDecimals: false)}/${l10n.monthAbbreviation}',
                style: TextStyle(
                  color: Colors.orange.shade300,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: progress > 0.8
                        ? [context.appColors.success, context.appColors.success.withValues(alpha: 0.8)]
                        : [Colors.orange, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Progress text
              Text(
                '$currentInstallment / $totalInstallments ${l10n.installmentsLabel}',
                style: TextStyle(
                  color: context.appColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              // Remaining
              Text(
                '${l10n.remaining}: ${formatTurkishCurrency(remainingAmount, decimalDigits: 0, showDecimals: false)}',
                style: TextStyle(
                  color: context.appColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Total amount
          if (expense.amount != installmentAmount) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.total}: ${formatTurkishCurrency(totalAmount, decimalDigits: 0, showDecimals: false)}',
              style: TextStyle(
                color: context.appColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
