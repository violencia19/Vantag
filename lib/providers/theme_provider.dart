import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme modes supported by the app
enum AppThemeMode { dark, light, automatic }

/// Provider for managing app theme (dark/light mode)
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  // Time-based automatic theme settings
  static const int _dayStartHour = 7; // 07:00 - Light mode starts
  static const int _nightStartHour = 19; // 19:00 - Dark mode starts

  AppThemeMode _themeMode = AppThemeMode.dark;
  bool _isInitialized = false;

  /// Current theme mode
  AppThemeMode get themeMode => _themeMode;

  /// Whether the provider has been initialized
  bool get isInitialized => _isInitialized;

  /// Get the current ThemeMode for MaterialApp
  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.automatic:
        // Time-based: 07:00-19:00 light, 19:00-07:00 dark
        return _isNightTime() ? ThemeMode.dark : ThemeMode.light;
    }
  }

  /// Check if current time is night time (19:00 - 07:00)
  bool _isNightTime() {
    final hour = DateTime.now().hour;
    return hour >= _nightStartHour || hour < _dayStartHour;
  }

  /// Whether dark mode is currently active
  bool isDarkMode(BuildContext context) {
    if (_themeMode == AppThemeMode.automatic) {
      return _isNightTime();
    }
    return _themeMode == AppThemeMode.dark;
  }

  /// Initialize theme from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      // Handle migration from old 'system' value to 'automatic'
      if (savedTheme == 'system') {
        _themeMode = AppThemeMode.automatic;
        await prefs.setString(_themeKey, 'automatic');
      } else {
        _themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == savedTheme,
          orElse: () => AppThemeMode.dark,
        );
      }
    }
    // Default is dark (already set in field initialization)

    _isInitialized = true;
    notifyListeners();
  }

  /// Refresh theme - call when app comes to foreground
  /// This rechecks the time for automatic mode
  void refreshTheme() {
    if (_themeMode == AppThemeMode.automatic) {
      notifyListeners();
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    final newMode = _themeMode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Get theme mode display name (deprecated - use localization instead)
  String getThemeModeName(BuildContext context, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.automatic:
        return 'Automatic';
    }
  }
}
