import 'package:app/revenuecat_service.dart';
import 'package:application/application.dart';
import 'package:flutter_test/flutter_test.dart';

/// `init()` used to swallow a failed `configure` and hand back a service
/// indistinguishable from a working one. Its `fetchOffering` then returned
/// null, which the paywall rendered as "One-time purchase · Unlock forever"
/// over a disabled button — a price line with no price — and purchases were
/// silently impossible. The service now remembers why the store is
/// unreachable and says so wherever it is asked to act.
void main() {
  final service = RevenueCatService.unconfigured(
    'RevenueCat failed to configure: boom',
  );

  test('fetching the offering throws the reason, not null', () async {
    await expectLater(
      service.fetchOffering(),
      throwsA(
        isA<StateError>().having((e) => e.message, 'message', contains('boom')),
      ),
    );
  });

  test('restoring reports the reason instead of "no previous purchase"', () async {
    await expectLater(
      service.restorePurchases(),
      throwsA(
        isA<PurchaseException>().having(
          (e) => e.message,
          'message',
          contains('boom'),
        ),
      ),
    );
  });

  test('the entitlement check answers no rather than throwing', () async {
    // The entitlement provider treats a throw as "offline" and attaches its
    // listener; an unconfigured store has nothing to listen to, so a plain
    // "not Pro" is the honest answer.
    expect(await service.checkProEntitlement(), isFalse);
  });

  test('the update stream is empty, not an error', () {
    expect(service.proEntitlementUpdates, emitsDone);
  });
}
