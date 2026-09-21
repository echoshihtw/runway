import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Uppercase was baked into content and also applied in code, so the label
/// voice changed screen to screen and the decision could not be undone for the
/// locales that ship. One mechanism now: the component uppercases, the
/// translation carries sentence case.
///
/// Every title below is rendered through a component that uppercases it, so a
/// baked-caps value renders the same but takes the decision away from the
/// design system.
const componentTitles = [
  'currency',
  'current',
  'language',
  'liabilities',
  'monthlyBudget',
  'subscriptions',
  'thisMonth',
  'dataSection',
  'futureAssumptions',
  'goal',
  'runwayGoal',
  'simulate',
];

/// Body text is never uppercased by anything, so caps there are permanent.
const bodyText = ['simHint'];

/// The rest of the file is the backlog. It may only shrink. Japanese and
/// Chinese are absent: their strings have no case, so uppercasing is the
/// identity and a count would mean nothing.
const bakedCapsBudget = <String, int>{
  'app_en.arb': 137,
  'app_es.arb': 154,
  'app_fr.arb': 154,
  'app_it.arb': 154,
};

Map<String, String> _strings(String file) {
  final raw = jsonDecode(File('lib/l10n/$file').readAsStringSync()) as Map;
  return {
    for (final e in raw.entries)
      if (!e.key.startsWith('@') && e.value is String)
        e.key as String: e.value as String,
  };
}

bool _isBakedCaps(String v) => v.toUpperCase() == v && v.toLowerCase() != v;

void main() {
  for (final file in bakedCapsBudget.keys) {
    test('$file leaves a component title to the component', () {
      final strings = _strings(file);
      final baked = [
        for (final key in componentTitles)
          if (_isBakedCaps(strings[key] ?? '')) '$key = "${strings[key]}"',
      ];
      expect(
        baked,
        isEmpty,
        reason: 'write these in sentence case; the card uppercases them',
      );
    });

    test('$file keeps body text out of upper case', () {
      final strings = _strings(file);
      final shouting = [
        for (final key in bodyText)
          if (_isBakedCaps(strings[key] ?? '')) key,
      ];
      expect(
        shouting,
        isEmpty,
        reason: 'nothing uppercases these, so the caps stick',
      );
    });

    test('$file does not add to the baked-caps backlog', () {
      final count = _strings(file).values.where(_isBakedCaps).length;
      final budget = bakedCapsBudget[file]!;
      expect(
        count,
        lessThanOrEqualTo(budget),
        reason: 'a new string carries sentence case; the component shouts',
      );
      expect(
        count,
        budget,
        reason: 'good — lower the budget for $file to $count',
      );
    });
  }
}
