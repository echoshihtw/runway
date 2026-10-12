import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Copy never joins words with an em dash. A lone "—" standing in for a value
/// that is not known yet is a placeholder, not prose, so it is allowed, with at
/// most one interpolation beside it (a currency symbol, say).
void main() {
  test('no string literal in lib joins words with an em dash', () {
    final literal = RegExp(r"'([^'\\]|\\.)*'");
    final interpolation = RegExp(r'\$\{[^}]*\}|\$[A-Za-z_][A-Za-z0-9_]*');
    final offending = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trimLeft();
        if (line.startsWith('//')) continue;
        for (final m in literal.allMatches(line)) {
          final text = m.group(0)!;
          if (!text.contains('—')) continue;
          final parts = interpolation.allMatches(text).length;
          final rest = text.replaceAll(interpolation, '').replaceAll(RegExp(r"[\s'—]"), '');
          final placeholder = rest.isEmpty && parts <= 1;
          if (!placeholder) offending.add('${file.path}:${i + 1}: $text');
        }
      }
    }
    expect(offending, isEmpty);
  });
}
