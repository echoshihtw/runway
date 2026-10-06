import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// A new owner has entered nothing. Cash is zero because the ledger is empty,
/// not because they are broke, so the runway withholds. The run out month has
/// to withhold with it, or the card says it cannot tell how many months are
/// left and then names the month they end.
void main() {
  const empty = BudgetBucket(budget: 0, spentThisMonth: 0, typicalSpending: 0);

  /// A budget is set, so hasCostBasis is true and only the missing balance can
  /// withhold the runway. Without it the first clause does the work and this
  /// says nothing about cashIsStated.
  test('a budget without a stated balance has no run out month', () {
    final model = computeModel(
      currentCash: 0,
      burn: MonthlyBurn(
        month: LedgerMonth(DateTime(2026, 10, 1)),
        fractionOfMonthLeft: 1,
        rent: empty,
        living: const BudgetBucket(
          budget: 50000,
          spentThisMonth: 0,
          typicalSpending: 0,
        ),
        subscriptions: 0,
        loanPayments: 0,
        loanPaymentsLeftThisMonth: 0,
      ),
      cashIsStated: false,
    );

    expect(model.runwayIsKnown, isFalse, reason: 'nothing has been entered');
    expect(
      model.runOutDate,
      isNull,
      reason: 'a month the money ends is a claim, and there is none to make',
    );
  });
}
