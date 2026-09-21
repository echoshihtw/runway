import 'package:test/test.dart';
import 'package:domain/domain.dart';
import '../helpers/transaction_helper.dart';

/// What the overview does when rent is logged in full.
///
/// Reported from a device: rent logged in full, and nothing appeared to
/// change. Most of that is the rule working. A budget is a floor, so spending
/// inside it adds no cost, the runway is a forecast that already expected the
/// rent, and the rent row shows the budget rather than the spend.
///
/// Cash is the exception and the proof: that is real money gone, and it has
/// to move by exactly the amount. If it ever stops moving, the ledger has
/// stopped reaching the overview.
void main() {
  final now = DateTime(2026, 9, 20);
  const budget = Budget(rent: 1450, living: 1100);

  ModelState model(List<Transaction> txs) {
    final burn = computeMonthlyBurn(
      transactions: txs,
      budget: budget,
      loans: const [],
      subscriptions: const [],
      now: now,
    );
    final cash = txs.fold<double>(
      0,
      (sum, t) => sum + (t.type.isInflow ? t.amount.value : -t.amount.value),
    );
    return computeModel(currentCash: cash, burn: burn);
  }

  final opening = makeTx(
    year: 2026,
    month: 9,
    day: 1,
    type: TransactionType.openingBalance,
    amount: 34000,
  );
  final rent = Transaction(
    id: 'rent-sep',
    date: DateTime(2026, 9, 2),
    type: TransactionType.expense,
    amount: Money(1450),
    category: ExpenseCategory.rent,
    createdAt: now,
    updatedAt: now,
  );

  test('logging rent in full: what moves and what does not', () {
    final before = model([opening]);
    final after = model([opening, rent]);

    expect(
      after.currentCash,
      before.currentCash - 1450,
      reason: 'rent leaving the account is real money gone',
    );
    expect(
      after.effectiveBurnRate,
      before.effectiveBurnRate,
      reason: 'a budget is a floor: spending inside it adds no cost',
    );
  });

  test('the rent row keeps showing the budget, not the spend', () {
    final burn = computeMonthlyBurn(
      transactions: [opening, rent],
      budget: budget,
      loans: const [],
      subscriptions: const [],
      now: now,
    );
    expect(burn.rent.budget, 1450);
    expect(burn.rent.spentThisMonth, 1450);
    expect(
      burn.rent.leftThisMonth,
      0,
      reason: 'nothing left of the rent budget once it is paid',
    );
    expect(
      burn.rent.monthlyEstimate,
      1450,
      reason: 'the cost is the budget either way, which is why nothing moved',
    );
  });
}
