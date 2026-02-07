import 'package:uuid/uuid.dart';

/// Represents a monthly budget limit for a specific expense category
class CategoryBudget {
  final String id;
  final String category;
  final double monthlyLimit;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  CategoryBudget({
    String? id,
    required this.category,
    required this.monthlyLimit,
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  CategoryBudget copyWith({
    String? id,
    String? category,
    double? monthlyLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'monthlyLimit': monthlyLimit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      id: json['id'] as String,
      category: json['category'] as String,
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  String toString() =>
      'CategoryBudget(id: $id, category: $category, limit: $monthlyLimit)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryBudget &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Budget with calculated spent amount for a specific month
class CategoryBudgetWithSpent {
  final CategoryBudget budget;
  final double spent;
  final int month;
  final int year;

  CategoryBudgetWithSpent({
    required this.budget,
    required this.spent,
    required this.month,
    required this.year,
  });

  /// Remaining amount (can be negative if over budget)
  double get remaining => budget.monthlyLimit - spent;

  /// Percentage of budget used (0-100+)
  double get percentUsed =>
      budget.monthlyLimit > 0 ? (spent / budget.monthlyLimit * 100) : 0;

  /// Clamped percentage for progress bars (0-100)
  double get percentUsedClamped => percentUsed.clamp(0, 100);

  /// Is over the budget limit?
  bool get isOverBudget => spent > budget.monthlyLimit;

  /// Is near the limit (80%+)?
  bool get isNearLimit => percentUsed >= 80 && !isOverBudget;

  /// Is on track (<80%)?
  bool get isOnTrack => percentUsed < 80;

  /// Warning level: 0=green, 1=yellow, 2=orange, 3=red
  int get warningLevel {
    if (percentUsed < 50) return 0;
    if (percentUsed < 80) return 1;
    if (percentUsed < 100) return 2;
    return 3;
  }

  @override
  String toString() =>
      'CategoryBudgetWithSpent(${budget.category}: $spent / ${budget.monthlyLimit})';
}
