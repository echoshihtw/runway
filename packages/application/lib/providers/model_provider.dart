import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import 'loan_provider.dart';
import 'scenario_provider.dart';
import 'subscription_provider.dart';
import 'budget_provider.dart';
import 'financial_assumptions_provider.dart';

/// Monthly burn split into rent, living, subscriptions and loans.
final monthlyBurnProvider = Provider<MonthlyBurn>((ref) {
  return computeMonthlyBurn(
    transactions: ref.watch(transactionsProvider).value ?? const [],
    budget: ref.watch(budgetProvider).value ?? const Budget(),
    loans: ref.watch(loanSummariesProvider),
    subscriptions: ref.watch(subscriptionsProvider).value ?? const [],
    now: DateTime.now(),
  );
});

final modelProvider = Provider<ModelState>((ref) {
  final assumptions =
      ref.watch(financialAssumptionsProvider).value ??
      const FinancialAssumptions();

  return computeModel(
    currentCash: _currentCash(ref.watch(transactionsProvider).value ?? const []),
    burn: ref.watch(monthlyBurnProvider),
    expectedMonthlyInflow: assumptions.expectedMonthlyInflow,
    expectedMonthlyBurnOverride: assumptions.expectedMonthlyBurnOverride,
  );
});

final scenarioModelProvider = Provider<ModelState?>((ref) {
  final scenario = ref.watch(scenarioProvider);
  if (!scenario.isActive) return null;

  final transactions = ref.watch(transactionsProvider).value;
  if (transactions == null) return null;

  final burn = ref.watch(monthlyBurnProvider);
  final variableBurn = scenario.burnRateOverride ?? burn.variableBurn;
  final netBurn =
      variableBurn +
      burn.loanPayments +
      burn.subscriptions -
      (scenario.simulatedIncome ?? 0.0);
  final monthlyBurn = netBurn > 0 ? netBurn : 0.0;

  return modelForMonthlyBurn(
    currentCash: _currentCash(transactions),
    burn: burn,
    monthlyBurn: monthlyBurn,
    dueThisMonth: monthlyBurn * burn.fractionOfMonthLeft,
  );
});

double _currentCash(List<Transaction> transactions) {
  final months = aggregateMonths(transactions);
  return months.isEmpty ? 0.0 : months.last.balance;
}
