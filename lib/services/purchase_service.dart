import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_limits.dart';
import 'notification_service.dart';

/// RevenueCat-based purchase service for Vantag Pro subscriptions
/// Supports: Monthly, Yearly (subscriptions) and Lifetime (one-time purchase)
class PurchaseService {
  static String get _apiKey {
    final key = dotenv.env['REVENUECAT_API_KEY'];
    if (key == null || key.isEmpty) {
      debugPrint('WARNING: REVENUECAT_API_KEY not found in .env file');
      return '';
    }
    return key;
  }

  static const String _entitlementId = 'pro';

  // Product identifiers
  static const String productMonthly = 'vantag_pro_monthly';
  static const String productYearly = 'vantag_pro_yearly';
  static const String productLifetime = 'vantag-pro-lifetime';

  // Usage limits for free tier (use AppLimits as single source of truth)
  static int get freeAiChatLimit => AppLimits.freeAiChatsPerDay;
  static int get freeHistoryDays => AppLimits.freeHistoryDays;

  // Pro credit limits (monthly reset)
  static const int proSubscriptionMonthlyLimit =
      500; // Monthly/Yearly subscribers
  static const int proLifetimeMonthlyLimit = 200; // Lifetime users

  // Credit pack product identifiers
  static const String creditPack50 = 'credit_pack_50';
  static const String creditPack150 = 'credit_pack_150';
  static const String creditPack500 = 'credit_pack_500';

  // Credit amounts for each pack
  static const Map<String, int> _creditPackAmounts = {
    creditPack50: 50,
    creditPack150: 150,
    creditPack500: 500,
  };

  // SharedPreferences keys
  static const String _keyDailyAiUsage = 'daily_ai_usage';
  static const String _keyLastAiUsageDate = 'last_ai_usage_date';
  static const String _keyMonthlyAiUsage = 'monthly_ai_usage';
  static const String _keyLastMonthlyReset = 'last_monthly_reset';
  static const String _keyIsLifetime = 'is_lifetime_user';
  static const String _keyExtraCredits = 'extra_ai_credits';

  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  bool _isInitialized = false;
  final _proStatusController = StreamController<bool>.broadcast();

  /// Stream to listen for Pro status changes
  Stream<bool> get proStatusStream => _proStatusController.stream;

  /// Initialize RevenueCat SDK
  static Future<void> init() async {
    final instance = PurchaseService();
    if (instance._isInitialized) return;

    try {
      // Check if API key is available
      final apiKey = _apiKey;
      if (apiKey.isEmpty) {
        debugPrint('RevenueCat: API key not configured, using mock mode');
        instance._isInitialized = true;
        return;
      }

      // Configure RevenueCat
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(apiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(apiKey);
      } else {
        // Windows/Web - use mock mode
        debugPrint('RevenueCat: Platform not supported, using mock mode');
        instance._isInitialized = true;
        return;
      }

      await Purchases.configure(configuration);

      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        final isPro = instance._checkEntitlement(customerInfo);
        instance._proStatusController.add(isPro);
      });

