import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every package is linted, and every package is analysed.
///
/// Five of the six packages carried a lints dev dependency and no
/// analysis_options.yaml to apply it, so `dart analyze` ran with only the
/// built-in errors on. `make analyze` was green while ninety-odd issues stood,
/// two of them real: application imported shared_preferences from a dev
/// dependency, and uuid was never declared at all. Both worked only because
/// another package in the workspace happened to pull them in.
///
/// Nothing announced that. The dependency was paid for and the rules were
/// never loaded, which is the failure mode a passing build hides best. A
/// seventh package would arrive the same way, so this asserts the two things
/// that have to be true of every one of them.
void main() {
  final root = Directory('..');

  List<Directory> packages() =>
      Directory('${root.path}/packages')
          .listSync()
          .whereType<Directory>()
          .where((d) => File('${d.path}/pubspec.yaml').existsSync())
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('every package applies a lint rule set', () {
    expect(packages(), isNotEmpty, reason: 'no packages found to check');
    for (final package in packages()) {
      expect(
        File('${package.path}/analysis_options.yaml').existsSync(),
        isTrue,
        reason:
            '${package.path.split('/').last} has no analysis_options.yaml, so '
            'its lint dependency is never applied',
      );
    }
  });

  test('make analyze reaches every package', () {
    // The target names its packages one line at a time, so a new one is
    // linted by the rule above and still never looked at by CI.
    final makefile = File('${root.path}/Makefile').readAsStringSync();
    final analyze = makefile.split('\nanalyze:')[1].split('\n\n')[0];
    for (final package in packages()) {
      final name = package.path.split('/').last;
      expect(
        analyze,
        contains('packages/$name'),
        reason: 'make analyze never analyses $name',
      );
    }
  });
}
