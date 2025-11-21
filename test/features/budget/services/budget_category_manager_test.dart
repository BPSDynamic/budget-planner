import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/features/budget/services/budget_category_manager.dart';
import 'package:budget_planner/features/transactions/models/transaction_model.dart';

void main() {
  group('BudgetCategoryManager', () {
    late BudgetCategoryManager manager;

    setUp(() {
      manager = BudgetCategoryManager();
    });

    group('createCategory', () {
      test('creates a category with valid parameters', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food and groceries',
          monthlyLimit: 500,
        );

        expect(category.name, 'Groceries');
        expect(category.description, 'Food and groceries');
        expect(category.monthlyLimit, 500);
        expect(category.id, isNotEmpty);
      });

      test('throws error for non-positive monthly limit', () {
        expect(
          () => manager.createCategory(
            name: 'Groceries',
            description: 'Food',
            monthlyLimit: 0,
          ),
          throwsArgumentError,
        );

        expect(
          () => manager.createCategory(
            name: 'Groceries',
            description: 'Food',
            monthlyLimit: -100,
          ),
          throwsArgumentError,
        );
      });

      test('adds category to internal list', () {
        manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        final categories = manager.getAllCategories();
        expect(categories.length, 1);
        expect(categories[0].name, 'Groceries');
      });
    });

    group('updateCategoryLimit', () {
      test('updates category limit successfully', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        manager.updateCategoryLimit(category.id, 600);

        final updated = manager.getCategoryDetails(category.id);
        expect(updated!.monthlyLimit, 600);
      });

      test('throws error for non-positive limit', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        expect(
          () => manager.updateCategoryLimit(category.id, 0),
          throwsArgumentError,
        );
      });

      test('throws error for non-existent category', () {
        expect(
          () => manager.updateCategoryLimit('non-existent', 600),
          throwsArgumentError,
        );
      });

      test('preserves other category properties', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        manager.updateCategoryLimit(category.id, 600);

        final updated = manager.getCategoryDetails(category.id);
        expect(updated!.name, 'Groceries');
        expect(updated.description, 'Food');
        expect(updated.id, category.id);
      });
    });

    group('calculateVariance', () {
      test('calculates variance correctly for expenses', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        final transactions = [
          Transaction(
            title: 'Groceries 1',
            amount: 100,
            date: DateTime(2024, 1, 5),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
          Transaction(
            title: 'Groceries 2',
            amount: 150,
            date: DateTime(2024, 1, 15),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
        ];

        final variance = manager.calculateVariance(
          category.id,
          '2024-01',
          transactions,
        );

        // Variance = 250 - 500 = -250 (underspending)
        expect(variance, -250.0);
      });

      test('returns positive variance for overspending', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 200,
        );

        final transactions = [
          Transaction(
            title: 'Groceries 1',
            amount: 150,
            date: DateTime(2024, 1, 5),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
          Transaction(
            title: 'Groceries 2',
            amount: 100,
            date: DateTime(2024, 1, 15),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
        ];

        final variance = manager.calculateVariance(
          category.id,
          '2024-01',
          transactions,
        );

        // Variance = 250 - 200 = 50 (overspending)
        expect(variance, 50.0);
      });

      test('returns zero variance for exact budget match', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 250,
        );

        final transactions = [
          Transaction(
            title: 'Groceries 1',
            amount: 100,
            date: DateTime(2024, 1, 5),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
          Transaction(
            title: 'Groceries 2',
            amount: 150,
            date: DateTime(2024, 1, 15),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
        ];

        final variance = manager.calculateVariance(
          category.id,
          '2024-01',
          transactions,
        );

        expect(variance, 0.0);
      });

      test('ignores income transactions', () {
        final category = manager.createCategory(
          name: 'Salary',
          description: 'Income',
          monthlyLimit: 5000,
        );

        final transactions = [
          Transaction(
            title: 'Salary',
            amount: 5000,
            date: DateTime(2024, 1, 1),
            type: TransactionType.income,
            category: 'Salary',
          ),
        ];

        final variance = manager.calculateVariance(
          category.id,
          '2024-01',
          transactions,
        );

        // Should be -5000 (no expenses, so 0 - 5000)
        expect(variance, -5000.0);
      });

      test('filters by period correctly', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        final transactions = [
          Transaction(
            title: 'Groceries Jan',
            amount: 100,
            date: DateTime(2024, 1, 5),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
          Transaction(
            title: 'Groceries Feb',
            amount: 200,
            date: DateTime(2024, 2, 5),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
        ];

        final januaryVariance = manager.calculateVariance(
          category.id,
          '2024-01',
          transactions,
        );

        final februaryVariance = manager.calculateVariance(
          category.id,
          '2024-02',
          transactions,
        );

        expect(januaryVariance, -400.0);
        expect(februaryVariance, -300.0);
      });

      test('returns variance accurate to two decimal places', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        final transactions = [
          Transaction(
            title: 'Groceries',
            amount: 333.33,
            date: DateTime(2024, 1, 5),
            type: TransactionType.expense,
            category: 'Groceries',
          ),
        ];

        final variance = manager.calculateVariance(
          category.id,
          '2024-01',
          transactions,
        );

        // Variance = 333.33 - 500 = -166.67
        expect(variance, -166.67);
      });

      test('throws error for non-existent category', () {
        expect(
          () => manager.calculateVariance('non-existent', '2024-01', []),
          throwsArgumentError,
        );
      });
    });

    group('getCategoryDetails', () {
      test('returns category details for existing category', () {
        final created = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        final details = manager.getCategoryDetails(created.id);

        expect(details, isNotNull);
        expect(details!.name, 'Groceries');
        expect(details.monthlyLimit, 500);
      });

      test('returns null for non-existent category', () {
        final details = manager.getCategoryDetails('non-existent');
        expect(details, isNull);
      });
    });

    group('assignTransactionToCategory', () {
      test('assigns transaction to category', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        manager.assignTransactionToCategory('txn-1', category.id);

        final transactions = manager.getTransactionsForCategory(category.id);
        expect(transactions, contains('txn-1'));
      });

      test('does not add duplicate transactions', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        manager.assignTransactionToCategory('txn-1', category.id);
        manager.assignTransactionToCategory('txn-1', category.id);

        final transactions = manager.getTransactionsForCategory(category.id);
        expect(transactions.length, 1);
      });

      test('throws error for non-existent category', () {
        expect(
          () => manager.assignTransactionToCategory('txn-1', 'non-existent'),
          throwsArgumentError,
        );
      });
    });

    group('getAllCategories', () {
      test('returns empty list initially', () {
        final categories = manager.getAllCategories();
        expect(categories, isEmpty);
      });

      test('returns all created categories', () {
        manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );
        manager.createCategory(
          name: 'Transport',
          description: 'Gas and transit',
          monthlyLimit: 300,
        );

        final categories = manager.getAllCategories();
        expect(categories.length, 2);
      });

      test('returns unmodifiable list', () {
        manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        final categories = manager.getAllCategories();
        expect(
          () => categories.add(manager.createCategory(
            name: 'Transport',
            description: 'Gas',
            monthlyLimit: 300,
          )),
          throwsUnsupportedError,
        );
      });
    });

    group('deleteCategory', () {
      test('deletes category successfully', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        final deleted = manager.deleteCategory(category.id);

        expect(deleted, true);
        expect(manager.getAllCategories(), isEmpty);
      });

      test('returns false for non-existent category', () {
        final deleted = manager.deleteCategory('non-existent');
        expect(deleted, false);
      });

      test('removes associated transactions', () {
        final category = manager.createCategory(
          name: 'Groceries',
          description: 'Food',
          monthlyLimit: 500,
        );

        manager.assignTransactionToCategory('txn-1', category.id);
        manager.deleteCategory(category.id);

        final transactions = manager.getTransactionsForCategory(category.id);
        expect(transactions, isEmpty);
      });
    });

    // Property-Based Tests

    group('Property 5: Budget Variance Calculation', () {
      test(
        'variance equals actual spending minus budget limit',
        () {
          // **Feature: household-budget-management, Property 5: Budget Variance Calculation**
          // **Validates: Requirements 3.5**

          final category = manager.createCategory(
            name: 'Groceries',
            description: 'Food',
            monthlyLimit: 500,
          );

          final transactions = [
            Transaction(
              title: 'Groceries 1',
              amount: 150,
              date: DateTime(2024, 1, 5),
              type: TransactionType.expense,
              category: 'Groceries',
            ),
            Transaction(
              title: 'Groceries 2',
              amount: 200,
              date: DateTime(2024, 1, 15),
              type: TransactionType.expense,
              category: 'Groceries',
            ),
          ];

          final variance = manager.calculateVariance(
            category.id,
            '2024-01',
            transactions,
          );

          // Variance = (150 + 200) - 500 = -150
          expect(variance, -150.0);

          // Verify formula: actual - budget
          final actualSpending = 150 + 200;
          final expectedVariance = actualSpending - 500;
          expect(variance, expectedVariance);
        },
      );
    });

    group('Property 12: Category Variance Recalculation', () {
      test(
        'variance recalculates correctly after limit update',
        () {
          // **Feature: household-budget-management, Property 12: Category Variance Recalculation**
          // **Validates: Requirements 3.4**

          final category = manager.createCategory(
            name: 'Groceries',
            description: 'Food',
            monthlyLimit: 500,
          );

          final transactions = [
            Transaction(
              title: 'Groceries',
              amount: 300,
              date: DateTime(2024, 1, 5),
              type: TransactionType.expense,
              category: 'Groceries',
            ),
          ];

          // Initial variance
          final variance1 = manager.calculateVariance(
            category.id,
            '2024-01',
            transactions,
          );
          expect(variance1, -200.0); // 300 - 500

          // Update limit
          manager.updateCategoryLimit(category.id, 250);

          // Recalculated variance
          final variance2 = manager.calculateVariance(
            category.id,
            '2024-01',
            transactions,
          );
          expect(variance2, 50.0); // 300 - 250

          // Verify variance changed
          expect(variance2, isNot(variance1));
        },
      );
    });
  });
}
