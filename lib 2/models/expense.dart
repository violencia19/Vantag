import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:vantag/theme/app_theme.dart';

enum ExpenseDecision {
  yes,
  thinking,
  no;

  /// Returns the localized label for UI display
  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ExpenseDecision.yes:
        return l10n.bought;
      case ExpenseDecision.thinking:
        return l10n.thinking;
      case ExpenseDecision.no:
        return l10n.passed;
    }
  }

  /// Internal key for data export/serialization (not for UI display)
  String get label {
    switch (this) {
      case ExpenseDecision.yes:
        return 'yes';
      case ExpenseDecision.thinking:
        return 'thinking';
      case ExpenseDecision.no:
        return 'no';
    }
  }
}

enum RecordType {
  real,
  simulation;

  String get label {
    switch (this) {
      case RecordType.real:
        return 'Gerçek';
      case RecordType.simulation:
        return 'Simülasyon';
    }
  }
}

/// Gider tipi: tek seferlik, tekrarlayan veya taksitli
enum ExpenseType {
  single,
  recurring,
  installment;

  String get label {
    switch (this) {
      case ExpenseType.single:
        return 'Tek Seferlik';
      case ExpenseType.recurring:
        return 'Tekrarlayan';
      case ExpenseType.installment:
        return 'Taksitli';
    }
  }
}

/// Wealth Coach: Expense Status - aktif, düşünüyor veya arşivlenmiş
enum ExpenseStatus {
  active,
  thinking,
  archived;

  String get label {
    switch (this) {
      case ExpenseStatus.active:
        return 'Aktif';
      case ExpenseStatus.thinking:
        return 'Karar Aşamasında';
      case ExpenseStatus.archived:
        return 'İrade Zaferi';
    }
  }

  String get displayName => label;
}

/// Wealth Coach: Kategori bazlı eşik değerleri (Smart Choice için varsayılan tutarlar)
class CategoryThresholds {
  static const Map<String, double> defaults = {
    'Yiyecek': 150.0, // Kahve yerine evde demle
    'Ulaşım': 100.0, // Taksi yerine toplu taşıma
    'Giyim': 500.0, // Marka yerine alternatif
    'Elektronik': 2000.0, // Yeni model yerine eski
    'Eğlence': 200.0, // Sinema yerine evde film
    'Sağlık': 100.0, // Vitamin vs
    'Eğitim': 300.0, // Kurs alternatifleri
    'Faturalar': 200.0, // Paket downgrade
    'Abonelik': 100.0, // Abonelik harcaması
    'Diğer': 150.0,
  };

  static double getDefault(String category) {
    return defaults[category] ?? 150.0;
  }
}

/// Wealth Coach: Kategori bazlı düşünme süreleri (saat cinsinden)
class ThinkingDurations {
  static const Map<String, int> hours = {
    'Yiyecek': 24, // 1 gün - hızlı karar
    'Ulaşım': 48, // 2 gün
    'Giyim': 72, // 3 gün
    'Elektronik': 168, // 7 gün - büyük alım
    'Eğlence': 48, // 2 gün
    'Sağlık': 24, // 1 gün - acil olabilir
    'Eğitim': 120, // 5 gün
    'Faturalar': 72, // 3 gün
    'Abonelik': 24, // 1 gün - otomatik kayıt
    'Diğer': 48, // 2 gün
  };

  static int getHours(String category) {
    return hours[category] ?? 48;
  }

  static Duration getDuration(String category) {
    return Duration(hours: getHours(category));
  }
}

class Expense {
  final double amount;
  final String category;
  final String? subCategory; // Opsiyonel alt kategori
  final DateTime date;
  final double hoursRequired;
  final double daysRequired;
  final ExpenseDecision? decision;
  final DateTime? decisionDate;
  final RecordType recordType;

  // Wealth Coach: Yeni alanlar
  final ExpenseStatus status;
  final double? savedFrom; // Smart Choice için alternatif tutar
  final bool isSmartChoice; // Smart Choice toggle kullanıldı mı
  final DateTime? archivedAt; // Arşivlenme tarihi
  final String? archiveReason; // Arşivlenme nedeni

