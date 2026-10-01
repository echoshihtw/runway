class LedgerMonth {
  final DateTime value;

  LedgerMonth._(this.value);

  factory LedgerMonth(DateTime date) {
    return LedgerMonth._(DateTime(date.year, date.month, 1));
  }

  factory LedgerMonth.fromYearMonth(int year, int month) {
    return LedgerMonth._(DateTime(year, month, 1));
  }

  LedgerMonth next() => LedgerMonth(DateTime(value.year, value.month + 1, 1));

  /// Whole months from [other] to this one. Negative when [other] is later.
  int monthsSince(LedgerMonth other) =>
      (value.year - other.value.year) * 12 + (value.month - other.value.month);

  bool isBefore(LedgerMonth other) => value.isBefore(other.value);
  bool isAfter(LedgerMonth other) => value.isAfter(other.value);

  bool operator <(LedgerMonth other) => isBefore(other);
  bool operator >(LedgerMonth other) => isAfter(other);

  @override
  bool operator ==(Object other) =>
      other is LedgerMonth && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}';
}
