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
    // The form is handed over directly, as the edit paths already do, so the
    // sheet is the height of its content. It used to be wrapped in a
    // ScaffoldMessenger and a Scaffold purely to host a failure SnackBar, and
    // a Scaffold inside a scroll-controlled sheet expands to the full height
    // of the screen. The form reports its own failure inline now, next to the
    // typing, which needs no Scaffold and reads better besides.
    builder: (_) => SubscriptionForm(
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
          // Keeps the form open with the typing intact. Returning true would
          // dismiss it as though the subscription existed.
          return false;
        }
        return true;
      },
    ),
  );
}
