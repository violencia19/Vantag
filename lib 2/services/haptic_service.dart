import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized haptic feedback service with standardized patterns
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  static const _keyEnabled = 'haptic_enabled';
  bool _enabled = true;

  bool get enabled => _enabled;

  /// Initialize service
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_keyEnabled) ?? true;
  }

  /// Toggle haptic feedback
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value);
  }

  // ==================== STANDARD PATTERNS ====================

  /// Light tap - for small interactions (toggles, selections)
  void tap() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Selection click - for list/grid item selections
  void selection() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Light impact - for button presses
  void light() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Medium impact - for confirmations, transitions
  void medium() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for important actions, warnings
  void heavy() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  // ==================== SEMANTIC PATTERNS ====================

  /// Success feedback - double tap pattern
  void success() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Error feedback - heavy single
  void error() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Warning feedback - double heavy
  void warning() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      HapticFeedback.heavyImpact();
    });
  }

  /// Notification feedback - light triple
  void notification() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 80), () {
      HapticFeedback.selectionClick();
    });
    Future.delayed(const Duration(milliseconds: 160), () {
      HapticFeedback.lightImpact();
    });
  }

  // ==================== CONTEXTUAL PATTERNS ====================

  /// Button press feedback
  void buttonPress() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Navigation change
  void navigation() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Pull to refresh
  void refresh() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Swipe action
  void swipe() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Delete action
  void delete() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Achievement unlocked
  void achievement() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Celebration (confetti, victory)
  void celebrate() {
    if (!_enabled) return;
    // Rapid succession of light taps
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        HapticFeedback.lightImpact();
      });
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedback.mediumImpact();
    });
  }

  /// Slider tick
  void tick() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Modal open
  void modalOpen() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Modal close
  void modalClose() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Long press start
  void longPressStart() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Drag start
  void dragStart() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Drag end / drop
  void dragEnd() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }
}

/// Global instance for easy access
final haptics = HapticService();
