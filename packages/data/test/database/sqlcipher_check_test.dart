import 'package:data/data.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

void main() {
  test('plain SQLite reports no cipher version', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await readCipherVersion(db), isNull);
  });

  test('a cipher version passes', () {
    expect(() => ensureSqlCipher('4.6.1 community', fatal: true), returnsNormally);
  });

  test('a missing cipher version is fatal in debug builds', () {
    expect(
      () => ensureSqlCipher(null, fatal: true),
      throwsA(isA<SqlCipherUnavailableError>()),
    );
  });

  test('a missing cipher version is reported in release builds', () {
    final reported = <Object>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) => reported.add(details.exception);
    addTearDown(() => FlutterError.onError = previous);

    ensureSqlCipher(null, fatal: false);

    expect(reported.single, isA<SqlCipherUnavailableError>());
  });
}
