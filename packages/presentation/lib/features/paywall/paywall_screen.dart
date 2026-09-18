import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final offeringAsync = ref.watch(proOfferingProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
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
            _titleFor(widget.trigger),
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          ..._proFeatures.map(
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
                  Text(f, style: AppTextStyles.body),
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
            loading: () => const _PriceButton(
              label: 'UNLOCK RUNWAY PRO',
              priceLabel: 'Loading price...',
              loading: true,
              onPressed: null,
            ),
            // Reachable now that fetchOffering lets a failed call propagate
            // instead of swallowing it to null.
            error: (_, __) => const _PriceButton(
              label: 'UNLOCK RUNWAY PRO',
              priceLabel:
                  "Couldn't reach the store. Check your connection and try "
                  'again.',
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
                  ? '${pkg.priceString} · One-time purchase'
                  : "Pro isn't available right now. Please try again later.";
              return _PriceButton(
                label: 'UNLOCK RUNWAY PRO',
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
            label: 'Restore purchase',
            variant: NeoButtonVariant.ghost,
            fullWidth: true,
            onPressed: _loading ? null : _restore,
          ),
          const SizedBox(height: AppSpacing.xs),
          NeoButton(
            label: 'Maybe later',
            variant: NeoButtonVariant.ghost,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: AppSpacing.xs),
          const _LegalLinks(),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  ProPackage? _lifetimePackage(ProOffering? offering) {
    if (offering == null) return null;
    final lifetime = offering.packages
        .where((p) => p.type == ProPackageType.lifetime)
        .firstOrNull;
    return lifetime ?? offering.packages.firstOrNull;
  }

  Future<void> _purchase(ProPackage pkg) async {
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
      if (!e.userCancelled) {
        setState(() => _errorMessage = 'Purchase failed. Please try again.');
      }
    } catch (_) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
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
        setState(() => _errorMessage = 'No previous purchase found.');
      }
    } catch (_) {
      setState(() => _errorMessage = 'Restore failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _titleFor(String trigger) => switch (trigger) {
    'entry_limit' => 'Unlimited entries\nis a Pro feature.',
    'simulation' => 'Unlimited simulations\nis a Pro feature.',
    _ => 'Unlock Runway Pro.',
  };

  // Loans are free (#80). The app is free; the planning tool is the paid part.
  static const _proFeatures = [
    'Unlimited entries',
    'Unlimited scenario simulations',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
