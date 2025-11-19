import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/features/budget/models/forecast.dart';

void main() {
  group('Forecast', () {
    test(
      '**Feature: household-budget-management, Property 9: Forecast Persistence** - '
      'Serialization round trip preserves all fields',
      () {
        // Arrange
        final original = Forecast(
          period: '2025-01',
          category: 'Groceries',
          projectedAmount: 500.0,
          assumptions: 'Based on last 3 months average',
        );

        // Act
        final map = original.toMap();
        final restored = Forecast.fromMap(map);

        // Assert
        expect(restored.id, equals(original.id));
        expect(restored.period, equals(original.period));
        expect(restored.category, equals(original.category));
        expect(restored.projectedAmount, equals(original.projectedAmount));
        expect(restored.assumptions, equals(original.assumptions));
        expect(restored.createdDate, equals(original.createdDate));
        expect(restored, equals(original));
      },
    );

    test(
      '**Feature: household-budget-management, Property 9: Forecast Persistence** - '
      'Multiple round trips preserve data integrity',
      () {
        // Arrange
        final original = Forecast(
          period: '2025-02',
          category: 'Utilities',
          projectedAmount: 200.0,
          assumptions: 'Winter heating costs included',
        );

        // Act - perform multiple round trips
        var current = original;
        for (int i = 0; i < 5; i++) {
          final map = current.toMap();
          current = Forecast.fromMap(map);
        }

        // Assert
        expect(current, equals(original));
      },
    );

    test(
      '**Feature: household-budget-management, Property 9: Forecast Persistence** - '
      'Preserves custom ID and creation date',
      () {
        // Arrange
        final customId = 'forecast-id-456';
        final customDate = DateTime(2024, 6, 20, 14, 45);
        final original = Forecast(
          id: customId,
          period: '2025-03',
          category: 'Entertainment',
          projectedAmount: 150.0,
          assumptions: 'Seasonal increase expected',
          createdDate: customDate,
        );

        // Act
        final map = original.toMap();
        final restored = Forecast.fromMap(map);

        // Assert
        expect(restored.id, equals(customId));
        expect(restored.createdDate, equals(customDate));
        expect(restored, equals(original));
      },
    );

    test(
      '**Feature: household-budget-management, Property 9: Forecast Persistence** - '
      'Handles various projected amount values',
      () {
        // Test with different amount values
        final testAmounts = [0.0, 1.0, 100.50, 1000.99, 9999.99];

        for (final amount in testAmounts) {
          // Arrange
          final original = Forecast(
            period: '2025-04',
            category: 'Test',
            projectedAmount: amount,
            assumptions: 'Test assumption',
          );

          // Act
          final map = original.toMap();
          final restored = Forecast.fromMap(map);

          // Assert
          expect(restored.projectedAmount, equals(amount));
          expect(restored, equals(original));
        }
      },
    );

    test(
      '**Feature: household-budget-management, Property 9: Forecast Persistence** - '
      'Handles various period formats',
      () {
        // Test with different period formats (YYYY-MM)
        final testPeriods = ['2024-01', '2025-12', '2026-06', '2030-03'];

        for (final period in testPeriods) {
          // Arrange
          final original = Forecast(
            period: period,
            category: 'Test',
            projectedAmount: 500.0,
            assumptions: 'Test',
          );

          // Act
          final map = original.toMap();
          final restored = Forecast.fromMap(map);

          // Assert
          expect(restored.period, equals(period));
          expect(restored, equals(original));
        }
      },
    );

    test(
      '**Feature: household-budget-management, Property 9: Forecast Persistence** - '
      'Handles long assumption strings',
      () {
        // Arrange
        final longAssumption =
            'Based on historical data from the past 12 months, '
            'accounting for seasonal variations and expected market changes. '
            'This forecast assumes stable employment and no major life changes.';
        final original = Forecast(
          period: '2025-05',
          category: 'Groceries',
          projectedAmount: 550.0,
          assumptions: longAssumption,
        );

        // Act
        final map = original.toMap();
        final restored = Forecast.fromMap(map);

        // Assert
        expect(restored.assumptions, equals(longAssumption));
        expect(restored, equals(original));
      },
    );
  });
}
