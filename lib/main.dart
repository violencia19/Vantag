import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'firebase_options.dart';

import 'screens/screens.dart';
import 'theme/theme.dart';
import 'providers/providers.dart';
import 'services/auth_service.dart';
import 'services/expense_history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register fvp for Windows/Linux video support
  fvp.registerWith();

  print("🚀 ADIM 1: Flutter Hazır");

  // LocaleProvider başlat
  final localeProvider = LocaleProvider();
  await localeProvider.initialize();
  print("✅ ADIM 1.5: Locale Provider Hazır");

  // CurrencyProvider başlat
  final currencyProvider = CurrencyProvider();
  await currencyProvider.loadCurrency();
  print("✅ ADIM 1.6: Currency Provider Hazır");

  // Firebase başlat
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ ADIM 2: Firebase Core Başarılı");
  } catch (e) {
    print("❌ HATA: Firebase Core Bağlanamadı: $e");
  }

  // AuthService ile anonim giriş yap
  final authService = AuthService();
  final result = await authService.signInAnonymously();

  if (result.success) {
    print("✅ ADIM 3: Auth Başarılı - UID: ${result.user?.uid}");
    authService.debugAuthStatus();

    // Cloud'dan mevcut expense verilerini çek (multi-device sync)
    final expenseService = ExpenseHistoryService();
    await expenseService.syncFromFirestore();
    print("✅ ADIM 4: Cloud veriler senkronize edildi");
  } else {
    print("❌ HATA: Auth Başarısız: ${result.errorMessage}");
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(VantagApp(
    localeProvider: localeProvider,
    currencyProvider: currencyProvider,
  ));
}

class VantagApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  final CurrencyProvider currencyProvider;

  const VantagApp({
    super.key,
    required this.localeProvider,
    required this.currencyProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: currencyProvider),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Vantag',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,

            // Localization ayarları
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Sistem dili desteklenmiyorsa Türkçe kullan
            localeResolutionCallback: (locale, supportedLocales) {
              // Kullanıcı tercih ettiyse onu kullan
              if (localeProvider.locale != null) {
                return localeProvider.locale;
              }

              // Sistem dilini kontrol et
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }

              // Varsayılan Türkçe
              return const Locale('tr');
            },

            home: const VantagSplashScreen(),
          );
        },
      ),
    );
  }
}