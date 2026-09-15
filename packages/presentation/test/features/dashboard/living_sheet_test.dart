import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/living_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

Transaction _tx(
  String note,
  TransactionType type,
  double amount,
  DateTime date, {
  ExpenseCategory? category,
  bool withNote = true,
}) => Transaction(
  id: note,
  date: date,
  type: type,
  amount: Money(amount),
  note: withNote ? note : null,
  category: category,
  createdAt: date,
  updatedAt: date,
);

MonthlyBurn _burn({required double budget, required double spent}) => MonthlyBurn(
  month: SurvivalMonth(DateTime(2026, 9)),
  fractionOfMonthLeft: 16 / 30,
  rent: const BudgetBucket(budget: 32000, spentThisMonth: 0, typicalSpending: 0),
  living: BudgetBucket(budget: budget, spentThisMonth: spent, typicalSpending: spent),
  subscriptions: 0,
  loanPayments: 0,
  loanPaymentsLeftThisMonth: 0,
);

Future<void> _pumpSheet(
  WidgetTester tester, {
  required MonthlyBurn burn,
  List<Transaction> transactions = const [],
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        monthlyBurnProvider.overrideWithValue(burn),
        transactionsProvider.overrideWith((ref) => Stream.value(transactions)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: LivingSheet()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists this month\'s living expenses, newest first', (tester) async {
    await _pumpSheet(
      tester,
      burn: _burn(budget: 30000, spent: 300),
      transactions: [
        _tx('Bus', TransactionType.expense, 90, DateTime(2026, 9, 10),
            category: ExpenseCategory.transport, withNote: false),
        _tx('Lunch', TransactionType.expense, 210, DateTime(2026, 9, 15)),
        _tx('Rent', TransactionType.expense, 32000, DateTime(2026, 9, 1),
            category: ExpenseCategory.rent),
        _tx('Salary', TransactionType.income, 5000, DateTime(2026, 9, 2)),
        _tx('Old coffee', TransactionType.expense, 40, DateTime(2026, 8, 30)),
      ],
    );

    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('TRANSPORT'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Lunch')).dy,
      lessThan(tester.getTopLeft(find.text('TRANSPORT')).dy),
    );
    expect(find.text('Rent'), findsNothing);
    expect(find.text('Salary'), findsNothing);
    expect(find.text('Old coffee'), findsNothing);
  });

  testWidgets('shows spent, left, and a daily allowance', (tester) async {
    await _pumpSheet(tester, burn: _burn(budget: 30000, spent: 210));

    expect(find.textContaining(RegExp(r'210 / .*30,000')), findsOneWidget);
    expect(find.textContaining(RegExp(r'29,790 left$')), findsOneWidget);
    expect(find.textContaining('1,862 a day for 16 days'), findsOneWidget);
    expect(find.text('No living expenses logged this month'), findsOneWidget);
  });

  testWidgets('over budget shows the overage and no allowance', (tester) async {
    await _pumpSheet(tester, burn: _burn(budget: 30000, spent: 31500));

    expect(find.textContaining(RegExp(r'1,500 over budget$')), findsOneWidget);
    expect(find.textContaining('a day for'), findsNothing);
  });
}
