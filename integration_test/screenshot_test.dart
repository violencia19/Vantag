import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vantag/main.dart' as app;

/// Integration test for capturing raw screenshots from all main screens.
///
/// Captures 6 screens: Home, Reports, Add Expense, Achievements, Dreams, Settings
///
/// Run with:
///   flutter test integration_test/screenshot_test.dart -d <device_id>
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Store Screenshots', () {
    testWidgets('Capture all 6 screens', (tester) async {
      // Suppress FlutterError.onError — the app throws non-critical errors
      // during init (Firebase permission-denied, .env missing, etc.) that
      // would otherwise fail the test.
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        debugPrint('Suppressed FlutterError: ${details.exceptionAsString()}');
      };

      // Start app
      app.main();

      // Wait for splash screen with fixed pump (pumpAndSettle hangs due to
      // video player and ongoing animations that never "settle")
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // === Screenshot 1: Home Screen ===
      debugPrint('=== Taking Screenshot 1: Home ===');
      await _captureScreen(binding, 'raw_1_home');

      // === Screenshot 2: Reports/Analysis Screen ===
      debugPrint('=== Taking Screenshot 2: Reports ===');
      final analysisTab = _findByTexts(['Analiz', 'Analysis']);
      if (analysisTab != null) {
        await tester.tap(analysisTab);
        await _settle(tester);
        await _captureScreen(binding, 'raw_2_reports');
      } else {
        debugPrint('WARNING: Analysis tab not found!');
      }

      // === Screenshot 3: Add Expense Sheet ===
      debugPrint('=== Taking Screenshot 3: Add Expense ===');
      // Navigate back to Home first
      final homeTab = _findByTexts(['Ana Sayfa', 'Home']);
      if (homeTab != null) {
        await tester.tap(homeTab);
        await _settle(tester);
      }

      // Tap the center FAB (+) button to open add expense sheet
      bool fabTapped = false;
      final fabFinder = find.byIcon(CupertinoIcons.plus);
      if (fabFinder.evaluate().isNotEmpty) {
        await tester.tap(fabFinder.first);
        fabTapped = true;
      }
      if (fabTapped) {
        await _settle(tester);
        await _captureScreen(binding, 'raw_3_add_expense');

        // Close the sheet by tapping outside
        await tester.tapAt(const Offset(200, 50));
        await _settle(tester);
        // Try again if sheet is still showing
        await tester.tapAt(const Offset(200, 100));
        await _settle(tester);
      } else {
        debugPrint('WARNING: Add expense FAB not found!');
      }

      // === Screenshot 5: Dreams/Pursuits Screen ===
      debugPrint('=== Taking Screenshot 5: Dreams ===');
      final dreamsTab = _findByTexts(['Hayaller', 'Dreams']);
      if (dreamsTab != null) {
        await tester.tap(dreamsTab);
        await _settle(tester);
        await _captureScreen(binding, 'raw_5_dreams');
      } else {
        debugPrint('WARNING: Dreams tab not found!');
      }

      // === Screenshot 6: Settings Screen ===
      debugPrint('=== Taking Screenshot 6: Settings ===');
      final settingsTab = _findByTexts(['Ayarlar', 'Settings']);
      if (settingsTab != null) {
        await tester.tap(settingsTab);
        await _settle(tester);
        await _captureScreen(binding, 'raw_6_settings');
      } else {
        debugPrint('WARNING: Settings tab not found!');
      }

      // === Screenshot 4: Achievements Screen ===
      debugPrint('=== Taking Screenshot 4: Achievements ===');
      // Scroll to find badges button in settings
      final badgesButton = _findByTexts(['Rozetler', 'Badges']);
      if (badgesButton != null) {
        await tester.ensureVisible(badgesButton);
        await _settle(tester);
        await tester.tap(badgesButton);
        await _settle(tester);
        await _captureScreen(binding, 'raw_4_achievements');
      } else {
        debugPrint('WARNING: Badges button not found in Settings!');
      }

      debugPrint('=== All screenshots captured! ===');

      // Restore error handler
      FlutterError.onError = originalOnError;
    });
  });
}

/// Settle with timeout — pumps frames for a fixed duration instead of waiting
/// for all animations to stop (which never happens with ongoing animations)
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

/// Find widget by trying multiple text labels (for EN/TR support)
Finder? _findByTexts(List<String> texts) {
  for (final text in texts) {
    final finder = find.text(text);
    if (finder.evaluate().isNotEmpty) {
      return finder;
    }
  }
  return null;
}

/// Takes both a Flutter screenshot and a simctl device screenshot
Future<void> _captureScreen(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  // Ensure output directory exists
  final dir = Directory('docs/screenshots');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  // Take Flutter-level screenshot
  final List<int> bytes = await binding.takeScreenshot(name);
  final file = File('docs/screenshots/$name.png');
  await file.writeAsBytes(bytes);
  debugPrint('Screenshot saved: docs/screenshots/$name.png');

  // Also take device-level screenshot via simctl (higher resolution, includes status bar)
  try {
    final result = await Process.run('xcrun', [
      'simctl',
      'io',
      'booted',
      'screenshot',
      'docs/screenshots/${name}_device.png',
    ]);
    if (result.exitCode == 0) {
      debugPrint('Device screenshot saved: docs/screenshots/${name}_device.png');
    } else {
      debugPrint('simctl screenshot failed: ${result.stderr}');
    }
  } catch (e) {
    debugPrint('simctl screenshot error: $e');
  }
}