  // Multi-currency: Orijinal para birimi bilgisi
  final double? originalAmount; // Girilen tutar (farklı para biriminde)
  final String? originalCurrency; // Girilen para birimi kodu (USD, EUR, vb.)

  // Gider tipi ve zorunluluk
  final ExpenseType type;
  final bool isMandatory; // Zorunlu gider mi? (kira, fatura, kredi)

  // Taksit bilgileri
  final int? installmentCount; // Toplam taksit sayısı
  final int? currentInstallment; // Şu anki taksit (1, 2, 3...)
  final double? cashPrice; // Peşin fiyat
  final double? installmentTotal; // Taksitli toplam (vade farkı dahil)
  final DateTime? installmentStartDate; // Taksit başlangıç tarihi

  // Otomatik abonelik kaydı
  final bool isAutoRecorded; // Abonelikten otomatik oluşturuldu mu?
  final String? subscriptionId; // Kaynak abonelik ID'si

  const Expense({
    required this.amount,
    required this.category,
    this.subCategory,
    required this.date,
    required this.hoursRequired,
    required this.daysRequired,
    this.decision,
    this.decisionDate,
    this.recordType = RecordType.real,
    // Wealth Coach: Yeni alanlar
    this.status = ExpenseStatus.active,
    this.savedFrom,
    this.isSmartChoice = false,
    this.archivedAt,
    this.archiveReason,
    // Multi-currency
    this.originalAmount,
    this.originalCurrency,
    // Gider tipi ve taksit
    this.type = ExpenseType.single,
    this.isMandatory = false,
    this.installmentCount,
    this.currentInstallment,
    this.cashPrice,
    this.installmentTotal,
    this.installmentStartDate,
    // Otomatik abonelik kaydı
    this.isAutoRecorded = false,
    this.subscriptionId,
  });

  bool get isSimulation => recordType == RecordType.simulation;
  bool get isReal => recordType == RecordType.real;

  // Taksit getter'ları
  /// Aylık taksit tutarı
  double get installmentAmount {
    if (installmentTotal != null &&
        installmentCount != null &&
        installmentCount! > 0) {
      return installmentTotal! / installmentCount!;
    }
    return amount;
  }

  /// Vade farkı tutarı
  double get interestAmount {
    if (installmentTotal != null && cashPrice != null) {
      return installmentTotal! - cashPrice!;
    }
    return 0;
  }

  /// Vade farkı yüzdesi
  double get interestRate {
    if (cashPrice != null && cashPrice! > 0 && interestAmount > 0) {
      return (interestAmount / cashPrice!) * 100;
    }
    return 0;
  }

  /// Kalan taksit sayısı
  int get remainingInstallments {
    if (installmentCount != null && currentInstallment != null) {
      return installmentCount! - currentInstallment!;
    }
    return 0;
  }

  /// Taksit bitti mi?
  bool get isInstallmentCompleted {
    return type == ExpenseType.installment && remainingInstallments <= 0;
  }

  // Wealth Coach: Smart Choice tasarruf tutarı
  double get savedAmount => isSmartChoice && savedFrom != null
      ? (savedFrom! - amount).clamp(0, double.infinity)
      : 0;

  /// Wealth Coach: Thinking items için son kullanma tarihi
  DateTime? get expirationDate {
    if (decision != ExpenseDecision.thinking) return null;
    final duration = ThinkingDurations.getDuration(category);
    return (decisionDate ?? date).add(duration);
  }

  /// Wealth Coach: Thinking item süresi dolmuş mu?
  bool get isExpired {
    final expDate = expirationDate;
    if (expDate == null) return false;
    return DateTime.now().isAfter(expDate);
  }

