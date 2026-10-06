import 'package:app/runway_root.dart';
import 'package:application/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _sessionProvider = Provider<int>((ref) => -1);

void main() {
  late List<String> events;
  late List<int> disposedSessions;
  late Provider<int> trackedSession;

  Future<void> pumpRoot(
    WidgetTester tester, {
    Future<void> Function()? erase,
  }) async {
    var opened = 0;
    await tester.pumpWidget(
      RunwayRoot(
        openSession: () {
          final id = opened++;
          events.add('open $id');
          return [_sessionProvider.overrideWithValue(id)];
        },
        eraseAllData: () async {
          events.add('erase after disposing $disposedSessions');
          await erase?.call();
        },
        onRestarted: () => events.add('restarted'),
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () => ref.read(dataResetServiceProvider).deleteAllData(),
              child: Text('session ${ref.watch(trackedSession)}'),
            ),
          ),
        ),
      ),
    );
  }

  setUp(() {
    events = [];
    disposedSessions = [];
    trackedSession = Provider<int>((ref) {
      final id = ref.watch(_sessionProvider);
      ref.onDispose(() => disposedSessions.add(id));
      return id;
    });
  });

  testWidgets('erases only after the old scope is gone, then starts fresh', (
    tester,
  ) async {
    await pumpRoot(tester);
    expect(find.text('session 0'), findsOneWidget);

    await tester.tap(find.text('session 0'));
    await tester.pumpAndSettle();

    expect(events, [
      'open 0',
      'erase after disposing [0]',
      'restarted',
      'open 1',
    ]);
    expect(find.text('session 1'), findsOneWidget);
  });

  testWidgets('still restarts when erasing fails, and reports the error', (
    tester,
  ) async {
    await pumpRoot(tester, erase: () async => throw StateError('disk full'));

    await tester.tap(find.text('session 0'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isA<StateError>());
    expect(events.last, 'open 1');
    expect(find.text('session 1'), findsOneWidget);
  });
}
