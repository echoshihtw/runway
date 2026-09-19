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
      onSubmit: (loanAmount, monthlyPayment, termMonths, date, note) async {
        final now = DateTime.now();
        final loanId = const Uuid().v4();
        // The wizard packs the source and the name into one note field.
        final parts = (note ?? '').split(' — ');
        final source = parts.isNotEmpty
            ? parts[0].replaceAll(' LOAN', '')
            : 'OTHER';
        final name = parts.length > 1 ? parts[1] : 'LOAN';

        try {
          await ref.read(addLoanUseCaseProvider).execute(
            Loan(
              id: loanId,
              name: name,
              source: source,
              originalAmount: loanAmount,
              monthlyPayment: monthlyPayment,
              originalTermMonths: termMonths,
              startDate: date,
              createdAt: now,
              updatedAt: now,
            ),
          );
        } catch (_) {
          return false;
        }

        // Money that arrived before the opening balance is already inside it,
        // so writing it again takes it twice. Entering a loan taken out last
        // year used to add its whole principal to today's cash — money long
        // since received and spent, already in the figure the owner typed.
        // Subscriptions have obeyed this rule since charges were first
        // written; loans now use the same one.
        final openingBalanceDate = latestOpeningBalanceDate(
          ref.read(transactionsProvider).value ?? const [],
        );
        if (isAlreadyInOpeningBalance(
          date,
          openingBalanceDate: openingBalanceDate,
        )) {
          return true;
        }

        // The money arriving is an entry of its own, linked by loanId. Two
        // writes, and the second can fail on its own: that left a commitment
        // whose principal never entered the balance, so the runway divided by
        // a payment for money the owner never received (#133). If it fails,
        // the loan is taken back out, because half a loan is worse than none.
        try {
          await ref.read(addTransactionUseCaseProvider).execute(
            Transaction(
              id: const Uuid().v4(),
              date: date,
              type: TransactionType.loan,
              amount: Money(loanAmount),
              note: note,
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
