import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/theme.dart';

/// Animasyonlu bottom sheet
/// Açılırken: backdrop blur + karartma + slideUp + scale
/// Kapanırken: aynı animasyonun tersi
class AnimatedBottomSheet extends StatefulWidget {
  final Widget child;
  final double? initialHeight;
  final double? maxHeight;
  final bool showDragHandle;
  final VoidCallback? onClose;

  const AnimatedBottomSheet({
    super.key,
    required this.child,
    this.initialHeight,
    this.maxHeight,
    this.showDragHandle = true,
    this.onClose,
  });

  /// Bottom sheet'i göster
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? initialHeight,
    double? maxHeight,
    bool showDragHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => _AnimatedBottomSheetWrapper(
        initialHeight: initialHeight,
        maxHeight: maxHeight,
        showDragHandle: showDragHandle,
        child: child,
      ),
    );
  }

  @override
  State<AnimatedBottomSheet> createState() => _AnimatedBottomSheetState();
}

class _AnimatedBottomSheetState extends State<AnimatedBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showDragHandle)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.appColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Flexible(child: widget.child),
        ],
      ),
    );
  }
}

class _AnimatedBottomSheetWrapper extends StatefulWidget {
  final Widget child;
  final double? initialHeight;
  final double? maxHeight;
  final bool showDragHandle;

  const _AnimatedBottomSheetWrapper({
    required this.child,
    this.initialHeight,
    this.maxHeight,
    this.showDragHandle = true,
  });

  @override
  State<_AnimatedBottomSheetWrapper> createState() =>
      _AnimatedBottomSheetWrapperState();
}

class _AnimatedBottomSheetWrapperState extends State<_AnimatedBottomSheetWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _backdropAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standardCurve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standardCurve,
    ));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: AppAnimations.backdropBlur,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standardCurve,
    ));

    _backdropAnimation = Tween<double>(
      begin: 0.0,
      end: AppAnimations.backdropOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standardCurve,
    ));

    _controller.forward();
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
        return Stack(
          children: [
            // Backdrop with blur
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value,
                    sigmaY: _blurAnimation.value,
                  ),
                  child: Container(
                    color: Colors.black.withValues(
                      alpha: _backdropAnimation.value,
                    ),
                  ),
                ),
              ),
            ),

            // Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(
                  0,
                  _slideAnimation.value * AppAnimations.sheetSlideOffset.dy,
                ),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  alignment: Alignment.bottomCenter,
                  child: AnimatedBottomSheet(
                    initialHeight: widget.initialHeight,
                    maxHeight: widget.maxHeight,
                    showDragHandle: widget.showDragHandle,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Modal dialog için wrapper
class AnimatedModal extends StatefulWidget {
  final Widget child;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const AnimatedModal({
    super.key,
    required this.child,
    this.showCloseButton = true,
    this.onClose,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool showCloseButton = true,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: AppAnimations.medium,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _AnimatedModalWrapper(
          animation: animation,
          showCloseButton: showCloseButton,
          child: child,
        );
      },
    );
  }

  @override
  State<AnimatedModal> createState() => _AnimatedModalState();
}

class _AnimatedModalState extends State<AnimatedModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showCloseButton)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(PhosphorIconsDuotone.x, color: context.appColors.textSecondary),
                onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
              ),
            ),
          widget.child,
        ],
      ),
    );
  }
}

class _AnimatedModalWrapper extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final bool showCloseButton;

  const _AnimatedModalWrapper({
    required this.animation,
    required this.child,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: AppAnimations.standardCurve,
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, _) {
        return Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: curvedAnimation.value * AppAnimations.backdropBlur,
                    sigmaY: curvedAnimation.value * AppAnimations.backdropBlur,
                  ),
                  child: Container(
                    color: Colors.black.withValues(
                      alpha: curvedAnimation.value * AppAnimations.backdropOpacity,
                    ),
                  ),
                ),
              ),
            ),

            // Modal
            Center(
              child: Transform.scale(
                scale: 0.8 + (0.2 * curvedAnimation.value),
                child: Opacity(
                  opacity: curvedAnimation.value,
                  child: AnimatedModal(
                    showCloseButton: showCloseButton,
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
