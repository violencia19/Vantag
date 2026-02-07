import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data
/// Uses iOS Keychain / Android EncryptedSharedPreferences
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // Storage keys
  static const String _keyPinHash = 'pin_hash';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyDeviceToken = 'device_token';
  static const String _keyRefreshToken = 'refresh_token';

  // iOS Keychain options for maximum security
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  // Android encrypted shared preferences
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final _storage = const FlutterSecureStorage(
    iOptions: _iosOptions,
    aOptions: _androidOptions,
  );

  // ─────────────────────────────────────────────────────────────────
  // GENERIC METHODS
  // ─────────────────────────────────────────────────────────────────

  /// Write a value securely
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('[SecureStorage] Write error for key $key');
    }
  }

  /// Read a value securely
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('[SecureStorage] Read error for key $key');
      return null;
    }
  }

  /// Delete a value
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('[SecureStorage] Delete error for key $key');
    }
  }

  /// Delete all stored values
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('[SecureStorage] DeleteAll error');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // PIN STORAGE
  // ─────────────────────────────────────────────────────────────────

  /// Save PIN hash securely
  Future<void> savePinHash(String hash) async {
    await write(_keyPinHash, hash);
  }

  /// Get PIN hash
  Future<String?> getPinHash() async {
    return await read(_keyPinHash);
  }

  /// Delete PIN hash
  Future<void> deletePinHash() async {
    await delete(_keyPinHash);
  }

  /// Check if PIN is set
  Future<bool> hasPinSet() async {
    final hash = await getPinHash();
    return hash != null && hash.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────────
  // TOKEN STORAGE
  // ─────────────────────────────────────────────────────────────────

  /// Save FCM token securely
  Future<void> saveFcmToken(String token) async {
    await write(_keyFcmToken, token);
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    return await read(_keyFcmToken);
  }

  /// Save device token securely
  Future<void> saveDeviceToken(String token) async {
    await write(_keyDeviceToken, token);
  }

  /// Get device token
  Future<String?> getDeviceToken() async {
    return await read(_keyDeviceToken);
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await write(_keyRefreshToken, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await read(_keyRefreshToken);
  }
}

/// Global instance for easy access
final secureStorage = SecureStorageService();
