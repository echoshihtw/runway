import 'package:domain/domain.dart';
import 'package:test/test.dart';

Transaction _tx(TransactionType type, DateTime date) => Transaction(
  id: '$type-$date',
  date: date,
  type: type,
  amount: Money(100),
  createdAt: date,
  updatedAt: date,
);

void main() {
  group('the latest opening balance', () {
    test('is null when there is none', () {
      expect(latestOpeningBalanceDate(const []), isNull);
      expect(
        latestOpeningBalanceDate([
          _tx(TransactionType.expense, DateTime(2026, 9, 1)),
        ]),
        isNull,
      );
    });

    test('is the most recent one, not the first', () {
      expect(
        latestOpeningBalanceDate([
          _tx(TransactionType.openingBalance, DateTime(2026, 1, 1)),
          _tx(TransactionType.openingBalance, DateTime(2026, 9, 1)),
        ]),
        DateTime(2026, 9, 1),
      );
    });
  });

  group('money already inside the stated balance', () {
    final opening = DateTime(2026, 9, 1);

    test('arriving before it is already counted', () {
      expect(
        isAlreadyInOpeningBalance(
          DateTime(2026, 1, 15),
          openingBalanceDate: opening,
        ),
        isTrue,
      );
    });

    test('arriving on the day or after it is not', () {
      // The balance is stated as of that date, so the day itself is not before.
      expect(
        isAlreadyInOpeningBalance(opening, openingBalanceDate: opening),
        isFalse,
      );
      expect(
        isAlreadyInOpeningBalance(
          DateTime(2026, 9, 19),
          openingBalanceDate: opening,
        ),
        isFalse,
      );
    });

    test('with no opening balance nothing is already counted', () {
      expect(
        isAlreadyInOpeningBalance(
          DateTime(2020, 1, 1),
          openingBalanceDate: null,
        ),
        isFalse,
      );
    });
  });
}
