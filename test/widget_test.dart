import 'package:flutter_test/flutter_test.dart';

import 'package:budget_planner/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BudgetPlannerApp());

    // Verify that the dashboard is displayed
    expect(find.text('Budget Planner'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
  });
}
