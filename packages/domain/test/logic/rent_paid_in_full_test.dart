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

  test('the month turns and the rent is owed again', () {
    // Nothing resets anything. spentThisMonth is derived on every read from
    // the entries whose month matches today's, so on the 1st September's rent
    // simply stops matching. There is no scheduled job to fail or run twice.
    MonthlyBurn burnAt(DateTime when) => computeMonthlyBurn(
      transactions: [opening, rent],
      budget: budget,
      loans: const [],
      subscriptions: const [],
      now: when,
    );

    final september = burnAt(DateTime(2026, 9, 20));
    final october = burnAt(DateTime(2026, 10, 5));

    expect(september.rent.spentThisMonth, 1450);
    expect(september.rent.leftThisMonth, 0);

    expect(
      october.rent.spentThisMonth,
      0,
      reason: 'the row states the amount again rather than saying paid',
    );
    expect(
      october.rent.leftThisMonth,
      1450,
      reason: 'a fresh month owes the whole rent',
    );
    expect(
      october.rent.budget,
      1450,
      reason: 'the budget is a setting and does not turn over with the month',
    );

    // September does not vanish: it joins the average that lets real spending
    // overtake a budget as the runway's basis.
    expect(october.rent.typicalSpending, 1450);
  });

  test('rent dated next month does not settle this one', () {
    // "A plan, not a cost" — anything after today is ignored, so a post-dated
    // payment cannot settle a month it has not reached.
    final nextMonth = Transaction(
      id: 'rent-oct',
      date: DateTime(2026, 10, 2),
      type: TransactionType.expense,
      amount: Money(1450),
      category: ExpenseCategory.rent,
      createdAt: now,
      updatedAt: now,
    );
    final burn = computeMonthlyBurn(
      transactions: [opening, nextMonth],
      budget: budget,
      loans: const [],
      subscriptions: const [],
      now: DateTime(2026, 9, 20),
    );

    expect(burn.rent.spentThisMonth, 0);
  });

  test('an unspent budget comes back whole, not larger', () {
    // Spending less is already rewarded, in cash: 200 not spent is 200 still
    // there, and the runway is cash over burn. Adding it to next month's
    // allowance as well would count the same 200 twice.
    final someLiving = Transaction(
      id: 'living-sep',
      date: DateTime(2026, 9, 10),
      type: TransactionType.expense,
      amount: Money(900),
      createdAt: now,
      updatedAt: now,
    );

    MonthlyBurn burnAt(DateTime when) => computeMonthlyBurn(
      transactions: [opening, someLiving],
      budget: budget,
      loans: const [],
      subscriptions: const [],
      now: when,
    );

    final september = burnAt(DateTime(2026, 9, 20));
    expect(september.living.spentThisMonth, 900);
    expect(september.living.leftThisMonth, 200);

    final october = burnAt(DateTime(2026, 10, 5));
    expect(
      october.living.leftThisMonth,
      1100,
      reason: 'the allowance returns whole',
    );
    expect(
      october.living.leftThisMonth,
      isNot(1300),
      reason: 'and does not carry September\'s 200 on top of it',
    );

    // The 200 is not lost. It is cash, which is where spending less shows up.
    final cash = [opening, someLiving].fold<double>(
      0,
      (sum, t) => sum + (t.type.isInflow ? t.amount.value : -t.amount.value),
    );
    expect(cash, 33100);
  });
}
