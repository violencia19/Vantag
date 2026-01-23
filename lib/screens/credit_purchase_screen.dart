import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../services/purchase_service.dart';

/// Credit pack definitions
enum CreditPack {
  small(id: 'credit_pack_50', credits: 50, price: 29.99),
  medium(id: 'credit_pack_150', credits: 150, price: 69.99),
  large(id: 'credit_pack_500', credits: 500, price: 149.99);

  final String id;
  final int credits;
  final double price;

  const CreditPack({
    required this.id,
    required this.credits,
    required this.price,
  });

  /// Price per credit for comparison
  double get pricePerCredit => price / credits;
}

/// Credit Purchase Screen for Lifetime users
class CreditPurchaseScreen extends StatefulWidget {
  const CreditPurchaseScreen({super.key});

  @override
  State<CreditPurchaseScreen> createState() => _CreditPurchaseScreenState();
}

class _CreditPurchaseScreenState extends State<CreditPurchaseScreen> {
  bool _isPurchasing = false;
  String? _purchasingPackId;
  int _currentCredits = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentCredits();
  }

  Future<void> _loadCurrentCredits() async {
    final credits = await PurchaseService().getExtraCredits();
    if (mounted) {
      setState(() => _currentCredits = credits);
    }
  }

  Future<void> _purchasePack(CreditPack pack) async {
    if (_isPurchasing) return;

    setState(() {
      _isPurchasing = true;
      _purchasingPackId = pack.id;
    });

    HapticFeedback.mediumImpact();

    try {
      final result = await PurchaseService().purchaseCreditPack(pack.id);

      if (mounted) {
        if (result.success) {
          // Credits added successfully
          await _loadCurrentCredits();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    PhosphorIconsDuotone.checkCircle,
                    color: context.appColors.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).creditPurchaseSuccess(pack.credits),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: context.appColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: context.appColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
          _purchasingPackId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIconsDuotone.caretLeft,
            color: context.appColors.textPrimary,
          ),
          tooltip: l10n.goBack,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.creditPurchaseTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.appColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Current credits display
              _buildCurrentCreditsCard(l10n),

              const SizedBox(height: 32),

              // Header
              _buildHeader(l10n),

              const SizedBox(height: 24),

              // Credit packs
              _buildPackCard(pack: CreditPack.small, l10n: l10n),
              const SizedBox(height: 16),
              _buildPackCard(
                pack: CreditPack.medium,
                l10n: l10n,
                badge: l10n.creditPackPopular,
              ),
              const SizedBox(height: 16),
              _buildPackCard(
                pack: CreditPack.large,
                l10n: l10n,
                badge: l10n.creditPackBestValue,
              ),

              const SizedBox(height: 32),

              // Footer info
              _buildFooterInfo(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentCreditsCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.appColors.primary.withValues(alpha: 0.15),
            context.appColors.secondary.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.appColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.appColors.primary,
                  context.appColors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              PhosphorIconsDuotone.coins,
              size: 24,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.creditCurrentBalance,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.creditAmount(_currentCredits),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.appColors.primary.withValues(alpha: 0.2),
                context.appColors.secondary.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            PhosphorIconsDuotone.batteryCharging,
            size: 32,
            color: context.appColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.creditPurchaseHeader,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.creditPurchaseSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: context.appColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPackCard({
    required CreditPack pack,
    required AppLocalizations l10n,
    String? badge,
  }) {
    final isLoading = _isPurchasing && _purchasingPackId == pack.id;
    final isDisabled = _isPurchasing && _purchasingPackId != pack.id;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: badge != null
                ? context.appColors.primary.withValues(alpha: 0.5)
                : context.appColors.cardBorder,
            width: badge != null ? 2 : 1,
          ),
          boxShadow: badge != null
              ? [
                  BoxShadow(
                    color: context.appColors.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : () => _purchasePack(pack),
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Credits icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.appColors.primary.withValues(alpha: 0.15),
                              context.appColors.secondary.withValues(
                                alpha: 0.15,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '${pack.credits}',
                            style: TextStyle(
                              fontSize: pack.credits >= 100 ? 18 : 22,
                              fontWeight: FontWeight.w800,
                              color: context.appColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.creditPackTitle(pack.credits),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: context.appColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.creditPackPricePerCredit(
                                pack.pricePerCredit.toStringAsFixed(2),
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: context.appColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.appColors.primary,
                              context.appColors.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.appColors.textPrimary,
                                ),
                              )
                            : Text(
                                '₺${pack.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: context.appColors.textPrimary,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                // Badge
                if (badge != null)
                  Positioned(
                    top: 0,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.appColors.primary,
                            context.appColors.secondary,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.textPrimary,
                          letterSpacing: 0.5,
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

  Widget _buildFooterInfo(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsDuotone.infinity,
            size: 24,
            color: context.appColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.creditNeverExpire,
              style: TextStyle(
                fontSize: 13,
                color: context.appColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
