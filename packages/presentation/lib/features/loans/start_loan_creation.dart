import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../shared/pro_gate.dart';
import '../transactions/widgets/loan_wizard.dart';

/// The one way to create a loan.
///
/// Loans are free (#80, decided 2026-09-16: the Pro gate is simulations and
/// entries, not loans). The one-active-loan limit that lived here is gone.
/// What remains gated is the entry itself — a loan writes the money arriving
/// as an entry, and that counts like any other.
Future<void> startLoanCreation(BuildContext context, WidgetRef ref) async {
  if (!allowsNewEntry(context, ref)) return;

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder: (_) => LoanWizard(
      onSubmit:
          (
            loanAmount,
            monthlyPayment,
            termMonths,
            date,
            source,
            name,
            note,
          ) async {
            final now = DateTime.now();
            final loanId = const Uuid().v4();

            try {
              await ref
                  .read(addLoanUseCaseProvider)
                  .execute(
                    Loan(
                      id: loanId,
                      name: name,
                      source: source,
                      originalAmount: loanAmount,
                      monthlyPayment: monthlyPayment,
                      originalTermMonths: termMonths,
                      startDate: date,
                      note: note,
                      createdAt: now,
                      updatedAt: now,
                    ),
                  );
            } catch (_) {
              return false;
            }

            // The money arriving is an entry of its own, linked by loanId. Two
            // writes, and the second can fail on its own: that left a commitment
            // whose principal never entered the balance, so the runway divided by
            // a payment for money the owner never received (#133). If it fails,
            // the loan is taken back out, because half a loan is worse than none.
            try {
              await ref
                  .read(addTransactionUseCaseProvider)
                  .execute(
                    Transaction(
                      id: const Uuid().v4(),
                      date: date,
                      type: TransactionType.loan,
                      amount: Money(loanAmount),
                      // The log row falls back to the type label when there is no
                      // note, so a drawdown with nothing typed would read only
                      // "LOAN". The lender's name is what tells them apart.
                      note: note ?? name,
                      loanId: loanId,
                      createdAt: now,
                      updatedAt: now,
                    ),
                  );
            } catch (_) {
              try {
                await ref.read(deleteLoanUseCaseProvider).execute(loanId);
              } catch (_) {
                // Nothing more to try. Reporting the failure is still right: the
                // wizard stays open and the owner is not told it worked.
              }
              return false;
            }
            return true;
          },
    ),
  );
}
