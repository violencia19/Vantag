import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/savings_pool.dart';
import '../services/savings_pool_service.dart';

/// Tasarruf Havuzu State Provider
class SavingsPoolProvider extends ChangeNotifier {
  final SavingsPoolService _service = SavingsPoolService();

  SavingsPool _pool = SavingsPool.empty();
  StreamSubscription<SavingsPool>? _subscription;
  bool _isLoading = true;
  String? _error;

  // Getters
  SavingsPool get pool => _pool;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSaved => _pool.totalSaved;
  double get allocatedToDreams => _pool.allocatedToDreams;
  double get available => _pool.available;
  double get shadowDebt => _pool.shadowDebt;
  bool get hasDebt => _pool.hasDebt;
  bool get canUseJoker => _pool.canUseJoker;
  bool get jokerUsedThisMonth => _pool.jokerUsedThisMonth;

  /// Provider'ı başlat ve stream'e bağlan
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // İlk olarak local'den yükle (hızlı başlangıç için)
      _pool = await _service.getPool();
      _isLoading = false;
      notifyListeners();
      debugPrint(
        '💰 [SavingsPoolProvider] Initial load: available=${_pool.available}, debt=${_pool.shadowDebt}',
      );

      // Aylık joker reset kontrolü
      await _service.resetMonthlyJoker();

      // Stream'e bağlan (background updates için)
      _subscription?.cancel();
      _subscription = _service.poolStream.listen(
        (pool) {
          _pool = pool;
          _isLoading = false;
          _error = null;
          notifyListeners();
          debugPrint(
            '💰 [SavingsPoolProvider] Pool updated: available=${pool.available}, debt=${pool.shadowDebt}',
          );
        },
        onError: (e) {
          // Stream hatası olsa bile local data'yı kullan, loading'i kapat
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
          debugPrint('❌ [SavingsPoolProvider] Stream error: $e');
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ [SavingsPoolProvider] Initialize error: $e');
    }
  }

  /// Tasarruf ekle (vazgeçme durumunda)
  Future<void> addSavings(double amount) async {
    if (amount <= 0) return;

    try {
      await _service.addSavings(amount);
      debugPrint('✅ [SavingsPoolProvider] Added savings: $amount');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('❌ [SavingsPoolProvider] addSavings error: $e');
    }
  }

  /// Hayale para ayır
  /// Returns true if successful, false if needs budget shift dialog
  Future<AllocationResult> allocateToDream(
    double amount,
    String dreamId, {
    BudgetShiftSource? source,
  }) async {
    if (amount <= 0) {
      return AllocationResult.error('Invalid amount');
    }

    // Yeterli bakiye var mı kontrol et
    if (source == null && available < amount) {
      if (available > 0) {
        // Kısmi bakiye var, bütçe kaydırma gerekiyor
        return AllocationResult.needsBudgetShift(amount - available);
      } else {
        // Hiç bakiye yok, tam kaynak belirtmeli
        return AllocationResult.needsFullSource(amount);
      }
    }

    try {
      final success = await _service.allocateToDream(
        amount,
        dreamId,
        source: source,
      );
      if (success) {
        return AllocationResult.success();
      } else {
        if (source == BudgetShiftSource.joker && jokerUsedThisMonth) {
          return AllocationResult.jokerAlreadyUsed();
        }
        return AllocationResult.error('Allocation failed');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return AllocationResult.error(e.toString());
    }
  }

  /// Joker kullan
  Future<bool> useJoker(double amount, String dreamId) async {
    if (!canUseJoker) return false;

    final result = await allocateToDream(
      amount,
      dreamId,
      source: BudgetShiftSource.joker,
    );
    return result.isSuccess;
  }

  /// Gölge borç oluştur
  Future<void> createShadowDebt(double amount, String dreamId) async {
    try {
      await _service.createShadowDebt(amount, dreamId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Borç öde
  Future<void> repayDebt(double amount) async {
    try {
      await _service.repayDebt(amount);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Hayalden para geri al (hayal silindiğinde veya tamamlandığında)
  Future<void> deallocateFromDream(double amount) async {
    try {
      await _service.deallocateFromDream(amount);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Yenile
  Future<void> refresh() async {
    await initialize();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Havuz allocation sonucu
class AllocationResult {
  final AllocationStatus status;
  final double? shortfall; // Eksik miktar
  final String? errorMessage;

  const AllocationResult._({
    required this.status,
    this.shortfall,
    this.errorMessage,
  });

  factory AllocationResult.success() =>
      const AllocationResult._(status: AllocationStatus.success);

  factory AllocationResult.needsBudgetShift(double shortfall) =>
      AllocationResult._(
        status: AllocationStatus.needsBudgetShift,
        shortfall: shortfall,
      );

  factory AllocationResult.needsFullSource(double amount) => AllocationResult._(
    status: AllocationStatus.needsFullSource,
    shortfall: amount,
  );

  factory AllocationResult.jokerAlreadyUsed() =>
      const AllocationResult._(status: AllocationStatus.jokerAlreadyUsed);

  factory AllocationResult.error(String message) =>
      AllocationResult._(status: AllocationStatus.error, errorMessage: message);

  bool get isSuccess => status == AllocationStatus.success;
  bool get needsBudgetShift => status == AllocationStatus.needsBudgetShift;
  bool get needsFullSource => status == AllocationStatus.needsFullSource;
  bool get isJokerAlreadyUsed => status == AllocationStatus.jokerAlreadyUsed;
  bool get isError => status == AllocationStatus.error;
}

enum AllocationStatus {
  success,
  needsBudgetShift,
  needsFullSource,
  jokerAlreadyUsed,
  error,
}
