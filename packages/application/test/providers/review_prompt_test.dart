import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Transaction _tx(TransactionType type) {
  final date = DateTime(2026, 9, 1);
  return Transaction(
    id: type.name,
    date: date,
    type: type,
    amount: Money(100),
    createdAt: date,
    updatedAt: date,
  );
}

ModelState _model(int runwayMonths) => ModelState(
  currentCash: 1000,
  burnRate: 100,
  effectiveBurnRate: 100,
  monthlyPayment: 0,
  subscriptionMonthlyCost: 0,
  runwayMonths: runwayMonths,
  runwayDays: runwayMonths * 30,
);

void main() {
  group('eligibility', () {
    final both = [
      _tx(TransactionType.openingBalance),
      _tx(TransactionType.expense),
    ];

    test('needs an opening balance, an expense and a finite runway', () {
      expect(
        isEligibleForReviewPrompt(transactions: both, model: _model(10)),
        isTrue,
      );
    });

    test('is not eligible without an expense', () {
      expect(
        isEligibleForReviewPrompt(
          transactions: [_tx(TransactionType.openingBalance)],
          model: _model(10),
        ),
        isFalse,
      );
    });

    test('is not eligible with unlimited runway', () {
      expect(
        isEligibleForReviewPrompt(transactions: both, model: _model(9999)),
        isFalse,
      );
    });
  });

  group('when to ask', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('asks on the launch after first becoming eligible, then never again', () async {
      final prefs = await SharedPreferences.getInstance();

      await recordAppLaunch(prefs);
      await recordReviewEligibility(prefs);
      expect(shouldRequestReview(prefs, eligible: true), isFalse);

      await recordAppLaunch(prefs);
      expect(shouldRequestReview(prefs, eligible: true), isTrue);

      await markReviewRequested(prefs);
      await recordAppLaunch(prefs);
      expect(shouldRequestReview(prefs, eligible: true), isFalse);
    });

    test('keeps the first eligible launch', () async {
      final prefs = await SharedPreferences.getInstance();

      await recordAppLaunch(prefs);
      await recordReviewEligibility(prefs);
      await recordAppLaunch(prefs);
      await recordReviewEligibility(prefs);

      expect(shouldRequestReview(prefs, eligible: true), isTrue);
    });

    test('never asks while not eligible', () async {
      SharedPreferences.setMockInitialValues({
        'app_launch_count': 5,
        'review_eligible_at_launch': 1,
      });
      final prefs = await SharedPreferences.getInstance();

      expect(shouldRequestReview(prefs, eligible: false), isFalse);
    });
  });
}
