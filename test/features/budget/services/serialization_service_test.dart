import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/features/budget/services/serialization_service.dart';
import 'package:budget_planner/features/budget/models/budget_category.dart';
import 'package:budget_planner/features/budget/models/forecast.dart';

void main() {
  group('SerializationService', () {
    late SerializationService service;

    setUp(() {
      service = SerializationService();
    });

    group('serializeBudgetData', () {
      test('serializes empty list to empty JSON array', () {
        final json = service.serializeBudgetData([]);
        expect(json, '[]');
      });

      test('serializes single category to JSON', () {
        final category = BudgetCategory(
          name: 'Groceries',
          description: 'Food and groceries',
          monthlyLimit: 500,
        );

        final json = service.serializeBudgetData([category]);

        expect(json, contains('Groceries'));
        expect(json, contains('Food and groceries'));
        expect(json, contains('500'));
      });

      test('serializes multiple categories to JSON', () {
        final categories = [
          BudgetCategory(
            name: 'Groceries',
            description: 'Food',
            monthlyLimit: 500,
          ),
          BudgetCategory(
            name: 'Transport',
            description: 'Gas and transit',
            monthlyLimit: 300,
          ),
        ];

        final json = service.serializeBudgetData(categories);

        expect(json, contains('Groceries'));
        expect(json, contains('Transport'));
      });

      test('includes all required fields in serialization', () {
        final category = BudgetCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        final json = service.serializeBudgetData([category]);

        expect(json, contains('"id"'));
        expect(json, contains('"name"'));
        expect(json, contains('"description"'));
        expect(json, contains('"monthlyLimit"'));
        expect(json, contains('"createdDate"'));
      });
    });

    group('deserializeBudgetData', () {
      test('deserializes empty JSON array', () {
        final categories = service.deserializeBudgetData('[]');
        expect(categories, isEmpty);
      });

      test('deserializes single category from JSON', () {
        final original = BudgetCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        final json = service.serializeBudgetData([original]);
        final deserialized = service.deserializeBudgetData(json);

        expect(deserialized.length, 1);
        expect(deserialized[0].name, 'Groceries');
        expect(deserialized[0].description, 'Food');
        expect(deserialized[0].monthlyLimit, 500);
      });

      test('deserializes multiple categories from JSON', () {
        final originals = [
          BudgetCategory(
            name: 'Groceries',
            description: 'Food',
            monthlyLimit: 500,
          ),
          BudgetCategory(
            name: 'Transport',
            description: 'Gas',
            monthlyLimit: 300,
          ),
        ];

        final json = service.serializeBudgetData(originals);
        final deserialized = service.deserializeBudgetData(json);

        expect(deserialized.length, 2);
        expect(deserialized[0].name, 'Groceries');
        expect(deserialized[1].name, 'Transport');
      });

      test('throws error for invalid JSON', () {
        expect(
          () => service.deserializeBudgetData('invalid json'),
          throwsFormatException,
        );
      });

      test('throws error for missing required fields', () {
        final invalidJson = '[{"name": "Groceries"}]';

        expect(
          () => service.deserializeBudgetData(invalidJson),
          throwsArgumentError,
        );
      });
    });

    group('serializeForecasts', () {
      test('serializes empty list to empty JSON array', () {
        final json = service.serializeForecasts([]);
        expect(json, '[]');
      });

      test('serializes single forecast to JSON', () {
        final now = DateTime.now();
        final futureMonth =
            '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';

        final forecast = Forecast(
          period: futureMonth,
          category: 'Groceries',
          projectedAmount: 500,
          assumptions: 'Based on historical data',
        );

        final json = service.serializeForecasts([forecast]);

        expect(json, contains('Groceries'));
        expect(json, contains('Based on historical data'));
        expect(json, contains('500'));
      });

      test('includes all required fields in serialization', () {
        final now = DateTime.now();
        final futureMonth =
            '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';

        final forecast = Forecast(
          period: futureMonth,
          category: 'Groceries',
          projectedAmount: 500,
          assumptions: 'Test',
        );

        final json = service.serializeForecasts([forecast]);

        expect(json, contains('"id"'));
        expect(json, contains('"period"'));
        expect(json, contains('"category"'));
        expect(json, contains('"projectedAmount"'));
        expect(json, contains('"assumptions"'));
        expect(json, contains('"createdDate"'));
      });
    });

    group('deserializeForecasts', () {
      test('deserializes empty JSON array', () {
        final forecasts = service.deserializeForecasts('[]');
        expect(forecasts, isEmpty);
      });

      test('deserializes single forecast from JSON', () {
        final now = DateTime.now();
        final futureMonth =
            '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';

        final original = Forecast(
          period: futureMonth,
          category: 'Groceries',
          projectedAmount: 500,
          assumptions: 'Test',
        );

        final json = service.serializeForecasts([original]);
        final deserialized = service.deserializeForecasts(json);

        expect(deserialized.length, 1);
        expect(deserialized[0].category, 'Groceries');
        expect(deserialized[0].projectedAmount, 500);
      });

      test('throws error for invalid JSON', () {
        expect(
          () => service.deserializeForecasts('invalid json'),
          throwsFormatException,
        );
      });

      test('throws error for missing required fields', () {
        final invalidJson = '[{"category": "Groceries"}]';

        expect(
          () => service.deserializeForecasts(invalidJson),
          throwsArgumentError,
        );
      });
    });

    group('validateDeserializedData', () {
      test('throws error if data is not a map', () {
        expect(
          () => service.validateDeserializedData('not a map'),
          throwsArgumentError,
        );

        expect(
          () => service.validateDeserializedData([]),
          throwsArgumentError,
        );
      });

      test('throws error for missing id field', () {
        expect(
          () => service.validateDeserializedData({
            'createdDate': DateTime.now().toIso8601String(),
          }),
          throwsArgumentError,
        );
      });

      test('throws error for missing createdDate field', () {
        expect(
          () => service.validateDeserializedData({
            'id': 'test-id',
          }),
          throwsArgumentError,
        );
      });

      test('throws error if id is not a string', () {
        expect(
          () => service.validateDeserializedData({
            'id': 123,
            'createdDate': DateTime.now().toIso8601String(),
          }),
          throwsArgumentError,
        );
      });

      test('throws error if createdDate is not a string', () {
        expect(
          () => service.validateDeserializedData({
            'id': 'test-id',
            'createdDate': DateTime.now(),
          }),
          throwsArgumentError,
        );
      });

      test('throws error if createdDate is not valid ISO8601', () {
        expect(
          () => service.validateDeserializedData({
            'id': 'test-id',
            'createdDate': 'not-a-date',
          }),
          throwsArgumentError,
        );
      });

      test('throws error if monthlyLimit is not a number', () {
        expect(
          () => service.validateDeserializedData({
            'id': 'test-id',
            'createdDate': DateTime.now().toIso8601String(),
            'monthlyLimit': 'not-a-number',
          }),
          throwsArgumentError,
        );
      });

      test('throws error if monthlyLimit is not positive', () {
        expect(
          () => service.validateDeserializedData({
            'id': 'test-id',
            'createdDate': DateTime.now().toIso8601String(),
            'monthlyLimit': 0,
          }),
          throwsArgumentError,
        );
      });

      test('throws error if projectedAmount is not a number', () {
        expect(
          () => service.validateDeserializedData({
            'id': 'test-id',
            'createdDate': DateTime.now().toIso8601String(),
            'projectedAmount': 'not-a-number',
          }),
          throwsArgumentError,
        );
      });

      test('throws error if projectedAmount is not positive', () {
        expect(
          () => service.validateDeserializedData({
            'id': 'test-id',
            'createdDate': DateTime.now().toIso8601String(),
            'projectedAmount': -100,
          }),
          throwsArgumentError,
        );
      });

      test('accepts valid category data', () {
        // Should not throw
        service.validateDeserializedData({
          'id': 'test-id',
          'name': 'Groceries',
          'description': 'Food',
          'monthlyLimit': 500,
          'createdDate': DateTime.now().toIso8601String(),
        });
      });

      test('accepts valid forecast data', () {
        // Should not throw
        service.validateDeserializedData({
          'id': 'test-id',
          'period': '2025-06',
          'category': 'Groceries',
          'projectedAmount': 500,
          'assumptions': 'Test',
          'createdDate': DateTime.now().toIso8601String(),
        });
      });
    });

    // Property-Based Tests

    group('Property 10: Serialization Round Trip', () {
      test(
        'budget data serialized and deserialized equals original',
        () {
          // **Feature: household-budget-management, Property 10: Serialization Round Trip**
          // **Validates: Requirements 5.5**

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
          final json = service.serializeBudgetData(original);

          // Deserialize
          final deserialized = service.deserializeBudgetData(json);

          // Verify round trip
          expect(deserialized.length, original.length);
          for (int i = 0; i < original.length; i++) {
            expect(deserialized[i].id, original[i].id);
            expect(deserialized[i].name, original[i].name);
            expect(deserialized[i].description, original[i].description);
            expect(deserialized[i].monthlyLimit, original[i].monthlyLimit);
            expect(deserialized[i].createdDate, original[i].createdDate);
          }
        },
      );

      test(
        'forecast data serialized and deserialized equals original',
        () {
          // **Feature: household-budget-management, Property 10: Serialization Round Trip**
          // **Validates: Requirements 5.5**

          final now = DateTime.now();
          final futureMonth =
              '${now.year}-${(now.month + 2).toString().padLeft(2, '0')}';
          final futureMonth2 =
              '${now.year}-${(now.month + 3).toString().padLeft(2, '0')}';

          final original = [
            Forecast(
              period: futureMonth,
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
          final json = service.serializeForecasts(original);

          // Deserialize
          final deserialized = service.deserializeForecasts(json);

          // Verify round trip
          expect(deserialized.length, original.length);
          for (int i = 0; i < original.length; i++) {
            expect(deserialized[i].id, original[i].id);
            expect(deserialized[i].period, original[i].period);
            expect(deserialized[i].category, original[i].category);
            expect(deserialized[i].projectedAmount, original[i].projectedAmount);
            expect(deserialized[i].assumptions, original[i].assumptions);
            expect(deserialized[i].createdDate, original[i].createdDate);
          }
        },
      );
    });
  });
}
