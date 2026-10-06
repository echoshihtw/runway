import '../entities/transaction.dart';
import '../enums/transaction_type.dart';

/// The date of the most recent opening balance, or null if there is none.
///
/// An opening balance is a stated truth at its date: whatever had happened by
/// then is already inside the figure the owner typed.
DateTime? latestOpeningBalanceDate(List<Transaction> transactions) =>
    transactions
        .where((t) => t.type == TransactionType.openingBalance)
        .fold<DateTime?>(
          null,
          (latest, t) =>
              latest == null || t.date.isAfter(latest) ? t.date : latest,
        );

/// Whether money that arrived on [date] is already inside the stated balance,
/// and so must not be written to the ledger a second time.
///
/// Subscriptions have obeyed this since charges were first written: a plan
/// billed before the opening balance produces no entry, because the money is
/// already counted. Loans did not, so entering a loan taken out last year
/// added its whole principal to today's cash — money the owner received and
/// spent long ago, already reflected in the balance they typed.
bool isAlreadyInOpeningBalance(
  DateTime date, {
  required DateTime? openingBalanceDate,
}) => openingBalanceDate != null && date.isBefore(openingBalanceDate);
