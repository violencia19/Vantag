import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../services/services.dart';
import '../theme/theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _notificationService = NotificationService();
  Map<String, bool> _settings = {};
  bool _isLoading = true;
  int _dailyReminderHour = 20;
  int _dailyReminderMinute = 0;
  int? _trialDaysRemaining;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.getSettings();
    final dailyTime = await _notificationService.getDailyReminderTime();
    final trialDays = await _notificationService.getTrialDaysRemaining();

    if (mounted) {
      setState(() {
        _settings = settings;
        _dailyReminderHour = dailyTime?.hour ?? 20;
        _dailyReminderMinute = dailyTime?.minute ?? 0;
        _trialDaysRemaining = trialDays;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    setState(() => _settings[key] = value);
    await _notificationService.updateSetting(key, value);
  }

  Future<void> _selectDailyReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _dailyReminderHour,
        minute: _dailyReminderMinute,
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        _dailyReminderHour = picked.hour;
        _dailyReminderMinute = picked.minute;
      });
      await _notificationService.scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
      );
    }
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.vantColors.background,
      appBar: AppBar(
        backgroundColor: context.vantColors.background,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.arrow_left,
            color: context.vantColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notificationSettings,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: context.vantColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Master switch
                  _buildMasterSwitch(context),
                  const SizedBox(height: 24),

                  // Notification types
                  if (_settings['enabled'] == true) ...[
                    Text(
                      l10n.notificationTypes,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildSettingTile(
                      title: l10n.awarenessReminder,
                      subtitle: l10n.awarenessReminderDesc,
                      key: 'delayedAwareness',
                      icon: CupertinoIcons.lightbulb_fill,
                    ),
                    const SizedBox(height: 12),

                    _buildSettingTile(
                      title: l10n.giveUpCongrats,
                      subtitle: l10n.giveUpCongratsDesc,
                      key: 'reinforce',
                      icon: CupertinoIcons.star_fill,
                    ),
                    const SizedBox(height: 12),

                    _buildSettingTile(
                      title: l10n.streakReminder,
                      subtitle: l10n.streakReminderDesc,
                      key: 'streakReminder',
                      icon: CupertinoIcons.flame_fill,
                    ),
                    const SizedBox(height: 12),

                    _buildSettingTile(
                      title: l10n.weeklySummary,
                      subtitle: l10n.weeklySummaryDesc,
                      key: 'weeklyInsight',
                      icon: CupertinoIcons.chart_bar_fill,
                    ),
                    const SizedBox(height: 12),

                    _buildSettingTile(
                      title: l10n.subscriptionReminder,
                      subtitle: l10n.subscriptionReminderDesc,
                      key: 'subscriptionReminder',
                      icon: CupertinoIcons.calendar_badge_plus,
                    ),

                    const SizedBox(height: 24),

                    // Trial & Daily Reminders Section
                    Text(
                      l10n.trialReminderEnabled,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.vantColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Trial days remaining indicator
                    if (_trialDaysRemaining != null &&
                        _trialDaysRemaining! > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.vantColors.primary.withValues(alpha: 0.1),
                              context.vantColors.accent.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.vantColors.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.clock_fill,
                              size: 24,
                              color: context.vantColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.trialDaysRemaining(_trialDaysRemaining!),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.vantColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    _buildSettingTile(
                      title: l10n.trialReminderEnabled,
                      subtitle: l10n.trialReminderDesc,
                      key: 'trialReminder',
                      icon: CupertinoIcons.gift_fill,
                    ),
                    const SizedBox(height: 12),

                    _buildSettingTile(
                      title: l10n.dailyReminderEnabled,
                      subtitle: l10n.dailyReminderDesc,
                      key: 'dailyReminder',
                      icon: CupertinoIcons.alarm_fill,
                    ),

                    // Daily reminder time picker
                    if (_settings['dailyReminder'] == true) ...[
                      const SizedBox(height: 12),
                      _buildTimePicker(l10n),
                    ],

                    const SizedBox(height: 32),

                    // Info note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.vantColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.vantColors.cardBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.info_circle_fill,
                            size: 18,
                            color: context.vantColors.textTertiary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.nightModeNotice,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.vantColors.textTertiary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildMasterSwitch(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEnabled = _settings['enabled'] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled
            ? context.vantColors.primary.withValues(alpha: 0.1)
            : context.vantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled
              ? context.vantColors.primary.withValues(alpha: 0.3)
              : context.vantColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isEnabled
                  ? context.vantColors.primary.withValues(alpha: 0.2)
                  : context.vantColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEnabled
                  ? CupertinoIcons.bell_fill
                  : CupertinoIcons.bell_slash_fill,
              size: 24,
              color: isEnabled
                  ? context.vantColors.primary
                  : context.vantColors.textTertiary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.notifications,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.vantColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEnabled ? l10n.on : l10n.off,
                  style: TextStyle(
                    fontSize: 13,
                    color: isEnabled
                        ? context.vantColors.primary
                        : context.vantColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => _updateSetting('enabled', value),
            activeTrackColor: context.vantColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _selectDailyReminderTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.vantColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.vantColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.vantColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.clock,
                size: 20,
                color: context.vantColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dailyReminderTime,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.vantColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(_dailyReminderHour, _dailyReminderMinute),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.vantColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: context.vantColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required String key,
    required IconData icon,
  }) {
    final isEnabled = _settings[key] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.vantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.vantColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.vantColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? context.vantColors.textSecondary
                  : context.vantColors.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isEnabled
                        ? context.vantColors.textPrimary
                        : context.vantColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.vantColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => _updateSetting(key, value),
            activeTrackColor: context.vantColors.primary,
          ),
        ],
      ),
    );
  }
}
