import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/router/page_indicator.dart';

Future<List<int>> _pump(WidgetTester tester, {int currentIndex = 0}) async {
  final selected = <int>[];
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: PageIndicator(
            currentIndex: currentIndex,
            onSelect: selected.add,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return selected;
}

void main() {
  testWidgets('labels the three screens', (tester) async {
    await _pump(tester);

    expect(find.text('OVERVIEW'), findsOneWidget);
    expect(find.text('LOG'), findsOneWidget);
    expect(find.text('PLAN'), findsOneWidget);
  });

  testWidgets('tapping a label selects that screen', (tester) async {
    final selected = await _pump(tester);

    await tester.tap(find.text('LOG'));
    await tester.tap(find.text('PLAN'));

    expect(selected, [1, 2]);
  });

  testWidgets('marks the current screen as selected', (tester) async {
    await _pump(tester, currentIndex: 1);

    // The component uppercases for display; the semantics label keeps the
    // written form, so a screen reader says "Log" instead of spelling it.
    expect(
      tester.getSemantics(find.bySemanticsLabel('Log')),
      isSemantics(
        label: 'Log',
        isButton: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
  });
}
