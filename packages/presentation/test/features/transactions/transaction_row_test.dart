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

Transaction _of(TransactionType type, {String? note, double amount = 210}) {
  final date = DateTime(2026, 9, 2);
  return Transaction(
    id: 'tx-${type.name}',
    date: date,
    type: type,
    amount: Money(amount),
    note: note,
    loanId: type == TransactionType.repayment ? 'loan-1' : null,
    createdAt: date,
    updatedAt: date,
  );
}

/// By the digits, not the symbol: '¥' is only the currency provider's
/// loading fallback, and by the time the row has settled it reads '$'.
Color _amountColor(WidgetTester tester, String digits) =>
    tester.widget<Text>(find.textContaining(digits)).style!.color!;

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
  testWidgets('the note leads and the budget moves underneath', (tester) async {
    await _pumpRow(tester, _expense(note: 'Lunch with Mei'));

    expect(find.text('Lunch with Mei'), findsOneWidget);
    // An expense names the budget it uses up, even with no category.
    expect(find.text('EXPENSE · LIVING'), findsOneWidget);
    expect(
      _top(tester, 'Lunch with Mei'),
      lessThan(_top(tester, 'EXPENSE · LIVING')),
    );
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

  // One glyph per concept (#136). A loan is the bank wherever it appears —
  // the card, the money arriving, each payment — so nothing in the log has to
  // be compared with a near-twin to be read.
  group('one glyph per concept', () {
    testWidgets('a loan payment wears the bank, and says what it is', (
      tester,
    ) async {
      await _pumpRow(tester, _of(TransactionType.repayment, note: 'Student loan'));

      expect(find.byIcon(Icons.account_balance_rounded), findsOneWidget);
      expect(find.byIcon(Icons.replay_rounded), findsNothing);
      expect(find.text('LOAN PAYMENT'), findsOneWidget, reason: 'a noun, not a verb');
    });

    testWidgets('money arriving from a loan wears the bank too', (tester) async {
      await _pumpRow(tester, _of(TransactionType.loan, note: 'Bank loan', amount: 5000));

      expect(find.byIcon(Icons.account_balance_rounded), findsOneWidget);
      expect(find.byIcon(Icons.credit_score_rounded), findsNothing);
    });

    testWidgets('the opening balance is a starting line, not a bank', (
      tester,
    ) async {
      await _pumpRow(tester, _of(TransactionType.openingBalance, amount: 34000));

      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_rounded), findsNothing);
      // Not money that moved this month, so it must not read like it.
      expect(_amountColor(tester, '34,000'), AppColors.textSecondary);
    });
  });
}
