import 'package:uuid/uuid.dart';

class BudgetCategory {
  final String id;
  final String name;
  final String description;
  final double monthlyLimit;
  final DateTime createdDate;

  BudgetCategory({
    String? id,
    required this.name,
    required this.description,
    required this.monthlyLimit,
    DateTime? createdDate,
  })  : id = id ?? const Uuid().v4(),
        createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'monthlyLimit': monthlyLimit,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory BudgetCategory.fromMap(Map<String, dynamic> map) {
    return BudgetCategory(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      monthlyLimit: map['monthlyLimit'],
      createdDate: DateTime.parse(map['createdDate']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          monthlyLimit == other.monthlyLimit &&
          createdDate == other.createdDate;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      monthlyLimit.hashCode ^
      createdDate.hashCode;
}
