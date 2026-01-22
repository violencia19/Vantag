import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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

  const PremiumNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xF20D0D1A), // rgba(13,13,26,0.95)
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home
                _NavItem(
                  icon: PhosphorIconsDuotone.house,
                  label: l10n.homePage,
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                // Reports
                _NavItem(
                  icon: PhosphorIconsDuotone.chartBar,
                  label: l10n.analysis,
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                // FAB - Center
                _CenterAddButton(onTap: onAddTap),
                // Pursuits (Dreams)
                _NavItem(
                  icon: PhosphorIconsDuotone.star,
                  label: l10n.navPursuits,
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                // Settings
                _NavItem(
                  icon: PhosphorIconsDuotone.gear,
                  label: l10n.navSettings,
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

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              duotoneSecondaryColor: isActive
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                letterSpacing: 0.3,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAddButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CenterAddButton({required this.onTap});

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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryButton,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: _isPressed ? 0.3 : 0.5),
                    blurRadius: _isPressed ? 15 : 25,
                    offset: Offset(0, _isPressed ? 4 : 8),
                  ),
                ],
              ),
              child: PhosphorIcon(
                PhosphorIconsDuotone.plus,
                size: 28,
                color: Colors.white,
                duotoneSecondaryColor: Colors.white.withValues(alpha: 0.6),
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
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
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
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        width: 2,
                      ),
                      boxShadow: widget.isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
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
                          return PhosphorIcon(
                            PhosphorIconsDuotone.user,
                            size: 16,
                            color: widget.isActive
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          );
                        },
                      ),
                    ),
                  )
                : PhosphorIcon(
                    PhosphorIconsDuotone.user,
                    size: 24,
                    color: widget.isActive
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    duotoneSecondaryColor: widget.isActive
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.textTertiary.withValues(alpha: 0.3),
                  ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                color:
                    widget.isActive ? AppColors.primary : AppColors.textTertiary,
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
class PremiumNavBarWithShowcase extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTap;

  const PremiumNavBarWithShowcase({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xF20D0D1A), // rgba(13,13,26,0.95)
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home
                _NavItem(
                  icon: PhosphorIconsDuotone.house,
                  label: l10n.homePage,
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                // Reports - with Showcase
                Showcase(
                  key: TourKeys.navBarReport,
                  title: l10n.reports,
                  description: l10n.reportsDescription,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  descTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  tooltipBackgroundColor: AppColors.gradientMid,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.95,
                  targetBorderRadius: BorderRadius.circular(12),
                  child: _NavItem(
                    icon: PhosphorIconsDuotone.chartBar,
                    label: l10n.analysis,
                    isActive: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
                // FAB - Center with Showcase
                Showcase(
                  key: TourKeys.navBarAddButton,
                  title: l10n.quickAdd,
                  description: l10n.quickAddDescription,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  descTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  tooltipBackgroundColor: AppColors.gradientMid,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.95,
                  targetShapeBorder: const CircleBorder(),
                  child: _CenterAddButton(onTap: onAddTap),
                ),
                // Pursuits (Dreams) - with Showcase
                Showcase(
                  key: TourKeys.navBarAchievements,
                  title: l10n.navPursuits,
                  description: l10n.emptyPursuitsMessage,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  descTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  tooltipBackgroundColor: AppColors.gradientMid,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.95,
                  targetBorderRadius: BorderRadius.circular(12),
                  child: _NavItem(
                    icon: PhosphorIconsDuotone.star,
                    label: l10n.navPursuits,
                    isActive: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ),
                // Settings - with Showcase
                Showcase(
                  key: TourKeys.navBarProfile,
                  title: l10n.navSettings,
                  description: l10n.profileAndSettingsDescription,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  descTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  tooltipBackgroundColor: AppColors.gradientMid,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.95,
                  targetBorderRadius: BorderRadius.circular(12),
                  child: _NavItem(
                    icon: PhosphorIconsDuotone.gear,
                    label: l10n.navSettings,
                    isActive: currentIndex == 3,
                    onTap: () => onTap(3),
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
