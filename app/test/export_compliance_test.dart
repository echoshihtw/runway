import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The export compliance key must stay **out** of Info.plist.
///
/// It has been all three states and only one of them works:
///
/// - `false` tells App Store Connect there is nothing to ask about, so it skips
///   the compliance questions entirely. The app bundles SQLCipher, so there is
///   something to ask about.
/// - `true` asserts that approved export documentation already exists and that
///   its code sits alongside as `ITSEncryptionExportComplianceCode`. There is no
///   such code, so the upload is refused outright — ITMS-90592, hit on the first
///   attempt at 1.0.0.
/// - Absent is the third state and the right one. App Store Connect marks the
///   build Missing Compliance and asks, and the honest answers are standard
///   algorithms, contains third-party cryptography, and the mass market
///   exemption under EAR 740.17(b)(1) with ECCN 5D992.c.
///
/// Recorded in CONTRACTS.md, decided in #199, and re-added as `false` by #237
/// by someone who read neither. This test is why that cannot happen a third
/// time: the decision was written down, and writing it down was not enough.
void main() {
  late String plist;

  setUpAll(() {
    plist = File('ios/Runner/Info.plist').readAsStringSync();
  });

  test('the export compliance key is absent, so Apple asks the question', () {
    expect(
      plist,
      isNot(contains('ITSAppUsesNonExemptEncryption')),
      reason: 'false skips the questions and true needs a code that does not '
          'exist; absent is the state that lets the questionnaire be answered',
    );
  });

  test('no compliance code is declared, because none was ever issued', () {
    expect(
      plist,
      isNot(contains('ITSEncryptionExportComplianceCode')),
      reason: 'a code here without approved documentation is ITMS-90592',
    );
  });
}
