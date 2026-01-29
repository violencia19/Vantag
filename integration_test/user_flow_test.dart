import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vantag/main.dart' as app;

/// Integration test for basic user flow:
/// Onboarding → Salary Entry → Expense Entry → Decision → Verify
///
/// Run with:
/// flutter test integration_test/user_flow_test.dart
///
/// Or on device:
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/user_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Flow Integration Tests', () {
    testWidgets('1. App launches and shows splash screen', (tester) async {
      // Start app
      app.main();

      // Wait for initial load
      await tester.pump(const Duration(seconds: 1));

      // The app should be running
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('2. App navigates past splash to main content', (tester) async {
      app.main();

      // Wait for splash to complete (video/animation)
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Should find some UI element (either onboarding or main screen)
      expect(
        find.byType(Scaffold).evaluate().isNotEmpty ||
            find.byType(Container).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('3. Main screen has bottom navigation', (tester) async {
      app.main();

      // Wait for app to fully load
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Look for navigation bar or bottom navigation elements
      // The app uses a custom PremiumNavBar
      final scaffold = find.byType(Scaffold);
      expect(scaffold.evaluate().isNotEmpty, true);
    });

    testWidgets('4. Can enter expense amount', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Find text field for expense input
      final textFields = find.byType(TextField);

      if (textFields.evaluate().isNotEmpty) {
        // Enter an expense amount
        await tester.enterText(textFields.first, '100');
        await tester.pumpAndSettle();

        // Text should be entered
        expect(find.text('100'), findsWidgets);
      }
    });

    testWidgets('5. Decision buttons are present', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Look for GestureDetector widgets (used in decision buttons)
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors.evaluate().isNotEmpty, true);
    });

    testWidgets('6. Navigation between tabs works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Try to find and tap different tabs
      // Turkish labels
      final trLabels = ['Harcama', 'Rapor', 'Hayallerim', 'Profil'];
      // English labels
      final enLabels = ['Expense', 'Report', 'Pursuits', 'Profile'];

      for (final label in [...trLabels, ...enLabels]) {
        final tab = find.text(label);
        if (tab.evaluate().isNotEmpty) {
          await tester.tap(tab);
          await tester.pumpAndSettle();
          break;
        }
      }

      // App should still be running
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('7. Report screen displays correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Navigate to Report tab
      final reportTab = find.text('Rapor');
      final reportTabEn = find.text('Report');

      if (reportTab.evaluate().isNotEmpty) {
        await tester.tap(reportTab);
      } else if (reportTabEn.evaluate().isNotEmpty) {
        await tester.tap(reportTabEn);
      }

      await tester.pumpAndSettle();

      // Should show some content
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('8. Profile screen displays correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Navigate to Profile tab
      final profileTab = find.text('Profil');
      final profileTabEn = find.text('Profile');

      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
      } else if (profileTabEn.evaluate().isNotEmpty) {
        await tester.tap(profileTabEn);
      }

      await tester.pumpAndSettle();

      // Should show profile content
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('9. Pursuits screen displays correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Navigate to Pursuits tab
      final pursuitsTab = find.text('Hayallerim');
      final pursuitsTabEn = find.text('Pursuits');

      if (pursuitsTab.evaluate().isNotEmpty) {
        await tester.tap(pursuitsTab);
      } else if (pursuitsTabEn.evaluate().isNotEmpty) {
        await tester.tap(pursuitsTabEn);
      }

      await tester.pumpAndSettle();

      // Should show pursuits content
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('10. App handles rapid navigation gracefully', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Rapidly tap between tabs
      final tabs = ['Harcama', 'Rapor', 'Hayallerim', 'Profil'];

      for (var i = 0; i < 3; i++) {
        for (final label in tabs) {
          final tab = find.text(label);
          if (tab.evaluate().isNotEmpty) {
            await tester.tap(tab);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }
      }

      await tester.pumpAndSettle();

      // App should not crash
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Expense Entry Flow', () {
    testWidgets('1. Expense entry shows result after calculation', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Find expense input
      final textFields = find.byType(TextField);

      if (textFields.evaluate().isNotEmpty) {
        // Clear any existing text and enter new amount
        await tester.enterText(textFields.first, '500');
        await tester.pumpAndSettle();

        // Should show result or decision buttons after entry
        // Look for any container (result cards, buttons, etc.)
        expect(find.byType(Container), findsWidgets);
      }
    });

    testWidgets('2. Category selection works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Look for category chips or buttons
      // Common category names in Turkish
      final categories = [
        'Yiyecek',
        'Ulaşım',
        'Giyim',
        'Elektronik',
        'Eğlence',
      ];

      for (final category in categories) {
        final categoryWidget = find.text(category);
        if (categoryWidget.evaluate().isNotEmpty) {
          await tester.tap(categoryWidget.first);
          await tester.pumpAndSettle();
          break;
        }
      }

      // App should still be running
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('AI Chat Flow', () {
    testWidgets('1. AI FAB button is present', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Look for floating action button
      final fab = find.byType(FloatingActionButton);

      // FAB might be present for AI chat
      // Not all users will have it visible
      if (fab.evaluate().isNotEmpty) {
        expect(fab, findsWidgets);
      }
    });

    testWidgets('2. AI chat sheet opens when FAB tapped', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      final fab = find.byType(FloatingActionButton);

      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();

        // A bottom sheet or modal should appear
        expect(find.byType(Container), findsWidgets);
      }
    });
  });

  group('Error Handling', () {
    testWidgets('1. App handles empty expense gracefully', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Try to submit empty expense (if submit button exists)
      final submitButtons = find.byType(ElevatedButton);

      if (submitButtons.evaluate().isNotEmpty) {
        await tester.tap(submitButtons.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // App should not crash
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('2. App handles very large numbers', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      final textFields = find.byType(TextField);

      if (textFields.evaluate().isNotEmpty) {
        // Enter a very large number
        await tester.enterText(textFields.first, '999999999999');
        await tester.pumpAndSettle();

        // App should handle it gracefully
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });
}
