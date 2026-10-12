import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The privacy page and the privacy manifest say Runway collects no analytics.
/// Firebase coming back would make both untrue without anyone editing either,
/// so it fails here first.
void main() {
  test('pubspec depends on no Firebase package', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, isNot(contains('firebase_')));
  });

  test('no file under lib imports Firebase', () {
    final importers = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => f.readAsStringSync().contains('package:firebase_'))
        .map((f) => f.path)
        .toList();
    expect(importers, isEmpty);
  });
}
