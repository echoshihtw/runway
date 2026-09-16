import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import '../use_cases/add_loan_use_case.dart';
import '../use_cases/edit_loan_use_case.dart';
import '../use_cases/delete_loan_use_case.dart';

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  throw UnimplementedError(
    'loanRepositoryProvider must be overridden in main.dart',
  );
});

final loansProvider = StreamProvider<List<Loan>>((ref) {
  return ref.watch(loanRepositoryProvider).watchAll();
});

final loanSummariesProvider = Provider<List<LoanSummary>>((ref) {
  final loans = ref.watch(loansProvider).value ?? [];
  final transactions = ref.watch(transactionsProvider).value ?? [];
  return computeLoanSummaries(
    loans: loans,
    transactions: transactions,
    now: DateTime.now(),
  );
});

final activeLoanSummariesProvider = Provider<List<LoanSummary>>((ref) {
  final summaries = ref.watch(loanSummariesProvider);
  return activeLoanSummaries(summaries);
});

final totalMonthlyLoanPaymentProvider = Provider<double>((ref) {
  final summaries = ref.watch(loanSummariesProvider);
  return totalMonthlyPaymentFromSummaries(summaries);
});

final addLoanUseCaseProvider = Provider<AddLoanUseCase>((ref) {
  return AddLoanUseCase(ref.watch(loanRepositoryProvider));
});

final editLoanUseCaseProvider = Provider<EditLoanUseCase>((ref) {
  return EditLoanUseCase(ref.watch(loanRepositoryProvider));
});

final deleteLoanUseCaseProvider = Provider<DeleteLoanUseCase>((ref) {
  return DeleteLoanUseCase(ref.watch(loanRepositoryProvider));
});
