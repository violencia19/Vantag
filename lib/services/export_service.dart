import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import 'services.dart';

/// Premium Excel Export Service
/// 6 sheet'li detaylı finansal rapor oluşturur
class ExportService {
  // Styling constants
  static const _headerColor = '#8B5CF6'; // Mor
  static const _headerTextColor = '#FFFFFF';
  static const _positiveColor = '#10B981'; // Yeşil
  static const _negativeColor = '#EF4444'; // Kırmızı
  static const _warningColor = '#F59E0B'; // Sarı
  static const _alternateRowColor = '#F8FAFC';

  /// Excel dosyası oluştur ve paylaş
  Future<File?> exportToExcel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    try {
      // Verileri topla
      final profileService = ProfileService();
      final expenseService = ExpenseHistoryService();
      final subscriptionService = SubscriptionService();
      final achievementsService = AchievementsService();
      final calculationService = CalculationService();

      final profile = await profileService.getProfile();
      final expenses = await expenseService.getExpenses();
      final subscriptions = await subscriptionService.getSubscriptions();
      final achievements = await achievementsService.getAchievements();

      if (profile == null) {
        throw Exception('Profile not found');
      }

      // Calculate hourly rate inline
      final now = DateTime.now();
      final workDays = calculationService.workDaysInMonth(
        now.year,
        now.month,
        profile.workDaysPerWeek,
      );
      final totalWorkHoursPerMonth = workDays * profile.dailyHours;
      final hourlyRate = totalWorkHoursPerMonth > 0
          ? profile.monthlyIncome / totalWorkHoursPerMonth
          : profile.monthlyIncome / 160; // Fallback: 160 hours/month

      // Excel oluştur
      final excel = Excel.createExcel();

      // Sheet'leri oluştur
      _createOverviewSheet(excel, l10n, profile, expenses, hourlyRate);
      _createTransactionsSheet(excel, l10n, expenses, hourlyRate);
      _createCategoriesSheet(excel, l10n, expenses, hourlyRate);
      _createMonthlyTrendsSheet(excel, l10n, expenses, profile);
      _createSubscriptionsSheet(excel, l10n, subscriptions, hourlyRate);
      _createAchievementsSheet(excel, l10n, achievements);

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
  Future<void> shareExcel(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Vantag Finansal Rapor',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 1: OVERVIEW (Özet)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createOverviewSheet(
    Excel excel,
    AppLocalizations l10n,
    UserProfile profile,
    List<Expense> expenses,
    double hourlyRate,
  ) {
    final sheet = excel['Özet'];

    // Başlık
    _setMergedCell(sheet, 'A1', 'VANTAG', 3);
    _setCell(sheet, 'A3', l10n.financialReport, isBold: true, fontSize: 16);
    _setCell(sheet, 'A4', '${l10n.createdAt}: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}');

    // Hesaplamalar
    final totalIncome = profile.monthlyIncome;
    final totalSpent = expenses
        .where((e) => e.decision == ExpenseDecision.yes)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final totalSaved = totalIncome - totalSpent;
    final savingsRate = totalIncome > 0 ? (totalSaved / totalIncome * 100) : 0;
    final totalWorkHours = hourlyRate > 0 ? totalSpent / hourlyRate : 0.0;

    // Özet kartları
    int row = 6;
    _setCell(sheet, 'A$row', l10n.totalIncome, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(totalIncome));
    row++;

    _setCell(sheet, 'A$row', l10n.totalSpent, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(totalSpent));
    row++;

    _setCell(sheet, 'A$row', l10n.totalSaved, isBold: true);
    _setCell(
      sheet,
      'B$row',
      _formatCurrency(totalSaved),
      bgColor: totalSaved >= 0 ? _positiveColor : _negativeColor,
      textColor: '#FFFFFF',
    );
    row++;

    _setCell(sheet, 'A$row', l10n.savingsRate, isBold: true);
    _setCell(sheet, 'B$row', '${savingsRate.toStringAsFixed(1)}%');
    row++;

    _setCell(sheet, 'A$row', l10n.hourlyRate, isBold: true);
    _setCell(sheet, 'B$row', _formatCurrency(hourlyRate));
    row++;

    _setCell(sheet, 'A$row', l10n.workHoursEquivalent, isBold: true);
    _setCell(sheet, 'B$row', '${totalWorkHours.toStringAsFixed(1)} ${l10n.hours}');

    // Kolon genişlikleri
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 20);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 2: TRANSACTIONS (Harcamalar)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createTransactionsSheet(
    Excel excel,
    AppLocalizations l10n,
    List<Expense> expenses,
    double hourlyRate,
  ) {
    final sheet = excel['Harcamalar'];

    // Header
    final headers = [
      l10n.date,
      l10n.category,
      l10n.description,
      l10n.amount,
      l10n.currency,
      l10n.originalAmount,
      l10n.decision,
      l10n.workHours,
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

    // Tarihe göre sırala (yeniden eskiye)
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Verileri ekle
    double totalAmount = 0;
    for (var i = 0; i < sortedExpenses.length; i++) {
      final expense = sortedExpenses[i];
      final row = i + 2;
      final isAlternate = i % 2 == 1;

      _setCell(sheet, 'A$row', DateFormat('dd.MM.yyyy').format(expense.date),
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'B$row', expense.category,
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'C$row', expense.subCategory ?? '-',
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'D$row', _formatCurrency(expense.amount),
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'E$row', expense.originalCurrency ?? 'TRY',
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(
          sheet,
          'F$row',
          expense.originalAmount != null
              ? _formatNumber(expense.originalAmount!)
              : '-',
          bgColor: isAlternate ? _alternateRowColor : null);

      // Karar renklendirmesi
      String? decisionBgColor;
      if (expense.decision == ExpenseDecision.yes) {
        decisionBgColor = _positiveColor;
      } else if (expense.decision == ExpenseDecision.thinking) {
        decisionBgColor = _warningColor;
      } else if (expense.decision == ExpenseDecision.no) {
        decisionBgColor = _negativeColor;
      }
      _setCell(
        sheet,
        'G$row',
        expense.decision?.label ?? '-',
        bgColor: decisionBgColor,
        textColor: decisionBgColor != null ? '#FFFFFF' : null,
      );

      _setCell(sheet, 'H$row', '${expense.hoursRequired.toStringAsFixed(1)}h',
          bgColor: isAlternate ? _alternateRowColor : null);

      if (expense.decision == ExpenseDecision.yes) {
        totalAmount += expense.amount;
      }
    }

    // Toplam satırı
    final totalRow = sortedExpenses.length + 2;
    _setCell(sheet, 'A$totalRow', l10n.total, isBold: true);
    _setCell(sheet, 'D$totalRow', _formatCurrency(totalAmount), isBold: true);
    _setCell(
        sheet, 'H$totalRow', '${(hourlyRate > 0 ? totalAmount / hourlyRate : 0.0).toStringAsFixed(1)}h',
        isBold: true);

    // Kolon genişlikleri
    sheet.setColumnWidth(0, 12); // Tarih
    sheet.setColumnWidth(1, 12); // Kategori
    sheet.setColumnWidth(2, 20); // Açıklama
    sheet.setColumnWidth(3, 15); // Tutar
    sheet.setColumnWidth(4, 10); // Para Birimi
    sheet.setColumnWidth(5, 15); // Orijinal Tutar
    sheet.setColumnWidth(6, 15); // Karar
    sheet.setColumnWidth(7, 12); // Çalışma Saati
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 3: CATEGORIES (Kategoriler)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createCategoriesSheet(
    Excel excel,
    AppLocalizations l10n,
    List<Expense> expenses,
    double hourlyRate,
  ) {
    final sheet = excel['Kategoriler'];

    // Header
    final headers = [
      l10n.category,
      l10n.totalSpent,
      l10n.transactionCount,
      l10n.average,
      l10n.percentage,
      l10n.workHours,
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

    // Sadece "Aldım" kararı verilen harcamalar
    final yesExpenses =
        expenses.where((e) => e.decision == ExpenseDecision.yes).toList();
    final totalSpent =
        yesExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    // Kategori bazlı grupla
    final categoryMap = <String, List<Expense>>{};
    for (final expense in yesExpenses) {
      categoryMap.putIfAbsent(expense.category, () => []).add(expense);
    }

    // Toplam harcamaya göre sırala (yüksekten düşüğe)
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) {
        final totalA = a.value.fold<double>(0, (sum, e) => sum + e.amount);
        final totalB = b.value.fold<double>(0, (sum, e) => sum + e.amount);
        return totalB.compareTo(totalA);
      });

    // Verileri ekle
    for (var i = 0; i < sortedCategories.length; i++) {
      final entry = sortedCategories[i];
      final category = entry.key;
      final categoryExpenses = entry.value;
      final row = i + 2;
      final isAlternate = i % 2 == 1;
      final isHighest = i == 0;

      final catTotal =
          categoryExpenses.fold<double>(0, (sum, e) => sum + e.amount);
      final catCount = categoryExpenses.length;
      final catAverage = catCount > 0 ? catTotal / catCount : 0.0;
      final catPercentage = totalSpent > 0 ? (catTotal / totalSpent * 100) : 0;
      final catHours = hourlyRate > 0 ? catTotal / hourlyRate : 0.0;

      _setCell(sheet, 'A$row', category,
          isBold: isHighest,
          bgColor: isHighest ? _warningColor : (isAlternate ? _alternateRowColor : null));
      _setCell(sheet, 'B$row', _formatCurrency(catTotal),
          bgColor: isAlternate && !isHighest ? _alternateRowColor : null);
      _setCell(sheet, 'C$row', catCount.toString(),
          bgColor: isAlternate && !isHighest ? _alternateRowColor : null);
      _setCell(sheet, 'D$row', _formatCurrency(catAverage),
          bgColor: isAlternate && !isHighest ? _alternateRowColor : null);
      _setCell(sheet, 'E$row', '${catPercentage.toStringAsFixed(1)}%',
          bgColor: isAlternate && !isHighest ? _alternateRowColor : null);
      _setCell(sheet, 'F$row', '${catHours.toStringAsFixed(1)}h',
          bgColor: isAlternate && !isHighest ? _alternateRowColor : null);
    }

    // Kolon genişlikleri
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 18);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 12);
    sheet.setColumnWidth(5, 15);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 4: MONTHLY TRENDS (Aylık Trendler)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createMonthlyTrendsSheet(
    Excel excel,
    AppLocalizations l10n,
    List<Expense> expenses,
    UserProfile profile,
  ) {
    final sheet = excel['Aylık Trendler'];

    // Header
    final headers = [
      l10n.month,
      l10n.totalIncome,
      l10n.totalSpent,
      l10n.totalSaved,
      l10n.changePercent,
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

    // Son 12 ayı hesapla
    final now = DateTime.now();
    final months = <DateTime>[];
    for (var i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      months.add(month);
    }

    double? previousSpent;
    for (var i = 0; i < months.length; i++) {
      final month = months[i];
      final row = i + 2;
      final isAlternate = i % 2 == 1;

      // O aydaki harcamalar
      final monthExpenses = expenses.where((e) =>
          e.date.year == month.year &&
          e.date.month == month.month &&
          e.decision == ExpenseDecision.yes);
      final spent = monthExpenses.fold<double>(0, (sum, e) => sum + e.amount);
      final income = profile.monthlyIncome;
      final saved = income - spent;

      // Değişim yüzdesi
      String changeStr = '-';
      String? changeBgColor;
      if (previousSpent != null && previousSpent > 0) {
        final change = ((spent - previousSpent) / previousSpent) * 100;
        if (change > 0) {
          changeStr = '↑ ${change.toStringAsFixed(1)}%';
          changeBgColor = _negativeColor; // Harcama arttı = kötü
        } else if (change < 0) {
          changeStr = '↓ ${change.abs().toStringAsFixed(1)}%';
          changeBgColor = _positiveColor; // Harcama azaldı = iyi
        } else {
          changeStr = '→ 0%';
        }
      }

      final monthName = DateFormat('MMMM yyyy', 'tr').format(month);
      _setCell(sheet, 'A$row', monthName,
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'B$row', _formatCurrency(income),
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'C$row', _formatCurrency(spent),
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(
        sheet,
        'D$row',
        _formatCurrency(saved),
        bgColor: saved >= 0 ? _positiveColor : _negativeColor,
        textColor: '#FFFFFF',
      );
      _setCell(
        sheet,
        'E$row',
        changeStr,
        bgColor: changeBgColor,
        textColor: changeBgColor != null ? '#FFFFFF' : null,
      );

      previousSpent = spent;
    }

    // Kolon genişlikleri
    sheet.setColumnWidth(0, 18);
    sheet.setColumnWidth(1, 18);
    sheet.setColumnWidth(2, 18);
    sheet.setColumnWidth(3, 18);
    sheet.setColumnWidth(4, 15);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 5: SUBSCRIPTIONS (Abonelikler)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createSubscriptionsSheet(
    Excel excel,
    AppLocalizations l10n,
    List<Subscription> subscriptions,
    double hourlyRate,
  ) {
    final sheet = excel['Abonelikler'];

    // Header
    final headers = [
      l10n.subscription,
      l10n.amount,
      l10n.renewalDay,
      l10n.yearlyAmount,
      l10n.category,
      l10n.nextRenewal,
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

    // Sadece aktif abonelikler
    final activeSubscriptions = subscriptions.where((s) => s.isActive).toList();

    double totalMonthly = 0;
    for (var i = 0; i < activeSubscriptions.length; i++) {
      final sub = activeSubscriptions[i];
      final row = i + 2;
      final isAlternate = i % 2 == 1;
      final isUpcoming = sub.daysUntilRenewal <= 3;

      totalMonthly += sub.amount;
      final yearlyAmount = sub.amount * 12;

      _setCell(sheet, 'A$row', sub.name,
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'B$row', _formatCurrency(sub.amount),
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'C$row', '${sub.renewalDay}',
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'D$row', _formatCurrency(yearlyAmount),
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(sheet, 'E$row', sub.category,
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(
        sheet,
        'F$row',
        DateFormat('dd.MM.yyyy').format(sub.nextRenewalDate),
        bgColor: isUpcoming ? _warningColor : (isAlternate ? _alternateRowColor : null),
      );
    }

    // Toplam satırları
    final totalRow = activeSubscriptions.length + 3;
    _setCell(sheet, 'A$totalRow', '${l10n.monthly} ${l10n.total}', isBold: true);
    _setCell(sheet, 'B$totalRow', _formatCurrency(totalMonthly), isBold: true);

    final yearlyRow = totalRow + 1;
    _setCell(sheet, 'A$yearlyRow', '${l10n.yearly} ${l10n.total}', isBold: true);
    _setCell(sheet, 'B$yearlyRow', _formatCurrency(totalMonthly * 12), isBold: true);

    final hoursRow = yearlyRow + 1;
    _setCell(sheet, 'A$hoursRow', l10n.workHoursEquivalent, isBold: true);
    _setCell(
        sheet, 'B$hoursRow', '${(hourlyRate > 0 ? totalMonthly / hourlyRate : 0.0).toStringAsFixed(1)}h/ay',
        isBold: true);

    // Kolon genişlikleri
    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 12);
    sheet.setColumnWidth(3, 18);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 15);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHEET 6: ACHIEVEMENTS (Başarılar)
  // ═══════════════════════════════════════════════════════════════════════════
  void _createAchievementsSheet(
    Excel excel,
    AppLocalizations l10n,
    List<Achievement> achievements,
  ) {
    final sheet = excel['Başarılar'];

    // Header
    final headers = [
      l10n.badge,
      l10n.status,
      l10n.earnedDate,
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

    for (var i = 0; i < achievements.length; i++) {
      final achievement = achievements[i];
      final row = i + 2;
      final isAlternate = i % 2 == 1;

      _setCell(sheet, 'A$row', achievement.title,
          bgColor: isAlternate ? _alternateRowColor : null);
      _setCell(
        sheet,
        'B$row',
        achievement.isUnlocked ? '✓ ${l10n.unlocked}' : '○ ${l10n.locked}',
        bgColor: achievement.isUnlocked ? _positiveColor : null,
        textColor: achievement.isUnlocked ? '#FFFFFF' : null,
      );
      _setCell(
        sheet,
        'C$row',
        achievement.isUnlocked ? DateFormat('dd.MM.yyyy').format(DateTime.now()) : '-',
        bgColor: isAlternate ? _alternateRowColor : null,
      );
    }

    // İstatistikler
    final statsRow = achievements.length + 4;
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    _setCell(sheet, 'A$statsRow', l10n.totalBadges, isBold: true);
    _setCell(sheet, 'B$statsRow', '$unlockedCount / ${achievements.length}');

    // Kolon genişlikleri
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 15);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

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
      fontColorHex: textColor != null ? _hexToExcelColor(textColor) : ExcelColor.black,
      backgroundColorHex: bgColor != null ? _hexToExcelColor(bgColor) : ExcelColor.none,
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
      fontColorHex: _hexToExcelColor(_headerColor),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Merge cells
    final startIndex = CellIndex.indexByString(startCell);
    final endCol = startIndex.columnIndex + cols - 1;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: startIndex.columnIndex, rowIndex: startIndex.rowIndex),
      CellIndex.indexByColumnRow(columnIndex: endCol, rowIndex: startIndex.rowIndex),
    );
  }

  String _columnLetter(int index) {
    return String.fromCharCode(65 + index); // A, B, C, ...
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0.00', 'tr');
    return '${formatter.format(value)} ₺';
  }

  String _formatNumber(double value) {
    final formatter = NumberFormat('#,##0.00', 'tr');
    return formatter.format(value);
  }

  ExcelColor _hexToExcelColor(String hex) {
    // #RRGGBB formatını AARRGGBB'ye çevir
    final cleanHex = hex.replaceAll('#', '');
    return ExcelColor.fromHexString('FF$cleanHex');
  }
}
