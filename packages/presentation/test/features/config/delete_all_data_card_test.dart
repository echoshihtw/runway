import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/config/widgets/delete_all_data_card.dart';

class _FakeDataResetService implements DataResetService {
  int calls = 0;

  @override
  Future<void> deleteAllData() async => calls++;
}

Future<_FakeDataResetService> _pumpCard(WidgetTester tester) async {
  final service = _FakeDataResetService();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [dataResetServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: DeleteAllDataCard()),
      ),
    ),
  );
  await tester.pump();
  return service;
}

void main() {
  testWidgets('cancelling the confirmation keeps the data', (tester) async {
    final service = await _pumpCard(tester);

    await tester.tap(find.text('DELETE ALL DATA'));
    await tester.pumpAndSettle();
    expect(find.text('Delete everything?'), findsOneWidget);

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect(find.text('Delete everything?'), findsNothing);
    expect(service.calls, 0);
  });

  testWidgets('confirming deletes all data once', (tester) async {
    final service = await _pumpCard(tester);

    await tester.tap(find.text('DELETE ALL DATA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DELETE EVERYTHING'));
    await tester.pumpAndSettle();

    expect(service.calls, 1);
  });
}
