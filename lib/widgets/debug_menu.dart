import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/services.dart';
import '../theme/theme.dart';

/// Task 90: Debug Menu
/// Developer-only menu for testing and debugging
/// Only visible in debug mode or when unlocked via secret gesture
class DebugMenu extends StatefulWidget {
  const DebugMenu({super.key});

  /// Show debug menu via bottom sheet
  static Future<void> show(BuildContext context) async {
    // Only allow in debug mode
    if (!kDebugMode) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DebugMenu(),
    );
  }

  /// Check if debug menu should be enabled
  static bool get isEnabled => kDebugMode;

  @override
  State<DebugMenu> createState() => _DebugMenuState();
}

class _DebugMenuState extends State<DebugMenu> {
  final _streakService = StreakService();
  final _notificationService = NotificationService();

  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final streakData = await _streakService.getStreakData();

    setState(() {
      _stats = {
        'Current Streak': streakData.currentStreak,
        'Longest Streak': streakData.longestStreak,
        'Is Stale': streakData.isStale,
        'Platform': Platform.operatingSystem,
        'Debug Mode': kDebugMode,
        'Prefs Keys': prefs.getKeys().length,
      };
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.appColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsDuotone.bug,
                  color: context.appColors.warning,
                ),
                const SizedBox(width: 12),
                Text(
                  'Debug Menu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.appColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DEV ONLY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Stats section
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSection('App Stats', [
                  ..._stats.entries.map((e) => _buildStatRow(e.key, e.value.toString())),
                ]),
                _buildSection('Quick Actions', [
                  _buildActionButton(
                    'Reset Streak',
                    PhosphorIconsDuotone.arrowCounterClockwise,
                    () async {
                      await _streakService.resetAllStreakData();
                      HapticFeedback.heavyImpact();
                      _loadStats();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Streak reset!')),
                        );
                      }
                    },
                  ),
                  _buildActionButton(
                    'Clear Notifications',
                    PhosphorIconsDuotone.bellSlash,
                    () async {
                      await _notificationService.cancelAll();
                      HapticFeedback.mediumImpact();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifications cleared!')),
                        );
                      }
                    },
                  ),
                  _buildActionButton(
                    'Test Achievement Notification',
                    PhosphorIconsDuotone.trophy,
                    () async {
                      await _notificationService.showAchievementUnlocked(
                        achievementTitle: 'Test Achievement',
                        achievementDescription: 'This is a test notification',
                      );
                      HapticFeedback.lightImpact();
                    },
                  ),
                  _buildActionButton(
                    'Clear SharedPreferences',
                    PhosphorIconsDuotone.trash,
                    () async {
                      final confirmed = await _showConfirmDialog(
                        context,
                        'Clear All Data?',
                        'This will reset all app data. Are you sure?',
                      );
                      if (confirmed == true) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        HapticFeedback.heavyImpact();
                        _loadStats();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All data cleared!')),
                          );
                        }
                      }
                    },
                    isDestructive: true,
                  ),
                ]),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.appColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.appColors.textPrimary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isDestructive
                      ? context.appColors.error
                      : context.appColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDestructive
                          ? context.appColors.error
                          : context.appColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  PhosphorIconsDuotone.caretRight,
                  size: 16,
                  color: context.appColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.surface,
        title: Text(
          title,
          style: TextStyle(color: context.appColors.textPrimary),
        ),
        content: Text(
          message,
          style: TextStyle(color: context.appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirm',
              style: TextStyle(color: context.appColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Secret tap gesture to unlock debug menu
/// Wrap around any widget to enable debug menu access
class DebugMenuTrigger extends StatefulWidget {
  final Widget child;
  final int requiredTaps;

  const DebugMenuTrigger({
    super.key,
    required this.child,
    this.requiredTaps = 7,
  });

  @override
  State<DebugMenuTrigger> createState() => _DebugMenuTriggerState();
}

class _DebugMenuTriggerState extends State<DebugMenuTrigger> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();

    // Reset if more than 2 seconds since last tap
    if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds > 2) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = now;

    if (_tapCount >= widget.requiredTaps) {
      _tapCount = 0;
      HapticFeedback.heavyImpact();
      DebugMenu.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only wrap in debug mode
    if (!kDebugMode) return widget.child;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
