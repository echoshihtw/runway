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

  test('a missing cipher version throws', () {
    expect(
      () => ensureSqlCipher(null, fatal: true),
      throwsA(isA<SqlCipherUnavailableError>()),
    );
  });

  test('reporting instead of throwing is available, but is not the default', () {
    final reported = <Object>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) => reported.add(details.exception);
    addTearDown(() => FlutterError.onError = previous);

    ensureSqlCipher(null, fatal: false);

    expect(reported.single, isA<SqlCipherUnavailableError>());
  });

  test('the default is fatal, in release as much as in debug', () {
    // It used to default to kDebugMode, so a release build whose SQLCipher
    // linkage regressed wrote plaintext and only filed a report nobody reads,
    // while the listing promised the data was encrypted on the device.
    expect(
      () => ensureSqlCipher(null),
      throwsA(isA<SqlCipherUnavailableError>()),
    );
  });
}
