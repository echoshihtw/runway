import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/loans/loan_card.dart';

/// The rule under a loan card separates one loan from the next, so the last
/// one has nothing to separate from. NEW LOAN draws its own rule above
/// itself, and the two sat eight points apart in the same colour, reading as
/// a stray line above the button.
///
/// `_SubRow` in the subscriptions panel already took this flag; the loans
/// panel never got it.
final _start = DateTime(DateTime.now().year - 2, 1, 1);

LoanSummary _summary() {
  final loan = Loan(
    id: 'l1',
    name: 'Fubon',
    source: 'BANK',
    originalAmount: 120000,
    monthlyPayment: 1500,
    originalTermMonths: 96,
    startDate: _start,
    createdAt: _start,
    updatedAt: _start,
  );
  return LoanSummary(
    loan: loan,
    totalRepaid: 0,
    remainingBalance: loan.originalAmount,
    paidThisMonth: 0,
  );
}

Future<Color?> _ruleColour(WidgetTester tester, {required bool show}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: LoanCard(
              summary: _summary(),
              showDivider: show,
              onTap: () {},
              onRepay: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final box = tester.widget<Container>(
    find
        .descendant(of: find.byType(LoanCard), matching: find.byType(Container))
        .first,
  );
  return ((box.decoration! as BoxDecoration).border! as Border).bottom.color;
}

void main() {
  testWidgets('the last loan draws no rule, so the strip draws the only one', (
    tester,
  ) async {
    expect(await _ruleColour(tester, show: false), Colors.transparent);
  });

  testWidgets('a loan with another below it keeps its rule', (tester) async {
    expect(await _ruleColour(tester, show: true), AppColors.panelBorder);
  });
}
