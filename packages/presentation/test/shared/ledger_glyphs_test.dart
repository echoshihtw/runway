import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The same concept wore three marks: the card, the rows and the log each
/// picked their own. #136 is the collision that produced. The retired glyphs
/// must not creep back in through a new call site.
void main() {
  test('no presentation source draws a retired loan glyph', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      for (final retired in ['Icons.replay_rounded', 'Icons.credit_score_rounded']) {
        if (source.contains(retired)) offenders.add('${file.path}: $retired');
      }
    }
    expect(offenders, isEmpty);
  });
}
