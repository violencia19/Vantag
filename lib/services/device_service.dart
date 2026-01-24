import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device token mismatch result
enum DeviceCheckResult {
  /// Token matches - this is the active device
  valid,

  /// Token doesn't match - logged in from another device
  anotherDeviceLoggedIn,

  /// No user logged in
  notLoggedIn,

  /// Error occurred during check
  error,
}

/// Service for single device policy enforcement
/// Ensures only one device can be logged in at a time per user
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  static const String _deviceTokenKey = 'device_token';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _cachedDeviceToken;

  /// Get or generate a unique device token for this device
  Future<String> getDeviceToken() async {
    // Return cached token if available
    if (_cachedDeviceToken != null) {
      return _cachedDeviceToken!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_deviceTokenKey);

    // Generate new token if not exists
    if (token == null || token.isEmpty) {
      token = _generateDeviceToken();
      await prefs.setString(_deviceTokenKey, token);
      debugPrint('📱 [Device] New device token generated: ${token.substring(0, 8)}...');
    }

    _cachedDeviceToken = token;
    return token;
  }

  /// Generate a unique device token
  String _generateDeviceToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    return '${platform}_${timestamp}_$random';
  }

  /// Register this device as the active device for the user
  /// Call this after successful login
  Future<void> registerDevice() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('⚠️ [Device] No user to register device for');
      return;
    }

    try {
      final deviceToken = await getDeviceToken();

      await _firestore.collection('users').doc(user.uid).set({
        'currentDevice': deviceToken,
        'lastDeviceLoginAt': FieldValue.serverTimestamp(),
        'devicePlatform': Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other'),
      }, SetOptions(merge: true));

      debugPrint('✅ [Device] Device registered for user ${user.uid.substring(0, 8)}...');
    } catch (e) {
      debugPrint('❌ [Device] Failed to register device: $e');
    }
  }

  /// Check if this device is still the active device for the user
  /// Returns DeviceCheckResult indicating the status
  Future<DeviceCheckResult> checkDeviceStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      return DeviceCheckResult.notLoggedIn;
    }

    // Skip check for anonymous users
    if (user.isAnonymous) {
      return DeviceCheckResult.valid;
    }

    try {
      final deviceToken = await getDeviceToken();
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        // No Firestore record yet, register this device
        await registerDevice();
        return DeviceCheckResult.valid;
      }

      final data = doc.data();
      final serverToken = data?['currentDevice'] as String?;

      if (serverToken == null) {
        // No device registered, register this one
        await registerDevice();
        return DeviceCheckResult.valid;
      }

      if (serverToken == deviceToken) {
        debugPrint('✅ [Device] Device token matches - this is the active device');
        return DeviceCheckResult.valid;
      } else {
        debugPrint('⚠️ [Device] Device token mismatch!');
        debugPrint('   Local: ${deviceToken.substring(0, 8)}...');
        debugPrint('   Server: ${serverToken.substring(0, 8)}...');
        return DeviceCheckResult.anotherDeviceLoggedIn;
      }
    } catch (e) {
      debugPrint('❌ [Device] Error checking device status: $e');
      return DeviceCheckResult.error;
    }
  }

  /// Clear device token from Firestore on sign out
  Future<void> clearDeviceOnSignOut() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final deviceToken = await getDeviceToken();
      final doc = await _firestore.collection('users').doc(user.uid).get();

      // Only clear if this device is the current one
      // (don't clear if we're being kicked out by another device)
      final serverToken = doc.data()?['currentDevice'] as String?;
      if (serverToken == deviceToken) {
        await _firestore.collection('users').doc(user.uid).update({
          'currentDevice': FieldValue.delete(),
          'lastDeviceLoginAt': FieldValue.delete(),
        });
        debugPrint('✅ [Device] Device token cleared from Firestore');
      }
    } catch (e) {
      debugPrint('⚠️ [Device] Failed to clear device token: $e');
    }
  }

  /// Listen to device changes in real-time
  /// Returns a stream that emits true when another device logs in
  Stream<bool> watchDeviceChanges() {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists) return false;

      final serverToken = snapshot.data()?['currentDevice'] as String?;
      if (serverToken == null) return false;

      final localToken = await getDeviceToken();
      return serverToken != localToken;
    });
  }
}
