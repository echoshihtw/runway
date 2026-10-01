import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// A label written as a Dart string never reaches the ARB files, so it ships in
/// English to all six languages. The Log empty state carried one:
/// '+ ADD OPENING BALANCE', which also disagreed with the two other screens
/// offering the same action.
void main() {
  test('no screen draws a label the translators never saw', () {
    final offenders = <String>[];
    // Shouty strings of two or more words are labels, not keys or ids.
    final shouty = RegExp(r"""Text\(\s*'([+A-Z][A-Z+ ]{5,})'""");

    for (final f
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      for (final m in shouty.allMatches(f.readAsStringSync())) {
        offenders.add('${f.path}: "${m.group(1)}"');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'draw these from l10n so the other five languages get them',
    );
  });
}
