import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for handling referral system with IP-based abuse prevention
/// Prevents same IP from creating multiple accounts for referral bonus abuse
class ReferralService {
  static final ReferralService _instance = ReferralService._internal();
  factory ReferralService() => _instance;
  ReferralService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int _maxAccountsPerIP = 3;
  static const String _ipHashCollection = 'ip_hashes';
  static const String _referralsCollection = 'referrals';

  /// Get current user's IP address
  Future<String?> _getIPAddress() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ipify.org?format=json'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'] as String?;
      }
    } catch (e) {
      debugPrint('[ReferralService] Error getting IP: $e');
    }
    return null;
  }

  /// Hash an IP address for privacy
  String _hashIP(String ip) {
    final bytes = utf8.encode(ip);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register user's IP hash when they create an account
  Future<void> registerUserIP() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ip = await _getIPAddress();
    if (ip == null) {
      debugPrint('[ReferralService] Could not get IP, skipping registration');
      return;
    }

    final ipHash = _hashIP(ip);

    try {
      // Store IP hash with user ID
      await _firestore.collection(_ipHashCollection).doc(user.uid).set({
        'ipHash': ipHash,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[ReferralService] Registered IP hash for user ${user.uid}');
    } catch (e) {
      debugPrint('[ReferralService] Error registering IP: $e');
    }
  }

  /// Check if a referral bonus can be granted (IP not abused)
  /// Returns true if bonus can be granted, false if abuse detected
  Future<bool> canGrantReferralBonus() async {
    final ip = await _getIPAddress();
    if (ip == null) {
      // If we can't get IP, allow the bonus (benefit of doubt)
      debugPrint('[ReferralService] Could not get IP, allowing bonus');
      return true;
    }

    final ipHash = _hashIP(ip);

    try {
      // Count how many users have this IP hash
      final query = await _firestore
          .collection(_ipHashCollection)
          .where('ipHash', isEqualTo: ipHash)
          .get();

      final accountCount = query.docs.length;
      debugPrint('[ReferralService] Accounts with same IP: $accountCount');

      if (accountCount >= _maxAccountsPerIP) {
        debugPrint('[ReferralService] IP abuse detected: $accountCount accounts from same IP');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('[ReferralService] Error checking IP abuse: $e');
      // On error, allow the bonus
      return true;
    }
  }

  /// Apply referral code and grant bonus if valid
  /// Returns true if successful, false if abused or invalid
  Future<ReferralResult> applyReferralCode(String referralCode) async {
    final user = _auth.currentUser;
    if (user == null) {
      return ReferralResult(
        success: false,
        message: 'User not logged in',
      );
    }

    // Check if user already used a referral code
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists && userDoc.data()?['usedReferralCode'] != null) {
      return ReferralResult(
        success: false,
        message: 'Already used a referral code',
      );
    }

    // Check IP abuse
    final canGrant = await canGrantReferralBonus();
    if (!canGrant) {
      return ReferralResult(
        success: false,
        message: 'Referral bonus not available',
        isAbuse: true,
      );
    }

    // Validate referral code exists
    final referrerQuery = await _firestore
        .collection('users')
        .where('referralCode', isEqualTo: referralCode)
        .limit(1)
        .get();

    if (referrerQuery.docs.isEmpty) {
      return ReferralResult(
        success: false,
        message: 'Invalid referral code',
      );
    }

    final referrerId = referrerQuery.docs.first.id;

    // Can't refer yourself
    if (referrerId == user.uid) {
      return ReferralResult(
        success: false,
        message: 'Cannot use your own referral code',
      );
    }

    try {
      // Record the referral
      await _firestore.collection(_referralsCollection).add({
        'referrerId': referrerId,
        'refereeId': user.uid,
        'referralCode': referralCode,
        'createdAt': FieldValue.serverTimestamp(),
        'bonusGranted': true,
      });

      // Mark user as having used a referral code
      await _firestore.collection('users').doc(user.uid).set({
        'usedReferralCode': referralCode,
        'referredBy': referrerId,
      }, SetOptions(merge: true));

      // Grant bonus to both parties (e.g., 3 days premium)
      // This would integrate with ProProvider to add trial days
      // For now, just record the referral

      return ReferralResult(
        success: true,
        message: 'Referral bonus applied!',
        bonusDays: 3,
      );
    } catch (e) {
      debugPrint('[ReferralService] Error applying referral: $e');
      return ReferralResult(
        success: false,
        message: 'Error applying referral',
      );
    }
  }

  /// Generate a unique referral code for a user
  Future<String?> generateReferralCode() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Check if user already has a referral code
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists && userDoc.data()?['referralCode'] != null) {
      return userDoc.data()?['referralCode'] as String?;
    }

    // Generate new code: first 8 chars of user ID hash
    final code = _hashIP(user.uid).substring(0, 8).toUpperCase();

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'referralCode': code,
      }, SetOptions(merge: true));

      return code;
    } catch (e) {
      debugPrint('[ReferralService] Error generating referral code: $e');
      return null;
    }
  }

  /// Get referral statistics for a user
  Future<ReferralStats> getReferralStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      return ReferralStats(totalReferrals: 0, bonusDaysEarned: 0);
    }

    try {
      final referrals = await _firestore
          .collection(_referralsCollection)
          .where('referrerId', isEqualTo: user.uid)
          .get();

      return ReferralStats(
        totalReferrals: referrals.docs.length,
        bonusDaysEarned: referrals.docs.length * 3, // 3 days per referral
      );
    } catch (e) {
      debugPrint('[ReferralService] Error getting stats: $e');
      return ReferralStats(totalReferrals: 0, bonusDaysEarned: 0);
    }
  }
}

/// Result of applying a referral code
class ReferralResult {
  final bool success;
  final String message;
  final bool isAbuse;
  final int bonusDays;

  ReferralResult({
    required this.success,
    required this.message,
    this.isAbuse = false,
    this.bonusDays = 0,
  });
}

/// Statistics about a user's referrals
class ReferralStats {
  final int totalReferrals;
  final int bonusDaysEarned;

  ReferralStats({
    required this.totalReferrals,
    required this.bonusDaysEarned,
  });
}
