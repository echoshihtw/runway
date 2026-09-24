import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/transactions/widgets/transaction_form.dart';

typedef _Submitted = ({
  TransactionType type,
  ExpenseCategory? category,
  String? loanId,
});

Loan _loan(String id, String name) => Loan(
  id: id,
  name: name,
  source: 'bank',
  originalAmount: 100000,
  monthlyPayment: 5000,
  startDate: DateTime(2026, 1, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

Future<List<_Submitted>> _openForm(
  WidgetTester tester, {
  List<Loan> loans = const [],
  Transaction? existing,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final submitted = <_Submitted>[];
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => TransactionForm(
                existing: existing,
                loans: loans,
                onSubmit: (type, amount, date, note, category, loanId) =>
                    submitted.add((
                      type: type,
                      category: category,
                      loanId: loanId,
                    )),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return submitted;
}

Future<void> _confirm(WidgetTester tester, String amount) async {
  // CONFIRM follows the amount now, and enterText does not flush the
  // rebuild that enables it, so the frame has to be pumped before the tap.
  await tester.enterText(find.byType(TextField).first, amount);
  await tester.pump();
  await tester.tap(find.text('CONFIRM'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('without loans there is no LOAN choice', (tester) async {
    await _openForm(tester);

    expect(find.text('LIVING'), findsOneWidget);
    expect(find.text('RENT'), findsOneWidget);
    expect(find.text('LOAN'), findsNothing);
  });

  testWidgets('with one loan, LOAN picks it and saves a repayment', (
    tester,
  ) async {
    final submitted = await _openForm(tester, loans: [_loan('l1', 'Bank')]);

    expect(find.text('LOAN'), findsOneWidget);
    await tester.tap(find.text('LOAN'));
    await tester.pumpAndSettle();
    expect(find.text('BANK'), findsOneWidget);

    await _confirm(tester, '5000');

    expect(submitted.single.type, TransactionType.repayment);
    expect(submitted.single.loanId, 'l1');
    expect(submitted.single.category, isNull);
  });

  testWidgets('with two loans, the chosen loan is saved', (tester) async {
    final submitted = await _openForm(
      tester,
      loans: [_loan('l1', 'Bank'), _loan('l2', 'Family')],
    );

    await tester.tap(find.text('LOAN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('FAMILY'));
    await tester.pumpAndSettle();
    await _confirm(tester, '3000');

    expect(submitted.single.loanId, 'l2');
  });

  testWidgets('switching from LOAN back to LIVING saves an expense', (
    tester,
  ) async {
    final submitted = await _openForm(tester, loans: [_loan('l1', 'Bank')]);

    await tester.tap(find.text('LOAN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LIVING'));
    await tester.pumpAndSettle();
    expect(find.text('BANK'), findsNothing);
    await _confirm(tester, '210');

    expect(submitted.single.type, TransactionType.expense);
    expect(submitted.single.loanId, isNull);
  });

  testWidgets('editing a repayment opens with LOAN selected', (tester) async {
    final date = DateTime(2026, 9, 10);
    final submitted = await _openForm(
      tester,
      loans: [_loan('l1', 'Bank')],
      existing: Transaction(
        id: 'tx-1',
        date: date,
        type: TransactionType.repayment,
        amount: Money(5000),
        loanId: 'l1',
        createdAt: date,
        updatedAt: date,
      ),
    );

    expect(find.text('BANK'), findsOneWidget);
    await _confirm(tester, '5000');

    expect(submitted.single.type, TransactionType.repayment);
    expect(submitted.single.loanId, 'l1');
  });
}
