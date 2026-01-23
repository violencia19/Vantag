import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme modes supported by the app
enum AppThemeMode { dark, light, system }

/// Provider for managing app theme (dark/light mode)
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

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
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Whether dark mode is currently active
  bool isDarkMode(BuildContext context) {
    if (_themeMode == AppThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }

  /// Initialize theme from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => AppThemeMode.dark,
      );
    }

    _isInitialized = true;
    notifyListeners();
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

  /// Get theme mode display name
  String getThemeModeName(BuildContext context, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.system:
        return 'System';
    }
  }
}
