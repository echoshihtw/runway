import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product_config.dart';
import '../../../shared/pro_gate.dart';
import '../../paywall/paywall_screen.dart';

/// Says whether the owner has Pro, and offers the two ways to get it back.
///
/// Pro was only ever read to hide something: the free-allowance caption is
/// shown when `!isProOwner`, and the gates call `showPaywall` when the
/// allowance runs out. Nothing anywhere said "you have Pro", so someone who
/// had just paid had no way to confirm it landed, which is the state that
/// makes a person email asking whether they were charged twice.
///
/// Reaching the paywall matters more than the badge. `showPaywall` had exactly
/// one caller, the gate in pro_gate.dart, so it opened only once an allowance
/// was spent — and Restore purchase lives on it. An owner on a new phone starts
/// with an empty Keychain and a full allowance, so restoring a purchase they
/// had already made meant first logging five entries they did not want, to be
/// offered the button. This card opens the same sheet with nothing spent.
class ProStatusCard extends ConsumerWidget {
  const ProStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Watched, not read: the card has to change the moment the
    // purchase lands, which is the one thing it is for.
    final isPro = watchProOwner(ref);

    return NeoCard(
      // The product name, which is these words in all six languages.
      title: 'Runway Pro',
      accentColor: SC.accentLife,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isPro ? _owned(l10n) : _notOwned(context, ref, l10n),
      ),
    );
  }

  List<Widget> _owned(AppLocalizations l10n) => [
    Text(
      l10n.proUnlocked,
      style: AppTextStyles.bodySmall.copyWith(color: SC.captionColor),
    ),
  ];

  List<Widget> _notOwned(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    // What is left, in the same words the two gates already use. A count that
    // has not loaded says nothing rather than guessing at zero, which would
    // read as a full allowance to someone who has none.
    final entries = ref.watch(entryCountProvider).value;
    final simulations = ref.watch(simulationCountProvider).value;

    return [
      if (entries != null)
        Text(
          l10n.freeEntriesUsed(entries, ProductConfig.freeEntries),
          style: AppTextStyles.caption,
        ),
      if (simulations != null)
        Text(
          l10n.freeSimulationsUsed(simulations, ProductConfig.freeSimulations),
          style: AppTextStyles.caption,
        ),
      if (entries != null || simulations != null)
        const SizedBox(height: AppSpacing.md),
      NeoButton(
        label: l10n.paywallUnlock,
        variant: NeoButtonVariant.primary,
        fullWidth: true,
        onPressed: () => showPaywall(context, trigger: 'settings'),
      ),
    ];
  }
}
