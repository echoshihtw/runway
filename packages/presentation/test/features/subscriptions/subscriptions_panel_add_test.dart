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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Subscription _sub() => Subscription(
  id: 'sub-1',
  name: 'Spotify',
  category: SubscriptionCategory.personal,
  amount: 980,
  cycle: BillingCycle.monthly,
  startDate: DateTime(2026, 6, 3),
  nextBillingDate: DateTime(2026, 6, 3),
  createdAt: DateTime(2026, 6, 3),
  updatedAt: DateTime(2026, 6, 3),
);

Future<void> _pump(WidgetTester tester, List<Subscription> subs) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(_Subscriptions(subs)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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

    expect(find.text('> NO ACTIVE SUBSCRIPTIONS'), findsOneWidget);
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
}
