import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CONTRACTS.md §4.1 says never to use a raw `AppColors.*` in presentation.
/// The rule was advisory, so it lost: the package carries far more raw
/// references than semantic ones, and every hue decision made in a feature
/// file is a decision the semantic layer cannot hold. Individual edits will
/// not fix that — only a gate will.
///
/// This is a ratchet, not a ban. A file already over budget may not get worse,
/// a file not listed may not use raw colours at all, and a file that improves
/// must lower its own number here so the ground it won is never given back.
///
/// Lowering a number is the point. Raising one needs a reason in the pull
/// request, and usually means the semantic layer is missing a token, which is
/// its own piece of work rather than a licence to reach past it.
const budget = <String, int>{
  'features/config/config_screen.dart': 32,
  'features/transactions/widgets/loan_wizard.dart': 33,
  'features/dashboard/widgets/getting_started_card.dart': 21,
  'features/subscriptions/subscription_form.dart': 21,
  'features/scenarios/scenarios_screen.dart': 16,
  'features/transactions/transactions_screen.dart': 16,
  'features/loans/loan_card.dart': 14,
  'features/transactions/widgets/transaction_form.dart': 13,
  'features/onboarding/onboarding_screen.dart': 12,
  'features/subscriptions/subscriptions_panel.dart': 11,
  'features/paywall/paywall_screen.dart': 8,
  'features/dashboard/widgets/runway_card.dart': 3,
  'features/paywall/pro_locked_card.dart': 6,
  'features/transactions/widgets/transaction_row.dart': 5,
  'features/config/widgets/delete_all_data_card.dart': 4,
  'features/transactions/daily_spend_sheet.dart': 4,
  'features/subscriptions/widgets/subscription_prompt_card.dart': 3,
  'features/dashboard/dashboard_screen.dart': 2,
  'features/dashboard/widgets/living_sheet.dart': 2,
  'features/dashboard/widgets/this_month_card.dart': 2,
  'features/loans/liabilities_panel.dart': 2,
  'router/page_indicator.dart': 2,
  'features/boot/boot_screen.dart': 1,
  'features/loans/start_loan_creation.dart': 1,
  'features/subscriptions/add_subscription_sheet.dart': 1,
  'features/transactions/show_entry_sheet.dart': 1,
  'shared/add_strip.dart': 1,
};

void main() {
  test('no file reaches past the semantic colour layer more than it already '
      'does', () {
    final root = Directory('lib');
    final counts = <String, int>{};

    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final relative = entity.path.substring('lib/'.length);
      // Whitespace-tolerant: the formatter is free to split `AppColors` from
      // its `.field` across two lines, and a plain substring count then reads
      // one fewer than there are. The budget moved when nothing but the
      // formatting had.
      final hits = RegExp(
        r'\bAppColors\s*\.',
      ).allMatches(entity.readAsStringSync()).length;
      if (hits > 0) counts[relative] = hits;
    }

    final tooMany = <String>[];
    final unlisted = <String>[];
    final improved = <String>[];

    counts.forEach((file, hits) {
      final allowed = budget[file];
      if (allowed == null) {
        unlisted.add('  $file uses AppColors $hits times; use SC instead');
      } else if (hits > allowed) {
        tooMany.add('  $file: $hits, budgeted $allowed');
      } else if (hits < allowed) {
        improved.add('  $file: now $hits, lower its budget from $allowed');
      }
    });

    for (final file in budget.keys) {
      if (!counts.containsKey(file)) {
        improved.add('  $file: none left, remove it from the budget');
      }
    }

    expect(
      [...tooMany, ...unlisted, ...improved],
      isEmpty,
      reason:
          'CONTRACTS.md §4.1: presentation styles through SC, not AppColors.\n'
          '${[...tooMany, ...unlisted, ...improved].join('\n')}',
    );
  });
}
