import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/services/purchase_service.dart';

/// Provider for Pro subscription status (RevenueCat + Firestore promo override)
class ProProvider extends ChangeNotifier {
  static const _keyIsPro = 'is_pro_user';
  static const _keyIsPromo = 'is_promo_user';

  bool _isPro = false;
  bool _isPromo = false; // Firestore promo_users override
  bool _isLoading = true;
  String? _promoType; // "gift", "tester", "influencer"
  StreamSubscription<bool>? _proStatusSubscription;
  StreamSubscription<DocumentSnapshot>? _promoSubscription;

  bool get isPro => _isPro || _isPromo;
  bool get isPromo => _isPromo;
  String? get promoType => _promoType;
  bool get isLoading => _isLoading;

  /// Initialize and load Pro status from RevenueCat + Firestore
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check RevenueCat entitlement
      _isPro = await PurchaseService().checkProStatus();

      // 2. Check Firestore promo_users collection
      await _checkPromoStatus();

      // Fallback to local storage if both fail
      if (!_isPro && !_isPromo) {
        final prefs = await SharedPreferences.getInstance();
        _isPro = prefs.getBool(_keyIsPro) ?? false;
        _isPromo = prefs.getBool(_keyIsPromo) ?? false;
      }

      // Listen to RevenueCat status changes
      _proStatusSubscription = PurchaseService().proStatusStream.listen((
        isPro,
      ) {
        _setPro(isPro);
      });

      // Listen to Firestore promo_users changes
      _listenToPromoStatus();
    } catch (e) {
      debugPrint('ProProvider initialization error: $e');
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      _isPro = prefs.getBool(_keyIsPro) ?? false;
      _isPromo = prefs.getBool(_keyIsPromo) ?? false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check Firestore promo_users collection for current user
  Future<void> _checkPromoStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isPromo = false;
      _promoType = null;
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('promo_users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _isPromo = true;
        _promoType = doc.data()?['type'] as String?;
        debugPrint(
          '✅ [ProProvider] Promo user found: ${user.uid}, type: $_promoType',
        );

        // Persist locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsPromo, true);
      } else {
        _isPromo = false;
        _promoType = null;
      }
    } catch (e) {
      debugPrint('❌ [ProProvider] Promo check error: $e');
      // Don't change status on error, keep previous value
    }
  }

  /// Listen to Firestore promo_users changes in real-time
  void _listenToPromoStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _promoSubscription?.cancel();
    _promoSubscription = FirebaseFirestore.instance
        .collection('promo_users')
        .doc(user.uid)
        .snapshots()
        .listen(
          (snapshot) {
            final wasPromo = _isPromo;

            if (snapshot.exists) {
              _isPromo = true;
              _promoType = snapshot.data()?['type'] as String?;
            } else {
              _isPromo = false;
              _promoType = null;
            }

            if (wasPromo != _isPromo) {
              debugPrint('🔄 [ProProvider] Promo status changed: $_isPromo');
              notifyListeners();
              _persistPromoStatus(_isPromo);
            }
          },
          onError: (e) {
            debugPrint('❌ [ProProvider] Promo listener error: $e');
          },
        );
  }

  /// Persist promo status to local storage
  Future<void> _persistPromoStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPromo, value);
  }

  /// Internal setter for RevenueCat status
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

  /// Refresh Pro status from RevenueCat + Firestore
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isPro = await PurchaseService().checkProStatus();
      await _checkPromoStatus();
    } catch (e) {
      debugPrint('ProProvider refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called when user logs in - re-check promo status
  Future<void> onUserLogin() async {
    await _checkPromoStatus();
    _listenToPromoStatus();
    notifyListeners();
  }

  /// Called when user logs out - clear promo status
  Future<void> onUserLogout() async {
    _promoSubscription?.cancel();
    _isPromo = false;
    _promoType = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPromo, false);

    notifyListeners();
  }

  @override
  void dispose() {
    _proStatusSubscription?.cancel();
    _promoSubscription?.cancel();
    super.dispose();
  }
}
