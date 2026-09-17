import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../paywall/paywall_screen.dart';
import '../transactions/widgets/loan_wizard.dart';

/// The one way to create a loan.
///
/// This lived in two near-identical copies, in `app_router` and
/// `transactions_screen`, each carrying its own entitlement check. The
/// liabilities card's door would have been a third, and a third copy that
/// forgot the gate would hand every free owner unlimited loans.
Future<void> startLoanCreation(BuildContext context, WidgetRef ref) async {
  final isPro =
      FeatureFlags.devProEntitlement ||
      (ref.read(entitlementProvider).value?.isPro ?? false);
  if (!isPro) {
    final loans = await ref.read(loansProvider.future);
    final transactions = await ref.read(transactionsProvider.future);
    if (!context.mounted) return;
    if (hasActiveLoan(loans: loans, transactions: transactions)) {
      showPaywall(context, trigger: 'loan_limit');
      return;
    }
  }
  if (!context.mounted) return;

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
        // The money arriving is an entry of its own, linked by loanId.
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
      },
    ),
  );
}
