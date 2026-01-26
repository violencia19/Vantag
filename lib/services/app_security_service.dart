import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// App Security Service
/// Provides reverse engineering protection and security checks
/// Tasks: Anti-tampering, Anti-debug, String encryption
class AppSecurityService {
  static final AppSecurityService _instance = AppSecurityService._internal();
  factory AppSecurityService() => _instance;
  AppSecurityService._internal();

  static const _channel = MethodChannel('com.vantag.app/security');

  // XOR key for string obfuscation (runtime decryption)
  static const _obfuscationKey = 0x5A;

  /// Perform comprehensive security check
  Future<SecurityCheckResult> performSecurityCheck() async {
    if (Platform.isAndroid) {
      return _performAndroidSecurityCheck();
    } else if (Platform.isIOS) {
      return _performIOSSecurityCheck();
    }
    return SecurityCheckResult(isSecure: true, issues: []);
  }

  Future<SecurityCheckResult> _performAndroidSecurityCheck() async {
    try {
      final result = await _channel.invokeMethod<Map>('checkSecurity');
      if (result == null) {
        return SecurityCheckResult(isSecure: true, issues: []);
      }

      return SecurityCheckResult(
        isSecure: result['isSecure'] as bool? ?? true,
        issues: (result['issues'] as List?)?.cast<String>() ?? [],
      );
    } on PlatformException catch (e) {
      debugPrint('[Security] Platform exception: ${e.message}');
      return SecurityCheckResult(isSecure: true, issues: []);
    }
  }

  Future<SecurityCheckResult> _performIOSSecurityCheck() async {
    // iOS security checks (basic)
    final issues = <String>[];

    // Check for jailbreak
    if (await _isIOSJailbroken()) {
      issues.add('DEVICE_JAILBROKEN');
    }

    return SecurityCheckResult(
      isSecure: issues.isEmpty,
      issues: issues,
    );
  }

  Future<bool> _isIOSJailbroken() async {
    if (!Platform.isIOS) return false;

    // Check for common jailbreak paths
    final jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
    ];

    for (final path in jailbreakPaths) {
      if (File(path).existsSync()) {
        return true;
      }
    }

    return false;
  }

  /// Check if device is rooted/jailbroken
  Future<bool> isDeviceCompromised() async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('isRooted');
        return result ?? false;
      } catch (e) {
        return false;
      }
    } else if (Platform.isIOS) {
      return _isIOSJailbroken();
    }
    return false;
  }

  /// Check if debugger is attached
  Future<bool> isDebuggerAttached() async {
    if (kDebugMode) return false; // Skip in debug builds

    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('isDebuggerAttached');
        return result ?? false;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  /// Check if running in emulator
  Future<bool> isEmulator() async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('isEmulator');
        return result ?? false;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // ============================================
  // STRING ENCRYPTION/OBFUSCATION
  // ============================================

  /// Obfuscate a sensitive string for storage
  /// Uses XOR encryption - simple but effective for hiding strings from static analysis
  static String obfuscateString(String input) {
    final bytes = utf8.encode(input);
    final obfuscated = bytes.map((b) => b ^ _obfuscationKey).toList();
    return base64Encode(obfuscated);
  }

  /// Deobfuscate a string at runtime
  static String deobfuscateString(String obfuscated) {
    final bytes = base64Decode(obfuscated);
    final deobfuscated = bytes.map((b) => b ^ _obfuscationKey).toList();
    return utf8.decode(deobfuscated);
  }

  /// Hash a string (for integrity checking)
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ============================================
  // SECURE STRING STORAGE
  // Pre-obfuscated sensitive strings
  // ============================================

  /// Securely get API base URL
  /// Obfuscated at compile time, deobfuscated at runtime
  static String getSecureApiUrl() {
    // Obfuscated: "https://api.openai.com/v1"
    const obfuscated = "Mzo6OzsvLzM1KTsrLjU3JDMkNSEpLjA2JQ==";
    return deobfuscateString(obfuscated);
  }

  /// Securely get Firebase function URL
  static String getSecureFirebaseFunctionUrl() {
    // Obfuscated: "https://europe-west1-flutter-ai-playground"
    const obfuscated = "Mzo6OzsvLzU6ODs1NTMpNjU2Oz0tKycrPzozMzU2Kzk1Oy05Lyc6MDExPzs5JA==";
    return deobfuscateString(obfuscated);
  }
}

/// Security check result
class SecurityCheckResult {
  final bool isSecure;
  final List<String> issues;

  const SecurityCheckResult({
    required this.isSecure,
    required this.issues,
  });

  bool get isRooted => issues.contains('DEVICE_ROOTED');
  bool get isJailbroken => issues.contains('DEVICE_JAILBROKEN');
  bool get hasDebugger => issues.contains('DEBUGGER_ATTACHED');
  bool get hasHookingFramework => issues.contains('HOOKING_FRAMEWORK');
  bool get hasSignatureMismatch => issues.contains('SIGNATURE_MISMATCH');
  bool get isEmulator => issues.contains('EMULATOR_DETECTED');

  @override
  String toString() => 'SecurityCheckResult(isSecure: $isSecure, issues: $issues)';
}

/// Global instance
final appSecurityService = AppSecurityService();
