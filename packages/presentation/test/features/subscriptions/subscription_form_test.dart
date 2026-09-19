import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/subscriptions/subscription_form.dart';

/// The form was built when amounts were yen: the payment field was
/// digitsOnly, so no price with cents could be typed at all, and CONFIRM was
/// always enabled while submit returned early, so tapping it on an empty form
/// did nothing.
Future<void> _pump(
  WidgetTester tester, {
  Subscription? existing,
  Future<bool> Function()? onSubmit,
}) async {
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SubscriptionForm(
            existing: existing,
            onSubmit: (_, __, ___, ____, _____, ______) async =>
                onSubmit == null ? true : await onSubmit(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Subscription _netflix(double amount) => Subscription(
  id: 's1',
  name: 'Netflix',
  category: SubscriptionCategory.personal,
  amount: amount,
  cycle: BillingCycle.monthly,
  startDate: DateTime(2026, 9, 1),
  nextBillingDate: DateTime(2026, 10, 1),
  createdAt: DateTime(2026, 9, 1),
  updatedAt: DateTime(2026, 9, 1),
);

Finder get _amountField => find.byType(TextField).at(1);

void main() {
  testWidgets('a price with cents can be typed', (tester) async {
    await _pump(tester);

    await tester.enterText(_amountField, '9.99');
    await tester.pump();

    expect(
      tester.widget<TextField>(_amountField).controller!.text,
      '9.99',
      reason: 'digitsOnly stripped the point, so no dollar price was enterable',
    );
  });

  testWidgets('an existing price keeps its cents when the sheet opens', (
    tester,
  ) async {
    await _pump(tester, existing: _netflix(9.99));

    expect(tester.widget<TextField>(_amountField).controller!.text, '9.99');
  });

  testWidgets('a whole price does not grow decimals', (tester) async {
    await _pump(tester, existing: _netflix(12));

    expect(tester.widget<TextField>(_amountField).controller!.text, '12');
  });

  group('CONFIRM is only live when there is something to save', () {
    testWidgets('dead on an empty form', (tester) async {
      await _pump(tester);
      expect(tester.widget<NeoButton>(_confirm()).onPressed, isNull);
    });

    testWidgets('dead with a name but no amount', (tester) async {
      await _pump(tester);
      await tester.enterText(find.byType(TextField).first, 'Netflix');
      await tester.pump();
      expect(tester.widget<NeoButton>(_confirm()).onPressed, isNull);
    });

    testWidgets('live once both are there', (tester) async {
      await _pump(tester);
      await tester.enterText(find.byType(TextField).first, 'Netflix');
      await tester.enterText(_amountField, '9.99');
      await tester.pump();
      expect(tester.widget<NeoButton>(_confirm()).onPressed, isNotNull);
    });
  });

  testWidgets('a refused write says so in the sheet and keeps the typing', (
    tester,
  ) async {
    await _pump(tester, onSubmit: () async => false);

    await tester.enterText(find.byType(TextField).first, 'Netflix');
    await tester.enterText(_amountField, '9.99');
    await tester.pump();
    await tester.tap(_confirm());
    await tester.pumpAndSettle();

    expect(find.textContaining("Couldn't save"), findsOneWidget);
    expect(
      tester.widget<TextField>(_amountField).controller!.text,
      '9.99',
      reason: 'the typing has to survive a refusal',
    );
  });
}

Finder _confirm() => find.ancestor(
  of: find.text('CONFIRM'),
  matching: find.byType(NeoButton),
);
