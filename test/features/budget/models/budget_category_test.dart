import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/features/budget/models/budget_category.dart';

void main() {
  group('BudgetCategory', () {
    test(
      '**Feature: household-budget-management, Property 7: Budget Category Persistence** - '
      'Serialization round trip preserves all fields',
      () {
        // Arrange
        final original = BudgetCategory(
          name: 'Groceries',
          description: 'Weekly grocery shopping',
          monthlyLimit: 500.0,
        );

        // Act
        final map = original.toMap();
        final restored = BudgetCategory.fromMap(map);

        // Assert
        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.description, equals(original.description));
        expect(restored.monthlyLimit, equals(original.monthlyLimit));
        expect(restored.createdDate, equals(original.createdDate));
        expect(restored, equals(original));
      },
    );

    test(
      '**Feature: household-budget-management, Property 7: Budget Category Persistence** - '
      'Multiple round trips preserve data integrity',
      () {
        // Arrange
        final original = BudgetCategory(
          name: 'Utilities',
          description: 'Monthly utility bills',
          monthlyLimit: 200.0,
        );

        // Act - perform multiple round trips
        var current = original;
        for (int i = 0; i < 5; i++) {
          final map = current.toMap();
          current = BudgetCategory.fromMap(map);
        }

        // Assert
        expect(current, equals(original));
      },
    );

    test(
      '**Feature: household-budget-management, Property 7: Budget Category Persistence** - '
      'Preserves custom ID and creation date',
      () {
        // Arrange
        final customId = 'custom-id-123';
        final customDate = DateTime(2024, 1, 15, 10, 30);
        final original = BudgetCategory(
          id: customId,
          name: 'Entertainment',
          description: 'Movies and games',
          monthlyLimit: 100.0,
          createdDate: customDate,
        );

        // Act
        final map = original.toMap();
        final restored = BudgetCategory.fromMap(map);

        // Assert
        expect(restored.id, equals(customId));
        expect(restored.createdDate, equals(customDate));
        expect(restored, equals(original));
      },
    );

    test(
      '**Feature: household-budget-management, Property 7: Budget Category Persistence** - '
      'Handles various monthly limit values',
      () {
        // Test with different limit values
        final testLimits = [0.0, 1.0, 100.50, 1000.99, 9999.99];

        for (final limit in testLimits) {
          // Arrange
          final original = BudgetCategory(
            name: 'Test Category',
            description: 'Test',
            monthlyLimit: limit,
          );

          // Act
          final map = original.toMap();
          final restored = BudgetCategory.fromMap(map);

          // Assert
          expect(restored.monthlyLimit, equals(limit));
          expect(restored, equals(original));
        }
      },
    );
  });
}
