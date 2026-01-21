import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

/// Service for managing pursuits (savings goals)
/// Follows the same lock mechanism pattern as ExpenseHistoryService
class PursuitService {
  static const _keyPursuits = 'pursuits_v1';
  static const _keyTransactions = 'pursuit_transactions_v1';

  // Firestore references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Future chain pattern - ensures FIFO execution without race conditions
  static Future<void> _chain = Future.value();

  /// Get current user's UID
  String? get _userId => _auth.currentUser?.uid;

  /// Firestore pursuits collection reference
  CollectionReference<Map<String, dynamic>>? get _pursuitsCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('pursuits');
  }

  /// Firestore transactions collection reference
  CollectionReference<Map<String, dynamic>>? get _transactionsCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('pursuit_transactions');
  }

  /// Lock mechanism - operations run in FIFO order
  Future<T> _withLock<T>(Future<T> Function() operation) async {
    final previous = _chain;
    final completer = Completer<void>();
    _chain = completer.future;

    await previous;

    try {
      return await operation();
    } finally {
      completer.complete();
    }
  }

  // ============================================
  // PURSUIT CRUD OPERATIONS
  // ============================================

  /// Get all pursuits (both active and completed)
  Future<List<Pursuit>> getAllPursuits() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyPursuits);

    if (json == null || json.isEmpty) {
      return [];
    }

    try {
      return Pursuit.decodeList(json);
    } catch (e) {
      return [];
    }
  }

  /// Get active (not archived, not completed) pursuits
  Future<List<Pursuit>> getActivePursuits() async {
    final all = await getAllPursuits();
    return all
        .where((p) => !p.isArchived && !p.isCompleted)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get completed pursuits
  Future<List<Pursuit>> getCompletedPursuits() async {
    final all = await getAllPursuits();
    return all.where((p) => p.isCompleted).toList()
      ..sort((a, b) => (b.completedAt ?? b.updatedAt)
          .compareTo(a.completedAt ?? a.updatedAt));
  }

  /// Get a single pursuit by ID
  Future<Pursuit?> getPursuitById(String id) async {
    final all = await getAllPursuits();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a new pursuit
  Future<void> createPursuit(Pursuit pursuit) async {
    await _withLock(() async {
      final pursuits = await getAllPursuits();
      pursuits.insert(0, pursuit);
      await _savePursuits(pursuits);

      // Sync to Firestore
      await _syncPursuitToFirestore(pursuit);
    });
  }

  /// Update an existing pursuit
  Future<void> updatePursuit(Pursuit pursuit) async {
    await _withLock(() async {
      final pursuits = await getAllPursuits();
      final index = pursuits.indexWhere((p) => p.id == pursuit.id);

      if (index != -1) {
        final updated = pursuit.copyWith(updatedAt: DateTime.now());
        pursuits[index] = updated;
        await _savePursuits(pursuits);

        // Sync to Firestore
        await _syncPursuitToFirestore(updated);
      }
    });
  }

  /// Add savings to a pursuit
  Future<void> addSavings(
    String pursuitId,
    double amount,
    TransactionSource source, {
    String? note,
    String? currency,
  }) async {
    await _withLock(() async {
      final pursuits = await getAllPursuits();
      final index = pursuits.indexWhere((p) => p.id == pursuitId);

      if (index != -1) {
        final pursuit = pursuits[index];
        final newSavedAmount = pursuit.savedAmount + amount;
        final updated = pursuit.copyWith(
          savedAmount: newSavedAmount,
          updatedAt: DateTime.now(),
        );
        pursuits[index] = updated;
        await _savePursuits(pursuits);

        // Create transaction record
        final transaction = PursuitTransaction.create(
          pursuitId: pursuitId,
          amount: amount,
          currency: currency ?? pursuit.currency,
          source: source,
          note: note,
        );
        await _addTransaction(transaction);

        // Sync to Firestore
        await _syncPursuitToFirestore(updated);
        await _syncTransactionToFirestore(transaction);
      }
    });
  }

  /// Mark a pursuit as completed
  Future<void> completePursuit(String pursuitId) async {
    await _withLock(() async {
      final pursuits = await getAllPursuits();
      final index = pursuits.indexWhere((p) => p.id == pursuitId);

      if (index != -1) {
        final updated = pursuits[index].copyWith(
          completedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        pursuits[index] = updated;
        await _savePursuits(pursuits);

        // Sync to Firestore
        await _syncPursuitToFirestore(updated);
      }
    });
  }

  /// Archive a pursuit (soft delete)
  Future<void> archivePursuit(String pursuitId) async {
    await _withLock(() async {
      final pursuits = await getAllPursuits();
      final index = pursuits.indexWhere((p) => p.id == pursuitId);

      if (index != -1) {
        final updated = pursuits[index].copyWith(
          isArchived: true,
          updatedAt: DateTime.now(),
        );
        pursuits[index] = updated;
        await _savePursuits(pursuits);

        // Sync to Firestore
        await _syncPursuitToFirestore(updated);
      }
    });
  }

  /// Delete a pursuit permanently
  Future<void> deletePursuit(String pursuitId) async {
    await _withLock(() async {
      final pursuits = await getAllPursuits();
      pursuits.removeWhere((p) => p.id == pursuitId);
      await _savePursuits(pursuits);

      // Delete from Firestore
      await _deletePursuitFromFirestore(pursuitId);

      // Delete associated transactions
      await _deleteTransactionsForPursuit(pursuitId);
    });
  }

  // ============================================
  // TRANSACTION OPERATIONS
  // ============================================

  /// Get all transactions for a pursuit
  Future<List<PursuitTransaction>> getTransactions(String pursuitId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyTransactions);

    if (json == null || json.isEmpty) {
      return [];
    }

    try {
      final all = PursuitTransaction.decodeList(json);
      return all.where((t) => t.pursuitId == pursuitId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  /// Add a transaction record
  Future<void> _addTransaction(PursuitTransaction transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyTransactions);

    List<PursuitTransaction> transactions = [];
    if (json != null && json.isNotEmpty) {
      try {
        transactions = PursuitTransaction.decodeList(json);
      } catch (e) {
        // Start fresh if corrupted
      }
    }

    transactions.insert(0, transaction);
    await prefs.setString(
      _keyTransactions,
      PursuitTransaction.encodeList(transactions),
    );
  }

  /// Delete all transactions for a pursuit
  Future<void> _deleteTransactionsForPursuit(String pursuitId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyTransactions);

    if (json == null || json.isEmpty) return;

    try {
      final transactions = PursuitTransaction.decodeList(json);
      transactions.removeWhere((t) => t.pursuitId == pursuitId);
      await prefs.setString(
        _keyTransactions,
        PursuitTransaction.encodeList(transactions),
      );
    } catch (e) {
      // Ignore errors
    }
  }

  // ============================================
  // FREE TIER LIMIT
  // ============================================

  /// Check if user can create a new pursuit (Free: 1 max)
  Future<bool> canCreatePursuit(bool isPremium) async {
    if (isPremium) return true;

    final pursuits = await getActivePursuits();
    return pursuits.isEmpty;
  }

  /// Get the active pursuit count
  Future<int> getActivePursuitCount() async {
    final pursuits = await getActivePursuits();
    return pursuits.length;
  }

  // ============================================
  // LOCAL STORAGE
  // ============================================

  Future<void> _savePursuits(List<Pursuit> pursuits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPursuits, Pursuit.encodeList(pursuits));
  }

  /// Clear all local data (for testing)
  Future<void> clearAll() async {
    await _withLock(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPursuits);
      await prefs.remove(_keyTransactions);
    });
  }

  // ============================================
  // FIRESTORE SYNC
  // ============================================

  Future<void> _syncPursuitToFirestore(Pursuit pursuit) async {
    final collection = _pursuitsCollection;
    if (collection == null) return;

    try {
      await collection.doc(pursuit.id).set({
        ...pursuit.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent fail - local storage is primary
    }
  }

  Future<void> _syncTransactionToFirestore(PursuitTransaction transaction) async {
    final collection = _transactionsCollection;
    if (collection == null) return;

    try {
      await collection.doc(transaction.id).set({
        ...transaction.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent fail - local storage is primary
    }
  }

  Future<void> _deletePursuitFromFirestore(String pursuitId) async {
    final collection = _pursuitsCollection;
    if (collection == null) return;

    try {
      await collection.doc(pursuitId).delete();
    } catch (e) {
      // Silent fail
    }
  }

  /// Sync all local pursuits to Firestore
  Future<void> syncAllToFirestore() async {
    final collection = _pursuitsCollection;
    if (collection == null) return;

    try {
      final pursuits = await getAllPursuits();
      if (pursuits.isEmpty) return;

      final batch = _firestore.batch();
      for (final pursuit in pursuits) {
        batch.set(collection.doc(pursuit.id), {
          ...pursuit.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      // Silent fail
    }
  }

  /// Restore pursuits from Firestore
  Future<void> syncFromFirestore() async {
    final collection = _pursuitsCollection;
    if (collection == null) return;

    try {
      final snapshots = await collection.orderBy('createdAt', descending: true).get();

      if (snapshots.docs.isEmpty) return;

      final pursuits = snapshots.docs
          .map((doc) => Pursuit.fromJson(doc.data()))
          .toList();

      await _savePursuits(pursuits);
    } catch (e) {
      // Silent fail
    }
  }
}
