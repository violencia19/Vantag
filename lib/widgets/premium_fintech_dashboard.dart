import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../theme/theme.dart';
import '../utils/currency_utils.dart';
import 'package:vantag/l10n/app_localizations.dart';

/// Premium Fintech Dashboard Components
/// Beyond, Revolut, N26 dark mode style

/// Premium Balance Card - Kredi kartı görünümünde, neon glow efektli
class PremiumBalanceCard extends StatefulWidget {
  final double netBalance;
  final double totalIncome;
  final double totalSpent;
  final double savedAmount;
  final int savedCount;
  final int incomeSourceCount;
  final VoidCallback? onTap;

  const PremiumBalanceCard({
    super.key,
    required this.netBalance,
    required this.totalIncome,
    required this.totalSpent,
    this.savedAmount = 0,
    this.savedCount = 0,
    this.incomeSourceCount = 1,
    this.onTap,
  });

  @override
  State<PremiumBalanceCard> createState() => _PremiumBalanceCardState();
}

class _PremiumBalanceCardState extends State<PremiumBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<double> _countAnimation;
  double _displayedBalance = 0;
  double _displayedIncome = 0;
  double _displayedSpent = 0;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );

    _countController.addListener(() {
      setState(() {
        _displayedBalance = widget.netBalance * _countAnimation.value;
        _displayedIncome = widget.totalIncome * _countAnimation.value;
        _displayedSpent = widget.totalSpent * _countAnimation.value;
      });
    });

    _countController.forward();
  }

  @override
  void didUpdateWidget(PremiumBalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.netBalance != widget.netBalance ||
        oldWidget.totalIncome != widget.totalIncome ||
        oldWidget.totalSpent != widget.totalSpent) {
      _countController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  double get spentPercent =>
      widget.totalIncome > 0 ? (widget.totalSpent / widget.totalIncome).clamp(0, 1) : 0;

  bool get isHealthy => widget.netBalance >= 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.appColors.surfaceLight,
              context.appColors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: context.appColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: context.appColors.primary.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısım: Net Bakiye label + sources badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.netBalance,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: context.appColors.textSecondary,
                  ),
                ),
                // Sources badge
                if (widget.incomeSourceCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.appColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          PhosphorIconsDuotone.wallet,
                          size: 14,
                          color: context.appColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.incomeSources(widget.incomeSourceCount),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: context.appColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // BÜYÜK RAKAM - Counting animation ile
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTurkishCurrency(_displayedBalance, decimalDigits: 0, showDecimals: false),
                  style: GoogleFonts.inter(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: isHealthy ? Colors.white : context.appColors.error,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                  child: Text(
                    currencyProvider.symbol,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1F1D2B),
                borderRadius: BorderRadius.circular(2),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        width: constraints.maxWidth * spentPercent,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryButton,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Budget text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.budgetUsage,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                    color: context.appColors.textTertiary,
                  ),
                ),
                Text(
                  "${formatTurkishCurrency(_displayedSpent, decimalDigits: 0, showDecimals: false)} / ${formatTurkishCurrency(widget.totalIncome, decimalDigits: 0, showDecimals: false)}",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Income ve Expense kartları
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: PhosphorIconsDuotone.arrowDown,
                    label: l10n.income,
                    value: formatTurkishCurrency(_displayedIncome, decimalDigits: 0, showDecimals: false),
                    color: context.appColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: PhosphorIconsDuotone.arrowUp,
                    label: l10n.expense,
                    value: formatTurkishCurrency(_displayedSpent, decimalDigits: 0, showDecimals: false),
                    color: context.appColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat Card (Income/Expense)
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w500,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium Currency Band
class PremiumCurrencyBand extends StatelessWidget {
  final String? usdRate;
  final String? eurRate;
  final String? goldRate;
  final bool usdUp;
  final bool eurUp;
  final bool goldUp;

  const PremiumCurrencyBand({
    super.key,
    this.usdRate,
    this.eurRate,
    this.goldRate,
    this.usdUp = true,
    this.eurUp = false,
    this.goldUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _CurrencyItem(
            symbol: "USD",
            value: usdRate ?? "-",
            isUp: usdUp,
          ),
          _Divider(),
          _CurrencyItem(
            symbol: "EUR",
            value: eurRate ?? "-",
            isUp: eurUp,
          ),
          _Divider(),
          _CurrencyItem(
            symbol: "Altın",
            value: goldRate ?? "-",
            isUp: goldUp,
          ),
        ],
      ),
    );
  }
}

