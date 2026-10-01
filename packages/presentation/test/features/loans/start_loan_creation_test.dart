import 'dart:async';

import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/loans/start_loan_creation.dart';
import 'package:presentation/features/transactions/widgets/loan_wizard.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the loan write open until the test lets it land.
class _Loans implements LoanRepository {
  final items = <Loan>[];
  final landed = Completer<void>();

  @override
  Stream<List<Loan>> watchAll() => Stream.value(items);

  @override
  Future<List<Loan>> getAll() async => items;

  @override
  Future<void> add(Loan loan) async {
    await landed.future;
    items.add(loan);
  }

  @override
  Future<void> delete(String id) async => items.removeWhere((l) => l.id == id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionRepository {
  final items = <Transaction>[];

  @override
  Stream<List<Transaction>> watchAll() => Stream.value(items);

  @override
  Future<List<Transaction>> getAll() async => items;

  @override
  Future<void> add(Transaction transaction) async => items.add(transaction);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

class _Opener extends ConsumerWidget {
  const _Opener();

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton(
    onPressed: () => startLoanCreation(context, ref),
    child: const Text('OPEN'),
  );
}

void main() {
  testWidgets('the opener going away mid-write leaves no half loan', (
    tester,
  ) async {
    // The sheet sits on the root navigator, so the widget that opened it can
    // be disposed while a write is in flight. Its ref goes with it, and every
    // read after the first await used to throw: the loan stayed, its money
    // never arrived, and the rollback could not run either.
    SharedPreferences.setMockInitialValues({});
    final loans = _Loans();
    final transactions = _Transactions();
    final showOpener = ValueNotifier(true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanRepositoryProvider.overrideWithValue(loans),
          transactionRepositoryProvider.overrideWithValue(transactions),
          purchaseServiceProvider.overrideWithValue(_FreeTier()),
          usageCountStoreProvider.overrideWithValue(_EntryCount()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: showOpener,
              builder: (_, show, _) =>
                  show ? const _Opener() : const SizedBox(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Fubon');
    await tester.enterText(find.byType(TextField).at(1), '120000');
    await tester.pump();
    await tester.ensureVisible(find.textContaining('NEXT'));
    await tester.tap(find.textContaining('NEXT'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '36');
    await tester.pump();
    await tester.ensureVisible(find.textContaining('NEXT'));
    await tester.tap(find.textContaining('NEXT'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('CONFIRM'));
    await tester.tap(find.text('CONFIRM'));
    await tester.pump();

    showOpener.value = false;
    await tester.pump();
    loans.landed.complete();
    await tester.pumpAndSettle();

    expect(
      transactions.items.where((t) => t.loanId != null).length,
      loans.items.length,
      reason: 'a loan without its money is the half loan #133 forbade',
    );
    expect(
      find.byType(LoanWizard),
      loans.items.isEmpty ? findsOneWidget : findsNothing,
      reason: 'the wizard says it failed only when nothing was kept',
    );
  });
}
