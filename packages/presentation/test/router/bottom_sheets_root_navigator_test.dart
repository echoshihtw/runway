import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The three screens live in nested navigators under the app shell, and the
/// shell draws the HOME, LOG and PLAN labels above them. A bottom sheet opened
/// on a screen's own navigator slides in underneath those labels. Every sheet
/// must open on the root navigator so it covers them.
void main() {
  test('every bottom sheet opens on the root navigator', () {
    final call = RegExp(r'showModalBottomSheet(?:<[^>]*>)?\(');
    final offenders = <String>[];
    var calls = 0;

    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final source = file.readAsStringSync();
      for (final match in call.allMatches(source)) {
        calls++;
        // The named arguments come first in every call; look at the opening lines.
        final head = source.substring(
          match.end,
          (match.end + 200).clamp(0, source.length),
        );
        if (!head.contains('useRootNavigator: true')) {
          final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;
          offenders.add('${file.path}:$line');
        }
      }
    }

    expect(calls, greaterThan(0));
    expect(offenders, isEmpty, reason: 'Add useRootNavigator: true to these sheets');
  });
}
