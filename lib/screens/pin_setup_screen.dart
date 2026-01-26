import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../services/lock_service.dart';
import '../services/haptic_service.dart';
import '../theme/theme.dart';

/// Screen for setting up a new PIN
class PinSetupScreen extends StatefulWidget {
  /// If true, this is changing an existing PIN
  final bool isChanging;

  const PinSetupScreen({super.key, this.isChanging = false});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String _firstPin = '';
  bool _isConfirming = false;
  String? _error;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 24,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      haptics.light();
      setState(() {
        _enteredPin += number;
        _error = null;
      });

      if (_enteredPin.length == 4) {
        _processPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      haptics.light();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _error = null;
      });
    }
  }

  void _processPin() {
    if (!_isConfirming) {
      // First entry - store and ask for confirmation
      setState(() {
        _firstPin = _enteredPin;
        _enteredPin = '';
        _isConfirming = true;
      });
    } else {
      // Confirming - check if they match
      if (_enteredPin == _firstPin) {
        _savePin();
      } else {
        haptics.error();
        _shakeController.forward().then((_) => _shakeController.reset());
        setState(() {
          _error = AppLocalizations.of(context).pinMismatch;
          _enteredPin = '';
          _firstPin = '';
          _isConfirming = false;
        });
      }
    }
  }

  Future<void> _savePin() async {
    await LockService.setPin(_firstPin);
    await LockService.setLockEnabled(true);

    haptics.success();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pinSet),
          backgroundColor: context.appColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _reset() {
    haptics.light();
    setState(() {
      _enteredPin = '';
      _firstPin = '';
      _isConfirming = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIconsRegular.arrowLeft,
            color: context.appColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          if (_isConfirming)
            TextButton(
              onPressed: _reset,
              child: Text(
                l10n.reset,
                style: TextStyle(color: context.appColors.textSecondary),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _isConfirming
                      ? PhosphorIconsFill.lockKey
                      : PhosphorIconsFill.lock,
                  size: 40,
                  color: context.appColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                _isConfirming ? l10n.confirmPin : l10n.createPin,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirming
                    ? l10n.confirmPinDescription
                    : l10n.createPinDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // PIN dots with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _shakeAnimation.value *
                          ((_shakeController.value * 10).toInt().isEven
                              ? 1
                              : -1),
                      0,
                    ),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _enteredPin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? context.appColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: _error != null
                              ? context.appColors.error
                              : context.appColors.primary,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Error message
              const SizedBox(height: 20),
              SizedBox(
                height: 20,
                child: _error != null
                    ? Text(
                        _error!,
                        style: TextStyle(
                          color: context.appColors.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : null,
              ),

              const Spacer(),

              // Number pad
              _buildNumberPad(),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map(_buildNumberButton).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map(_buildNumberButton).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map(_buildNumberButton).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 72),
            _buildNumberButton('0'),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.appColors.surface,
          border: Border.all(color: context.appColors.cardBorder, width: 1),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _onDeletePressed,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Center(
          child: Icon(
            PhosphorIconsRegular.backspace,
            size: 28,
            color: context.appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