  /// Wealth Coach: Kalan süre (thinking items için)
  Duration? get remainingTime {
    final expDate = expirationDate;
    if (expDate == null) return null;
    final remaining = expDate.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Simulation thresholds (fixed, salary-independent)
  static const double _realMaxThreshold = 250000; // Below this: always real
  static const double _simulationMinThreshold =
      750000; // Above this: always simulation

  /// Check if amount requires user dialog (middle range: 250k - 750k)
  static bool needsSimulationDialog(double amount) {
    return amount >= _realMaxThreshold && amount <= _simulationMinThreshold;
  }

  /// Otomatik simülasyon tespiti (sabit limitler, maaştan bağımsız)
  /// < 250,000₺ = gerçek harcama
  /// > 750,000₺ = simülasyon
  /// 250,000₺ - 750,000₺ arası = kullanıcıya sor (needsSimulationDialog)
  static RecordType detectRecordType(double amount, double hoursRequired) {
    if (amount < _realMaxThreshold) {
      return RecordType.real;
    }
    if (amount > _simulationMinThreshold) {
      return RecordType.simulation;
    }
    // Middle range: default to real, but caller should use needsSimulationDialog first
    return RecordType.real;
  }

  Expense copyWith({
    double? amount,
    String? category,
    String? subCategory,
    DateTime? date,
    double? hoursRequired,
    double? daysRequired,
    ExpenseDecision? decision,
    DateTime? decisionDate,
    RecordType? recordType,
    // Wealth Coach: Yeni alanlar
    ExpenseStatus? status,
    double? savedFrom,
    bool? isSmartChoice,
    DateTime? archivedAt,
    String? archiveReason,
    // Multi-currency
    double? originalAmount,
    String? originalCurrency,
    // Gider tipi ve taksit
    ExpenseType? type,
    bool? isMandatory,
    int? installmentCount,
    int? currentInstallment,
    double? cashPrice,
    double? installmentTotal,
    DateTime? installmentStartDate,
    // Otomatik abonelik kaydı
    bool? isAutoRecorded,
    String? subscriptionId,
  }) {
    return Expense(
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      date: date ?? this.date,
      hoursRequired: hoursRequired ?? this.hoursRequired,
      daysRequired: daysRequired ?? this.daysRequired,
      decision: decision ?? this.decision,
      decisionDate: decisionDate ?? this.decisionDate,
      recordType: recordType ?? this.recordType,
      // Wealth Coach: Yeni alanlar
      status: status ?? this.status,
      savedFrom: savedFrom ?? this.savedFrom,
      isSmartChoice: isSmartChoice ?? this.isSmartChoice,
      archivedAt: archivedAt ?? this.archivedAt,
      archiveReason: archiveReason ?? this.archiveReason,
      // Multi-currency
      originalAmount: originalAmount ?? this.originalAmount,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      // Gider tipi ve taksit
      type: type ?? this.type,
      isMandatory: isMandatory ?? this.isMandatory,
      installmentCount: installmentCount ?? this.installmentCount,
      currentInstallment: currentInstallment ?? this.currentInstallment,
      cashPrice: cashPrice ?? this.cashPrice,
      installmentTotal: installmentTotal ?? this.installmentTotal,
      installmentStartDate: installmentStartDate ?? this.installmentStartDate,
      // Otomatik abonelik kaydı
      isAutoRecorded: isAutoRecorded ?? this.isAutoRecorded,
      subscriptionId: subscriptionId ?? this.subscriptionId,
    );
  }

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'category': category,
    if (subCategory != null) 'subCategory': subCategory,
    'date': date.toIso8601String(),
    'hoursRequired': hoursRequired,
    'daysRequired': daysRequired,
    'decision': decision?.name,
    'decisionDate': decisionDate?.toIso8601String(),
    'recordType': recordType.name,
    // Wealth Coach: Yeni alanlar
    'status': status.name,
    if (savedFrom != null) 'savedFrom': savedFrom,
    'isSmartChoice': isSmartChoice,
    if (archivedAt != null) 'archivedAt': archivedAt!.toIso8601String(),
    if (archiveReason != null) 'archiveReason': archiveReason,
    // Multi-currency
    if (originalAmount != null) 'originalAmount': originalAmount,
    if (originalCurrency != null) 'originalCurrency': originalCurrency,
    // Gider tipi ve taksit
    'type': type.name,
    'isMandatory': isMandatory,
    if (installmentCount != null) 'installmentCount': installmentCount,
    if (currentInstallment != null) 'currentInstallment': currentInstallment,
    if (cashPrice != null) 'cashPrice': cashPrice,
    if (installmentTotal != null) 'installmentTotal': installmentTotal,
    if (installmentStartDate != null)
      'installmentStartDate': installmentStartDate!.toIso8601String(),
    // Otomatik abonelik kaydı
    'isAutoRecorded': isAutoRecorded,
    if (subscriptionId != null) 'subscriptionId': subscriptionId,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    amount: (json['amount'] as num).toDouble(),
    category: json['category'] as String,
    // Eski kayıtlar için null (backward compatible)
    subCategory: json['subCategory'] as String?,
    date: DateTime.parse(json['date'] as String),
    hoursRequired: (json['hoursRequired'] as num).toDouble(),
    daysRequired: (json['daysRequired'] as num).toDouble(),
    decision: json['decision'] != null
        ? ExpenseDecision.values.byName(json['decision'] as String)
        : null,
    decisionDate: json['decisionDate'] != null
        ? DateTime.parse(json['decisionDate'] as String)
        : null,
    // Eski kayıtlar için varsayılan: real
    recordType: json['recordType'] != null
        ? RecordType.values.byName(json['recordType'] as String)
        : RecordType.real,
    // Wealth Coach: Yeni alanlar (backward compatible)
    status: json['status'] != null
        ? ExpenseStatus.values.byName(json['status'] as String)
        : ExpenseStatus.active,
    savedFrom: json['savedFrom'] != null
        ? (json['savedFrom'] as num).toDouble()
        : null,
    isSmartChoice: json['isSmartChoice'] as bool? ?? false,
    archivedAt: json['archivedAt'] != null
        ? DateTime.parse(json['archivedAt'] as String)
        : null,
    archiveReason: json['archiveReason'] as String?,
    // Multi-currency (backward compatible)
    originalAmount: json['originalAmount'] != null
        ? (json['originalAmount'] as num).toDouble()
        : null,
    originalCurrency: json['originalCurrency'] as String?,
    // Gider tipi ve taksit (backward compatible)
    type: json['type'] != null
        ? ExpenseType.values.firstWhere(
            (e) => e.name == json['type'],
            orElse: () => ExpenseType.single,
          )
        : ExpenseType.single,
    isMandatory: json['isMandatory'] as bool? ?? false,
    installmentCount: json['installmentCount'] as int?,
    currentInstallment: json['currentInstallment'] as int?,
    cashPrice: json['cashPrice'] != null
        ? (json['cashPrice'] as num).toDouble()
        : null,
    installmentTotal: json['installmentTotal'] != null
        ? (json['installmentTotal'] as num).toDouble()
        : null,
    installmentStartDate: json['installmentStartDate'] != null
        ? DateTime.parse(json['installmentStartDate'] as String)
        : null,
    // Otomatik abonelik kaydı (backward compatible)
    isAutoRecorded: json['isAutoRecorded'] as bool? ?? false,
    subscriptionId: json['subscriptionId'] as String?,
  );

