import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Pursuit categories with emoji representation
enum PursuitCategory {
  tech,      // 📱 Teknoloji
  travel,    // ✈️ Seyahat
  home,      // 🏠 Ev
  fashion,   // 👗 Moda
  vehicle,   // 🚗 Araç
  education, // 📚 Eğitim
  health,    // 💊 Sağlık
  other;     // 📦 Diğer

  String get emoji {
    switch (this) {
      case PursuitCategory.tech:
        return '📱';
      case PursuitCategory.travel:
        return '✈️';
      case PursuitCategory.home:
        return '🏠';
      case PursuitCategory.fashion:
        return '👗';
      case PursuitCategory.vehicle:
        return '🚗';
      case PursuitCategory.education:
        return '📚';
      case PursuitCategory.health:
        return '💊';
      case PursuitCategory.other:
        return '📦';
    }
  }

  String get labelTr {
    switch (this) {
      case PursuitCategory.tech:
        return 'Teknoloji';
      case PursuitCategory.travel:
        return 'Seyahat';
      case PursuitCategory.home:
        return 'Ev';
      case PursuitCategory.fashion:
        return 'Moda';
      case PursuitCategory.vehicle:
        return 'Araç';
      case PursuitCategory.education:
        return 'Eğitim';
      case PursuitCategory.health:
        return 'Sağlık';
      case PursuitCategory.other:
        return 'Diğer';
    }
  }

  String get labelEn {
    switch (this) {
      case PursuitCategory.tech:
        return 'Tech';
      case PursuitCategory.travel:
        return 'Travel';
      case PursuitCategory.home:
        return 'Home';
      case PursuitCategory.fashion:
        return 'Fashion';
      case PursuitCategory.vehicle:
        return 'Vehicle';
      case PursuitCategory.education:
        return 'Education';
      case PursuitCategory.health:
        return 'Health';
      case PursuitCategory.other:
        return 'Other';
    }
  }
}

/// A savings goal (pursuit/dream) that the user is working toward
class Pursuit {
  final String id;
  final String name;
  final double targetAmount;
  final String currency;
  final double savedAmount;
  final String? imageUrl;
  final String emoji;
  final PursuitCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final bool isArchived;
  final int sortOrder;

  const Pursuit({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currency,
    this.savedAmount = 0,
    this.imageUrl,
    required this.emoji,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.isArchived = false,
    this.sortOrder = 0,
  });

  /// Progress percentage (0.0 to 1.0)
  double get progressPercent => targetAmount > 0
      ? (savedAmount / targetAmount).clamp(0.0, 1.0)
      : 0.0;

  /// Progress percentage for display (0 to 100)
  int get progressPercentDisplay => (progressPercent * 100).round();

  /// Check if the pursuit is completed
  bool get isCompleted => completedAt != null;

  /// Remaining amount to reach target
  double get remainingAmount =>
      (targetAmount - savedAmount).clamp(0.0, double.infinity);

  /// Check if target has been reached (for completion detection)
  bool get hasReachedTarget => savedAmount >= targetAmount;

  /// Days since creation
  int get daysSinceCreation =>
      DateTime.now().difference(createdAt).inDays;

  /// Factory to create a new pursuit with UUID
  factory Pursuit.create({
    required String name,
    required double targetAmount,
    required String currency,
    required PursuitCategory category,
    String? imageUrl,
    String? emoji,
    double initialSavings = 0,
  }) {
    final now = DateTime.now();
    return Pursuit(
      id: const Uuid().v4(),
      name: name,
      targetAmount: targetAmount,
      currency: currency,
      savedAmount: initialSavings,
      imageUrl: imageUrl,
      emoji: emoji ?? category.emoji,
      category: category,
      createdAt: now,
      updatedAt: now,
      sortOrder: now.millisecondsSinceEpoch,
    );
  }

  Pursuit copyWith({
    String? id,
    String? name,
    double? targetAmount,
    String? currency,
    double? savedAmount,
    String? imageUrl,
    String? emoji,
    PursuitCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool? isArchived,
    int? sortOrder,
  }) {
    return Pursuit(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currency: currency ?? this.currency,
      savedAmount: savedAmount ?? this.savedAmount,
      imageUrl: imageUrl ?? this.imageUrl,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currency': currency,
    'savedAmount': savedAmount,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'emoji': emoji,
    'category': category.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    'isArchived': isArchived,
    'sortOrder': sortOrder,
  };

  factory Pursuit.fromJson(Map<String, dynamic> json) {
    return Pursuit(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'] as String?,
      emoji: json['emoji'] as String? ?? '📦',
      category: PursuitCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => PursuitCategory.other,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isArchived: json['isArchived'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  static String encodeList(List<Pursuit> pursuits) =>
      jsonEncode(pursuits.map((p) => p.toJson()).toList());

  static List<Pursuit> decodeList(String json) =>
      (jsonDecode(json) as List).map((e) => Pursuit.fromJson(e)).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pursuit &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Pursuit(id: $id, name: $name, progress: $progressPercentDisplay%)';
}
