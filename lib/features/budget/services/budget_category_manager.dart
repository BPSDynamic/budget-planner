import 'package:budget_planner/features/budget/models/budget_category.dart';
import 'package:budget_planner/features/transactions/models/transaction_model.dart';

class BudgetCategoryManager {
  final List<BudgetCategory> _categories = [];
  final Map<String, List<String>> _categoryTransactions =
      {}; // categoryId -> list of transactionIds

  /// Creates a new budget category
  /// Returns the created category
  BudgetCategory createCategory({
    required String name,
    required String description,
    required double monthlyLimit,
  }) {
    if (monthlyLimit <= 0) {
      throw ArgumentError('Monthly limit must be positive');
    }

    final category = BudgetCategory(
      name: name,
      description: description,
      monthlyLimit: monthlyLimit,
    );

    _categories.add(category);
    _categoryTransactions[category.id] = [];

    return category;
  }

  /// Updates the monthly limit for a category
  /// Recalculates all variances for that category
  void updateCategoryLimit(String categoryId, double newLimit) {
    if (newLimit <= 0) {
      throw ArgumentError('Monthly limit must be positive');
    }

    final categoryIndex =
        _categories.indexWhere((cat) => cat.id == categoryId);
    if (categoryIndex == -1) {
      throw ArgumentError('Category not found');
    }

    final oldCategory = _categories[categoryIndex];
    _categories[categoryIndex] = BudgetCategory(
      id: oldCategory.id,
      name: oldCategory.name,
      description: oldCategory.description,
      monthlyLimit: newLimit,
      createdDate: oldCategory.createdDate,
    );
  }

  /// Calculates variance for a category in a specific period
  /// Formula: actual spending - budget limit
  /// Positive values indicate overspending, negative values indicate underspending
  /// Period format: 'YYYY-MM'
  double calculateVariance(
    String categoryId,
    String period,
    List<Transaction> transactions,
  ) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => throw ArgumentError('Category not found'),
    );

    // Calculate actual spending for this category in the period
    double actualSpending = 0.0;

    for (final transaction in transactions) {
      if (transaction.category == category.name) {
        final transactionMonth =
            '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';

        if (transactionMonth == period &&
            transaction.type == TransactionType.expense) {
          actualSpending += transaction.amount;
        }
      }
    }

    // Variance = actual - budget
    final variance = actualSpending - category.monthlyLimit;
    return double.parse(variance.toStringAsFixed(2));
  }

  /// Gets detailed information about a category
  BudgetCategory? getCategoryDetails(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Assigns a transaction to a category
  void assignTransactionToCategory(String transactionId, String categoryId) {
    if (!_categoryTransactions.containsKey(categoryId)) {
      throw ArgumentError('Category not found');
    }

    final transactions = _categoryTransactions[categoryId]!;
    if (!transactions.contains(transactionId)) {
      transactions.add(transactionId);
    }
  }

  /// Gets all categories
  List<BudgetCategory> getAllCategories() {
    return List.unmodifiable(_categories);
  }

  /// Deletes a category
  bool deleteCategory(String categoryId) {
    final index = _categories.indexWhere((cat) => cat.id == categoryId);
    if (index == -1) {
      return false;
    }

    _categories.removeAt(index);
    _categoryTransactions.remove(categoryId);
    return true;
  }

  /// Gets transactions assigned to a category
  List<String> getTransactionsForCategory(String categoryId) {
    return List.unmodifiable(_categoryTransactions[categoryId] ?? []);
  }

  /// Clears all categories and transactions
  void clear() {
    _categories.clear();
    _categoryTransactions.clear();
  }
}
