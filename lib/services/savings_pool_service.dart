import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/savings_pool.dart';

/// Tasarruf Havuzu Firestore Service
class SavingsPoolService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firestore document reference
  DocumentReference<Map<String, dynamic>>? get _docRef {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('savings_pool').doc('current');
  }

  /// Havuz verisi stream'i
  Stream<SavingsPool> get poolStream {
    final ref = _docRef;
    if (ref == null) {
      return Stream.value(SavingsPool.empty());
    }

    return ref.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return SavingsPool.empty();
      }
      return SavingsPool.fromFirestore(snapshot.data()!);
    });
  }

  /// Mevcut havuzu getir
  Future<SavingsPool> getPool() async {
    final ref = _docRef;
    if (ref == null) return SavingsPool.empty();

    try {
      final snapshot = await ref.get();
      if (!snapshot.exists || snapshot.data() == null) {
        return SavingsPool.empty();
      }
      return SavingsPool.fromFirestore(snapshot.data()!);
    } catch (e) {
      debugPrint('❌ [SavingsPoolService] getPool error: $e');
      return SavingsPool.empty();
    }
  }

  /// Havuzu güncelle
  Future<void> updatePool(SavingsPool pool) async {
    final ref = _docRef;
    if (ref == null) {
      debugPrint('❌ [SavingsPoolService] No user logged in');
      return;
    }

    try {
      await ref.set(pool.toFirestore(), SetOptions(merge: true));
      debugPrint('✅ [SavingsPoolService] Pool updated: $pool');
    } catch (e) {
      debugPrint('❌ [SavingsPoolService] updatePool error: $e');
      rethrow;
    }
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
