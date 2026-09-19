import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/loans/liabilities_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nothing in the app ever set a loan inactive. A loan settled early went on
/// charging the runway until its term ran out, and a loan whose drawdown entry
/// had lost its id could not be reached by the delete path at all.
class _Loans implements LoanRepository {
  _Loans(this.items);
  final List<Loan> items;
  final updated = <Loan>[];

  @override
  Stream<List<Loan>> watchAll() => Stream.value(items);

  @override
  Future<List<Loan>> getAll() async => items;

  @override
  Future<void> update(Loan loan) async => updated.add(loan);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionRepository {
  _Transactions(this.items);
  final List<Transaction> items;

  @override
  Stream<List<Transaction>> watchAll() => Stream.value(items);

  @override
  Future<List<Transaction>> getAll() async => items;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FreeTier implements PurchaseService {
  @override
  Stream<bool> get proEntitlementUpdates => const Stream<bool>.empty();
  @override
  Future<bool> checkProEntitlement() async => false;
  @override
  Future<ProOffering?> fetchOffering() async => null;
  @override
  Future<bool> purchasePackage(ProPackage package) async => false;
  @override
  Future<bool> restorePurchases() async => false;
}

class _EntryCount implements UsageCountStore {
  final counts = <String, int>{};
  @override
  Future<int> read(String key) async => counts[key] ?? 0;
  @override
  Future<void> write(String key, int count) async => counts[key] = count;
}

Loan _loan() => Loan(
  id: 'loan-1',
  name: 'Fubon',
  source: 'BANK',
  originalAmount: 120000,
  monthlyPayment: 10000,
  startDate: DateTime(2026, 3, 1),
  createdAt: DateTime(2026, 3, 1),
  updatedAt: DateTime(2026, 3, 1),
);

Future<_Loans> _pump(
  WidgetTester tester, {
  List<Transaction> txs = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final loans = _Loans([_loan()]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        loanRepositoryProvider.overrideWithValue(loans),
        transactionRepositoryProvider.overrideWithValue(
          _Transactions(txs.toList()),
        ),
        purchaseServiceProvider.overrideWithValue(_FreeTier()),
        usageCountStoreProvider.overrideWithValue(_EntryCount()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(child: LiabilitiesPanel()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return loans;
}

Future<void> _openPanel(WidgetTester tester) async {
  await tester.tap(find.text('LIABILITIES'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a loan can be marked settled, and only after confirming', (
    tester,
  ) async {
    final loans = await _pump(tester);
    await _openPanel(tester);

    await tester.tap(find.text('FUBON'));
    await tester.pumpAndSettle();
    expect(find.text('MARK AS SETTLED'), findsWidgets);

    // Backing out writes nothing.
    await tester.tap(find.text('ABORT'));
    await tester.pumpAndSettle();
    expect(loans.updated, isEmpty);

    await tester.tap(find.text('FUBON'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MARK AS SETTLED').last);
    await tester.pumpAndSettle();

    expect(loans.updated, hasLength(1));
    expect(loans.updated.single.isActive, isFalse);
    expect(
      loans.updated.single.id,
      'loan-1',
      reason: 'the same loan, not a new one',
    );
  });

  testWidgets('REPAY opens the repay sheet, not the settled dialog', (
    tester,
  ) async {
    await _pump(tester);
    await _openPanel(tester);

    await tester.tap(find.text('REPAY'));
    await tester.pumpAndSettle();

    // The card's tap target sits under REPAY's own, so the inner one has to
    // win or the repay button would settle the loan instead.
    expect(find.text('MARK AS SETTLED'), findsNothing);
    expect(find.text('REPAY LOAN'), findsOneWidget);
  });

  testWidgets('a loan whose drawdown entry lost its id can still be settled', (
    tester,
  ) async {
    // This is the escape hatch for an entry orphaned before the edit fix: the
    // delete path cannot reach such a loan, but it is active and not fully
    // repaid, so it still has a card, so it still has this.
    final orphaned = Transaction(
      id: 'tx-1',
      date: DateTime(2026, 3, 1),
      type: TransactionType.loan,
      amount: Money(120000),
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 3, 1),
    );
    final loans = await _pump(tester, txs: [orphaned]);
    await _openPanel(tester);

    await tester.tap(find.text('FUBON'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MARK AS SETTLED').last);
    await tester.pumpAndSettle();

    expect(loans.updated.single.isActive, isFalse);
  });
}
