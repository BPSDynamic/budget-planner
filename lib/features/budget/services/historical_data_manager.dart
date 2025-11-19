import 'package:budget_planner/features/transactions/models/transaction_model.dart';

class HistoricalDataManager {
  static const int _maxHistoricalYears = 5;

  /// Validates that a transaction date falls within the 5-year historical window
  /// Returns true if the date is within the allowed range, false otherwise
  bool validateTransactionDate(DateTime date) {
    final now = DateTime.now();
    final fiveYearsAgo = DateTime(now.year - _maxHistoricalYears, now.month, now.day);
    
    // Date must be after or equal to 5 years ago, and not in the future
    return !date.isBefore(fiveYearsAgo) && !date.isAfter(now);
  }

  /// Retrieves transactions within a specified date range
  /// Returns only transactions where the date falls within [startDate] and [endDate]
  List<Transaction> getTransactionsByDateRange(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return transactions.where((transaction) {
      // Include transactions on the start date and end date
      return !transaction.date.isBefore(startDate) &&
          !transaction.date.isAfter(endDate);
    }).toList();
  }

  /// Retrieves all transactions for a specific year
  List<Transaction> getTransactionsForYear(
    List<Transaction> transactions,
    int year,
  ) {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);
    return getTransactionsByDateRange(transactions, startDate, endDate);
  }

  /// Retrieves all transactions for a specific month and year
  List<Transaction> getTransactionsForMonth(
    List<Transaction> transactions,
    int year,
    int month,
  ) {
    final startDate = DateTime(year, month, 1);
    final endDate = month == 12
        ? DateTime(year + 1, 1, 1).subtract(const Duration(days: 1))
        : DateTime(year, month + 1, 1).subtract(const Duration(days: 1));
    return getTransactionsByDateRange(transactions, startDate, endDate);
  }
}
