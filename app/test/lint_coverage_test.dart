import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every package is linted, and CI analyses every package.
///
/// No package carried an analysis_options.yaml, so `dart analyze` ran with only
/// the built-in errors on and the build was green while ninety-odd issues
/// stood. Two were real: `application` imported shared_preferences from a dev
/// dependency and used uuid without declaring it.
///
/// CI runs `make analyze` and `make test`, so the package list lives once, in
/// the Makefile. Both are checked: CI must call the targets, and the targets
/// must reach every package, analyse it with --fatal-infos and test it.
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

  /// The commands of one Makefile target, up to the next blank line.
  String target(String makefile, String name) {
    final start = makefile.indexOf(RegExp('^$name:', multiLine: true));
    expect(start, isNot(-1), reason: 'the Makefile has no $name target');
    final end = makefile.indexOf('\n\n', start);
    return makefile.substring(start, end == -1 ? makefile.length : end);
  }

  test('CI analyses and tests every package', () {
    final ci = File('${root.path}/.github/workflows/ci.yml').readAsStringSync();
    // Comments do not run, so a step commented out must not satisfy this.
    final steps = ci
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('#'))
        .join('\n');
    expect(steps, contains('make analyze'), reason: 'ci.yml never analyses');
    expect(steps, contains('make test'), reason: 'ci.yml never tests');

    final makefile = File('${root.path}/Makefile').readAsStringSync();
    final analyze = target(makefile, 'analyze');
    final tests = target(makefile, 'test');
    for (final package in packages()) {
      final name = package.path.split('/').last;
      final dir = name == 'app' ? r'(app|\$\(APP_DIR\))' : 'packages/$name';
      expect(
        RegExp('cd $dir && \\S+(?: flutter)? analyze --fatal-infos'),
        predicate<RegExp>((r) => r.hasMatch(analyze)),
        reason: 'make analyze never analyses $name with --fatal-infos',
      );
      expect(
        RegExp('cd $dir && .*test'),
        predicate<RegExp>((r) => r.hasMatch(tests)),
        reason: 'make test never tests $name',
      );
    }
  });
}
