import 'dart:convert';
import 'dart:io';

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

  test('every locale says exactly what the template declares', () {
    // A message added to the template and forgotten elsewhere ships English
    // into that language. gen-l10n does not fail for it: it warns during a
    // build nobody reads, then falls back, so the app runs and the tests pass
    // and the only way to find out is to switch language and look.
    //
    // The files are read from the directory rather than listed here. A list
    // would be a second thing to keep in step, which is the fault this is for.
    Set<String> messagesIn(File f) {
      final json = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      // @-prefixed entries describe a message rather than being one.
      return json.keys.where((k) => !k.startsWith('@')).toSet();
    }

    final files = Directory('lib/l10n')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.arb'))
        .toList();
    final template = files.singleWhere((f) => f.path.endsWith('app_en.arb'));
    final expected = messagesIn(template);
    expect(expected, isNotEmpty, reason: 'the template declares nothing');

    final problems = <String>[];
    for (final file in files.where((f) => f != template)) {
      final name = file.uri.pathSegments.last;
      final messages = messagesIn(file);
      final missing = expected.difference(messages);
      final extra = messages.difference(expected);
      if (missing.isNotEmpty) {
        problems.add('$name falls back to English for: ${missing.join(', ')}');
      }
      if (extra.isNotEmpty) {
        problems.add('$name keeps messages nothing reaches: ${extra.join(', ')}');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
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
