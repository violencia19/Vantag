import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import 'main_screen.dart';

/// Preset goal data for onboarding
class _PresetGoal {
  final String id;
  final String Function(AppLocalizations) getName;
  final IconData icon;
  final int estimatedHours;
  final double targetAmount;
  final String emoji;

  const _PresetGoal({
    required this.id,
    required this.getName,
    required this.icon,
    required this.estimatedHours,
    required this.targetAmount,
    required this.emoji,
  });
}

/// Preset goals for onboarding
final List<_PresetGoal> _presetGoals = [
  _PresetGoal(
    id: 'airpods',
    getName: (l10n) => l10n.pursuitOnboardingAirpods,
    icon: CupertinoIcons.headphones,
    estimatedHours: 50,
    targetAmount: 8000,
    emoji: '🎧',
  ),
  _PresetGoal(
    id: 'iphone',
    getName: (l10n) => l10n.pursuitOnboardingIphone,
    icon: CupertinoIcons.device_phone_portrait,
    estimatedHours: 400,
    targetAmount: 65000,
    emoji: '📱',
  ),
  _PresetGoal(
    id: 'vacation',
    getName: (l10n) => l10n.pursuitOnboardingVacation,
    icon: CupertinoIcons.airplane,
    estimatedHours: 200,
    targetAmount: 30000,
    emoji: '✈️',
  ),
  _PresetGoal(
    id: 'custom',
    getName: (l10n) => l10n.pursuitOnboardingCustom,
    icon: CupertinoIcons.add,
    estimatedHours: 0,
    targetAmount: 0,
    emoji: '✨',
  ),
];

/// Keys for storing pending pursuit in SharedPreferences
class PendingPursuitKeys {
  static const String hasPending = 'pending_pursuit_has';
  static const String goalId = 'pending_pursuit_goal_id';
  static const String goalName = 'pending_pursuit_name';
  static const String goalAmount = 'pending_pursuit_amount';
  static const String goalEmoji = 'pending_pursuit_emoji';
  static const String isCustom = 'pending_pursuit_is_custom';
}

/// Onboarding screen for selecting a savings goal
/// Shown after OnboardingTryScreen, before MainScreen
class OnboardingPursuitScreen extends StatefulWidget {
  const OnboardingPursuitScreen({super.key});

  @override
  State<OnboardingPursuitScreen> createState() =>
      _OnboardingPursuitScreenState();
}

class _OnboardingPursuitScreenState extends State<OnboardingPursuitScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedGoalId;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
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
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _savePendingPursuit(
    _PresetGoal goal,
    AppLocalizations l10n,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PendingPursuitKeys.hasPending, true);
    await prefs.setString(PendingPursuitKeys.goalId, goal.id);
    await prefs.setString(PendingPursuitKeys.goalName, goal.getName(l10n));
    await prefs.setDouble(PendingPursuitKeys.goalAmount, goal.targetAmount);
    await prefs.setString(PendingPursuitKeys.goalEmoji, goal.emoji);
    await prefs.setBool(PendingPursuitKeys.isCustom, goal.id == 'custom');
  }

  void _onGoalSelected(String goalId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedGoalId = goalId;
    });
  }

  Future<void> _continueWithGoal() async {
    if (_selectedGoalId == null) return;

    HapticFeedback.mediumImpact();

    final l10n = AppLocalizations.of(context);
    final selectedGoal = _presetGoals.firstWhere(
      (g) => g.id == _selectedGoalId,
    );

    // Save pending pursuit for MainScreen to create
    await _savePendingPursuit(selectedGoal, l10n);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _skip() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
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

              // Header
              Text(
                l10n.pursuitOnboardingTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.pursuitOnboardingSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: context.appColors.textSecondary,
                ),
              ),

              const Spacer(flex: 1),

              // Goal grid (2x2)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: _presetGoals.map((goal) {
                  final isSelected = _selectedGoalId == goal.id;
                  return _GoalCard(
                    goal: goal,
                    isSelected: isSelected,
                    onTap: () => _onGoalSelected(goal.id),
                    l10n: l10n,
                  );
                }).toList(),
              ),

              const Spacer(flex: 2),

              // CTA Button
              RepaintBoundary(
                child: GestureDetector(
                  onTapDown: _selectedGoalId != null
                      ? (_) => _buttonAnimationController.forward()
                      : null,
                  onTapUp: _selectedGoalId != null
                      ? (_) {
                          _buttonAnimationController.reverse();
                          _continueWithGoal();
                        }
                      : null,
                  onTapCancel: _selectedGoalId != null
                      ? () => _buttonAnimationController.reverse()
                      : null,
                  child: ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: _selectedGoalId != null
                            ? context.appColors.primary
                            : context.appColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _selectedGoalId != null
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
                        l10n.pursuitOnboardingCta,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _selectedGoalId != null
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
                  l10n.pursuitOnboardingSkip,
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

/// Individual goal card widget
class _GoalCard extends StatelessWidget {
  final _PresetGoal goal;
  final bool isSelected;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = goal.id == 'custom';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? context.appColors.primary
                : context.appColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.appColors.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon container
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.appColors.primary.withValues(
                                  alpha: 0.15,
                                )
                              : context.appColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          goal.icon,
                          size: 28,
                          color: isSelected
                              ? context.appColors.primary
                              : context.appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Name
                      Text(
                        goal.getName(l10n),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Hours estimate (not for custom)
                      if (!isCustom)
                        Text(
                          '~${l10n.pursuitOnboardingHours(goal.estimatedHours)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.appColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),

                // Selected checkmark
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.appColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.checkmark,
                        size: 14,
                        color: context.appColors.background,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
