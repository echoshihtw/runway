import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Analytics may say what someone did, never what they have. Every parameter
/// of the port is a closed category, a flag or a locale, so an amount, a name
/// or a note has no way in. A String is only allowed where its value cannot
/// be something the user typed, and each one says why.
const _allowedTypes = {'bool', 'TransactionType', 'BillingCycle', 'Locale'};

const _allowedStrings = {
  'logScreen.name': 'a route path from the router table',
  'logAddLoan.source': "one of the loan wizard's fixed choices",
  'logChangeCurrency.code': 'an ISO 4217 code from supportedCurrencies',
};

bool _allowed(String type, String key) =>
    _allowedTypes.contains(type) ||
    (type == 'String' && _allowedStrings.containsKey(key));

final _port = File(
  '../packages/application/lib/analytics_service.dart',
).readAsStringSync();

/// `name -> [(type, parameter)]` for every method the port declares.
Map<String, List<(String, String)>> _portMethods([String? source]) {
  final body = RegExp(
    r'abstract class AnalyticsService \{(.*?)\n\}',
    dotAll: true,
  ).firstMatch(source ?? _port)!.group(1)!;
  final methods = <RegExpMatch>[];
  // Every member is read, so one the pattern does not know fails here
  // instead of passing unchecked.
  for (final member in body.split(';')) {
    final declaration = member.replaceAll(RegExp(r'//.*'), '').trim();
    if (declaration.isEmpty) continue;
    final m = RegExp(
      r'^Future<void> (\w+)\((.*)\)$',
      dotAll: true,
    ).firstMatch(declaration);
    if (m == null) throw FormatException('unreadable port member', declaration);
    methods.add(m);
  }
  return {
    for (final m in methods)
      m.group(1)!: [
        for (final raw in m.group(2)!.replaceAll(RegExp('[{}]'), '').split(','))
          if (raw.trim().isNotEmpty)
            () {
              final words = raw
                  .split('=')
                  .first
                  .trim()
                  .split(RegExp(r'\s+'))
                  .where((w) => w != 'required')
                  .toList();
              return (words.first, words.last);
            }(),
      ],
  };
}

void main() {
  test('the port is found and declares methods', () {
    expect(_portMethods(), isNotEmpty);
  });

  test('no port parameter can carry an amount or free text', () {
    final offending = <String>[];
    _portMethods().forEach((method, params) {
      for (final (type, name) in params) {
        final key = '$method.$name';
        if (!_allowed(type, key)) offending.add('$key: $type');
      }
    });
    expect(offending, isEmpty);
  });

  test('a member the parser cannot read fails rather than slipping by', () {
    expect(
      () => _portMethods('''
abstract class AnalyticsService {
  Future<void> logSetBudget();
  Future<bool> logNote(String note);
}'''),
      throwsA(anything),
    );
  });

  test('a parameter that could carry money or a note is caught', () {
    // The check above is only worth having if it can fail.
    expect(_allowed('double', 'logSetBudget.rent'), isFalse);
    expect(_allowed('Money', 'logAddTransaction.amount'), isFalse);
    expect(_allowed('String', 'logAddTransaction.note'), isFalse);
  });
}
