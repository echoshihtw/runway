import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'subscription_form.dart';

/// The one way to create a subscription.
///
/// This sheet existed in three verbatim copies — the add menu, the swipe
/// action sheet and the subscriptions card — and each reported success whether
/// the write landed or not, so a refused write said nothing at all.
Future<void> showAddSubscriptionSheet(BuildContext context, WidgetRef ref) {
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
    // A SnackBar from the app's own messenger renders underneath this route,
    // behind the modal barrier, so the failure would be invisible. This one
    // belongs to the sheet, and shows inside it. The form does its own
    // keyboard inset handling, so the Scaffold must not also do it.
    builder: (_) => ScaffoldMessenger(
      child: Builder(
        builder: (sheetContext) => Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: SubscriptionForm(
            onSubmit: (name, category, amount, cycle, startDate, note) async {
              final now = DateTime.now();
              try {
                await ref.read(addSubscriptionUseCaseProvider).execute(
                  Subscription(
                    id: const Uuid().v4(),
                    name: name,
                    category: category,
                    amount: amount,
                    cycle: cycle,
                    startDate: startDate,
                    nextBillingDate: computeNextBillingDate(startDate, cycle),
                    note: note,
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
              } catch (_) {
                if (!sheetContext.mounted) return false;
                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  SnackBar(
                    content: Text(sheetContext.l10n.subscriptionSaveFailed),
                    backgroundColor: AppColors.surfaceHigh,
                  ),
                );
                // Keeps the form open with the typing intact. Returning true
                // would dismiss it as though the subscription existed.
                return false;
              }
              return true;
            },
          ),
        ),
      ),
    ),
  );
}
