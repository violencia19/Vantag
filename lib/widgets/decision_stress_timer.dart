import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../services/sensory_feedback_service.dart';
import '../theme/theme.dart';

/// Wealth Coach: Decision Stress Timer
/// Graduated countdown system based on risk level
class DecisionStressTimer extends StatefulWidget {
  final double amount;
  final RiskLevel riskLevel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String? confirmLabel;
  final String? warningMessage;

  const DecisionStressTimer({
    super.key,
    required this.amount,
    required this.riskLevel,
    required this.onConfirm,
    this.onCancel,
    this.confirmLabel,
    this.warningMessage,
  });

  @override
  State<DecisionStressTimer> createState() => _DecisionStressTimerState();
}

class _DecisionStressTimerState extends State<DecisionStressTimer>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _canConfirm = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _remainingSeconds = widget.riskLevel.countdownSeconds;
    _canConfirm = _remainingSeconds == 0;

    // Pulse animation (for high risk)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (!_canConfirm) {
      _startCountdown();
      if (widget.riskLevel == RiskLevel.high ||
          widget.riskLevel == RiskLevel.extreme) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        sensoryFeedback.triggerCountdownTick();
      }

      if (_remainingSeconds == 0) {
        timer.cancel();
        _pulseController.stop();
        setState(() => _canConfirm = true);
        HapticFeedback.mediumImpact();
      }
    });
  }

  Color get _riskColor {
    switch (widget.riskLevel) {
      case RiskLevel.none:
      case RiskLevel.low:
        return AppColors.medalGold; // Gold
      case RiskLevel.medium:
        return AppColors.warning; // Orange
      case RiskLevel.high:
        return AppColors.categoryBills; // Red
      case RiskLevel.extreme:
        return AppColors.dangerRed; // Dark Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // No risk - direct confirm button
    if (widget.riskLevel == RiskLevel.none) {
      return _buildConfirmButton(l10n);
    }

    return Column(
      children: [
        // Warning message
        if (widget.warningMessage != null && widget.warningMessage!.isNotEmpty)
          _buildWarningCard(l10n),

        const SizedBox(height: 16),

        // Countdown or confirm button
        if (!_canConfirm)
          _buildCountdownIndicator(l10n)
        else
          _buildConfirmButton(l10n),

        // Cancel button
        if (widget.onCancel != null) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              foregroundColor: context.appColors.textSecondary,
            ),
            child: Text(l10n.giveUp),
          ),
        ],
      ],
    );
  }

  Widget _buildWarningCard(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _canConfirm ? 1.0 : _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _riskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _riskColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Risk icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _riskColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getWarningIcon(), color: _riskColor, size: 24),
                ),
                const SizedBox(width: 12),
                // Message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRiskLabel(l10n),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _riskColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.warningMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getRiskLabel(AppLocalizations l10n) {
    switch (widget.riskLevel) {
      case RiskLevel.none:
        return l10n.riskLevelNone;
      case RiskLevel.low:
        return l10n.riskLevelLow;
      case RiskLevel.medium:
        return l10n.riskLevelMedium;
      case RiskLevel.high:
        return l10n.riskLevelHigh;
      case RiskLevel.extreme:
        return l10n.riskLevelExtreme;
    }
  }

  IconData _getWarningIcon() {
    switch (widget.riskLevel) {
      case RiskLevel.none:
        return PhosphorIconsDuotone.checkCircle;
      case RiskLevel.low:
        return PhosphorIconsDuotone.info;
      case RiskLevel.medium:
        return PhosphorIconsDuotone.warningCircle;
      case RiskLevel.high:
        return PhosphorIconsDuotone.warningOctagon;
      case RiskLevel.extreme:
        return PhosphorIconsDuotone.skull;
    }
  }

  Widget _buildCountdownIndicator(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: _riskColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _riskColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Countdown number
          Text(
            '$_remainingSeconds',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: _riskColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.thinkingTime,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:
                    1 - (_remainingSeconds / widget.riskLevel.countdownSeconds),
                backgroundColor: _riskColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(_riskColor),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          widget.onConfirm();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.riskLevel == RiskLevel.none
              ? context.appColors.primary
              : _riskColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.riskLevel == RiskLevel.none
                  ? PhosphorIconsDuotone.check
                  : PhosphorIconsDuotone.warningCircle,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              widget.confirmLabel ?? l10n.confirm,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Risk level badge widget
class RiskBadge extends StatelessWidget {
  final RiskLevel riskLevel;
  final bool showLabel;

  const RiskBadge({super.key, required this.riskLevel, this.showLabel = true});

  Color _getColor(BuildContext context) {
    switch (riskLevel) {
      case RiskLevel.none:
        return context.appColors.success;
      case RiskLevel.low:
        return AppColors.medalGold;
      case RiskLevel.medium:
        return AppColors.warning;
      case RiskLevel.high:
        return AppColors.categoryBills;
      case RiskLevel.extreme:
        return AppColors.dangerRed;
    }
  }

  String _getRiskLabel(AppLocalizations l10n) {
    switch (riskLevel) {
      case RiskLevel.none:
        return l10n.riskLevelNone;
      case RiskLevel.low:
        return l10n.riskLevelLow;
      case RiskLevel.medium:
        return l10n.riskLevelMedium;
      case RiskLevel.high:
        return l10n.riskLevelHigh;
      case RiskLevel.extreme:
        return l10n.riskLevelExtreme;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (riskLevel == RiskLevel.none) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final color = _getColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(riskLevel.emoji, style: const TextStyle(fontSize: 12)),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _getRiskLabel(l10n),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
