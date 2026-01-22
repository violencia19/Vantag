import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wealth Coach: Risk Seviyeleri
enum RiskLevel {
  none,      // %0-10 - Risk yok
  low,       // %10-15 - Düşük risk
  medium,    // %15-25 - Orta risk
  high,      // %25+ - Yüksek risk
  extreme;   // %50+ - Ekstrem risk

  String get label {
    switch (this) {
      case RiskLevel.none:
        return 'Güvenli';
      case RiskLevel.low:
        return 'Düşük Risk';
      case RiskLevel.medium:
        return 'Orta Risk';
      case RiskLevel.high:
        return 'Yüksek Risk';
      case RiskLevel.extreme:
        return 'Kritik Risk';
    }
  }

  String get emoji {
    switch (this) {
      case RiskLevel.none:
        return '';
      case RiskLevel.low:
        return '';
      case RiskLevel.medium:
        return '';
      case RiskLevel.high:
        return '';
      case RiskLevel.extreme:
        return '';
    }
  }

  /// Geri sayım süresi (saniye)
  int get countdownSeconds {
    switch (this) {
      case RiskLevel.none:
      case RiskLevel.low:
        return 0; // Geri sayım yok
      case RiskLevel.medium:
        return 2;
      case RiskLevel.high:
        return 3;
      case RiskLevel.extreme:
        return 5;
    }
  }

  /// Arka plan renk yoğunluğu (0.0 - 1.0)
  double get backgroundIntensity {
    switch (this) {
      case RiskLevel.none:
        return 0.0;
      case RiskLevel.low:
        return 0.15;
      case RiskLevel.medium:
        return 0.35;
      case RiskLevel.high:
        return 0.55;
      case RiskLevel.extreme:
        return 0.75;
    }
  }
}

/// Wealth Coach: Sensory Feedback Manager
/// Haptic, ses ve görsel feedback merkezi yönetimi
class SensoryFeedbackManager {
  static final SensoryFeedbackManager _instance = SensoryFeedbackManager._internal();
  factory SensoryFeedbackManager() => _instance;
  SensoryFeedbackManager._internal();

  // Ayarlar
  bool _hapticEnabled = true;
  bool _soundEnabled = true;
  bool _visualFeedbackEnabled = true;

  // Kullanıcı finansal verileri (cache)
  double _hourlyRate = 100.0; // Varsayılan saatlik ücret
  double _monthlyIncome = 10000.0; // Varsayılan aylık gelir

  // Preference keys
  static const _keyHapticEnabled = 'sensory_haptic_enabled';
  static const _keySoundEnabled = 'sensory_sound_enabled';
  static const _keyVisualEnabled = 'sensory_visual_enabled';

  // Son tetiklenen tutar (performans için)
  double _lastTriggeredAmount = 0;
  int _lastTriggeredDigits = 0;

