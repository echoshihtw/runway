import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Exporting the 1.0.1 archive failed with no signing identity to use. The
/// Runner target carried
/// `"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Distribution"` on top of its
/// own `CODE_SIGN_IDENTITY = "Apple Distribution"`, and within one level a
/// matching condition beats the unconditional value, so every device build
/// asked for "iPhone Distribution". xcodebuild matches identities by name
/// prefix, and the certificate in the keychain is named
/// "Apple Distribution: …", so nothing matched.
///
/// Xcode writes those overrides back whenever signing is edited in the UI,
/// which is how they arrived. This is the guard.
void main() {
  late String pbxproj;
  late Map<String, String> runner;

  setUpAll(() {
    pbxproj = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    runner = _configurationsOfTarget(pbxproj, 'Runner');
  });

  test('the Runner target still has the three configurations', () {
    // If this fails the rest of the file is asserting about nothing.
    expect(runner.keys, containsAll(<String>['Debug', 'Release', 'Profile']));
  });

  test('Release signs the way the manual export expects', () {
    final release = runner['Release']!;
    expect(release, contains('CODE_SIGN_IDENTITY = "Apple Distribution";'));
    expect(release, contains('CODE_SIGN_STYLE = Manual;'));
    expect(
      release,
      contains('PROVISIONING_PROFILE_SPECIFIER = "Financial Runway App Store";'),
    );
  });

  test('Debug signs with a development certificate', () {
    expect(
      runner['Debug']!,
      contains('CODE_SIGN_IDENTITY = "Apple Development";'),
    );
  });

  test('no sdk-qualified identity names a distribution certificate', () {
    // Deliberately not "no sdk-qualified identity at all": Xcode's own
    // project-level defaults pin Apple Development that way for all three
    // configurations, the target's own settings outrank them, and they are
    // wanted. What must never come back is a *distribution* certificate named
    // through a condition.
    final identities = RegExp(r'"CODE_SIGN_IDENTITY\[sdk[^"]*"\s*=\s*([^;]+);')
        .allMatches(pbxproj)
        .map((m) => m.group(1)!.trim())
        .toList();

    expect(identities, isNotEmpty, reason: "Xcode's own defaults should remain");
    for (final identity in identities) {
      expect(
        identity,
        isNot(contains('Distribution')),
        reason: 'a device build would ask for $identity, and the export cannot '
            'find a certificate under that name',
      );
    }
  });

  test('the team is one constant, not a conditional pair', () {
    // A conditional team alongside the plain one is the same trap one setting
    // over: two values, and which applies depends on the sdk being built.
    expect(pbxproj, isNot(contains('DEVELOPMENT_TEAM[sdk')));
    for (final name in <String>['Debug', 'Release', 'Profile']) {
      expect(
        runner[name]!,
        contains('DEVELOPMENT_TEAM = ZU622WJ4SH;'),
        reason: '$name must name the team, or signing falls back to a guess',
      );
    }
  });
}

/// The `XCBuildConfiguration` blocks belonging to one native target, by name.
///
/// Whole-file matching cannot tell the Runner target's settings from the
/// project-level defaults or the RunnerTests target's, and those three levels
/// are exactly what went wrong here.
Map<String, String> _configurationsOfTarget(String pbxproj, String target) {
  final list = RegExp(
    'Build configuration list for PBXNativeTarget "$target" \\*/ = \\{'
    r'.*?buildConfigurations = \((.*?)\);',
    dotAll: true,
  ).firstMatch(pbxproj);
  expect(list, isNotNull, reason: 'no build configuration list for $target');

  final configurations = <String, String>{};
  for (final line in RegExp(r'(\w{24}) /\* (\w+) \*/,')
      .allMatches(list!.group(1)!)) {
    final id = line.group(1)!;
    final block = RegExp(
      '$id /\\* ${line.group(2)} \\*/ = \\{\\n'
      r'\t+isa = XCBuildConfiguration;.*?\n\t+\};',
      dotAll: true,
    ).firstMatch(pbxproj);
    expect(block, isNotNull, reason: 'no XCBuildConfiguration $id');
    configurations[line.group(2)!] = block!.group(0)!;
  }
  return configurations;
}
