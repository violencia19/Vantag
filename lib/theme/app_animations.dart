import 'package:flutter/material.dart';

/// Global animasyon sabitleri
/// Tüm uygulama genelinde tutarlı animasyon dili için kullanılır
class AppAnimations {
  AppAnimations._();

  // ========== CURVES ==========
  /// Standart animasyon curve'ü - tüm animasyonlar için varsayılan
  static const Curve standardCurve = Curves.easeOutCubic;

  /// Giriş animasyonları için
  static const Curve enterCurve = Curves.easeOutCubic;

  /// Çıkış animasyonları için
  static const Curve exitCurve = Curves.easeInCubic;

  /// Bounce efektli animasyonlar için
  static const Curve bounceCurve = Curves.elasticOut;

  /// Yumuşak yavaşlama için
  static const Curve decelerateCurve = Curves.decelerate;

  // ========== DURATIONS ==========
  /// Mikro animasyonlar (buton press, icon change)
  static const Duration micro = Duration(milliseconds: 160);

  /// Kısa animasyonlar (renk değişimi, opacity)
  static const Duration short = Duration(milliseconds: 200);

  /// Orta animasyonlar (kart geçişleri)
  static const Duration medium = Duration(milliseconds: 300);

  /// Sayfa geçişleri
  static const Duration pageTransition = Duration(milliseconds: 300);

  /// Counter animasyonları
  static const Duration counter = Duration(milliseconds: 600);

  /// Uzun animasyonlar (achievement celebration)
  static const Duration long = Duration(milliseconds: 500);

  /// Çok uzun animasyonlar (confetti)
  static const Duration extraLong = Duration(milliseconds: 2500);

  // ========== DELAYS ==========
  /// Staggered animasyonlarda kartlar arası gecikme
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Sayfa açılınca ilk animasyon öncesi bekleme
  static const Duration initialDelay = Duration(milliseconds: 150);

  /// Karar sonrası counter animasyonu öncesi bekleme
  static const Duration decisionDelay = Duration(milliseconds: 80);

  // ========== SCALES ==========
  /// Buton press scale (Premium: 0.95 for tactile feel)
  static const double buttonPressScale = 0.95;

  /// Header scroll scale (min)
  static const double headerMinScale = 0.92;

  /// Achievement pulse scale
  static const double achievementPulseScale = 1.03;

  /// Card hover/focus scale
  static const double cardFocusScale = 1.02;

  // ========== OPACITIES ==========
  /// Header scroll opacity (min)
  static const double headerMinOpacity = 0.8;

  /// Kilitli rozet opacity
  static const double lockedOpacity = 0.6;

  /// Disabled element opacity
  static const double disabledOpacity = 0.5;

  /// Overlay backdrop opacity
  static const double backdropOpacity = 0.7;

  // ========== OFFSETS ==========
  /// Kart slide-up animasyonu başlangıç offset'i
  static const Offset cardSlideOffset = Offset(0, 30);

  /// Bottom sheet slide offset
  static const Offset sheetSlideOffset = Offset(0, 50);

  // ========== BLUR ==========
  /// Backdrop blur değeri
  static const double backdropBlur = 10.0;

  /// Kilitli rozet blur değeri
  static const double lockedBlur = 2.0;

  // ========== HELPER METHODS ==========

  /// Staggered animasyon için gecikme hesapla
  static Duration staggeredDelay(int index) {
    return Duration(milliseconds: staggerDelay.inMilliseconds * index);
  }

  /// Sayfa açılış animasyonu için toplam gecikme
  static Duration pageEntryDelay(int index) {
    return Duration(
      milliseconds:
          initialDelay.inMilliseconds + staggerDelay.inMilliseconds * index,
    );
  }
}

/// Animasyon yardımcı extension'ları
extension AnimationExtensions on Duration {
  /// Duration'ı Curve ile birleştir
  ({Duration duration, Curve curve}) withCurve([Curve? curve]) {
    return (duration: this, curve: curve ?? AppAnimations.standardCurve);
  }
}

/// Widget animasyon mixin'i
mixin AnimatedStateMixin<T extends StatefulWidget> on State<T> {
  /// Güvenli setState - mounted kontrolü ile
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  /// Gecikmeli işlem çalıştır
  Future<void> delayed(Duration duration, VoidCallback callback) async {
    await Future.delayed(duration);
    if (mounted) callback();
  }
}
