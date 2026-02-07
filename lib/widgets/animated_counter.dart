import 'dart:math' as math;
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
        return Text(_formatValue(animatedValue), style: style);
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
      tween: Tween<double>(begin: _started ? null : 0, end: _displayValue),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, animatedValue, child) {
        return Text(_formatValue(animatedValue), style: widget.style);
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
                style:
                    valueStyle ??
                    TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: context.vantColors.textPrimary,
                    ),
              ),
              TextSpan(
                text: unit,
                style:
                    unitStyle ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.vantColors.textSecondary,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Premium Number Ticker Widget
/// Her rakam bağımsız olarak slot makinesi gibi döner
class NumberTicker extends StatefulWidget {
  final double value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final int decimalPlaces;
  final Duration duration;
  final Curve curve;
  final bool useGrouping;

  const NumberTicker({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
    this.decimalPlaces = 0,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    this.useGrouping = true,
  });

  @override
  State<NumberTicker> createState() => _NumberTickerState();
}

class _NumberTickerState extends State<NumberTicker> {
  late List<int> _digits;
  late List<int> _oldDigits;
  String _formattedPrefix = '';
  String _formattedSuffix = '';

  @override
  void initState() {
    super.initState();
    _parseValue(widget.value, isInitial: true);
  }

  @override
  void didUpdateWidget(NumberTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldDigits = List.from(_digits);
      _parseValue(widget.value, isInitial: false);
    }
  }

  void _parseValue(double value, {required bool isInitial}) {
    String formatted;
    if (widget.decimalPlaces > 0) {
      formatted = value.toStringAsFixed(widget.decimalPlaces);
    } else {
      formatted = value.toInt().abs().toString();
    }

    // Apply grouping
    if (widget.useGrouping && widget.decimalPlaces == 0) {
      final buffer = StringBuffer();
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(formatted[i]);
        count++;
      }
      formatted = buffer.toString().split('').reversed.join();
    }

    // Parse digits and separators
    final List<int> newDigits = [];
    for (int i = 0; i < formatted.length; i++) {
      final char = formatted[i];
      if (char == '.' || char == ',') {
        newDigits.add(-1); // Separator marker
      } else {
        newDigits.add(int.parse(char));
      }
    }

    if (isInitial) {
      _oldDigits = List.filled(newDigits.length, 0);
    }

    // Pad old digits if needed
    while (_oldDigits.length < newDigits.length) {
      _oldDigits.insert(0, 0);
    }

    _digits = newDigits;
    _formattedPrefix = widget.prefix ?? '';
    _formattedSuffix = widget.suffix ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        widget.style ?? Theme.of(context).textTheme.headlineMedium;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Prefix
        if (_formattedPrefix.isNotEmpty)
          Text(_formattedPrefix, style: effectiveStyle),

        // Digits
        ..._digits.asMap().entries.map((entry) {
          final index = entry.key;
          final digit = entry.value;

          if (digit == -1) {
            // Separator (dot or comma)
            return Text(
              widget.decimalPlaces > 0 &&
                      index == _digits.length - widget.decimalPlaces - 1
                  ? ','
                  : '.',
              style: effectiveStyle,
            );
          }

          final oldDigit = index < _oldDigits.length ? _oldDigits[index] : 0;

          return _TickerDigit(
            digit: digit,
            oldDigit: oldDigit < 0 ? 0 : oldDigit,
            style: effectiveStyle!,
            duration: widget.duration,
            curve: widget.curve,
            delay: Duration(milliseconds: 50 * index),
          );
        }),

        // Suffix
        if (_formattedSuffix.isNotEmpty)
          Text(_formattedSuffix, style: effectiveStyle),
      ],
    );
  }
}

class _TickerDigit extends StatefulWidget {
  final int digit;
  final int oldDigit;
  final TextStyle style;
  final Duration duration;
  final Curve curve;
  final Duration delay;

  const _TickerDigit({
    required this.digit,
    required this.oldDigit,
    required this.style,
    required this.duration,
    required this.curve,
    required this.delay,
  });

  @override
  State<_TickerDigit> createState() => _TickerDigitState();
}

