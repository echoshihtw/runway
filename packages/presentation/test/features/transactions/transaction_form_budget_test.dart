import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/transactions/widgets/transaction_form.dart';

typedef _Submitted = ({TransactionType type, ExpenseCategory? category});

Future<List<_Submitted>> _openForm(
  WidgetTester tester, {
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
                onSubmit: (type, amount, date, note, category, loanId) =>
                    submitted.add((type: type, category: category)),
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
  testWidgets('an expense counts as living by default', (tester) async {
    final submitted = await _openForm(tester);

    await _confirm(tester, '210');

    expect(submitted.single.type, TransactionType.expense);
    expect(submitted.single.category, isNull);
  });

  testWidgets('choosing rent saves the rent category', (tester) async {
    final submitted = await _openForm(tester);

    await tester.tap(find.text('RENT'));
    await tester.pump();
    await _confirm(tester, '32000');

    expect(submitted.single.category, ExpenseCategory.rent);
  });

  testWidgets('editing a living expense keeps its category', (tester) async {
    final date = DateTime(2026, 9, 15);
    final submitted = await _openForm(
      tester,
      existing: Transaction(
        id: 'tx-1',
        date: date,
        type: TransactionType.expense,
        amount: Money(210),
        category: ExpenseCategory.food,
        createdAt: date,
        updatedAt: date,
      ),
    );

    await _confirm(tester, '250');

    expect(submitted.single.category, ExpenseCategory.food);
  });

  testWidgets('income has no budget choice', (tester) async {
    await _openForm(tester);

    await tester.tap(find.text('IN'));
    await tester.pump();

    expect(find.text('RENT'), findsNothing);
    expect(find.text('LIVING'), findsNothing);
  });
}
