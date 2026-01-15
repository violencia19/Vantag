import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/main.dart';
import 'package:vantag/providers/providers.dart';
import 'package:vantag/screens/screens.dart';

void main() {
  testWidgets('App shows splash screen on start', (WidgetTester tester) async {
    final localeProvider = LocaleProvider();
    await localeProvider.initialize();

    final currencyProvider = CurrencyProvider();
    final proProvider = ProProvider();

    await tester.pumpWidget(VantagApp(
      localeProvider: localeProvider,
      currencyProvider: currencyProvider,
      proProvider: proProvider,
    ));

    expect(find.byType(VantagSplashScreen), findsOneWidget);
  });
}
