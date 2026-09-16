import 'dart:math' as math;

import '../entities/budget.dart';
import '../entities/loan_summary.dart';
import '../entities/subscription.dart';
import '../entities/transaction.dart';
import '../enums/expense_category.dart';
import '../enums/transaction_type.dart';
import '../value_objects/survival_month.dart';
import 'loan_engine.dart';
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

  double get leftThisMonth => math.max(budget - spentThisMonth, 0);
}

/// Everything that makes up the monthly burn, split so nothing is counted
/// twice or missed.
class MonthlyBurn {
  final SurvivalMonth month;

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

  const MonthlyBurn({
    required this.month,
    required this.fractionOfMonthLeft,
    required this.rent,
    required this.living,
    required this.subscriptions,
    required this.loanPayments,
    required this.loanPaymentsLeftThisMonth,
  });

  /// Rent and living, without subscriptions or loans.
  double get variableBurn => rent.monthlyEstimate + living.monthlyEstimate;

  /// Logged rent and living spending, ignoring budgets.
  double get typicalSpending => rent.typicalSpending + living.typicalSpending;

  double get total => variableBurn + subscriptions + loanPayments;

  /// Days left in [month], counting today.
  int get daysLeftThisMonth {
    final daysInMonth = DateTime(month.value.year, month.value.month + 1, 0).day;
    return (fractionOfMonthLeft * daysInMonth).round();
  }

  /// What the rest of this month still costs. Spending already logged is
  /// already out of cash, so only the unused part of each budget counts.
  double get dueThisMonth =>
      rent.leftThisMonth +
      living.leftThisMonth +
      subscriptions * fractionOfMonthLeft +
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
/// - Income, loans received, investments and opening balances are not burn.
MonthlyBurn computeMonthlyBurn({
  required List<Transaction> transactions,
  required Budget budget,
  required List<LoanSummary> loans,
  required List<Subscription> subscriptions,
  required DateTime now,
}) {
  final month = SurvivalMonth(now);

  BudgetBucket bucket({
    required bool Function(Transaction) counts,
    required double budgetAmount,
  }) {
    final spending = transactions.where(counts);
    var spentThisMonth = 0.0;
    final completedMonths = <SurvivalMonth, double>{};
    for (final t in spending) {
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
    final typicalSpending = completedMonths.isEmpty
        ? spentThisMonth
        : completedMonths.values.reduce((a, b) => a + b) /
              completedMonths.length;
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
    loanPayments: activeLoans.fold(0.0, (sum, l) => sum + l.loan.monthlyPayment),
    loanPaymentsLeftThisMonth: activeLoans.fold(
      0.0,
      (sum, l) => sum + math.max(l.loan.monthlyPayment - l.paidThisMonth, 0),
    ),
  );
}
