import 'package:domain/domain.dart';

class AddTransactionUseCase {
  final TransactionRepository _repository;

  /// Runs after the entry is saved. Every door that writes an entry comes
  /// through here, so a caller that wants to count entries counts once, not
  /// once per door. The ledger write has already happened: a failure in here
  /// must not be mistaken for a failed save.
  final Future<void> Function(Transaction transaction)? onAdded;

  const AddTransactionUseCase(this._repository, {this.onAdded});

  Future<void> execute(Transaction transaction) async {
    if (transaction.amount.isZero) {
      throw const InvalidTransactionFailure('Amount cannot be zero');
    }
    if (transaction.amount.value > 1e12) {
      throw const InvalidTransactionFailure('Amount exceeds maximum');
    }
    await _repository.add(transaction);
    try {
      await onAdded?.call(transaction);
    } catch (_) {
      // The entry is the user's data and it is saved. The count is ours.
    }
  }
}
