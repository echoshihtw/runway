import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/loans/liabilities_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unbounded text on the loan card and its total (#95 item 4), and a
/// TextEditingController the repay sheet created and never disposed (item 2).
class _Loans implements LoanRepository {
  _Loans(this.items);
  final List<Loan> items;

  @override
  Stream<List<Loan>> watchAll() => Stream.value(items);

  @override
  Future<List<Loan>> getAll() async => items;

  @override
  Future<void> add(Loan loan) async => items.add(loan);

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
  Future<void> add(Transaction transaction) async => items.add(transaction);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The Keychain counter, in memory. Fresh per pump, so every test starts free.
class _EntryCount implements UsageCountStore {
  final counts = <String, int>{};

  @override
  Future<int> read(String key) async => counts[key] ?? 0;

  @override
  Future<void> write(String key, int count) async => counts[key] = count;
}

/// Free tier: the store says no, and nothing is cached.
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

Loan _loan({String name = 'Bank', double monthlyPayment = 10000}) => Loan(
  id: 'loan-1',
  name: name,
  source: 'BANK',
  originalAmount: 120000,
  monthlyPayment: monthlyPayment,
  startDate: DateTime(2026, 3, 1),
  createdAt: DateTime(2026, 3, 1),
  updatedAt: DateTime(2026, 3, 1),
);

Future<void> _pump(
  WidgetTester tester,
  List<Loan> loans, {
  double textScale = 1.0,
}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        loanRepositoryProvider.overrideWithValue(_Loans(loans.toList())),
        transactionRepositoryProvider.overrideWithValue(_Transactions([])),
        purchaseServiceProvider.overrideWithValue(_FreeTier()),
        usageCountStoreProvider.overrideWithValue(_EntryCount()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(child: LiabilitiesPanel()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a fifty-character lender name fits a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester, [_loan(name: 'A' * 50)], textScale: 2.0);
    await tester.tap(find.text('LIABILITIES'));
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason:
          'the name input allows 50 characters; the card must degrade, '
          'not overflow',
    );
  });

  testWidgets(
    'a twelve-digit total is bounded like its subscriptions sibling',
    (tester) async {
      await _pump(tester, [_loan(monthlyPayment: 999999999999)]);

      // The summary row renders before the card's own payment line.
      final total = tester.widget<Text>(
        find.textContaining('999,999,999,999').first,
      );
      expect(total.maxLines, 1);
      expect(total.overflow, TextOverflow.ellipsis);
    },
  );

  testWidgets('a twelve-digit installment fits the expanded card', (
    tester,
  ) async {
    // The card's own detail rows were unbounded, so the figure the test above
    // uses overflowed them as soon as the card was expanded.
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester, [_loan(monthlyPayment: 999999999999)]);
    await tester.tap(find.text('LIABILITIES'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the repay sheet opens and closes cleanly', (tester) async {
    await _pump(tester, [_loan()]);
    await tester.tap(find.text('LIABILITIES'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('REPAY'));
    await tester.pumpAndSettle();
    expect(find.text('CONFIRM'), findsOneWidget);

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect(find.text('CONFIRM'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
