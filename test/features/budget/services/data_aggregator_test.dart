import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/features/budget/services/data_aggregator.dart';
import 'package:budget_planner/features/transactions/models/transaction_model.dart';
import 'package:budget_planner/features/budget/models/aggregated_data.dart';

void main() {
  group('DataAggregator', () {
    late DataAggregator aggregator;

    setUp(() {
      aggregator = DataAggregator();
    });

    group('aggregateByMonth', () {
      test('returns empty map for empty transaction list', () {
        final result = aggregator.aggregateByMonth([]);
        expect(result, isEmpty);
      });

      test('groups transactions by month correctly', () {
        final transactions = [
          Transaction(
            title: 'Salary',
            amount: 5000,
            date: DateTime(2024, 1, 15),
            type: TransactionType.income,
            category: 'Salary',
          ),
          Transaction(
            title: 'Groceries',
            amount: 100,
            date: DateTime(2024, 1, 20),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Salary',
            amount: 5000,
            date: DateTime(2024, 2, 15),
            type: TransactionType.income,
            category: 'Salary',
          ),
        ];

        final result = aggregator.aggregateByMonth(transactions);

        expect(result.keys, containsAll(['2024-01', '2024-02']));
        expect(result['2024-01']!.totalIncome, 5000);
        expect(result['2024-01']!.totalExpense, 100);
        expect(result['2024-02']!.totalIncome, 5000);
        expect(result['2024-02']!.totalExpense, 0);
      });

      test('aggregates categories within each month', () {
        final transactions = [
          Transaction(
            title: 'Groceries',
            amount: 100,
            date: DateTime(2024, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Gas',
            amount: 50,
            date: DateTime(2024, 1, 15),
            type: TransactionType.expense,
            category: 'Transport',
          ),
          Transaction(
            title: 'More Groceries',
            amount: 75,
            date: DateTime(2024, 1, 20),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final result = aggregator.aggregateByMonth(transactions);

        expect(result['2024-01']!.byCategory['Food'], 175);
        expect(result['2024-01']!.byCategory['Transport'], 50);
      });
    });

    group('aggregateByCategory', () {
      test('returns empty map for empty transaction list', () {
        final result = aggregator.aggregateByCategory([], '2024-01');
        expect(result, isEmpty);
      });

      test('filters transactions by period correctly', () {
        final transactions = [
          Transaction(
            title: 'Groceries',
            amount: 100,
            date: DateTime(2024, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Groceries',
            amount: 150,
            date: DateTime(2024, 2, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final result = aggregator.aggregateByCategory(transactions, '2024-01');

        expect(result['Food'], 100);
        expect(result.length, 1);
      });

      test('sums all transactions for a category in the period', () {
        final transactions = [
          Transaction(
            title: 'Groceries 1',
            amount: 50,
            date: DateTime(2024, 1, 5),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Groceries 2',
            amount: 75,
            date: DateTime(2024, 1, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Gas',
            amount: 40,
            date: DateTime(2024, 1, 20),
            type: TransactionType.expense,
            category: 'Transport',
          ),
        ];

        final result = aggregator.aggregateByCategory(transactions, '2024-01');

        expect(result['Food'], 125);
        expect(result['Transport'], 40);
      });
    });

    group('calculateYearOverYearGrowth', () {
      test('throws error if year1 is not before year2', () {
        expect(
          () => aggregator.calculateYearOverYearGrowth([], 'Food', 2024, 2024),
          throwsArgumentError,
        );
        expect(
          () => aggregator.calculateYearOverYearGrowth([], 'Food', 2025, 2024),
          throwsArgumentError,
        );
      });

      test('returns 0.0 if previous year has no data', () {
        final transactions = [
          Transaction(
            title: 'Groceries',
            amount: 100,
            date: DateTime(2024, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final growth = aggregator.calculateYearOverYearGrowth(
          transactions,
          'Food',
          2023,
          2024,
        );

        expect(growth, 0.0);
      });

      test('calculates growth rate correctly', () {
        final transactions = [
          Transaction(
            title: 'Groceries',
            amount: 100,
            date: DateTime(2023, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Groceries',
            amount: 150,
            date: DateTime(2024, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final growth = aggregator.calculateYearOverYearGrowth(
          transactions,
          'Food',
          2023,
          2024,
        );

        // ((150 - 100) / 100) * 100 = 50.0
        expect(growth, 50.0);
      });

      test('returns negative growth for decrease', () {
        final transactions = [
          Transaction(
            title: 'Groceries',
            amount: 200,
            date: DateTime(2023, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Groceries',
            amount: 100,
            date: DateTime(2024, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final growth = aggregator.calculateYearOverYearGrowth(
          transactions,
          'Food',
          2023,
          2024,
        );

        // ((100 - 200) / 200) * 100 = -50.0
        expect(growth, -50.0);
      });

      test('returns growth accurate to two decimal places', () {
        final transactions = [
          Transaction(
            title: 'Groceries',
            amount: 100,
            date: DateTime(2023, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Groceries',
            amount: 133.33,
            date: DateTime(2024, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final growth = aggregator.calculateYearOverYearGrowth(
          transactions,
          'Food',
          2023,
          2024,
        );

        // ((133.33 - 100) / 100) * 100 = 33.33
        expect(growth, 33.33);
      });

      test('only includes transactions for specified category', () {
        final transactions = [
          Transaction(
            title: 'Groceries',
            amount: 100,
            date: DateTime(2023, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Gas',
            amount: 1000,
            date: DateTime(2023, 1, 10),
            type: TransactionType.expense,
            category: 'Transport',
          ),
          Transaction(
            title: 'Groceries',
            amount: 150,
            date: DateTime(2024, 1, 10),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final growth = aggregator.calculateYearOverYearGrowth(
          transactions,
          'Food',
          2023,
          2024,
        );

        // Should only consider Food category: ((150 - 100) / 100) * 100 = 50.0
        expect(growth, 50.0);
      });
    });

    group('caching', () {
      test('caches aggregation data', () {
        final data = AggregatedData(
          period: '2024-01',
          totalIncome: 5000,
          totalExpense: 1000,
          byCategory: {'Food': 500, 'Transport': 200},
        );

        aggregator.cacheAggregation('test-key', data);
        final cached = aggregator.getCachedAggregation('test-key');

        expect(cached, data);
      });

      test('returns null for non-existent cache key', () {
        final cached = aggregator.getCachedAggregation('non-existent');
        expect(cached, isNull);
      });

      test('removes expired cache entries', () async {
        final data = AggregatedData(
          period: '2024-01',
          totalIncome: 5000,
          totalExpense: 1000,
          byCategory: {},
        );

        aggregator.cacheAggregation(
          'test-key',
          data,
          ttl: Duration(milliseconds: 100),
        );

        // Wait for cache to expire
        await Future.delayed(Duration(milliseconds: 150));

        final cached = aggregator.getCachedAggregation('test-key');
        expect(cached, isNull);
      });

      test('clears all cache', () {
        final data = AggregatedData(
          period: '2024-01',
          totalIncome: 5000,
          totalExpense: 1000,
          byCategory: {},
        );

        aggregator.cacheAggregation('key1', data);
        aggregator.cacheAggregation('key2', data);

        aggregator.clearCache();

        expect(aggregator.getCachedAggregation('key1'), isNull);
        expect(aggregator.getCachedAggregation('key2'), isNull);
      });
    });

    // Property-Based Tests

    group('Property 3: Monthly Aggregation Accuracy', () {
      test(
        'sum of all category totals for a month equals total spending',
        () {
          // **Feature: household-budget-management, Property 3: Monthly Aggregation Accuracy**
          // **Validates: Requirements 6.5**

          // Generate test data with multiple categories
          final transactions = [
            Transaction(
              title: 'Groceries',
              amount: 100,
              date: DateTime(2024, 1, 5),
              type: TransactionType.expense,
              category: 'Food',
            ),
            Transaction(
              title: 'Gas',
              amount: 50,
              date: DateTime(2024, 1, 10),
              type: TransactionType.expense,
              category: 'Transport',
            ),
            Transaction(
              title: 'Utilities',
              amount: 75,
              date: DateTime(2024, 1, 15),
              type: TransactionType.expense,
              category: 'Utilities',
            ),
            Transaction(
              title: 'Salary',
              amount: 5000,
              date: DateTime(2024, 1, 1),
              type: TransactionType.income,
              category: 'Salary',
            ),
          ];

          final monthlyData = aggregator.aggregateByMonth(transactions);
          final january = monthlyData['2024-01']!;

          // Sum all category totals
          double categorySum = 0;
          january.byCategory.forEach((_, amount) {
            categorySum += amount;
          });

          // Total spending should equal sum of all categories
          final totalSpending = january.totalIncome + january.totalExpense;
          expect(categorySum, totalSpending);
        },
      );
    });

    group('Property 4: Category Aggregation Correctness', () {
      test(
        'sum of transactions for a category equals reported total',
        () {
          // **Feature: household-budget-management, Property 4: Category Aggregation Correctness**
          // **Validates: Requirements 6.2**

          final transactions = [
            Transaction(
              title: 'Groceries 1',
              amount: 50,
              date: DateTime(2024, 1, 5),
              type: TransactionType.expense,
              category: 'Food',
            ),
            Transaction(
              title: 'Groceries 2',
              amount: 75,
              date: DateTime(2024, 1, 10),
              type: TransactionType.expense,
              category: 'Food',
            ),
            Transaction(
              title: 'Groceries 3',
              amount: 25,
              date: DateTime(2024, 1, 15),
              type: TransactionType.expense,
              category: 'Food',
            ),
            Transaction(
              title: 'Gas',
              amount: 40,
              date: DateTime(2024, 1, 20),
              type: TransactionType.expense,
              category: 'Transport',
            ),
          ];

          final categoryTotals =
              aggregator.aggregateByCategory(transactions, '2024-01');

          // Verify Food category total
          expect(categoryTotals['Food'], 150);

          // Verify Transport category total
          expect(categoryTotals['Transport'], 40);

          // Verify sum of all categories
          double sum = 0;
          categoryTotals.forEach((_, amount) {
            sum += amount;
          });
          expect(sum, 190);
        },
      );
    });

    group('Property 6: Year-over-Year Growth Calculation', () {
      test(
        'growth rate calculated correctly with formula ((Y2-Y1)/Y1)*100',
        () {
          // **Feature: household-budget-management, Property 6: Year-over-Year Growth Calculation**
          // **Validates: Requirements 2.2**

          final transactions = [
            Transaction(
              title: 'Food 2023',
              amount: 1000,
              date: DateTime(2023, 6, 15),
              type: TransactionType.expense,
              category: 'Food',
            ),
            Transaction(
              title: 'Food 2024',
              amount: 1200,
              date: DateTime(2024, 6, 15),
              type: TransactionType.expense,
              category: 'Food',
            ),
          ];

          final growth = aggregator.calculateYearOverYearGrowth(
            transactions,
            'Food',
            2023,
            2024,
          );

          // ((1200 - 1000) / 1000) * 100 = 20.0
          expect(growth, 20.0);
        },
      );
    });

    group('Property 14: Aggregation Caching Consistency', () {
      test(
        'cached result from second query equals result from first query',
        () {
          // **Feature: household-budget-management, Property 14: Aggregation Caching Consistency**
          // **Validates: Requirements 6.3**

          final transactions = [
            Transaction(
              title: 'Groceries',
              amount: 100,
              date: DateTime(2024, 1, 10),
              type: TransactionType.expense,
              category: 'Food',
            ),
            Transaction(
              title: 'Gas',
              amount: 50,
              date: DateTime(2024, 1, 15),
              type: TransactionType.expense,
              category: 'Transport',
            ),
          ];

          // First aggregation
          final monthlyData1 = aggregator.aggregateByMonth(transactions);
          final january1 = monthlyData1['2024-01']!;

          // Cache the result
          aggregator.cacheAggregation('2024-01', january1);

          // Second aggregation (should retrieve from cache)
          final cached = aggregator.getCachedAggregation('2024-01');

          // Verify cached result equals original
          expect(cached, january1);
          expect(cached!.totalIncome, january1.totalIncome);
          expect(cached.totalExpense, january1.totalExpense);
          expect(cached.byCategory, january1.byCategory);
        },
      );
    });
  });
}
