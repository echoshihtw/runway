import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/loans/liabilities_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The repay sheet popped the route before awaiting the write, so a refused
/// write left the owner believing a repayment was recorded that never was: the
/// sheet was gone, no message appeared, and the balance had not moved (#156).
///
/// The wizard learned this in #133. This is the same fault in the other sheet.
class _Loans implements LoanRepository {
  _Loans(this.items);
  final List<Loan> items;

  @override
  Stream<List<Loan>> watchAll() => Stream.value(items);

  @override
  Future<List<Loan>> getAll() async => items;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionRepository {
  _Transactions({required this.refuseWrites});

  /// A storage failure, which is what this is really about. An amount over
  /// 1e12 throws from the use case instead, but that path is unreachable
  /// through the field, so it would not prove the sheet handles a throw.
  final bool refuseWrites;

  /// A real write takes a SQLite round trip. Without the delay the route pops
  /// inside the first tap's microtask and a second tap cannot land.
  Duration delay = Duration.zero;
  final List<Transaction> items = [];
  int attempts = 0;

  @override
  Stream<List<Transaction>> watchAll() => Stream.value(items);

  @override
  Future<List<Transaction>> getAll() async => items;

  @override
  Future<void> add(Transaction transaction) async {
    attempts++;
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    if (refuseWrites) throw Exception('disk is full');
    items.add(transaction);
  }

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

class _NoUsage implements UsageCountStore {
  @override
  Future<int> read(String key) async => 0;

  @override
  Future<void> write(String key, int count) async {}
}

Loan _loan() => Loan(
  id: 'loan-1',
  name: 'Fubon',
  source: 'Fubon Bank',
  originalAmount: 120000,
  monthlyPayment: 5000,
  startDate: DateTime(2026, 1, 1),
  isActive: true,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

Future<_Transactions> _pump(
  WidgetTester tester, {
  required bool refuseWrites,
}) async {
  SharedPreferences.setMockInitialValues({});
  final transactions = _Transactions(refuseWrites: refuseWrites);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        loanRepositoryProvider.overrideWithValue(_Loans([_loan()])),
        transactionRepositoryProvider.overrideWithValue(transactions),
        purchaseServiceProvider.overrideWithValue(_FreeTier()),
        usageCountStoreProvider.overrideWithValue(_NoUsage()),
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
  return transactions;
}

/// The card is collapsed, and REPAY lives in the details.
Future<void> _openRepaySheet(WidgetTester tester) async {
  await tester.tap(find.text('LIABILITIES'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('REPAY').first);
  await tester.tap(find.text('REPAY').first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a refused repayment keeps the sheet open and says so', (
    tester,
  ) async {
    final transactions = await _pump(tester, refuseWrites: true);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await _openRepaySheet(tester);
    expect(find.text(l10n.repayLoan), findsOneWidget);

    await tester.tap(find.text(l10n.confirm.toUpperCase()));
    await tester.pumpAndSettle();

    expect(
      find.text(l10n.repayLoan),
      findsOneWidget,
      reason: 'nothing was written, so the sheet must not close as if it was',
    );
    expect(find.text(l10n.repaymentSaveFailed), findsOneWidget);
    expect(
      transactions.items,
      isEmpty,
      reason: 'the message must not be the only thing that is true',
    );
  });

  testWidgets('a repayment that lands closes the sheet', (tester) async {
    final transactions = await _pump(tester, refuseWrites: false);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await _openRepaySheet(tester);
    await tester.tap(find.text(l10n.confirm.toUpperCase()));
    await tester.pumpAndSettle();

    expect(find.text(l10n.repayLoan), findsNothing);
    expect(find.text(l10n.repaymentSaveFailed), findsNothing);
    expect(transactions.items, hasLength(1));
    expect(transactions.items.single.type, TransactionType.repayment);
  });

  testWidgets('two taps in one frame write one repayment', (tester) async {
    // Disabling the button is not a guard. setState only schedules a rebuild,
    // so until a frame is produced the old button is still mounted with a live
    // onPressed, and NeoButton fires on tap-up.
    final transactions = await _pump(tester, refuseWrites: false);
    transactions.delay = const Duration(milliseconds: 20);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await _openRepaySheet(tester);
    final confirm = find.text(l10n.confirm.toUpperCase());
    await tester.tap(confirm);
    await tester.tap(confirm, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(transactions.attempts, 1, reason: 'one tap-up too many is a write');
    expect(transactions.items, hasLength(1));
  });
}
