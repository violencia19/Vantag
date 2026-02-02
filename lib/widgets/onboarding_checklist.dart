import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../theme/theme.dart';

/// Checklist item data model
class ChecklistItem {
  final String id;
  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;
  final Color iconColor;
  final bool isCompleted;
  final VoidCallback? onTap;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
    required this.iconColor,
    required this.isCompleted,
    this.onTap,
  });
}

/// Onboarding checklist widget for main screen
/// Shows 4 quick-win items to guide new users
/// Dismisses after 3 items completed with celebration
class OnboardingChecklist extends StatefulWidget {
  final VoidCallback? onAddExpense;
  final VoidCallback? onViewReport;
  final VoidCallback? onCreatePursuit;
  final VoidCallback? onEnableNotifications;

  const OnboardingChecklist({
    super.key,
    this.onAddExpense,
    this.onViewReport,
    this.onCreatePursuit,
    this.onEnableNotifications,
  });

  @override
  State<OnboardingChecklist> createState() => _OnboardingChecklistState();
}

class _OnboardingChecklistState extends State<OnboardingChecklist>
    with SingleTickerProviderStateMixin {
  static const String _keyChecklistDismissed = 'onboarding_checklist_dismissed';
  static const String _keyNotificationsEnabled = 'checklist_notifications_done';

  late ConfettiController _confettiController;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;

  bool _isDismissed = false;
  bool _showCelebration = false;
  bool _notificationsCompleted = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebrationScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.elasticOut,
      ),
    );
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isDismissed = prefs.getBool(_keyChecklistDismissed) ?? false;
        _notificationsCompleted = prefs.getBool(_keyNotificationsEnabled) ?? false;
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _dismissChecklist({bool isDismissedEarly = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyChecklistDismissed, true);

    if (isDismissedEarly) {
      // Track early dismissal
      final financeProvider = context.read<FinanceProvider>();
      final pursuitProvider = context.read<PursuitProvider>();
      int completedCount = 0;
      if (financeProvider.expenses.isNotEmpty) completedCount++;
      if (financeProvider.expenses.length >= 3) completedCount++;
      if (pursuitProvider.allPursuits.isNotEmpty) completedCount++;
      if (_notificationsCompleted) completedCount++;

      AnalyticsService().logChecklistDismissed(completedCount: completedCount);
    }

    setState(() {
      _isDismissed = true;
    });
  }

  Future<void> _markNotificationsDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, true);
    setState(() {
      _notificationsCompleted = true;
    });
  }

  void _checkCompletion(List<ChecklistItem> items) {
    final completedCount = items.where((i) => i.isCompleted).length;

    // Show celebration when 3 items completed
    if (completedCount >= 3 && !_showCelebration) {
      _showCelebration = true;
      _confettiController.play();
      _celebrationController.forward();
      HapticFeedback.heavyImpact();

      // Track analytics
      AnalyticsService().logChecklistCompleted(totalTimeMinutes: 5); // Estimate
      AnalyticsService().logCelebrationShown(
        celebrationType: 'confetti',
        milestoneName: 'checklist_completed',
      );

      // Auto-dismiss after celebration
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _dismissChecklist();
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final financeProvider = context.watch<FinanceProvider>();
    final pursuitProvider = context.watch<PursuitProvider>();

    // Build checklist items
    final items = _buildItems(
      l10n,
      financeProvider,
      pursuitProvider,
    );

    // Check if should show celebration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCompletion(items);
    });

    final completedCount = items.where((i) => i.isCompleted).length;
    final progress = completedCount / items.length;

    return Stack(
      children: [
        // Main checklist card
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _showCelebration
              ? _buildCelebrationCard(l10n, completedCount)
              : _buildChecklistCard(l10n, items, progress, completedCount),
        ),

        // Confetti
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: [
                context.appColors.primary,
                context.appColors.accent,
                context.appColors.success,
                context.appColors.warning,
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<ChecklistItem> _buildItems(
    AppLocalizations l10n,
    FinanceProvider financeProvider,
    PursuitProvider pursuitProvider,
  ) {
    final hasExpenses = financeProvider.expenses.isNotEmpty;
    final hasPursuits = pursuitProvider.allPursuits.isNotEmpty;
    final hasMultipleExpenses = financeProvider.expenses.length >= 3;

    final items = <ChecklistItem>[
      // Item 1: Add first expense (quick win)
      ChecklistItem(
        id: 'add_expense',
        title: l10n.checklistFirstExpenseTitle,
        subtitle: l10n.checklistFirstExpenseSubtitle,
        duration: '1 dk',
        icon: CupertinoIcons.doc_text_fill,
        iconColor: context.appColors.primary,
        isCompleted: hasExpenses,
        onTap: widget.onAddExpense,
      ),

      // Item 2: View your first report
      ChecklistItem(
        id: 'view_report',
        title: l10n.checklistViewReportTitle,
        subtitle: l10n.checklistViewReportSubtitle,
        duration: '30 sn',
        icon: CupertinoIcons.chart_bar_fill,
        iconColor: context.appColors.accent,
        isCompleted: hasMultipleExpenses, // Needs some data to be meaningful
        onTap: widget.onViewReport,
      ),

      // Item 3: Create a savings goal
      ChecklistItem(
        id: 'create_pursuit',
        title: l10n.checklistCreatePursuitTitle,
        subtitle: l10n.checklistCreatePursuitSubtitle,
        duration: '1 dk',
        icon: CupertinoIcons.scope,
        iconColor: context.appColors.success,
        isCompleted: hasPursuits,
        onTap: widget.onCreatePursuit,
      ),

      // Item 4: Enable notifications
      ChecklistItem(
        id: 'enable_notifications',
        title: l10n.checklistNotificationsTitle,
        subtitle: l10n.checklistNotificationsSubtitle,
        duration: '30 sn',
        icon: CupertinoIcons.bell_fill,
        iconColor: context.appColors.warning,
        isCompleted: _notificationsCompleted,
        onTap: () async {
          HapticFeedback.lightImpact();
          final granted = await NotificationService().requestPermission();
          if (granted) {
            await _markNotificationsDone();
            // Calculate completed count manually
            int completedCount = 0;
            if (hasExpenses) completedCount++;
            if (hasMultipleExpenses) completedCount++;
            if (hasPursuits) completedCount++;
            completedCount++; // This notification item
            AnalyticsService().logChecklistItemCompleted(
              itemName: 'enable_notifications',
              itemIndex: 3,
              totalCompleted: completedCount,
            );
          }
          widget.onEnableNotifications?.call();
        },
      ),
    ];
    return items;
  }

  Widget _buildChecklistCard(
    AppLocalizations l10n,
    List<ChecklistItem> items,
    double progress,
    int completedCount,
  ) {
    return Padding(
      key: const ValueKey('checklist'),
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              // Glass effect: semi-transparent with blur
              color: context.appColors.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.appColors.primary.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with progress
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.checklistTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.checklistProgress(completedCount, items.length),
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dismiss button
                IconButton(
                  onPressed: () => _dismissChecklist(isDismissedEarly: true),
                  icon: Icon(
                    CupertinoIcons.xmark,
                    size: 20,
                    color: context.appColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: context.appColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation(context.appColors.success),
                minHeight: 6,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Checklist items
          ...items.map((item) => _buildChecklistItem(item)),

          const SizedBox(height: 8),
        ],
      ),
    ), // Container
  ), // BackdropFilter
), // ClipRRect
    ); // Padding
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.isCompleted ? null : item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Status indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.isCompleted
                      ? context.appColors.success.withValues(alpha: 0.15)
                      : item.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: item.isCompleted
                        ? context.appColors.success.withValues(alpha: 0.3)
                        : item.iconColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  item.isCompleted ? CupertinoIcons.checkmark_circle_fill : item.icon,
                  size: 22,
                  color: item.isCompleted
                      ? context.appColors.success
                      : item.iconColor,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: item.isCompleted
                            ? context.appColors.textTertiary
                            : context.appColors.textPrimary,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Duration badge or checkmark
              if (!item.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.duration,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                )
              else
                Icon(
                  CupertinoIcons.checkmark,
                  size: 20,
                  color: context.appColors.success,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationCard(AppLocalizations l10n, int completedCount) {
    return ScaleTransition(
      scale: _celebrationScale,
      child: Container(
        key: const ValueKey('celebration'),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.appColors.success.withValues(alpha: 0.15),
              context.appColors.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.appColors.success.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.appColors.success.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.rosette,
                size: 32,
                color: context.appColors.success,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              l10n.checklistCelebrationTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              l10n.checklistCelebrationSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension to check if checklist should be shown
extension OnboardingChecklistExtension on BuildContext {
  Future<bool> shouldShowOnboardingChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_checklist_dismissed') ?? false);
  }
}
