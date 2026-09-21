import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/loans/loan_card.dart';
import 'package:presentation/features/transactions/widgets/loan_wizard.dart';

// The card reads its own DateTime.now(), so there is no clock to pin. The
// start date is taken relative to today and the term set well past it, or the
// test would start failing on a fixed date years from now.
final _start = DateTime(DateTime.now().year - 2, 1, 1);

Loan _loan({int termMonths = 120}) => Loan(
  id: 'l1',
  name: 'Fubon',
  source: 'BANK',
  originalAmount: 120000,
  monthlyPayment: 1500,
  originalTermMonths: termMonths,
  startDate: _start,
  createdAt: _start,
  updatedAt: _start,
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

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
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
      find.text(
        'You have repaid what you borrowed. '
        'Payments run to the end of the term.',
      ),
      findsOneWidget,
      reason:
          'the seam is explained in plain words, not bank vocabulary: '
          'remainingBalance ignores interest, so repaid principal is not the '
          'lender\'s view of the loan',
    );

    // A tick reads as finished, and it sat directly above that sentence.
    expect(
      find.text('✓ PAID'),
      findsNothing,
      reason: 'the term is still charging, so this loan is not over',
    );
    // The installment is what leaves the runway, so it stays on the card, and
    // REPAY stays reachable: without it paidThisMonth can never be recorded
    // and the burn reserves the payment for ever.
    expect(find.text('INSTALLMENT'), findsOneWidget);
    expect(find.text('REPAY'), findsOneWidget);
  });

  testWidgets('the still-paying card says how many months are left', (
    tester,
  ) async {
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

    // The caption promises payments to the end of the term, so the card has
    // to say when that is. monthsRemaining used to return 0 the moment the
    // principal was repaid, which is why the row was hidden.
    expect(find.text('MONTHS LEFT'), findsOneWidget);
    expect(find.text('0 MO'), findsNothing);
  });

  testWidgets('a loan past its term with principal still owing keeps its '
      'installment on screen', (tester) async {
    await tester.pumpWidget(
      _wrap(
        LoanCard(
          summary: _summary(repaid: 40000, termMonths: 6),
          onTap: () {},
          onRepay: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Gating the money rows on the costing rule took the installment away
    // from exactly the loan whose cost the owner most needs to see.
    expect(find.text('INSTALLMENT'), findsOneWidget);
    expect(find.text('PAID THIS MO'), findsOneWidget);
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

    expect(find.textContaining('repaid what you borrowed'), findsNothing);
    expect(find.text('MONTHS LEFT'), findsOneWidget);
  });
}
