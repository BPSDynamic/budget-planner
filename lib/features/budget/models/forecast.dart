import 'package:uuid/uuid.dart';

class Forecast {
  final String id;
  final String period; // YYYY-MM format
  final String category;
  final double projectedAmount;
  final String assumptions;
  final DateTime createdDate;

  Forecast({
    String? id,
    required this.period,
    required this.category,
    required this.projectedAmount,
    required this.assumptions,
    DateTime? createdDate,
  })  : id = id ?? const Uuid().v4(),
        createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'period': period,
      'category': category,
      'projectedAmount': projectedAmount,
      'assumptions': assumptions,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Forecast.fromMap(Map<String, dynamic> map) {
    return Forecast(
      id: map['id'],
      period: map['period'],
      category: map['category'],
      projectedAmount: map['projectedAmount'],
      assumptions: map['assumptions'],
      createdDate: DateTime.parse(map['createdDate']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Forecast &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          period == other.period &&
          category == other.category &&
          projectedAmount == other.projectedAmount &&
          assumptions == other.assumptions &&
          createdDate == other.createdDate;

  @override
  int get hashCode =>
      id.hashCode ^
      period.hashCode ^
      category.hashCode ^
      projectedAmount.hashCode ^
      assumptions.hashCode ^
      createdDate.hashCode;
}
