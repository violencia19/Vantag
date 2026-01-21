import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../screens/voice_input_screen.dart';
import '../theme/theme.dart';

/// Simple voice input button that opens VoiceInputScreen
class VoiceInputButton extends StatelessWidget {
  /// Button size
  final double size;

  /// Primary color for gradient
  final Color? primaryColor;

  /// Secondary color for gradient
  final Color? secondaryColor;

  const VoiceInputButton({
    super.key,
    this.size = 56,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? AppColors.primary;
    final secondary = secondaryColor ?? AppColors.secondary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const VoiceInputScreen(),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, secondary],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: PhosphorIcon(
            PhosphorIconsFill.microphone,
            color: Colors.white,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }
}

/// Compact voice button for inline use (e.g., in QuickAddSheet header)
class CompactVoiceButton extends StatelessWidget {
  /// Optional callback when voice input is complete
  /// If not provided, uses default VoiceInputScreen flow
  final VoidCallback? onTap;

  /// Button size
  final double size;

  const CompactVoiceButton({
    super.key,
    this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const VoiceInputScreen(),
            ),
          );
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: PhosphorIcon(
            PhosphorIconsFill.microphone,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

/// Animated voice button with pulse effect
class AnimatedVoiceButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final bool isListening;

  const AnimatedVoiceButton({
    super.key,
    required this.onTap,
    this.size = 120,
    this.isListening = false,
  });

  @override
  State<AnimatedVoiceButton> createState() => _AnimatedVoiceButtonState();
}

class _AnimatedVoiceButtonState extends State<AnimatedVoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedVoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.isListening ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isListening
                      ? [const Color(0xFFE74C3C), const Color(0xFFC0392B)]
                      : [AppColors.primary, AppColors.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isListening
                            ? const Color(0xFFE74C3C)
                            : AppColors.primary)
                        .withValues(alpha: widget.isListening ? 0.6 : 0.4),
                    blurRadius: widget.isListening ? 50 : 25,
                    spreadRadius: widget.isListening ? 10 : 0,
                  ),
                ],
              ),
              child: Center(
                child: PhosphorIcon(
                  widget.isListening
                      ? PhosphorIconsFill.stop
                      : PhosphorIconsFill.microphone,
                  color: Colors.white,
                  size: widget.size * 0.4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Sound level waveform visualization
class VoiceWaveform extends StatefulWidget {
  final double soundLevel;
  final Color color;
  final double width;
  final double height;

  const VoiceWaveform({
    super.key,
    required this.soundLevel,
    this.color = const Color(0xFF6C63FF),
    this.width = 200,
    this.height = 60,
  });

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: _WaveformPainter(
              color: widget.color,
              progress: _waveController.value,
              amplitude: widget.soundLevel,
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for waveform visualization
class _WaveformPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double amplitude;

  _WaveformPainter({
    required this.color,
    required this.progress,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const barCount = 15;
    final barWidth = size.width / (barCount * 2);
    final maxHeight = size.height * 0.85;
    final minHeight = size.height * 0.15;

    for (var i = 0; i < barCount; i++) {
      final x = barWidth + (i * barWidth * 2);

      // Create wave effect with sound level
      final wave = math.sin((i / barCount + progress) * math.pi * 2);
      final heightFactor = 0.3 + (wave + 1) / 2 * 0.7;
      final amplifiedHeight = minHeight +
          (maxHeight - minHeight) * heightFactor * (0.3 + amplitude * 0.7);

      final y1 = (size.height - amplifiedHeight) / 2;
      final y2 = y1 + amplifiedHeight;

      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.amplitude != amplitude;
  }
}
