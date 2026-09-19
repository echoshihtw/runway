import 'dart:async';

import 'package:application/application.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePurchaseService implements PurchaseService {
  _FakePurchaseService({this.serverPro = false, this.offline = false});

  final bool serverPro;

  /// The store cannot be reached: the check throws instead of answering.
  final bool offline;
  final updates = StreamController<bool>.broadcast();
  int entitlementChecks = 0;

  @override
  Stream<bool> get proEntitlementUpdates => updates.stream;

  @override
  Future<bool> checkProEntitlement() async {
    entitlementChecks++;
    if (offline) throw Exception('no network');
    return serverPro;
  }

  @override
  Future<ProOffering?> fetchOffering() async => null;

  @override
  Future<bool> purchasePackage(ProPackage package) async => false;

  @override
  Future<bool> restorePurchases() async => false;
}

ProviderContainer _containerWith(PurchaseService service) {
  final container = ProviderContainer(
    overrides: [purchaseServiceProvider.overrideWithValue(service)],
  );
  container.listen(entitlementProvider, (_, _) {});
  addTearDown(container.dispose);
  return container;
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'a cached unlock is given up when the store says it has lapsed',
    () async {
      // A refund or a lapsed subscription had no way in: a cached unlock
      // returned straight away and the store was never consulted again on that
      // device, so the only thing that could correct it was never called.
      SharedPreferences.setMockInitialValues({kIsProPreferenceKey: true});
      final service = _FakePurchaseService(serverPro: false);
      final container = _containerWith(service);

      expect(
        (await container.read(entitlementProvider.future)).isPro,
        isTrue,
        reason: 'the cache still answers first, so launch is not held up',
      );

      await _settle();

      expect(container.read(entitlementProvider).value?.isPro, isFalse);
      expect(service.entitlementChecks, greaterThan(0));
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getBool(kIsProPreferenceKey),
        isFalse,
        reason: 'and the next launch must not restore it',
      );
    },
  );

  test('an unreachable store never takes Pro away', () async {
    SharedPreferences.setMockInitialValues({kIsProPreferenceKey: true});
    final container = _containerWith(_FakePurchaseService(offline: true));

    expect((await container.read(entitlementProvider.future)).isPro, isTrue);
    await _settle();

    expect(
      container.read(entitlementProvider).value?.isPro,
      isTrue,
      reason: 'only a store that answers may revoke',
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(kIsProPreferenceKey), isTrue);
  });

  test('starts locked with no cached or server entitlement', () async {
    final container = _containerWith(_FakePurchaseService());

    final state = await container.read(entitlementProvider.future);

    expect(state.isPro, isFalse);
  });

  test(
    'unlocks without a relaunch when a purchase completes outside the paywall',
    () async {
      final service = _FakePurchaseService();
      final container = _containerWith(service);
      expect((await container.read(entitlementProvider.future)).isPro, isFalse);

      service.updates.add(true);
      await _settle();

      expect(container.read(entitlementProvider).value?.isPro, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_pro'), isTrue);
    },
  );

  test('an update without the entitlement never revokes Pro', () async {
    final service = _FakePurchaseService();
    final container = _containerWith(service);
    await container.read(entitlementProvider.future);

    service.updates.add(true);
    await _settle();
    service.updates.add(false);
    await _settle();

    expect(container.read(entitlementProvider).value?.isPro, isTrue);
  });

  test(
    'an offline first launch still unlocks when the store later reports Pro',
    () async {
      // The throw path returned isPro: false and never attached the update
      // listener — that was only wired on a *successful* check — so regaining
      // connectivity mid-session changed nothing, and a paying customer stayed
      // locked out until relaunch.
      final service = _FakePurchaseService(offline: true);
      final container = _containerWith(service);
      expect((await container.read(entitlementProvider.future)).isPro, isFalse);

      service.updates.add(true);
      await _settle();

      expect(
        container.read(entitlementProvider).value?.isPro,
        isTrue,
        reason: 'the store said Pro; nobody was listening',
      );
    },
  );

  test('uses a cached unlock without asking RevenueCat', () async {
    SharedPreferences.setMockInitialValues({'is_pro': true});
    final service = _FakePurchaseService();
    final container = _containerWith(service);

    final state = await container.read(entitlementProvider.future);

    expect(state.isPro, isTrue);
    expect(service.entitlementChecks, 0);
  });

  test('stays unlocked from the server check alone', () async {
    final container = _containerWith(_FakePurchaseService(serverPro: true));

    final state = await container.read(entitlementProvider.future);

    expect(state.isPro, isTrue);
  });
}
