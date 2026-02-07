import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../services/notification_service.dart';
import '../theme/theme.dart';

/// Onboarding screen for selecting salary day
/// Shown during onboarding flow after income wizard
class OnboardingSalaryDayScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const OnboardingSalaryDayScreen({
    super.key,
    required this.onComplete,
    this.onSkip,
  });

  @override
  State<OnboardingSalaryDayScreen> createState() =>
      _OnboardingSalaryDayScreenState();
}

class _OnboardingSalaryDayScreenState extends State<OnboardingSalaryDayScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedDay;
  late FixedExtentScrollController _dayController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _dayController = FixedExtentScrollController(initialItem: 0);
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _saveSalaryDay() async {
    if (_selectedDay == null) return;

    HapticFeedback.mediumImpact();

    final financeProvider = context.read<FinanceProvider>();
    final profile = financeProvider.userProfile;

    if (profile != null) {
      final updatedProfile = profile.copyWith(salaryDay: _selectedDay);
      financeProvider.setUserProfile(updatedProfile);

      // Schedule payday notification
      await NotificationService().schedulePaydayNotification(
        salaryDay: _selectedDay!,
      );
    }

    widget.onComplete();
  }

  void _skip() {
    HapticFeedback.lightImpact();
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      widget.onComplete();
    }
  }

  void _onDaySelected(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDay = index + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),

              // Icon
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  CupertinoIcons.calendar_badge_plus,
                  size: 40,
                  color: context.appColors.primary,
                ),
              ),

              // Title
              Text(
                l10n.onboardingSalaryDayTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                l10n.onboardingSalaryDayDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: context.appColors.textSecondary,
                ),
              ),

              const Spacer(flex: 1),

              // Day Picker
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Day selector
                    SizedBox(
                      width: 100,
                      child: ListWheelScrollView.useDelegate(
                        controller: _dayController,
                        itemExtent: 60,
                        perspective: 0.005,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: _onDaySelected,
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 31,
                          builder: (context, index) {
                            final day = index + 1;
                            final isSelected = _selectedDay == day;
                            return Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: isSelected ? 36 : 24,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? context.appColors.primary
                                      : context.appColors.textTertiary,
                                ),
                                child: Text('$day'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Selected day indicator
              if (_selectedDay != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.appColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.calendar_badge_plus,
                        size: 20,
                        color: context.appColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.dayOfMonth(_selectedDay!),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(flex: 2),

              // CTA Button
              RepaintBoundary(
                child: GestureDetector(
                  onTapDown: _selectedDay != null
                      ? (_) => _buttonAnimationController.forward()
                      : null,
                  onTapUp: _selectedDay != null
                      ? (_) {
                          _buttonAnimationController.reverse();
                          _saveSalaryDay();
                        }
                      : null,
                  onTapCancel: _selectedDay != null
                      ? () => _buttonAnimationController.reverse()
                      : null,
                  child: ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: _selectedDay != null
                            ? context.appColors.primary
                            : context.appColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _selectedDay != null
                            ? [
                                BoxShadow(
                                  color: context.appColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        l10n.save,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _selectedDay != null
                              ? context.appColors.background
                              : context.appColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip link
              TextButton(
                onPressed: _skip,
                child: Text(
                  l10n.salaryDaySkip,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.appColors.textTertiary,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
