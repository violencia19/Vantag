import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import 'services.dart';

/// Premium Excel Export Service
/// 6 sheet'li detaylı profesyonel finansal rapor oluşturur
class ExportService {
  // Styling constants
  static const _headerColor = '#8B5CF6'; // Mor
  static const _headerTextColor = '#FFFFFF';
  static const _positiveColor = '#10B981'; // Yeşil
  static const _negativeColor = '#EF4444'; // Kırmızı
  static const _warningColor = '#F59E0B'; // Sarı
  static const _alternateRowColor = '#F8FAFC';
  static const _titleColor = '#6366F1'; // Indigo

  /// Excel dosyası oluştur ve paylaş
  Future<File?> exportToExcel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    try {
      // Verileri topla
      final profileService = ProfileService();
      final expenseService = ExpenseHistoryService();
      final calculationService = CalculationService();

      final profile = await profileService.getProfile();
      final expenses = await expenseService.getExpenses();

      if (profile == null) {
        throw Exception('Profile not found');
      }

      // Calculate hourly rate
      final now = DateTime.now();
      final workDays = calculationService.workDaysInMonth(
        now.year,
        now.month,
        profile.workDaysPerWeek,
      );
      final totalWorkHoursPerMonth = workDays * profile.dailyHours;
      final hourlyRate = totalWorkHoursPerMonth > 0
          ? profile.monthlyIncome / totalWorkHoursPerMonth
          : profile.monthlyIncome / 160;

      // Sadece gerçek harcamalar (simülasyonları hariç tut)
      final realExpenses = expenses.where((e) => !e.isSimulation).toList();

      // Excel oluştur
      final excel = Excel.createExcel();

      // 6 Sheet oluştur
      _createExpensesSheet(excel, l10n, realExpenses, hourlyRate);
      _createSummarySheet(excel, l10n, profile, realExpenses, hourlyRate);
      _createCategoriesSheet(excel, l10n, realExpenses, hourlyRate);
      _createTimeAnalysisSheet(excel, l10n, realExpenses);
      _createDecisionsSheet(excel, l10n, realExpenses, hourlyRate);
      _createInstallmentsSheet(excel, l10n, realExpenses, hourlyRate);

      // Varsayılan Sheet1'i sil
      excel.delete('Sheet1');

      // Dosyayı kaydet
      final bytes = excel.save();
      if (bytes == null) throw Exception('Failed to generate Excel');

      final tempDir = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final fileName = 'Vantag_Rapor_$dateStr.xlsx';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      debugPrint('[ExportService] Error: $e');
      rethrow;
    }
  }

  /// Dosyayı paylaş
  Future<void> shareFile(File file) async {
    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'Vantag Finansal Rapor');
  }

  /// Alias for backwards compatibility
  Future<void> shareExcel(File file) => shareFile(file);

  /// Platform channel for saving to Downloads
  static const _fileSaverChannel = MethodChannel('com.vantag.app/file_saver');

  /// Downloads klasörüne kaydet (MediaStore API ile Android 10+ uyumlu)
  Future<({File? file, String? path, String? error})> saveToDownloads(File sourceFile) async {
    debugPrint('[ExportService] ═══════════════════════════════════════');
    debugPrint('[ExportService] Starting saveToDownloads with MediaStore...');
    debugPrint('[ExportService] Source file: ${sourceFile.path}');

    try {
      // Step 1: Verify source file exists
      final sourceExists = await sourceFile.exists();
      debugPrint('[ExportService] Step 1 - Source file exists: $sourceExists');
      if (!sourceExists) {
        return (file: null, path: null, error: 'Source file does not exist');
      }

      // Step 2: Get source file size
      final sourceSize = await sourceFile.length();
      debugPrint('[ExportService] Step 2 - Source file size: $sourceSize bytes');
      if (sourceSize == 0) {
        return (file: null, path: null, error: 'Source file is empty');
      }

      // Step 3: Extract file name and determine MIME type
      final fileName = sourceFile.path.split('/').last;
      debugPrint('[ExportService] Step 3 - File name: $fileName');

      String mimeType = 'application/octet-stream';
      if (fileName.endsWith('.xlsx')) {
        mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else if (fileName.endsWith('.csv')) {
        mimeType = 'text/csv';
      }

      // Step 4: Save using platform channel (MediaStore API)
      debugPrint('[ExportService] Step 4 - Calling platform channel...');
      final savedPath = await _fileSaverChannel.invokeMethod<String>('saveToDownloads', {
        'sourcePath': sourceFile.path,
        'fileName': fileName,
        'mimeType': mimeType,
        'subFolder': 'Vantag',
      });

      if (savedPath != null) {
        debugPrint('[ExportService] ✅ SUCCESS - Saved to: $savedPath');
        debugPrint('[ExportService] ═══════════════════════════════════════');
        return (file: sourceFile, path: savedPath, error: null);
      } else {
        return (file: null, path: null, error: 'MediaStore save returned null');
      }
    } on PlatformException catch (e) {
      debugPrint('[ExportService] ❌ Platform ERROR: ${e.message}');
      debugPrint('[ExportService] Details: ${e.details}');
      debugPrint('[ExportService] ═══════════════════════════════════════');
      return (file: null, path: null, error: e.message ?? 'Platform error');
    } catch (e, stack) {
      debugPrint('[ExportService] ❌ ERROR: $e');
      debugPrint('[ExportService] Stack: $stack');
      debugPrint('[ExportService] ═══════════════════════════════════════');
      return (file: null, path: null, error: e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 1: EXPENSES (Harcama Listesi)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createExpensesSheet(
    Excel excel,
    AppLocalizations l10n,
    List<Expense> expenses,
    double hourlyRate,
  ) {
    final sheet = excel[l10n.excelSheetExpenses];

    // Header row
    final headers = [
      l10n.csvHeaderDate,           // Tarih
      l10n.excelHeaderDay,          // Gün
      l10n.csvHeaderTime,           // Saat
      l10n.csvHeaderAmount,         // Tutar
      l10n.csvHeaderCurrency,       // Para Birimi
      l10n.csvHeaderCategory,       // Kategori
      l10n.csvHeaderSubcategory,    // Alt Kategori
      l10n.excelHeaderStore,        // Mağaza/Yer
      l10n.csvHeaderProduct,        // Ürün/Açıklama
      l10n.csvHeaderDecision,       // Karar
      l10n.excelHeaderHoursEquiv,   // Saat Karşılığı
      l10n.excelHeaderMinutes,      // Dakika Karşılığı
      l10n.excelHeaderInstallmentCount, // Taksit
      l10n.excelHeaderMonthlyInstallment, // Aylık Taksit
      l10n.csvHeaderMandatory,      // Zorunlu
      l10n.excelHeaderSimulation,   // Simülasyon
    ];

    for (var i = 0; i < headers.length; i++) {
      _setCell(
        sheet,
        '${_columnLetter(i)}1',
        headers[i],
        isBold: true,
        bgColor: _headerColor,
        textColor: _headerTextColor,
      );
    }

    // Sort expenses by date (newest first)
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Data rows
    for (var i = 0; i < sortedExpenses.length; i++) {
      final expense = sortedExpenses[i];
      final row = i + 2;
      final isAlternate = i % 2 == 1;

      // Tarih
      _setCell(sheet, 'A$row', DateFormat('dd/MM/yyyy').format(expense.date),
          bgColor: isAlternate ? _alternateRowColor : null);

      // Gün (lokalize)
      _setCell(sheet, 'B$row', _getLocalizedDayName(l10n, expense.date.weekday),
          bgColor: isAlternate ? _alternateRowColor : null);

      // Saat
      _setCell(sheet, 'C$row', DateFormat('HH:mm').format(expense.date),
          bgColor: isAlternate ? _alternateRowColor : null);

      // Tutar
      _setCell(sheet, 'D$row', _formatCurrency(expense.amount),
          bgColor: isAlternate ? _alternateRowColor : null);

      // Para Birimi
      _setCell(sheet, 'E$row', expense.originalCurrency ?? 'TRY',
          bgColor: isAlternate ? _alternateRowColor : null);

      // Kategori (lokalize)
      _setCell(sheet, 'F$row', ExpenseCategory.getLocalizedName(expense.category, l10n),
          bgColor: isAlternate ? _alternateRowColor : null);

      // Alt Kategori
      _setCell(sheet, 'G$row', expense.subCategory ?? '-',
          bgColor: isAlternate ? _alternateRowColor : null);

      // Mağaza/Yer - subCategory'den çıkar veya boş bırak
      _setCell(sheet, 'H$row', expense.subCategory ?? '-',
          bgColor: isAlternate ? _alternateRowColor : null);

      // Ürün/Açıklama
      _setCell(sheet, 'I$row', expense.subCategory ?? expense.category,
          bgColor: isAlternate ? _alternateRowColor : null);

      // Karar (renkli)
      String? decisionBgColor;
      String decisionText = '-';
      if (expense.decision == ExpenseDecision.yes) {
        decisionBgColor = _positiveColor;
        decisionText = l10n.excelDecisionsBought;
      } else if (expense.decision == ExpenseDecision.thinking) {
        decisionBgColor = _warningColor;
        decisionText = l10n.excelDecisionsThinking;
      } else if (expense.decision == ExpenseDecision.no) {
        decisionBgColor = _negativeColor;
        decisionText = l10n.excelDecisionsPassed;
      }
      _setCell(sheet, 'J$row', decisionText,
          bgColor: decisionBgColor,
          textColor: decisionBgColor != null ? '#FFFFFF' : null);

      // Saat Karşılığı
      _setCell(sheet, 'K$row', '${expense.hoursRequired.toStringAsFixed(1)} h',
          bgColor: isAlternate ? _alternateRowColor : null);

      // Dakika Karşılığı
      final minutes = (expense.hoursRequired * 60).round();
      _setCell(sheet, 'L$row', '$minutes dk',
          bgColor: isAlternate ? _alternateRowColor : null);

      // Taksit
      final installmentText = expense.installmentCount != null
          ? '${expense.currentInstallment ?? 1}/${expense.installmentCount}'
          : '-';
      _setCell(sheet, 'M$row', installmentText,
          bgColor: isAlternate ? _alternateRowColor : null);

      // Aylık Taksit
      final monthlyPayment = expense.installmentCount != null && expense.installmentCount! > 0
          ? expense.amount / expense.installmentCount!
          : 0.0;
      _setCell(sheet, 'N$row', expense.installmentCount != null ? _formatCurrency(monthlyPayment) : '-',
          bgColor: isAlternate ? _alternateRowColor : null);

      // Zorunlu
      _setCell(sheet, 'O$row', expense.isMandatory ? l10n.excelYes : l10n.excelNo,
          bgColor: isAlternate ? _alternateRowColor : null);

      // Simülasyon
      _setCell(sheet, 'P$row', expense.isSimulation ? l10n.excelSimulation : l10n.excelReal,
          bgColor: isAlternate ? _alternateRowColor : null);
    }

    // Column widths
    sheet.setColumnWidth(0, 12);  // Tarih
    sheet.setColumnWidth(1, 12);  // Gün
    sheet.setColumnWidth(2, 8);   // Saat
    sheet.setColumnWidth(3, 15);  // Tutar
    sheet.setColumnWidth(4, 10);  // Para Birimi
    sheet.setColumnWidth(5, 14);  // Kategori
    sheet.setColumnWidth(6, 18);  // Alt Kategori
    sheet.setColumnWidth(7, 18);  // Mağaza
    sheet.setColumnWidth(8, 20);  // Ürün
    sheet.setColumnWidth(9, 14);  // Karar
    sheet.setColumnWidth(10, 12); // Saat
    sheet.setColumnWidth(11, 12); // Dakika
    sheet.setColumnWidth(12, 10); // Taksit
    sheet.setColumnWidth(13, 14); // Aylık Taksit
    sheet.setColumnWidth(14, 10); // Zorunlu
    sheet.setColumnWidth(15, 12); // Simülasyon
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 2: SUMMARY (Özet)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createSummarySheet(
    Excel excel,
    AppLocalizations l10n,
    UserProfile profile,
    List<Expense> expenses,
    double hourlyRate,
  ) {
    final sheet = excel[l10n.excelSheetSummary];

    // Title
    _setMergedCell(sheet, 'A1', 'VANTAG', 4);
    _setCell(sheet, 'A3', l10n.excelReportTitle, isBold: true, fontSize: 16);
    _setCell(sheet, 'A4', '${l10n.excelReportGeneratedAt}: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}');

    // Calculate period
    DateTime? firstDate;
    DateTime? lastDate;
    if (expenses.isNotEmpty) {
      firstDate = expenses.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
      lastDate = expenses.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);
    }

    if (firstDate != null && lastDate != null) {
      final periodStart = DateFormat('dd.MM.yyyy').format(firstDate);
      final periodEnd = DateFormat('dd.MM.yyyy').format(lastDate);
      _setCell(sheet, 'A5', '${l10n.excelReportPeriod}: $periodStart - $periodEnd');
    }

    // Calculations
    final yesExpenses = expenses.where((e) => e.decision == ExpenseDecision.yes).toList();
    final noExpenses = expenses.where((e) => e.decision == ExpenseDecision.no).toList();

    final totalSpent = yesExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final totalSaved = noExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final totalIncome = profile.monthlyIncome;
    final savingsRate = totalIncome > 0 ? (totalSaved / totalIncome * 100) : 0;
    final totalWorkHours = hourlyRate > 0 ? totalSpent / hourlyRate : 0.0;
    final totalWorkDays = totalWorkHours / profile.dailyHours;

    // Summary cards
    int row = 7;

    _setCell(sheet, 'A$row', l10n.totalIncome, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(totalIncome));
    row++;

    _setCell(sheet, 'A$row', l10n.excelTotalExpenses, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(totalSpent),
        bgColor: _negativeColor, textColor: '#FFFFFF');
    row++;

    _setCell(sheet, 'A$row', l10n.totalSaved, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(totalSaved),
        bgColor: _positiveColor, textColor: '#FFFFFF');
    row++;

    _setCell(sheet, 'A$row', l10n.excelSavingsRate, isBold: true);
    _setCell(sheet, 'B$row', '${savingsRate.toStringAsFixed(1)}%');
    row++;

    row++; // Empty row

    _setCell(sheet, 'A$row', l10n.excelTotalTransactions, isBold: true);
    _setCell(sheet, 'B$row', expenses.length.toString());
    row++;

    if (yesExpenses.isNotEmpty) {
      final avgPerTransaction = totalSpent / yesExpenses.length;
      _setCell(sheet, 'A$row', l10n.excelAvgPerTransaction, isBold: true);
      _setCell(sheet, 'B$row', _formatCurrency(avgPerTransaction));
      row++;
    }

    // Time-based averages
    if (firstDate != null && lastDate != null) {
      final daysDiff = lastDate.difference(firstDate).inDays + 1;

      if (daysDiff > 0) {
        final dailyAvg = totalSpent / daysDiff;
        _setCell(sheet, 'A$row', l10n.excelDailyAverage, isBold: true);
        _setCell(sheet, 'B$row', _formatCurrency(dailyAvg));
        row++;
      }

      if (daysDiff >= 7) {
        final weeklyAvg = totalSpent / (daysDiff / 7);
        _setCell(sheet, 'A$row', l10n.excelWeeklyAverage, isBold: true);
        _setCell(sheet, 'B$row', _formatCurrency(weeklyAvg));
        row++;
      }

      if (daysDiff >= 30) {
        final monthlyAvg = totalSpent / (daysDiff / 30);
        _setCell(sheet, 'A$row', l10n.excelMonthlyAverage, isBold: true);
        _setCell(sheet, 'B$row', _formatCurrency(monthlyAvg));
        row++;
      }
    }

    row++; // Empty row

    _setCell(sheet, 'A$row', l10n.hourlyRate, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(hourlyRate));
    row++;

    _setCell(sheet, 'A$row', l10n.excelTotalWorkHours, isBold: true);
    _setCell(sheet, 'B$row', '${totalWorkHours.toStringAsFixed(1)} ${l10n.hours}');
    row++;

    _setCell(sheet, 'A$row', l10n.excelTotalWorkDays, isBold: true);
    _setCell(sheet, 'B$row', '${totalWorkDays.toStringAsFixed(1)} ${l10n.days}');

    // Column widths
    sheet.setColumnWidth(0, 28);
    sheet.setColumnWidth(1, 22);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 3: CATEGORIES (Kategori Analizi)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createCategoriesSheet(
    Excel excel,
    AppLocalizations l10n,
    List<Expense> expenses,
    double hourlyRate,
  ) {
    final sheet = excel[l10n.excelSheetCategories];

    // Header
    final headers = [
      l10n.excelCategoryRank,
      l10n.category,
      l10n.excelCategoryTotal,
      l10n.excelCategoryCount,
      l10n.excelCategoryAvg,
      l10n.excelCategoryShare,
      l10n.excelCategoryHours,
    ];

    for (var i = 0; i < headers.length; i++) {
      _setCell(
        sheet,
        '${_columnLetter(i)}1',
        headers[i],
        isBold: true,
        bgColor: _headerColor,
        textColor: _headerTextColor,
      );
    }

    // Only "bought" expenses
    final yesExpenses = expenses.where((e) => e.decision == ExpenseDecision.yes).toList();
    final totalSpent = yesExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    // Group by category
    final categoryMap = <String, List<Expense>>{};
    for (final expense in yesExpenses) {
      categoryMap.putIfAbsent(expense.category, () => []).add(expense);
    }

    // Sort by total amount (highest first)
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) {
        final totalA = a.value.fold<double>(0, (sum, e) => sum + e.amount);
        final totalB = b.value.fold<double>(0, (sum, e) => sum + e.amount);
        return totalB.compareTo(totalA);
      });

    // Data rows
    for (var i = 0; i < sortedCategories.length; i++) {
      final entry = sortedCategories[i];
      final category = entry.key;
      final categoryExpenses = entry.value;
      final row = i + 2;
      final isAlternate = i % 2 == 1;
      final isTop = i == 0;

      final catTotal = categoryExpenses.fold<double>(0, (sum, e) => sum + e.amount);
      final catCount = categoryExpenses.length;
      final catAverage = catCount > 0 ? catTotal / catCount : 0.0;
      final catPercentage = totalSpent > 0 ? (catTotal / totalSpent * 100) : 0;
      final catHours = hourlyRate > 0 ? catTotal / hourlyRate : 0.0;

      // Sıra
      _setCell(sheet, 'A$row', '#${i + 1}',
          isBold: isTop,
          bgColor: isTop ? _warningColor : (isAlternate ? _alternateRowColor : null));

      // Kategori
      _setCell(sheet, 'B$row', ExpenseCategory.getLocalizedName(category, l10n),
          isBold: isTop,
          bgColor: isTop ? _warningColor : (isAlternate ? _alternateRowColor : null));

      // Toplam
      _setCell(sheet, 'C$row', _formatCurrency(catTotal),
          bgColor: isAlternate && !isTop ? _alternateRowColor : null);

      // Adet
      _setCell(sheet, 'D$row', catCount.toString(),
          bgColor: isAlternate && !isTop ? _alternateRowColor : null);

      // Ortalama
      _setCell(sheet, 'E$row', _formatCurrency(catAverage),
          bgColor: isAlternate && !isTop ? _alternateRowColor : null);

      // Pay %
      _setCell(sheet, 'F$row', '${catPercentage.toStringAsFixed(1)}%',
          bgColor: isAlternate && !isTop ? _alternateRowColor : null);

      // Çalışma Saati
      _setCell(sheet, 'G$row', '${catHours.toStringAsFixed(1)}h',
          bgColor: isAlternate && !isTop ? _alternateRowColor : null);
    }

    // Total row
    final totalRow = sortedCategories.length + 3;
    _setCell(sheet, 'A$totalRow', l10n.total, isBold: true);
    _setCell(sheet, 'C$totalRow', _formatCurrency(totalSpent), isBold: true);
    _setCell(sheet, 'D$totalRow', yesExpenses.length.toString(), isBold: true);
    _setCell(sheet, 'F$totalRow', '100%', isBold: true);
    _setCell(sheet, 'G$totalRow', '${(hourlyRate > 0 ? totalSpent / hourlyRate : 0).toStringAsFixed(1)}h', isBold: true);

    // Column widths
    sheet.setColumnWidth(0, 8);   // Sıra
    sheet.setColumnWidth(1, 18);  // Kategori
    sheet.setColumnWidth(2, 18);  // Toplam
    sheet.setColumnWidth(3, 12);  // Adet
    sheet.setColumnWidth(4, 16);  // Ortalama
    sheet.setColumnWidth(5, 12);  // Pay %
    sheet.setColumnWidth(6, 14);  // Çalışma Saati
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 4: TIME ANALYSIS (Zaman Analizi)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createTimeAnalysisSheet(
    Excel excel,
    AppLocalizations l10n,
    List<Expense> expenses,
  ) {
    final sheet = excel[l10n.excelSheetTimeAnalysis];

    // Title
    _setCell(sheet, 'A1', l10n.excelTimeTitle, isBold: true, fontSize: 14);

    // Only "bought" expenses
    final yesExpenses = expenses.where((e) => e.decision == ExpenseDecision.yes).toList();

    if (yesExpenses.isEmpty) {
      _setCell(sheet, 'A3', '-');
      return;
    }

    int row = 3;

    // ═══════════════════════════════════════════════════════════════════════
    // BÖLÜM 1: Genel İstatistikler
    // ═══════════════════════════════════════════════════════════════════════

    // By day of week
    final dayTotals = <int, double>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    final dayCounts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    // By hour
    final hourTotals = <int, double>{};
    for (var h = 0; h < 24; h++) {
      hourTotals[h] = 0;
    }

    // By time of day
    double morningTotal = 0, afternoonTotal = 0, eveningTotal = 0, nightTotal = 0;

    for (final expense in yesExpenses) {
      final weekday = expense.date.weekday;
      final hour = expense.date.hour;

      dayTotals[weekday] = (dayTotals[weekday] ?? 0) + expense.amount;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
      hourTotals[hour] = (hourTotals[hour] ?? 0) + expense.amount;

      if (hour >= 6 && hour < 12) {
        morningTotal += expense.amount;
      } else if (hour >= 12 && hour < 18) {
        afternoonTotal += expense.amount;
      } else if (hour >= 18 && hour < 24) {
        eveningTotal += expense.amount;
      } else {
        nightTotal += expense.amount;
      }
    }

    // Most active day
    final mostActiveDay = dayTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
    _setCell(sheet, 'A$row', l10n.excelMostActiveDay, isBold: true);
    _setCell(sheet, 'B$row', _getLocalizedDayName(l10n, mostActiveDay.key));
    _setCell(sheet, 'C$row', _formatCurrency(mostActiveDay.value));
    row++;

    // Most active hour
    final mostActiveHour = hourTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
    _setCell(sheet, 'A$row', l10n.excelMostActiveHour, isBold: true);
    _setCell(sheet, 'B$row', '${mostActiveHour.key.toString().padLeft(2, '0')}:00');
    _setCell(sheet, 'C$row', _formatCurrency(mostActiveHour.value));
    row++;

    // Weekday vs Weekend average
    final weekdayTotal = dayTotals[1]! + dayTotals[2]! + dayTotals[3]! + dayTotals[4]! + dayTotals[5]!;
    final weekendTotal = dayTotals[6]! + dayTotals[7]!;
    final weekdayCount = dayCounts[1]! + dayCounts[2]! + dayCounts[3]! + dayCounts[4]! + dayCounts[5]!;
    final weekendCount = dayCounts[6]! + dayCounts[7]!;

    row++;
    _setCell(sheet, 'A$row', l10n.excelWeekdayAvg, isBold: true);
    _setCell(sheet, 'B$row', weekdayCount > 0 ? _formatCurrency(weekdayTotal / weekdayCount) : '-');
    row++;

    _setCell(sheet, 'A$row', l10n.excelWeekendAvg, isBold: true);
    _setCell(sheet, 'B$row', weekendCount > 0 ? _formatCurrency(weekendTotal / weekendCount) : '-');
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // BÖLÜM 2: Günün Saatlerine Göre
    // ═══════════════════════════════════════════════════════════════════════
    row += 2;
    _setCell(sheet, 'A$row', l10n.excelByHour, isBold: true, fontSize: 12);
    row++;

    _setCell(sheet, 'A$row', l10n.excelMorningSpend, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(morningTotal));
    row++;

    _setCell(sheet, 'A$row', l10n.excelAfternoonSpend, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(afternoonTotal));
    row++;

    _setCell(sheet, 'A$row', l10n.excelEveningSpend, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(eveningTotal));
    row++;

    _setCell(sheet, 'A$row', l10n.excelNightSpend, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(nightTotal));
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // BÖLÜM 3: Haftanın Günlerine Göre
    // ═══════════════════════════════════════════════════════════════════════
    row += 2;
    _setCell(sheet, 'A$row', l10n.excelByDayOfWeek, isBold: true, fontSize: 12);
    row++;

    final dayNames = [
      l10n.excelDayMonday,
      l10n.excelDayTuesday,
      l10n.excelDayWednesday,
      l10n.excelDayThursday,
      l10n.excelDayFriday,
      l10n.excelDaySaturday,
      l10n.excelDaySunday,
    ];

    for (var i = 1; i <= 7; i++) {
      final isAlternate = i % 2 == 0;
      _setCell(sheet, 'A$row', dayNames[i - 1],
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'B$row', _formatCurrency(dayTotals[i] ?? 0),
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'C$row', '${dayCounts[i] ?? 0} ${l10n.excelDecisionCount.toLowerCase()}',
          bgColor: isAlternate ? _alternateRowColor : null);
      row++;
    }

    // Column widths
    sheet.setColumnWidth(0, 24);
    sheet.setColumnWidth(1, 18);
    sheet.setColumnWidth(2, 14);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 5: DECISIONS (Kararlar Analizi)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createDecisionsSheet(
    Excel excel,
    AppLocalizations l10n,
    List<Expense> expenses,
    double hourlyRate,
  ) {
    final sheet = excel[l10n.excelSheetDecisions];

    // Header
    final headers = [
      l10n.csvHeaderDecision,
      l10n.excelDecisionCount,
      l10n.excelDecisionAmount,
      l10n.excelDecisionPercent,
      l10n.excelDecisionAvg,
      l10n.excelDecisionHours,
    ];

    for (var i = 0; i < headers.length; i++) {
      _setCell(
        sheet,
        '${_columnLetter(i)}1',
        headers[i],
        isBold: true,
        bgColor: _headerColor,
        textColor: _headerTextColor,
      );
    }

    // Calculate stats
    final yesExpenses = expenses.where((e) => e.decision == ExpenseDecision.yes).toList();
    final thinkingExpenses = expenses.where((e) => e.decision == ExpenseDecision.thinking).toList();
    final noExpenses = expenses.where((e) => e.decision == ExpenseDecision.no).toList();

    final yesTotal = yesExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final thinkingTotal = thinkingExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final noTotal = noExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final grandTotal = yesTotal + thinkingTotal + noTotal;

    // Row 2: Bought
    _setCell(sheet, 'A2', l10n.excelDecisionsBought, isBold: true, bgColor: _positiveColor, textColor: '#FFFFFF');
    _setCell(sheet, 'B2', yesExpenses.length.toString());
    _setCell(sheet, 'C2', _formatCurrency(yesTotal));
    _setCell(sheet, 'D2', '${grandTotal > 0 ? (yesTotal / grandTotal * 100).toStringAsFixed(1) : 0}%');
    _setCell(sheet, 'E2', yesExpenses.isNotEmpty ? _formatCurrency(yesTotal / yesExpenses.length) : '-');
    _setCell(sheet, 'F2', '${(hourlyRate > 0 ? yesTotal / hourlyRate : 0).toStringAsFixed(1)}h');

    // Row 3: Thinking
    _setCell(sheet, 'A3', l10n.excelDecisionsThinking, isBold: true, bgColor: _warningColor, textColor: '#FFFFFF');
    _setCell(sheet, 'B3', thinkingExpenses.length.toString());
    _setCell(sheet, 'C3', _formatCurrency(thinkingTotal));
    _setCell(sheet, 'D3', '${grandTotal > 0 ? (thinkingTotal / grandTotal * 100).toStringAsFixed(1) : 0}%');
    _setCell(sheet, 'E3', thinkingExpenses.isNotEmpty ? _formatCurrency(thinkingTotal / thinkingExpenses.length) : '-');
    _setCell(sheet, 'F3', '${(hourlyRate > 0 ? thinkingTotal / hourlyRate : 0).toStringAsFixed(1)}h');

    // Row 4: Passed
    _setCell(sheet, 'A4', l10n.excelDecisionsPassed, isBold: true, bgColor: _negativeColor, textColor: '#FFFFFF');
    _setCell(sheet, 'B4', noExpenses.length.toString());
    _setCell(sheet, 'C4', _formatCurrency(noTotal));
    _setCell(sheet, 'D4', '${grandTotal > 0 ? (noTotal / grandTotal * 100).toStringAsFixed(1) : 0}%');
    _setCell(sheet, 'E4', noExpenses.isNotEmpty ? _formatCurrency(noTotal / noExpenses.length) : '-');
    _setCell(sheet, 'F4', '${(hourlyRate > 0 ? noTotal / hourlyRate : 0).toStringAsFixed(1)}h');

    // Total row
    _setCell(sheet, 'A6', l10n.total, isBold: true);
    _setCell(sheet, 'B6', expenses.length.toString(), isBold: true);
    _setCell(sheet, 'C6', _formatCurrency(grandTotal), isBold: true);
    _setCell(sheet, 'D6', '100%', isBold: true);

    // Additional insights
    int row = 8;
    _setCell(sheet, 'A$row', l10n.excelSavingsFromPassed, isBold: true, fontSize: 12);
    row++;
    _setCell(sheet, 'A$row', l10n.totalSaved);
    _setCell(sheet, 'B$row', _formatCurrency(noTotal), bgColor: _positiveColor, textColor: '#FFFFFF');
    row++;

    _setCell(sheet, 'A$row', l10n.excelTotalWorkHours);
    _setCell(sheet, 'B$row', '${(hourlyRate > 0 ? noTotal / hourlyRate : 0).toStringAsFixed(1)} ${l10n.hours}');
    row++;

    row++;
    _setCell(sheet, 'A$row', l10n.excelPotentialSavings, isBold: true, fontSize: 12);
    row++;
    _setCell(sheet, 'A$row', l10n.excelDecisionAmount);
    _setCell(sheet, 'B$row', _formatCurrency(thinkingTotal), bgColor: _warningColor, textColor: '#FFFFFF');

    // Column widths
    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 12);
    sheet.setColumnWidth(2, 18);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 16);
    sheet.setColumnWidth(5, 14);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 6: INSTALLMENTS (Taksitler)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createInstallmentsSheet(
    Excel excel,
    AppLocalizations l10n,
    List<Expense> expenses,
    double hourlyRate,
  ) {
    final sheet = excel[l10n.excelSheetInstallments];

    // Header
    final headers = [
      l10n.excelInstallmentName,
      l10n.csvHeaderCategory,
      l10n.excelInstallmentTotal,
      l10n.excelInstallmentMonthly,
      l10n.excelInstallmentProgress,
      l10n.excelInstallmentRemaining,
      l10n.excelInstallmentStartDate,
      l10n.excelInstallmentInterest,
    ];

    for (var i = 0; i < headers.length; i++) {
      _setCell(
        sheet,
        '${_columnLetter(i)}1',
        headers[i],
        isBold: true,
        bgColor: _headerColor,
        textColor: _headerTextColor,
      );
    }

    // Filter installment expenses
    final installmentExpenses = expenses
        .where((e) => e.installmentCount != null && e.installmentCount! > 1)
        .toList();

    if (installmentExpenses.isEmpty) {
      _setCell(sheet, 'A3', l10n.excelNoInstallments, fontSize: 12);
      sheet.setColumnWidth(0, 30);
      return;
    }

    // Sort by remaining amount (highest first)
    installmentExpenses.sort((a, b) {
      final remainingA = (a.installmentCount! - (a.currentInstallment ?? 1)) * a.installmentAmount;
      final remainingB = (b.installmentCount! - (b.currentInstallment ?? 1)) * b.installmentAmount;
      return remainingB.compareTo(remainingA);
    });

    double totalMonthlyPayments = 0;
    double totalRemaining = 0;

    // Data rows
    for (var i = 0; i < installmentExpenses.length; i++) {
      final expense = installmentExpenses[i];
      final row = i + 2;
      final isAlternate = i % 2 == 1;

      final monthlyPayment = expense.installmentAmount;
      final current = expense.currentInstallment ?? 1;
      final total = expense.installmentCount!;
      final remaining = (total - current) * monthlyPayment;
      final progress = current / total * 100;

      totalMonthlyPayments += monthlyPayment;
      totalRemaining += remaining;

      // Açıklama
      _setCell(sheet, 'A$row', expense.subCategory ?? expense.category,
          bgColor: isAlternate ? _alternateRowColor : null);

      // Kategori
      _setCell(sheet, 'B$row', ExpenseCategory.getLocalizedName(expense.category, l10n),
          bgColor: isAlternate ? _alternateRowColor : null);

      // Toplam Tutar
      _setCell(sheet, 'C$row', _formatCurrency(expense.installmentTotal ?? expense.amount),
          bgColor: isAlternate ? _alternateRowColor : null);

      // Aylık Ödeme
      _setCell(sheet, 'D$row', _formatCurrency(monthlyPayment),
          bgColor: isAlternate ? _alternateRowColor : null);

      // İlerleme
      _setCell(sheet, 'E$row', '$current/$total (${progress.toStringAsFixed(0)}%)',
          bgColor: progress >= 80 ? _positiveColor : (isAlternate ? _alternateRowColor : null),
          textColor: progress >= 80 ? '#FFFFFF' : null);

      // Kalan
      _setCell(sheet, 'F$row', _formatCurrency(remaining),
          bgColor: isAlternate ? _alternateRowColor : null);

      // Başlangıç Tarihi
      _setCell(sheet, 'G$row', DateFormat('dd.MM.yyyy').format(expense.installmentStartDate ?? expense.date),
          bgColor: isAlternate ? _alternateRowColor : null);

      // Vade Farkı
      final interest = expense.interestAmount;
      _setCell(sheet, 'H$row', interest > 0 ? _formatCurrency(interest) : '-',
          bgColor: interest > 0 ? _warningColor : (isAlternate ? _alternateRowColor : null),
          textColor: interest > 0 ? '#FFFFFF' : null);
    }

    // Summary rows
    final summaryRow = installmentExpenses.length + 4;
    _setCell(sheet, 'A$summaryRow', l10n.excelTotalMonthlyPayments, isBold: true);
    _setCell(sheet, 'D$summaryRow', _formatCurrency(totalMonthlyPayments), isBold: true,
        bgColor: _warningColor, textColor: '#FFFFFF');

    final debtRow = summaryRow + 1;
    _setCell(sheet, 'A$debtRow', l10n.excelTotalRemainingDebt, isBold: true);
    _setCell(sheet, 'F$debtRow', _formatCurrency(totalRemaining), isBold: true,
        bgColor: _negativeColor, textColor: '#FFFFFF');

    // Work hours equivalent
    final hoursRow = debtRow + 1;
    _setCell(sheet, 'A$hoursRow', l10n.workHoursEquivalent, isBold: true);
    _setCell(sheet, 'D$hoursRow', '${(hourlyRate > 0 ? totalMonthlyPayments / hourlyRate : 0).toStringAsFixed(1)}h/${l10n.monthly.toLowerCase()}');

    // Column widths
    sheet.setColumnWidth(0, 22);
    sheet.setColumnWidth(1, 14);
    sheet.setColumnWidth(2, 16);
    sheet.setColumnWidth(3, 14);
    sheet.setColumnWidth(4, 16);
    sheet.setColumnWidth(5, 16);
    sheet.setColumnWidth(6, 14);
    sheet.setColumnWidth(7, 14);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  String _getLocalizedDayName(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case 1: return l10n.excelDayMonday;
      case 2: return l10n.excelDayTuesday;
      case 3: return l10n.excelDayWednesday;
      case 4: return l10n.excelDayThursday;
      case 5: return l10n.excelDayFriday;
      case 6: return l10n.excelDaySaturday;
      case 7: return l10n.excelDaySunday;
      default: return '-';
    }
  }

  void _setCell(
    Sheet sheet,
    String cellRef,
    String value, {
    bool isBold = false,
    int fontSize = 11,
    String? bgColor,
    String? textColor,
  }) {
    final cell = sheet.cell(CellIndex.indexByString(cellRef));
    cell.value = TextCellValue(value);

    cell.cellStyle = CellStyle(
      bold: isBold,
      fontSize: fontSize,
      fontColorHex: textColor != null
          ? _hexToExcelColor(textColor)
          : ExcelColor.black,
      backgroundColorHex: bgColor != null
          ? _hexToExcelColor(bgColor)
          : ExcelColor.none,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );
  }

  void _setMergedCell(Sheet sheet, String startCell, String value, int cols) {
    final cell = sheet.cell(CellIndex.indexByString(startCell));
    cell.value = TextCellValue(value);
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 24,
      fontColorHex: _hexToExcelColor(_titleColor),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Merge cells
    final startIndex = CellIndex.indexByString(startCell);
    final endCol = startIndex.columnIndex + cols - 1;
    sheet.merge(
      CellIndex.indexByColumnRow(
        columnIndex: startIndex.columnIndex,
        rowIndex: startIndex.rowIndex,
      ),
      CellIndex.indexByColumnRow(
        columnIndex: endCol,
        rowIndex: startIndex.rowIndex,
      ),
    );
  }

  String _columnLetter(int index) {
    return String.fromCharCode(65 + index); // A, B, C, ...
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0.00', 'tr');
    return '${formatter.format(value)} ₺';
  }

  ExcelColor _hexToExcelColor(String hex) {
    // #RRGGBB formatını AARRGGBB'ye çevir
    final cleanHex = hex.replaceAll('#', '');
    return ExcelColor.fromHexString('FF$cleanHex');
  }
}
