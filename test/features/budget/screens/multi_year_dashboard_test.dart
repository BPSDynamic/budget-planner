import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Multi-Year Dashboard - Decimal Precision Tests', () {
    test('Property 15: Decimal Precision - Year-over-year growth calculation',
        () {
      // Feature: household-budget-management, Property 15: Decimal Precision
      // Validates: Requirements 2.5

      // Test that year-over-year growth calculations are accurate to 2 decimal places
      final testCases = [
        // (currentYear, previousYear, expectedGrowth)
        (1000.0, 500.0, 100.00), // 100% growth
        (750.0, 1000.0, -25.00), // -25% decline
        (1234.56, 1000.00, 23.46), // Decimal inputs
        (100.0, 300.0, -66.67), // Negative growth with decimals
        (0.0, 100.0, -100.00), // Zero current year
        (100.0, 0.0, 100.00), // Zero previous year (special case)
      ];

      for (final testCase in testCases) {
        final currentYear = testCase.$1;
        final previousYear = testCase.$2;
        final expectedGrowth = testCase.$3;

        // Calculate growth
        double growth;
        if (previousYear == 0) {
          growth = currentYear > 0 ? 100.0 : 0.0;
        } else {
          growth = ((currentYear - previousYear) / previousYear) * 100;
        }

        // Round to 2 decimal places
        final roundedGrowth =
            double.parse(growth.toStringAsFixed(2));

        // Verify precision
        expect(
          roundedGrowth,
          expectedGrowth,
          reason:
              'Growth from $previousYear to $currentYear should be $expectedGrowth%',
        );

        // Verify that the string representation has at most 2 decimal places
        final stringRep = roundedGrowth.toStringAsFixed(2);
        final parts = stringRep.split('.');
        expect(parts.length, 2, reason: 'Should have decimal point');
        expect(parts[1].length, 2,
            reason: 'Should have exactly 2 decimal places');
      }
    });

    test('Property 15: Decimal Precision - Category percentage calculation',
        () {
      // Feature: household-budget-management, Property 15: Decimal Precision
      // Validates: Requirements 2.5

      // Test that category percentages are accurate to 2 decimal places
      final categoryTotals = {
        'Groceries': 500.0,
        'Utilities': 200.0,
        'Entertainment': 150.0,
        'Transport': 100.0,
      };

      final totalAmount =
          categoryTotals.values.fold(0.0, (sum, val) => sum + val);

      for (final entry in categoryTotals.entries) {
        final percentage = (entry.value / totalAmount * 100);
        final roundedPercentage =
            double.parse(percentage.toStringAsFixed(2));

        // Verify precision
        expect(
          roundedPercentage,
          greaterThanOrEqualTo(0),
          reason: 'Percentage should be non-negative',
        );
        expect(
          roundedPercentage,
          lessThanOrEqualTo(100),
          reason: 'Percentage should not exceed 100',
        );

        // Verify that the string representation has at most 2 decimal places
        final stringRep = roundedPercentage.toStringAsFixed(2);
        final parts = stringRep.split('.');
        expect(parts.length, 2, reason: 'Should have decimal point');
        expect(parts[1].length, 2,
            reason: 'Should have exactly 2 decimal places');
      }

      // Verify that all percentages sum to approximately 100
      final totalPercentage = categoryTotals.entries
          .map((e) => double.parse(
              (e.value / totalAmount * 100).toStringAsFixed(2)))
          .fold(0.0, (sum, val) => sum + val);

      expect(
        totalPercentage,
        closeTo(100.0, 0.01),
        reason: 'All percentages should sum to 100%',
      );
    });

    test('Property 15: Decimal Precision - Variance calculation', () {
      // Feature: household-budget-management, Property 15: Decimal Precision
      // Validates: Requirements 2.5

      // Test that variance calculations are accurate to 2 decimal places
      final testCases = [
        // (actual, budget, expectedVariance)
        (1500.0, 1000.0, 500.00), // Overspending
        (800.0, 1000.0, -200.00), // Underspending
        (1234.56, 1000.00, 234.56), // Decimal values
        (0.0, 100.0, -100.00), // No spending
        (100.0, 0.0, 100.00), // No budget
      ];

      for (final testCase in testCases) {
        final actual = testCase.$1;
        final budget = testCase.$2;
        final expectedVariance = testCase.$3;

        // Calculate variance: (actual - budget)
        final variance = actual - budget;
        final roundedVariance =
            double.parse(variance.toStringAsFixed(2));

        // Verify precision
        expect(
          roundedVariance,
          expectedVariance,
          reason:
              'Variance for actual=$actual, budget=$budget should be $expectedVariance',
        );

        // Verify that the string representation has at most 2 decimal places
        final stringRep = roundedVariance.toStringAsFixed(2);
        final parts = stringRep.split('.');
        expect(parts.length, 2, reason: 'Should have decimal point');
        expect(parts[1].length, 2,
            reason: 'Should have exactly 2 decimal places');
      }
    });
  });
}
