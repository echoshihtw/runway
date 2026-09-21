import 'package:flutter/material.dart';
import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

/// Every control in this app was a bare GestureDetector, which carries no
/// role. A screen reader announced each one as static text, with nothing to
/// say it could be activated and nothing to tell a disabled button from a
/// live one.
///
/// These components are where the app's controls actually live, so the role
/// belongs here rather than at each of the call sites.
Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(home: Scaffold(body: Center(child: child))),
);

SemanticsData _of(WidgetTester tester, String label) =>
    tester.getSemantics(find.bySemanticsLabel(label)).getSemanticsData();

void main() {
  testWidgets('a button says it is a button, and says it once', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, NeoButton(label: 'CONFIRM', onPressed: () {}));

    // getSemantics throws on more than one match, so this also proves the
    // label is not announced twice by the button and its own Text.
    final data = _of(tester, 'CONFIRM');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    expect(
      data.flagsCollection.isEnabled,
      Tristate.isTrue,
      reason: 'a live button has to sound live',
    );
    semantics.dispose();
  });

  testWidgets('a disabled button does not sound like a live one', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, const NeoButton(label: 'CONFIRM'));

    final data = _of(tester, 'CONFIRM');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.flagsCollection.isEnabled, Tristate.isFalse);
    expect(
      data.hasAction(SemanticsAction.tap),
      isFalse,
      reason: 'nothing happens on tap, so nothing should offer it',
    );
    semantics.dispose();
  });

  testWidgets('an expandable card reports whether it is open', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      const NeoExpandableCard(
        title: 'Liabilities',
        summary: Text('DEBT/MO'),
        details: Text('the loans'),
      ),
    );

    final closed = _of(tester, 'LIABILITIES');
    expect(closed.flagsCollection.isButton, isTrue);
    expect(
      closed.flagsCollection.isExpanded,
      Tristate.isFalse,
      reason: 'a card that opens has to say it opens, and that it is shut',
    );

    await tester.tap(find.text('LIABILITIES'));
    await tester.pumpAndSettle();
    expect(
      _of(tester, 'LIABILITIES').flagsCollection.isExpanded,
      Tristate.isTrue,
      reason: 'the state has to change with the card',
    );
    semantics.dispose();
  });

  testWidgets('a card with nothing to expand claims nothing', (tester) async {
    // Half the cards in the app have no details. Marking those as buttons
    // would offer an action that does not exist.
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      const NeoExpandableCard(title: 'Goal', summary: Text('6 MONTHS')),
    );

    final data = _of(tester, 'GOAL').flagsCollection;
    expect(data.isButton, isFalse);
    expect(
      data.isExpanded,
      Tristate.none,
      reason: 'there is no open or shut to report',
    );
    semantics.dispose();
  });

  testWidgets('a card is a control only when tapping it does something', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await _pump(tester, const NeoCard(child: Text('nothing happens')));
    expect(
      tester
          .getSemantics(find.text('nothing happens'))
          .getSemanticsData()
          .flagsCollection
          .isButton,
      isFalse,
    );

    await _pump(
      tester,
      NeoCard(onTap: () {}, child: const Text('something happens')),
    );
    expect(
      tester
          .getSemantics(find.byType(NeoCard))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    semantics.dispose();
  });
}
