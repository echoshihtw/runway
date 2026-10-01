import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The mono numerals are the app's typographic signature, and the split broke
/// in the one place it is most visible: every figure the owner typed came out
/// in the label face while the figures printed beside it were mono.
Future<TextStyle?> _styleOf(WidgetTester tester, NeoInputType type) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: NeoInput(
          label: 'FIELD',
          controller: TextEditingController(),
          inputType: type,
          hint: '0',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.widget<TextField>(find.byType(TextField)).style;
}

bool _isMono(TextStyle? s) => (s?.fontFamily ?? '').contains('JetBrains');

void main() {
  testWidgets('an amount is typed in the mono face', (tester) async {
    expect(_isMono(await _styleOf(tester, NeoInputType.decimal)), isTrue);
    expect(_isMono(await _styleOf(tester, NeoInputType.numeric)), isTrue);
  });

  testWidgets('words are typed in the reading face', (tester) async {
    expect(_isMono(await _styleOf(tester, NeoInputType.name)), isFalse);
    expect(_isMono(await _styleOf(tester, NeoInputType.note)), isFalse);
    expect(_isMono(await _styleOf(tester, NeoInputType.text)), isFalse);
  });

  testWidgets('the hint matches the field it sits in', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: NeoInput(
            label: 'AMOUNT',
            controller: TextEditingController(),
            inputType: NeoInputType.decimal,
            hint: '50,000',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(_isMono(field.decoration?.hintStyle), isTrue);
  });

  test('a caption-sized amount keeps its size and changes only its face', () {
    expect(
      AppTextStyles.metricCaption.fontSize,
      AppTextStyles.caption.fontSize,
    );
    expect(_isMono(AppTextStyles.metricCaption), isTrue);
    expect(_isMono(AppTextStyles.caption), isFalse);
  });
}
