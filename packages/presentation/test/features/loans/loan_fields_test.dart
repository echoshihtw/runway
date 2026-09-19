import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/loans/loan_card.dart';
import 'package:presentation/features/transactions/widgets/loan_wizard.dart';

Loan _loan({int termMonths = 96}) => Loan(
  id: 'l1',
  name: 'Fubon',
  source: 'BANK',
  originalAmount: 120000,
  monthlyPayment: 1500,
  originalTermMonths: termMonths,
  startDate: DateTime(2020, 1, 1),
  createdAt: DateTime(2020, 1, 1),
  updatedAt: DateTime(2020, 1, 1),
);

LoanSummary _summary({required double repaid, int termMonths = 96}) {
  final loan = _loan(termMonths: termMonths);
  return LoanSummary(
    loan: loan,
    totalRepaid: repaid,
    remainingBalance: (loan.originalAmount - repaid).clamp(0, double.infinity),
    paidThisMonth: 0,
  );
}

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('the wizard hands the source, the lender and the note over '
      'as three fields', (tester) async {
    String? gotSource;
    String? gotName;
    String? gotNote;

    await tester.pumpWidget(
      _wrap(
        LoanWizard(
          onSubmit: (_, __, ___, ____, source, name, note) async {
            gotSource = source;
            gotName = name;
            gotNote = note;
            return true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'John');
    await tester.enterText(find.byType(TextField).at(1), '120000');
    await tester.pump();
    await tester.ensureVisible(find.textContaining('NEXT'));
    await tester.tap(find.textContaining('NEXT'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), '36');
    await tester.pump();
    await tester.ensureVisible(find.textContaining('NEXT'));
    await tester.tap(find.textContaining('NEXT'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), 'bought a car');
    await tester.pump();
    await tester.ensureVisible(find.text('CONFIRM'));
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    // They used to be packed into one string and split apart by the caller on
    // the first separator only, so the note ended up glued to the name.
    expect(gotSource, 'BANK');
    expect(gotName, 'John');
    expect(gotNote, 'bought a car');
  });

  testWidgets('a loan whose principal is repaid but whose term runs on says '
      'the payments continue', (tester) async {
    await tester.pumpWidget(
      _wrap(
        LoanCard(
          summary: _summary(repaid: 120000),
          onTap: () {},
          onRepay: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('PRINCIPAL REPAID. PAYMENTS RUN TO THE END OF THE TERM.'),
      findsOneWidget,
    );
    // The installment is what leaves the runway, so it stays on the card, and
    // REPAY stays reachable: without it paidThisMonth can never be recorded
    // and the burn reserves the payment for ever.
    expect(find.text('INSTALLMENT'), findsOneWidget);
    expect(find.text('REPAY'), findsOneWidget);
  });

  testWidgets('a loan still being repaid says nothing of the sort', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LoanCard(
          summary: _summary(repaid: 40000),
          onTap: () {},
          onRepay: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('PRINCIPAL REPAID'), findsNothing);
    expect(find.text('MONTHS LEFT'), findsOneWidget);
  });
}
