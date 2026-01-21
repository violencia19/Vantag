import 'dart:io';
import 'package:flutter/foundation.dart';
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
import 'services/budget_service.dart';
import 'services/purchase_service.dart';

/// Global navigator key for deep link dialogs
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register fvp for Windows/Linux video support
  fvp.registerWith();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env dosyası yüklendi");
  } catch (e) {
    debugPrint("❌ .env dosyası yüklenemedi: $e");
  }

  // Initialize AI Service (Memory + Models)
  try {
    await AIService().initialize();
    debugPrint("✅ AI Service başlatıldı");
  } catch (e) {
    debugPrint("❌ AI Service hatası: $e");
  }

  // Initialize RevenueCat for in-app purchases
  try {
    await PurchaseService.init();
    debugPrint("✅ RevenueCat başlatıldı");
  } catch (e) {
    debugPrint("❌ RevenueCat hatası: $e");
  }

  debugPrint("🚀 ADIM 1: Flutter Hazır");

  // LocaleProvider başlat
  final localeProvider = LocaleProvider();
  await localeProvider.initialize();
  debugPrint("✅ ADIM 1.5: Locale Provider Hazır");

  // CurrencyProvider başlat
  final currencyProvider = CurrencyProvider();
  await currencyProvider.loadCurrency();
  debugPrint("✅ ADIM 1.6: Currency Provider Hazır");

  // Firebase başlat (ProProvider'dan ÖNCE başlatılmalı!)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ ADIM 2: Firebase Core Başarılı");
  } catch (e) {
    debugPrint("❌ HATA: Firebase Core Bağlanamadı: $e");
  }

  // AuthService ile anonim giriş yap (ProProvider'dan ÖNCE Auth olmalı!)
  final authService = AuthService();
  final result = await authService.signInAnonymously();

  if (result.success) {
    debugPrint("✅ ADIM 3: Auth Başarılı - UID: ${result.user?.uid}");
    authService.debugAuthStatus();

    // Cloud'dan mevcut expense verilerini çek (multi-device sync)
    final expenseService = ExpenseHistoryService();
    await expenseService.syncFromFirestore();
    debugPrint("✅ ADIM 4: Cloud veriler senkronize edildi");
  } else {
    debugPrint("❌ HATA: Auth Başarısız: ${result.errorMessage}");
  }

  // ProProvider başlat (Firebase + Auth başlatıldıktan sonra!)
  final proProvider = ProProvider();
  await proProvider.initialize();
  debugPrint("✅ ADIM 5: Pro Provider Hazır");

  // SavingsPoolProvider başlat (Auth gerekiyor)
  final savingsPoolProvider = SavingsPoolProvider();
  await savingsPoolProvider.initialize();
  debugPrint("✅ ADIM 6: Savings Pool Provider Hazır");

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
    savingsPoolProvider: savingsPoolProvider,
  ));
}

class VantagApp extends StatefulWidget {
  final LocaleProvider localeProvider;
  final CurrencyProvider currencyProvider;
  final ProProvider proProvider;
  final SavingsPoolProvider savingsPoolProvider;

  const VantagApp({
    super.key,
    required this.localeProvider,
    required this.currencyProvider,
    required this.proProvider,
    required this.savingsPoolProvider,
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
        ChangeNotifierProxyProvider<FinanceProvider, BudgetService>(
          create: (context) => BudgetService(context.read<FinanceProvider>()),
          update: (context, financeProvider, previous) =>
              previous ?? BudgetService(financeProvider),
        ),
        ChangeNotifierProvider.value(value: widget.localeProvider),
        ChangeNotifierProvider.value(value: widget.currencyProvider),
        ChangeNotifierProvider.value(value: widget.proProvider),
        ChangeNotifierProvider.value(value: widget.savingsPoolProvider),
        ChangeNotifierProvider(create: (_) => PursuitProvider()),
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