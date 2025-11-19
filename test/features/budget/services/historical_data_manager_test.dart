import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/features/budget/services/historical_data_manager.dart';
import 'package:budget_planner/features/transactions/models/transaction_model.dart';

void main() {
  group('HistoricalDataManager', () {
    late HistoricalDataManager manager;

    setUp(() {
      manager = HistoricalDataManager();
    });

    group('Property 1: Historical Data Range Validation', () {
      test(
        '**Feature: household-budget-management, Property 1: Historical Data Range Validation** - '
        'Validates transactions within 5-year window',
        () {
          // Arrange
          final now = DateTime.now();
          final withinWindow = DateTime(now.year - 2, 6, 15);
          final atBoundary = DateTime(now.year - 5, now.month, now.day);
          final justOutside = DateTime(now.year - 5, now.month, now.day).subtract(const Duration(days: 1));

          // Act & Assert
          expect(manager.validateTransactionDate(withinWindow), isTrue);
          expect(manager.validateTransactionDate(atBoundary), isTrue);
          expect(manager.validateTransactionDate(justOutside), isFalse);
        },
      );

      test(
        '**Feature: household-budget-management, Property 1: Historical Data Range Validation** - '
        'Rejects transactions outside 5-year window',
        () {
          // Arrange
          final now = DateTime.now();
          final tooOld = DateTime(now.year - 6, 1, 1);
          final future = now.add(const Duration(days: 1));

          // Act & Assert
          expect(manager.validateTransactionDate(tooOld), isFalse);
          expect(manager.validateTransactionDate(future), isFalse);
        },
      );

      test(
        '**Feature: household-budget-management, Property 1: Historical Data Range Validation** - '
        'Accepts transactions from various years within window',
        () {
          // Arrange
          final now = DateTime.now();
          final testDates = [
            DateTime(now.year, 1, 1), // Current year
            DateTime(now.year - 1, 6, 15), // 1 year ago
            DateTime(now.year - 2, 12, 31), // 2 years ago
            DateTime(now.year - 3, 3, 20), // 3 years ago
            DateTime(now.year - 4, 9, 10), // 4 years ago
          ];

          // Act & Assert
          for (final date in testDates) {
            expect(manager.validateTransactionDate(date), isTrue,
                reason: 'Date $date should be within 5-year window');
          }
        },
      );
    });

    group('Property 2: Date Range Filtering Completeness', () {
      test(
        '**Feature: household-budget-management, Property 2: Date Range Filtering Completeness** - '
        'Returns only transactions within specified range',
        () {
          // Arrange
          final now = DateTime.now();
          final transactions = [
            Transaction(
              title: 'Before range',
              amount: 100,
              date: DateTime(now.year, 1, 1),
              type: TransactionType.expense,
              category: 'test',
            ),
            Transaction(
              title: 'In range 1',
              amount: 200,
              date: DateTime(now.year, 6, 15),
              type: TransactionType.expense,
              category: 'test',
            ),
            Transaction(
              title: 'In range 2',
              amount: 150,
              date: DateTime(now.year, 7, 20),
              type: TransactionType.income,
              category: 'test',
            ),
            Transaction(
              title: 'After range',
              amount: 300,
              date: DateTime(now.year, 12, 31),
              type: TransactionType.expense,
              category: 'test',
            ),
          ];

          final startDate = DateTime(now.year, 6, 1);
          final endDate = DateTime(now.year, 7, 31);

          // Act
          final result = manager.getTransactionsByDateRange(
            transactions,
            startDate,
            endDate,
          );

          // Assert
          expect(result.length, equals(2));
          expect(result.every((t) => t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate)), isTrue);
          expect(result.every((t) => t.date.isBefore(endDate.add(const Duration(days: 1))) || 
              t.date.isAtSameMomentAs(endDate)), isTrue);
        },
      );

      test(
        '**Feature: household-budget-management, Property 2: Date Range Filtering Completeness** - '
        'Excludes all transactions outside range',
        () {
          // Arrange
          final now = DateTime.now();
          final transactions = [
            Transaction(
              title: 'Outside 1',
              amount: 100,
              date: DateTime(now.year - 1, 12, 31),
              type: TransactionType.expense,
              category: 'test',
            ),
            Transaction(
              title: 'Outside 2',
              amount: 200,
              date: DateTime(now.year + 1, 1, 1),
              type: TransactionType.expense,
              category: 'test',
            ),
          ];

          final startDate = DateTime(now.year, 6, 1);
          final endDate = DateTime(now.year, 6, 30);

          // Act
          final result = manager.getTransactionsByDateRange(
            transactions,
            startDate,
            endDate,
          );

          // Assert
          expect(result.isEmpty, isTrue);
        },
      );

      test(
        '**Feature: household-budget-management, Property 2: Date Range Filtering Completeness** - '
        'Includes boundary dates',
        () {
          // Arrange
          final now = DateTime.now();
          final startDate = DateTime(now.year, 6, 1);
          final endDate = DateTime(now.year, 6, 30);

          final transactions = [
            Transaction(
              title: 'Start boundary',
              amount: 100,
              date: startDate,
              type: TransactionType.expense,
              category: 'test',
            ),
            Transaction(
              title: 'End boundary',
              amount: 200,
              date: endDate,
              type: TransactionType.expense,
              category: 'test',
            ),
          ];

          // Act
          final result = manager.getTransactionsByDateRange(
            transactions,
            startDate,
            endDate,
          );

          // Assert
          expect(result.length, equals(2));
        },
      );
    });

    group('getTransactionsForYear', () {
      test('Returns all transactions for specified year', () {
        // Arrange
        final now = DateTime.now();
        final year = now.year;
        final transactions = [
          Transaction(
            title: 'Jan transaction',
            amount: 100,
            date: DateTime(year, 1, 15),
            type: TransactionType.expense,
            category: 'test',
          ),
          Transaction(
            title: 'Dec transaction',
            amount: 200,
            date: DateTime(year, 12, 25),
            type: TransactionType.income,
            category: 'test',
          ),
          Transaction(
            title: 'Other year',
            amount: 150,
            date: DateTime(year - 1, 6, 15),
            type: TransactionType.expense,
            category: 'test',
          ),
        ];

        // Act
        final result = manager.getTransactionsForYear(transactions, year);

        // Assert
        expect(result.length, equals(2));
        expect(result.every((t) => t.date.year == year), isTrue);
      });
    });

    group('getTransactionsForMonth', () {
      test('Returns all transactions for specified month and year', () {
        // Arrange
        final now = DateTime.now();
        final year = now.year;
        const month = 6;
        final transactions = [
          Transaction(
            title: 'June 1',
            amount: 100,
            date: DateTime(year, month, 1),
            type: TransactionType.expense,
            category: 'test',
          ),
          Transaction(
            title: 'June 30',
            amount: 200,
            date: DateTime(year, month, 30),
            type: TransactionType.income,
            category: 'test',
          ),
          Transaction(
            title: 'July transaction',
            amount: 150,
            date: DateTime(year, month + 1, 15),
            type: TransactionType.expense,
            category: 'test',
          ),
        ];

        // Act
        final result = manager.getTransactionsForMonth(transactions, year, month);

        // Assert
        expect(result.length, equals(2));
        expect(result.every((t) => t.date.year == year && t.date.month == month), isTrue);
      });

      test('Handles December correctly', () {
        // Arrange
        final now = DateTime.now();
        final year = now.year;
        const month = 12;
        final transactions = [
          Transaction(
            title: 'Dec 1',
            amount: 100,
            date: DateTime(year, month, 1),
            type: TransactionType.expense,
            category: 'test',
          ),
          Transaction(
            title: 'Dec 31',
            amount: 200,
            date: DateTime(year, month, 31),
            type: TransactionType.income,
            category: 'test',
          ),
          Transaction(
            title: 'Jan next year',
            amount: 150,
            date: DateTime(year + 1, 1, 1),
            type: TransactionType.expense,
            category: 'test',
          ),
        ];

        // Act
        final result = manager.getTransactionsForMonth(transactions, year, month);

        // Assert
        expect(result.length, equals(2));
        expect(result.every((t) => t.date.year == year && t.date.month == month), isTrue);
      });
    });
  });
}
