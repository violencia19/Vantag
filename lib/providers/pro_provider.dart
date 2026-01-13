import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for Pro subscription status
class ProProvider extends ChangeNotifier {
  static const _keyIsPro = 'is_pro_user';

  bool _isPro = false;
  bool _isLoading = true;

  bool get isPro => _isPro;
  bool get isLoading => _isLoading;

  /// Initialize and load Pro status from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isPro = prefs.getBool(_keyIsPro) ?? false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set Pro status (called after successful purchase)
  Future<void> setPro(bool value) async {
    _isPro = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPro, value);
  }

  /// Toggle Pro status (for testing)
  Future<void> togglePro() async {
    await setPro(!_isPro);
  }
}
