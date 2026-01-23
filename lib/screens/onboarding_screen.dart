import 'dart:async';
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
  final bool showCoffeeClockAnimation;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconColor,
    this.showDecisionButtons = false,
    this.showStartButton = false,
    this.showCoffeeClockAnimation = false,
  });
}

/// Build localized onboarding pages
List<OnboardingPageData> _buildOnboardingPages(AppLocalizations l10n, BuildContext context) {
  return [
    // Slide 1: Hook - Coffee to Clock animation
    OnboardingPageData(
      title: l10n.onboardingHookTitle,
      subtitle: l10n.onboardingHookSubtitle,
      showCoffeeClockAnimation: true,
    ),
    // Slide 2: Decision buttons
    OnboardingPageData(
      title: l10n.everyExpenseDecision,
      subtitle: l10n.youDecide,
      showDecisionButtons: true,
    ),
    // Slide 3: Start button
    OnboardingPageData(
      title: l10n.oneExpenseEnough,
      subtitle: l10n.startSmall,
      icon: PhosphorIconsDuotone.rocketLaunch,
      iconColor: context.appColors.primary,
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
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  // Coffee-clock animation
  late AnimationController _iconAnimationController;
  bool _showClock = false;
  Timer? _iconToggleTimer;

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

    // Setup icon animation controller for crossfade
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Start coffee-clock toggle timer
    _startIconToggle();
  }

  void _startIconToggle() {
    _iconToggleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          _showClock = !_showClock;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimationController.dispose();
    _iconAnimationController.dispose();
    _iconToggleTimer?.cancel();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final profileService = ProfileService();
    final success = await profileService.setOnboardingCompleted();
    debugPrint('[Onboarding] ✓ Onboarding completed flag saved: $success');

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
    final pages = _buildOnboardingPages(l10n, context);

    return Scaffold(
      backgroundColor: context.appColors.background,
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
                    showClock: _showClock,
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
        final success = await profileService.setOnboardingCompleted();
        debugPrint('[Onboarding] ✓ Onboarding skipped, flag saved: $success');

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
        style: TextStyle(
          color: context.appColors.textSecondary,
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
  final bool showClock;

  const _OnboardingPage({
    required this.data,
    required this.onStartPressed,
    required this.buttonAnimationController,
    required this.buttonScaleAnimation,
    required this.l10n,
    required this.showClock,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Coffee-Clock animation (Slide 1 hook)
          if (data.showCoffeeClockAnimation) ...[
            _CoffeeClockAnimation(showClock: showClock),
            const SizedBox(height: 48),
          ],

          // Icon or visual content
          if (data.icon != null) ...[
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: data.iconColor?.withValues(alpha: 0.1) ??
                    context.appColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: data.iconColor?.withValues(alpha: 0.2) ??
                      context.appColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                data.icon,
                size: 64,
                color: data.iconColor ?? context.appColors.primary,
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
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: context.appColors.textSecondary,
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
                      color: context.appColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      l10n.start,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.background,
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

/// Animated coffee-to-clock icon for the hook slide
class _CoffeeClockAnimation extends StatelessWidget {
  final bool showClock;

  const _CoffeeClockAnimation({required this.showClock});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.appColors.primary.withValues(alpha: 0.15),
            context.appColors.accent.withValues(alpha: 0.1),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: context.appColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: showClock
            ? Icon(
                PhosphorIconsDuotone.clock,
                key: const ValueKey('clock'),
                size: 72,
                color: context.appColors.primary,
              )
            : Icon(
                PhosphorIconsDuotone.coffee,
                key: const ValueKey('coffee'),
                size: 72,
                color: context.appColors.accent,
              ),
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
          color: context.appColors.decisionNo,
          icon: PhosphorIconsDuotone.x,
          label: l10n.passed,
        ),
        const SizedBox(width: 12),
        _DecisionButton(
          color: context.appColors.decisionThinking,
          icon: PhosphorIconsDuotone.hourglass,
          label: l10n.thinking,
        ),
        const SizedBox(width: 12),
        _DecisionButton(
          color: context.appColors.decisionYes,
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
        color: isActive ? context.appColors.primary : context.appColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
