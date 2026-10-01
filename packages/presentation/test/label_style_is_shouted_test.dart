import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `AppTextStyles.label` is the 11pt shouted label. A sentence-case string
/// drawn in it lands beside shouted neighbours and reads as a mistake, which
/// is how the Plan screen showed "Projected runway" next to RUNWAY and CASH.
///
/// Either the ARB value is already caps, or the call site shouts it. A heading
/// is not a label and belongs in `AppTextStyles.title`.
void main() {
  test('every label-styled string is caps by the time it is drawn', () {
    final arb = File(
      '../design_system/lib/l10n/app_en.arb',
    ).readAsStringSync();
    String? valueOf(String key) =>
        RegExp('"$key":\\s*"((?:[^"\\\\]|\\\\.)*)"').firstMatch(arb)?.group(1);

    // Collapsed whitespace, so a call split over lines reads as one.
    final drawn = RegExp(
      r'Text\(\s*l10n\.(\w+)\s*,\s*style:\s*AppTextStyles\.label',
    );

    final offenders = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');
      for (final m in drawn.allMatches(source)) {
        final key = m.group(1)!;
        final value = valueOf(key);
        if (value == null || value == value.toUpperCase()) continue;
        offenders.add('${file.path}  l10n.$key = "$value"');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'A sentence-case string is drawn in the shouted label style. Shout '
          'it at the call site with toUpperCase(), or use AppTextStyles.title '
          'if it is a heading:\n${offenders.join('\n')}',
    );
  });
}
