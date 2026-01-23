import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Google Assistant Routine setup guide
/// Walks user through setting up "Hey Google, harcama ekle" routine
class AssistantSetupScreen extends StatefulWidget {
  const AssistantSetupScreen({super.key});

  @override
  State<AssistantSetupScreen> createState() => _AssistantSetupScreenState();
}

class _AssistantSetupScreenState extends State<AssistantSetupScreen> {
  int _currentStep = 0;

  late List<_SetupStep> _steps;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);

    _steps = [
      _SetupStep(
        icon: PhosphorIconsDuotone.robot,
        title: l10n.assistantSetupStep1Title,
        description: l10n.assistantSetupStep1Desc,
        tip: l10n.assistantSetupStep1Tip,
      ),
      _SetupStep(
        icon: PhosphorIconsDuotone.path,
        title: l10n.assistantSetupStep2Title,
        description: l10n.assistantSetupStep2Desc,
        tip: l10n.assistantSetupStep2Tip,
      ),
      _SetupStep(
        icon: PhosphorIconsDuotone.plusCircle,
        title: l10n.assistantSetupStep3Title,
        description: l10n.assistantSetupStep3Desc,
        tip: l10n.assistantSetupStep3Tip,
      ),
      _SetupStep(
        icon: PhosphorIconsDuotone.microphone,
        title: l10n.assistantSetupStep4Title,
        description: l10n.assistantSetupStep4Desc,
        tip: l10n.assistantSetupStep4Tip,
      ),
      _SetupStep(
        icon: PhosphorIconsDuotone.deviceMobile,
        title: l10n.assistantSetupStep5Title,
        description: l10n.assistantSetupStep5Desc,
        tip: l10n.assistantSetupStep5Tip,
      ),
      _SetupStep(
        icon: PhosphorIconsDuotone.floppyDisk,
        title: l10n.assistantSetupStep6Title,
        description: l10n.assistantSetupStep6Desc,
        tip: l10n.assistantSetupStep6Tip,
      ),
    ];
  }

  Future<void> _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('assistant_setup_completed', true);

    if (mounted) {
      Navigator.pop(context);

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(PhosphorIconsDuotone.checkCircle, color: context.appColors.textPrimary),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.assistantSetupComplete)),
            ],
          ),
          backgroundColor: context.appColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
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
            PhosphorIconsDuotone.x,
            color: context.appColors.textSecondary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.assistantSetupTitle,
          style: TextStyle(
            color: context.appColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: PhosphorIcon(
                    PhosphorIconsDuotone.robot,
                    size: 48,
                    color: context.appColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.assistantSetupHeadline,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.assistantSetupSubheadline,
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(_steps.length, (index) {
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? context.appColors.primary
                          : context.appColors.surfaceLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 8),

          // Step counter
          Text(
            '${l10n.step} ${_currentStep + 1} / ${_steps.length}',
            style: TextStyle(
              color: context.appColors.textTertiary,
              fontSize: 12,
            ),
          ),

          // Step content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),

                  // Step icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.appColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: PhosphorIcon(
                      _steps[_currentStep].icon,
                      size: 48,
                      color: context.appColors.primary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Step title
                  Text(
                    _steps[_currentStep].title,
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Step description
                  Text(
                    _steps[_currentStep].description,
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Tip box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.appColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.appColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIconsDuotone.lightbulb,
                          color: context.appColors.warning,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _steps[_currentStep].tip,
                            style: TextStyle(
                              color: context.appColors.warning,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Back button
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _currentStep--);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: context.appColors.textTertiary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.back,
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                if (_currentStep > 0) const SizedBox(width: 12),

                // Next/Complete button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < _steps.length - 1) {
                        setState(() => _currentStep++);
                      } else {
                        _completeSetup();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.primary,
                      foregroundColor: context.appColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep < _steps.length - 1
                          ? l10n.next
                          : l10n.completed,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Skip option
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.laterButton,
              style: TextStyle(color: context.appColors.textTertiary),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SetupStep {
  final IconData icon;
  final String title;
  final String description;
  final String tip;

  _SetupStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.tip,
  });
}
