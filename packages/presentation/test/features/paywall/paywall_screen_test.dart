import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/paywall/paywall_screen.dart';

Future<void> _pumpPaywall(WidgetTester tester, {Locale? locale}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [proOfferingProvider.overrideWith((ref) async => null)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(child: PaywallScreen(trigger: 'default')),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('links to the Terms of Use and the Privacy Policy', (tester) async {
    await _pumpPaywall(tester);

    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('lists only Pro features that ship', (tester) async {
    await _pumpPaywall(tester);

    expect(find.text('Unlimited loans'), findsOneWidget);
    expect(find.text('Unlimited scenario simulations'), findsOneWidget);
    expect(find.text('Cash timeline chart'), findsNothing);
    expect(find.text('Priority support'), findsNothing);
    expect(find.text('Subscriptions tracker'), findsNothing);
  });

  testWidgets('translates the legal links', (tester) async {
    await _pumpPaywall(tester, locale: const Locale('ja'));

    expect(find.text('利用規約'), findsOneWidget);
    expect(find.text('プライバシーポリシー'), findsOneWidget);
  });
}
