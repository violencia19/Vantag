import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Wealth Coach: Quiet Luxury Design System
/// JPMorgan & Goldman Sachs özel bankacılık şıklığı

class QuietLuxury {
  QuietLuxury._();

  // ═══════════════════════════════════════════════════════
  // RENK PALETİ
  // ═══════════════════════════════════════════════════════

  /// Ana arka plan - Midnight Blue
  static const Color background = Color(0xFF1A1A2E);

  /// İkincil metin - Slate Grey
  static const Color textSecondary = Color(0xFF4A4A5A);

  /// Ana metin - Off-White
  static const Color textPrimary = Color(0xFFF5F5F5);

  /// Üçüncül metin - daha soluk
  static const Color textTertiary = Color(0xFF6A6A7A);

  /// Pozitif durumlar - Subtle Green (opacity 0.7)
  static const Color positive = Color(0xB32ECC71); // 0.7 opacity

  /// Negatif durumlar - Subtle Red (opacity 0.7)
  static const Color negative = Color(0xB3E74C3C); // 0.7 opacity

  /// Uyarı - Subtle Amber
  static const Color warning = Color(0xB3FF8C00); // 0.7 opacity

  /// Altın - SADECE özel anlar için (Victory, Achievement, Milestone)
  static const Color gold = Color(0xFFFFD700);

  /// Kart arka planı - çok subtle beyaz
  static const Color cardBackground = Color(0x0DFFFFFF); // 0.05 opacity

  /// Kart border - subtle beyaz
  static const Color cardBorder = Color(0x1AFFFFFF); // 0.1 opacity

  /// Gölge rengi
  static const Color shadowColor = Color(0x33000000); // 0.2 opacity

  /// Premium mor gölge
  static const Color premiumShadow = Color(0x4D8B5CF6); // 0.3 opacity purple

  // ═══════════════════════════════════════════════════════
  // TİPOGRAFİ
  // ═══════════════════════════════════════════════════════

  /// Büyük sayılar - nefes alan premium his
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.5,
    color: textPrimary,
  );

  /// Başlıklar
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: textPrimary,
  );

  /// Alt başlıklar
  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  /// Body text
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  /// Küçük etiketler
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );

  /// Vurgulu sayılar (tutarlar)
  static const TextStyle amount = TextStyle(
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
