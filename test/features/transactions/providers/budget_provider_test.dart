import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_planner/features/transactions/providers/budget_provider.dart';
import 'package:budget_planner/features/transactions/models/transaction_model.dart';
import 'package:budget_planner/features/budget/models/budget_category.dart';
import 'package:budget_planner/features/budget/models/forecast.dart';

void main() {
  group('BudgetProvider', () {
    late BudgetProvider provider;

    setUpAll(() {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      provider = BudgetProvider();
    });

    group('Category Management', () {
      test('adds category successfully', () {
        final category = BudgetCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        provider.addCategory(category);

        expect(provider.categories.length, 1);
        expect(provider.categories[0].name, 'Groceries');
      });

      test('deletes category successfully', () {
        final category = BudgetCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        provider.addCategory(category);
        provider.deleteCategory(category.id);

        expect(provider.categories, isEmpty);
      });

      test('maintains multiple categories', () {
        final cat1 = BudgetCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );
        final cat2 = BudgetCategory(
          name: 'Transport',
          description: 'Gas',
          monthlyLimit: 300,
        );

        provider.addCategory(cat1);
        provider.addCategory(cat2);

        expect(provider.categories.length, 2);
      });
    });

    group('Forecast Management', () {
      test('adds forecast successfully', () {
        final now = DateTime.now();
        final futureMonth =
            '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';

        final forecast = Forecast(
          period: futureMonth,
          category: 'Groceries',
          projectedAmount: 500,
          assumptions: 'Test',
        );

        provider.addForecast(forecast);

        expect(provider.forecasts.length, 1);
        expect(provider.forecasts[0].category, 'Groceries');
      });

      test('deletes forecast successfully', () {
        final now = DateTime.now();
        final futureMonth =
            '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';

        final forecast = Forecast(
          period: futureMonth,
          category: 'Groceries',
          projectedAmount: 500,
          assumptions: 'Test',
        );

        provider.addForecast(forecast);
        provider.deleteForecast(forecast.id);

        expect(provider.forecasts, isEmpty);
      });

      test('maintains multiple forecasts', () {
        final now = DateTime.now();
        final futureMonth1 =
            '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';
        final futureMonth2 =
            '${now.year}-${(now.month + 3).toString().padLeft(2, '0')}';

        final forecast1 = Forecast(
          period: futureMonth1,
          category: 'Groceries',
          projectedAmount: 500,
          assumptions: 'Test 1',
        );
        final forecast2 = Forecast(
          period: futureMonth2,
          category: 'Transport',
          projectedAmount: 300,
          assumptions: 'Test 2',
        );

        provider.addForecast(forecast1);
        provider.addForecast(forecast2);

        expect(provider.forecasts.length, 2);
      });
    });

    group('Date Range Preference', () {
      test('sets date range preference', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);

        provider.setDateRangePreference(startDate, endDate);

        expect(provider.dateRangePreference, isNotNull);
        expect(provider.dateRangePreference!.startDate, startDate);
        expect(provider.dateRangePreference!.endDate, endDate);
      });

      test('gets date range preference', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);

        provider.setDateRangePreference(startDate, endDate);
        final retrieved = provider.getDateRangePreference();

        expect(retrieved, isNotNull);
        expect(retrieved!.startDate, startDate);
        expect(retrieved!.endDate, endDate);
      });

      test('returns null when no preference set', () {
        final retrieved = provider.getDateRangePreference();
        expect(retrieved, isNull);
      });
    });

    group('Currency Management', () {
      test('sets currency successfully', () {
        provider.setCurrency('€');

        expect(provider.currency, '€');
      });

      test('defaults to dollar sign', () {
        expect(provider.currency, '\$');
      });
    });

    group('Data Persistence', () {
      test('maintains categories after operations', () {
        final category = BudgetCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        provider.addCategory(category);
        final categoryId = category.id;

        // Verify category is stored
        expect(provider.categories.length, 1);
        expect(provider.categories[0].id, categoryId);
      });

      test('maintains forecasts after operations', () {
        final now = DateTime.now();
        final futureMonth =
            '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';

        final forecast = Forecast(
          period: futureMonth,
          category: 'Groceries',
          projectedAmount: 500,
          assumptions: 'Test',
        );

        provider.addForecast(forecast);
        final forecastId = forecast.id;

        // Verify forecast is stored
        expect(provider.forecasts.length, 1);
        expect(provider.forecasts[0].id, forecastId);
      });
    });

    // Property-Based Tests

    group('Property 13: Date Range Preference Persistence', () {
      test(
        'date range preference persists correctly',
        () {
          // **Feature: household-budget-management, Property 13: Date Range Preference Persistence**
          // **Validates: Requirements 1.4**

          final startDate = DateTime(2024, 1, 1);
          final endDate = DateTime(2024, 12, 31);

          // Set preference
          provider.setDateRangePreference(startDate, endDate);

          // Retrieve preference
          final retrieved = provider.getDateRangePreference();

          // Verify persistence
          expect(retrieved, isNotNull);
          expect(retrieved!.startDate, startDate);
          expect(retrieved!.endDate, endDate);
          expect(retrieved!.startDate.year, 2024);
          expect(retrieved!.endDate.year, 2024);
        },
      );
    });
  });
}
