import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../services/lock_service.dart';
import '../services/haptic_service.dart';
import '../theme/theme.dart';

/// Lock screen with PIN input and biometric option
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  bool _isLoading = false;
  String? _error;
  bool _biometricAvailable = false;

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

    _checkBiometric();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final canUse = await LockService.canUseBiometrics();
    final isEnabled = await LockService.isBiometricEnabled();
    setState(() => _biometricAvailable = canUse && isEnabled);

    // Auto-trigger biometric on launch
    if (_biometricAvailable) {
      _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    if (!_biometricAvailable) return;

    final l10n = AppLocalizations.of(context);
    final success = await LockService.authenticateWithBiometrics(
      l10n.unlockWithBiometric,
    );

    if (success && mounted) {
      haptics.success();
      widget.onUnlocked();
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      haptics.light();
      setState(() {
        _enteredPin += number;
        _error = null;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
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

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    final success = await LockService.verifyPin(_enteredPin);

    if (success) {
      haptics.success();
      widget.onUnlocked();
    } else {
      haptics.error();
      _shakeController.forward().then((_) => _shakeController.reset());
      setState(() {
        _error = AppLocalizations.of(context).wrongPin;
        _enteredPin = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  PhosphorIconsFill.lock,
                  size: 40,
                  color: context.appColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                l10n.enterPin,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vantag',
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
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

              const SizedBox(height: 24),

              // Biometric button
              if (_biometricAvailable)
                TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: FutureBuilder<bool>(
                    future: LockService.hasFaceId(),
                    builder: (context, snapshot) {
                      return Icon(
                        snapshot.data == true
                            ? PhosphorIconsRegular.scan
                            : PhosphorIconsRegular.fingerprint,
                        color: context.appColors.primary,
                      );
                    },
                  ),
                  label: Text(
                    l10n.useBiometric,
                    style: TextStyle(
                      color: context.appColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                const SizedBox(height: 48),

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
            const SizedBox(width: 72), // Empty space
            _buildNumberButton('0'),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _onNumberPressed(number),
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
      onTap: _isLoading ? null : _onDeletePressed,
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
