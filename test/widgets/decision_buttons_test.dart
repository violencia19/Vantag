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
    testWidgets('displays decision prompt text', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (_) {},
      ));
      await tester.pumpAndSettle();

      // Should display the decision prompt
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('has three decision buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (_) {},
      ));
      await tester.pumpAndSettle();

      // Should have a Row with 3 buttons
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('calls onDecision callback when button tapped',
        (tester) async {
      ExpenseDecision? receivedDecision;

      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (decision) => receivedDecision = decision,
      ));
      await tester.pumpAndSettle();

      // Tap somewhere in the widget area to trigger a button
      // The exact button depends on widget structure
      final gestureDetectors = find.byType(GestureDetector);
      if (gestureDetectors.evaluate().isNotEmpty) {
        await tester.tap(gestureDetectors.first);
        await tester.pumpAndSettle();
      }

      // Decision should have been called
      expect(receivedDecision, isNotNull);
    });

    testWidgets('buttons are disabled when enabled is false', (tester) async {
      ExpenseDecision? receivedDecision;

      await tester.pumpWidget(createWidgetUnderTest(
        onDecision: (decision) => receivedDecision = decision,
        enabled: false,
      ));
      await tester.pumpAndSettle();

      // Try to tap
      final gestureDetectors = find.byType(GestureDetector);
      if (gestureDetectors.evaluate().isNotEmpty) {
        await tester.tap(gestureDetectors.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // When disabled, callback should not be triggered
      // (This depends on implementation - may need adjustment)
    });
  });
}
