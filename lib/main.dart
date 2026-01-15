import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'firebase_options.dart';

import 'screens/screens.dart';
import 'theme/theme.dart';
import 'providers/providers.dart';
import 'services/auth_service.dart';
import 'services/expense_history_service.dart';
import 'services/ai_service.dart';
import 'services/deep_link_service.dart';
import 'services/siri_service.dart';

/// Global navigator key for deep link dialogs
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register fvp for Windows/Linux video support
  fvp.registerWith();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env dosyası yüklendi");
  } catch (e) {
    print("❌ .env dosyası yüklenemedi: $e");
  }

  // Initialize AI Service (Memory + Models)
  try {
    await AIService().initialize();
    print("✅ AI Service başlatıldı");
  } catch (e) {
    print("❌ AI Service hatası: $e");
  }

  print("🚀 ADIM 1: Flutter Hazır");

  // LocaleProvider başlat
  final localeProvider = LocaleProvider();
  await localeProvider.initialize();
  print("✅ ADIM 1.5: Locale Provider Hazır");

  // CurrencyProvider başlat
  final currencyProvider = CurrencyProvider();
  await currencyProvider.loadCurrency();
  print("✅ ADIM 1.6: Currency Provider Hazır");

  // ProProvider başlat
  final proProvider = ProProvider();
  await proProvider.initialize();
  print("✅ ADIM 1.7: Pro Provider Hazır");

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
    proProvider: proProvider,
  ));
}

class VantagApp extends StatefulWidget {
  final LocaleProvider localeProvider;
  final CurrencyProvider currencyProvider;
  final ProProvider proProvider;

  const VantagApp({
    super.key,
    required this.localeProvider,
    required this.currencyProvider,
    required this.proProvider,
  });

  @override
  State<VantagApp> createState() => _VantagAppState();
}

class _VantagAppState extends State<VantagApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize Deep Link Service
    DeepLinkService().init(navigatorKey);

    // Initialize Siri shortcuts (iOS only)
    if (Platform.isIOS) {
      SiriService().setupShortcuts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider.value(value: widget.localeProvider),
        ChangeNotifierProvider.value(value: widget.currencyProvider),
        ChangeNotifierProvider.value(value: widget.proProvider),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Vantag',
            navigatorKey: navigatorKey,
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