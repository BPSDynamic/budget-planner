import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transactions/providers/budget_provider.dart';
import '../../transactions/widgets/transaction_card.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/balance_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer2<BudgetProvider, SettingsProvider>(
        builder: (context, budgetProvider, settingsProvider, child) {
          final currency = settingsProvider.currency;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: BalanceCard(
                  balance: budgetProvider.balance,
                  income: budgetProvider.totalIncome,
                  expense: budgetProvider.totalExpense,
                  currency: currency,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              if (budgetProvider.transactions.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final transaction = budgetProvider.transactions[index];
                      return TransactionCard(
                        transaction: transaction,
                        currency: currency,
                        onTap: () {
                          // TODO: Show details or edit
                        },
                      );
                    },
                    childCount: budgetProvider.transactions.length,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
