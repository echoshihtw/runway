import 'package:flutter/material.dart';

/// One glyph per concept, named by what it means.
///
/// The same concept once wore three marks — the card, the rows and the log
/// each chose their own — and the bank ended up meaning both "a loan" and
/// "the opening balance" (#136). Pick from these five words, not from
/// Material's thousand, and the card and the log cannot drift apart again.
abstract final class LedgerGlyphs {
  /// A loan, wherever it appears: the liabilities card, the money arriving,
  /// every payment. The lender is a bank; nothing else in the log is a
  /// building, so it cannot be mistaken for a direction or a cycle.
  static const lender = Icons.account_balance_rounded;

  /// A subscription, wherever it appears: the card, the rows, the charge.
  static const recurring = Icons.autorenew_rounded;

  /// The opening balance — a starting line, not money that moved.
  static const start = Icons.flag_rounded;

  /// Money the owner chose to spend.
  static const spent = Icons.arrow_upward_rounded;

  /// Money in.
  static const inflow = Icons.arrow_downward_rounded;
}
