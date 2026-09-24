import 'package:flutter/material.dart';
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
  ///
  /// Material rounded, like every other icon in the app. These were emoji,
  /// which the system draws in its own artwork: a dozen hues the palette
  /// never chose, redrawn by Apple between OS versions, and unable to dim
  /// with the tile they sit in. An icon takes the tile's colour.
  ///
  /// `shopping_bag` is deliberately not here — [LedgerGlyphs] has no claim on
  /// these, but the transaction form already spends that one on LIVING as a
  /// whole, and groceries is one occasion inside it.
  static final presets = <DailySpendPreset>[
    DailySpendPreset(
      Icons.local_cafe_rounded,
      (l) => l.presetCoffee,
      (l) => l.presetCoffeeNote,
    ),
    DailySpendPreset(
      Icons.lunch_dining_rounded,
      (l) => l.presetLunch,
      (l) => l.presetLunchNote,
    ),
    DailySpendPreset(
      Icons.ramen_dining_rounded,
      (l) => l.presetDinner,
      (l) => l.presetDinnerNote,
    ),
    DailySpendPreset(
      Icons.directions_transit_rounded,
      (l) => l.presetTransport,
      (l) => l.presetTransportNote,
    ),
    DailySpendPreset(
      Icons.shopping_basket_rounded,
      (l) => l.presetGroceries,
      (l) => l.presetGroceriesNote,
    ),
    // Not a plus: the add button already wears `add_rounded`, and every tile
    // here adds. This one means "an occasion that is not listed".
    DailySpendPreset(
      Icons.more_horiz_rounded,
      (l) => l.presetSomethingElse,
      null,
      dim: true,
    ),
  ];
}

/// One tile on the add sheet. The tile shouts ([label]) and the entry's note
/// is prose ([note]); a null note is the unmodified free-form sheet.
class DailySpendPreset {
  final IconData glyph;
  final String Function(AppLocalizations l10n) label;
  final String Function(AppLocalizations l10n)? note;
  final bool dim;

  const DailySpendPreset(this.glyph, this.label, this.note, {this.dim = false});
}
