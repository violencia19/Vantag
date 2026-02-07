import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vantag/theme/app_colors.dart';

/// Abonelik renk paleti
class SubscriptionColors {
  static List<Color> get palette => VantColors.subscriptionColors;

  /// Index'e göre renk döndür (mod 8 ile sınırla)
  static Color get(int index) => palette[index % 8];

  /// Renk sayısı
  static int get count => palette.length;
}

class Subscription {
  final String id;
  final String name;
  final double amount;
  final int renewalDay; // 1-31
  final String category;
  final bool isActive;
  final bool autoRecord; // Otomatik harcama kaydı oluştur
  final DateTime createdAt;
  final int colorIndex; // Renk paleti indeksi (0-7)
  final String? notes; // Kullanıcı notları

  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.renewalDay,
    required this.category,
    this.isActive = true,
    this.autoRecord = true, // Varsayılan olarak otomatik kayıt açık
    required this.createdAt,
    this.colorIndex = 0,
    this.notes,
  });

  /// Abonelik rengi
  Color get color => SubscriptionColors.get(colorIndex);

  /// Sonraki yenileme tarihini hesapla
  DateTime get nextRenewalDate {
    final now = DateTime.now();
    final thisMonth = DateTime(
      now.year,
      now.month,
      _clampDay(now.year, now.month),
    );

    if (thisMonth.isAfter(now) || thisMonth.isAtSameMomentAs(now)) {
      return thisMonth;
    } else {
      // Sonraki ay
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      return DateTime(nextYear, nextMonth, _clampDay(nextYear, nextMonth));
    }
  }

  /// Ayın gün sayısına göre günü sınırla (örn: 31 Şubat → 28/29)
  int _clampDay(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return renewalDay > daysInMonth ? daysInMonth : renewalDay;
  }

  /// Belirli bir ay/yıl için yenileme günü (takvim görünümü için)
  int getRenewalDayForMonth(int year, int month) {
    return _clampDay(year, month);
  }

  /// Yenilemeye kaç gün kaldı
  int get daysUntilRenewal {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final renewal = DateTime(
      nextRenewalDate.year,
      nextRenewalDate.month,
      nextRenewalDate.day,
    );
    return renewal.difference(today).inDays;
  }

  /// Yarın mı yenileniyor?
  bool get isRenewalTomorrow => daysUntilRenewal == 1;

  /// Bugün mü yenileniyor?
  bool get isRenewalToday => daysUntilRenewal == 0;

  /// Yenilenmeye kaç saat kaldı
  int get hoursUntilRenewal {
    final now = DateTime.now();
    final renewal = DateTime(
      nextRenewalDate.year,
      nextRenewalDate.month,
      nextRenewalDate.day,
    );
    return renewal.difference(now).inHours.clamp(0, 999);
  }

  /// Kaç gündür abone (createdAt'tan bugüne)
  int get daysSinceSubscription {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Kaç ay abone (yaklaşık)
  int get monthsSubscribed {
    final now = DateTime.now();
    return (now.year - createdAt.year) * 12 + (now.month - createdAt.month);
  }

  /// Toplam ödenen tutar (tahmini)
  double get totalPaid {
    final months = monthsSubscribed;
    return months > 0 ? months * amount : amount;
  }

  Subscription copyWith({
    String? name,
    double? amount,
    int? renewalDay,
    String? category,
    bool? isActive,
    bool? autoRecord,
    int? colorIndex,
    String? notes,
  }) {
    return Subscription(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      renewalDay: renewalDay ?? this.renewalDay,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      autoRecord: autoRecord ?? this.autoRecord,
      createdAt: createdAt,
      colorIndex: colorIndex ?? this.colorIndex,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'renewalDay': renewalDay,
    'category': category,
    'isActive': isActive,
    'autoRecord': autoRecord,
    'createdAt': createdAt.toIso8601String(),
    'colorIndex': colorIndex,
    'notes': notes,
  };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'] as String,
    name: json['name'] as String,
    amount: (json['amount'] as num).toDouble(),
    renewalDay: json['renewalDay'] as int,
    category: json['category'] as String,
    isActive: json['isActive'] as bool? ?? true,
    autoRecord: json['autoRecord'] as bool? ?? true,
    createdAt: DateTime.parse(json['createdAt'] as String),
    colorIndex: json['colorIndex'] as int? ?? 0,
    notes: json['notes'] as String?,
  );

  static String encodeList(List<Subscription> subs) =>
      jsonEncode(subs.map((s) => s.toJson()).toList());

  static List<Subscription> decodeList(String json) =>
      (jsonDecode(json) as List).map((s) => Subscription.fromJson(s)).toList();
}
