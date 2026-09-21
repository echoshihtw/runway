import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/transactions/widgets/loan_wizard.dart';

/// The wizard popped the route immediately after calling onSubmit, which was
/// declared void, so it closed whether the write landed or not — and a loan
/// creation is two writes, so the second could fail on its own (#133).
Future<void> _pump(
  WidgetTester tester,
  Future<bool> Function() onSubmit,
) async {
  // The default 800x600 test view, deliberately: the wizard's step content
  // overflows horizontally at iPhone-Pro width, which is a separate defect
  // and not what this file is about.
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: LoanWizard(
            onSubmit: (_, __, ___, ____, _____, ______, _______) async =>
                onSubmit(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Walks the three steps with the minimum each one needs.
Future<void> _fillAndReachConfirm(WidgetTester tester) async {
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
}

void main() {
  testWidgets('a refused write keeps the wizard open and says so', (
    tester,
  ) async {
    await _pump(tester, () async => false);
    await _fillAndReachConfirm(tester);

    await tester.ensureVisible(find.text('CONFIRM'));
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(
      find.byType(LoanWizard),
      findsOneWidget,
      reason: 'nothing was written, so it must not close as though it was',
    );
    expect(find.textContaining("Couldn't save"), findsOneWidget);
  });

  testWidgets('a write that lands closes the wizard', (tester) async {
    await _pump(tester, () async => true);
    await _fillAndReachConfirm(tester);

    await tester.ensureVisible(find.text('CONFIRM'));
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(find.byType(LoanWizard), findsNothing);
  });
}
