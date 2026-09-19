import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'widgets/transaction_form.dart';

/// The one way to open the entry form.
///
/// This existed in three near-identical copies — `_showForm` and
/// `_showFormWithType` in `transactions_screen`, and `_showForm` in
/// `app_router` — each carrying its own copy of the loan-choice logic, and
/// those two copies had already drifted apart in how they recover the loan an
/// existing repayment names. The preset grid would have been a fourth.
Future<void> showEntrySheet(
  BuildContext context,
  WidgetRef ref, {
  Transaction? existing,
  String? prefillNote,
  TransactionType? preselectedType,
}) {
  final loans = _loanChoices(ref, existing: existing);

  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder: (_) => TransactionForm(
      existing: existing,
      prefillNote: prefillNote,
      preselectedType: preselectedType,
      loans: loans,
      onSubmit: (type, amount, date, note, category, loanId) async {
        final now = DateTime.now();
        if (existing == null) {
          await ref
              .read(addTransactionUseCaseProvider)
              .execute(
                Transaction(
                  id: const Uuid().v4(),
                  date: date,
                  type: type,
                  amount: Money(amount),
                  note: note,
                  loanId: type == TransactionType.repayment ? loanId : null,
                  category: category,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        } else {
          // A repayment names the loan it pays; a drawdown carries the id
          // that ties it to the commitment it created, and that id is the
          // only handle the delete path has. Clearing it on a confirm that
          // changed nothing orphaned the loan for good: it could no longer be
          // removed, and went on charging the runway.
          final keepsLoanId =
              type == TransactionType.repayment ||
              type == TransactionType.loan;
          await ref.read(editTransactionUseCaseProvider).execute(
            existing.copyWith(
              date: date,
              type: type,
              amount: Money(amount),
              note: note,
              loanId: keepsLoanId ? (loanId ?? existing.loanId) : null,
              clearLoanId: !keepsLoanId,
              category: category,
              clearCategory: category == null,
              updatedAt: now,
            ),
          );
        }
      },
    ),
  );
}

/// The loans a repayment may point at, best target first.
List<Loan> _loanChoices(WidgetRef ref, {Transaction? existing}) =>
    repaymentTargets(
      ref.read(loanSummariesProvider),
      existingLoanId: existing?.loanId,
    );
