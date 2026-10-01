import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product_config.dart';
import '../../../shared/pro_gate.dart';
import '../../paywall/paywall_screen.dart';

/// Says whether the owner has Pro, and offers the two ways to get it back.
///
/// Confirms Pro landed, and carries Restore purchase. Everywhere else the
/// paywall opens only once an allowance is spent, so an owner on a new phone
/// would have to log five entries to reach the button.
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

    final entriesShown = entries == null
        ? null
        : shownAsUsed(used: entries, free: ProductConfig.freeEntries);
    final simulationsShown = simulations == null
        ? null
        : shownAsUsed(used: simulations, free: ProductConfig.freeSimulations);

    return [
      if (entriesShown != null)
        Text(
          l10n.freeEntriesUsed(entriesShown, ProductConfig.freeEntries),
          style: AppTextStyles.caption,
        ),
      if (simulationsShown != null)
        Text(
          l10n.freeSimulationsUsed(
            simulationsShown,
            ProductConfig.freeSimulations,
          ),
          style: AppTextStyles.caption,
        ),
      if (entriesShown != null || simulationsShown != null)
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
