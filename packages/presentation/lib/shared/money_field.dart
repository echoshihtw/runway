/// The text a money field shows for [value].
///
/// Every form used `toStringAsFixed(0)`, so opening an existing 9.99 to edit
/// it showed "10" and saving put 10 back. Cents survive a round trip now, and
/// whole amounts stay whole rather than growing a ".00" nobody typed.
String moneyField(double? value) {
  if (value == null) return '';
  final fixed = value.toStringAsFixed(2);
  return fixed.endsWith('.00')
      ? fixed.substring(0, fixed.length - 3)
      : fixed;
}
