import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage Simple Mode functionality
/// Simple Mode provides a streamlined experience with essential features only
class SimpleModeService extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const String _keySimpleModeEnabled = 'simple_mode_enabled';

  /// Top 5 essential categories for simple mode
  static const List<String> simpleModeCategories = [
    'food', // Yemek
    'transport', // Ulaşım
    'shopping', // Alışveriş
    'bills', // Faturalar
    'entertainment', // Eğlence
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // SINGLETON
  // ═══════════════════════════════════════════════════════════════════════════

  static final SimpleModeService _instance = SimpleModeService._internal();
  factory SimpleModeService() => _instance;
  SimpleModeService._internal();

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════════

  bool _isEnabled = false;
  bool _isInitialized = false;

  /// Whether simple mode is currently enabled
  bool get isEnabled => _isEnabled;

  /// Whether the service has been initialized
  bool get isInitialized => _isInitialized;

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Initialize the service and load saved state
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_keySimpleModeEnabled) ?? false;
    _isInitialized = true;
    notifyListeners();
    debugPrint('[SimpleModeService] Initialized: isEnabled=$_isEnabled');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOGGLE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Enable or disable simple mode
  Future<void> setEnabled(bool value) async {
    if (_isEnabled == value) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySimpleModeEnabled, value);
    _isEnabled = value;
    notifyListeners();
    debugPrint(
      '[SimpleModeService] Simple mode ${value ? 'enabled' : 'disabled'}',
    );
  }

  /// Toggle simple mode on/off
  Future<void> toggle() async {
    await setEnabled(!_isEnabled);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE FLAGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Whether AI Chat should be shown
  /// Simple mode hides AI chat completely
  bool get showAiChat => !_isEnabled;

  /// Whether to show full dashboard stats
  /// Simple mode shows only today's work hours
  bool get showFullDashboard => !_isEnabled;

  /// Whether to show all categories
  /// Simple mode shows only top 5 categories
  bool get showAllCategories => !_isEnabled;

  /// Get available categories based on mode
  List<String> getAvailableCategories(List<String> allCategories) {
    if (!_isEnabled) return allCategories;
    // Filter to only simple mode categories, maintaining order
    return simpleModeCategories
        .where((cat) => allCategories.contains(cat))
        .toList();
  }

  /// Whether to show advanced report periods
  /// Simple mode only shows weekly reports
  bool get showAdvancedReports => !_isEnabled;

  /// Whether multiple pursuits are allowed
  /// Simple mode limits to 1 pursuit
  bool get allowMultiplePursuits => !_isEnabled;

  // ═══════════════════════════════════════════════════════════════════════════
  // DEBUG
  // ═══════════════════════════════════════════════════════════════════════════

  /// Reset to default state (for testing)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySimpleModeEnabled);
    _isEnabled = false;
    notifyListeners();
    debugPrint('[SimpleModeService] Reset to default');
  }
}

/// Global instance for easy access
final simpleModeService = SimpleModeService();
