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

  return modelForScenario(
    currentCash: _currentCash(transactions),
    burn: ref.watch(monthlyBurnProvider),
    monthlyCostOverride: scenario.burnRateOverride,
    simulatedIncome: scenario.simulatedIncome,
  );
});

double _currentCash(List<Transaction> transactions) =>
    currentCashAsOf(transactions: transactions, now: DateTime.now());
