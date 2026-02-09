import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'tour_service.dart';

/// App tour using tutorial_coach_mark.
/// Triggers ONCE after first login, walks through 7 home-screen stops.
class AppTourService {
  static const _prefKey = 'app_tour_completed';

  /// Check if tour has been completed
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Mark tour as completed
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  /// Reset tour (for testing / settings)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  /// Show the tour if not yet completed.
  /// Call from MainScreen after the first frame is rendered.
  static Future<void> showIfNeeded(BuildContext context) async {
    if (await isCompleted()) return;
    if (!context.mounted) return;

    // Small delay so widgets have settled
    await Future.delayed(const Duration(milliseconds: 800));
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final targets = _buildTargets(l10n);

    // Filter out targets whose keys aren't attached to a widget
    final validTargets = targets.where((t) {
      return t.keyTarget?.currentContext != null;
    }).toList();

    if (validTargets.isEmpty) return;

    TutorialCoachMark(
      targets: validTargets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      textSkip: l10n.tourSkip,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 300),
      unFocusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      textStyleSkip: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      beforeFocus: (target) async {
        final keyContext = target.keyTarget?.currentContext;
        if (keyContext != null) {
          await Scrollable.ensureVisible(
            keyContext,
            duration: const Duration(milliseconds: 300),
          );
        }
      },
      onFinish: () => markCompleted(),
      onSkip: () {
        markCompleted();
        return true;
      },
    ).show(context: context);
  }

  static List<TargetFocus> _buildTargets(AppLocalizations l10n) {
    return [
      // 1. Profile avatar
      _target(
        key: TourKeys.tourProfileAvatar,
        shape: ShapeLightFocus.Circle,
        title: l10n.tourProfileTitle,
        description: l10n.tourProfileDesc,
        align: ContentAlign.bottom,
        isFirst: true,
      ),
      // 2. Hero card (work hours)
      _target(
        key: TourKeys.tourHeroCard,
        shape: ShapeLightFocus.RRect,
        title: l10n.tourHeroCardTitle,
        description: l10n.tourHeroCardDesc,
        align: ContentAlign.bottom,
      ),
      // 3. Habit calculator
      _target(
        key: TourKeys.tourHabitCalc,
        shape: ShapeLightFocus.RRect,
        title: l10n.tourHabitCalcTitle,
        description: l10n.tourHabitCalcDesc,
        align: ContentAlign.top,
      ),
      // 4. FAB (+) button
      _target(
        key: TourKeys.tourFabButton,
        shape: ShapeLightFocus.Circle,
        title: l10n.tourFabTitle,
        description: l10n.tourFabDesc,
        align: ContentAlign.top,
      ),
      // 5. Reports tab
      _target(
        key: TourKeys.tourReportsTab,
        shape: ShapeLightFocus.RRect,
        title: l10n.tourReportsTabTitle,
        description: l10n.tourReportsTabDesc,
        align: ContentAlign.top,
      ),
      // 6. Pursuits tab
      _target(
        key: TourKeys.tourPursuitsTab,
        shape: ShapeLightFocus.RRect,
        title: l10n.tourPursuitsTabTitle,
        description: l10n.tourPursuitsTabDesc,
        align: ContentAlign.top,
      ),
      // 7. Settings tab
      _target(
        key: TourKeys.tourSettingsTab,
        shape: ShapeLightFocus.RRect,
        title: l10n.tourSettingsTabTitle,
        description: l10n.tourSettingsTabDesc,
        align: ContentAlign.top,
        isLast: true,
      ),
    ];
  }

  static TargetFocus _target({
    required GlobalKey key,
    required ShapeLightFocus shape,
    required String title,
    required String description,
    required ContentAlign align,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TargetFocus(
      identify: key.toString(),
      keyTarget: key,
      shape: shape,
      radius: 12,
      paddingFocus: 6,
      enableTargetTab: false,
      enableOverlayTab: false,
      contents: [
        TargetContent(
          align: align,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          builder: (context, controller) {
            final l10n = AppLocalizations.of(context);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFFEFACD),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isLast)
                      GestureDetector(
                        onTap: () => controller.next(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5F4A8B), Color(0xFF7B62A8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.tourNext,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    if (isLast)
                      GestureDetector(
                        onTap: () => controller.next(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF34D399)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.tourDone,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
