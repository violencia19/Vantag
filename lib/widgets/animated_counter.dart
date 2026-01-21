import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Animasyonlu sayaç widget'ı
/// Sayılar pat diye değişmez, akışkan bir şekilde artar/azalır
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final int decimalPlaces;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool useGrouping; // 1.000,00 formatı

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
    this.decimalPlaces = 0,
    this.duration = AppAnimations.counter,
    this.delay = Duration.zero,
    this.curve = AppAnimations.standardCurve,
    this.useGrouping = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        return Text(
          _formatValue(animatedValue),
          style: style,
        );
      },
    );
  }

  String _formatValue(double val) {
    String formatted;

    if (decimalPlaces > 0) {
      formatted = val.toStringAsFixed(decimalPlaces);
    } else {
      formatted = val.toInt().toString();
    }

    if (useGrouping) {
      // Türkçe format: 1.234.567,89
      final parts = formatted.split('.');
      final intPart = parts[0];
      final decPart = parts.length > 1 ? parts[1] : null;

      final buffer = StringBuffer();
      int count = 0;
      for (int i = intPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(intPart[i]);
        count++;
      }
      formatted = buffer.toString().split('').reversed.join();
      if (decPart != null) {
        formatted = '$formatted,$decPart';
      }
    }

    final result = StringBuffer();
    if (prefix != null) result.write(prefix);
    result.write(formatted);
    if (suffix != null) result.write(suffix);

    return result.toString();
  }
}

/// Gecikmeli animasyonlu sayaç
/// Karar verildikten sonra kısa bir bekleme ile başlar
class DelayedAnimatedCounter extends StatefulWidget {
  final double value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final int decimalPlaces;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool useGrouping;

  const DelayedAnimatedCounter({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
    this.decimalPlaces = 0,
    this.duration = AppAnimations.counter,
    this.delay = AppAnimations.decisionDelay,
    this.curve = AppAnimations.standardCurve,
    this.useGrouping = true,
  });

  @override
  State<DelayedAnimatedCounter> createState() => _DelayedAnimatedCounterState();
}

class _DelayedAnimatedCounterState extends State<DelayedAnimatedCounter> {
  double _displayValue = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(DelayedAnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      setState(() {
        _displayValue = widget.value;
        _started = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(_displayValue),
      tween: Tween<double>(
        begin: _started ? null : 0,
        end: _displayValue,
      ),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, animatedValue, child) {
        return Text(
          _formatValue(animatedValue),
          style: widget.style,
        );
      },
    );
  }

  String _formatValue(double val) {
    String formatted;

    if (widget.decimalPlaces > 0) {
      formatted = val.toStringAsFixed(widget.decimalPlaces);
    } else {
      formatted = val.toInt().toString();
    }

    if (widget.useGrouping) {
      final parts = formatted.split('.');
      final intPart = parts[0];
      final decPart = parts.length > 1 ? parts[1] : null;

      final buffer = StringBuffer();
      int count = 0;
      for (int i = intPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(intPart[i]);
        count++;
      }
      formatted = buffer.toString().split('').reversed.join();
      if (decPart != null) {
        formatted = '$formatted,$decPart';
      }
    }

    final result = StringBuffer();
    if (widget.prefix != null) result.write(widget.prefix);
    result.write(formatted);
    if (widget.suffix != null) result.write(widget.suffix);

    return result.toString();
  }
}

/// Saat ve gün sayacı
/// "12.5 saat" veya "3.2 gün" formatında gösterir
class AnimatedTimeCounter extends StatelessWidget {
  final double hours;
  final TextStyle? valueStyle;
  final TextStyle? unitStyle;
  final Duration duration;
  final Curve curve;
  final bool showDays; // Günleri de göster

  const AnimatedTimeCounter({
    super.key,
    required this.hours,
    this.valueStyle,
    this.unitStyle,
    this.duration = AppAnimations.counter,
    this.curve = AppAnimations.standardCurve,
    this.showDays = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // 8 saatten fazlaysa gün olarak göster
    final bool displayAsDays = showDays && hours >= 8;
    final double displayValue = displayAsDays ? hours / 8 : hours;
    final String unit = ' ${displayAsDays ? l10n.days : l10n.hours}';

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: displayValue),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        final formattedValue = animatedValue < 10
            ? animatedValue.toStringAsFixed(1)
            : animatedValue.toInt().toString();

        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: formattedValue,
                style: valueStyle ?? const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: unit,
                style: unitStyle ?? const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
