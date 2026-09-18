import 'package:design_system/design_system.dart';

/// Everything about the product that is a decision rather than a mechanism,
/// in one place. Change a number or a preset here; nothing else needs to know.
///
/// The RevenueCat entitlement id (`pro`) is the one decision not here: it is
/// needed at SDK start-up and lives in `app/lib/revenuecat_config.dart`.
abstract final class ProductConfig {
  /// The free plan is a trial: this many entries, ever, then Pro. Every kind
  /// counts except the opening balance. Decided 2026-09-18.
  static const freeEntries = 5;

  /// Simulations a free user can run before the Pro paywall (#80).
  static const freeSimulations = 3;

  /// What the add button offers. Presets partition by occasion, not by item:
  /// if two could ever answer the same tap, one is redundant. The last is the
  /// free-form sheet, dimmer so it does not compete for recognition.
  static final presets = <DailySpendPreset>[
    DailySpendPreset('☕', (l) => l.presetCoffee, (l) => l.presetCoffeeNote),
    DailySpendPreset('🍱', (l) => l.presetLunch, (l) => l.presetLunchNote),
    DailySpendPreset('🍜', (l) => l.presetDinner, (l) => l.presetDinnerNote),
    DailySpendPreset(
      '🚇',
      (l) => l.presetTransport,
      (l) => l.presetTransportNote,
    ),
    DailySpendPreset(
      '🛒',
      (l) => l.presetGroceries,
      (l) => l.presetGroceriesNote,
    ),
    DailySpendPreset('＋', (l) => l.presetSomethingElse, null, dim: true),
  ];
}

/// One tile on the add sheet. The tile shouts ([label]) and the entry's note
/// is prose ([note]); a null note is the unmodified free-form sheet.
class DailySpendPreset {
  final String glyph;
  final String Function(AppLocalizations l10n) label;
  final String Function(AppLocalizations l10n)? note;
  final bool dim;

  const DailySpendPreset(this.glyph, this.label, this.note, {this.dim = false});
}