  /// Servisi başlat
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _hapticEnabled = prefs.getBool(_keyHapticEnabled) ?? true;
    _soundEnabled = prefs.getBool(_keySoundEnabled) ?? true;
    _visualFeedbackEnabled = prefs.getBool(_keyVisualEnabled) ?? true;
  }

  /// Kullanıcı finansal verilerini güncelle
  void updateFinancials({double? hourlyRate, double? monthlyIncome}) {
    if (hourlyRate != null) _hourlyRate = hourlyRate;
    if (monthlyIncome != null) _monthlyIncome = monthlyIncome;
  }

  // ==================== HAPTIC FEEDBACK ====================

  /// Tutar bazlı haptic feedback
  /// Sadece basamak değişiminde tetiklenir (performans)
  void triggerHapticForAmount(double amount) {
    if (!_hapticEnabled) return;

    // Basamak kontrolü (performans için)
    final digits = amount.toInt().toString().length;
    if (digits == _lastTriggeredDigits && (amount - _lastTriggeredAmount).abs() < 50) {
      return; // Aynı basamakta küçük değişiklik, tetikleme
    }

    _lastTriggeredAmount = amount;
    _lastTriggeredDigits = digits;

    // Tutar bazlı haptic seçimi
    if (amount <= 100) {
      HapticFeedback.selectionClick();
    } else if (amount <= 500) {
      HapticFeedback.lightImpact();
    } else if (amount <= 1000) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  /// Karar anı haptic feedback
  void triggerDecisionHaptic(bool isPositive) {
    if (!_hapticEnabled) return;

    if (isPositive) {
      // Olumlu karar (vazgeçtim)
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.lightImpact();
      });
    } else {
      // Olumsuz karar (aldım - büyük harcama)
      HapticFeedback.heavyImpact();
    }
  }

  /// Geri sayım tick haptic
  void triggerCountdownTick() {
    if (!_hapticEnabled) return;
    HapticFeedback.selectionClick();
  }

  /// Başarı haptic (golden glow anı)
  void triggerSuccessHaptic() {
    if (!_hapticEnabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      HapticFeedback.lightImpact();
    });
  }

  // ==================== RISK HESAPLAMA ====================

  /// Tutar için risk seviyesi hesapla
  RiskLevel getRiskLevel(double amount) {
    if (_monthlyIncome <= 0) return RiskLevel.none;

    final percentage = (amount / _monthlyIncome) * 100;

    if (percentage >= 50) return RiskLevel.extreme;
    if (percentage >= 25) return RiskLevel.high;
    if (percentage >= 15) return RiskLevel.medium;
    if (percentage >= 10) return RiskLevel.low;
    return RiskLevel.none;
  }

  /// Tutar için çalışma süresi hesapla
  Duration getWorkDuration(double amount) {
    if (_hourlyRate <= 0) return Duration.zero;
    final hours = amount / _hourlyRate;
    return Duration(minutes: (hours * 60).round());
  }

  /// Özgürlük hedefi gecikme günü hesapla
  int getFreedomDelayDays(double amount) {
    // Basit hesaplama: Aylık tasarruf hedefinin %20'si varsayılan
    final monthlyTarget = _monthlyIncome * 0.2;
    if (monthlyTarget <= 0) return 0;
    return (amount / (monthlyTarget / 30)).round();
  }

  /// Risk uyarı mesajı oluştur
  String getRiskWarningMessage(double amount) {
    final riskLevel = getRiskLevel(amount);
    final workDuration = getWorkDuration(amount);
    final delayDays = getFreedomDelayDays(amount);
    final percentage = (_monthlyIncome > 0)
        ? ((amount / _monthlyIncome) * 100).toStringAsFixed(1)
        : '0';

    switch (riskLevel) {
      case RiskLevel.none:
        return '';
      case RiskLevel.low:
        return 'Bu harcama özgürlük hedefini $delayDays gün geriye çeker';
      case RiskLevel.medium:
        return 'Bu harcama için ${_formatDuration(workDuration)} çalışman gerekiyor. Özgürlük hedefin $delayDays gün gecikecek.';
      case RiskLevel.high:
        return 'Bu harcama aylık gelirinin %$percentage\'i! Özgürlük hedefin $delayDays gün geriye gidecek.';
      case RiskLevel.extreme:
        return 'DİKKAT! Bu harcama aylık gelirinin %$percentage\'i! Bu karar finansal özgürlüğünü ciddi şekilde etkileyecek.';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} gün ${duration.inHours % 24} saat';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} saat ${duration.inMinutes % 60} dakika';
    } else {
      return '${duration.inMinutes} dakika';
    }
  }

  // ==================== GÖRSEL FEEDBACK ====================

  /// Blood-Pressure arka plan rengi hesapla
  Color getBackgroundColor(double amount, {Color baseColor = const Color(0xFF1A1A2E)}) {
    if (!_visualFeedbackEnabled) return baseColor;

    final riskLevel = getRiskLevel(amount);
    final intensity = riskLevel.backgroundIntensity;

    if (intensity <= 0) return baseColor;

    // Kırmızı tonuna geçiş
    const dangerColor = Color(0xFFE74C3C);
    return Color.lerp(baseColor, dangerColor, intensity)!;
  }

  /// Tutar için arka plan gradient oluştur
  List<Color> getBackgroundGradient(double amount) {
    if (!_visualFeedbackEnabled) {
      return [const Color(0xFF1A1A2E), const Color(0xFF16213E)];
    }

    final riskLevel = getRiskLevel(amount);
    final intensity = riskLevel.backgroundIntensity;

    const baseStart = Color(0xFF1A1A2E);
    const baseEnd = Color(0xFF16213E);
    const dangerStart = Color(0xFF4A1C1C);
    const dangerEnd = Color(0xFF2D1010);

    return [
      Color.lerp(baseStart, dangerStart, intensity)!,
      Color.lerp(baseEnd, dangerEnd, intensity)!,
    ];
  }

  /// Tutar alanı border rengi
  Color getAmountBorderColor(double amount) {
    if (!_visualFeedbackEnabled) return const Color(0xFF2D3436);

    final riskLevel = getRiskLevel(amount);

    switch (riskLevel) {
      case RiskLevel.none:
        return const Color(0xFF2D3436);
      case RiskLevel.low:
        return const Color(0xFFFFD700).withValues(alpha: 0.5);
      case RiskLevel.medium:
        return const Color(0xFFFF9500).withValues(alpha: 0.6);
      case RiskLevel.high:
        return const Color(0xFFE74C3C).withValues(alpha: 0.7);
      case RiskLevel.extreme:
        return const Color(0xFFE74C3C);
    }
  }

  // ==================== AYARLAR ====================

  bool get hapticEnabled => _hapticEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get visualFeedbackEnabled => _visualFeedbackEnabled;

  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHapticEnabled, value);
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, value);
  }

  Future<void> setVisualFeedbackEnabled(bool value) async {
    _visualFeedbackEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVisualEnabled, value);
  }

  /// Haptic feedback sıfırla (yeni giriş için)
  void resetHapticState() {
    _lastTriggeredAmount = 0;
    _lastTriggeredDigits = 0;
  }
}

/// Global erişim için kısayol
final sensoryFeedback = SensoryFeedbackManager();
