class AggregatedData {
  final String period; // month/year identifier
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> byCategory;
  final Map<String, AggregatedData>? byMonth;

  AggregatedData({
    required this.period,
    required this.totalIncome,
    required this.totalExpense,
    required this.byCategory,
    this.byMonth,
  });

  Map<String, dynamic> toMap() {
    return {
      'period': period,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'byCategory': byCategory,
      'byMonth': byMonth?.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory AggregatedData.fromMap(Map<String, dynamic> map) {
    return AggregatedData(
      period: map['period'],
      totalIncome: map['totalIncome'],
      totalExpense: map['totalExpense'],
      byCategory: Map<String, double>.from(map['byCategory'] ?? {}),
      byMonth: map['byMonth'] != null
          ? (map['byMonth'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, AggregatedData.fromMap(value)))
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AggregatedData &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          totalIncome == other.totalIncome &&
          totalExpense == other.totalExpense &&
          byCategory == other.byCategory &&
          byMonth == other.byMonth;

  @override
  int get hashCode =>
      period.hashCode ^
      totalIncome.hashCode ^
      totalExpense.hashCode ^
      byCategory.hashCode ^
      byMonth.hashCode;
}
