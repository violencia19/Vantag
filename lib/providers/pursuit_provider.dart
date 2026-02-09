import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/pursuit_service.dart';

/// Provider for managing pursuits (savings goals) state
class PursuitProvider extends ChangeNotifier {
  final PursuitService _service = PursuitService();

  List<Pursuit> _pursuits = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  // ============================================
  // GETTERS
  // ============================================

  /// All pursuits (both active and completed)
  List<Pursuit> get allPursuits => List.unmodifiable(_pursuits);

  /// Active pursuits (not archived, not completed)
  List<Pursuit> get activePursuits =>
      _pursuits.where((p) => !p.isArchived && !p.isCompleted).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  /// Completed pursuits
  List<Pursuit> get completedPursuits =>
      _pursuits.where((p) => p.isCompleted).toList()..sort(
        (a, b) => (b.completedAt ?? b.updatedAt).compareTo(
          a.completedAt ?? a.updatedAt,
        ),
      );

  /// Total saved amount across all active pursuits
  double get totalSaved =>
      activePursuits.fold(0.0, (sum, p) => sum + p.savedAmount);

  /// Total target amount across all active pursuits
  double get totalTarget =>
      activePursuits.fold(0.0, (sum, p) => sum + p.targetAmount);

  /// Overall progress percentage (0.0 to 1.0)
  double get overallProgress =>
      totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Number of active pursuits
  int get activePursuitCount => activePursuits.length;

  /// Number of completed pursuits
  int get completedPursuitCount => completedPursuits.length;

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Initialize the provider and load pursuits
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pursuits = await _service.getAllPursuits();
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
      debugPrint('PursuitProvider initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh pursuits from storage
  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pursuits = await _service.getAllPursuits();
    } catch (e) {
      _error = e.toString();
      debugPrint('PursuitProvider refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CRUD OPERATIONS
  // ============================================

  /// Create a new pursuit
  /// Returns true if successful, false if limit reached (free tier)
  Future<bool> createPursuit(Pursuit pursuit, {bool isPremium = false}) async {
    final canCreate = await _service.canCreatePursuit(isPremium);
    if (!canCreate) {
      return false;
    }

    try {
      await _service.createPursuit(pursuit);
      _pursuits.insert(0, pursuit);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('PursuitProvider createPursuit error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update an existing pursuit
  Future<void> updatePursuit(Pursuit pursuit) async {
    try {
      await _service.updatePursuit(pursuit);
      final index = _pursuits.indexWhere((p) => p.id == pursuit.id);
      if (index != -1) {
        _pursuits[index] = pursuit.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('PursuitProvider updatePursuit error: $e');
      notifyListeners();
    }
  }

  /// Add savings to a pursuit
  /// Returns true if pursuit reached 100% (for celebration)
  Future<bool> addSavings(
    String pursuitId,
    double amount, {
    TransactionSource source = TransactionSource.manual,
    String? note,
    String? currency,
  }) async {
    try {
      await _service.addSavings(
        pursuitId,
        amount,
        source,
        note: note,
        currency: currency,
      );

      final index = _pursuits.indexWhere((p) => p.id == pursuitId);
      if (index != -1) {
        final pursuit = _pursuits[index];
        final newSavedAmount = pursuit.savedAmount + amount;
        final updated = pursuit.copyWith(
          savedAmount: newSavedAmount,
          updatedAt: DateTime.now(),
        );
        _pursuits[index] = updated;
        notifyListeners();

        // Check if pursuit reached target
        return updated.hasReachedTarget && !pursuit.hasReachedTarget;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('PursuitProvider addSavings error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Mark a pursuit as completed
  Future<void> completePursuit(String pursuitId) async {
    try {
      await _service.completePursuit(pursuitId);

      final index = _pursuits.indexWhere((p) => p.id == pursuitId);
      if (index != -1) {
        _pursuits[index] = _pursuits[index].copyWith(
          completedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('PursuitProvider completePursuit error: $e');
      notifyListeners();
    }
  }

  /// Archive a pursuit (soft delete)
  Future<void> archivePursuit(String pursuitId) async {
    try {
      await _service.archivePursuit(pursuitId);

      final index = _pursuits.indexWhere((p) => p.id == pursuitId);
      if (index != -1) {
        _pursuits[index] = _pursuits[index].copyWith(
          isArchived: true,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('PursuitProvider archivePursuit error: $e');
      notifyListeners();
    }
  }

  /// Delete a pursuit permanently
  Future<void> deletePursuit(String pursuitId) async {
    try {
      await _service.deletePursuit(pursuitId);
      _pursuits.removeWhere((p) => p.id == pursuitId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('PursuitProvider deletePursuit error: $e');
      notifyListeners();
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Get a pursuit by ID
  Pursuit? getPursuitById(String id) {
    try {
      return _pursuits.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get transactions for a pursuit
  Future<List<PursuitTransaction>> getTransactions(String pursuitId) async {
    return await _service.getTransactions(pursuitId);
  }

  /// Check if user can create a new pursuit
  Future<bool> canCreatePursuit(bool isPremium) async {
    return await _service.canCreatePursuit(isPremium);
  }

  /// Reset all data (for account deletion)
  Future<void> resetAllData() async {
    await _service.clearAll();
    _pursuits = [];
    _isInitialized = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Sync from Firestore (for restore)
  Future<void> syncFromCloud() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.syncFromFirestore();
      _pursuits = await _service.getAllPursuits();
    } catch (e) {
      _error = e.toString();
      debugPrint('PursuitProvider syncFromCloud error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync to Firestore (for backup)
  Future<void> syncToCloud() async {
    try {
      await _service.syncAllToFirestore();
    } catch (e) {
      _error = e.toString();
      debugPrint('PursuitProvider syncToCloud error: $e');
      notifyListeners();
    }
  }
}
