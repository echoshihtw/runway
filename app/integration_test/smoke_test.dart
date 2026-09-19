import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke', () {
    // Boot routes to onboarding until it has been completed once, so these
    // tests would never reach the dashboard they check.
    setUp(
      () => SharedPreferences.setMockInitialValues({'onboarding_done': true}),
    );

    testWidgets('app launches without crashing', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await pumpRealTime(tester, seconds: 7);

      // If we reach here the app rendered without throwing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('getting started card appears for fresh user', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await pumpRealTime(tester, seconds: 7);

      expect(find.text('GETTING STARTED'), findsOneWidget);
    });

    testWidgets('tune icon opens config sheet', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await pumpRealTime(tester, seconds: 7);

      // The Getting Started card shows a tune icon too, so aim at the
      // header's, which comes first in the tree.
      await tester.tap(find.byIcon(Icons.tune_rounded).first);
      // The status badge pulses, so pumpAndSettle would never return.
      await pumpRealTime(tester, seconds: 2);

      expect(find.text('FORECAST'), findsOneWidget);
    });
  });
}
