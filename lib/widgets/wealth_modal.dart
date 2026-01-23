import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Premium Modal Bottom Sheet - Wealth Coach
/// Glassmorphism design, haptic feedback, golden glow effect
class WealthModal extends StatefulWidget {
  final String title;
  final Widget child;
  final VoidCallback? onSave;
  final bool Function()? isDirty;
  final VoidCallback? onClose;

  const WealthModal({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.isDirty,
    this.onClose,
  });

  @override
  State<WealthModal> createState() => _WealthModalState();
}

class _WealthModalState extends State<WealthModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showGoldenGlow = false;

  @override
  void initState() {
    super.initState();
    // Content fade-in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Start fade-in with 200ms delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Trigger Golden Glow effect
  void triggerGoldenGlow() {
    setState(() => _showGoldenGlow = true);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showGoldenGlow = false);
    });
  }

  /// Close control - show dialog if there are changes
  Future<bool> _handleWillPop() async {
    if (widget.isDirty?.call() ?? false) {
      final l10n = AppLocalizations.of(context);
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _UnsavedChangesDialog(l10n: l10n),
      );

      switch (result) {
        case 'save':
          widget.onSave?.call();
          return true;
        case 'discard':
          return true;
        case 'cancel':
        default:
          return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: context.appColors.surface.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: _showGoldenGlow
                      ? const Color(0xFFFFD700)
                      : Colors.white.withValues(alpha: 0.1),
                  width: _showGoldenGlow ? 2 : 1,
                ),
                boxShadow: _showGoldenGlow
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.appColors.textTertiary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Close button
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final shouldClose = await _handleWillPop();
                            if (shouldClose && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: context.appColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              PhosphorIconsDuotone.x,
                              size: 20,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content with fade animation
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Unsaved changes dialog
class _UnsavedChangesDialog extends StatelessWidget {
  final AppLocalizations l10n;

  const _UnsavedChangesDialog({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.appColors.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    PhosphorIconsDuotone.warningCircle,
                    color: Color(0xFFFFD700),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.unsavedChanges,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.unsavedChangesConfirm,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    // Discard
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop('discard');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: context.appColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.discardChanges,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Save
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop('save');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.primary,
                          foregroundColor: context.appColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.save,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Cancel
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop('cancel');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: context.appColors.textSecondary,
                  ),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Global key for accessing WealthModal state (for golden glow trigger)
final wealthModalKey = GlobalKey<_WealthModalState>();

/// Show Premium Modal Bottom Sheet
///
/// [title] - Modal title
/// [child] - Modal content
/// [isDirty] - Form change control (for dialog when closing)
/// [onSave] - Save callback
///
/// Returns: Result when modal closes (true: saved, false: cancelled)
Future<T?> showWealthModal<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  bool Function()? isDirty,
  VoidCallback? onSave,
}) async {
  // Haptic feedback when modal opens
  HapticFeedback.lightImpact();

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 350),
    ),
    builder: (context) => WealthModal(
      key: wealthModalKey,
      title: title,
      isDirty: isDirty,
      onSave: onSave,
      child: child,
    ),
  );
}

/// Trigger Golden Glow effect (for external access)
void triggerWealthModalGlow() {
  wealthModalKey.currentState?.triggerGoldenGlow();
}
