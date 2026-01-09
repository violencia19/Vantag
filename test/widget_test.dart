import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/main.dart';
import 'package:vantag/providers/providers.dart';
import 'package:vantag/screens/screens.dart';

void main() {
  testWidgets('App shows splash screen on start', (WidgetTester tester) async {
    final localeProvider = LocaleProvider();
    await localeProvider.initialize();

    await tester.pumpWidget(VantagApp(localeProvider: localeProvider));

    expect(find.byType(VantagSplashScreen), findsOneWidget);
  });
}
