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
            onSubmit: (_, _, _, _, _, _, _) async => onSubmit(),
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

  testWidgets('two taps on CONFIRM submit once', (tester) async {
    // Disabling the button is not a guard: setState only schedules a rebuild,
    // so until a frame renders it is still live and NeoButton fires on tap-up.
    // A loan creation is two writes, so a second entry duplicates both (#277).
    var attempts = 0;
    await _pump(tester, () async {
      attempts++;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return true;
    });
    await _fillAndReachConfirm(tester);

    await tester.ensureVisible(find.text('CONFIRM'));
    await tester.tap(find.text('CONFIRM'));
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(attempts, 1, reason: 'one tap-up too many is a second loan');
  });

  testWidgets('a write that throws is reported, not swallowed', (tester) async {
    // A throw used to strand _saving, and the button reads !_saving, so
    // CONFIRM went dead with nothing said.
    await _pump(tester, () async => throw Exception('disk is full'));
    await _fillAndReachConfirm(tester);

    await tester.ensureVisible(find.text('CONFIRM'));
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(
      find.byType(LoanWizard),
      findsOneWidget,
      reason: 'nothing was written',
    );
    expect(find.textContaining("Couldn't save"), findsOneWidget);
    expect(
      tester
          .widget<NeoButton>(
            find.ancestor(
              of: find.text('CONFIRM'),
              matching: find.byType(NeoButton),
            ),
          )
          .onPressed,
      isNotNull,
      reason: 'CONFIRM has to come back, or the wizard is dead',
    );
  });

  testWidgets('two taps on NEXT advance one step', (tester) async {
    // Same fault as CONFIRM, and the same cause: NeoButton fires on tap-up
    // against an onPressed captured at build time, so two tap-ups in one frame
    // both land. Skipping the term page leaves termMo at 0, an open-ended
    // loan nobody chose (#277).
    await _pump(tester, () async => true);

    await tester.enterText(find.byType(TextField).at(0), 'Fubon');
    await tester.enterText(find.byType(TextField).at(1), '120000');
    await tester.pump();

    await tester.ensureVisible(find.textContaining('NEXT'));
    await tester.tap(find.textContaining('NEXT'));
    await tester.tap(find.textContaining('NEXT'));
    await tester.pumpAndSettle();

    expect(find.text('2 / 3'), findsOneWidget, reason: 'one tap, one step');
  });

  testWidgets('two taps on NEXT advance one step after going back', (
    tester,
  ) async {
    // Re-checking validity in _next looked like a fix and was not: coming back
    // to a step leaves its field filled, so the check passes on the second
    // tap-up and the wizard jumps 1/3 to 3/3. The press has to be refused for
    // being a second press, not for landing somewhere invalid.
    await _pump(tester, () async => true);
    await _fillAndReachConfirm(tester);

    await tester.ensureVisible(find.text('BACK'));
    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget, reason: 'back at the start');

    await tester.ensureVisible(find.textContaining('NEXT'));
    await tester.tap(find.textContaining('NEXT'));
    await tester.tap(find.textContaining('NEXT'));
    await tester.pumpAndSettle();

    expect(find.text('2 / 3'), findsOneWidget, reason: 'one tap, one step');
  });
}
