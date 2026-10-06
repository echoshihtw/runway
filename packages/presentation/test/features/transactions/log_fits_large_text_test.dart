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

/// The smallest screen we support at the largest text size, the same bar the
/// preset grid is held to.
void main() {
  testWidgets('the month header fits a narrow screen at double text size', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320 * 3, 800 * 3);
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
                amount: Money(1234567),
                note: 'Dinner with the team',
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
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const TransactionsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'the month and its total must share one row without overflowing',
    );
  });
}