  static String encodeList(List<Expense> expenses) =>
      jsonEncode(expenses.map((e) => e.toJson()).toList());

  static List<Expense> decodeList(String json) =>
      (jsonDecode(json) as List).map((e) => Expense.fromJson(e)).toList();
}

class ExpenseCategory {
  static const List<String> all = [
    'Yiyecek',
    'Ulaşım',
    'Giyim',
    'Elektronik',
    'Eğlence',
    'Sağlık',
    'Eğitim',
    'Faturalar',
    'Abonelik',
    'Diğer',
  ];

  /// Kategori ikonu (Cupertino icon)
  static IconData getIcon(String category) {
    switch (category) {
      case 'Yiyecek':
        return CupertinoIcons.cart_fill;
      case 'Ulaşım':
        return CupertinoIcons.car_fill;
      case 'Giyim':
        return CupertinoIcons.tag_fill;
      case 'Elektronik':
        return CupertinoIcons.device_phone_portrait;
      case 'Eğlence':
        return CupertinoIcons.gamecontroller_fill;
      case 'Sağlık':
        return CupertinoIcons.heart_fill;
      case 'Eğitim':
        return CupertinoIcons.book_fill;
      case 'Faturalar':
        return CupertinoIcons.doc_text_fill;
      case 'Abonelik':
        return CupertinoIcons.bell_fill;
      case 'Diğer':
      default:
        return CupertinoIcons.cube_box_fill;
    }
  }

