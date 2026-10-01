import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../use_cases/add_transaction_use_case.dart';
import '../use_cases/edit_transaction_use_case.dart';
import '../use_cases/delete_transaction_use_case.dart';
import 'repository_provider.dart';
import 'usage_count_provider.dart';

/// Streams all transactions live from SQLite
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

/// Use case providers
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(
    ref.watch(transactionRepositoryProvider),
    // Every kind of entry counts toward the free limit except the opening
    // balance: starting is not logging, and onboarding must never dead-end.
    onAdded: (transaction) async {
      // Two kinds of entry do not count against the free allowance.
      //
      // The opening balance is where the ledger starts, not something logged,
      // and onboarding must never dead-end.
      //
      // A confirmed subscription charge is the app telling the owner a bill
      // is due and the owner agreeing. They did not decide to log anything,
      // and the store listing promises subscription tracking is free for
      // everyone — which it was not, while someone tracking three of them
      // spent most of five free entries confirming bills.
      const uncounted = {
        TransactionType.openingBalance,
        TransactionType.subscriptionCharge,
      };
      if (uncounted.contains(transaction.type)) return;
      await ref.read(entryCountProvider.notifier).increment();
    },
  );
});

final editTransactionUseCaseProvider = Provider<EditTransactionUseCase>((ref) {
  return EditTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((
  ref,
) {
  return DeleteTransactionUseCase(ref.watch(transactionRepositoryProvider));
});
