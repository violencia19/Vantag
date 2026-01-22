import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_pool.dart';

/// Tasarruf Havuzu Service (Local + Firestore hybrid)
/// Falls back to local storage when Firestore fails
class SavingsPoolService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Local storage key
  static const _localKey = 'savings_pool_local';

  // Stream controller for local updates
  final _localStreamController = StreamController<SavingsPool>.broadcast();
  SavingsPool _cachedPool = SavingsPool.empty();
  bool _useLocalOnly = false;

  /// Firestore document reference
  DocumentReference<Map<String, dynamic>>? get _docRef {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('savings_pool').doc('current');
  }

  /// Havuz verisi stream'i (hybrid - tries Firestore, falls back to local)
  Stream<SavingsPool> get poolStream {
    if (_useLocalOnly) {
      return _localStreamController.stream;
    }

    final ref = _docRef;
    if (ref == null) {
      return _localStreamController.stream;
    }

    // Try Firestore first, fall back to local on error
    return ref.snapshots().handleError((e) {
      debugPrint('⚠️ [SavingsPoolService] Firestore error, switching to local: $e');
      _useLocalOnly = true;
      _loadLocalPool().then((pool) => _localStreamController.add(pool));
    }).map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return _cachedPool;
      }
      _cachedPool = SavingsPool.fromFirestore(snapshot.data()!);
      // Also save locally as backup
      _saveLocalPool(_cachedPool);
      return _cachedPool;
    });
  }

  /// Mevcut havuzu getir
  Future<SavingsPool> getPool() async {
    // Try Firestore first
    if (!_useLocalOnly) {
      final ref = _docRef;
      if (ref != null) {
        try {
          final snapshot = await ref.get();
          if (snapshot.exists && snapshot.data() != null) {
            _cachedPool = SavingsPool.fromFirestore(snapshot.data()!);
            _saveLocalPool(_cachedPool); // Backup locally
            return _cachedPool;
          }
        } catch (e) {
          debugPrint('⚠️ [SavingsPoolService] Firestore getPool error, using local: $e');
          _useLocalOnly = true;
        }
      }
    }

    // Fall back to local
    return _loadLocalPool();
  }

  /// Load pool from local storage
  Future<SavingsPool> _loadLocalPool() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_localKey);
      if (json != null) {
        final data = jsonDecode(json) as Map<String, dynamic>;
        _cachedPool = SavingsPool.fromFirestore(data);
        debugPrint('💾 [SavingsPoolService] Loaded from local: $_cachedPool');
        return _cachedPool;
      }
    } catch (e) {
      debugPrint('❌ [SavingsPoolService] Local load error: $e');
    }
    return SavingsPool.empty();
  }

  /// Save pool to local storage
  Future<void> _saveLocalPool(SavingsPool pool) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localKey, jsonEncode(pool.toFirestore(forLocalStorage: true)));
    } catch (e) {
      debugPrint('❌ [SavingsPoolService] Local save error: $e');
    }
  }

  /// Havuzu güncelle (tries Firestore, always updates local)
  Future<void> updatePool(SavingsPool pool) async {
    _cachedPool = pool;

    // Always save locally first
    await _saveLocalPool(pool);
    _localStreamController.add(pool);

    // Try Firestore if not in local-only mode
    if (!_useLocalOnly) {
      final ref = _docRef;
      if (ref != null) {
        try {
          await ref.set(pool.toFirestore(), SetOptions(merge: true));
          debugPrint('✅ [SavingsPoolService] Pool updated (Firestore): $pool');
          return;
        } catch (e) {
          debugPrint('⚠️ [SavingsPoolService] Firestore update failed, local only: $e');
          _useLocalOnly = true;
        }
      }
    }

    debugPrint('✅ [SavingsPoolService] Pool updated (local): $pool');
  }

  /// Tasarruf ekle (vazgeçme durumunda)
  Future<void> addSavings(double amount) async {
    if (amount <= 0) return;

    final pool = await getPool();

    // Önce borç varsa onu kapat
    double remainingAmount = amount;
    double newDebt = pool.shadowDebt;

    if (pool.hasDebt) {
      if (amount >= pool.shadowDebt) {
        // Borç tamamen kapanıyor
        remainingAmount = amount - pool.shadowDebt;
        newDebt = 0;
        debugPrint('💰 [SavingsPoolService] Debt fully paid: ${pool.shadowDebt}');
      } else {
        // Borç kısmen ödeniyor
        newDebt = pool.shadowDebt - amount;
        remainingAmount = 0;
        debugPrint('💰 [SavingsPoolService] Debt partially paid: $amount, remaining debt: $newDebt');
      }
    }

    final newPool = pool.copyWith(
      totalSaved: pool.totalSaved + remainingAmount,
      shadowDebt: newDebt,
    );

    await updatePool(newPool);
  }

  /// Hayale para ayır
  Future<bool> allocateToDream(double amount, String dreamId, {BudgetShiftSource? source}) async {
    if (amount <= 0) return false;

    final pool = await getPool();

    // Joker kontrolü
    if (source == BudgetShiftSource.joker) {
      if (pool.jokerUsedThisMonth) {
        debugPrint('❌ [SavingsPoolService] Joker already used this month');
        return false;
      }

      // Joker kullanıldı, direkt ekle
      final newPool = pool.copyWith(
        allocatedToDreams: pool.allocatedToDreams + amount,
        jokerUsedThisMonth: true,
      );
      await updatePool(newPool);
      debugPrint('🃏 [SavingsPoolService] Joker used for $amount to dream $dreamId');
      return true;
    }

    // Ekstra gelir - direkt ekle
    if (source == BudgetShiftSource.extraIncome) {
      final newPool = pool.copyWith(
        totalSaved: pool.totalSaved + amount,
        allocatedToDreams: pool.allocatedToDreams + amount,
      );
      await updatePool(newPool);
      debugPrint('💰 [SavingsPoolService] Extra income $amount added to dream $dreamId');
      return true;
    }

    // Normal akış - havuzdan al
    if (pool.available >= amount) {
      // Yeterli bakiye var
      final newPool = pool.copyWith(
        allocatedToDreams: pool.allocatedToDreams + amount,
      );
      await updatePool(newPool);
      debugPrint('✅ [SavingsPoolService] Allocated $amount to dream $dreamId');
      return true;
    }

    // Bütçe kaydırma ile ekle (kategori seçilmiş)
    if (source != null) {
      final newPool = pool.copyWith(
        allocatedToDreams: pool.allocatedToDreams + amount,
      );
      await updatePool(newPool);
      debugPrint('📊 [SavingsPoolService] Budget shift from ${source.name}: $amount to dream $dreamId');
      return true;
    }

    // Yetersiz bakiye ve kaynak belirtilmemiş
    debugPrint('❌ [SavingsPoolService] Insufficient funds: available ${pool.available}, requested $amount');
    return false;
  }

  /// Gölge borç oluştur (havuz eksiye düşürülür)
  Future<void> createShadowDebt(double amount, String dreamId) async {
    if (amount <= 0) return;

    final pool = await getPool();
    final newPool = pool.copyWith(
      allocatedToDreams: pool.allocatedToDreams + amount,
      shadowDebt: pool.shadowDebt + amount,
    );
    await updatePool(newPool);
    debugPrint('🔴 [SavingsPoolService] Shadow debt created: $amount for dream $dreamId');
  }

  /// Borç öde
  Future<void> repayDebt(double amount) async {
    if (amount <= 0) return;

    final pool = await getPool();
    if (!pool.hasDebt) return;

    final newDebt = (pool.shadowDebt - amount).clamp(0.0, double.infinity);
    final newPool = pool.copyWith(shadowDebt: newDebt);
    await updatePool(newPool);
    debugPrint('💳 [SavingsPoolService] Debt repaid: $amount, remaining: $newDebt');
  }

  /// Aylık joker reset (ay değişince çağrılır)
  Future<void> resetMonthlyJoker() async {
    final pool = await getPool();
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    // Aynı ayda zaten resetlenmişse atla
    if (pool.jokerResetDate.year == currentMonth.year &&
        pool.jokerResetDate.month == currentMonth.month) {
      return;
    }

    final newPool = pool.copyWith(
      jokerUsedThisMonth: false,
      jokerResetDate: currentMonth,
    );
    await updatePool(newPool);
    debugPrint('🔄 [SavingsPoolService] Monthly joker reset');
  }

  /// Havuzdan hayale ayrılan tutarı geri al (hayal silindiğinde)
  Future<void> deallocateFromDream(double amount) async {
    if (amount <= 0) return;

    final pool = await getPool();
    final newPool = pool.copyWith(
      allocatedToDreams: (pool.allocatedToDreams - amount).clamp(0.0, double.infinity),
    );
    await updatePool(newPool);
    debugPrint('↩️ [SavingsPoolService] Deallocated $amount from dreams');
  }
}
