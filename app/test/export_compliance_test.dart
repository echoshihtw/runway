import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// App Store Connect asks the export compliance question on every upload and
/// holds the build undistributable until it is answered. Declaring the answer
/// in Info.plist answers it once, which matters most for TestFlight, where an
/// unanswered build cannot reach a tester.
///
/// The value is a declaration about the app, not a build setting: false says
/// the app uses no *non-exempt* encryption. Financial Runway ships AES through
/// SQLCipher to encrypt its own database, which is the exemption that was
/// claimed in App Store Connect for the 1.0.0 submission. This test exists so
/// the file and that answer cannot drift apart silently.
void main() {
  late String plist;

  setUpAll(() {
    plist = File('ios/Runner/Info.plist').readAsStringSync();
  });

  test('the export compliance answer is declared, so uploads stop asking', () {
    expect(
      plist,
      contains('<key>ITSAppUsesNonExemptEncryption</key>'),
      reason: 'every upload will prompt, and the build waits until it is '
          'answered by hand',
    );
  });

  test('it claims the exemption, matching what was answered for 1.0.0', () {
    final value = plist
        .split('<key>ITSAppUsesNonExemptEncryption</key>')[1]
        .trimLeft()
        .split('\n')
        .first
        .trim();
    expect(
      value,
      '<false/>',
      reason: 'true means non-exempt encryption, which also requires '
          'ITSEncryptionExportComplianceCode from a CCATS submission',
    );
  });

  test('no compliance code is declared, because none is needed', () {
    // The code only applies to the true branch. Carrying one alongside false
    // would state two different answers to the same question.
    expect(plist, isNot(contains('ITSEncryptionExportComplianceCode')));
  });
}
