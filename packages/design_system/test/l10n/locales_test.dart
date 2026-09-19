import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Chinese ships once, in Traditional. The Simplified file was Simplified in
/// name only — 102 of its values carried Traditional-only characters,
/// including cash, settings and metrics — so a mainland reader got a mixture
/// rather than their own script. One consistent Traditional locale is honest;
/// a Simplified one can be added when it is actually translated.
Future<AppLocalizations> _l10n(WidgetTester tester, Locale locale) async {
  late AppLocalizations l10n;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context);
          return const SizedBox();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return l10n;
}

void main() {
  test('one Chinese locale ships, and no regional variant', () {
    final chinese = AppLocalizations.supportedLocales
        .where((l) => l.languageCode == 'zh')
        .toList();

    expect(chinese, hasLength(1));
    expect(chinese.single.countryCode, isNull);
    expect(chinese.single.scriptCode, isNull);
  });

  test('the shipped locales are the six the listing claims', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.toString()).toList(),
      ['en', 'es', 'fr', 'it', 'ja', 'zh'],
    );
  });

  testWidgets('the Chinese locale serves Traditional characters', (
    tester,
  ) async {
    final l10n = await _l10n(tester, const Locale('zh'));

    // 現 and 錄 exist only in Traditional; 现 and 录 are the Simplified forms.
    expect(l10n.cash, contains('現'));
    expect(l10n.cash, isNot(contains('现')));
    expect(l10n.transactionLog, contains('錄'));
  });

  testWidgets('a Simplified device falls back to that same Traditional copy', (
    tester,
  ) async {
    // Not ideal, and deliberate: Traditional read with effort beats a file
    // that claims to be Simplified and is not.
    final l10n = await _l10n(
      tester,
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      ),
    );

    expect(l10n.cash, contains('現'));
  });
}
