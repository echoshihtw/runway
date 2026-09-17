import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../use_cases/add_subscription_use_case.dart';
import '../use_cases/edit_subscription_use_case.dart';
import '../use_cases/delete_subscription_use_case.dart';
import 'transaction_provider.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  throw UnimplementedError(
    'subscriptionRepositoryProvider must be overridden in main.dart',
  );
});

final subscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchAll();
});

final subscriptionMonthlyTotalProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider).value ?? [];
  return totalSubscriptionMonthlyCost(subs);
});

/// The subscription charges whose payment date has arrived and which are not
/// recorded yet — the questions to ask, not entries to write.
///
/// A derived charge says "the reminder says this billed", which is not the same
/// claim as "this was paid". Only the owner can make the second one, so nothing
/// reaches the ledger until they confirm it.
final pendingSubscriptionChargesProvider = Provider<List<Transaction>>((ref) {
  return dueSubscriptionCharges(
    subscriptions: ref.watch(subscriptionsProvider).value ?? const [],
    transactions: ref.watch(transactionsProvider).value ?? const [],
    now: DateTime.now(),
  );
});

/// Charge prompts answered "I didn't pay it" in this session.
///
/// Not persisted: the question is unresolved, so it is worth asking again next
/// launch. The other two answers edit the reminder, which stops the prompt on
/// its own.
class DismissedSubscriptionPrompts extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  void dismiss(String chargeId) => state = {...state, chargeId};
}

final dismissedSubscriptionPromptsProvider =
    NotifierProvider<DismissedSubscriptionPrompts, Set<String>>(
      DismissedSubscriptionPrompts.new,
    );

final addSubscriptionUseCaseProvider = Provider<AddSubscriptionUseCase>((ref) {
  return AddSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final editSubscriptionUseCaseProvider = Provider<EditSubscriptionUseCase>((
  ref,
) {
  return EditSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final deleteSubscriptionUseCaseProvider = Provider<DeleteSubscriptionUseCase>((
  ref,
) {
  return DeleteSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});
