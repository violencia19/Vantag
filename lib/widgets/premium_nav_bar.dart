import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../services/services.dart';

/// Premium Floating Navigation Bar
/// Premium banking-style design - Gradient FAB, Glassmorphism
class PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTap;
  final VoidCallback? onAddLongPress;

  const PremiumNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
    this.onAddLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 34),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? VantColors.surface.withValues(alpha: 0.95)
                  : const Color(0xF2FFFFFF),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home
                _NavItem(
                  icon: CupertinoIcons.house_fill,
                  label: l10n.homePage,
                  tooltip: l10n.navHomeTooltip,
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                // Reports
                _NavItem(
                  icon: CupertinoIcons.chart_bar_fill,
                  label: l10n.analysis,
                  tooltip: l10n.navReportsTooltip,
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                // FAB - Center
                Semantics(
                  label: l10n.accessibilityAddExpense,
                  button: true,
                  child: _CenterAddButton(
                    onTap: onAddTap,
                    onLongPress: onAddLongPress,
                  ),
                ),
                // Pursuits (Dreams)
                _NavItem(
                  icon: CupertinoIcons.star_fill,
                  label: l10n.navPursuits,
                  tooltip: l10n.navPursuitsTooltip,
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                // Settings
                _NavItem(
                  icon: CupertinoIcons.gear_alt_fill,
                  label: l10n.navSettings,
                  tooltip: l10n.navSettingsTooltip,
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
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
  final bool isActive;
  final VoidCallback onTap;
  final String? tooltip;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.vantColors;

    return Semantics(
      label: tooltip ?? label,
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: () {
          haptics.navigation();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? colors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? VantShadows.glow(VantColors.primary, intensity: 0.4, blur: 12)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: isActive
                    ? BoxDecoration(
                        boxShadow: VantShadows.glow(VantColors.primary, intensity: 0.3, blur: 8),
                      )
                    : null,
                child: Icon(
                  icon,
                  size: 24,
                  color: isActive ? colors.primary : colors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? colors.primary : colors.textTertiary,
                  letterSpacing: 0.8,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterAddButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CenterAddButton({required this.onTap, this.onLongPress});

  @override
  State<_CenterAddButton> createState() => _CenterAddButtonState();
}

class _CenterAddButtonState extends State<_CenterAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    haptics.buttonPress();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onLongPress() {
    setState(() => _isPressed = false);
    _controller.reverse();
    HapticFeedback.heavyImpact();
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onLongPress != null ? _onLongPress : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.vantColors.primary.withValues(
                      alpha: _isPressed ? 0.3 : 0.5,
                    ),
                    blurRadius: _isPressed ? 15 : 25,
                    offset: Offset(0, _isPressed ? 4 : 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: VantGradients.primaryButton,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.plus,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileNavItem extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;
  final String label;

  const _ProfileNavItem({
    required this.isActive,
    required this.onTap,
    required this.label,
  });

  @override
  State<_ProfileNavItem> createState() => _ProfileNavItemState();
}

class _ProfileNavItemState extends State<_ProfileNavItem> {
  final _profileService = ProfileService();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final path = await _profileService.getProfilePhotoPath();
    if (mounted) {
      setState(() => _photoPath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        haptics.navigation();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isActive
              ? context.vantColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _photoPath != null
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isActive
                            ? context.vantColors.primary
                            : context.vantColors.textTertiary,
                        width: 2,
                      ),
                      boxShadow: widget.isActive
                          ? [
                              BoxShadow(
                                color: context.vantColors.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipOval(
                      child: Image.file(
                        File(_photoPath!),
                        fit: BoxFit.cover,
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            CupertinoIcons.person_fill,
                            size: 16,
                            color: widget.isActive
                                ? context.vantColors.primary
                                : context.vantColors.textTertiary,
                          );
                        },
                      ),
                    ),
                  )
                : Icon(
                    CupertinoIcons.person_fill,
                    size: 24,
                    color: widget.isActive
                        ? context.vantColors.primary
                        : context.vantColors.textTertiary,
                  ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                color: widget.isActive
                    ? context.vantColors.primary
                    : context.vantColors.textTertiary,
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium Floating Navigation Bar with Showcase support
/// iOS 26 Liquid Glass Design
class PremiumNavBarWithShowcase extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTap;
  final VoidCallback? onAddLongPress;

  const PremiumNavBarWithShowcase({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
    this.onAddLongPress,
  });

  @override
  State<PremiumNavBarWithShowcase> createState() =>
      _PremiumNavBarWithShowcaseState();
}

class _PremiumNavBarWithShowcaseState extends State<PremiumNavBarWithShowcase>
    with SingleTickerProviderStateMixin {
  // Breathing glow animation
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: VantAnimation.breathing,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: VantAnimation.glowMin,
      end: VantAnimation.glowMax,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: VantAnimation.curveSmooth,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;

    // Floating nav with breathing glow
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 34),
          // Glow shadow for premium feel
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VantRadius.xxl),
            boxShadow: [
              // Animated breathing glow
              BoxShadow(
                color: VantColors.primary.withValues(
                  alpha: _glowAnimation.value,
                ),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
              // Deep shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(VantRadius.xxl),
            child: BackdropFilter(
              // Glass blur
              filter: ImageFilter.blur(
                sigmaX: VantBlur.medium,
                sigmaY: VantBlur.medium,
              ),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  // Glass gradient
                  gradient: isDark
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            VantColors.primary.withValues(alpha: 0.15),
                            VantColors.surface.withValues(alpha: 0.9),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.85),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(VantRadius.xxl),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: 0.08,
                    ),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Home
                    _NavItem(
                      icon: CupertinoIcons.house_fill,
                      label: l10n.homePage,
                      isActive: widget.currentIndex == 0,
                      onTap: () => widget.onTap(0),
                    ),
                    // Reports - with Showcase
                    Showcase(
                      key: TourKeys.navBarReport,
                      title: l10n.reports,
                      description: l10n.reportsDescription,
                      titleTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.vantColors.textPrimary,
                        fontSize: 16,
                      ),
                      descTextStyle: TextStyle(
                        color: context.vantColors.textSecondary,
                        fontSize: 14,
                      ),
                      tooltipBackgroundColor: context.vantColors.gradientMid,
                      overlayColor: Colors.black,
                      overlayOpacity: 0.95,
                      targetBorderRadius: BorderRadius.circular(16),
                      child: _NavItem(
                        icon: CupertinoIcons.chart_bar_fill,
                        label: l10n.analysis,
                        isActive: widget.currentIndex == 1,
                        onTap: () => widget.onTap(1),
                      ),
                    ),
                    // FAB - Center with Showcase
                    Showcase(
                      key: TourKeys.navBarAddButton,
                      title: l10n.quickAdd,
                      description: l10n.quickAddDescription,
                      titleTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.vantColors.textPrimary,
                        fontSize: 16,
                      ),
                      descTextStyle: TextStyle(
                        color: context.vantColors.textSecondary,
                        fontSize: 14,
                      ),
                      tooltipBackgroundColor: context.vantColors.gradientMid,
                      overlayColor: Colors.black,
                      overlayOpacity: 0.95,
                      targetShapeBorder: const CircleBorder(),
                      targetPadding: EdgeInsets.zero,
                      child: Semantics(
                        label: l10n.accessibilityAddExpense,
                        button: true,
                        child: _CenterAddButton(
                          onTap: widget.onAddTap,
                          onLongPress: widget.onAddLongPress,
                        ),
                      ),
                    ),
                    // Pursuits (Dreams) - with Showcase
                    Showcase(
                      key: TourKeys.navBarAchievements,
                      title: l10n.navPursuits,
                      description: l10n.emptyPursuitsMessage,
                      titleTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.vantColors.textPrimary,
                        fontSize: 16,
                      ),
                      descTextStyle: TextStyle(
                        color: context.vantColors.textSecondary,
                        fontSize: 14,
                      ),
                      tooltipBackgroundColor: context.vantColors.gradientMid,
                      overlayColor: Colors.black,
                      overlayOpacity: 0.95,
                      targetBorderRadius: BorderRadius.circular(16),
                      child: _NavItem(
                        icon: CupertinoIcons.star_fill,
                        label: l10n.navPursuits,
                        isActive: widget.currentIndex == 2,
                        onTap: () => widget.onTap(2),
                      ),
                    ),
                    // Settings - with Showcase
                    Showcase(
                      key: TourKeys.navBarProfile,
                      title: l10n.navSettings,
                      description: l10n.profileAndSettingsDescription,
                      titleTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.vantColors.textPrimary,
                        fontSize: 16,
                      ),
                      descTextStyle: TextStyle(
                        color: context.vantColors.textSecondary,
                        fontSize: 14,
                      ),
                      tooltipBackgroundColor: context.vantColors.gradientMid,
                      overlayColor: Colors.black,
                      overlayOpacity: 0.95,
                      targetBorderRadius: BorderRadius.circular(16),
                      child: _NavItem(
                        icon: CupertinoIcons.gear_alt_fill,
                        label: l10n.navSettings,
                        isActive: widget.currentIndex == 3,
                        onTap: () => widget.onTap(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