class _CurrencyItem extends StatelessWidget {
  final String symbol;
  final String value;
  final bool isUp;

  const _CurrencyItem({
    required this.symbol,
    required this.value,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          symbol,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: context.appColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              isUp ? "↑" : "↓",
              style: TextStyle(
                fontSize: 12,
                color: isUp ? context.appColors.success : context.appColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

/// Premium Section Title
class PremiumSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const PremiumSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Premium Transaction Item
class PremiumTransactionItem extends StatelessWidget {
  final String storeName;
  final String category;
  final double amount;
  final String time;
  final IconData categoryIcon;
  final Color categoryColor;
  final bool isExpense;
  final VoidCallback? onTap;

  const PremiumTransactionItem({
    super.key,
    required this.storeName,
    required this.category,
    required this.amount,
    required this.time,
    required this.categoryIcon,
    required this.categoryColor,
    this.isExpense = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Mağaza ikonu
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: PhosphorIcon(categoryIcon, size: 24, color: categoryColor),
            ),
            const SizedBox(width: 14),
            // İsim ve kategori
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Tutar ve saat
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isExpense ? '-' : '+'}${formatTurkishCurrency(amount, decimalDigits: 0, showDecimals: false)}",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isExpense ? context.appColors.error : context.appColors.success,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: context.appColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium Header with Profile Photo
class PremiumHeader extends StatelessWidget {
  final String greeting;
  final String title;
  final String? photoPath;
  final VoidCallback? onSettingsTap;
  final Widget? trailing;

  const PremiumHeader({
    super.key,
    required this.greeting,
    required this.title,
    this.photoPath,
    this.onSettingsTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Profil fotoğrafı
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.appColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: context.appColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: photoPath != null
                  ? Image.asset(photoPath!, fit: BoxFit.cover)
                  : Container(
                      color: context.appColors.surfaceLight,
                      child: PhosphorIcon(
                        PhosphorIconsDuotone.user,
                        size: 24,
                        color: context.appColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Selamlama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$greeting 👋",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Trailing widgets
          if (trailing != null) trailing!,
          // Ayarlar butonu
          if (onSettingsTap != null)
            _GlassButton(
              icon: PhosphorIconsDuotone.gear,
              onTap: onSettingsTap!,
            ),
        ],
      ),
    );
  }
}

/// Glass Button
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;

  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                PhosphorIcon(icon, size: 20, color: context.appColors.textSecondary),
                if (badge != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: context.appColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.appColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.primary,
                          ),
                        ),
                      ),
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

/// Premium Floating Bottom Navigation Bar
class PremiumFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onAddPressed;

  const PremiumFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Positioned(
      left: 20,
      right: 20,
      bottom: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: context.appColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: context.appColors.primary.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.appColors.primary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: PhosphorIconsDuotone.house,
                  label: l10n.dashboard,
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                ),
                _NavItem(
                  icon: PhosphorIconsDuotone.chartBar,
                  label: l10n.navReports,
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                ),
                // Ortadaki FAB
                GestureDetector(
                  onTap: onAddPressed,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryButton,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      PhosphorIconsDuotone.plus,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                _NavItem(
                  icon: PhosphorIconsDuotone.trophy,
                  label: l10n.navAchievements,
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                ),
                _NavItem(
                  icon: PhosphorIconsDuotone.user,
                  label: l10n.navProfile,
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              size: 24,
              color: isSelected ? context.appColors.primary : context.appColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? context.appColors.primary : context.appColors.textTertiary,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.primary.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
