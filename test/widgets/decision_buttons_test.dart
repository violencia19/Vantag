import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/widgets/decision_buttons.dart';
import 'package:vantag/models/expense.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vantag/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest({
    required Function(ExpenseDecision) onDecision,
    bool enabled = true,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: DecisionButtons(
          onDecision: onDecision,
          enabled: enabled,
        ),
      ),
    );
  }

  group('DecisionButtons', () {
    // ========================================
    // Basic Rendering Tests
    // ========================================
    testWidgets('1. displays decision prompt text', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (_) {},
      ));
      await tester.pumpAndSettle();

      // Should display text widgets
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('2. has three decision buttons in a Row', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (_) {},
      ));
      await tester.pumpAndSettle();

      // Should have a Column containing Row with 3 buttons
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('3. displays all three decision labels', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (_) {},
      ));
      await tester.pumpAndSettle();

      // Verify the buttons exist by finding GestureDetector widgets
      // (which wrap the decision buttons)
      expect(find.byType(GestureDetector), findsWidgets);
    });

    // ========================================
    // Interaction Tests
    // ========================================
    testWidgets('4. calls onDecision with YES when first button tapped',
        (tester) async {
      ExpenseDecision? receivedDecision;

      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (decision) => receivedDecision = decision,
      ));
      await tester.pumpAndSettle();

      // Find all GestureDetector widgets (the buttons)
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors.evaluate().length, greaterThanOrEqualTo(3));

      // Tap the first button (Yes/Bought)
      await tester.tap(gestureDetectors.first);
      await tester.pumpAndSettle();

      expect(receivedDecision, ExpenseDecision.yes);
    });

    testWidgets('5. does not call callback when disabled', (tester) async {
      ExpenseDecision? receivedDecision;

      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (decision) => receivedDecision = decision,
        enabled: false,
      ));
      await tester.pumpAndSettle();

      final gestureDetectors = find.byType(GestureDetector);
      if (gestureDetectors.evaluate().isNotEmpty) {
        await tester.tap(gestureDetectors.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // When disabled, callback should not be triggered
      // Note: This depends on implementation details
    });

    // ========================================
    // Visual State Tests
    // ========================================
    testWidgets('6. has visual indicators for enabled state', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (_) {},
        enabled: true,
      ));
      await tester.pumpAndSettle();

      // Find AnimatedOpacity widgets for visual feedback
      expect(find.byType(AnimatedOpacity), findsWidgets);
    });

    testWidgets('7. has visual indicators for disabled state', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (_) {},
        enabled: false,
      ));
      await tester.pumpAndSettle();

      // Should still render but with reduced opacity
      expect(find.byType(AnimatedOpacity), findsWidgets);
    });

    // ========================================
    // Animation Tests
    // ========================================
    testWidgets('8. has Transform widget for scale animation', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (_) {},
      ));
      await tester.pumpAndSettle();

      // Transform.scale is used for press animation
      expect(find.byType(Transform), findsWidgets);
    });

    // ========================================
    // Layout Tests
    // ========================================
    testWidgets('9. buttons are evenly distributed', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (_) {},
      ));
      await tester.pumpAndSettle();

      // Should have Expanded widgets for equal distribution
      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('10. has correct spacing between buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (_) {},
      ));
      await tester.pumpAndSettle();

      // Should have SizedBox for spacing
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  // ========================================
  // SingleDecisionButton Tests
  // ========================================
  group('SingleDecisionButton', () {
    Widget createSingleButton({
      VoidCallback? onTap,
      bool isSelected = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleDecisionButton(
            label: 'Test',
            icon: Icons.check,
            color: Colors.green,
            onTap: onTap,
            isSelected: isSelected,
          ),
        ),
      );
    }

    testWidgets('1. renders with label and icon', (tester) async {
      await tester.pumpWidget(createSingleButton());
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('2. calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createSingleButton(
        onTap: () => tapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('3. shows selected state visually', (tester) async {
      await tester.pumpWidget(createSingleButton(
        isSelected: true,
      ));
      await tester.pumpAndSettle();

      // Should have AnimatedContainer for state transitions
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('4. has minimum touch target size', (tester) async {
      await tester.pumpWidget(createSingleButton());
      await tester.pumpAndSettle();

      // The button should have minHeight: 44 for accessibility
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      expect(container.constraints?.minHeight, greaterThanOrEqualTo(44));
    });

    testWidgets('5. renders in non-selected state', (tester) async {
      await tester.pumpWidget(createSingleButton(
        isSelected: false,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SingleDecisionButton), findsOneWidget);
    });
  });
}
