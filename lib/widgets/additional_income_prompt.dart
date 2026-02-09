
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../screens/income_wizard_screen.dart';

/// Prompt card asking users if they have additional income
/// Glassmorphism design with yes/no options
class AdditionalIncomePrompt extends StatelessWidget {
  final VoidCallback? onYes;
  final VoidCallback? onNo;

  const AdditionalIncomePrompt({
    super.key,
    this.onYes,
    this.onNo,
  });

  void _openIncomeWizard(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IncomeWizardScreen(
          skipToAdditional: true,
        ),
      ),
    ).then((_) {
      onYes?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.vantColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.vantColors.success.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.vantColors.success.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.vantColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.money_dollar_circle_fill,
                      size: 28,
                      color: context.vantColors.success,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  l10n.additionalIncomePromptTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.vantColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  l10n.additionalIncomePromptSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.vantColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons row
                Row(
                  children: [
                    // Yes button
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: l10n.additionalIncomeYes,
                        child: GestureDetector(
                          onTap: () => _openIncomeWizard(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: context.vantColors.success,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.plus_circle_fill,
                                    size: 18,
                                    color: context.vantColors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.additionalIncomeYes,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.vantColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // No button
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: l10n.additionalIncomeNo,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onNo?.call();
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: context.vantColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.vantColors.cardBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                l10n.additionalIncomeNo,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.vantColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
