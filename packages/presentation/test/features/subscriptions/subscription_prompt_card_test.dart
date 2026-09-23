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
  Object? failWith;

  @override
  Future<void> add(Transaction transaction) async {
    if (failWith != null) throw failWith!;
    added.add(transaction);
  }

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
  Locale locale = const Locale('en'),
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
        locale: locale,
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

Transaction _chargeOn(DateTime date) => Transaction(
  id: subscriptionChargeId('sub-1', date),
  type: TransactionType.subscriptionCharge,
  amount: Money(980),
  date: date,
  note: 'Spotify',
  createdAt: DateTime(2026, 9, 17),
  updatedAt: DateTime(2026, 9, 17),
);

void _batchTests() {
  final queue = [
    _chargeOn(DateTime(2026, 7, 3)),
    _chargeOn(DateTime(2026, 8, 3)),
    _chargeOn(DateTime(2026, 9, 3)),
  ];

  testWidgets('a queue is one question, not three', (tester) async {
    await _pump(tester, pending: queue);

    expect(find.textContaining('3'), findsWidgets);
    expect(find.textContaining('2,940'), findsOneWidget);
    expect(find.text('Confirm all'), findsOneWidget);
    // The single question is not shown while there is a queue.
    expect(find.text('Yes, log it'), findsNothing);
  });

  testWidgets('confirm all records every charge that was due', (tester) async {
    final repository = await _pump(tester, pending: queue);

    await tester.tap(find.text('Confirm all'));
    await tester.pumpAndSettle();

    expect(repository.added.map((t) => t.date), [
      DateTime(2026, 7, 3),
      DateTime(2026, 8, 3),
      DateTime(2026, 9, 3),
    ]);
  });

  testWidgets('review each falls through to one question at a time', (
    tester,
  ) async {
    final repository = await _pump(tester, pending: queue);

    await tester.tap(find.text('Review each'));
    await tester.pumpAndSettle();

    expect(find.text('Yes, log it'), findsOneWidget);
    // Sep 3, not 3 Sep: the date in this sentence takes the reader's own
    // order now. The mono date labels elsewhere keep their one pattern.
    expect(find.textContaining('Jul 3'), findsOneWidget);
    expect(repository.added, isEmpty, reason: 'reviewing writes nothing');
  });
}

void main() {
  testWidgets('the date in the question is written the reader\'s way', (
    tester,
  ) async {
    // The date sits inside a sentence, so it cannot keep one pattern for every
    // language the way the mono labels do. It was built from 'd MMM' with no
    // locale, so a Chinese reader was asked "你在3 Sep支付了..." with an English
    // date in the middle of it. Passing the locale to that same pattern would
    // not have fixed it either: 'd MMM' renders as "3 9月" in Chinese, which is
    // the day and the month the wrong way round.
    await _pump(tester, pending: [_charge], locale: const Locale('zh'));
    expect(find.textContaining('9月3日'), findsOneWidget);
    expect(find.textContaining('Sep'), findsNothing);
  });

  testWidgets('a write that fails is not silently treated as recorded', (
    tester,
  ) async {
    // The old blanket catch assumed the only possible throw was the derived
    // id colliding. AddTransactionUseCase also rejects a zero amount, so a
    // reminder saved at zero made Yes do nothing, for ever, without a word.
    final repository = await _pump(tester, pending: [_charge]);
    repository.failWith = const InvalidTransactionFailure('Amount cannot be zero');

    await tester.tap(find.text('Yes, log it'));
    await tester.pumpAndSettle();

    expect(repository.added, isEmpty);
    // What matters is that the owner is told, not that an exception escaped:
    // an unawaited throw reaches neither the test nor the person tapping.
    expect(
      find.text("Couldn't record that. Check the amount on the subscription."),
      findsOneWidget,
    );
  });


  testWidgets('asks before recording, naming the amount, plan and date', (
    tester,
  ) async {
    await _pump(tester, pending: [_charge]);

    expect(find.textContaining('Spotify'), findsOneWidget);
    expect(find.textContaining('980'), findsOneWidget);
    expect(find.textContaining('Sep 3'), findsOneWidget);
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

  _batchTests();
}
