import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Accessibility preferences and utilities
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  static const _keyHighContrast = 'a11y_high_contrast';
  static const _keyLargeText = 'a11y_large_text';
  static const _keyReduceMotion = 'a11y_reduce_motion';
  static const _keyReduceTransparency = 'a11y_reduce_transparency';

  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  bool _reduceMotionEnabled = false;
  bool _reduceTransparencyEnabled = false;

  bool get highContrastEnabled => _highContrastEnabled;
  bool get largeTextEnabled => _largeTextEnabled;
  bool get reduceMotionEnabled => _reduceMotionEnabled;
  bool get reduceTransparencyEnabled => _reduceTransparencyEnabled;

  /// Initialize service and load preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _highContrastEnabled = prefs.getBool(_keyHighContrast) ?? false;
    _largeTextEnabled = prefs.getBool(_keyLargeText) ?? false;
    _reduceMotionEnabled = prefs.getBool(_keyReduceMotion) ?? false;
    _reduceTransparencyEnabled = prefs.getBool(_keyReduceTransparency) ?? false;
  }

  Future<void> setHighContrast(bool value) async {
    _highContrastEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHighContrast, value);
  }

  Future<void> setLargeText(bool value) async {
    _largeTextEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLargeText, value);
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotionEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReduceMotion, value);
  }

  Future<void> setReduceTransparency(bool value) async {
    _reduceTransparencyEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReduceTransparency, value);
  }

  // ==================== SEMANTIC HELPERS ====================

  /// Get animation duration based on reduce motion setting
  Duration getAnimationDuration(Duration normal) {
    if (_reduceMotionEnabled) {
      return Duration.zero;
    }
    return normal;
  }

  /// Get blur amount based on reduce transparency setting
  double getBlurAmount(double normal) {
    if (_reduceTransparencyEnabled) {
      return 0;
    }
    return normal;
  }

  /// Get opacity based on reduce transparency setting
  double getOpacity(double normal) {
    if (_reduceTransparencyEnabled) {
      return 1.0;
    }
    return normal;
  }

  /// Get text scale factor
  double getTextScaleFactor() {
    if (_largeTextEnabled) {
      return 1.2;
    }
    return 1.0;
  }

  /// Get contrasted color
  Color getContrastedColor(Color color, {Color? highContrastColor}) {
    if (_highContrastEnabled) {
      return highContrastColor ?? _increaseContrast(color);
    }
    return color;
  }

  Color _increaseContrast(Color color) {
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness > 0.5) {
      return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
    } else {
      return hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
    }
  }
}

/// Global instance
final a11y = AccessibilityService();

// ==================== SEMANTIC WRAPPER WIDGETS ====================

/// Wrapper for semantic labeling
class SemanticLabel extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final bool button;
  final bool header;
  final bool link;
  final VoidCallback? onTap;

  const SemanticLabel({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.button = false,
    this.header = false,
    this.link = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      header: header,
      link: link,
      onTap: onTap,
      child: child,
    );
  }
}

/// Wrapper for buttons with semantic labels
class SemanticButton extends StatelessWidget {
  final Widget child;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const SemanticButton({
    super.key,
    required this.child,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      child: child,
    );
  }
}

/// Wrapper for value displays (currency, numbers)
class SemanticValue extends StatelessWidget {
  final Widget child;
  final String value;
  final String? label;
  final bool increasedValue;
  final bool decreasedValue;

  const SemanticValue({
    super.key,
    required this.child,
    required this.value,
    this.label,
    this.increasedValue = false,
    this.decreasedValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: value,
      label: label,
      increasedValue: increasedValue ? value : null,
      decreasedValue: decreasedValue ? value : null,
      child: ExcludeSemantics(child: child),
    );
  }
}

/// Wrapper for progress indicators
class SemanticProgress extends StatelessWidget {
  final Widget child;
  final double value; // 0.0 - 1.0
  final String? label;

  const SemanticProgress({
    super.key,
    required this.child,
    required this.value,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return Semantics(
      label: label ?? 'Progress',
      value: '$percent%',
      child: ExcludeSemantics(child: child),
    );
  }
}

/// Wrapper for images with descriptions
class SemanticImage extends StatelessWidget {
  final Widget child;
  final String description;
  final bool decorative;

  const SemanticImage({
    super.key,
    required this.child,
    required this.description,
    this.decorative = false,
  });

  @override
  Widget build(BuildContext context) {
    if (decorative) {
      return ExcludeSemantics(child: child);
    }
    return Semantics(
      image: true,
      label: description,
      child: child,
    );
  }
}

/// Wrapper for list items
class SemanticListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final int total;
  final String? label;

  const SemanticListItem({
    super.key,
    required this.child,
    required this.index,
    required this.total,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label != null ? '$label, ${index + 1} of $total' : '${index + 1} of $total',
      child: child,
    );
  }
}

/// Wrapper for toggleable controls
class SemanticToggle extends StatelessWidget {
  final Widget child;
  final String label;
  final bool toggled;
  final VoidCallback? onTap;

  const SemanticToggle({
    super.key,
    required this.child,
    required this.label,
    required this.toggled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      toggled: toggled,
      onTap: onTap,
      child: child,
    );
  }
}

/// Live region for announcements
class SemanticAnnouncement extends StatelessWidget {
  final Widget child;
  final String? announcement;
  final bool liveRegion;

  const SemanticAnnouncement({
    super.key,
    required this.child,
    this.announcement,
    this.liveRegion = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: liveRegion,
      label: announcement,
      child: child,
    );
  }
}

// ==================== HELPER FUNCTIONS ====================

/// Announce a message to screen readers
void announceToScreenReader(BuildContext context, String message) {
  SemanticsService.announce(message, TextDirection.ltr);
}

/// Check if screen reader is enabled
bool isScreenReaderEnabled(BuildContext context) {
  return MediaQuery.of(context).accessibleNavigation;
}

/// Check if reduce motion is enabled in system
bool isReduceMotionEnabled(BuildContext context) {
  return MediaQuery.of(context).disableAnimations;
}

/// Check if high contrast is enabled in system
bool isHighContrastEnabled(BuildContext context) {
  return MediaQuery.of(context).highContrast;
}

/// Check if bold text is enabled in system
bool isBoldTextEnabled(BuildContext context) {
  return MediaQuery.of(context).boldText;
}
