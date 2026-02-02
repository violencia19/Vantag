import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';

/// App lock service with PIN and biometric authentication
class LockService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _lockEnabledKey = 'lock_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinSaltKey = 'pin_salt';

  // ============================================================
  // BIOMETRIC METHODS
  // ============================================================

  /// Check if device supports biometrics
  static Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint('[LockService] Error checking biometrics: $e');
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('[LockService] Error getting biometrics: $e');
      return [];
    }
  }

  /// Check if Face ID is available (iOS)
  static Future<bool> hasFaceId() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Check if fingerprint is available
  static Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint) ||
        biometrics.contains(BiometricType.strong) ||
        biometrics.contains(BiometricType.weak);
  }

  /// Authenticate with biometrics
  static Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('[LockService] Biometric auth error: $e');
      return false;
    }
  }

  // ============================================================
  // LOCK SETTINGS
  // ============================================================

  /// Check if lock is enabled
  static Future<bool> isLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lockEnabledKey) ?? false;
  }

  /// Enable/disable lock
  static Future<void> setLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockEnabledKey, enabled);
  }

  /// Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable/disable biometric
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  // ============================================================
  // PIN METHODS (Using Secure Storage)
  // ============================================================

  /// Generate random salt for PIN hashing
  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Hash PIN with salt using PBKDF2-like approach
  static String _hashPin(String pin, String salt) {
    // Multiple rounds for brute-force resistance
    List<int> hash = utf8.encode('$pin$salt');
    for (var i = 0; i < 10000; i++) {
      hash = sha256.convert(hash).bytes;
    }
    return base64Encode(hash);
  }

  /// Save PIN (hashed with random salt, stored in secure storage)
  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = _generateSalt();
    final hashedPin = _hashPin(pin, salt);

    // Store salt in SharedPreferences (not sensitive)
    await prefs.setString(_pinSaltKey, salt);
    // Store hash in secure storage
    await secureStorage.savePinHash(hashedPin);
  }

  /// Verify PIN
  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_pinSaltKey);
    if (salt == null) return false;

    final savedHash = await secureStorage.getPinHash();
    if (savedHash == null) return false;

    final inputHash = _hashPin(pin, salt);

    // Constant-time comparison to prevent timing attacks
    if (savedHash.length != inputHash.length) return false;
    var result = 0;
    for (var i = 0; i < savedHash.length; i++) {
      result |= savedHash.codeUnitAt(i) ^ inputHash.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Check if PIN is set
  static Future<bool> hasPinSet() async {
    return await secureStorage.hasPinSet();
  }

  /// Remove PIN and disable lock
  static Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinSaltKey);
    await secureStorage.deletePinHash();
    await prefs.setBool(_lockEnabledKey, false);
    await prefs.setBool(_biometricEnabledKey, false);
  }

  /// Change PIN
  static Future<bool> changePin(String oldPin, String newPin) async {
    final isValid = await verifyPin(oldPin);
    if (!isValid) return false;

    await setPin(newPin);
    return true;
  }
}
