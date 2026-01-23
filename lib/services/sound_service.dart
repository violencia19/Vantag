import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sound effect types available in the app
enum SoundType {
  celebration, // Pursuit completed, achievement unlocked
  success, // Expense added, settings saved
  coin, // Quick add expense, money-related
  tap, // Button taps (optional)
  warning, // Spending exceeds threshold
  cashOut, // Expense confirmation
  victory, // "Vazgectim" decision
  countdown, // Timer tick
}

/// Sound effects service for key moments in the app
/// Provides audio feedback to enhance user experience
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true;
  bool _isInitialized = false;
  double _volume = 0.7;

  // SharedPreferences keys
  static const _keySoundEnabled = 'sound_enabled';
  static const _keySoundVolume = 'sound_volume';

  // Sound asset paths
  static const Map<SoundType, String> _soundPaths = {
    SoundType.celebration: 'sounds/celebration.mp3',
    SoundType.success: 'sounds/success.mp3',
    SoundType.coin: 'sounds/coin.mp3',
    SoundType.tap: 'sounds/tap.mp3',
    SoundType.warning: 'sounds/warning.mp3',
    SoundType.cashOut: 'sounds/cash_out.mp3',
    SoundType.victory: 'sounds/victory.mp3',
    SoundType.countdown: 'sounds/countdown_tick.mp3',
  };

  /// Initialize sound service - call in main.dart
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_keySoundEnabled) ?? true;
      _volume = prefs.getDouble(_keySoundVolume) ?? 0.7;

      // Configure audio player
      await _player.setReleaseMode(ReleaseMode.stop);

      _isInitialized = true;
      debugPrint(
        '[Sound] Service initialized. Enabled: $_isEnabled, Volume: $_volume',
      );
    } catch (e) {
      debugPrint('[Sound] Initialization error: $e');
      _isInitialized = true; // Mark as initialized to avoid retry loops
    }
  }

  /// Play a sound effect by type
  Future<void> play(SoundType type) async {
    if (!_isEnabled || !_isInitialized) return;

    final assetPath = _soundPaths[type];
    if (assetPath == null) return;

    try {
      await _player.stop(); // Stop any currently playing sound
      await _player.setVolume(_volume);
      await _player.play(AssetSource(assetPath));
      debugPrint('[Sound] Playing: $assetPath');
    } catch (e) {
      // Silently fail - sound is enhancement, not critical
      debugPrint('[Sound] Play error for $type: $e');
    }
  }

  // ==================== CONVENIENCE METHODS ====================

  /// Play celebration sound (pursuit completed, achievement unlocked)
  Future<void> playCelebration() => play(SoundType.celebration);

  /// Play success sound (expense added, settings saved)
  Future<void> playSuccess() => play(SoundType.success);

  /// Play coin sound (money-related actions)
  Future<void> playCoin() => play(SoundType.coin);

  /// Play tap sound (button taps - optional)
  Future<void> playTap() => play(SoundType.tap);

  /// Play warning sound (spending threshold exceeded)
  Future<void> playWarning() => play(SoundType.warning);

  /// Play cash out sound (expense confirmation)
  Future<void> playCashOut() => play(SoundType.cashOut);

  /// Play victory sound ("Vazgectim" decision)
  Future<void> playVictory() => play(SoundType.victory);

  /// Play countdown tick sound
  Future<void> playCountdownTick() => play(SoundType.countdown);

  // ==================== CONTROL ====================

  /// Stop currently playing sound
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('[Sound] Stop error: $e');
    }
  }

  // ==================== SETTINGS ====================

  /// Check if sound effects are enabled
  bool get isEnabled => _isEnabled;

  /// Get current volume (0.0 - 1.0)
  double get volume => _volume;

  /// Enable or disable sound effects
  Future<void> setEnabled(bool value) async {
    _isEnabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySoundEnabled, value);
      debugPrint('[Sound] Enabled set to: $value');
    } catch (e) {
      debugPrint('[Sound] setEnabled error: $e');
    }
  }

  /// Set volume level (0.0 - 1.0)
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keySoundVolume, _volume);
      await _player.setVolume(_volume);
      debugPrint('[Sound] Volume set to: $_volume');
    } catch (e) {
      debugPrint('[Sound] setVolume error: $e');
    }
  }

  /// Toggle sound effects on/off
  Future<void> toggle() async {
    await setEnabled(!_isEnabled);
  }

  /// Dispose of resources
  void dispose() {
    _player.dispose();
    _isInitialized = false;
  }
}

/// Global instance for easy access
final soundService = SoundService();
