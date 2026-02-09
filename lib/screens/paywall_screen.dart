import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:vantag/providers/locale_provider.dart';
import 'package:vantag/services/analytics_service.dart';
import 'package:vantag/services/purchase_service.dart';
import '../theme/theme.dart';

/// Premium paywall screen with subscription options
class PaywallScreen extends StatefulWidget {
  /// Optional feature that triggered the paywall
  final String? featureName;

  const PaywallScreen({super.key, this.featureName});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with TickerProviderStateMixin {
  Offerings? _offerings;
  Package? _selectedPackage;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // iOS 26 Liquid Glass: Animated breathing glow
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

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

    // iOS 26 Liquid Glass: Breathing glow effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _loadOfferings();
    _animationController.forward();
    // Track paywall viewed for conversion funnel
    AnalyticsService().logPaywallViewed(source: widget.featureName);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
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
            backgroundColor: context.vantColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: context.vantColors.error,
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
              ? context.vantColors.success
              : context.vantColors.textSecondary,
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
        decoration: const BoxDecoration(gradient: VantGradients.background),
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
                      icon: const Icon(CupertinoIcons.xmark),
                      tooltip: l10n.close,
                      style: IconButton.styleFrom(
                        backgroundColor: context.vantColors.surface,
                        foregroundColor: context.vantColors.textSecondary,
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
                          color: context.vantColors.textSecondary,
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

                      // Auto-renewal disclosure (Apple App Store requirement)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.subscriptionAutoRenewalNotice,
                          style: TextStyle(
                            color: context.vantColors.textTertiary,
                            fontSize: 10,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Restore purchases
                      TextButton(
                        onPressed: _isPurchasing ? null : _restorePurchases,
                        child: Text(
                          l10n.restorePurchases,
                          style: TextStyle(
                            color: context.vantColors.textSecondary,
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
                              final localeProvider = context.read<LocaleProvider>();
                              final langCode = localeProvider.locale?.languageCode ?? 'tr';
                              final privacyUrl = langCode == 'tr'
                                  ? 'https://violencia19.github.io/Vantag/privacy-tr'
                                  : 'https://violencia19.github.io/Vantag/privacy-en';
                              launchUrl(Uri.parse(privacyUrl));
                            },
                            child: Text(
                              l10n.privacyPolicy,
                              style: TextStyle(
                                color: context.vantColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: context.vantColors.textTertiary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final localeProvider = context.read<LocaleProvider>();
                              final langCode = localeProvider.locale?.languageCode ?? 'tr';
                              final termsUrl = langCode == 'tr'
                                  ? 'https://violencia19.github.io/Vantag/terms-tr'
                                  : 'https://violencia19.github.io/Vantag/terms-en';
                              launchUrl(Uri.parse(termsUrl));
                            },
                            child: Text(
                              l10n.termsOfService,
                              style: TextStyle(
                                color: context.vantColors.textTertiary,
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
    // iOS 26 Liquid Glass: Animated Pro badge
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              // Animated breathing glow
              BoxShadow(
                color: VantColors.primary.withValues(
                  alpha: _glowAnimation.value,
                ),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  // Solid gradient replacing glass blur
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      VantColors.primary.withValues(alpha: 0.8),
                      VantColors.primaryLight.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      color: Colors.white,
                      size: 24,
                      shadows: [
                        Shadow(
                          color: VantColors.primary.withValues(alpha: 0.6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'VANTAG PRO',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                        shadows: [
                          Shadow(
                            color: VantColors.primary.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  Widget _buildFreeTrialBanner(AppLocalizations l10n) {
    // iOS 26 Liquid Glass: Free trial banner with glass effect
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          // Primary violet glow
          BoxShadow(
            color: VantColors.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Solid gradient replacing glass blur
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  VantColors.primary.withValues(alpha: 0.6),
                  VantColors.primary.withValues(alpha: 0.35),
                  const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: VantColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.vantColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.gift_fill,
                  color: context.vantColors.textPrimary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.freeTrialBanner,
                  style: TextStyle(
                    color: context.vantColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
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
              color: context.vantColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            l10n.freeTrialDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.vantColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // No payment now indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.checkmark_shield_fill,
                color: context.vantColors.primary.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.noPaymentNow,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.vantColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)]
              : [const Color(0x0A000000), const Color(0x05000000)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000), width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
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
                      context.vantColors.primary,
                      context.vantColors.secondary,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Pro',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: context.vantColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: context.vantColors.cardBorder),
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
                color: context.vantColors.textTertiary,
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
                    CupertinoIcons.checkmark,
                    color: context.vantColors.primary,
                    size: 20,
                  )
                : feature.pro.toLowerCase() == 'no' ||
                      feature.pro.toLowerCase() == 'hayır'
                ? Icon(CupertinoIcons.xmark, color: context.vantColors.error, size: 20)
                : Text(
                    feature.pro,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.vantColors.primary,
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

        return Semantics(
          button: true,
          selected: isSelected,
          label:
              '${_getPackageTitle(package)} ${package.storeProduct.priceString}',
          child: GestureDetector(
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
                    ? LinearGradient(
                        colors: [
                          VantColors.primary.withValues(alpha: 0.12),
                          VantColors.primary.withValues(alpha: 0.04),
                        ],
                      )
                    : LinearGradient(
                        colors: context.isDarkMode
                            ? [const Color(0x08FFFFFF), const Color(0x04FFFFFF)]
                            : [const Color(0x08000000), const Color(0x04000000)],
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? context.vantColors.primary
                      : context.isDarkMode ? const Color(0x0FFFFFFF) : const Color(0x0F000000),
                  width: isSelected ? 2 : 0.5,
                ),
                boxShadow: isSelected
                    ? VantShadows.glow(VantColors.primary, intensity: 0.25, blur: 16)
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
                                ? context.vantColors.primary
                                : context.vantColors.textTertiary,
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
                                        context.vantColors.primary,
                                        context.vantColors.secondary,
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
                                    color: context.vantColors.textSecondary,
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
                                ?.copyWith(
                                  color: context.vantColors.textTertiary,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              VantColors.premiumPurple,
                              VantColors.premiumPurple.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: VantColors.premiumPurple.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.infinite,
                              size: 10,
                              color: context.vantColors.textPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.forever,
                              style: TextStyle(
                                color: context.vantColors.textPrimary,
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
                              context.vantColors.gold,
                              VantColors.currencyGold,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: context.vantColors.gold.withValues(
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
                            color: context.vantColors.background,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
    final buttonColor = context.vantColors.primary;
    final buttonColorEnd = context.vantColors.secondary;

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
              ...VantShadows.coloredGlow(buttonColor, intensity: 0.6),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isPurchasing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: context.vantColors.textPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isMonthlyWithTrial) ...[
                        Icon(
                          CupertinoIcons.gift_fill,
                          color: context.vantColors.textPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        buttonText,
                        style: TextStyle(
                          color: context.vantColors.textPrimary,
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
          _buildTrustItem(CupertinoIcons.checkmark_shield_fill, l10n.securePayment),
          _buildTrustItem(CupertinoIcons.lock_fill, l10n.encrypted),
          _buildTrustItem(CupertinoIcons.arrow_counterclockwise, l10n.cancelAnytime),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: context.vantColors.textTertiary, size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.vantColors.textTertiary,
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
        color: context.vantColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            color: context.vantColors.error,
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
            icon: const Icon(CupertinoIcons.arrow_clockwise),
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
            color: context.vantColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.vantColors.cardBorder),
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
                    color: context.vantColors.textTertiary,
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
            color: context.vantColors.textTertiary.withValues(
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
