import 'dart:math' as math;

import '../entities/budget.dart';
import '../entities/loan_summary.dart';
import '../entities/subscription.dart';
import '../entities/transaction.dart';
import '../enums/expense_category.dart';
import '../enums/transaction_type.dart';
import '../value_objects/ledger_month.dart';
import 'loan_engine.dart';
import 'subscription_billing.dart';
import 'subscription_engine.dart';

/// Logged spending against one budget.
///
/// Logged expenses use up the budget instead of adding to it, so a $210
/// lunch under a $30,000 living budget leaves the month's cost at $30,000.
class BudgetBucket {
  final double budget;
  final double spentThisMonth;

  /// Average logged spending per completed month, or this month's spending
  /// when there is no earlier history.
  final double typicalSpending;

  const BudgetBucket({
    required this.budget,
    required this.spentThisMonth,
    required this.typicalSpending,
  });

  /// Expected cost of a full month. The budget is a floor: spending only
  /// raises it when it goes over.
  double get monthlyEstimate => math.max(budget, typicalSpending);

  /// What is left of the budget. A display figure: it is what "821 left"
  /// and the living sheet's daily amount are built from.
  double get leftThisMonth => math.max(budget - spentThisMonth, 0);

  /// What this bucket still costs for the rest of the month.
  ///
  /// Measured against [monthlyEstimate], not [budget]. Charging the budget
  /// remainder made the rest of the month free whenever no budget was set —
  /// the default — because the remainder of zero is zero, while every later
  /// month was charged typical spending.
  double get remainingThisMonth =>
      math.max(monthlyEstimate - spentThisMonth, 0);
}

/// Everything that makes up the monthly burn, split so nothing is counted
/// twice or missed.
class MonthlyBurn {
  final LedgerMonth month;

  /// Share of [month] still ahead, counting today. 1.0 on the first day.
  final double fractionOfMonthLeft;

  final BudgetBucket rent;
  final BudgetBucket living;

  /// Monthly equivalent of active subscriptions. Never logged as expenses.
  final double subscriptions;

  /// Scheduled monthly payments on active loans.
  final double loanPayments;

  /// Scheduled loan payments not yet covered by repayments logged this month.
  final double loanPaymentsLeftThisMonth;

  /// Subscription bills dated this month with no confirmed entry: owed, and
  /// not yet out of cash. A confirmed charge is a transaction, so it is
  /// already in the balance and is not counted here as well.
  final double subscriptionsUnpaid;

  const MonthlyBurn({
    required this.month,
    required this.fractionOfMonthLeft,
    required this.rent,
    required this.living,
    required this.subscriptions,
    required this.loanPayments,
    required this.loanPaymentsLeftThisMonth,
    this.subscriptionsUnpaid = 0,
  });

  /// Rent and living, without subscriptions or loans.
  double get variableBurn => rent.monthlyEstimate + living.monthlyEstimate;

  /// Logged rent and living spending, ignoring budgets.
  double get typicalSpending => rent.typicalSpending + living.typicalSpending;

  double get total => variableBurn + subscriptions + loanPayments;

  /// Days left in [month], counting today.
  int get daysLeftThisMonth {
    final daysInMonth = DateTime(
      month.value.year,
      month.value.month + 1,
      0,
    ).day;
    return (fractionOfMonthLeft * daysInMonth).round();
  }

  /// What the rest of this month still costs. Spending already logged is
  /// already out of cash, so only the unused part of each budget counts.
  double get dueThisMonth =>
      rent.remainingThisMonth +
      living.remainingThisMonth +
      subscriptionsUnpaid +
      loanPaymentsLeftThisMonth;
}

/// Whether [t] uses up the rent budget.
bool countsAsRent(Transaction t) =>
    t.type == TransactionType.expense && t.category == ExpenseCategory.rent;

/// Whether [t] uses up the living budget: every expense that is not rent,
/// including uncategorized ones.
bool countsAsLiving(Transaction t) =>
    t.type == TransactionType.expense && t.category != ExpenseCategory.rent;

/// Splits spending into the rent and living budgets.
///
/// - Expenses with the rent category count as rent. Every other expense,
///   including uncategorized ones, counts as living.
/// - Loan repayments count only against their loan's scheduled payment.
/// - Income, loans received and opening balances are not burn.
MonthlyBurn computeMonthlyBurn({
  required List<Transaction> transactions,
  required Budget budget,
  required List<LoanSummary> loans,
  required List<Subscription> subscriptions,
  required DateTime now,
}) {
  final month = LedgerMonth(now);

  final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

  // How far back an average of this owner's spending may reach.
  //
  // Only spending sets it. The date picker takes any entry back to 2020, and a
  // backdated balance, salary or loan would widen the window without adding
  // anything to divide over: six months of spending over eighty months reads
  // as almost no burn and lengthens the runway.
  //
  // One window for both buckets, so a first rent entry in month six does not
  // make rent look like a six-month-old habit.
  LedgerMonth? earliestSpendingMonth;
  for (final t in transactions) {
    if (t.date.isAfter(endOfToday)) continue;
    if (!countsAsRent(t) && !countsAsLiving(t)) continue;
    if (earliestSpendingMonth == null ||
        t.month.isBefore(earliestSpendingMonth)) {
      earliestSpendingMonth = t.month;
    }
  }

  BudgetBucket bucket({
    required bool Function(Transaction) counts,
    required double budgetAmount,
  }) {
    final spending = transactions.where(counts);
    var spentThisMonth = 0.0;
    final completedMonths = <LedgerMonth, double>{};
    for (final t in spending) {
      if (t.date.isAfter(endOfToday)) {
        // A plan, not a cost. Cash already ignores these; the month must too,
        // or a future-dated expense pays for part of the month in advance.
        continue;
      }
      if (t.month == month) {
        spentThisMonth += t.amount.value;
      } else if (t.month.isBefore(month)) {
        completedMonths.update(
          t.month,
          (total) => total + t.amount.value,
          ifAbsent: () => t.amount.value,
        );
      }
    }
    // Over the months that passed, not the months holding an entry. Dividing
    // by completedMonths.length made eight quiet months after one 40,000
    // January read as 40,000 typical, for ever. A quiet month was still
    // lived through.
    final elapsed = earliestSpendingMonth == null
        ? 0
        : month.monthsSince(earliestSpendingMonth);
    final typicalSpending = elapsed <= 0
        ? spentThisMonth
        : completedMonths.values.fold(0.0, (a, b) => a + b) / elapsed;
    return BudgetBucket(
      budget: budgetAmount,
      spentThisMonth: spentThisMonth,
      typicalSpending: typicalSpending,
    );
  }

  final activeLoans = costingLoanSummaries(loans, now: now);
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

  return MonthlyBurn(
    month: month,
    fractionOfMonthLeft: (daysInMonth - now.day + 1) / daysInMonth,
    rent: bucket(counts: countsAsRent, budgetAmount: budget.rent),
    living: bucket(counts: countsAsLiving, budgetAmount: budget.living),
    subscriptions: totalSubscriptionMonthlyCost(subscriptions),
    loanPayments: activeLoans.fold(
      0.0,
      (sum, l) => sum + l.loan.monthlyPayment,
    ),
    loanPaymentsLeftThisMonth: activeLoans.fold(
      0.0,
      (sum, l) => sum + math.max(l.loan.monthlyPayment - l.paidThisMonth, 0),
    ),
    subscriptionsUnpaid: subscriptionsUnpaidThisMonth(
      subscriptions: subscriptions,
      transactions: transactions,
      now: now,
    ),
  );
}
