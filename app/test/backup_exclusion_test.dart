import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The encrypted database lives in Documents, which iOS backs up, while its
/// key is stored this-device-only and is not. A restored device carried a
/// database it could never open, and the app minted a new key over it, which
/// bricked it for good.
///
/// `Info.plist` claimed to handle this with `NSURLIsExcludedFromBackupKey`,
/// which does nothing at all: it is an NSURL resource attribute set through
/// `setResourceValues`, not a plist key. Having it there is worse than not,
/// because it reads as though the job were done. The real exclusion is in
/// `AppDelegate.excludeDocumentsFromBackup`.
void main() {
  test('the plist does not pretend to exclude the database from backup', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, isNot(contains('NSURLIsExcludedFromBackupKey')));
  });

  test('the exclusion is done where it actually works', () {
    final delegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    expect(delegate, contains('isExcludedFromBackup'));
    expect(delegate, contains('excludeDocumentsFromBackup'));
  });
}
