import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingDone = 'onboarding_done';

/// Check if onboarding has been completed
Future<bool> hasCompletedOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingDone) ?? false;
}

Future<void> markOnboardingDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingDone, true);
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _page = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _totalPages = 3;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    await markOnboardingDone();
    if (!mounted) return;
    // Go to HUD — Getting Started card guides them from there
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.gradientBackground,
              ),
            ),

            // Pages
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                _PageWelcome(onNext: _next),
                _PagePrivacy(onNext: _next),
                _PageFirstAction(onFinish: _finish),
              ],
            ),

            // Progress dots + skip
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Row(
                        children: List.generate(
                          _totalPages,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: i == _page ? 20 : 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: i == _page
                                  ? AppColors.neonGreen
                                  : AppColors.cardBorder,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      // Skip
                      if (_page < _totalPages - 1)
                        GestureDetector(
                          onTap: _skip,
                          child: Text(
                            context.l10n.onboardingSkip,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1: Welcome ───────────────────────────────────────────
class _PageWelcome extends StatelessWidget {
  final VoidCallback onNext;
  const _PageWelcome({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _PageLayout(
      icon: '◈',
      iconData: Icons.radio_button_checked_rounded,
      iconColor: AppColors.neonGreen,
      title: l10n.onboardingWelcomeTitle,
      subtitle: l10n.onboardingWelcomeBody,
      cta: l10n.onboardingGetStarted,
      onNext: onNext,
    );
  }
}

// ── Page 2: Privacy ───────────────────────────────────────────
class _PagePrivacy extends StatelessWidget {
  final VoidCallback onNext;
  const _PagePrivacy({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _PageLayout(
      icon: '🔒',
      iconData: Icons.lock_rounded,
      iconColor: AppColors.neonGreen,
      title: l10n.onboardingPrivacyTitle,
      subtitle: l10n.onboardingPrivacyBody,
      extras: const _PrivacyPoints(),
      cta: l10n.onboardingIUnderstand,
      onNext: onNext,
    );
  }
}

class _PrivacyPoints extends StatelessWidget {
  const _PrivacyPoints();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final points = [
      ('🔐', l10n.onboardingPrivacyEncrypted),
      ('📱', l10n.onboardingPrivacyOnDevice),
      ('🙈', l10n.onboardingPrivacyHidden),
      ('🗑️', l10n.onboardingPrivacyDelete),
    ];

    return Column(
      children: points
          .map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Text(p.$1, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      p.$2,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Page 3: First Action ──────────────────────────────────────
class _PageFirstAction extends StatelessWidget {
  final VoidCallback onFinish;
  const _PageFirstAction({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _PageLayout(
      icon: '🚀',
      iconData: Icons.rocket_launch_rounded,
      iconColor: AppColors.neonGreen,
      title: l10n.onboardingFirstActionTitle,
      subtitle: l10n.onboardingFirstActionBody,
      cta: l10n.onboardingAddMyBalance,
      ctaColor: AppColors.neonGreen,
      onNext: onFinish,
    );
  }
}

// ── Reusable page layout ──────────────────────────────────────
class _PageLayout extends StatelessWidget {
  final String icon;
  final IconData iconData;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? extras;
  final String cta;
  final Color? ctaColor;
  final VoidCallback onNext;

  const _PageLayout({
    required this.icon,
    required this.iconData,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.extras,
    required this.cta,
    this.ctaColor,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // The content scrolls and the button is pinned below it. A fixed Column
    // with a Spacer had nowhere to put a longer headline, a longer language or
    // a larger text setting: the first screen anyone sees overflowed on a
    // small phone at the default text size, and by nearly four hundred pixels
    // with the text turned up. LayoutBuilder so the content still fills the
    // screen and the Spacer still pushes the button to the bottom when there
    // is room, which is what the design wants when it fits.
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  80,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Text(
                      icon,
                      style: TextStyle(
                        fontSize: icon.length == 1 && icon.codeUnitAt(0) < 256
                            ? 48
                            : 48,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Title
                    Text(
                      title,
                      style: AppTextStyles.heroLarge.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Subtitle
                    Text(
                      subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),

                    if (extras != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      extras!,
                    ],

                    const Spacer(),

                    // CTA
                    NeoButton(
                      label: cta,
                      variant: NeoButtonVariant.primary,
                      fullWidth: true,
                      color: ctaColor,
                      onPressed: onNext,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
