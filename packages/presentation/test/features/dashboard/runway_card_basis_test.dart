import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/runway_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The runway can sit on three bases — a budget the owner typed, spending the
/// app measured, or a cost assumption that replaces both — and nothing on the
/// card said which (#87). Every finance report states its basis; this one
/// reported 1,388 months derived from two typed numbers with the same
/// confidence as a measurement.
final _now = DateTime(2026, 9, 15);

Transaction _tx(String id, TransactionType type, double amount) => Transaction(
  id: id,
  date: DateTime(2026, 9, 10),
  type: type,
  amount: Money(amount),
  createdAt: _now,
  updatedAt: _now,
);

ModelState _model({
  required Budget budget,
  required double spent,
  double? assumption,
}) {
  final txs = [
    _tx('ob', TransactionType.openingBalance, 34000),
    if (spent > 0) _tx('e', TransactionType.expense, spent),
  ];
  final burn = computeMonthlyBurn(
    transactions: txs,
    budget: budget,
    loans: const [],
    subscriptions: const [],
    now: _now,
  );
  return computeModel(
    currentCash: currentCashAsOf(transactions: txs, now: _now),
    burn: burn,
    expectedMonthlyBurnOverride: assumption,
  );
}

Future<void> _pump(WidgetTester tester, ModelState state) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: RunwayCard(model: state)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('a budget doing the work says so', (tester) async {
    // 210 logged under an 1,100 budget: the budget is the floor, and the
    // number is a plan, not a measurement.
    await _pump(tester, _model(budget: const Budget(living: 1100), spent: 210));
    expect(find.text('On your budget, if income paused today'), findsOneWidget);
  });

  testWidgets('logged spending doing the work says so', (tester) async {
    // No budget, 800 logged: the estimate is what was measured.
    await _pump(tester, _model(budget: const Budget(), spent: 800));
    expect(find.text('On your spending, if income paused today'), findsOneWidget);
  });

  testWidgets('an active assumption says so, loudest of the three', (
    tester,
  ) async {
    await _pump(
      tester,
      _model(budget: const Budget(living: 1100), spent: 210, assumption: 2300),
    );
    expect(
      find.text('On your cost assumption, if income paused today'),
      findsOneWidget,
    );
  });

  testWidgets('the old undifferentiated caption is gone', (tester) async {
    await _pump(tester, _model(budget: const Budget(living: 1100), spent: 210));
    expect(find.text('If income paused today'), findsNothing);
  });
}
