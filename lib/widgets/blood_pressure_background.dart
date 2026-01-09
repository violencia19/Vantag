import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/sensory_feedback_service.dart';
import '../theme/theme.dart';

/// Wealth Coach: Blood-Pressure Background
/// Tutar arttıkça kırmızıya dönen animasyonlu arka plan
class BloodPressureBackground extends StatelessWidget {
  final double amount;
  final Widget child;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool enableGlow;
  final double borderRadius;

  const BloodPressureBackground({
    super.key,
    required this.amount,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
    this.enableGlow = true,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = sensoryFeedback.getBackgroundGradient(amount);
    final riskLevel = sensoryFeedback.getRiskLevel(amount);
    final borderColor = sensoryFeedback.getAmountBorderColor(amount);

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: riskLevel.backgroundIntensity > 0.3 ? 2 : 1,
        ),
        boxShadow: enableGlow && riskLevel.backgroundIntensity > 0.2
            ? [
                BoxShadow(
                  color: const Color(0xFFE74C3C).withValues(
                    alpha: riskLevel.backgroundIntensity * 0.3,
                  ),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Wealth Coach: Premium Modal Background
/// Glassmorphism + Blood Pressure efekti kombine
class PremiumModalBackground extends StatelessWidget {
  final double amount;
  final Widget child;
  final bool showGoldenGlow;
  final VoidCallback? onClose;

  const PremiumModalBackground({
    super.key,
    required this.amount,
    required this.child,
    this.showGoldenGlow = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = sensoryFeedback.getBackgroundGradient(amount);
    final riskLevel = sensoryFeedback.getRiskLevel(amount);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  gradientColors[0].withValues(alpha: 0.95),
                  gradientColors[1].withValues(alpha: 0.98),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: showGoldenGlow
                    ? const Color(0xFFFFD700)
                    : riskLevel.backgroundIntensity > 0.3
                        ? const Color(0xFFE74C3C).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1),
                width: showGoldenGlow || riskLevel.backgroundIntensity > 0.3 ? 2 : 1,
              ),
              boxShadow: [
                if (showGoldenGlow)
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                else if (riskLevel.backgroundIntensity > 0.2)
                  BoxShadow(
                    color: const Color(0xFFE74C3C).withValues(
                      alpha: riskLevel.backgroundIntensity * 0.3,
                    ),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Wealth Coach: Tutar Input Wrapper
/// Tutar alanı için blood pressure border efekti
class BloodPressureAmountField extends StatelessWidget {
  final double amount;
  final Widget child;
  final bool isValid;

  const BloodPressureAmountField({
    super.key,
    required this.amount,
    required this.child,
    this.isValid = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = sensoryFeedback.getAmountBorderColor(amount);
    final riskLevel = sensoryFeedback.getRiskLevel(amount);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isValid ? borderColor : AppColors.cardBorder,
          width: isValid && riskLevel != RiskLevel.none ? 2 : 1,
        ),
        boxShadow: isValid && riskLevel.backgroundIntensity > 0.2
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Wealth Coach: Risk Indicator Bar
/// Ekranın üstünde ince risk göstergesi
class RiskIndicatorBar extends StatelessWidget {
  final double amount;
  final double height;

  const RiskIndicatorBar({
    super.key,
    required this.amount,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    final riskLevel = sensoryFeedback.getRiskLevel(amount);

    if (riskLevel == RiskLevel.none) {
      return SizedBox(height: height);
    }

    Color color;
    switch (riskLevel) {
      case RiskLevel.none:
        color = Colors.transparent;
        break;
      case RiskLevel.low:
        color = const Color(0xFFFFD700);
        break;
      case RiskLevel.medium:
        color = const Color(0xFFFF9500);
        break;
      case RiskLevel.high:
        color = const Color(0xFFE74C3C);
        break;
      case RiskLevel.extreme:
        color = const Color(0xFFB71C1C);
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.3),
            color,
            color.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
