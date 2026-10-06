import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A NeoButton that is not full width is laid out at its own width. As a plain
/// child of a Row it gets unbounded constraints, so the Flexible around its
/// label is treated as non-flex and the label never ellipsises: at large text
/// sizes the row simply ran off the screen. Wrap is the shape that holds, and
/// it has to keep the buttons right-aligned when they do fit on one line — a
/// Flexible would hand each an equal share and shift them left.
Widget _wrap(Widget child, {double width = 390, double scale = 1.0}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: SizedBox(width: width, child: child),
        ),
      ),
    );

Widget _buttons() => Wrap(
  alignment: WrapAlignment.end,
  spacing: AppSpacing.sm,
  runSpacing: AppSpacing.sm,
  children: const [
    NeoButton(label: 'CLEAR', onPressed: null),
    NeoButton(label: 'SET ASSUMPTIONS', onPressed: null),
  ],
);

void main() {
  testWidgets('the buttons stay against the right edge when they fit', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_buttons()));
    await tester.pumpAndSettle();

    final last = tester.getRect(find.byType(NeoButton).last);
    expect(
      last.right,
      moreOrLessEquals(390, epsilon: 1),
      reason: 'right-aligned, not sitting in the left half of a flex share',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the buttons take a second line rather than run off the edge', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_buttons(), width: 320, scale: 2.0));
    await tester.pumpAndSettle();

    final first = tester.getRect(find.byType(NeoButton).first);
    final second = tester.getRect(find.byType(NeoButton).last);

    expect(tester.takeException(), isNull, reason: 'nothing overflowed');
    expect(
      second.top,
      greaterThan(first.top),
      reason: 'it wrapped onto its own line',
    );
    expect(first.right, lessThanOrEqualTo(320));
    expect(second.right, lessThanOrEqualTo(320));
  });
}
