import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/transactions/transactions_screen.dart';
import 'package:presentation/features/transactions/widgets/transaction_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The purge dialog used to delete inside its own action button, after popping
/// its context, from a showDialog nobody awaited.
///
/// These pass against that version too: the defect was that the work was
/// untracked, not that it did the wrong thing, and a widget test cannot see
/// the difference. They are here so the delete path has cover at all, and so
/// the move to an awaited bool cannot change what it does. `discarded_futures`
/// is the check that would have caught the original.
class _Transactions implements TransactionRepository {
  _Transactions(this.items);
  final List<Transaction> items;
  final deleted = <String>[];

  @override
  Stream<List<Transaction>> watchAll() => Stream.value(items);

  @override
  Future<List<Transaction>> getAll() async => items;

  @override
  Future<void> delete(String id) async => deleted.add(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Loans implements LoanRepository {
  final deleted = <String>[];

  @override
  Stream<List<Loan>> watchAll() => Stream.value(const []);

  @override
  Future<List<Loan>> getAll() async => const [];

  @override
  Future<void> delete(String id) async => deleted.add(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Transaction _entry(TransactionType type, {String? loanId}) {
  final date = DateTime(2026, 9, 10);
  return Transaction(
    id: 'tx-1',
    date: date,
    type: type,
    amount: Money(210),
    loanId: loanId,
    createdAt: date,
    updatedAt: date,
  );
}

Future<(_Transactions, _Loans)> _pump(
  WidgetTester tester,
  Transaction tx,
) async {
  SharedPreferences.setMockInitialValues({});
  final txs = _Transactions([tx]);
  final loans = _Loans();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(txs),
        loanRepositoryProvider.overrideWithValue(loans),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TransactionsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (txs, loans);
}

/// A long press on the row is the way in, as transaction_row wires onDelete.
Future<void> _openDialog(WidgetTester tester) async {
  await tester.longPress(find.byType(TransactionRow).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('confirming deletes the entry', (tester) async {
    final (txs, _) = await _pump(tester, _entry(TransactionType.expense));
    await _openDialog(tester);

    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    expect(txs.deleted, ['tx-1']);
  });

  testWidgets('cancelling deletes nothing', (tester) async {
    final (txs, _) = await _pump(tester, _entry(TransactionType.expense));
    await _openDialog(tester);

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect(txs.deleted, isEmpty);
  });

  testWidgets('a loan entry takes its loan with it', (tester) async {
    final (txs, loans) = await _pump(
      tester,
      _entry(TransactionType.loan, loanId: 'loan-7'),
    );
    await _openDialog(tester);

    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    expect(txs.deleted, ['tx-1']);
    expect(loans.deleted, ['loan-7'], reason: 'the dialog promised this');
  });
}
