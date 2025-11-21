import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/features/budget/services/forecast_manager.dart';

void main() {
  group('ForecastManager', () {
    late ForecastManager manager;
    late String futureMonth;
    late String futureMonth2;
    late String futureMonth3;

    setUp(() {
      manager = ForecastManager();
      // Generate future months dynamically
      final now = DateTime.now();
      final future1 = DateTime(now.year, now.month + 2);
      final future2 = DateTime(now.year, now.month + 3);
      final future3 = DateTime(now.year, now.month + 4);
      futureMonth = '${future1.year}-${future1.month.toString().padLeft(2, '0')}';
      futureMonth2 = '${future2.year}-${future2.month.toString().padLeft(2, '0')}';
      futureMonth3 = '${future3.year}-${future3.month.toString().padLeft(2, '0')}';
    });

    group('createForecast', () {
      test('creates a forecast with valid parameters', () {
        final forecast = manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Based on historical data',
        );

        expect(forecast.period, futureMonth);
        expect(forecast.category, 'Groceries');
        expect(forecast.projectedAmount, 500);
        expect(forecast.assumptions, 'Based on historical data');
        expect(forecast.id, isNotEmpty);
      });

      test('throws error for non-positive amount', () {
        expect(
          () => manager.createForecast(
            period: futureMonth,
            category: 'Groceries',
            amount: 0,
            assumptions: 'Test',
          ),
          throwsArgumentError,
        );

        expect(
          () => manager.createForecast(
            period: futureMonth,
            category: 'Groceries',
            amount: -100,
            assumptions: 'Test',
          ),
          throwsArgumentError,
        );
      });

      test('throws error for past period', () {
        expect(
          () => manager.createForecast(
            period: '2020-01',
            category: 'Groceries',
            amount: 500,
            assumptions: 'Test',
          ),
          throwsArgumentError,
        );
      });

      test('throws error for invalid period format', () {
        expect(
          () => manager.createForecast(
            period: '2025/03',
            category: 'Groceries',
            amount: 500,
            assumptions: 'Test',
          ),
          throwsArgumentError,
        );

        expect(
          () => manager.createForecast(
            period: '2025-3',
            category: 'Groceries',
            amount: 500,
            assumptions: 'Test',
          ),
          throwsArgumentError,
        );
      });

      test('adds forecast to internal list', () {
        manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );

        expect(manager.forecastCount, 1);
      });
    });

    group('validateForecast', () {
      test('throws error for non-positive amount', () {
        expect(
          () => manager.validateForecast(
            period: futureMonth,
            amount: 0,
          ),
          throwsArgumentError,
        );
      });

      test('throws error for invalid period format', () {
        expect(
          () => manager.validateForecast(
            period: '2025/03',
            amount: 500,
          ),
          throwsArgumentError,
        );
      });

      test('throws error for past period', () {
        expect(
          () => manager.validateForecast(
            period: '2020-01',
            amount: 500,
          ),
          throwsArgumentError,
        );
      });

      test('accepts valid future period', () {
        // Should not throw
        manager.validateForecast(
          period: futureMonth,
          amount: 500,
        );
      });
    });

    group('deleteForecast', () {
      test('deletes forecast successfully', () {
        final forecast = manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );

        final deleted = manager.deleteForecast(forecast.id);

        expect(deleted, true);
        expect(manager.forecastCount, 0);
      });

      test('returns false for non-existent forecast', () {
        final deleted = manager.deleteForecast('non-existent');
        expect(deleted, false);
      });
    });

    group('getForecastsByPeriod', () {
      test('returns empty list for period with no forecasts', () {
        final forecasts = manager.getForecastsByPeriod(futureMonth);
        expect(forecasts, isEmpty);
      });

      test('returns all forecasts for a specific period', () {
        manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );
        manager.createForecast(
          period: futureMonth,
          category: 'Transport',
          amount: 300,
          assumptions: 'Test',
        );
        manager.createForecast(
          period: futureMonth2,
          category: 'Groceries',
          amount: 550,
          assumptions: 'Test',
        );

        final period1 = manager.getForecastsByPeriod(futureMonth);
        final period2 = manager.getForecastsByPeriod(futureMonth2);

        expect(period1.length, 2);
        expect(period2.length, 1);
      });

      test('filters by period correctly', () {
        manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );
        manager.createForecast(
          period: futureMonth2,
          category: 'Groceries',
          amount: 550,
          assumptions: 'Test',
        );

        final period1 = manager.getForecastsByPeriod(futureMonth);

        expect(period1.length, 1);
        expect(period1[0].period, futureMonth);
      });
    });

    group('getForecastsByCategory', () {
      test('returns empty list for category with no forecasts', () {
        final forecasts = manager.getForecastsByCategory('Groceries');
        expect(forecasts, isEmpty);
      });

      test('returns all forecasts for a specific category', () {
        manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );
        manager.createForecast(
          period: futureMonth2,
          category: 'Groceries',
          amount: 550,
          assumptions: 'Test',
        );
        manager.createForecast(
          period: futureMonth,
          category: 'Transport',
          amount: 300,
          assumptions: 'Test',
        );

        final groceries = manager.getForecastsByCategory('Groceries');
        final transport = manager.getForecastsByCategory('Transport');

        expect(groceries.length, 2);
        expect(transport.length, 1);
      });

      test('filters by category correctly', () {
        manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );
        manager.createForecast(
          period: futureMonth,
          category: 'Transport',
          amount: 300,
          assumptions: 'Test',
        );

        final groceries = manager.getForecastsByCategory('Groceries');

        expect(groceries.length, 1);
        expect(groceries[0].category, 'Groceries');
      });
    });

    group('getAllForecasts', () {
      test('returns empty list initially', () {
        final forecasts = manager.getAllForecasts();
        expect(forecasts, isEmpty);
      });

      test('returns all created forecasts', () {
        manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );
        manager.createForecast(
          period: futureMonth2,
          category: 'Transport',
          amount: 300,
          assumptions: 'Test',
        );

        final forecasts = manager.getAllForecasts();
        expect(forecasts.length, 2);
      });

      test('returns unmodifiable list', () {
        manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );

        final forecasts = manager.getAllForecasts();
        expect(
          () => forecasts.add(manager.createForecast(
            period: futureMonth2,
            category: 'Transport',
            amount: 300,
            assumptions: 'Test',
          )),
          throwsUnsupportedError,
        );
      });
    });

    group('getForecastById', () {
      test('returns forecast for existing ID', () {
        final created = manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );

        final retrieved = manager.getForecastById(created.id);

        expect(retrieved, isNotNull);
        expect(retrieved!.id, created.id);
      });

      test('returns null for non-existent ID', () {
        final retrieved = manager.getForecastById('non-existent');
        expect(retrieved, isNull);
      });
    });

    group('clear', () {
      test('clears all forecasts', () {
        manager.createForecast(
          period: futureMonth,
          category: 'Groceries',
          amount: 500,
          assumptions: 'Test',
        );
        manager.createForecast(
          period: futureMonth2,
          category: 'Transport',
          amount: 300,
          assumptions: 'Test',
        );

        manager.clear();

        expect(manager.forecastCount, 0);
      });
    });

    // Property-Based Tests

    group('Property 8: Forecast Data Validation', () {
      test(
        'forecast amount is positive and period is in future',
        () {
          // **Feature: household-budget-management, Property 8: Forecast Data Validation**
          // **Validates: Requirements 4.5**

          final forecast = manager.createForecast(
            period: futureMonth3,
            category: 'Groceries',
            amount: 500,
            assumptions: 'Based on historical data',
          );

          // Verify amount is positive
          expect(forecast.projectedAmount, greaterThan(0));

          // Verify period is in future or current
          final parts = forecast.period.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final forecastDate = DateTime(year, month, 1);
          final now = DateTime.now();
          final currentMonth = DateTime(now.year, now.month, 1);

          expect(forecastDate.isAfter(currentMonth) || forecastDate.isAtSameMomentAs(currentMonth), true);
        },
      );
    });

    group('Property 11: Forecast Data Separation', () {
      test(
        'forecasts are stored separately and not mixed with transactions',
        () {
          // **Feature: household-budget-management, Property 11: Forecast Data Separation**
          // **Validates: Requirements 4.2**

          final forecast1 = manager.createForecast(
            period: futureMonth,
            category: 'Groceries',
            amount: 500,
            assumptions: 'Test 1',
          );

          final forecast2 = manager.createForecast(
            period: futureMonth2,
            category: 'Transport',
            amount: 300,
            assumptions: 'Test 2',
          );

          // Verify forecasts are stored separately
          final allForecasts = manager.getAllForecasts();
          expect(allForecasts.length, 2);

          // Verify each forecast maintains its own data
          expect(allForecasts[0].id, forecast1.id);
          expect(allForecasts[1].id, forecast2.id);

          // Verify forecasts don't interfere with each other
          manager.deleteForecast(forecast1.id);
          expect(manager.forecastCount, 1);
          expect(manager.getForecastById(forecast2.id), isNotNull);
        },
      );
    });
  });
}
