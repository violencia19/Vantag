import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of promo code validation
class PromoResult {
  final bool isValid;
  final int? daysGranted;
  final String? errorMessage;
  final String? promoType;

  const PromoResult({
    required this.isValid,
    this.daysGranted,
    this.errorMessage,
    this.promoType,
  });

  factory PromoResult.success(int days, String type) => PromoResult(
        isValid: true,
        daysGranted: days,
        promoType: type,
      );

  factory PromoResult.error(String message) => PromoResult(
        isValid: false,
        errorMessage: message,
      );
}

/// Service for handling promotional codes
class PromoService {
  static final PromoService _instance = PromoService._internal();
  factory PromoService() => _instance;
  PromoService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _promoExpiryKey = 'promo_expiry_date';
  static const String _usedPromoCodesKey = 'used_promo_codes';

  /// Validate and apply a promo code
  Future<PromoResult> redeemPromoCode(String code, String userId) async {
    try {
      final normalizedCode = code.trim().toUpperCase();

      // Check if already used
      if (await _isCodeUsedByUser(normalizedCode, userId)) {
        return PromoResult.error('codeAlreadyUsed');
      }

      // Fetch code from Firestore
      final doc = await _firestore.collection('promo_codes').doc(normalizedCode).get();

      if (!doc.exists) {
        return PromoResult.error('invalidCode');
      }

      final data = doc.data()!;
      final isActive = data['isActive'] as bool? ?? false;
      final maxUses = data['maxUses'] as int? ?? 0;
      final currentUses = data['usedCount'] as int? ?? 0;
      final expiryDate = (data['expiryDate'] as Timestamp?)?.toDate();
      final daysGranted = data['daysGranted'] as int? ?? 7;
      final promoType = data['type'] as String? ?? 'pro_trial';

      // Validate code
      if (!isActive) {
        return PromoResult.error('codeExpired');
      }

      if (maxUses > 0 && currentUses >= maxUses) {
        return PromoResult.error('codeLimitReached');
      }

      if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
        return PromoResult.error('codeExpired');
      }

      // Apply the promo
      await _applyPromo(normalizedCode, userId, daysGranted);

      // Update usage count
      await _firestore.collection('promo_codes').doc(normalizedCode).update({
        'usedCount': FieldValue.increment(1),
        'usedBy': FieldValue.arrayUnion([userId]),
      });

      return PromoResult.success(daysGranted, promoType);
    } catch (e) {
      debugPrint('[PromoService] Error redeeming code: $e');
      return PromoResult.error('unknownError');
    }
  }

  /// Check if code was already used by this user
  Future<bool> _isCodeUsedByUser(String code, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final usedCodes = prefs.getStringList(_usedPromoCodesKey) ?? [];
    return usedCodes.contains('$code:$userId');
  }

  /// Apply promo days to user
  Future<void> _applyPromo(String code, String userId, int days) async {
    final prefs = await SharedPreferences.getInstance();

    // Get current expiry or use now
    final currentExpiryStr = prefs.getString(_promoExpiryKey);
    DateTime baseDate;
    if (currentExpiryStr != null) {
      final currentExpiry = DateTime.parse(currentExpiryStr);
      baseDate = currentExpiry.isAfter(DateTime.now()) ? currentExpiry : DateTime.now();
    } else {
      baseDate = DateTime.now();
    }

    // Add days
    final newExpiry = baseDate.add(Duration(days: days));
    await prefs.setString(_promoExpiryKey, newExpiry.toIso8601String());

    // Mark code as used
    final usedCodes = prefs.getStringList(_usedPromoCodesKey) ?? [];
    usedCodes.add('$code:$userId');
    await prefs.setStringList(_usedPromoCodesKey, usedCodes);
  }

  /// Check if user has active promo subscription
  Future<bool> hasActivePromo() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_promoExpiryKey);
    if (expiryStr == null) return false;

    final expiry = DateTime.parse(expiryStr);
    return DateTime.now().isBefore(expiry);
  }

  /// Get promo expiry date
  Future<DateTime?> getPromoExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_promoExpiryKey);
    if (expiryStr == null) return null;
    return DateTime.parse(expiryStr);
  }

  /// Get remaining promo days
  Future<int> getRemainingPromoDays() async {
    final expiry = await getPromoExpiry();
    if (expiry == null) return 0;

    final remaining = expiry.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
}

/// Global instance
final promoService = PromoService();
