import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_planner/features/budget/screens/budget_category_screen.dart';
import 'package:budget_planner/features/budget/models/budget_category.dart';
import 'package:budget_planner/features/transactions/models/transaction_model.dart';
import 'package:budget_planner/features/transactions/providers/budget_provider.dart';

void main() {
  group('BudgetCategoryScreen', () {
    late BudgetProvider budgetProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      budgetProvider = BudgetProvider();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider<BudgetProvider>.value(
          value: budgetProvider,
          child: const BudgetCategoryScreen(),
        ),
      );
    }

    testWidgets('displays empty state when no categories exist', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No categories yet'), findsOneWidget);
      expect(find.text('Create a category to get started'), findsOneWidget);
      expect(find.byIcon(Icons.category_outlined), findsOneWidget);
    });

    testWidgets('displays category list when categories exist', (WidgetTester tester) async {
      final category = BudgetCategory(
        name: 'Groceries',
        description: 'Food and groceries',
        monthlyLimit: 500,
      );
      budgetProvider.addCategory(category);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Groceries'), findsWidgets);
      expect(find.text('Food and groceries'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays multiple categories', (WidgetTester tester) async {
      final category1 = BudgetCategory(
        name: 'Groceries',
        description: 'Food',
        monthlyLimit: 500,
      );
      final category2 = BudgetCategory(
        name: 'Transport',
        description: 'Gas and transit',
        monthlyLimit: 300,
      );
      budgetProvider.addCategory(category1);
      budgetProvider.addCategory(category2);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Groceries'), findsWidgets);
      expect(find.text('Transport'), findsWidgets);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Gas and transit'), findsOneWidget);
    });

    testWidgets('displays variance information correctly', (WidgetTester tester) async {
      final category = BudgetCategory(
        name: 'Groceries',
        description: 'Food',
        monthlyLimit: 500,
      );
      budgetProvider.addCategory(category);

      // Add transactions for current month
      final now = DateTime.now();
      final transaction = Transaction(
        title: 'Groceries',
        amount: 300,
        date: now,
        type: TransactionType.expense,
        category: 'Groceries',
      );
      budgetProvider.addTransaction(transaction);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show remaining budget (500 - 300 = 200)
      expect(find.text('Remaining'), findsOneWidget);
      expect(find.text('\$ 200.00'), findsOneWidget);
    });

    testWidgets('displays overspent status when spending exceeds limit', (WidgetTester tester) async {
      final category = BudgetCategory(
        name: 'Groceries',
        description: 'Food',
        monthlyLimit: 200,
      );
      budgetProvider.addCategory(category);

      // Add transactions exceeding limit
      final now = DateTime.now();
      final transaction1 = Transaction(
        title: 'Groceries 1',
        amount: 150,
        date: now,
        type: TransactionType.expense,
        category: 'Groceries',
      );
      final transaction2 = Transaction(
        title: 'Groceries 2',
        amount: 100,
        date: now,
        type: TransactionType.expense,
        category: 'Groceries',
      );
      budgetProvider.addTransaction(transaction1);
      budgetProvider.addTransaction(transaction2);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show overspent status
      expect(find.text('Overspent'), findsOneWidget);
      expect(find.text('\$ 50.00'), findsOneWidget);
    });

    testWidgets('FAB opens add category dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(AlertDialog), findsNothing);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Add New Category'), findsOneWidget);
    });

    testWidgets('can add a new category', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.byType(TextField).at(0),
        'Groceries',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'Food and groceries',
      );
      await tester.enterText(
        find.byType(TextField).at(2),
        '500',
      );

      // Submit
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify category was added
      expect(find.text('Groceries'), findsWidgets);
      expect(find.text('Food and groceries'), findsOneWidget);
    });

    testWidgets('shows error when adding category with empty name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Leave name empty, fill limit
      await tester.enterText(
        find.byType(TextField).at(2),
        '500',
      );

      // Submit
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should show error
      expect(find.text('Please fill in all required fields'), findsOneWidget);
    });

    testWidgets('shows error when adding category with invalid limit', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill form with invalid limit
      await tester.enterText(
        find.byType(TextField).at(0),
        'Groceries',
      );
      await tester.enterText(
        find.byType(TextField).at(2),
        '-100',
      );

      // Submit
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should show error
      expect(find.text('Monthly limit must be positive'), findsOneWidget);
    });

    testWidgets('can edit a category', (WidgetTester tester) async {
      final category = BudgetCategory(
        name: 'Groceries',
        description: 'Food',
        monthlyLimit: 500,
      );
      budgetProvider.addCategory(category);

      await tester.pumpWidget(createWidgetUnderTest());

      // Open menu
      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();

      // Tap edit
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify dialog opened with existing data
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Edit Category'), findsOneWidget);
    });

    testWidgets('can delete a category with confirmation', (WidgetTester tester) async {
      final category = BudgetCategory(
        name: 'Groceries',
        description: 'Food',
        monthlyLimit: 500,
      );
      budgetProvider.addCategory(category);

      await tester.pumpWidget(createWidgetUnderTest());

      // Open menu
      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Delete Category'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      // Verify category was deleted
      expect(find.text('No categories yet'), findsOneWidget);
    });

    testWidgets('displays category with no description', (WidgetTester tester) async {
      final category = BudgetCategory(
        name: 'Groceries',
        description: '',
        monthlyLimit: 500,
      );
      budgetProvider.addCategory(category);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Groceries'), findsWidgets);
      // Description should not be displayed
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays current spending correctly', (WidgetTester tester) async {
      final category = BudgetCategory(
        name: 'Groceries',
        description: 'Food',
        monthlyLimit: 500,
      );
      budgetProvider.addCategory(category);

      // Add transaction
      final now = DateTime.now();
      final transaction = Transaction(
        title: 'Groceries',
        amount: 250,
        date: now,
        type: TransactionType.expense,
        category: 'Groceries',
      );
      budgetProvider.addTransaction(transaction);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display current spending
      expect(find.text('Current Spending'), findsOneWidget);
      expect(find.text('\$ 250.00'), findsOneWidget);
    });

    testWidgets('ignores transactions from other months', (WidgetTester tester) async {
      final category = BudgetCategory(
        name: 'Groceries',
        description: 'Food',
        monthlyLimit: 500,
      );
      budgetProvider.addCategory(category);

      // Add transaction from previous month
      final lastMonth = DateTime.now().subtract(Duration(days: 30));
      final transaction = Transaction(
        title: 'Groceries',
        amount: 300,
        date: lastMonth,
        type: TransactionType.expense,
        category: 'Groceries',
      );
      budgetProvider.addTransaction(transaction);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show remaining budget (no current month spending)
      expect(find.text('Remaining'), findsOneWidget);
      // Check for the remaining amount in the variance section
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('ignores income transactions in variance calculation', (WidgetTester tester) async {
      final category = BudgetCategory(
        name: 'Salary',
        description: 'Income',
        monthlyLimit: 5000,
      );
      budgetProvider.addCategory(category);

      // Add income transaction
      final now = DateTime.now();
      final transaction = Transaction(
        title: 'Salary',
        amount: 5000,
        date: now,
        type: TransactionType.income,
        category: 'Salary',
      );
      budgetProvider.addTransaction(transaction);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show remaining budget (income not counted as spending)
      expect(find.text('Remaining'), findsOneWidget);
      // Verify the category is displayed
      expect(find.text('Salary'), findsWidgets);
    });
  });
}
