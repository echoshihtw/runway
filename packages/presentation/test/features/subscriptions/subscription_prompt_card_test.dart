import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/subscriptions/widgets/subscription_prompt_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The reminder knows what should have billed; only the owner knows what left
/// the account. This is the one place in the app that writes to the ledger on a
/// tap, so it must write exactly what was confirmed and nothing otherwise.
class _FakeTransactionRepository implements TransactionRepository {
  final List<Transaction> added = [];

  @override
  Future<void> add(Transaction transaction) async => added.add(transaction);

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<Transaction>> getAll() async => const [];

  @override
  Future<void> update(Transaction transaction) async {}

  @override
  Stream<List<Transaction>> watchAll() => Stream.value(const []);
}

final _subscription = Subscription(
  id: 'sub-1',
  name: 'Spotify',
  category: SubscriptionCategory.personal,
  amount: 980,
  cycle: BillingCycle.monthly,
  startDate: DateTime(2026, 9, 3),
  nextBillingDate: DateTime(2026, 9, 3),
  createdAt: DateTime(2026, 9, 3),
  updatedAt: DateTime(2026, 9, 3),
);

final _charge = Transaction(
  id: subscriptionChargeId('sub-1', DateTime(2026, 9, 3)),
  type: TransactionType.subscriptionCharge,
  amount: Money(980),
  date: DateTime(2026, 9, 3),
  note: 'Spotify',
  createdAt: DateTime(2026, 9, 17),
  updatedAt: DateTime(2026, 9, 17),
);

Future<_FakeTransactionRepository> _pump(
  WidgetTester tester, {
  required List<Transaction> pending,
}) async {
  SharedPreferences.setMockInitialValues({});
  final repository = _FakeTransactionRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(repository),
        subscriptionsProvider.overrideWith((ref) => Stream.value([_subscription])),
        pendingSubscriptionChargesProvider.overrideWithValue(pending),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(child: SubscriptionPromptCard()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('asks before recording, naming the amount, plan and date', (
    tester,
  ) async {
    await _pump(tester, pending: [_charge]);

    expect(find.textContaining('Spotify'), findsOneWidget);
    expect(find.textContaining('980'), findsOneWidget);
    expect(find.textContaining('3 Sep'), findsOneWidget);
    expect(find.text('Yes, log it'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });

  testWidgets('nothing is asked, and nothing rendered, when nothing is due', (
    tester,
  ) async {
    final repository = await _pump(tester, pending: const []);

    expect(find.byType(NeoCard), findsNothing);
    expect(find.textContaining('Spotify'), findsNothing);
    expect(repository.added, isEmpty);
  });

  testWidgets('yes records exactly the charge that was confirmed', (
    tester,
  ) async {
    final repository = await _pump(tester, pending: [_charge]);

    await tester.tap(find.text('Yes, log it'));
    await tester.pumpAndSettle();

    expect(repository.added, hasLength(1));
    final written = repository.added.single;
    expect(written.id, _charge.id);
    expect(written.amount.value, 980);
    expect(written.date, DateTime(2026, 9, 3));
    expect(written.type, TransactionType.subscriptionCharge);
  });

  testWidgets('no asks what happened, and writes nothing on its own', (
    tester,
  ) async {
    final repository = await _pump(tester, pending: [_charge]);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(find.text('I cancelled it'), findsOneWidget);
    expect(find.text('The price changed'), findsOneWidget);
    expect(find.text("I didn't pay it"), findsOneWidget);
    expect(repository.added, isEmpty, reason: 'no answer means no entry');
  });
}
