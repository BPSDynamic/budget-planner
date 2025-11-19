class HistoricalSummary {
  final int year;
  final Map<int, Map<String, double>> monthlyTotals; // month -> {income, expense}
  final Map<String, double> categoryTotals;
  final Map<String, double> yearOverYearGrowth;

  HistoricalSummary({
    required this.year,
    required this.monthlyTotals,
    required this.categoryTotals,
    required this.yearOverYearGrowth,
  });

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'monthlyTotals': monthlyTotals,
      'categoryTotals': categoryTotals,
      'yearOverYearGrowth': yearOverYearGrowth,
    };
  }

  factory HistoricalSummary.fromMap(Map<String, dynamic> map) {
    return HistoricalSummary(
      year: map['year'],
      monthlyTotals: Map<int, Map<String, double>>.from(
        (map['monthlyTotals'] as Map).map(
          (key, value) => MapEntry(
            int.parse(key.toString()),
            Map<String, double>.from(value),
          ),
        ),
      ),
      categoryTotals: Map<String, double>.from(map['categoryTotals'] ?? {}),
      yearOverYearGrowth:
          Map<String, double>.from(map['yearOverYearGrowth'] ?? {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoricalSummary &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          monthlyTotals == other.monthlyTotals &&
          categoryTotals == other.categoryTotals &&
          yearOverYearGrowth == other.yearOverYearGrowth;

  @override
  int get hashCode =>
      year.hashCode ^
      monthlyTotals.hashCode ^
      categoryTotals.hashCode ^
      yearOverYearGrowth.hashCode;
}
