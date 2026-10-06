import 'dart:io';

import 'package:data/data.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

/// Seconds since the epoch, which is how drift stores a DateTime.
int _at(int y, int m, int d) =>
    DateTime(y, m, d).millisecondsSinceEpoch ~/ 1000;

/// A version 6 database holding charges confirmed under the stepping schedule.
///
/// Ids are written out rather than derived, so this states what is on a device
/// instead of trusting the code under test.
Future<void> _seedVersion6(File file) async {
  final current = AppDatabase.forTesting(NativeDatabase(file));
  await current.customSelect('SELECT 1').get();
  await current.close();

  final raw = sqlite3.open(file.path);
  final columns = raw.select('PRAGMA table_info(subscriptions)');
  if (!columns.any((c) => c['name'] == 'next_billing_date')) {
    raw.execute(
      'ALTER TABLE subscriptions ADD COLUMN next_billing_date INTEGER NOT NULL DEFAULT 0;',
    );
  }
  void subscription(
    String id,
    String cycle,
    DateTime start, {
    bool active = true,
  }) {
    final at = start.millisecondsSinceEpoch ~/ 1000;
    raw.execute(
      'INSERT INTO subscriptions (id, name, category, amount, cycle, start_date, '
      'next_billing_date, is_active, created_at, updated_at) '
      'VALUES (?, ?, ?, 30, ?, ?, ?, ?, ?, ?)',
      [id, id, 'personal', cycle, at, at, active ? 1 : 0, at, at],
    );
  }

  void charge(String id, int date, {double amount = 30}) => raw.execute(
    'INSERT INTO transactions (id, date, type, amount, note, created_at, updated_at) '
    "VALUES (?, ?, 'subscriptionCharge', ?, 'bill', ?, ?)",
    [id, date, amount, date, date],
  );

  subscription('s29', 'monthly', DateTime(2026, 1, 29));
  subscription('s30', 'monthly', DateTime(2026, 1, 30));
  subscription('s31', 'monthly', DateTime(2026, 1, 31));
  subscription('q30', 'quarterly', DateTime(2025, 11, 30), active: false);
  subscription('w', 'weekly', DateTime(2026, 1, 31));
  subscription('m15', 'monthly', DateTime(2026, 1, 15));

  // Period 0 never moved.
  charge('subchg-s31-20260131', _at(2026, 1, 31));
  // DateTime(2026, 2, 29) is 1 March, and the walk stayed on the 1st.
  charge('subchg-s29-20260301', _at(2026, 3, 1));
  charge('subchg-s29-20260401', _at(2026, 4, 1));
  charge('subchg-s30-20260302', _at(2026, 3, 2));
  charge('subchg-s30-20260402', _at(2026, 4, 2));
  charge('subchg-s31-20260303', _at(2026, 3, 3));
  charge('subchg-s31-20260403', _at(2026, 4, 3));
  // Period 8: the walk skipped February, so it is a month ahead here.
  charge('subchg-s31-20261003', _at(2026, 10, 3));
  // The same February bill under both ids.
  charge('subchg-s30-20260228', _at(2026, 2, 28), amount: 999);
  // A paused quarterly plan: DateTime(2026, 2, 30) is 2 March.
  charge('subchg-q30-20260302', _at(2026, 3, 2));
  // Dates that never moved.
  charge('subchg-w-20260207', _at(2026, 2, 7));
  charge('subchg-m15-20260215', _at(2026, 2, 15));
  charge('tx-1', _at(2026, 3, 3));

  raw.execute('PRAGMA user_version = 6;');
  raw.dispose();
}

Future<List<String>> _rows(File file) async {
  final db = AppDatabase.forTesting(NativeDatabase(file));
  final rows = await db
      .customSelect('SELECT id, amount FROM transactions ORDER BY id')
      .get();
  await db.close();
  return [
    for (final r in rows) '${r.read<String>('id')} ${r.read<double>('amount')}',
  ];
}

void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('runway_schema_v7_');
    file = File(p.join(dir.path, kDatabaseFileName));
    await _seedVersion6(file);
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test(
    'charges confirmed under drifted ids move to the corrected ones',
    () async {
      expect(await _rows(file), [
        'subchg-m15-20260215 30.0',
        'subchg-q30-20260228 30.0',
        'subchg-s29-20260228 30.0',
        'subchg-s29-20260329 30.0',
        'subchg-s30-20260228 30.0',
        'subchg-s30-20260330 30.0',
        'subchg-s31-20260131 30.0',
        'subchg-s31-20260228 30.0',
        'subchg-s31-20260331 30.0',
        'subchg-s31-20260930 30.0',
        'subchg-w-20260207 30.0',
        'tx-1 30.0',
      ]);

      final raw = sqlite3.open(file.path);
      addTearDown(raw.dispose);
      expect(raw.select('PRAGMA user_version').single.values.first, 7);
      final columns = raw.select('PRAGMA table_info(subscriptions)');
      expect(
        columns.map((c) => c['name']),
        isNot(contains('next_billing_date')),
      );
    },
  );

  test('running the upgrade a second time changes nothing', () async {
    final once = await _rows(file);

    final raw = sqlite3.open(file.path);
    raw.execute('PRAGMA user_version = 6;');
    raw.dispose();

    expect(await _rows(file), once);
  });
}
