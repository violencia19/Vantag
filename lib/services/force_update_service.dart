import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../theme/theme.dart';
import 'package:vantag/l10n/app_localizations.dart';

/// Service for checking and enforcing app updates
class ForceUpdateService {
  static final ForceUpdateService _instance = ForceUpdateService._internal();
  factory ForceUpdateService() => _instance;
  ForceUpdateService._internal();

  static const String _currentVersion = '1.0.3';
  static const String _minVersionKey = 'min_app_version';
  static const String _recommendedVersionKey = 'recommended_app_version';

  // A/B Test flags
  static const String _paywallVariantKey = 'paywall_variant';
  static const String _onboardingShortKey = 'onboarding_short';

  late final FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Set defaults
      await _remoteConfig.setDefaults({
        _minVersionKey: '1.0.0',
        _recommendedVersionKey: '1.0.3',
        _paywallVariantKey: 'default',
        _onboardingShortKey: false,
      });

      // Fetch and activate
      await _remoteConfig.fetchAndActivate();

      _isInitialized = true;
      debugPrint('[ForceUpdate] Initialized - min: ${_remoteConfig.getString(_minVersionKey)}');
    } catch (e) {
      debugPrint('[ForceUpdate] Initialization error: $e');
    }
  }

  /// Check if current version is below minimum
  bool get isUpdateRequired {
    if (!_isInitialized) return false;

    final minVersion = _remoteConfig.getString(_minVersionKey);
    return _compareVersions(_currentVersion, minVersion) < 0;
  }

  /// Check if there's a recommended update
  bool get isUpdateRecommended {
    if (!_isInitialized) return false;

    final recommendedVersion = _remoteConfig.getString(_recommendedVersionKey);
    return _compareVersions(_currentVersion, recommendedVersion) < 0;
  }

  // A/B Test getters
  String get paywallVariant => _isInitialized
      ? _remoteConfig.getString(_paywallVariantKey)
      : 'default';

  bool get isOnboardingShort => _isInitialized
      ? _remoteConfig.getBool(_onboardingShortKey)
      : false;

  /// Compare version strings (returns -1 if v1 < v2, 0 if equal, 1 if v1 > v2)
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }
    return 0;
  }

  /// Show force update dialog
  static Future<void> showUpdateDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: context.appColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: context.appColors.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.arrowsClockwise,
                    size: 36,
                    color: context.appColors.warning,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  l10n.updateRequired,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  l10n.updateRequiredMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: context.appColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openStore(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.updateNow,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _openStore() async {
    final url = Platform.isIOS
        ? 'https://apps.apple.com/app/id6740157696'
        : 'https://play.google.com/store/apps/details?id=com.vantag.app';

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

/// Global instance
final forceUpdateService = ForceUpdateService();
