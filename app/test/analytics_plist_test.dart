import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Firebase reads these from Info.plist before any Dart runs. Each one keeps
/// analytics to the events the app sends itself, never an advertising signal or
/// a device-level identifier, and stops Firebase logging the single Flutter
/// view controller as a screen next to the app's own screen views.
void main() {
  late String plist;

  setUpAll(() {
    plist = File('ios/Runner/Info.plist').readAsStringSync();
  });

  for (final key in <String>[
    'GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_PERSONALIZATION_SIGNALS',
    'GOOGLE_ANALYTICS_IDFV_COLLECTION_ENABLED',
    'FirebaseAutomaticScreenReportingEnabled',
  ]) {
    test('$key is off', () {
      expect(
        RegExp('<key>$key</key>\\s*<false/>').hasMatch(plist),
        isTrue,
        reason: '$key must be present and false',
      );
    });
  }
}
