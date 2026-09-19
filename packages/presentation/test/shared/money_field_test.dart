import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/shared/money_field.dart';

/// Every form formatted money with toStringAsFixed(0), so opening an existing
/// 9.99 to edit it showed "10" — and saving wrote 10 back. The amount fields
/// were also digitsOnly, so typing 9.99 produced 999.
void main() {
  test('nothing to show for nothing', () {
    expect(moneyField(null), '');
  });

  test('a whole amount stays whole', () {
    expect(moneyField(12), '12');
    expect(moneyField(1450), '1450');
    expect(moneyField(0), '0');
  });

  test('cents survive', () {
    expect(moneyField(9.99), '9.99');
    expect(moneyField(9.9), '9.90');
    expect(moneyField(0.5), '0.50');
  });

  test('a computed payment rounds to cents rather than to whole units', () {
    // 120000 over 36 months at 5% lands on a fraction; the installment used
    // to be truncated to a whole number before it was stored.
    expect(moneyField(3596.6659), '3596.67');
  });

  test('what it returns can be parsed back', () {
    for (final v in [0.0, 9.99, 12.0, 1450.5, 3596.6659]) {
      expect(double.parse(moneyField(v)), closeTo(v, 0.005));
    }
  });
}
