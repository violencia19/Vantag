import 'package:shared_preferences/shared_preferences.dart';

/// Wealth Coach: Ses Dosyası Türleri
enum SoundType {
  cashOut,      // Harcama onayı
  victory,      // Vazgeçtim/İrade zaferi
  countdown,    // Geri sayım tick
  warning,      // Risk uyarısı
  success,      // Başarılı kayıt
  celebration,  // Rozet/başarım
}

/// Wealth Coach: Sound Service
/// Placeholder implementasyon - audioplayers paketi eklenince aktif edilecek
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _isEnabled = true;
  bool _isInitialized = false;

  // Ses dosyası yolları (placeholder)
  static const Map<SoundType, String> _soundPaths = {
    SoundType.cashOut: 'assets/sounds/cash_out.mp3',
    SoundType.victory: 'assets/sounds/victory.mp3',
    SoundType.countdown: 'assets/sounds/countdown_tick.mp3',
    SoundType.warning: 'assets/sounds/warning.mp3',
    SoundType.success: 'assets/sounds/success.mp3',
    SoundType.celebration: 'assets/sounds/celebration.mp3',
  };

  static const _keySoundEnabled = 'sound_enabled';
  static const _keySoundVolume = 'sound_volume';

  double _volume = 0.7;

  /// Servisi başlat
  Future<void> init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_keySoundEnabled) ?? true;
    _volume = prefs.getDouble(_keySoundVolume) ?? 0.7;

    // Ses özelliği gelecek sürümde aktif edilecek

    _isInitialized = true;
  }

  /// Ses çal
  Future<void> play(SoundType type) async {
    if (!_isEnabled || !_isInitialized) return;

    final path = _soundPaths[type];
    if (path == null) return;

    // Ses özelliği gelecek sürümde aktif edilecek
  }

  /// Harcama onayı sesi
  Future<void> playCashOut() => play(SoundType.cashOut);

  /// İrade zaferi sesi
  Future<void> playVictory() => play(SoundType.victory);

  /// Geri sayım tick sesi
  Future<void> playCountdownTick() => play(SoundType.countdown);

  /// Uyarı sesi
  Future<void> playWarning() => play(SoundType.warning);

  /// Başarı sesi
  Future<void> playSuccess() => play(SoundType.success);

  /// Kutlama sesi
  Future<void> playCelebration() => play(SoundType.celebration);

  /// Sesi durdur
  Future<void> stop() async {
    // Ses özelliği gelecek sürümde aktif edilecek
  }

  // ==================== AYARLAR ====================

  bool get isEnabled => _isEnabled;
  double get volume => _volume;

  Future<void> setEnabled(bool value) async {
    _isEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, value);
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySoundVolume, _volume);

    // Ses özelliği gelecek sürümde aktif edilecek
  }

  /// Dispose
  void dispose() {
    _isInitialized = false;
  }
}

/// Global erişim için kısayol
final soundService = SoundService();
