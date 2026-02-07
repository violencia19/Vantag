import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/user_profile.dart';
import '../providers/finance_provider.dart';

/// Bütçe hesaplama servisi
/// Zorunlu gider, taksit ve harcanabilir bütçe hesaplamalarını yapar
class BudgetService extends ChangeNotifier {
  final FinanceProvider _financeProvider;

  BudgetService(this._financeProvider) {
    // Provider değiştiğinde biz de güncelleniriz
    _financeProvider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _financeProvider.removeListener(_onProviderChanged);
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // TEMEL GETTER'LAR
  // ═══════════════════════════════════════════════════════════════

  UserProfile? get _profile => _financeProvider.userProfile;
  List<Expense> get _currentMonthExpenses =>
      _financeProvider.currentMonthExpenses;

  /// Saatlik ücret (fallback ile) — always returns > 0 to prevent division-by-zero
  double get hourlyRate {
    if (_profile == null) return 1.0;
    final rate = _profile!.hourlyRate;
    if (rate <= 0) {
      // Fallback: aylık gelir / 160 saat, minimum 1.0 to avoid divide-by-zero
      final fallback = _profile!.monthlyIncome / 160;
      return fallback > 0 ? fallback : 1.0;
    }
    return rate;
  }

  /// Aylık gelir
  double get monthlyIncome => _profile?.monthlyIncome ?? 0;

  // ═══════════════════════════════════════════════════════════════
  // BÜTÇE HESAPLAMALARI
  // ═══════════════════════════════════════════════════════════════

  /// Toplam bütçe (kullanıcı belirledi veya gelir)
  double get totalBudget {
    return _profile?.monthlyBudget ?? monthlyIncome;
  }

  /// Tasarruf hedefi
  double get savingsGoal => _profile?.monthlySavingsGoal ?? 0;

  /// Harcanabilir bütçe (toplam - tasarruf hedefi)
  /// NOT: Zorunlu giderler burada düşülmüyor, onlar ayrı gösterilecek
  double get spendableBudget {
    return totalBudget - savingsGoal;
  }

  // ═══════════════════════════════════════════════════════════════
  // HARCAMA ANALİZİ
  // ═══════════════════════════════════════════════════════════════

  /// Bu ayki toplam harcama
  double get totalExpenses {
    return _currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Zorunlu giderler toplamı (kira, fatura, kredi vs.)
  /// NOT: "Vazgeçtim" (decision=no) harcamalar hariç
  double get mandatoryExpenses {
    return _currentMonthExpenses
        .where((e) => e.isMandatory && e.decision != ExpenseDecision.no)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// İsteğe bağlı harcamalar (zorunlu olmayanlar)
  /// NOT: "Vazgeçtim" (decision=no) harcamalar hariç - bunlar gerçek harcama değil
  double get discretionaryExpenses {
    return _currentMonthExpenses
        .where((e) => !e.isMandatory && e.decision != ExpenseDecision.no)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Bu ayki taksit ödemeleri toplamı
  double get installmentPayments {
    return _currentMonthExpenses
        .where((e) => e.type == ExpenseType.installment)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Bu ay ödenen vade farkı toplamı (tahmini)
  /// Her taksit için: toplam vade farkı / taksit sayısı
  double get totalInterestPaid {
    return _currentMonthExpenses
        .where(
          (e) =>
              e.type == ExpenseType.installment &&
              e.installmentCount != null &&
              e.installmentCount! > 0,
        )
        .fold(0.0, (sum, e) => sum + (e.interestAmount / e.installmentCount!));
  }

  // ═══════════════════════════════════════════════════════════════
  // KALAN BÜTÇE
  // ═══════════════════════════════════════════════════════════════

  /// Gerçek harcanabilir bütçe (zorunlu giderler düşülmüş)
  /// Bu, kullanıcının "kontrol edebildiği" alan
  double get availableBudget {
    final available = spendableBudget - mandatoryExpenses;
    return available > 0 ? available : 0;
  }

  /// Kalan bütçe (harcanabilir - isteğe bağlı harcamalar)
  double get remainingBudget {
    return availableBudget - discretionaryExpenses;
  }

  /// Bütçe aşıldı mı?
  bool get isOverBudget => remainingBudget < 0;

  // ═══════════════════════════════════════════════════════════════
  // PROGRESS BAR
  // ═══════════════════════════════════════════════════════════════

  /// Progress bar yüzdesi (isteğe bağlı harcamalar / harcanabilir bütçe)
  /// 0-100 arası, aşım varsa 100'ü geçebilir (max 150)
  double get budgetUsagePercent {
    if (availableBudget <= 0) return 100;
    final percent = (discretionaryExpenses / availableBudget) * 100;
    return percent.clamp(0, 150);
  }

  /// Progress bar renk seviyesi
  /// 0: Yeşil (<%50), 1: Sarı (%50-70), 2: Turuncu (%70-90), 3: Kırmızı (>%90)
  int get budgetWarningLevel {
    final percent = budgetUsagePercent;
    if (percent < 50) return 0;
    if (percent < 70) return 1;
    if (percent < 90) return 2;
    return 3;
  }

  // ═══════════════════════════════════════════════════════════════
  // SAAT HESAPLAMALARI (Zaman = Para)
  // ═══════════════════════════════════════════════════════════════

  /// Kalan bütçenin saat karşılığı
  double get remainingHours {
    if (hourlyRate <= 0) return 0;
    return remainingBudget / hourlyRate;
  }

  /// Kullanılan bütçenin saat karşılığı (isteğe bağlı)
  double get usedHours {
    if (hourlyRate <= 0) return 0;
    return discretionaryExpenses / hourlyRate;
  }

  /// Zorunlu giderlerin saat karşılığı
  double get mandatoryHours {
    if (hourlyRate <= 0) return 0;
    return mandatoryExpenses / hourlyRate;
  }

  /// Bu ay ödenen vade farklarının saat karşılığı
  double get interestHours {
    if (hourlyRate <= 0) return 0;
    return totalInterestPaid / hourlyRate;
  }

  /// Toplam bütçenin saat karşılığı
  double get totalBudgetHours {
    if (hourlyRate <= 0) return 0;
    return totalBudget / hourlyRate;
  }

  /// Harcanabilir bütçenin saat karşılığı
  double get availableBudgetHours {
    if (hourlyRate <= 0) return 0;
    return availableBudget / hourlyRate;
  }

  // ═══════════════════════════════════════════════════════════════
  // TAKSİT ANALİZİ
  // ═══════════════════════════════════════════════════════════════

  /// Aktif taksitler listesi
  List<Expense> get activeInstallments {
    return _financeProvider.activeInstallments;
  }

  /// Toplam aktif taksit sayısı
  int get activeInstallmentCount => activeInstallments.length;

  /// Aylık toplam taksit yükü
  double get monthlyInstallmentBurden {
    return activeInstallments.fold(0.0, (sum, e) => sum + e.installmentAmount);
  }

  /// Toplam kalan taksit borcu
  double get totalRemainingDebt {
    return activeInstallments.fold(0.0, (sum, e) {
      final remaining = e.remainingInstallments * e.installmentAmount;
      return sum + remaining;
    });
  }

  /// Toplam vade farkı (tüm aktif taksitler)
  double get totalInterestAmount {
    return activeInstallments.fold(0.0, (sum, e) => sum + e.interestAmount);
  }

  /// Toplam vade farkının saat karşılığı
  double get totalInterestHours {
    if (hourlyRate <= 0) return 0;
    return totalInterestAmount / hourlyRate;
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER METODLAR
  // ═══════════════════════════════════════════════════════════════

  /// Belirli bir tutarın saat karşılığı
  double amountToHours(double amount) {
    if (hourlyRate <= 0) return 0;
    return amount / hourlyRate;
  }

  /// Belirli bir saatin TL karşılığı
  double hoursToAmount(double hours) {
    return hours * hourlyRate;
  }

  /// Özet bilgi (debug/logging için)
  Map<String, dynamic> get summary => {
    'totalBudget': totalBudget,
    'savingsGoal': savingsGoal,
    'mandatoryExpenses': mandatoryExpenses,
    'discretionaryExpenses': discretionaryExpenses,
    'availableBudget': availableBudget,
    'remainingBudget': remainingBudget,
    'budgetUsagePercent': budgetUsagePercent,
    'hourlyRate': hourlyRate,
    'remainingHours': remainingHours,
    'activeInstallments': activeInstallmentCount,
    'monthlyInstallmentBurden': monthlyInstallmentBurden,
  };
}
