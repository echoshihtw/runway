import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  _cashTests();
  group('calculateRunwayGoalProgress', () {
    test('normalizes current runway against a user target', () {
      expect(
        calculateRunwayGoalProgress(runwayMonths: 6, targetMonths: 24),
        0.25,
      );
    });

    test('caps progress at 1.0', () {
      expect(
        calculateRunwayGoalProgress(runwayMonths: 48, targetMonths: 24),
        1.0,
      );
    });

    test('treats infinite runway as complete for any finite goal', () {
      expect(
        calculateRunwayGoalProgress(runwayMonths: 9999, targetMonths: 24),
        1.0,
      );
    });

    test('returns zero for invalid targets', () {
      expect(
        calculateRunwayGoalProgress(runwayMonths: 6, targetMonths: 0),
        0.0,
      );
    });
  });

  group('calculateRunwayGoalProgressPercent', () {
    test('returns rounded UI percent', () {
      expect(
        calculateRunwayGoalProgressPercent(runwayMonths: 13, targetMonths: 24),
        54,
      );
    });
  });
}

void _cashTests() {
  group('a goal in months also names a sum of cash', () {
    test('the target is the months it asks for, at what a month costs', () {
      // The bar drew an unfilled half with no size. A target of 24 months is
      // 24 times the monthly cost, which is arithmetic the app already has.
      expect(
        runwayGoalCashTarget(targetMonths: 24, monthlyCost: 2803),
        67272,
      );
      expect(
        runwayGoalCashToGo(
          targetMonths: 24,
          monthlyCost: 2803,
          currentCash: 34336,
        ),
        32936,
      );
    });

    test('a goal already met has nothing left to go', () {
      expect(
        runwayGoalCashToGo(
          targetMonths: 6,
          monthlyCost: 2803,
          currentCash: 40000,
        ),
        0,
      );
    });

    test('with no monthly cost the target is not a number', () {
      // Dividing a runway by nothing is undefined, so multiplying a target by
      // nothing is a confident zero for something nobody can know.
      expect(runwayGoalCashTarget(targetMonths: 24, monthlyCost: 0), isNull);
      expect(
        runwayGoalCashToGo(
          targetMonths: 24,
          monthlyCost: 0,
          currentCash: 34336,
        ),
        isNull,
      );
    });
  });
}
