import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/transactions/widgets/transaction_form.dart';

/// What a month of rent costs is already stored, so typing it again on every
/// rent entry is work the app can do. It offers the figure and takes it back
/// if the owner chooses something else, because an amount left behind would
/// log the rent against the living budget.
Future<void> _pump(WidgetTester tester, {Transaction? existing}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TransactionForm(
              existing: existing,
              rentBudget: 1450,
              loans: const [],
              onSubmit: (_, __, ___, ____, _____, ______) async => true,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String _amount(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text;

void main() {
  testWidgets('choosing rent offers the rent that is set', (tester) async {
    await _pump(tester);
    expect(_amount(tester), isEmpty);

    await tester.tap(find.text('RENT'));
    await tester.pumpAndSettle();
    expect(_amount(tester), '1450');
  });

  testWidgets('choosing something else takes the offer back', (tester) async {
    // Left behind, it would log a month of rent against the living budget.
    await _pump(tester);
    await tester.tap(find.text('RENT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LIVING'));
    await tester.pumpAndSettle();

    expect(_amount(tester), isEmpty);
  });

  testWidgets('a typed figure survives the switch', (tester) async {
    // Once the owner types, the amount is theirs and the form stops touching
    // it — otherwise the handback would delete their own number.
    await _pump(tester);
    await tester.enterText(find.byType(TextField).at(0), '980');
    await tester.pump();

    await tester.tap(find.text('RENT'));
    await tester.pumpAndSettle();
    expect(_amount(tester), '980', reason: 'the offer never overwrites');

    await tester.tap(find.text('LIVING'));
    await tester.pumpAndSettle();
    expect(_amount(tester), '980', reason: 'and never deletes');
  });
}
