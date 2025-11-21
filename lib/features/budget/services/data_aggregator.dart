import 'package:intl/intl.dart';
import 'package:budget_planner/features/transactions/models/transaction_model.dart';
import 'package:budget_planner/features/budget/models/aggregated_data.dart';

class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.ttl,
  }) : createdAt = DateTime.now();

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}

class DataAggregator {
  final Map<String, CacheEntry<AggregatedData>> _cache = {};
  static const Duration defaultTTL = Duration(hours: 1);

  /// Aggregates transactions by month, grouping all transactions into monthly buckets
  /// Returns a map where keys are month identifiers (YYYY-MM) and values are aggregated data
  Map<String, AggregatedData> aggregateByMonth(List<Transaction> transactions) {
    final monthlyData = <String, Map<String, dynamic>>{};

    for (final transaction in transactions) {
      final monthKey = DateFormat('yyyy-MM').format(transaction.date);

      monthlyData.putIfAbsent(monthKey, () => {
        'totalIncome': 0.0,
        'totalExpense': 0.0,
        'byCategory': <String, double>{},
      });

      final data = monthlyData[monthKey]!;

      if (transaction.type == TransactionType.income) {
        data['totalIncome'] = (data['totalIncome'] as double) + transaction.amount;
      } else {
        data['totalExpense'] = (data['totalExpense'] as double) + transaction.amount;
      }

      final categoryMap = data['byCategory'] as Map<String, double>;
      categoryMap[transaction.category] =
          (categoryMap[transaction.category] ?? 0.0) + transaction.amount;
    }

    final result = <String, AggregatedData>{};
    monthlyData.forEach((monthKey, data) {
      result[monthKey] = AggregatedData(
        period: monthKey,
        totalIncome: data['totalIncome'] as double,
        totalExpense: data['totalExpense'] as double,
        byCategory: data['byCategory'] as Map<String, double>,
      );
    });

    return result;
  }

  /// Aggregates transactions by category for a specific period
  /// Returns a map where keys are category names and values are total amounts
  Map<String, double> aggregateByCategory(
    List<Transaction> transactions,
    String period,
  ) {
    final categoryTotals = <String, double>{};

    for (final transaction in transactions) {
      final transactionMonth = DateFormat('yyyy-MM').format(transaction.date);

      // Only include transactions from the specified period
      if (transactionMonth == period) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0.0) + transaction.amount;
      }
    }

    return categoryTotals;
  }

  /// Calculates year-over-year growth rate for a category between two years
  /// Formula: ((current year total - previous year total) / previous year total) * 100
  /// Returns the growth percentage, or 0.0 if previous year has no data
  double calculateYearOverYearGrowth(
    List<Transaction> transactions,
    String category,
    int year1,
    int year2,
  ) {
    if (year1 >= year2) {
      throw ArgumentError('year1 must be before year2');
    }

    double year1Total = 0.0;
    double year2Total = 0.0;

    for (final transaction in transactions) {
      if (transaction.category == category) {
        final transactionYear = transaction.date.year;

        if (transactionYear == year1) {
          year1Total += transaction.amount;
        } else if (transactionYear == year2) {
          year2Total += transaction.amount;
        }
      }
    }

    // If previous year has no data, return 0.0
    if (year1Total == 0.0) {
      return 0.0;
    }

    final growth = ((year2Total - year1Total) / year1Total) * 100;
    return double.parse(growth.toStringAsFixed(2));
  }

  /// Retrieves a cached aggregation result if it exists and hasn't expired
  AggregatedData? getCachedAggregation(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data;
    }
    // Remove expired entry
    _cache.remove(key);
    return null;
  }

  /// Caches an aggregation result with a TTL (time-to-live)
  void cacheAggregation(
    String key,
    AggregatedData data, {
    Duration? ttl,
  }) {
    _cache[key] = CacheEntry(
      data: data,
      ttl: ttl ?? defaultTTL,
    );
  }

  /// Clears all cached data
  void clearCache() {
    _cache.clear();
  }

  /// Removes expired entries from cache
  void removeExpiredEntries() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }
}
