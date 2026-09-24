import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/transactions/widgets/loan_wizard.dart';
import 'package:presentation/features/transactions/widgets/transaction_form.dart';

/// Both forms kept CONFIRM live on input their own handler refuses. The tap
/// did nothing, the sheet sat there, and nothing said why. The subscription
/// sheet and the repay sheet were fixed the same way before this.
Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

bool _enabled(WidgetTester tester, String label) {
  final button = tester.widget<NeoButton>(
    find.widgetWithText(NeoButton, label),
  );
  return button.onPressed != null;
}

void main() {
  testWidgets('an entry CONFIRMs only once the amount is worth something', (
    tester,
  ) async {
    var submitted = 0;
    await tester.pumpWidget(
      _wrap(
        TransactionForm(
          onSubmit: (_, _, _, _, _, _) => submitted++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_enabled(tester, 'CONFIRM'), isFalse, reason: 'nothing typed yet');

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.pump();
    expect(_enabled(tester, 'CONFIRM'), isFalse, reason: 'zero is refused');

    await tester.enterText(find.byType(TextField).first, '1200');
    await tester.pump();
    expect(_enabled(tester, 'CONFIRM'), isTrue);

    await tester.ensureVisible(find.text('CONFIRM'));
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();
    expect(submitted, 1);
  });

  testWidgets('the loan wizard will not move on from an amount of zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LoanWizard(
          onSubmit: (_, _, _, _, _, _, _) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Fubon');
    await tester.enterText(find.byType(TextField).at(1), '0');
    await tester.pump();

    // The write rejects a loan of zero, so the wizard could only ever have
    // carried the owner to a step that failed.
    expect(_enabled(tester, 'NEXT →'), isFalse);

    await tester.enterText(find.byType(TextField).at(1), '120000');
    await tester.pump();
    expect(_enabled(tester, 'NEXT →'), isTrue);
  });
}
