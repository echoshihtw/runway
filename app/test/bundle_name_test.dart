import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The store listing, the site, the Devpost entry and the demo video script all
/// say "Financial Runway". The home screen said "Runway" until 2026-09-16, so
/// the icon disagreed with everything the product is marketed as. This guards
/// the user-visible name against drifting back.
void main() {
  late String plist;

  setUpAll(() {
    plist = File('ios/Runner/Info.plist').readAsStringSync();
  });

  test('the home screen name is the name the listing uses', () {
    expect(plist, contains('<key>CFBundleDisplayName</key>'));
    expect(
      plist.split('<key>CFBundleDisplayName</key>')[1].trimLeft(),
      startsWith('<string>Financial Runway</string>'),
    );
  });

  test('the short name stays inside Apple guidance', () {
    // CFBundleName is the short name; Apple's guideline is 15 characters, and
    // "Financial Runway" is 16, so the full name belongs in the display name.
    final shortName = plist
        .split('<key>CFBundleName</key>')[1]
        .trimLeft()
        .split('<string>')[1]
        .split('</string>')[0];

    expect(shortName, isNotEmpty);
    expect(shortName.length, lessThanOrEqualTo(15));
  });
}
