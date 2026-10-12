import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/subscriptions/subscription_form.dart';
import 'package:presentation/features/transactions/widgets/loan_wizard.dart';
import 'package:presentation/features/transactions/widgets/transaction_form.dart';

/// A new entry, subscription or loan starts on the app's today, which the
/// clock decides. The forms used to read the device's day instead, so with the
/// clock pinned they still showed the real date.
final _today = DateTime(2026, 9, 15);

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('a new entry is dated the app\'s today', (tester) async {
    await tester.pumpWidget(
      _wrap(TransactionForm(today: _today, onSubmit: (_, _, _, _, _, _) {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('15 SEP 2026'), findsOneWidget);
  });

  testWidgets('a new subscription starts on the app\'s today', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _wrap(
        SubscriptionForm(
          today: _today,
          onSubmit: (_, _, _, _, _, _) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('15 SEP 2026'), findsOneWidget);
  });

  testWidgets('a new loan starts on the app\'s today', (tester) async {
    await tester.pumpWidget(
      _wrap(
        LoanWizard(
          today: _today,
          onSubmit: (_, _, _, _, _, _, _) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('15 SEP 2026'), findsOneWidget);
  });
}
