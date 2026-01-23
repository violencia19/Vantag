import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class ExpenseHistoryService {
  static const _keyExpenses = 'expense_history';
  static const int maxLocalExpenses = 100;

  // Firestore referansı
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Future chain pattern - race condition olmadan sıralı çalışma
  static Future<void> _chain = Future.value();

  /// Kullanıcının UID'sini al (anonymous auth)
  String? get _userId => _auth.currentUser?.uid;

  /// Firestore expenses collection referansı
  CollectionReference<Map<String, dynamic>>? get _expensesCollection {
    final uid = _userId;
    if (uid == null) {
      debugPrint("⚠️ [Firestore] Kullanıcı UID null - Auth yapılmamış!");
      return null;
    }
    return _firestore.collection('users').doc(uid).collection('expenses');
  }

  /// Expense için unique ID oluştur (Firestore document ID)
  String _generateExpenseId(Expense expense) {
    return '${expense.date.millisecondsSinceEpoch}_${expense.amount.hashCode.abs()}';
  }

  /// Lock mekanizması - işlemler FIFO sırasıyla çalışır
  Future<T> _withLock<T>(Future<T> Function() operation) async {
    // Atomik: önceki zinciri al + yeni zincir oluştur (await yok = kesinti yok)
    final previous = _chain;
    final completer = Completer<void>();
    _chain = completer.future;

    // Önceki işlem bitene kadar bekle
    await previous;

    try {
      return await operation();
    } finally {
      completer.complete();
    }
  }

  /// Tüm harcamaları getir (geçmiş listesi için)
  Future<List<Expense>> getAllExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyExpenses);

    if (json == null || json.isEmpty) {
      return [];
    }

    try {
      return Expense.decodeList(json);
    } catch (e) {
      // Corrupted data durumunda boş liste döndür
      return [];
    }
  }

  /// Sadece gerçek kayıtları getir (istatistikler için)
  Future<List<Expense>> getRealExpenses() async {
    final all = await getAllExpenses();
    return all.where((e) => e.isReal).toList();
  }

  /// Sadece simülasyonları getir
  Future<List<Expense>> getSimulationExpenses() async {
    final all = await getAllExpenses();
    return all.where((e) => e.isSimulation).toList();
  }

  /// Eski API uyumluluğu için (tüm harcamalar)
  Future<List<Expense>> getExpenses() async {
    return getAllExpenses();
  }

  /// Harcama ekle - hem local hem Firestore'a kaydeder
  /// Local'de max 100 tutulur, Firestore'da hepsi saklanır (Pro için)
  Future<void> addExpense(Expense expense) async {
    await _withLock(() async {
      // 1. Local'e kaydet (max 100 limit)
      final expenses = await getExpenses();
      expenses.insert(0, expense);

      // Local cache limit - en eski kayıtları sil
      if (expenses.length > maxLocalExpenses) {
        expenses.removeRange(maxLocalExpenses, expenses.length);
      }

      await _saveExpenses(expenses);

      // 2. Firestore'a kaydet (hepsi saklanır - Pro için archive)
      await _syncToFirestore(expense);
    });
  }

  /// Firestore'a tek bir expense kaydet
  Future<void> _syncToFirestore(Expense expense) async {
    final uid = _userId;
    debugPrint("🔄 [Firestore] Yazma başlıyor... UID: $uid");

    if (uid == null) {
      debugPrint(
        "❌ [Firestore] HATA: Kullanıcı giriş yapmamış! Auth kontrolü yapın.",
      );
      return;
    }

    final collection = _expensesCollection;
    if (collection == null) {
      debugPrint("❌ [Firestore] HATA: Collection referansı alınamadı!");
      return;
    }

    final docId = _generateExpenseId(expense);
    debugPrint("📝 [Firestore] Document ID: $docId");
    debugPrint("📝 [Firestore] Path: users/$uid/expenses/$docId");

    try {
      await collection.doc(docId).set({
        ...expense.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint(
        "✅ [Firestore] Yazma Başarılı! ${expense.amount} TL - ${expense.category}",
      );
    } on FirebaseException catch (e) {
      debugPrint("❌ [Firestore] Firebase Hatası!");
      debugPrint("   Code: ${e.code}");
      debugPrint("   Message: ${e.message}");
      if (e.code == 'permission-denied') {
        debugPrint(
          "   💡 ÇÖZÜM: Firebase Console > Firestore > Rules kısmını kontrol edin.",
        );
        debugPrint("   💡 Test için şu kuralları kullanın:");
        debugPrint("   rules_version = '2';");
        debugPrint("   service cloud.firestore {");
        debugPrint("     match /databases/{database}/documents {");
        debugPrint("       match /{document=**} {");
        debugPrint("         allow read, write: if true;");
        debugPrint("       }");
        debugPrint("     }");
        debugPrint("   }");
      }
    } catch (e) {
      debugPrint("❌ [Firestore] Beklenmeyen Hata: $e");
      debugPrint("   Type: ${e.runtimeType}");
    }
  }

  /// Firestore'dan bir expense sil
  Future<void> _deleteFromFirestore(Expense expense) async {
    final uid = _userId;
    if (uid == null) {
      debugPrint("⚠️ [Firestore] Silme atlandı - kullanıcı giriş yapmamış");
      return;
    }

    final collection = _expensesCollection;
    if (collection == null) return;

    final docId = _generateExpenseId(expense);
    debugPrint(
      "🗑️ [Firestore] Silme başlıyor... Path: users/$uid/expenses/$docId",
    );

    try {
      await collection.doc(docId).delete();
      debugPrint("✅ [Firestore] Silme Başarılı!");
    } on FirebaseException catch (e) {
      debugPrint("❌ [Firestore] Silme Hatası: ${e.code} - ${e.message}");
    } catch (e) {
      debugPrint("❌ [Firestore] Beklenmeyen Silme Hatası: $e");
    }
  }

  /// Firestore'da bir expense güncelle
  Future<void> _updateInFirestore(
    Expense oldExpense,
    Expense newExpense,
  ) async {
    final uid = _userId;
    if (uid == null) {
      debugPrint(
        "⚠️ [Firestore] Güncelleme atlandı - kullanıcı giriş yapmamış",
      );
      return;
    }

    final collection = _expensesCollection;
    if (collection == null) return;

    debugPrint("🔄 [Firestore] Güncelleme başlıyor...");

    try {
      // Eski document'ı sil (ID değişmiş olabilir)
      final oldDocId = _generateExpenseId(oldExpense);
      await collection.doc(oldDocId).delete();
      debugPrint("✅ [Firestore] Eski document silindi: $oldDocId");

      // Yeni document oluştur
      final newDocId = _generateExpenseId(newExpense);
      await collection.doc(newDocId).set({
        ...newExpense.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ [Firestore] Yeni document oluşturuldu: $newDocId");
    } on FirebaseException catch (e) {
      debugPrint("❌ [Firestore] Güncelleme Hatası: ${e.code} - ${e.message}");
    } catch (e) {
      debugPrint("❌ [Firestore] Beklenmeyen Güncelleme Hatası: $e");
    }
  }

  Future<void> updateExpense(int index, Expense expense) async {
    await _withLock(() async {
      final expenses = await getExpenses();
      if (index >= 0 && index < expenses.length) {
        final oldExpense = expenses[index];
        expenses[index] = expense;
        await _saveExpenses(expenses);
        debugPrint("✅ [Local] Harcama güncellendi: index=$index");

        // Firestore'da güncelle
        await _updateInFirestore(oldExpense, expense);
      }
    });
  }

  Future<void> deleteExpense(int index) async {
    await _withLock(() async {
      final expenses = await getExpenses();
      if (index >= 0 && index < expenses.length) {
        final expenseToDelete = expenses[index];
        expenses.removeAt(index);
        await _saveExpenses(expenses);
        debugPrint("✅ [Local] Harcama silindi: index=$index");

        // Firestore'dan sil
        await _deleteFromFirestore(expenseToDelete);
      }
    });
  }

  /// İstatistikleri getir (SADECE gerçek kayıtlar)
  Future<DecisionStats> getStats() async {
    final expenses = await getRealExpenses();
    return DecisionStats.fromExpenses(expenses);
  }

  Future<void> _saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyExpenses, Expense.encodeList(expenses));
  }

  /// Tüm geçmişi temizle (test için)
  Future<void> clearAll() async {
    await _withLock(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyExpenses);
      debugPrint("✅ [Local] Tüm veriler temizlendi");

      // Firestore'dan da temizle
      await _clearFirestore();
    });
  }

  /// Firestore'daki tüm expense'leri sil
  Future<void> _clearFirestore() async {
    final uid = _userId;
    if (uid == null) {
      debugPrint("⚠️ [Firestore] Temizleme atlandı - kullanıcı giriş yapmamış");
      return;
    }

    final collection = _expensesCollection;
    if (collection == null) return;

    debugPrint("🗑️ [Firestore] Toplu silme başlıyor...");

    try {
      final snapshots = await collection.get();
      if (snapshots.docs.isEmpty) {
        debugPrint("ℹ️ [Firestore] Silinecek document yok");
        return;
      }

      final batch = _firestore.batch();
      for (final doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint("✅ [Firestore] ${snapshots.docs.length} document silindi");
    } on FirebaseException catch (e) {
      debugPrint("❌ [Firestore] Toplu Silme Hatası: ${e.code} - ${e.message}");
    } catch (e) {
      debugPrint("❌ [Firestore] Beklenmeyen Toplu Silme Hatası: $e");
    }
  }

  /// Local verileri Firestore'a toplu senkronize et
  /// İlk kurulum veya migration için kullanılabilir
  Future<void> syncAllToFirestore() async {
    final uid = _userId;
    if (uid == null) {
      debugPrint("❌ [Sync] Kullanıcı giriş yapmamış - sync yapılamaz!");
      return;
    }

    final collection = _expensesCollection;
    if (collection == null) return;

    debugPrint("🔄 [Sync] Local → Firestore senkronizasyonu başlıyor...");

    try {
      final expenses = await getAllExpenses();
      if (expenses.isEmpty) {
        debugPrint("ℹ️ [Sync] Senkronize edilecek veri yok");
        return;
      }

      final batch = _firestore.batch();

      for (final expense in expenses) {
        final docId = _generateExpenseId(expense);
        batch.set(collection.doc(docId), {
          ...expense.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint("✅ [Sync] ${expenses.length} harcama Firestore'a yüklendi!");
    } on FirebaseException catch (e) {
      debugPrint("❌ [Sync] Hata: ${e.code} - ${e.message}");
    } catch (e) {
      debugPrint("❌ [Sync] Beklenmeyen Hata: $e");
    }
  }

  /// Firestore'dan local'e verileri çek (restore için)
  Future<void> syncFromFirestore() async {
    final uid = _userId;
    if (uid == null) {
      debugPrint("❌ [Sync] Kullanıcı giriş yapmamış - restore yapılamaz!");
      return;
    }

    final collection = _expensesCollection;
    if (collection == null) return;

    debugPrint("🔄 [Sync] Firestore → Local senkronizasyonu başlıyor...");

    try {
      final snapshots = await collection
          .orderBy('date', descending: true)
          .get();

      if (snapshots.docs.isEmpty) {
        debugPrint("ℹ️ [Sync] Firestore'da veri yok");
        return;
      }

      final expenses = snapshots.docs
          .map((doc) => Expense.fromJson(doc.data()))
          .toList();

      await _saveExpenses(expenses);
      debugPrint("✅ [Sync] ${expenses.length} harcama local'e indirildi!");
    } on FirebaseException catch (e) {
      debugPrint("❌ [Sync] Hata: ${e.code} - ${e.message}");
    } catch (e) {
      debugPrint("❌ [Sync] Beklenmeyen Hata: $e");
    }
  }

  /// Debug: Auth durumunu kontrol et
  void debugAuthStatus() {
    final user = _auth.currentUser;
    debugPrint("═══════════════════════════════════════");
    debugPrint("🔍 [DEBUG] Firebase Auth Durumu:");
    debugPrint("   User: ${user != null ? 'VAR' : 'YOK'}");
    debugPrint("   UID: ${user?.uid ?? 'null'}");
    debugPrint("   Anonymous: ${user?.isAnonymous ?? 'N/A'}");
    debugPrint("═══════════════════════════════════════");
  }

  /// Debug: Firestore bağlantısını test et
  Future<void> debugFirestoreConnection() async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("🔍 [DEBUG] Firestore Bağlantı Testi:");

    final uid = _userId;
    if (uid == null) {
      debugPrint("   ❌ Auth yapılmamış - test edilemiyor");
      debugPrint("═══════════════════════════════════════");
      return;
    }

    debugPrint("   UID: $uid");
    debugPrint("   Path: users/$uid/expenses");

    try {
      // Basit bir test yazması yap
      final testDoc = _firestore
          .collection('users')
          .doc(uid)
          .collection('_test')
          .doc('connection');
      await testDoc.set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint("   ✅ Yazma testi başarılı!");

      // Test verisini sil
      await testDoc.delete();
      debugPrint("   ✅ Silme testi başarılı!");
      debugPrint("   🎉 Firestore bağlantısı çalışıyor!");
    } on FirebaseException catch (e) {
      debugPrint("   ❌ Firestore Hatası: ${e.code}");
      debugPrint("   Message: ${e.message}");
    } catch (e) {
      debugPrint("   ❌ Beklenmeyen Hata: $e");
    }
    debugPrint("═══════════════════════════════════════");
  }

  // ============================================
  // PRO USERS: ARŞİVLENMİŞ VERİLERE ERİŞİM
  // ============================================

  /// Firestore'dan tüm expense sayısını getir
  Future<int> getTotalExpenseCount() async {
    final collection = _expensesCollection;
    if (collection == null) return 0;

    try {
      final snapshot = await collection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Firestore'dan arşivlenmiş expense'leri getir (Pro kullanıcılar için)
  /// [offset]: Atlanacak kayıt sayısı (pagination için)
  /// [limit]: Getirilecek kayıt sayısı
  Future<List<Expense>> fetchArchivedExpenses({
    int offset = 0,
    int limit = 50,
  }) async {
    final collection = _expensesCollection;
    if (collection == null) {
      return [];
    }

    try {
      Query<Map<String, dynamic>> query = collection.orderBy(
        'date',
        descending: true,
      );

      // Offset için: önce offset kadar kayıt atla
      if (offset > 0) {
        final skipDocs = await query.limit(offset).get();
        if (skipDocs.docs.isNotEmpty) {
          final lastDoc = skipDocs.docs.last;
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshots = await query.limit(limit).get();

      return snapshots.docs.map((doc) => Expense.fromJson(doc.data())).toList();
    } on FirebaseException catch (e) {
      debugPrint(
        "❌ [Firestore] Archive Fetch Hatası: ${e.code} - ${e.message}",
      );
      return [];
    } catch (e) {
      debugPrint("❌ [Firestore] Beklenmeyen Archive Fetch Hatası: $e");
      return [];
    }
  }

  /// Firestore'dan TÜM expense'leri getir (Pro export için)
  Future<List<Expense>> fetchAllExpensesFromFirestore() async {
    final collection = _expensesCollection;
    if (collection == null) {
      return [];
    }

    try {
      final snapshots = await collection
          .orderBy('date', descending: true)
          .get();

      return snapshots.docs.map((doc) => Expense.fromJson(doc.data())).toList();
    } catch (e) {
      return [];
    }
  }
}
