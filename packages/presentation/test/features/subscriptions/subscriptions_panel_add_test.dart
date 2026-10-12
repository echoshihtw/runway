import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/subscriptions/subscription_form.dart';
import 'package:presentation/features/subscriptions/subscriptions_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Creating a subscription used to exist only in a menu of record types. The
/// card that owns subscriptions had no way to make one — and its empty state,
/// the one place someone learns the feature exists, was inert text.
class _Subscriptions implements SubscriptionRepository {
  _Subscriptions(this.items);
  final List<Subscription> items;

  @override
  Stream<List<Subscription>> watchAll() => Stream.value(items);

  @override
  Future<List<Subscription>> getAll() async => items;

  @override
  Future<void> add(Subscription subscription) async => items.add(subscription);

  @override
  Future<void> delete(String id) async => items.removeWhere((s) => s.id == id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A ledger that refuses the write: a full disk, a locked database.
class _FailingSubscriptions extends _Subscriptions {
  _FailingSubscriptions() : super([]);

  @override
  Future<void> add(Subscription subscription) async =>
      throw Exception('the write failed');
}

class _Analytics extends NoOpAnalytics {
  final events = <String>[];

  @override
  Future<void> logAddSubscription(BillingCycle cycle) async =>
      events.add('add_subscription:${cycle.name}');

  @override
  Future<void> logDeleteSubscription() async =>
      events.add('delete_subscription');
}

Subscription _sub() => Subscription(
  id: 'sub-1',
  name: 'Spotify',
  category: SubscriptionCategory.personal,
  amount: 980,
  cycle: BillingCycle.monthly,
  startDate: DateTime(2026, 6, 3),
  createdAt: DateTime(2026, 6, 3),
  updatedAt: DateTime(2026, 6, 3),
);

Future<void> _pump(
  WidgetTester tester,
  List<Subscription> subs, {
  double textScale = 1.0,
  SubscriptionRepository? repository,
  AnalyticsService analytics = const NoOpAnalytics(),
}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(
          repository ?? _Subscriptions(subs.toList()),
        ),
        analyticsProvider.overrideWithValue(analytics),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(child: SubscriptionsPanel()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the empty state offers to create one, and opens the form', (
    tester,
  ) async {
    await _pump(tester, const []);

    expect(find.text('NO ACTIVE SUBSCRIPTIONS'), findsOneWidget);
    expect(find.text('+ SUBSCRIPTION'), findsOneWidget);

    await tester.tap(find.text('+ SUBSCRIPTION'));
    await tester.pumpAndSettle();

    expect(
      find.byType(SubscriptionForm),
      findsOneWidget,
      reason: 'the one place the feature is discovered must also act',
    );
  });

  testWidgets('with subscriptions listed, the way to add one is still there', (
    tester,
  ) async {
    await _pump(tester, [_sub()]);

    // The card collapses by default, so the strip is clipped rather than
    // absent: SizeTransition keeps its child in the tree at zero height, so a
    // finder still sees it. Expanding is what makes it reachable.
    await tester.tap(find.text('SUBSCRIPTIONS'));
    await tester.pumpAndSettle();

    expect(find.text('+ SUBSCRIPTION'), findsOneWidget);
    await tester.tap(find.text('+ SUBSCRIPTION'));
    await tester.pumpAndSettle();

    expect(find.byType(SubscriptionForm), findsOneWidget);
  });

  testWidgets('the empty state fits a narrow screen at double text size', (
    tester,
  ) async {
    // "NO ACTIVE SUBSCRIPTIONS" and "+ SUBSCRIPTION" share one row, and the
    // label was the only child of that row without a flex, so it kept its
    // full intrinsic width and pushed the row past the screen. Italian is
    // longer still: "> NESSUN ABBONAMENTO ATTIVO" beside "+ ABBONAMENTO".
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester, const [], textScale: 2.0);

    expect(
      tester.takeException(),
      isNull,
      reason:
          'the empty state must lay out on the smallest screen we support '
          'at the largest text size, not overflow',
    );
    expect(find.text('+ SUBSCRIPTION'), findsOneWidget);
  });

  testWidgets('the add strip is big enough to hit', (tester) async {
    await _pump(tester, [_sub()]);
    await tester.tap(find.text('SUBSCRIPTIONS'));
    await tester.pumpAndSettle();

    final strip = find
        .ancestor(
          of: find.text('+ SUBSCRIPTION'),
          matching: find.byType(GestureDetector),
        )
        .first;

    // Apple's minimum is 44pt. The strip padded only its top, so the tappable
    // area was the label's own height plus 10 — and the visible gap beneath
    // the label, which reads as part of the control, was outside it.
    expect(
      tester.getSize(strip).height,
      greaterThanOrEqualTo(44),
      reason: 'a control that looks tappable has to be reachable',
    );
  });

  testWidgets('a write that fails leaves the form open and says so', (
    tester,
  ) async {
    // onSubmit returned true unconditionally, so a failed write closed the
    // sheet exactly like a successful one: the subscription was silently not
    // created, and the only place that would have shown it is the card the
    // sheet just closed over.
    final analytics = _Analytics();
    await _pump(
      tester,
      const [],
      repository: _FailingSubscriptions(),
      analytics: analytics,
    );
    await _addNetflix(tester);

    expect(
      find.byType(SubscriptionForm),
      findsOneWidget,
      reason: 'nothing was written, so the sheet must not close as if it was',
    );
    expect(
      find.textContaining("Couldn't save"),
      findsOneWidget,
      reason:
          'and the failure has to be said out loud. It used to be a '
          'SnackBar, which needed a Scaffold, which stretched the sheet to '
          'full height; the form says it inline now, beside the typing',
    );
    expect(analytics.events, isEmpty, reason: 'nothing was added');
  });

  testWidgets('a saved subscription is counted once, by its cycle', (
    tester,
  ) async {
    final analytics = _Analytics();
    await _pump(tester, const [], analytics: analytics);
    await _addNetflix(tester);

    expect(find.byType(SubscriptionForm), findsNothing);
    expect(analytics.events, ['add_subscription:monthly']);
  });

  testWidgets('a deletion is counted once it is confirmed, never on abort', (
    tester,
  ) async {
    final analytics = _Analytics();
    await _pump(tester, [_sub()], analytics: analytics);
    await tester.tap(find.text('SUBSCRIPTIONS'));
    await tester.pumpAndSettle();

    Future<void> deleteThenAnswer(String answer) async {
      await tester.tap(find.text('SPOTIFY'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Delete subscription'));
      await tester.tap(find.text('Delete subscription'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(answer));
      await tester.pumpAndSettle();
    }

    await deleteThenAnswer('ABORT');
    expect(analytics.events, isEmpty);

    await deleteThenAnswer('DELETE SUBSCRIPTION');
    expect(analytics.events, ['delete_subscription']);
  });
}

Future<void> _addNetflix(WidgetTester tester) async {
  await tester.tap(find.text('+ SUBSCRIPTION'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).at(0), 'Netflix');
  await tester.enterText(find.byType(TextField).at(1), '1990');
  // CONFIRM is disabled until the form has something to save, and the
  // rebuild that enables it lands a frame after the typing.
  await tester.pump();
  await tester.ensureVisible(find.text('CONFIRM'));
  await tester.tap(find.text('CONFIRM'));
  await tester.pumpAndSettle();
}
