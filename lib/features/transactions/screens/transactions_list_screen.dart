import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_planner/features/transactions/models/transaction_model.dart';
import 'package:budget_planner/features/transactions/providers/budget_provider.dart';
import 'package:budget_planner/features/settings/providers/settings_provider.dart';
import 'package:budget_planner/core/theme/app_colors.dart';
import 'add_transaction_screen.dart';

enum TimeFilter { daily, weekly, monthly, yearly }

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  TimeFilter _selectedFilter = TimeFilter.monthly;
  DateTime _selectedDate = DateTime.now();

  List<Transaction> _getFilteredTransactions(List<Transaction> allTransactions) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (_selectedFilter) {
      case TimeFilter.daily:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case TimeFilter.weekly:
        final daysToSubtract = now.weekday - 1;
        startDate = now.subtract(Duration(days: daysToSubtract));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate.add(const Duration(days: 7));
        break;
      case TimeFilter.monthly:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case TimeFilter.yearly:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
    }

    return allTransactions.where((transaction) {
      return transaction.date.isAfter(startDate) &&
          transaction.date.isBefore(endDate);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String _getFilterLabel() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case TimeFilter.daily:
        return 'Today';
      case TimeFilter.weekly:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return 'Week of ${weekStart.year}-${weekStart.month}-${weekStart.day}';
      case TimeFilter.monthly:
        return '${now.year}-${now.month.toString().padLeft(2, '0')}';
      case TimeFilter.yearly:
        return '${now.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFilterLabel(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TimeFilter.values.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            filter.name.toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textLight,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: AppColors.primary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Transactions list
          Expanded(
            child: Consumer2<BudgetProvider, SettingsProvider>(
              builder: (context, budgetProvider, settingsProvider, _) {
                final currency = settingsProvider.currency;
                final filteredTransactions =
                    _getFilteredTransactions(budgetProvider.transactions);

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    final isExpense =
                        transaction.type == TransactionType.expense;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isExpense
                                ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isExpense
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: isExpense
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                        title: Text(
                          transaction.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${isExpense ? '-' : '+'}$currency${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isExpense
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
