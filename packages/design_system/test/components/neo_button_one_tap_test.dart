import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// onPressed is captured at build time and setState only schedules a rebuild,
/// so a caller that disables itself on the first press is still live until a
/// frame renders. Every caller inherited that: a loan wrote twice, a
/// subscription submitted twice, a step was skipped (#277).
Future<int> _taps(
  WidgetTester tester,
  Future<void> Function(Finder) tap,
) async {
  var fired = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: NeoButton(label: 'GO', onPressed: () => fired++),
      ),
    ),
  );
  await tap(find.text('GO'));
  await tester.pumpAndSettle();
  return fired;
}

void main() {
  testWidgets('two tap-ups in one frame press once', (tester) async {
    final fired = await _taps(tester, (go) async {
      await tester.tap(go);
      await tester.tap(go);
    });

    expect(fired, 1, reason: 'one tap-up too many is a second write');
  });

  // The half that keeps the latch honest. It clears on a rendered frame, and
  // that frame only arrives if one is asked for, so a callback that changes
  // nothing could otherwise leave the button dead for the life of the widget.
  testWidgets('two tap-ups in separate frames press twice', (tester) async {
    final fired = await _taps(tester, (go) async {
      await tester.tap(go);
      await tester.pumpAndSettle();
      await tester.tap(go);
    });

    expect(fired, 2, reason: 'the latch has to let go, or the button is dead');
  });

  // A screen reader activates the Semantics node, not the GestureDetector, so
  // a latch on the pointer path alone can be walked straight around.
  testWidgets('two screen reader taps in one frame press once', (tester) async {
    final handle = tester.ensureSemantics();
    var fired = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoButton(label: 'GO', onPressed: () => fired++),
        ),
      ),
    );

    final go = find.semantics.byLabel('GO');
    tester.semantics.performAction(go, SemanticsAction.tap);
    tester.semantics.performAction(go, SemanticsAction.tap);
    await tester.pumpAndSettle();

    expect(fired, 1, reason: 'the reader goes through the same one press');
    handle.dispose();
  });

  // A callback that rebuilds nothing is the case that strands the latch.
  testWidgets('a button whose press changes nothing stays live', (
    tester,
  ) async {
    var fired = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoButton(label: 'GO', onPressed: () => fired++),
        ),
      ),
    );

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('GO'));
      await tester.pumpAndSettle();
    }

    expect(fired, 3, reason: 'nothing here schedules a frame but the latch');
  });
}
