import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';

/// Full-screen voice input experience
/// Opens with microphone auto-started for seamless voice entry
class VoiceInputScreen extends StatefulWidget {
  /// If true, auto-start listening when screen opens
  final bool autoStart;

  const VoiceInputScreen({super.key, this.autoStart = true});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  final VoiceParserService _parser = VoiceParserService();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  String _statusText = '';
  double _soundLevel = 0;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if coming from deep link
      final deepLink = DeepLinkService();
      if (deepLink.shouldAutoStartVoice) {
        deepLink.consumeAutoStartFlag();
      }

      // Auto-start if requested
      if (widget.autoStart) {
        _startListening();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    if (_isInitialized) return;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (_recognizedText.isNotEmpty && !_isProcessing) {
              _processVoiceInput();
            } else {
              _stopListening();
            }
          }
        },
        onError: (error) {
          debugPrint('[Voice] Error: ${error.errorMsg}');
          if (mounted) {
            setState(() {
              _statusText = _getErrorMessage(error.errorMsg);
              _isListening = false;
            });
            _pulseController.stop();
          }
        },
      );
    } catch (e) {
      debugPrint('[Voice] Init error: $e');
    }
  }

  String _getErrorMessage(String error) {
    if (!mounted) return '';
    final l10n = AppLocalizations.of(context);
    if (error.contains('network')) {
      return l10n.networkRequired;
    } else if (error.contains('permission')) {
      return l10n.microphonePermissionRequired;
    }
    return l10n.errorTryAgain;
  }

  Future<void> _startListening() async {
    // Check microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDenied();
      return;
    }

    await _initSpeech();

    if (!_isInitialized) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() => _statusText = l10n.voiceNotAvailable);
      }
      return;
    }

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _isListening = true;
        _statusText = l10n.listening;
        _recognizedText = '';
      });
    }

    _pulseController.repeat(reverse: true);

    // Determine locale
    if (!mounted) return;
    final locale = Localizations.localeOf(context);
    final localeId = locale.languageCode == 'tr' ? 'tr_TR' : 'en_US';

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        }
      },
      onSoundLevelChange: (level) {
        if (mounted) {
          setState(() {
            _soundLevel = level.clamp(0, 10) / 10;
          });
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  void _stopListening() {
    _speech.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
    _pulseController.stop();
    _pulseController.reset();
  }

  Future<void> _processVoiceInput() async {
    if (_recognizedText.isEmpty) return;

    _stopListening();

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _isProcessing = true;
        _statusText = l10n.understanding;
      });
    }

    try {
      final result = await _parser.parse(_recognizedText);

      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (result.isValid) {
        if (result.confidence == VoiceConfidence.high) {
          await _saveExpense(result);
        } else {
          _showConfirmation(result);
        }
      } else {
        _showRetryOption();
      }
    } catch (e) {
      debugPrint('[Voice] Parse error: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _isProcessing = false;
          _statusText = l10n.couldNotUnderstandTryAgain;
        });
      }
    }
  }

  Future<void> _saveExpense(VoiceParseResult result) async {
    // Get expense service
    final expenseService = ExpenseHistoryService();

    // Map API category to app category
    final category = VoiceParserService.mapToAppCategory(result.category);

    // Calculate work time (simplified - actual calculation should use profile data)
    final amount = result.amount!;
    // Approximate: 1 hour = 50 TL (this should use user's hourly rate)
    final hoursRequired = amount / 50.0;
    final daysRequired = hoursRequired / 8.0;

    // Create expense with required fields
    final expense = Expense(
      amount: amount,
      category: category,
      subCategory: result.description,
      date: DateTime.now(),
      hoursRequired: hoursRequired,
      daysRequired: daysRequired,
      decision: ExpenseDecision.yes,
    );

    await expenseService.addExpense(expense);

    HapticFeedback.mediumImpact();

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      setState(() => _statusText = '${l10n.voiceExpenseAdded}!');

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  PhosphorIconsDuotone.checkCircle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${result.amount!.toStringAsFixed(0)} TL ${result.description.isNotEmpty ? result.description : category} eklendi',
                  ),
                ),
              ],
            ),
            backgroundColor: context.appColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showConfirmation(VoiceParseResult result) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.voiceConfirmExpense,
          style: TextStyle(color: context.appColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${result.amount?.toStringAsFixed(0) ?? "?"} TL',
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (result.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                result.description,
                style: TextStyle(
                  color: context.appColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
            if (result.category != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  VoiceParserService.mapToAppCategory(result.category),
                  style: TextStyle(
                    color: context.appColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startListening();
            },
            child: Text(
              l10n.sayAgain,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveExpense(result);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.yesSave),
          ),
        ],
      ),
    );
  }

  void _showRetryOption() {
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      setState(() => _statusText = l10n.couldNotUnderstandSayAgain);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !_isListening) {
          _startListening();
        }
      });
    }
  }

  void _showPermissionDenied() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.microphonePermissionDenied),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: l10n.settings,
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      PhosphorIconsDuotone.x,
                      color: context.appColors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    l10n.voiceInput,
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const Spacer(),

            // Microphone animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, child) {
                final scale = _isListening ? _pulseAnimation.value : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: GestureDetector(
                    onTap: _isListening || _isProcessing
                        ? null
                        : _startListening,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isListening
                              ? [
                                  const Color(0xFFE74C3C),
                                  const Color(0xFFC0392B),
                                ]
                              : [
                                  context.appColors.primary,
                                  context.appColors.secondary,
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isListening
                                        ? const Color(0xFFE74C3C)
                                        : context.appColors.primary)
                                    .withValues(
                                      alpha: _isListening ? 0.6 : 0.4,
                                    ),
                            blurRadius: _isListening ? 50 : 25,
                            spreadRadius: _isListening ? 10 : 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isProcessing
                            ? SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: context.appColors.textPrimary,
                                  strokeWidth: 3,
                                ),
                              )
                            : PhosphorIcon(
                                _isListening
                                    ? PhosphorIconsFill.stop
                                    : PhosphorIconsFill.microphone,
                                color: context.appColors.textPrimary,
                                size: 56,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Sound level indicator
            if (_isListening)
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.2 + (_soundLevel * 0.8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.appColors.primary,
                          context.appColors.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Status text
            Text(
              _statusText.isEmpty ? l10n.tapToSpeak : _statusText,
              style: TextStyle(
                color: _isListening
                    ? const Color(0xFFE74C3C)
                    : context.appColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // Recognized text
            if (_recognizedText.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.appColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.appColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _recognizedText,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const Spacer(),

            // Tips section
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.appColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PhosphorIcon(
                        PhosphorIconsDuotone.lightbulb,
                        color: context.appColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.speakExpense,
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"50 lira kahve"\n"markete 200 TL verdim"\n"uber 85 lira"',
                    style: TextStyle(
                      color: context.appColors.textTertiary,
                      fontSize: 13,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
