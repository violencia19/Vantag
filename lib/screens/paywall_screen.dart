import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  Offerings? _offerings;
  Package? _selectedPackage;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _loadOfferings();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            (p) =>
                p.identifier.contains('yearly') ||
                p.identifier.contains('annual'),
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

    HapticFeedback.mediumImpact();
    setState(() => _isPurchasing = true);

    final result = await PurchaseService().purchasePackage(_selectedPackage!);

    setState(() => _isPurchasing = false);

    if (mounted) {
      if (result.success) {
        Navigator.of(context).pop(true); // Return success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: context.appColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: context.appColors.error,
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
          backgroundColor: result.isPro == true
              ? context.appColors.success
              : context.appColors.textSecondary,
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
        decoration: const BoxDecoration(gradient: AppGradients.background),
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
                        backgroundColor: context.appColors.surface,
                        foregroundColor: context.appColors.textSecondary,
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
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        l10n.paywallSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Feature comparison
                      _buildFeatureComparison(l10n),
                      const SizedBox(height: 32),

                      // Package cards with animation
                      if (_isLoading)
                        _buildLoadingSkeleton()
                      else if (_error != null)
                        _buildErrorState()
                      else
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildPackageCards(),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Purchase button
                      if (!_isLoading && _error == null)
                        _buildPurchaseButton(l10n),
                      const SizedBox(height: 16),

                      // Trust indicators
                      _buildTrustIndicators(l10n),
                      const SizedBox(height: 16),

                      // Restore purchases
                      TextButton(
                        onPressed: _isPurchasing ? null : _restorePurchases,
                        child: Text(
                          l10n.restorePurchases,
                          style: TextStyle(
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Legal links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Privacy policy link
                            },
                            child: Text(
                              l10n.privacyPolicy,
                              style: TextStyle(
                                color: context.appColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: context.appColors.textTertiary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Terms of use link
                            },
                            child: Text(
                              l10n.termsOfService,
                              style: TextStyle(
                                color: context.appColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
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
        gradient: LinearGradient(
          colors: [context.appColors.primary, context.appColors.secondary],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.crown, color: context.appColors.textPrimary, size: 24),
          const SizedBox(width: 8),
          Text(
            'VANTAG PRO',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.appColors.textPrimary,
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
            context.appColors.success.withValues(alpha: 0.2),
            context.appColors.success.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.appColors.success.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.success.withValues(alpha: 0.2),
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
              color: context.appColors.success,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.gift, color: context.appColors.textPrimary, size: 18),
                const SizedBox(width: 8),
                Text(
                  l10n.freeTrialBanner,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
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
              color: context.appColors.success,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            l10n.freeTrialDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
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
                color: context.appColors.success.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.noPaymentNow,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.appColors.success,
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
      _Feature(
        l10n.featureAiChat,
        l10n.featureAiChatFree,
        l10n.featureUnlimited,
      ),
      _Feature(
        l10n.featureHistory,
        l10n.featureHistory30Days,
        l10n.featureUnlimited,
      ),
      _Feature(l10n.featureExport, l10n.featureNo, l10n.featureYes),
      _Feature(l10n.featureWidgets, l10n.featureNo, l10n.featureYes),
      _Feature(l10n.featureAds, l10n.featureYes, l10n.featureNo),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.cardBorder),
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
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      context.appColors.primary,
                      context.appColors.secondary,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Pro',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: context.appColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: context.appColors.cardBorder),
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
                color: context.appColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child:
                feature.pro.toLowerCase() == 'yes' ||
                    feature.pro.toLowerCase() == 'evet' ||
                    feature.pro == AppLocalizations.of(context).featureUnlimited
                ? Icon(
                    LucideIcons.check,
                    color: context.appColors.success,
                    size: 20,
                  )
                : feature.pro.toLowerCase() == 'no' ||
                      feature.pro.toLowerCase() == 'hayır'
                ? Icon(LucideIcons.x, color: context.appColors.error, size: 20)
                : Text(
                    feature.pro,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appColors.success,
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
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedPackage = package);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF2D2440), Color(0xFF1A1625)],
                    )
                  : null,
              color: isSelected ? null : context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? context.appColors.primary
                    : context.appColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: context.appColors.primary.withValues(alpha: 0.2),
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
                          color: isSelected
                              ? context.appColors.primary
                              : context.appColors.textTertiary,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      context.appColors.primary,
                                      context.appColors.secondary,
                                    ],
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getPackageSubtitle(package),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: context.appColors.textSecondary,
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getPricePeriod(package),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.appColors.textTertiary),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF9C27B0,
                            ).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.infinity,
                            size: 10,
                            color: context.appColors.textPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.forever,
                            style: TextStyle(
                              color: context.appColors.textPrimary,
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
                    top: -10,
                    left: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.appColors.gold,
                            const Color(0xFFFFB800),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: context.appColors.gold.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        l10n.mostPopular,
                        style: TextStyle(
                          color: context.appColors.background,
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
    final buttonText = isMonthlyWithTrial
        ? l10n.startFreeTrial
        : l10n.subscribeToPro;
    final buttonColor = isMonthlyWithTrial
        ? context.appColors.success
        : context.appColors.primary;
    final buttonColorEnd = isMonthlyWithTrial
        ? const Color(0xFF00C853)
        : context.appColors.secondary;

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
            gradient: LinearGradient(colors: [buttonColor, buttonColorEnd]),
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
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: context.appColors.textPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isMonthlyWithTrial) ...[
                        Icon(
                          LucideIcons.gift,
                          color: context.appColors.textPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        buttonText,
                        style: TextStyle(
                          color: context.appColors.textPrimary,
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

  Widget _buildTrustIndicators(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTrustItem(LucideIcons.shieldCheck, l10n.securePayment),
          _buildTrustItem(LucideIcons.lock, l10n.encrypted),
          _buildTrustItem(LucideIcons.refreshCcw, l10n.cancelAnytime),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: context.appColors.textTertiary, size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.appColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.alertCircle,
            color: context.appColors.error,
            size: 48,
          ),
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

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.cardBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              // Radio placeholder
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.appColors.textTertiary,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Text placeholders
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: 80 + (index * 20), height: 16),
                    const SizedBox(height: 8),
                    _ShimmerBox(width: 120 + (index * 10), height: 12),
                  ],
                ),
              ),
              // Price placeholder
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ShimmerBox(width: 60, height: 20),
                    const SizedBox(height: 4),
                    _ShimmerBox(width: 40, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading box
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: context.appColors.textTertiary.withValues(
              alpha: _animation.value,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

class _Feature {
  final String name;
  final String free;
  final String pro;

  _Feature(this.name, this.free, this.pro);
}
