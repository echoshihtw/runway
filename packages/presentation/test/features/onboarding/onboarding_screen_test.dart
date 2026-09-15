import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/onboarding/onboarding_screen.dart';

Future<void> _pumpOnboarding(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: OnboardingScreen())),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('onboarding is welcome, privacy, then first action', (
    tester,
  ) async {
    await _pumpOnboarding(tester);
    expect(find.text('Know your\nrunway.'), findsOneWidget);

    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    expect(find.text('Your data,\nyour device.'), findsOneWidget);

    await tester.tap(find.text('I UNDERSTAND'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to find\nyour runway?'), findsOneWidget);
    expect(find.text('ADD MY BALANCE'), findsOneWidget);
    expect(find.text('SKIP'), findsNothing);
  });

  testWidgets('the privacy page carries every privacy promise', (
    tester,
  ) async {
    await _pumpOnboarding(tester);
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    expect(find.text('Encrypted on device'), findsOneWidget);
    expect(find.text('Numbers stay on your device'), findsOneWidget);
    expect(find.text('Hidden when you switch apps'), findsOneWidget);
    expect(find.text('Delete anytime, instantly'), findsOneWidget);
    expect(find.text('Never sent to servers'), findsNothing);
  });

  testWidgets('the removed pages are gone', (tester) async {
    await _pumpOnboarding(tester);

    for (final cta in ['GET STARTED', 'I UNDERSTAND']) {
      await tester.tap(find.text(cta));
      await tester.pumpAndSettle();
      expect(find.text('Three steps\nto clarity.'), findsNothing);
      expect(find.text('Lock it\ndown.'), findsNothing);
    }
  });
}
