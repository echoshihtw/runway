import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/transactions/widgets/transaction_row.dart';

/// Every other number in the app takes its category's colour. The log was the
/// one place a figure stayed neutral, so an expense, a loan and a
/// subscription charge all read the same on the right-hand edge.
Transaction _tx(TransactionType type) {
  final date = DateTime(2026, 9, 14);
  return Transaction(
    id: 'tx-1',
    date: date,
    type: type,
    amount: Money(1200),
    note: 'Thing',
    createdAt: date,
    updatedAt: date,
  );
}

Future<Color?> _amountColour(WidgetTester tester, TransactionType type) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TransactionRow(
            transaction: _tx(type),
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return tester
      .widget<Text>(
        find.byWidgetPredicate(
          (w) => w is Text && (w.data ?? '').contains('1,200'),
        ),
      )
      .style
      ?.color;
}

void main() {
  testWidgets('an outflow is a cost, an inflow is life', (tester) async {
    expect(await _amountColour(tester, TransactionType.expense), SC.txExpense);
    expect(await _amountColour(tester, TransactionType.income), SC.txIncome);
  });

  testWidgets('a commitment keeps its own colour', (tester) async {
    // Expense, repayment and subscription charge are all outflows and all
    // wear the same arrow, so the hue is the only thing that says which.
    expect(
      await _amountColour(tester, TransactionType.repayment),
      SC.txRepayment,
    );
    expect(
      await _amountColour(tester, TransactionType.subscriptionCharge),
      SC.subscr,
    );
  });

  testWidgets('the opening balance takes no category colour', (tester) async {
    // It is where counting starts, not money that moved.
    expect(
      await _amountColour(tester, TransactionType.openingBalance),
      AppColors.textSecondary,
    );
  });
}
