import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product_config.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:url_launcher/url_launcher.dart';
import 'legal_links.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final String trigger;
  const PaywallScreen({super.key, required this.trigger});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _loading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final offeringAsync = ref.watch(proOfferingProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      // The one screen where the app takes money, and it had no height cap
      // and no scroll view: on a small phone it ran off the bottom at the
      // default text size, taking MAYBE LATER with it. Same fault as the
      // subscription sheet before #168 and both loan sheets before #176,
      // same fix.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neonGreen.withAlpha(50)),
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: AppColors.neonGreen,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              _titleFor(l10n, widget.trigger),
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            ..._proFeatures(l10n).map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.neonGreen,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(f, style: AppTextStyles.body)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: AppTextStyles.caption.copyWith(color: AppColors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            offeringAsync.when(
              loading: () => _PriceButton(
                label: l10n.paywallUnlock,
                priceLabel: l10n.paywallLoadingPrice,
                loading: true,
                onPressed: null,
              ),
              // Reachable now that fetchOffering lets a failed call propagate
              // instead of swallowing it to null.
              error: (_, __) => _PriceButton(
                label: l10n.paywallUnlock,
                priceLabel: l10n.paywallStoreUnreachable,
                loading: false,
                onPressed: null,
              ),
              data: (offering) {
                final pkg = _lifetimePackage(offering);
                // No package means RevenueCat has no offering marked Current, or
                // it holds none — a configuration state, not a product. It used
                // to render as "One-time purchase · Unlock forever" over a
                // disabled button: a price line with no price.
                final priceLabel = pkg != null
                    ? l10n.paywallOneTimePurchase(pkg.priceString)
                    : l10n.paywallUnavailable;
                return _PriceButton(
                  label: l10n.paywallUnlock,
                  priceLabel: priceLabel,
                  loading: _loading,
                  onPressed: pkg != null && !_loading
                      ? () => _purchase(pkg)
                      : null,
                );
              },
            ),

            const SizedBox(height: AppSpacing.sm),

            NeoButton(
              label: l10n.paywallRestore,
              variant: NeoButtonVariant.ghost,
              fullWidth: true,
              onPressed: _loading ? null : _restore,
            ),
            const SizedBox(height: AppSpacing.xs),
            NeoButton(
              label: l10n.paywallMaybeLater,
              variant: NeoButtonVariant.ghost,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.xs),
            const _LegalLinks(),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  /// The lifetime package, or nothing.
  ///
  /// This used to fall back to `packages.firstOrNull`, so an offering holding
  /// only a subscription rendered an enabled buy button under copy promising a
  /// one-time purchase — it sold the wrong thing rather than saying it could
  /// not sell (#17). No lifetime package is a configuration problem, and the
  /// screen already has honest words for that.
  ProPackage? _lifetimePackage(ProOffering? offering) => offering?.packages
      .where((p) => p.type == ProPackageType.lifetime)
      .firstOrNull;

  Future<void> _purchase(ProPackage pkg) async {
    final l10n = context.l10n;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final success = await ref
          .read(purchaseNotifierProvider.notifier)
          .purchase(pkg);
      if (!mounted) return;
      if (success) {
        await ref.read(entitlementProvider.notifier).unlockPro();
        if (mounted) Navigator.of(context).pop(true);
      }
    } on PurchaseException catch (e) {
      // The sheet can be dismissed while StoreKit is still deciding; the
      // finally block already checked mounted, the catches did not.
      if (!e.userCancelled && mounted) {
        setState(() => _errorMessage = l10n.paywallPurchaseFailed);
      }
    } catch (_) {
      if (mounted) setState(() => _errorMessage = l10n.paywallSomethingWrong);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
    final l10n = context.l10n;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final success = await ref
          .read(purchaseNotifierProvider.notifier)
          .restore();
      if (!mounted) return;
      if (success) {
        await ref.read(entitlementProvider.notifier).unlockPro();
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = l10n.paywallNoPreviousPurchase);
      }
    } catch (_) {
      if (mounted) setState(() => _errorMessage = l10n.paywallRestoreFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _titleFor(AppLocalizations l10n, String trigger) => switch (trigger) {
    // The wall names what was used, so it arrives as the end of something
    // rather than out of nowhere.
    'entry_limit' => l10n.paywallTitleEntries(ProductConfig.freeEntries),
    'simulation' => l10n.paywallTitleSimulations(ProductConfig.freeSimulations),
    _ => l10n.paywallTitleDefault,
  };

  // Loans are free (#80). The app is free; the planning tool is the paid part.
  List<String> _proFeatures(AppLocalizations l10n) => [
    l10n.paywallFeatureEntries,
    l10n.paywallFeatureSimulations,
  ];
}

class _PriceButton extends StatelessWidget {
  final String label;
  final String priceLabel;
  final bool loading;
  final VoidCallback? onPressed;

  const _PriceButton({
    required this.label,
    required this.priceLabel,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NeoButton(
          label: loading ? '...' : label,
          variant: NeoButtonVariant.primary,
          fullWidth: true,
          onPressed: onPressed,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          priceLabel,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Wrap, not Row: two translated link labels and a separator ran past the
    // edge on a narrow screen, and these are the two links App Review looks
    // for.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        _LegalLink(label: l10n.paywallTermsOfUse, url: kTermsOfUseUrl),
        Text('·', style: AppTextStyles.caption),
        _LegalLink(label: l10n.paywallPrivacyPolicy, url: kPrivacyPolicyUrl),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final Uri url;

  const _LegalLink({required this.label, required this.url});

  Future<void> _open() async {
    try {
      final opened = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      if (!opened) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Nothing useful to show if no browser can open the link.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}

void showPaywall(BuildContext context, {required String trigger}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder: (_) => PaywallScreen(trigger: trigger),
  );
}
