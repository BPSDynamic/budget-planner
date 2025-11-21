import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_planner/features/transactions/providers/budget_provider.dart';
import 'package:budget_planner/features/transactions/models/transaction_model.dart';
import 'package:budget_planner/features/budget/models/budget_category.dart';
import 'package:budget_planner/features/budget/models/forecast.dart';
import 'package:budget_planner/features/budget/services/budget_category_manager.dart';
import 'package:budget_planner/features/budget/services/data_aggregator.dart';
import 'package:budget_planner/features/budget/services/forecast_manager.dart';
import 'package:budget_planner/features/budget/services/serialization_service.dart';
import 'package:budget_planner/features/budget/services/historical_data_manager.dart';

void main() {
  group('Integration Tests: Household Budget Management', () {
    late BudgetProvider provider;
    late BudgetCategoryManager categoryManager;
    late DataAggregator aggregator;
    late ForecastManager forecastManager;
    late SerializationService serializationService;
    late HistoricalDataManager historicalDataManager;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = BudgetProvider();
      categoryManager = BudgetCategoryManager();
      aggregator = DataAggregator();
      forecastManager = ForecastManager();
      serializationService = SerializationService();
      historicalDataManager = HistoricalDataManager();
    });

    group('Flow 1: Create category → add transactions → calculate variance', () {
      test('Complete workflow from category creation to variance calculation', () {
        // Step 1: Create a budget category
        final category = categoryManager.createCategory(
          name: 'Groceries',
          description: 'Weekly grocery shopping',
          monthlyLimit: 500,
        );

        expect(category.name, 'Groceries');
        expect(category.monthlyLimit, 500);

        // Step 2: Create transactions for the category
        final transactions = [
          Transaction(
            title: 'Whole Foods',
            amount: 120,
            date: DateTime(2024, 1, 5),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
          Transaction(
            title: 'Trader Joes',
            amount: 85,
            date: DateTime(2024, 1, 12),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
          Transaction(
            title: 'Costco',
            amount: 150,
            date: DateTime(2024, 1, 20),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
        ];

        // Step 3: Assign transactions to category
        for (final txn in transactions) {
          categoryManager.assignTransactionToCategory(txn.title, category.id);
        }

        // Step 4: Calculate variance
        final variance = categoryManager.calculateVariance(
          category.id,
          '2024-01',
          transactions,
        );

        // Verify: Total spending = 120 + 85 + 150 = 355
        // Variance = 355 - 500 = -145 (underspending)
        expect(variance, -145.0);

        // Step 5: Verify category details
        final details = categoryManager.getCategoryDetails(category.id);
        expect(details, isNotNull);
        expect(details!.monthlyLimit, 500);
      });

      test('Variance recalculates when budget limit is updated', () {
        // Create category and transactions
        final category = categoryManager.createCategory(
          name: 'Utilities',
          description: 'Monthly utilities',
          monthlyLimit: 200,
        );

        final transactions = [
          Transaction(
            title: 'Electric',
            amount: 120,
            date: DateTime(2024, 1, 5),
            type: TransactionType.expense,
            category: 'Utilities',
          ),
          Transaction(
            title: 'Water',
            amount: 50,
            date: DateTime(2024, 1, 10),
            type: TransactionType.expense,
            category: 'Utilities',
          ),
        ];

        // Initial variance: (120 + 50) - 200 = -30
        var variance = categoryManager.calculateVariance(
          category.id,
          '2024-01',
          transactions,
        );
        expect(variance, -30.0);

        // Update budget limit
        categoryManager.updateCategoryLimit(category.id, 150);

        // Recalculated variance: (120 + 50) - 150 = 20 (overspending)
        variance = categoryManager.calculateVariance(
          category.id,
          '2024-01',
          transactions,
        );
        expect(variance, 20.0);
      });
    });

    group('Flow 2: Load 5-year historical data and filter by date range', () {
      test('Load and filter historical data across multiple years', () {
        // Create transactions spanning within 5 years
        final now = DateTime.now();
        final transactions = [
          // 4 years ago
          Transaction(
            title: 'Old transaction',
            amount: 100,
            date: DateTime(now.year - 4, 6, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
          // 3 years ago
          Transaction(
            title: 'Mid transaction 1',
            amount: 200,
            date: DateTime(now.year - 3, 3, 10),
            type: TransactionType.expense,
            category: 'Transport',
          ),
          // 2 years ago
          Transaction(
            title: 'Mid transaction 2',
            amount: 150,
            date: DateTime(now.year - 2, 8, 20),
            type: TransactionType.income,
            category: 'Salary',
          ),
          // Current year
          Transaction(
            title: 'Recent transaction',
            amount: 300,
            date: DateTime(now.year, 1, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        // Validate all transactions are within 5-year window
        for (final txn in transactions) {
          expect(historicalDataManager.validateTransactionDate(txn.date), isTrue);
        }

        // Filter by date range: last 2 years
        final startDate = DateTime(now.year - 2, 1, 1);
        final endDate = DateTime(now.year, 12, 31);

        final filtered = historicalDataManager.getTransactionsByDateRange(
          transactions,
          startDate,
          endDate,
        );

        // Should include transactions from 2 years ago and current year
        expect(filtered.length, 2);
        expect(filtered.every((t) => t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate)), isTrue);
      });

      test('Exclude transactions outside 5-year window', () {
        final now = DateTime.now();
        final tooOld = DateTime(now.year - 6, 1, 1);
        final withinWindow = DateTime(now.year - 2, 6, 15);

        expect(historicalDataManager.validateTransactionDate(tooOld), isFalse);
        expect(historicalDataManager.validateTransactionDate(withinWindow), isTrue);
      });

      test('Get transactions for specific year', () {
        final now = DateTime.now();
        final year = now.year;

        final transactions = [
          Transaction(
            title: 'Jan',
            amount: 100,
            date: DateTime(year, 1, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Dec',
            amount: 200,
            date: DateTime(year, 12, 25),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Other year',
            amount: 150,
            date: DateTime(year - 1, 6, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final yearTransactions = historicalDataManager.getTransactionsForYear(transactions, year);

        expect(yearTransactions.length, 2);
        expect(yearTransactions.every((t) => t.date.year == year), isTrue);
      });

      test('Get transactions for specific month', () {
        final now = DateTime.now();
        final year = now.year;
        const month = 6;

        final transactions = [
          Transaction(
            title: 'June 1',
            amount: 100,
            date: DateTime(year, month, 1),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'June 30',
            amount: 200,
            date: DateTime(year, month, 30),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'July',
            amount: 150,
            date: DateTime(year, month + 1, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final monthTransactions = historicalDataManager.getTransactionsForMonth(transactions, year, month);

        expect(monthTransactions.length, 2);
        expect(monthTransactions.every((t) => t.date.year == year && t.date.month == month), isTrue);
      });
    });

    group('Flow 3: Multi-year aggregation and year-over-year calculations', () {
      test('Aggregate data by month across multiple years', () {
        final transactions = [
          // January 2023
          Transaction(
            title: 'Groceries Jan 2023',
            amount: 100,
            date: DateTime(2023, 1, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
          // January 2024
          Transaction(
            title: 'Groceries Jan 2024',
            amount: 120,
            date: DateTime(2024, 1, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
          // February 2024
          Transaction(
            title: 'Groceries Feb 2024',
            amount: 110,
            date: DateTime(2024, 2, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final monthlyData = aggregator.aggregateByMonth(transactions);

        expect(monthlyData.containsKey('2023-01'), isTrue);
        expect(monthlyData.containsKey('2024-01'), isTrue);
        expect(monthlyData.containsKey('2024-02'), isTrue);
        expect(monthlyData['2023-01']!.totalExpense, 100);
        expect(monthlyData['2024-01']!.totalExpense, 120);
      });

      test('Calculate year-over-year growth for categories', () {
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
      });

      test('Aggregate by category for specific period', () {
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
            title: 'More Groceries',
            amount: 75,
            date: DateTime(2024, 1, 20),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'February Groceries',
            amount: 90,
            date: DateTime(2024, 2, 5),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        final categoryTotals = aggregator.aggregateByCategory(transactions, '2024-01');

        expect(categoryTotals['Food'], 175);
        expect(categoryTotals['Transport'], 50);
        expect(categoryTotals.length, 2);
      });

      test('Verify aggregation accuracy: sum of categories equals total', () {
        final transactions = [
          Transaction(
            title: 'Food',
            amount: 100,
            date: DateTime(2024, 1, 5),
            type: TransactionType.expense,
            category: 'Food',
          ),
          Transaction(
            title: 'Transport',
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
        ];

        final monthlyData = aggregator.aggregateByMonth(transactions);
        final january = monthlyData['2024-01']!;

        double categorySum = 0;
        january.byCategory.forEach((_, amount) {
          categorySum += amount;
        });

        expect(categorySum, january.totalExpense);
      });
    });

    group('Flow 4: Forecast creation and separation from transactions', () {
      test('Create forecasts and verify separation from transactions', () {
        final now = DateTime.now();
        final futureMonth1 = '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';
        final futureMonth2 = '${now.year}-${(now.month + 3).toString().padLeft(2, '0')}';

        // Create forecasts
        final forecast1 = forecastManager.createForecast(
          period: futureMonth1,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Based on historical data',
        );

        final forecast2 = forecastManager.createForecast(
          period: futureMonth2,
          category: 'Transport',
          amount: 300,
          assumptions: 'Conservative estimate',
        );

        // Create transactions
        final transactions = [
          Transaction(
            title: 'Groceries',
            amount: 100,
            date: DateTime(now.year, now.month, 15),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
        ];

        // Verify forecasts are stored separately
        final allForecasts = forecastManager.getAllForecasts();
        expect(allForecasts.length, 2);
        expect(allForecasts[0].id, forecast1.id);
        expect(allForecasts[1].id, forecast2.id);

        // Verify forecasts don't interfere with transactions
        expect(transactions.length, 1);
        expect(transactions[0].title, 'Groceries');
      });

      test('Delete forecast and verify it does not affect transactions', () {
        final now = DateTime.now();
        final futureMonth = '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';

        final forecast = forecastManager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );

        final transactions = [
          Transaction(
            title: 'Groceries',
            amount: 100,
            date: DateTime(now.year, now.month, 15),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
        ];

        // Delete forecast
        final deleted = forecastManager.deleteForecast(forecast.id);
        expect(deleted, isTrue);

        // Verify transactions are unaffected
        expect(transactions.length, 1);
        expect(transactions[0].title, 'Groceries');
      });

      test('Get forecasts by period and category', () {
        final now = DateTime.now();
        final futureMonth1 = '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';
        final futureMonth2 = '${now.year}-${(now.month + 3).toString().padLeft(2, '0')}';

        forecastManager.createForecast(
          period: futureMonth1,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test 1',
        );
        forecastManager.createForecast(
          period: futureMonth1,
          category: 'Transport',
          amount: 300,
          assumptions: 'Test 2',
        );
        forecastManager.createForecast(
          period: futureMonth2,
          category: 'Groceries',
          amount: 550,
          assumptions: 'Test 3',
        );

        final period1Forecasts = forecastManager.getForecastsByPeriod(futureMonth1);
        final groceryForecasts = forecastManager.getForecastsByCategory('Groceries');

        expect(period1Forecasts.length, 2);
        expect(groceryForecasts.length, 2);
      });
    });

    group('Flow 5: Serialization/deserialization of all data types', () {
      test('Round-trip serialization of budget categories', () {
        final original = [
          BudgetCategory(
            name: 'Groceries',
            description: 'Food and groceries',
            monthlyLimit: 500,
          ),
          BudgetCategory(
            name: 'Transport',
            description: 'Gas and transit',
            monthlyLimit: 300,
          ),
        ];

        // Serialize
        final json = serializationService.serializeBudgetData(original);

        // Deserialize
        final deserialized = serializationService.deserializeBudgetData(json);

        // Verify round trip
        expect(deserialized.length, 2);
        expect(deserialized[0].name, 'Groceries');
        expect(deserialized[0].monthlyLimit, 500);
        expect(deserialized[1].name, 'Transport');
        expect(deserialized[1].monthlyLimit, 300);
      });

      test('Round-trip serialization of forecasts', () {
        final now = DateTime.now();
        final futureMonth1 = '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';
        final futureMonth2 = '${now.year}-${(now.month + 3).toString().padLeft(2, '0')}';

        final original = [
          Forecast(
            period: futureMonth1,
            category: 'Groceries',
            projectedAmount: 500,
            assumptions: 'Based on historical data',
          ),
          Forecast(
            period: futureMonth2,
            category: 'Transport',
            projectedAmount: 300,
            assumptions: 'Conservative estimate',
          ),
        ];

        // Serialize
        final json = serializationService.serializeForecasts(original);

        // Deserialize
        final deserialized = serializationService.deserializeForecasts(json);

        // Verify round trip
        expect(deserialized.length, 2);
        expect(deserialized[0].category, 'Groceries');
        expect(deserialized[0].projectedAmount, 500);
        expect(deserialized[1].category, 'Transport');
        expect(deserialized[1].projectedAmount, 300);
      });

      test('Validate deserialized data with missing fields', () {
        final invalidJson = '[{"name": "Groceries"}]';

        expect(
          () => serializationService.deserializeBudgetData(invalidJson),
          throwsArgumentError,
        );
      });

      test('Validate deserialized data with incorrect types', () {
        expect(
          () => serializationService.validateDeserializedData({
            'id': 123, // Should be string
            'createdDate': DateTime.now().toIso8601String(),
          }),
          throwsArgumentError,
        );
      });
    });

    group('Flow 6: Date range preference persistence across sessions', () {
      test('Set and retrieve date range preference', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);

        // Set preference
        provider.setDateRangePreference(startDate, endDate);

        // Retrieve preference
        final retrieved = provider.getDateRangePreference();

        expect(retrieved, isNotNull);
        expect(retrieved!.startDate, startDate);
        expect(retrieved!.endDate, endDate);
      });

      test('Preference persists across multiple retrievals', () {
        final startDate = DateTime(2023, 6, 1);
        final endDate = DateTime(2024, 5, 31);

        provider.setDateRangePreference(startDate, endDate);

        // Retrieve multiple times
        final retrieved1 = provider.getDateRangePreference();
        final retrieved2 = provider.getDateRangePreference();

        expect(retrieved1!.startDate, startDate);
        expect(retrieved2!.startDate, startDate);
        expect(retrieved1!.endDate, endDate);
        expect(retrieved2!.endDate, endDate);
      });

      test('Update date range preference', () {
        final startDate1 = DateTime(2024, 1, 1);
        final endDate1 = DateTime(2024, 12, 31);

        provider.setDateRangePreference(startDate1, endDate1);
        var retrieved = provider.getDateRangePreference();
        expect(retrieved!.startDate, startDate1);

        // Update preference
        final startDate2 = DateTime(2023, 1, 1);
        final endDate2 = DateTime(2023, 12, 31);
        provider.setDateRangePreference(startDate2, endDate2);

        retrieved = provider.getDateRangePreference();
        expect(retrieved!.startDate, startDate2);
        expect(retrieved!.endDate, endDate2);
      });

      test('Return null when no preference is set', () {
        final retrieved = provider.getDateRangePreference();
        expect(retrieved, isNull);
      });
    });

    group('Complex Integration Scenarios', () {
      test('Complete workflow: categories, transactions, aggregation, and forecasts', () {
        // 1. Create categories
        final groceryCategory = categoryManager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        final transportCategory = categoryManager.createCategory(
          name: 'Transport',
          description: 'Gas',
          monthlyLimit: 300,
        );

        // 2. Create transactions
        final transactions = [
          Transaction(
            title: 'Whole Foods',
            amount: 120,
            date: DateTime(2024, 1, 5),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
          Transaction(
            title: 'Gas',
            amount: 50,
            date: DateTime(2024, 1, 10),
            type: TransactionType.expense,
            category: 'Transport',
          ),
          Transaction(
            title: 'Trader Joes',
            amount: 85,
            date: DateTime(2024, 1, 15),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
        ];

        // 3. Calculate variances
        final groceryVariance = categoryManager.calculateVariance(
          groceryCategory.id,
          '2024-01',
          transactions,
        );
        final transportVariance = categoryManager.calculateVariance(
          transportCategory.id,
          '2024-01',
          transactions,
        );

        expect(groceryVariance, -295.0); // (120 + 85) - 500
        expect(transportVariance, -250.0); // 50 - 300

        // 4. Aggregate data
        final monthlyData = aggregator.aggregateByMonth(transactions);
        expect(monthlyData['2024-01']!.totalExpense, 255);

        // 5. Create forecasts
        final now = DateTime.now();
        final futureMonth = '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';

        final forecast = forecastManager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 550,
          assumptions: 'Based on current spending',
        );

        expect(forecast.projectedAmount, 550);

        // 6. Verify all data is separate and consistent
        expect(categoryManager.getAllCategories().length, 2);
        expect(forecastManager.getAllForecasts().length, 1);
        expect(transactions.length, 3);
      });

      test('Multi-year analysis with categories and aggregation', () {
        // Create transactions across multiple years
        final transactions = [
          // 2022
          Transaction(
            title: 'Food 2022',
            amount: 800,
            date: DateTime(2022, 6, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
          // 2023
          Transaction(
            title: 'Food 2023',
            amount: 1000,
            date: DateTime(2023, 6, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
          // 2024
          Transaction(
            title: 'Food 2024',
            amount: 1200,
            date: DateTime(2024, 6, 15),
            type: TransactionType.expense,
            category: 'Food',
          ),
        ];

        // Create category
        final category = categoryManager.createCategory(
          name: 'Food',
          description: 'Groceries',
          monthlyLimit: 1000,
        );

        // Aggregate by month
        final monthlyData = aggregator.aggregateByMonth(transactions);
        expect(monthlyData.length, 3);

        // Calculate year-over-year growth
        final growth2023 = aggregator.calculateYearOverYearGrowth(
          transactions,
          'Food',
          2022,
          2023,
        );
        final growth2024 = aggregator.calculateYearOverYearGrowth(
          transactions,
          'Food',
          2023,
          2024,
        );

        // 2022 to 2023: ((1000 - 800) / 800) * 100 = 25.0
        expect(growth2023, 25.0);

        // 2023 to 2024: ((1200 - 1000) / 1000) * 100 = 20.0
        expect(growth2024, 20.0);
      });

      test('Serialization with provider persistence', () {
        // Add categories to provider
        final category1 = BudgetCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );
        final category2 = BudgetCategory(
          name: 'Transport',
          description: 'Gas',
          monthlyLimit: 300,
        );

        provider.addCategory(category1);
        provider.addCategory(category2);

        // Serialize categories
        final json = serializationService.serializeBudgetData(provider.categories);

        // Deserialize
        final deserialized = serializationService.deserializeBudgetData(json);

        expect(deserialized.length, 2);
        expect(deserialized[0].name, 'Groceries');
        expect(deserialized[1].name, 'Transport');
      });
    });
  });
}
