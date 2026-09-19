import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every name and note field in the app filtered its input through an
/// allow-list of ASCII characters, so a lender, a subscription or a note could
/// not be written in the language the app was translated into. The field
/// simply stayed empty, and the wizard's NEXT never enabled, with nothing on
/// screen to say why.
Future<TextEditingController> _type(
  WidgetTester tester,
  NeoInputType type,
  String text,
) async {
  final ctrl = TextEditingController();
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: NeoInput(label: 'FIELD', controller: ctrl, inputType: type),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  return ctrl;
}

void main() {
  testWidgets('a name can be written in Traditional Chinese', (tester) async {
    expect((await _type(tester, NeoInputType.name, '富邦銀行')).text, '富邦銀行');
  });

  testWidgets('a name can be written in Japanese', (tester) async {
    expect((await _type(tester, NeoInputType.name, '田中さん')).text, '田中さん');
  });

  testWidgets('a note can be written in Traditional Chinese', (tester) async {
    expect((await _type(tester, NeoInputType.note, '買車頭期款')).text, '買車頭期款');
  });

  testWidgets('a note can be written in Spanish with accents', (tester) async {
    expect(
      (await _type(tester, NeoInputType.note, 'café años')).text,
      'café años',
    );
  });

  testWidgets('free text takes Simplified Chinese', (tester) async {
    expect((await _type(tester, NeoInputType.text, '房租')).text, '房租');
  });

  testWidgets('an amount still refuses anything but a number', (tester) async {
    // The decimal filter keeps the leading run that parses and drops the
    // rest, so a stray letter truncates rather than being skipped over.
    expect((await _type(tester, NeoInputType.decimal, '12.45')).text, '12.45');
    expect((await _type(tester, NeoInputType.decimal, '12a3')).text, '12');
    expect((await _type(tester, NeoInputType.decimal, '一二三')).text, '');
  });

  testWidgets('a whole number still refuses anything but digits', (
    tester,
  ) async {
    expect((await _type(tester, NeoInputType.numeric, '3六6')).text, '36');
  });
}
