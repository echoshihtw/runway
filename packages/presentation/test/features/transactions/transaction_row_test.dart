import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/transactions/widgets/transaction_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

Transaction _expense({String? note, ExpenseCategory? category}) {
  final date = DateTime(2026, 9, 10);
  return Transaction(
    id: 'tx-1',
    date: date,
    type: TransactionType.expense,
    amount: Money(210),
    note: note,
    category: category,
    createdAt: date,
    updatedAt: date,
  );
}

Future<void> _pumpRow(WidgetTester tester, Transaction transaction) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TransactionRow(
            transaction: transaction,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _top(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text)).dy;

void main() {
  testWidgets('the note leads and the type moves underneath', (tester) async {
    await _pumpRow(tester, _expense(note: 'Lunch with Mei'));

    expect(find.text('Lunch with Mei'), findsOneWidget);
    expect(find.text('EXPENSE'), findsOneWidget);
    expect(_top(tester, 'Lunch with Mei'), lessThan(_top(tester, 'EXPENSE')));
  });

  testWidgets('without a note, the type is the title', (tester) async {
    await _pumpRow(tester, _expense());

    expect(find.text('EXPENSE'), findsOneWidget);
    expect(find.textContaining('·'), findsNothing);
  });

  testWidgets('a blank note falls back to the type', (tester) async {
    await _pumpRow(tester, _expense(note: '   '));

    expect(find.text('EXPENSE'), findsOneWidget);
  });

  testWidgets('the category joins the type under the note', (tester) async {
    await _pumpRow(
      tester,
      _expense(note: 'Groceries', category: ExpenseCategory.food),
    );

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('EXPENSE · LIVING · FOOD'), findsOneWidget);
  });

  testWidgets('transport counts against the living budget', (tester) async {
    await _pumpRow(
      tester,
      _expense(note: 'Metro pass', category: ExpenseCategory.transport),
    );

    expect(find.text('EXPENSE · LIVING · TRANSPORT'), findsOneWidget);
  });

  testWidgets('rent names its budget once', (tester) async {
    await _pumpRow(
      tester,
      _expense(note: 'Rent', category: ExpenseCategory.rent),
    );

    expect(find.text('EXPENSE · RENT'), findsOneWidget);
  });
}
