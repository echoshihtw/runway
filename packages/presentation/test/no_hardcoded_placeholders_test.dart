import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A placeholder that spells out an example is a liability, not a help.
///
/// It ships untranslated into six locales, it carries whatever currency and
/// culture the author had in mind, and twice it named a real company. The
/// labels beside these fields already say what they are for.
///
/// Format hints made of digits stay. So do the ones built from a value or
/// taken from the ARB files.
void main() {
  test('no hint spells out an example', () {
    final offenders = <String>[];
    final hint = RegExp(r'''hint:\s*(?:'([^']*)'|"([^"]*)")''');

    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final m in hint.allMatches(lines[i])) {
          final value = m.group(1) ?? m.group(2) ?? '';
          if (!RegExp(r'[A-Za-z]').hasMatch(value)) continue;
          offenders.add('${file.path}:${i + 1}  $value');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Hardcoded placeholder text found. Delete it, or if the field really '
          'needs a hint, put it in the ARB files:\n${offenders.join('\n')}',
    );
  });
}
