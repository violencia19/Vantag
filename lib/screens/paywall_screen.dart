import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:vantag/services/purchase_service.dart';
import 'package:vantag/theme/app_theme.dart';

/// Premium paywall screen with subscription options
class PaywallScreen extends StatefulWidget {
  /// Optional feature that triggered the paywall
  final String? featureName;

  const PaywallScreen({super.key, this.featureName});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Offerings? _offerings;
  Package? _selectedPackage;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final offerings = await PurchaseService().getOfferings();

      if (offerings != null && offerings.current != null) {
        setState(() {
          _offerings = offerings;
          // Select yearly by default (best value)
          _selectedPackage = offerings.current!.availablePackages.firstWhere(
            (p) => p.identifier.contains('yearly') || p.identifier.contains('annual'),
            orElse: () => offerings.current!.availablePackages.first,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No offerings available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load packages';
        _isLoading = false;
      });
    }
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null) return;

    setState(() => _isPurchasing = true);

    final result = await PurchaseService().purchasePackage(_selectedPackage!);

    setState(() => _isPurchasing = false);

    if (mounted) {
      if (result.success) {
        Navigator.of(context).pop(true); // Return success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);

    final result = await PurchaseService().restorePurchases();

    setState(() => _isPurchasing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isPro == true ? AppColors.success : AppColors.textSecondary,
        ),
      );

      if (result.isPro == true) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(LucideIcons.x),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Pro Badge
                      _buildProBadge(),
                      const SizedBox(height: 24),

                      // FREE TRIAL BANNER - Prominent
                      _buildFreeTrialBanner(l10n),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        l10n.paywallTitle,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        l10n.paywallSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Feature comparison
                      _buildFeatureComparison(l10n),
                      const SizedBox(height: 32),

                      // Package cards
                      if (_isLoading)
                        const CircularProgressIndicator(color: AppColors.primary)
                      else if (_error != null)
                        _buildErrorState()
                      else
                        _buildPackageCards(),
                      const SizedBox(height: 24),

                      // Purchase button
                      if (!_isLoading && _error == null) _buildPurchaseButton(l10n),
                      const SizedBox(height: 16),

                      // Restore purchases
                      TextButton(
                        onPressed: _isPurchasing ? null : _restorePurchases,
                        child: Text(
                          l10n.restorePurchases,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.crown, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            'VANTAG PRO',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeTrialBanner(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withValues(alpha: 0.2),
            AppColors.success.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.gift, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  l10n.freeTrialBanner,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main text
          Text(
            l10n.startFreeTrial,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            l10n.freeTrialDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // No payment now indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.shieldCheck,
                color: AppColors.success.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.noPaymentNow,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison(AppLocalizations l10n) {
    final features = [
      _Feature(l10n.featureAiChat, l10n.featureAiChatFree, l10n.featureUnlimited),
      _Feature(l10n.featureHistory, l10n.featureHistory30Days, l10n.featureUnlimited),
      _Feature(l10n.featureExport, l10n.featureNo, l10n.featureYes),
      _Feature(l10n.featureWidgets, l10n.featureNo, l10n.featureYes),
      _Feature(l10n.featureAds, l10n.featureYes, l10n.featureNo),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  l10n.feature,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Expanded(
                child: Text(
                  'Free',
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ).createShader(bounds),
                  child: Text(
                    'Pro',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: 8),
          // Features
          ...features.map((f) => _buildFeatureRow(f)),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(_Feature feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              feature.free,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: feature.pro.toLowerCase() == 'yes' ||
                    feature.pro.toLowerCase() == 'evet' ||
                    feature.pro == AppLocalizations.of(context).featureUnlimited
                ? const Icon(LucideIcons.check, color: AppColors.success, size: 20)
                : feature.pro.toLowerCase() == 'no' ||
                        feature.pro.toLowerCase() == 'hayır'
                    ? const Icon(LucideIcons.x, color: AppColors.error, size: 20)
                    : Text(
                        feature.pro,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                        ),
                        textAlign: TextAlign.center,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCards() {
    final packages = _offerings?.current?.availablePackages ?? [];
    final l10n = AppLocalizations.of(context);

    return Column(
      children: packages.map((package) {
        final isSelected = _selectedPackage?.identifier == package.identifier;
        final id = package.identifier.toLowerCase();
        final isYearly = id.contains('yearly') || id.contains('annual');
        final isLifetime = id.contains('lifetime');

        return GestureDetector(
          onTap: () => setState(() => _selectedPackage = package),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF2D2440),
                        Color(0xFF1A1625),
                      ],
                    )
                  : null,
              color: isSelected ? null : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    // Radio indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.textTertiary,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary, AppColors.secondary],
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // Package info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPackageTitle(package),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getPackageSubtitle(package),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          package.storeProduct.priceString,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getPricePeriod(package),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Lifetime badge (purple)
                if (isLifetime)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C27B0).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.infinity, size: 10, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            l10n.forever,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Most popular badge (yearly - gold)
                if (isYearly && !isLifetime)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gold, Color(0xFFFFB800)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.mostPopular,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getPackageTitle(Package package) {
    final l10n = AppLocalizations.of(context);
    final id = package.identifier.toLowerCase();

    if (id.contains('lifetime')) return l10n.lifetime;
    if (id.contains('monthly')) return l10n.monthly;
    if (id.contains('yearly') || id.contains('annual')) return l10n.yearly;
    return package.storeProduct.title;
  }

  String _getPackageSubtitle(Package package) {
    final l10n = AppLocalizations.of(context);
    final id = package.identifier.toLowerCase();

    if (id.contains('lifetime')) {
      return l10n.lifetimeDescription;
    }
    if (id.contains('yearly') || id.contains('annual')) {
      return l10n.yearlySavings;
    }
    return l10n.cancelAnytime;
  }

  String _getPricePeriod(Package package) {
    final l10n = AppLocalizations.of(context);
    final id = package.identifier.toLowerCase();

    if (id.contains('lifetime')) return l10n.oneTime;
    if (id.contains('monthly')) return '/ ${l10n.month}';
    if (id.contains('yearly') || id.contains('annual')) return '/ ${l10n.year}';
    return '';
  }

  Widget _buildPurchaseButton(AppLocalizations l10n) {
    // Check if selected package has a trial
    final id = _selectedPackage?.identifier.toLowerCase() ?? '';
    final isMonthlyWithTrial = id.contains('monthly');
    final buttonText = isMonthlyWithTrial ? l10n.startFreeTrial : l10n.subscribeToPro;
    final buttonColor = isMonthlyWithTrial ? AppColors.success : AppColors.primary;
    final buttonColorEnd = isMonthlyWithTrial ? const Color(0xFF00C853) : AppColors.secondary;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isPurchasing ? null : _purchase,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [buttonColor, buttonColorEnd],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isPurchasing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isMonthlyWithTrial) ...[
                        const Icon(LucideIcons.gift, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadOfferings,
            icon: const Icon(LucideIcons.refreshCw),
            label: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final String name;
  final String free;
  final String pro;

  _Feature(this.name, this.free, this.pro);
}