      instance._isInitialized = true;
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('RevenueCat initialization error: $e');
    }
  }

  /// Get available subscription offerings
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) return null;

    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a subscription package
  Future<PurchaseResult> purchasePackage(Package package) async {
    if (!_isInitialized) {
      return PurchaseResult(success: false, message: 'Service not initialized');
    }

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final isPro = _checkEntitlement(customerInfo);
      _proStatusController.add(isPro);

      // Check if it's a lifetime purchase and save locally
      if (package.identifier.toLowerCase().contains('lifetime')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLifetime, true);
      }

      // Cancel trial notifications since user converted to paid
      if (isPro) {
        try {
          await NotificationService().cancelTrialNotifications();
          debugPrint('[PurchaseService] Trial notifications cancelled');
        } catch (e) {
          debugPrint(
            '[PurchaseService] Error cancelling trial notifications: $e',
          );
        }
      }

      return PurchaseResult(
        success: isPro,
        message: isPro
            ? 'Purchase successful!'
            : 'Purchase completed but entitlement not found',
      );
    } on PurchasesErrorCode catch (e) {
      String message;
      switch (e) {
        case PurchasesErrorCode.purchaseCancelledError:
          message = 'Purchase cancelled';
          break;
        case PurchasesErrorCode.purchaseNotAllowedError:
          message = 'Purchase not allowed';
          break;
        case PurchasesErrorCode.purchaseInvalidError:
          message = 'Invalid purchase';
          break;
        case PurchasesErrorCode.productNotAvailableForPurchaseError:
          message = 'Product not available';
          break;
        case PurchasesErrorCode.productAlreadyPurchasedError:
          message = 'Already purchased';
          break;
        default:
          message = 'Purchase failed: $e';
      }
      return PurchaseResult(success: false, message: message);
    } catch (e) {
      return PurchaseResult(success: false, message: 'Purchase error: $e');
    }
  }

  /// Restore previous purchases
  Future<PurchaseResult> restorePurchases() async {
    if (!_isInitialized) {
      return PurchaseResult(success: false, message: 'Service not initialized');
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro = _checkEntitlement(customerInfo);
      _proStatusController.add(isPro);

      // Cancel trial notifications if user has active subscription
      if (isPro) {
        try {
          await NotificationService().cancelTrialNotifications();
          debugPrint(
            '[PurchaseService] Trial notifications cancelled after restore',
          );
        } catch (e) {
          debugPrint(
            '[PurchaseService] Error cancelling trial notifications: $e',
          );
        }
      }

      return PurchaseResult(
        success: true,
        message: isPro
            ? 'Pro subscription restored!'
            : 'No active subscription found',
        isPro: isPro,
      );
    } catch (e) {
      return PurchaseResult(success: false, message: 'Restore failed: $e');
    }
  }

  /// Check if user has Pro entitlement
  Future<bool> checkProStatus() async {
    if (!_isInitialized) {
      // Check on unsupported platforms via SharedPreferences
      if (!Platform.isAndroid && !Platform.isIOS) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool('is_pro_user') ?? false;
      }
      return false;
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _checkEntitlement(customerInfo);
    } catch (e) {
      debugPrint('Error checking Pro status: $e');
      return false;
    }
  }

  /// Check entitlement from CustomerInfo
  bool _checkEntitlement(CustomerInfo customerInfo) {
    return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
  }

  /// Check if user has Lifetime (not subscription)
  Future<bool> isLifetimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLifetime) ?? false;
  }

  /// Get current customer info
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_isInitialized) return null;

    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      return null;
    }
  }

  /// Login user (for account linking)
  Future<void> login(String userId) async {
    if (!_isInitialized) return;

    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('Error logging in: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    if (!_isInitialized) return;

    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USAGE LIMITS (Free Tier - Daily)
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if user can use AI chat (free: 4/day limit)
  Future<bool> canUseAiChat(bool isPro) async {
    if (isPro) return true;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_keyLastAiUsageDate) ?? '';

    // Reset counter if new day
    if (lastDate != today) {
      await prefs.setInt(_keyDailyAiUsage, 0);
      await prefs.setString(_keyLastAiUsageDate, today);
      return true;
    }

    final usage = prefs.getInt(_keyDailyAiUsage) ?? 0;
    return usage < freeAiChatLimit;
  }

  /// Increment AI chat usage counter (for free users - daily)
  Future<int> incrementAiUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_keyLastAiUsageDate) ?? '';

    int usage;
    if (lastDate != today) {
      usage = 1;
      await prefs.setString(_keyLastAiUsageDate, today);
    } else {
      usage = (prefs.getInt(_keyDailyAiUsage) ?? 0) + 1;
    }

    await prefs.setInt(_keyDailyAiUsage, usage);
    return usage;
  }

  /// Get remaining AI chat uses for today (free users)
  Future<int> getRemainingAiUses(bool isPro) async {
    if (isPro) return -1; // Check monthly credits instead

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_keyLastAiUsageDate) ?? '';

    if (lastDate != today) return freeAiChatLimit;

    final usage = prefs.getInt(_keyDailyAiUsage) ?? 0;
    return (freeAiChatLimit - usage).clamp(0, freeAiChatLimit);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USAGE LIMITS (Pro Tier - Monthly)
  // ══════════════════════════════════════════════════════════════════════════

  /// Get remaining monthly AI credits for Pro users
  Future<int> getRemainingMonthlyCredits(bool isPro, bool isLifetime) async {
    if (!isPro) return 0;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastResetStr = prefs.getString(_keyLastMonthlyReset);

    // Reset on 1st of each month
    if (lastResetStr == null ||
        !_isSameMonth(DateTime.parse(lastResetStr), now)) {
      await prefs.setInt(_keyMonthlyAiUsage, 0);
      await prefs.setString(_keyLastMonthlyReset, now.toIso8601String());
      return isLifetime ? proLifetimeMonthlyLimit : proSubscriptionMonthlyLimit;
    }

    final usage = prefs.getInt(_keyMonthlyAiUsage) ?? 0;
    final limit = isLifetime
        ? proLifetimeMonthlyLimit
        : proSubscriptionMonthlyLimit;
    return (limit - usage).clamp(0, limit);
  }

  /// Check if same month
  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// Increment monthly usage for Pro users
  Future<void> incrementMonthlyUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final usage = (prefs.getInt(_keyMonthlyAiUsage) ?? 0) + 1;
    await prefs.setInt(_keyMonthlyAiUsage, usage);
  }

  /// Check if Pro user can use AI (checks monthly credits)
  Future<bool> canProUserUseAi(bool isLifetime) async {
    final remaining = await getRemainingMonthlyCredits(true, isLifetime);
    return remaining > 0;
  }

  /// Get monthly limit based on subscription type
  int getMonthlyLimit(bool isLifetime) {
    return isLifetime ? proLifetimeMonthlyLimit : proSubscriptionMonthlyLimit;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HISTORY LIMITS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get history date limit for free users
  DateTime getHistoryLimit(bool isPro) {
    if (isPro) {
      return DateTime(2000); // effectively unlimited
    }
    return DateTime.now().subtract(Duration(days: freeHistoryDays));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CREDIT PACKS (For Lifetime Users)
  // ══════════════════════════════════════════════════════════════════════════

  /// Purchase a credit pack (consumable product)
  Future<PurchaseResult> purchaseCreditPack(String packId) async {
    if (!_isInitialized) {
      // For development/testing - simulate purchase
      if (!Platform.isAndroid && !Platform.isIOS) {
        final credits = _creditPackAmounts[packId] ?? 0;
        if (credits > 0) {
          await addCredits(credits);
          return PurchaseResult(
            success: true,
            message: 'Credits added (test mode)',
          );
        }
      }
      return PurchaseResult(success: false, message: 'Service not initialized');
    }

    try {
      // Get the product from offerings
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) {
        return PurchaseResult(
          success: false,
          message: 'No offerings available',
        );
      }

      // Find the credit pack product
      Package? package;
      for (final pkg in offerings.current!.availablePackages) {
        if (pkg.storeProduct.identifier == packId) {
          package = pkg;
          break;
        }
      }

      if (package == null) {
        return PurchaseResult(success: false, message: 'Credit pack not found');
      }

      // Purchase the consumable
      await Purchases.purchasePackage(package);

      // Add credits to local storage
      final credits = _creditPackAmounts[packId] ?? 0;
      await addCredits(credits);

      return PurchaseResult(
        success: true,
        message: 'Successfully purchased $credits credits',
      );
    } on PurchasesErrorCode catch (e) {
      String message;
      switch (e) {
        case PurchasesErrorCode.purchaseCancelledError:
          message = 'Purchase cancelled';
          break;
        case PurchasesErrorCode.purchaseNotAllowedError:
          message = 'Purchase not allowed';
          break;
        default:
          message = 'Purchase failed: $e';
      }
      return PurchaseResult(success: false, message: message);
    } catch (e) {
      return PurchaseResult(success: false, message: 'Purchase error: $e');
    }
  }

  /// Add credits to user's extra credit balance
  Future<void> addCredits(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyExtraCredits) ?? 0;
    await prefs.setInt(_keyExtraCredits, current + amount);
  }

  /// Get user's extra credits (purchased credits that never expire)
  Future<int> getExtraCredits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyExtraCredits) ?? 0;
  }

  /// Use one extra credit (returns true if successful)
  Future<bool> useExtraCredit() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyExtraCredits) ?? 0;
    if (current <= 0) return false;
    await prefs.setInt(_keyExtraCredits, current - 1);
    return true;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UNIFIED AI USAGE (Combines Monthly + Extra Credits for Lifetime)
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if Lifetime user can use AI (monthly + extra credits)
  Future<bool> canLifetimeUserUseAi() async {
    // First check monthly credits
    final monthlyRemaining = await getRemainingMonthlyCredits(true, true);
    if (monthlyRemaining > 0) return true;

    // Then check extra credits
    final extraCredits = await getExtraCredits();
    return extraCredits > 0;
  }

  /// Use AI credit for Lifetime user (uses monthly first, then extra)
  /// Returns: 'monthly' if used monthly, 'extra' if used extra, null if none available
  Future<String?> useLifetimeAiCredit() async {
    // First try monthly credits
    final monthlyRemaining = await getRemainingMonthlyCredits(true, true);
    if (monthlyRemaining > 0) {
      await incrementMonthlyUsage();
      return 'monthly';
    }

    // Then try extra credits
    final success = await useExtraCredit();
    if (success) return 'extra';

    return null;
  }

  /// Get total available AI credits for Lifetime user (monthly + extra)
  Future<int> getTotalLifetimeCredits() async {
    final monthly = await getRemainingMonthlyCredits(true, true);
    final extra = await getExtraCredits();
    return monthly + extra;
  }

  /// Get next monthly reset date
  DateTime getNextMonthlyResetDate() {
    final now = DateTime.now();
    // Next month, 1st day
    if (now.month == 12) {
      return DateTime(now.year + 1, 1, 1);
    }
    return DateTime(now.year, now.month + 1, 1);
  }

  /// Get days until monthly reset
  int getDaysUntilMonthlyReset() {
    final resetDate = getNextMonthlyResetDate();
    return resetDate.difference(DateTime.now()).inDays;
  }

  /// Dispose resources
  void dispose() {
    _proStatusController.close();
  }
}

/// Result of a purchase operation
class PurchaseResult {
  final bool success;
  final String message;
  final bool? isPro;

  PurchaseResult({required this.success, required this.message, this.isPro});
}
