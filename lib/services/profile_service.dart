import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ProfileService {
  // Legacy keys (eski format)
  static const _keyMonthlyIncome = 'monthly_income';
  static const _keyDailyHours = 'daily_hours';
  static const _keyWorkDaysPerWeek = 'work_days_per_week';
  static const _keyProfilePhotoPath = 'profile_photo_path';
  static const _keyOnboardingCompleted = 'onboarding_completed';

  // Yeni format keys
  static const _keyIncomeSources = 'income_sources';

  // Bütçe ayarları
  static const _keyMonthlyBudget = 'monthly_budget';
  static const _keySavingsGoal = 'savings_goal';

  // Salary & Balance Management
  static const _keySalaryDay = 'salary_day';
  static const _keyCurrentBalance = 'current_balance';
  static const _keyLastSalaryConfirmedDate = 'last_salary_confirmed_date';

  // One-time incomes
  static const _keyIncomes = 'incomes_v1';

  Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final hours = prefs.getDouble(_keyDailyHours);
    final days = prefs.getInt(_keyWorkDaysPerWeek);

    if (hours == null || days == null) {
      return null;
    }

    // Bütçe ayarlarını oku
    final monthlyBudget = prefs.getDouble(_keyMonthlyBudget);
    final savingsGoal = prefs.getDouble(_keySavingsGoal);

    // Salary & Balance Management
    final salaryDay = prefs.getInt(_keySalaryDay);
    final currentBalance = prefs.getDouble(_keyCurrentBalance);
    final lastSalaryConfirmedDateStr = prefs.getString(
      _keyLastSalaryConfirmedDate,
    );
    final lastSalaryConfirmedDate = lastSalaryConfirmedDateStr != null
        ? DateTime.tryParse(lastSalaryConfirmedDateStr)
        : null;

    // Önce yeni format'ı kontrol et
    final incomeSourcesJson = prefs.getString(_keyIncomeSources);
    if (incomeSourcesJson != null && incomeSourcesJson.isNotEmpty) {
      try {
        final incomeSources = IncomeSource.decodeList(incomeSourcesJson);
        return UserProfile(
          incomeSources: incomeSources,
          dailyHours: hours,
          workDaysPerWeek: days,
          monthlyBudget: monthlyBudget,
          monthlySavingsGoal: savingsGoal,
          salaryDay: salaryDay,
          currentBalance: currentBalance,
          lastSalaryConfirmedDate: lastSalaryConfirmedDate,
        );
      } catch (e) {
        // Decode hatası - eski formattan devam et
      }
    }

    // Eski format'tan migration
    final legacyIncome = prefs.getDouble(_keyMonthlyIncome);
    if (legacyIncome != null && legacyIncome > 0) {
      // Eski format'ı yeni format'a dönüştür
      final salarySource = IncomeSource.salary(
        amount: legacyIncome,
        title: 'Main Salary',
      );
      final profile = UserProfile(
        incomeSources: [salarySource],
        dailyHours: hours,
        workDaysPerWeek: days,
        monthlyBudget: monthlyBudget,
        monthlySavingsGoal: savingsGoal,
        salaryDay: salaryDay,
        currentBalance: currentBalance,
        lastSalaryConfirmedDate: lastSalaryConfirmedDate,
      );

      // Yeni format'ta kaydet
      await saveProfile(profile);
      return profile;
    }

    // Hiç gelir verisi yoksa boş profil döndür
    return UserProfile(
      incomeSources: [],
      dailyHours: hours,
      workDaysPerWeek: days,
      monthlyBudget: monthlyBudget,
      monthlySavingsGoal: savingsGoal,
      salaryDay: salaryDay,
      currentBalance: currentBalance,
      lastSalaryConfirmedDate: lastSalaryConfirmedDate,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();

    // Income sources'ı JSON olarak kaydet
    if (profile.incomeSources.isNotEmpty) {
      await prefs.setString(
        _keyIncomeSources,
        IncomeSource.encodeList(profile.incomeSources),
      );
    }

    // Legacy field'ı da güncelle (geriye uyumluluk)
    await prefs.setDouble(_keyMonthlyIncome, profile.monthlyIncome);
    await prefs.setDouble(_keyDailyHours, profile.dailyHours);
    await prefs.setInt(_keyWorkDaysPerWeek, profile.workDaysPerWeek);

    // Bütçe ayarları
    if (profile.monthlyBudget != null) {
      await prefs.setDouble(_keyMonthlyBudget, profile.monthlyBudget!);
    } else {
      await prefs.remove(_keyMonthlyBudget);
    }

    if (profile.monthlySavingsGoal != null) {
      await prefs.setDouble(_keySavingsGoal, profile.monthlySavingsGoal!);
    } else {
      await prefs.remove(_keySavingsGoal);
    }

    // Salary & Balance Management
    if (profile.salaryDay != null) {
      await prefs.setInt(_keySalaryDay, profile.salaryDay!);
    } else {
      await prefs.remove(_keySalaryDay);
    }

    if (profile.currentBalance != null) {
      await prefs.setDouble(_keyCurrentBalance, profile.currentBalance!);
    } else {
      await prefs.remove(_keyCurrentBalance);
    }

    if (profile.lastSalaryConfirmedDate != null) {
      await prefs.setString(
        _keyLastSalaryConfirmedDate,
        profile.lastSalaryConfirmedDate!.toIso8601String(),
      );
    } else {
      await prefs.remove(_keyLastSalaryConfirmedDate);
    }
  }

  /// Gelir kaynağı ekle
  Future<UserProfile?> addIncomeSource(IncomeSource source) async {
    final profile = await getProfile();
    if (profile == null) return null;

    final updatedProfile = profile.addIncomeSource(source);
    await saveProfile(updatedProfile);
    return updatedProfile;
  }

  /// Gelir kaynağı güncelle
  Future<UserProfile?> updateIncomeSource(
    String id,
    IncomeSource source,
  ) async {
    final profile = await getProfile();
    if (profile == null) return null;

    final updatedProfile = profile.updateIncomeSource(id, source);
    await saveProfile(updatedProfile);
    return updatedProfile;
  }

  /// Gelir kaynağı sil
  Future<UserProfile?> removeIncomeSource(String id) async {
    final profile = await getProfile();
    if (profile == null) return null;

    final updatedProfile = profile.removeIncomeSource(id);
    await saveProfile(updatedProfile);
    return updatedProfile;
  }

  /// Tüm gelir kaynaklarını getir
  Future<List<IncomeSource>> getIncomeSources() async {
    final profile = await getProfile();
    return profile?.incomeSources ?? [];
  }

  Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyDailyHours) &&
        prefs.containsKey(_keyWorkDaysPerWeek);
  }

  /// TÜM uygulama verilerini sıfırla
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Profil fotoğrafını kaydeder
  Future<String?> saveProfilePhoto(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${directory.path}/$fileName';

      // Eski fotoğrafı sil
      final oldPath = await getProfilePhotoPath();
      if (oldPath != null) {
        final oldFile = File(oldPath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      // Yeni fotoğrafı kopyala
      await imageFile.copy(savedPath);

      // Path'i kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyProfilePhotoPath, savedPath);
      return savedPath;
    } catch (e) {
      return null;
    }
  }

  /// Profil fotoğrafı path'ini getirir
  Future<String?> getProfilePhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_keyProfilePhotoPath);

    // Dosyanın hala var olup olmadığını kontrol et
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        return path;
      }
      // Dosya yoksa path'i temizle
      await prefs.remove(_keyProfilePhotoPath);
    }
    return null;
  }

  /// Profil fotoğrafını siler
  Future<void> deleteProfilePhoto() async {
    try {
      final path = await getProfilePhotoPath();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyProfilePhotoPath);
    } catch (e) {
      // Silme hatası sessizce geçilir
    }
  }

  /// Onboarding tamamlandı mı kontrol eder
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_keyOnboardingCompleted) ?? false;
      debugPrint('[ProfileService] isOnboardingCompleted: $completed');
      return completed;
    } catch (e) {
      debugPrint('[ProfileService] isOnboardingCompleted error: $e');
      return false;
    }
  }

  /// Onboarding'i tamamlandı olarak işaretler
  Future<bool> setOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setBool(_keyOnboardingCompleted, true);
      debugPrint('[ProfileService] setOnboardingCompleted: $success');

      if (!success) {
        // Retry once if first attempt fails
        debugPrint('[ProfileService] setOnboardingCompleted: retrying...');
        final retrySuccess = await prefs.setBool(_keyOnboardingCompleted, true);
        debugPrint(
          '[ProfileService] setOnboardingCompleted retry: $retrySuccess',
        );
        return retrySuccess;
      }

      return success;
    } catch (e) {
      debugPrint('[ProfileService] setOnboardingCompleted error: $e');
      return false;
    }
  }

  // ============================================
  // SALARY DAY & BALANCE MANAGEMENT
  // ============================================

  /// Maaş gününü güncelle
  Future<UserProfile?> updateSalaryDay(int? day) async {
    final profile = await getProfile();
    if (profile == null) return null;

    final updatedProfile = profile.copyWith(salaryDay: day);
    await saveProfile(updatedProfile);
    return updatedProfile;
  }

  /// Güncel bakiyeyi güncelle
  Future<UserProfile?> updateCurrentBalance(double? balance) async {
    final profile = await getProfile();
    if (profile == null) return null;

    final updatedProfile = profile.copyWith(currentBalance: balance);
    await saveProfile(updatedProfile);
    return updatedProfile;
  }

  /// Maaş onayını kaydet
  Future<UserProfile?> confirmSalaryReceived({double? newBalance}) async {
    final profile = await getProfile();
    if (profile == null) return null;

    final updatedProfile = profile.copyWith(
      lastSalaryConfirmedDate: DateTime.now(),
      currentBalance: newBalance ?? profile.currentBalance,
    );
    await saveProfile(updatedProfile);
    return updatedProfile;
  }

  /// Bakiyeden harcama düş
  Future<UserProfile?> deductFromBalance(double amount) async {
    final profile = await getProfile();
    if (profile == null) return null;

    final currentBalance = profile.currentBalance ?? 0;
    final newBalance = currentBalance - amount;

    final updatedProfile = profile.copyWith(currentBalance: newBalance);
    await saveProfile(updatedProfile);
    return updatedProfile;
  }

  /// Bakiyeye gelir ekle
  Future<UserProfile?> addToBalance(double amount) async {
    final profile = await getProfile();
    if (profile == null) return null;

    final currentBalance = profile.currentBalance ?? 0;
    final newBalance = currentBalance + amount;

    final updatedProfile = profile.copyWith(currentBalance: newBalance);
    await saveProfile(updatedProfile);
    return updatedProfile;
  }

  // ============================================
  // ONE-TIME INCOME MANAGEMENT
  // ============================================

  /// Tek seferlik gelirleri getir
  Future<List<Income>> getIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyIncomes);
    if (json == null || json.isEmpty) return [];

    try {
      return Income.decodeList(json);
    } catch (e) {
      return [];
    }
  }

  /// Tek seferlik gelir ekle
  Future<void> addIncome(Income income) async {
    final incomes = await getIncomes();
    incomes.insert(0, income); // En yenisi başta

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIncomes, Income.encodeList(incomes));
  }

  /// Bu ayki gelirleri getir
  Future<List<Income>> getCurrentMonthIncomes() async {
    final incomes = await getIncomes();
    final now = DateTime.now();
    return incomes
        .where((i) => i.date.year == now.year && i.date.month == now.month)
        .toList();
  }

  /// Bu ayki toplam geliri hesapla
  Future<double> getCurrentMonthTotalIncome() async {
    final incomes = await getCurrentMonthIncomes();
    return incomes.fold<double>(0.0, (sum, i) => sum + i.amount);
  }
}
