import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/services/purchase_service.dart';

/// Provider for Pro subscription status (RevenueCat integrated)
class ProProvider extends ChangeNotifier {
  static const _keyIsPro = 'is_pro_user';

  bool _isPro = false;
  bool _isLoading = true;
  StreamSubscription<bool>? _proStatusSubscription;

  bool get isPro => _isPro;
  bool get isLoading => _isLoading;

  /// Initialize and load Pro status from RevenueCat
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check RevenueCat entitlement
      _isPro = await PurchaseService().checkProStatus();

      // Fallback to local storage if RevenueCat fails
      if (!_isPro) {
        final prefs = await SharedPreferences.getInstance();
        _isPro = prefs.getBool(_keyIsPro) ?? false;
      }

      // Listen to RevenueCat status changes
      _proStatusSubscription = PurchaseService().proStatusStream.listen((isPro) {
        _setPro(isPro);
      });
    } catch (e) {
      debugPrint('ProProvider initialization error: $e');
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      _isPro = prefs.getBool(_keyIsPro) ?? false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Internal setter (called from RevenueCat stream)
  void _setPro(bool value) {
    if (_isPro != value) {
      _isPro = value;
      notifyListeners();
      _persistProStatus(value);
    }
  }

  /// Persist Pro status to local storage (backup)
  Future<void> _persistProStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPro, value);
  }

  /// Set Pro status (called after successful purchase)
  Future<void> setPro(bool value) async {
    _isPro = value;
    notifyListeners();
    await _persistProStatus(value);
  }

  /// Toggle Pro status (for testing only)
  Future<void> togglePro() async {
    await setPro(!_isPro);
  }

  /// Refresh Pro status from RevenueCat
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isPro = await PurchaseService().checkProStatus();
    } catch (e) {
      debugPrint('ProProvider refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _proStatusSubscription?.cancel();
    super.dispose();
  }
}
