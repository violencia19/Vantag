import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Wealth Coach: Quiet Luxury Design System
/// JPMorgan & Goldman Sachs özel bankacılık şıklığı
///
/// IMPORTANT: Colors now delegate to AppColors for consistency.
/// Use AppColors directly in new code.

class QuietLuxury {
  QuietLuxury._();

  // ═══════════════════════════════════════════════════════
  // RENK PALETİ - Delegated to AppColors
  // ═══════════════════════════════════════════════════════

  /// Ana arka plan - Midnight Blue
  static Color get background => AppColors.background;

  /// İkincil metin - Slate Grey
  static Color get textSecondary => AppColors.textSecondary;

  /// Ana metin - Off-White
  static Color get textPrimary => AppColors.textPrimary;

  /// Üçüncül metin - daha soluk
  static Color get textTertiary => AppColors.textTertiary;

  /// Pozitif durumlar
  static Color get positive => AppColors.success;

  /// Negatif durumlar
  static Color get negative => AppColors.error;

  /// Uyarı
  static Color get warning => AppColors.warning;

  /// Altın - SADECE özel anlar için (Victory, Achievement, Milestone)
  static Color get gold => AppColors.gold;

  /// Kart arka planı
  static Color get cardBackground => AppColors.cardBackground;

  /// Kart border
  static Color get cardBorder => AppColors.cardBorder;

  /// Gölge rengi
  static const Color shadowColor = Color(0x33000000); // 0.2 opacity

  /// Premium mor gölge
  static const Color premiumShadow = Color(0x4D8B5CF6); // 0.3 opacity purple

  // ═══════════════════════════════════════════════════════
  // TİPOGRAFİ
  // ═══════════════════════════════════════════════════════

  /// Büyük sayılar - nefes alan premium his
  static TextStyle get displayLarge => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.5,
    color: textPrimary,
  );

  /// Başlıklar
  static TextStyle get heading => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: textPrimary,
  );

  /// Alt başlıklar
  static TextStyle get subheading => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  /// Body text
  static TextStyle get body => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  /// Küçük etiketler
  static TextStyle get label => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );

  /// Vurgulu sayılar (tutarlar)
  static TextStyle get amount => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: textPrimary,
  );

  // ═══════════════════════════════════════════════════════
  // ANİMASYON SABİTLERİ
  // ═══════════════════════════════════════════════════════

  /// Sayfa geçişleri
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Curve pageTransitionCurve = Curves.easeInOutCubic;

  /// Modal açılışları
  static const Duration modalTransition = Duration(milliseconds: 300);
  static const Curve modalTransitionCurve = Curves.easeOutCubic;

  /// Sayı değişimleri
  static const Duration numberTransition = Duration(milliseconds: 200);

  /// Buton press scale (Premium: 0.95 for tactile feel)
  static const double buttonPressScale = 0.95;

  // ═══════════════════════════════════════════════════════
  // BOŞLUK SABİTLERİ
  // ═══════════════════════════════════════════════════════

  /// Sayfa padding
  static const EdgeInsets pagePadding = EdgeInsets.all(20);

  /// Kart içi padding
  static const EdgeInsets cardPadding = EdgeInsets.all(20);

  /// Kartlar arası boşluk
  static const double cardSpacing = 16;

  /// Elemanlar arası boşluk
  static const double elementSpacing = 12;

  // ═══════════════════════════════════════════════════════
  // KART DEKORASYONLARI
  // ═══════════════════════════════════════════════════════

  /// Glassmorphism kart dekorasyonu (Revolut style)
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppDesign.radiusXLarge),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.06),
      width: 1,
    ),
    boxShadow: AppDesign.shadowMedium,
  );

  /// Premium kart dekorasyonu (Revolut style)
  static BoxDecoration get premiumCardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppDesign.radiusXLarge),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.06),
      width: 1,
    ),
    boxShadow: AppDesign.cardShadow,
  );

  /// Subtle kart dekorasyonu (gölgesiz)
  static BoxDecoration get subtleCardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppDesign.radiusXLarge),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.06),
      width: 1,
    ),
  );

  /// Vurgulu kart dekorasyonu (pozitif)
  static BoxDecoration positiveCardDecoration({double glowOpacity = 0.1}) =>
      BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: positive.withValues(alpha: 0.3), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: positive.withValues(alpha: glowOpacity),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Border radius
  static BorderRadius get cardRadius => BorderRadius.circular(AppDesign.radiusLarge);
  static BorderRadius get buttonRadius => BorderRadius.circular(AppDesign.radiusSmall);
}

/// Glassmorphism Card Widget (Revolut Style)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final bool premium;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.decoration,
    this.premium = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = decoration ??
        (premium ? QuietLuxury.premiumCardDecoration : QuietLuxury.cardDecoration);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDesign.radiusXLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? AppDesign.cardPaddingLarge,
          decoration: effectiveDecoration.copyWith(
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Animated Number Widget - Sayı değişimlerinde fade geçiş
class AnimatedNumber extends StatelessWidget {
  final String value;
  final TextStyle? style;

  const AnimatedNumber({super.key, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: QuietLuxury.numberTransition,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Text(
        value,
        key: ValueKey(value),
        style: style ?? QuietLuxury.displayLarge,
      ),
    );
  }
}

/// Pressable Widget - Hafif scale efekti
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const Pressable({super.key, required this.child, this.onTap});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? QuietLuxury.buttonPressScale : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

/// Subtle Divider - Çizgi yerine boşluk ve opacity farkı
class SubtleDivider extends StatelessWidget {
  final double height;

  const SubtleDivider({super.key, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
