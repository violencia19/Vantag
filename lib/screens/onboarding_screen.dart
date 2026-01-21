import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../services/services.dart';
import 'screens.dart';

/// Onboarding page data - immutable
@immutable
class OnboardingPageData {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;
  final bool showDecisionButtons;
  final bool showStartButton;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconColor,
    this.showDecisionButtons = false,
    this.showStartButton = false,
  });
}

/// Build localized onboarding pages
List<OnboardingPageData> _buildOnboardingPages(AppLocalizations l10n) {
  return [
    OnboardingPageData(
      title: l10n.notBudgetApp,
      subtitle: l10n.showRealCost,
      icon: PhosphorIconsDuotone.clock,
      iconColor: AppColors.primary,
    ),
    OnboardingPageData(
      title: l10n.everyExpenseDecision,
      subtitle: l10n.youDecide,
      showDecisionButtons: true,
    ),
    OnboardingPageData(
      title: l10n.oneExpenseEnough,
      subtitle: l10n.startSmall,
      icon: PhosphorIconsDuotone.rocketLaunch,
      iconColor: AppColors.primary,
      showStartButton: true,
    ),
  ];
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final profileService = ProfileService();
    await profileService.setOnboardingCompleted();
    debugPrint('[Onboarding] ✓ Onboarding completed flag saved');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const UserProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _buildOnboardingPages(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView - wrapped with RepaintBoundary
            RepaintBoundary(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    data: pages[index],
                    onStartPressed: _completeOnboarding,
                    buttonAnimationController: _buttonAnimationController,
                    buttonScaleAnimation: _buttonScaleAnimation,
                    l10n: l10n,
                  );
                },
              ),
            ),

            // Skip button (top right)
            Positioned(
              top: 16,
              right: 16,
              child: _SkipButton(l10n: l10n),
            ),

            // Page indicators (bottom)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _PageIndicators(
                pageCount: pages.length,
                currentPage: _currentPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skip button - separate optimized widget
class _SkipButton extends StatelessWidget {
  final AppLocalizations l10n;

  const _SkipButton({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final profileService = ProfileService();
        await profileService.setOnboardingCompleted();
        debugPrint('[Onboarding] ✓ Onboarding skipped, flag saved');

        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const UserProfileScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Text(
        l10n.skip,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Page indicators - separate widget with RepaintBoundary
class _PageIndicators extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const _PageIndicators({
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          pageCount,
          (index) => _PageIndicator(isActive: index == currentPage),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final VoidCallback onStartPressed;
  final AnimationController buttonAnimationController;
  final Animation<double> buttonScaleAnimation;
  final AppLocalizations l10n;

  const _OnboardingPage({
    required this.data,
    required this.onStartPressed,
    required this.buttonAnimationController,
    required this.buttonScaleAnimation,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Icon or visual content
          if (data.icon != null) ...[
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: data.iconColor?.withValues(alpha: 0.1) ??
                    AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: data.iconColor?.withValues(alpha: 0.2) ??
                      AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                data.icon,
                size: 64,
                color: data.iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(height: 48),
          ],

          // Decision buttons visual
          if (data.showDecisionButtons) ...[
            _DecisionButtonsVisual(l10n: l10n),
            const SizedBox(height: 48),
          ],

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const Spacer(flex: 1),

          // Start button - animation isolation with RepaintBoundary
          if (data.showStartButton) ...[
            RepaintBoundary(
              child: GestureDetector(
                onTapDown: (_) => buttonAnimationController.forward(),
                onTapUp: (_) {
                  buttonAnimationController.reverse();
                  onStartPressed();
                },
                onTapCancel: () => buttonAnimationController.reverse(),
                child: ScaleTransition(
                  scale: buttonScaleAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      l10n.start,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _DecisionButtonsVisual extends StatelessWidget {
  final AppLocalizations l10n;

  const _DecisionButtonsVisual({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DecisionButton(
          color: AppColors.decisionNo,
          icon: PhosphorIconsDuotone.x,
          label: l10n.passed,
        ),
        const SizedBox(width: 12),
        _DecisionButton(
          color: AppColors.decisionThinking,
          icon: PhosphorIconsDuotone.hourglass,
          label: l10n.thinking,
        ),
        const SizedBox(width: 12),
        _DecisionButton(
          color: AppColors.decisionYes,
          icon: PhosphorIconsDuotone.check,
          label: l10n.bought,
        ),
      ],
    );
  }
}

class _DecisionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _DecisionButton({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 28,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;

  const _PageIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
