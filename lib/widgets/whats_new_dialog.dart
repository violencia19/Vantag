import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Dialog to show what's new in the app
class WhatsNewDialog extends StatelessWidget {
  final String version;
  final List<String> changes;

  const WhatsNewDialog({
    super.key,
    required this.version,
    required this.changes,
  });

  static const String _lastSeenVersionKey = 'last_seen_whats_new_version';
  static const String _currentVersion = '1.0.3';

  /// Check if we should show what's new dialog
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeenVersion = prefs.getString(_lastSeenVersionKey);
    return lastSeenVersion != _currentVersion;
  }

  /// Mark the current version as seen
  static Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenVersionKey, _currentVersion);
  }

  /// Show the dialog if needed
  static Future<void> showIfNeeded(BuildContext context) async {
    if (!await shouldShow()) return;

    final locale = Localizations.localeOf(context).languageCode;

    final changes = locale == 'tr'
        ? [
            'AI artık seçtiğiniz dilde cevap veriyor',
            'Performans iyileştirmeleri',
            'Hata düzeltmeleri',
          ]
        : [
            'AI now responds in your selected language',
            'Performance improvements',
            'Bug fixes',
          ];

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => WhatsNewDialog(
        version: _currentVersion,
        changes: changes,
      ),
    );

    await markAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: VGlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        blurSigma: VantBlur.heavy,
        glowColor: context.vantColors.primary,
        glowIntensity: 0.15,
        variant: VantGlassVariant.hero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: context.vantColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.sparkles,
                size: 32,
                color: context.vantColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              l10n.whatsNewInVersion(version),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.vantColors.textPrimary,
              ),
            ),

            const SizedBox(height: 20),

            // Changes list
            ...changes.map((change) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_circle,
                        size: 20,
                        color: context.vantColors.success,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          change,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.vantColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 20),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.vantColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.gotIt,
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
    );
  }
}
