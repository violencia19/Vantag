import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../theme/theme.dart';

/// Onboarding checklist widget — simple card, no blur, no heavy animations.
/// Shows 4 items to guide new users. Auto-dismisses when 3/4 complete.
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

class _OnboardingChecklistState extends State<OnboardingChecklist> {
  static const String _keyDismissed = 'onboarding_checklist_dismissed';
  static const String _keyNotifications = 'checklist_notifications_done';

  bool _isDismissed = false;
  bool _isVisible = true; // for fade-out
  bool _notificationsCompleted = false;
  bool _stateLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isDismissed = prefs.getBool(_keyDismissed) ?? false;
      _notificationsCompleted = prefs.getBool(_keyNotifications) ?? false;
      _stateLoaded = true;
    });
  }

  Future<void> _dismiss() async {
    // Fade out first
    setState(() => _isVisible = false);

    // Wait for fade animation, then persist
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDismissed, true);
    if (!mounted) return;
    setState(() => _isDismissed = true);
  }

  Future<void> _markNotificationsDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, true);
    if (!mounted) return;
    setState(() => _notificationsCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed || !_stateLoaded) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final finance = context.watch<FinanceProvider>();
    final pursuit = context.watch<PursuitProvider>();

    final hasExpenses = finance.expenses.isNotEmpty;
    final hasMultipleExpenses = finance.expenses.length >= 3;
    final hasPursuits = pursuit.allPursuits.isNotEmpty;

    final items = [
      _Item(
        title: l10n.checklistFirstExpenseTitle,
        subtitle: l10n.checklistFirstExpenseSubtitle,
        icon: CupertinoIcons.doc_text_fill,
        iconColor: context.vantColors.primary,
        done: hasExpenses,
        onTap: widget.onAddExpense,
      ),
      _Item(
        title: l10n.checklistViewReportTitle,
        subtitle: l10n.checklistViewReportSubtitle,
        icon: CupertinoIcons.chart_bar_fill,
        iconColor: context.vantColors.accent,
        done: hasMultipleExpenses,
        onTap: widget.onViewReport,
      ),
      _Item(
        title: l10n.checklistCreatePursuitTitle,
        subtitle: l10n.checklistCreatePursuitSubtitle,
        icon: CupertinoIcons.scope,
        iconColor: context.vantColors.success,
        done: hasPursuits,
        onTap: widget.onCreatePursuit,
      ),
      _Item(
        title: l10n.checklistNotificationsTitle,
        subtitle: l10n.checklistNotificationsSubtitle,
        icon: CupertinoIcons.bell_fill,
        iconColor: context.vantColors.warning,
        done: _notificationsCompleted,
        onTap: () async {
          HapticFeedback.lightImpact();
          final granted = await NotificationService().requestPermission();
          if (granted) await _markNotificationsDone();
          widget.onEnableNotifications?.call();
        },
      ),
    ];

    final completedCount = items.where((i) => i.done).length;
    final progress = completedCount / items.length;

    // Auto-dismiss when 3/4 complete
    if (completedCount >= 3 && _isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isVisible) {
          AnalyticsService().logChecklistCompleted(totalTimeMinutes: 5);
          _dismiss();
        }
      });
    }

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: context.vantColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.vantColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.checklistTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.vantColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.checklistProgress(completedCount, items.length),
                            style: TextStyle(
                              fontSize: 13,
                              color: context.vantColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        AnalyticsService().logChecklistDismissed(
                          completedCount: completedCount,
                        );
                        _dismiss();
                      },
                      icon: Icon(
                        CupertinoIcons.xmark,
                        size: 18,
                        color: context.vantColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: context.vantColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation(context.vantColors.success),
                    minHeight: 5,
                  ),
                ),
              ),

              // Items
              ...items.map((item) => _buildItem(context, item)),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _Item item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.done ? null : item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.done
                      ? context.vantColors.success.withValues(alpha: 0.15)
                      : item.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.done ? CupertinoIcons.checkmark_circle_fill : item.icon,
                  size: 20,
                  color: item.done ? context.vantColors.success : item.iconColor,
                ),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: item.done
                            ? context.vantColors.textTertiary
                            : context.vantColors.textPrimary,
                        decoration: item.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vantColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing
              if (item.done)
                Icon(
                  CupertinoIcons.checkmark,
                  size: 18,
                  color: context.vantColors.success,
                )
              else
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: context.vantColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple data holder for a checklist item.
class _Item {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool done;
  final VoidCallback? onTap;

  const _Item({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.done,
    this.onTap,
  });
}

/// Extension to check if checklist should be shown.
extension OnboardingChecklistExtension on BuildContext {
  Future<bool> shouldShowOnboardingChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_checklist_dismissed') ?? false);
  }
}