  /// Kategori rengi
  static Color getColor(String category) {
    switch (category) {
      case 'Yiyecek':
        return AppColors.categoryFood;
      case 'Ulaşım':
        return AppColors.categoryTransport;
      case 'Giyim':
        return AppColors.categoryShopping;
      case 'Elektronik':
        return AppColors.categoryEntertainment;
      case 'Eğlence':
        return AppColors.categoryBills;
      case 'Sağlık':
        return AppColors.categoryHealth;
      case 'Eğitim':
        return AppColors.categoryEducation;
      case 'Faturalar':
        return AppColors.categoryOther;
      case 'Abonelik':
        return AppColors.primary;
      case 'Diğer':
      default:
        return AppColors.categoryDefault;
    }
  }

  /// Lokalize kategori ismi (UI gösterimi için)
  static String getLocalizedName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Yiyecek':
        return l10n.categoryFood;
      case 'Ulaşım':
        return l10n.categoryTransport;
      case 'Giyim':
        return l10n.categoryClothing;
      case 'Elektronik':
        return l10n.categoryElectronics;
      case 'Eğlence':
        return l10n.categoryEntertainment;
      case 'Sağlık':
        return l10n.categoryHealth;
      case 'Eğitim':
        return l10n.categoryEducation;
      case 'Faturalar':
        return l10n.categoryBills;
      case 'Abonelik':
        return l10n.categorySubscription;
      case 'Diğer':
      default:
        return l10n.categoryOther;
    }
  }
}

class DecisionStats {
  final int yesCount;
  final double yesTotal;
  final int noCount;
  final double noTotal;
  final int thinkingCount;
  final double thinkingTotal;
  final double savedHours;
  final double savedDays;
  // Wealth Coach: Yeni istatistikler
  final double smartChoiceSaved; // Smart Choice ile tasarruf
  final int smartChoiceCount; // Smart Choice kullanan harcama sayısı

  const DecisionStats({
    this.yesCount = 0,
    this.yesTotal = 0,
    this.noCount = 0,
    this.noTotal = 0,
    this.thinkingCount = 0,
    this.thinkingTotal = 0,
    this.savedHours = 0,
    this.savedDays = 0,
    // Wealth Coach
    this.smartChoiceSaved = 0,
    this.smartChoiceCount = 0,
  });

  factory DecisionStats.fromExpenses(List<Expense> expenses) {
    int yesCount = 0;
    double yesTotal = 0;
    int noCount = 0;
    double noTotal = 0;
    int thinkingCount = 0;
    double thinkingTotal = 0;
    double savedHours = 0;
    double savedDays = 0;
    // Wealth Coach
    double smartChoiceSaved = 0;
    int smartChoiceCount = 0;

    for (final expense in expenses) {
      // Wealth Coach: Smart Choice hesaplamaları
      if (expense.isSmartChoice && expense.savedAmount > 0) {
        smartChoiceCount++;
        smartChoiceSaved += expense.savedAmount;
      }

      switch (expense.decision) {
        case ExpenseDecision.yes:
          yesCount++;
          yesTotal += expense.amount;
          break;
        case ExpenseDecision.no:
          noCount++;
          noTotal += expense.amount;
          savedHours += expense.hoursRequired;
          savedDays += expense.daysRequired;
          break;
        case ExpenseDecision.thinking:
          thinkingCount++;
          thinkingTotal += expense.amount;
          break;
        case null:
          break;
      }
    }

    return DecisionStats(
      yesCount: yesCount,
      yesTotal: yesTotal,
      noCount: noCount,
      noTotal: noTotal,
      thinkingCount: thinkingCount,
      thinkingTotal: thinkingTotal,
      savedHours: savedHours,
      savedDays: savedDays,
      // Wealth Coach
      smartChoiceSaved: smartChoiceSaved,
      smartChoiceCount: smartChoiceCount,
    );
  }

  double get savedAmount => noTotal;
  int get totalDecisions => yesCount + noCount + thinkingCount;

  // Wealth Coach: Toplam tasarruf (vazgeçilen + smart choice)
  double get totalSaved => noTotal + smartChoiceSaved;
}
