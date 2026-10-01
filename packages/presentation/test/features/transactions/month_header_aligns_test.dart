import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/transactions/transactions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Txs implements TransactionRepository {
  _Txs(this.items);
  final List<Transaction> items;
  @override
  Stream<List<Transaction>> watchAll() => Stream.value(items);
  @override
  Future<List<Transaction>> getAll() async => items;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Loans implements LoanRepository {
  @override
  Stream<List<Loan>> watchAll() => Stream.value(const []);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Future<void> _pump(
  WidgetTester tester,
  double width,
  double scale, {
  double amount = 1250,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = Size(width * 3, 900 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final d = DateTime(2026, 9, 10);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(
          _Txs([
            Transaction(
              id: 'a',
              date: d,
              type: TransactionType.expense,
              amount: Money(amount),
              createdAt: d,
              updatedAt: d,
            ),
          ]),
        ),
        loanRepositoryProvider.overrideWithValue(_Loans()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: const TransactionsScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the month and its total sit on the same line, centred', (
    tester,
  ) async {
    await _pump(tester, 390, 1);

    final month = tester.getRect(find.text('SEP 2026'));
    final total = tester.getRect(find.textContaining('1,250').first);

    expect(
      (month.center.dy - total.center.dy).abs(),
      lessThan(1),
      reason: 'the two read as one line, so their centres line up',
    );
    expect(
      total.right,
      greaterThan(month.right),
      reason: 'the total stays pushed to the far side',
    );
  });

  testWidgets('NET is gone', (tester) async {
    await _pump(tester, 390, 1);
    expect(find.text('NET'), findsNothing);
  });

  testWidgets('the total never breaks across lines', (tester) async {
    // A six figure month at double text on the smallest screen. Wider than its
    // line, the text would otherwise wrap anywhere, sign from digits included.
    await _pump(tester, 320, 2, amount: 125000);

    final total = tester.getRect(find.textContaining('125,000').first);
    expect(
      total.height,
      lessThan(50),
      reason: 'one line: it shrinks to fit rather than breaking',
    );
  });
}
