import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every package is linted, and CI analyses every package.
///
/// No package carried an analysis_options.yaml, so `dart analyze` ran with only
/// the built-in errors on and the build was green while ninety-odd issues
/// stood. Two were real: `application` imported shared_preferences from a dev
/// dependency and used uuid without declaring it.
///
/// Checked against ci.yml, not the Makefile. CI enumerates its own steps, so a
/// package added to the Makefile alone is never analysed on a pull request.
void main() {
  final root = Directory('..');

  /// Every workspace package, `app` included. `app` holds the rule set for the
  /// shipped binary and lives outside packages/.
  List<Directory> packages() => [
    ...Directory('${root.path}/packages')
        .listSync()
        .whereType<Directory>()
        .where((d) => File('${d.path}/pubspec.yaml').existsSync()),
    Directory('${root.path}/app'),
  ]..sort((a, b) => a.path.compareTo(b.path));

  test('every package applies a lint rule set', () {
    expect(packages(), hasLength(greaterThan(1)));
    for (final package in packages()) {
      final options = File('${package.path}/analysis_options.yaml');
      final name = package.path.split('/').last;

      expect(options.existsSync(), isTrue, reason: '$name has no lint config');
      // Existing is not enough: a file with no include applies no rules.
      expect(
        options.readAsStringSync(),
        contains('include: package:'),
        reason: '$name has a lint config that pulls in no rule set',
      );
    }
  });

  test('CI analyses every package', () {
    final ci = File('${root.path}/.github/workflows/ci.yml').readAsStringSync();
    // Comments do not run, so a step commented out must not satisfy this.
    final steps = ci
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('#'))
        .join('\n');

    for (final package in packages()) {
      final name = package.path.split('/').last;
      final dir = name == 'app' ? 'app' : 'packages/$name';
      expect(
        steps,
        contains('cd $dir && '),
        reason: 'ci.yml never runs anything in $dir',
      );
      expect(
        RegExp('cd ${RegExp.escape(dir)} && (dart|flutter) analyze'),
        predicate<RegExp>((r) => r.hasMatch(steps)),
        reason: 'ci.yml never analyses $dir',
      );
    }
  });
}
