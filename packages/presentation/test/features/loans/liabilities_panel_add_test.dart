import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/loans/liabilities_panel.dart';
import 'package:presentation/features/paywall/paywall_screen.dart';
import 'package:presentation/features/transactions/widgets/loan_wizard.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "NO ACTIVE LOANS" was inert text, and it is seen exactly when someone
/// does not yet know the feature exists. Creating a loan lived only in the add
/// menu — a tap and a decision away from the card that owns loans.
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

/// Free tier: the store says no, and nothing is cached.
/// The Keychain counter, in memory. Fresh per pump, so every test starts free.
class _EntryCount implements UsageCountStore {
  final counts = <String, int>{};

  @override
  Future<int> read(String key) async => counts[key] ?? 0;

  @override
  Future<void> write(String key, int count) async => counts[key] = count;
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

Loan _loan() => Loan(
  id: 'loan-1',
  name: 'Bank',
  source: 'BANK',
  originalAmount: 120000,
  monthlyPayment: 10000,
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
  testWidgets('the empty state offers to create one, and opens the wizard', (
    tester,
  ) async {
    await _pump(tester, const []);

    expect(find.text('NO ACTIVE LOANS'), findsOneWidget);
    expect(find.text('+ LOAN'), findsOneWidget);

    await tester.tap(find.text('+ LOAN'));
    await tester.pumpAndSettle();

    expect(
      find.byType(LoanWizard),
      findsOneWidget,
      reason: 'the first loan is free, so nothing should stand in the way',
    );
  });

  testWidgets('with a loan listed, the way to add one is still there', (
    tester,
  ) async {
    await _pump(tester, [_loan()]);

    // The card collapses by default. SizeTransition keeps its child in the
    // tree at zero height, so expanding is what makes the strip reachable.
    await tester.tap(find.text('LIABILITIES'));
    await tester.pumpAndSettle();

    expect(find.text('+ LOAN'), findsOneWidget);
  });

  testWidgets('a second loan is free, so the wizard opens', (tester) async {
    // The Pro gate is simulations and entries, not loans (#80, decided
    // 2026-09-16). The one-active-loan limit that used to live here is gone;
    // a free owner with an active loan reaches the wizard like anyone else.
    await _pump(tester, [_loan()]);
    await tester.tap(find.text('LIABILITIES'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ LOAN'));
    await tester.pumpAndSettle();

    expect(find.byType(LoanWizard), findsOneWidget);
    expect(find.byType(PaywallScreen), findsNothing);
  });

  testWidgets('the empty state fits a narrow screen at double text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester, const [], textScale: 2.0);

    expect(
      tester.takeException(),
      isNull,
      reason: 'the empty state must lay out on the smallest screen we support '
          'at the largest text size, not overflow',
    );
    expect(find.text('+ LOAN'), findsOneWidget);
  });

  testWidgets('the add strip is big enough to hit', (tester) async {
    await _pump(tester, [_loan()]);
    await tester.tap(find.text('LIABILITIES'));
    await tester.pumpAndSettle();

    final strip = find
        .ancestor(
          of: find.text('+ LOAN'),
          matching: find.byType(GestureDetector),
        )
        .first;

    expect(
      tester.getSize(strip).height,
      greaterThanOrEqualTo(44),
      reason: "Apple's minimum; a control that looks tappable must be "
          'reachable',
    );
  });
}
