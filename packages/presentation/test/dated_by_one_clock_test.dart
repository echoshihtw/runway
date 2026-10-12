import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every date the screens write comes from clockProvider, so a pinned clock
/// (tests, the store captures) sees one day across the whole record. A direct
/// DateTime.now() here would date money by the device instead.
void main() {
  test('no screen reads the device clock directly', () {
    final offending = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trimLeft();
        if (line.startsWith('//')) continue;
        if (line.contains('DateTime.now()')) {
          offending.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(
      offending,
      isEmpty,
      reason: 'read ref.read(clockProvider)() instead',
    );
  });
}
