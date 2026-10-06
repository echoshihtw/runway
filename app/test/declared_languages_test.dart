import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

/// Apple builds the App Store's Languages field from CFBundleLocalizations.
/// It cannot see Flutter's localisations, so build 151 listed as English only
/// while the app shipped six languages and the description said so. This ties
/// the declaration to the locales actually shipped, so the two cannot drift.
void main() {
  late String plist;

  setUpAll(() {
    plist = File('ios/Runner/Info.plist').readAsStringSync();
  });

  List<String> declaredLocales() {
    const key = '<key>CFBundleLocalizations</key>';
    expect(plist, contains(key), reason: 'the App Store lists no language');

    final array = plist.split(key)[1].split('</array>')[0];
    return RegExp(r'<string>([^<]+)</string>')
        .allMatches(array)
        .map((m) => m.group(1)!)
        .toList();
  }

  test('every shipped locale is declared to Apple', () {
    // Compared on the language code, because the plist carries the script
    // subtag and Flutter's locale does not.
    expect(
      declaredLocales().map((l) => l.split('-').first).toSet(),
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
    );
  });

  test('nothing is declared that the app does not ship', () {
    expect(
      declaredLocales(),
      hasLength(AppLocalizations.supportedLocales.length),
    );
  });

  test('Chinese is declared Traditional', () {
    // Plain "zh" displays as Simplified on the App Store, which is the one
    // script this app does not ship.
    expect(declaredLocales(), contains('zh-Hant'));
    expect(declaredLocales(), isNot(contains('zh')));
  });
}
