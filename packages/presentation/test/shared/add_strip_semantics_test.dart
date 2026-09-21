import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/shared/add_strip.dart';

/// The strip was a bare GestureDetector: a screen reader read "NEW LOAN" as
/// static text at the foot of a card, with nothing to say it was the way to
/// add one.
void main() {
  testWidgets('the add strip is a control, not a caption', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddStrip(label: 'NEW LOAN', color: SC.accentCost, onTap: () {}),
        ),
      ),
    );

    // getSemantics throws on more than one match, so this also proves the
    // label is not announced twice by the strip and its own Text.
    final data = tester
        .getSemantics(find.bySemanticsLabel('NEW LOAN'))
        .getSemanticsData();
    expect(data.flagsCollection.isButton, isTrue);
    // No enabled/disabled assertion: AddStrip.onTap is required and
    // non-null, so the strip has no disabled state to report.
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    semantics.dispose();
  });
}
