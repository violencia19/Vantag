import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Centralized Lottie animation widgets for consistent app-wide usage
class LottieAnimations {
  // Asset paths
  static const String _celebration = 'assets/animations/celebration.json';
  static const String _success = 'assets/animations/success.json';
  static const String _coin = 'assets/animations/coin.json';
  static const String _empty = 'assets/animations/empty.json';
  static const String _loading = 'assets/animations/loading.json';

  /// Celebration animation for pursuit completion, achievements
  static Widget celebration({
    double size = 200,
    bool repeat = false,
    BoxFit fit = BoxFit.contain,
    AnimationController? controller,
  }) {
    return Lottie.asset(
      _celebration,
      width: size,
      height: size,
      repeat: repeat,
      fit: fit,
      controller: controller,
    );
  }

  /// Success checkmark animation for confirmations
  static Widget success({
    double size = 80,
    bool repeat = false,
    VoidCallback? onComplete,
  }) {
    return Lottie.asset(
      _success,
      width: size,
      height: size,
      repeat: repeat,
      onLoaded: onComplete != null
          ? (composition) {
              Future.delayed(composition.duration, onComplete);
            }
          : null,
    );
  }

  /// Coin/money animation for savings, rewards
  static Widget coin({
    double size = 60,
    bool repeat = true,
  }) {
    return Lottie.asset(
      _coin,
      width: size,
      height: size,
      repeat: repeat,
    );
  }

  /// Empty state animation when no data
  static Widget emptyState({
    double size = 150,
    bool repeat = true,
  }) {
    return Lottie.asset(
      _empty,
      width: size,
      height: size,
      repeat: repeat,
    );
  }

  /// Loading animation for async operations
  static Widget loading({
    double size = 50,
    Color? color,
  }) {
    final widget = Lottie.asset(
      _loading,
      width: size,
      height: size,
      repeat: true,
    );

    if (color != null) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: widget,
      );
    }
    return widget;
  }

  /// Shows a success animation dialog that auto-dismisses
  static Future<void> showSuccessOverlay(
    BuildContext context, {
    double size = 120,
    Duration? duration,
  }) async {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Lottie.asset(
          _success,
          width: size,
          height: size,
          repeat: false,
          onLoaded: (composition) {
            final dismissDuration = duration ?? composition.duration;
            Future.delayed(dismissDuration, () {
              if (navigator.canPop()) {
                navigator.pop();
              }
            });
          },
        ),
      ),
    );
  }

  /// Full-screen celebration overlay
  static Widget celebrationOverlay({
    bool repeat = false,
  }) {
    return IgnorePointer(
      child: Lottie.asset(
        _celebration,
        repeat: repeat,
        fit: BoxFit.cover,
      ),
    );
  }
}