class _TickerDigitState extends State<_TickerDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _currentDigit;
  late int _targetDigit;

  @override
  void initState() {
    super.initState();
    _currentDigit = widget.oldDigit;
    _targetDigit = widget.digit;

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    _startAnimation();
  }

  void _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_TickerDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _currentDigit = oldWidget.digit;
      _targetDigit = widget.digit;
      _controller.reset();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate scroll offset
        final diff = _targetDigit - _currentDigit;
        final progress = _animation.value;

        return ClipRect(
          child: SizedBox(
            width: _getDigitWidth(),
            height: widget.style.fontSize! * 1.2,
            child: Stack(
              children: [
                // Old digit sliding out
                Positioned(
                  top:
                      -widget.style.fontSize! *
                      1.2 *
                      progress *
                      (diff > 0 ? 1 : -1),
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: 1 - progress,
                    child: Text(
                      _currentDigit.toString(),
                      style: widget.style,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // New digit sliding in
                Positioned(
                  top:
                      widget.style.fontSize! *
                      1.2 *
                      (1 - progress) *
                      (diff > 0 ? 1 : -1),
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: progress,
                    child: Text(
                      _targetDigit.toString(),
                      style: widget.style,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getDigitWidth() {
    final textPainter = TextPainter(
      text: TextSpan(text: '0', style: widget.style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width * 1.1; // Slight padding
  }
}

/// Flip Clock Style Number Ticker
/// Premium flip-card animation like airport departure boards
class FlipNumberTicker extends StatefulWidget {
  final double value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final Color? backgroundColor;
  final int decimalPlaces;
  final Duration duration;

  const FlipNumberTicker({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
    this.backgroundColor,
    this.decimalPlaces = 0,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FlipNumberTicker> createState() => _FlipNumberTickerState();
}

class _FlipNumberTickerState extends State<FlipNumberTicker> {
  late String _currentValue;
  late String _oldValue;

  @override
  void initState() {
    super.initState();
    _currentValue = _formatValue(widget.value);
    _oldValue = _currentValue;
  }

  @override
  void didUpdateWidget(FlipNumberTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = _currentValue;
      _currentValue = _formatValue(widget.value);
    }
  }

  String _formatValue(double value) {
    if (widget.decimalPlaces > 0) {
      return value.toStringAsFixed(widget.decimalPlaces);
    }
    return value.toInt().abs().toString();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        widget.style ??
        Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold);
    final bgColor = widget.backgroundColor ?? context.vantColors.cardBackground;

    // Pad to same length
    final maxLen = math.max(_currentValue.length, _oldValue.length);
    final paddedOld = _oldValue.padLeft(maxLen, '0');
    final paddedCurrent = _currentValue.padLeft(maxLen, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.prefix != null)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(widget.prefix!, style: effectiveStyle),
          ),
        ...List.generate(maxLen, (index) {
          final oldChar = paddedOld[index];
          final newChar = paddedCurrent[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: _FlipCard(
              oldValue: oldChar,
              newValue: newChar,
              style: effectiveStyle!,
              backgroundColor: bgColor,
              duration: widget.duration,
              delay: Duration(milliseconds: 80 * index),
            ),
          );
        }),
        if (widget.suffix != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(widget.suffix!, style: effectiveStyle),
          ),
      ],
    );
  }
}

class _FlipCard extends StatefulWidget {
  final String oldValue;
  final String newValue;
  final TextStyle style;
  final Color backgroundColor;
  final Duration duration;
  final Duration delay;

  const _FlipCard({
    required this.oldValue,
    required this.newValue,
    required this.style,
    required this.backgroundColor,
    required this.duration,
    required this.delay,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(widget.delay);
    if (mounted && widget.oldValue != widget.newValue) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.newValue != widget.newValue) {
      _controller.reset();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.style.fontSize! * 1.4;

    return SizedBox(
      width: size * 0.7,
      height: size,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final progress = _flipAnimation.value;

          return Stack(
            children: [
              // Background card
              Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              // Static bottom half (new value)
              Positioned(
                top: size / 2,
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(widget.newValue, style: widget.style),
                  ),
                ),
              ),

              // Animated top half
              if (progress < 0.5)
                Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(-progress * math.pi),
                  child: Container(
                    height: size / 2,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(widget.oldValue, style: widget.style),
                      ),
                    ),
                  ),
                ),

              // Animated bottom half (flipping in)
              if (progress >= 0.5)
                Positioned(
                  top: size / 2,
                  left: 0,
                  right: 0,
                  child: Transform(
                    alignment: Alignment.topCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateX((1 - progress) * math.pi),
                    child: Container(
                      height: size / 2,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(4),
                        ),
                      ),
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(widget.newValue, style: widget.style),
                        ),
                      ),
                    ),
                  ),
                ),

              // Divider line
              Positioned(
                top: size / 2 - 0.5,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
