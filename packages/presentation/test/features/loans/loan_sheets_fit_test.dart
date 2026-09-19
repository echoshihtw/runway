import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/loans/liabilities_panel.dart';
import 'package:presentation/features/transactions/show_entry_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The loan sheets repeat faults the subscription sheet had before #168:
/// no scroll view and no height cap, so CONFIRM sat past the bottom of a
/// small screen, and a CONFIRM that was live on an empty amount.
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
  _loanEntryKeepsItsLoan();

  testWidgets('the wizard fits a small screen at large text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester, const [], textScale: 2.0);
    await tester.tap(find.text('+ LOAN'));
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'the wizard had no scroll view, so it overflowed by 247px and '
          'CONFIRM could not be reached at all',
    );
  });

  testWidgets('the repay sheet fits a small screen at large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester, [_loan()], textScale: 2.0);
    await tester.tap(find.text('LIABILITIES'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('REPAY'));
    await tester.tap(find.text('REPAY'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('repay CONFIRM is dead until there is an amount', (tester) async {
    await _pump(tester, [_loan()]);
    await tester.tap(find.text('LIABILITIES'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('REPAY'));
    await tester.pumpAndSettle();

    final amount = find.byType(TextField).first;
    expect(_confirm(tester).onPressed, isNotNull, reason: 'prefilled');

    await tester.enterText(amount, '');
    await tester.pump();
    expect(
      _confirm(tester).onPressed,
      isNull,
      reason: 'it used to be live while the handler returned early, so the '
          'tap did nothing and the sheet just sat there',
    );

    await tester.enterText(amount, '250');
    await tester.pump();
    expect(_confirm(tester).onPressed, isNotNull);
  });
}

NeoButton _confirm(WidgetTester tester) => tester.widget<NeoButton>(
  find
      .ancestor(of: find.text('CONFIRM'), matching: find.byType(NeoButton))
      .first,
);

/// Confirming a loan entry in the log used to clear its loanId, and that id is
/// the only handle the delete path has — so the loan became undeletable and
/// went on charging the runway for good.
void _loanEntryKeepsItsLoan() {
  testWidgets('a loan entry keeps its loan when confirmed unchanged', (
    tester,
  ) async {
    final loan = _loan();
    final drawdown = Transaction(
      id: 'tx-1',
      date: DateTime(2026, 3, 1),
      type: TransactionType.loan,
      amount: Money(120000),
      loanId: loan.id,
      note: 'BANK — Bank',
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 3, 1),
    );
    final written = <Transaction>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanRepositoryProvider.overrideWithValue(_Loans([loan])),
          transactionRepositoryProvider.overrideWithValue(
            _Transactions([drawdown]),
          ),
          purchaseServiceProvider.overrideWithValue(_FreeTier()),
          usageCountStoreProvider.overrideWithValue(_EntryCount()),
          editTransactionUseCaseProvider.overrideWithValue(
            _RecordingEdit(written),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Consumer(
                builder: (context, ref, _) => TextButton(
                  onPressed: () =>
                      showEntrySheet(context, ref, existing: drawdown),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('CONFIRM'));
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(written, hasLength(1));
    expect(
      written.single.loanId,
      loan.id,
      reason: 'clearing it orphaned the loan, and nothing could delete it after',
    );
  });
}

class _RecordingEdit implements EditTransactionUseCase {
  _RecordingEdit(this.written);
  final List<Transaction> written;

  @override
  Future<void> execute(Transaction transaction) async =>
      written.add(transaction);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
