import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vantag/main.dart' as app;

/// Integration test for capturing screenshots of main screens
/// Run with: flutter test integration_test/screenshot_test.dart
///
/// For device screenshots:
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshot_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot Tests', () {
    testWidgets('Capture main screens - TR locale', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Wait for splash to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Screenshot 1: Main/Expense Screen
      await _takeScreenshot(binding, 'expense_screen_tr');

      // Navigate to Report tab
      final reportTab = find.text('Rapor');
      if (reportTab.evaluate().isNotEmpty) {
        await tester.tap(reportTab);
        await tester.pumpAndSettle();
        await _takeScreenshot(binding, 'report_screen_tr');
      }

      // Navigate to Pursuits tab
      final pursuitsTab = find.text('Hayallerim');
      if (pursuitsTab.evaluate().isNotEmpty) {
        await tester.tap(pursuitsTab);
        await tester.pumpAndSettle();
        await _takeScreenshot(binding, 'pursuits_screen_tr');
      }

      // Navigate to Profile tab
      final profileTab = find.text('Profil');
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
        await _takeScreenshot(binding, 'profile_screen_tr');
      }
    });

    testWidgets('Capture main screens - EN locale', (tester) async {
      // Start app with English locale
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Wait for splash to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Screenshot 1: Main/Expense Screen
      await _takeScreenshot(binding, 'expense_screen_en');

      // Navigate to Report tab
      final reportTab = find.text('Report');
      if (reportTab.evaluate().isNotEmpty) {
        await tester.tap(reportTab);
        await tester.pumpAndSettle();
        await _takeScreenshot(binding, 'report_screen_en');
      }

      // Navigate to Pursuits tab
      final pursuitsTab = find.text('Pursuits');
      if (pursuitsTab.evaluate().isNotEmpty) {
        await tester.tap(pursuitsTab);
        await tester.pumpAndSettle();
        await _takeScreenshot(binding, 'pursuits_screen_en');
      }

      // Navigate to Profile tab
      final profileTab = find.text('Profile');
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
        await _takeScreenshot(binding, 'profile_screen_en');
      }
    });

    testWidgets('Capture feature screens', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Try to open AI Chat
      final aiFab = find.byType(FloatingActionButton);
      if (aiFab.evaluate().isNotEmpty) {
        await tester.tap(aiFab.first);
        await tester.pumpAndSettle();
        await _takeScreenshot(binding, 'ai_chat_screen');

        // Close the sheet
        await tester.tapAt(const Offset(200, 100));
        await tester.pumpAndSettle();
      }

      // Navigate to subscriptions (from profile)
      final profileTab = find.text('Profil');
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();

        final subscriptionsButton = find.text('Abonelikler');
        if (subscriptionsButton.evaluate().isNotEmpty) {
          await tester.tap(subscriptionsButton);
          await tester.pumpAndSettle();
          await _takeScreenshot(binding, 'subscriptions_screen');
        }
      }
    });
  });
}

/// Takes a screenshot and saves it to screenshots/ folder
Future<void> _takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  // Ensure screenshots directory exists
  final dir = Directory('screenshots');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  // Take screenshot
  final List<int> bytes = await binding.takeScreenshot(name);

  // Save to file
  final file = File('screenshots/$name.png');
  await file.writeAsBytes(bytes);

  debugPrint('Screenshot saved: screenshots/$name.png');
}
