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
  ConsumerState<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _page = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
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
          curve: Curves.easeInOut);
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
                _PageHowItWorks(onNext: _next),
                _PageProtect(onNext: _next),
                _PageFirstAction(onFinish: _finish),
              ],
            ),

            // Progress dots + skip
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Row(
                        children: List.generate(_totalPages, (i) =>
                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 250),
                            width: i == _page ? 20 : 6,
                            height: 6,
                            margin: const EdgeInsets.only(
                                right: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: i == _page
                                  ? AppColors.neonGreen
                                  : AppColors.cardBorder,
                              borderRadius:
                                  BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      // Skip
                      if (_page < _totalPages - 1)
                        GestureDetector(
                          onTap: _skip,
                          child: Text('SKIP',
                              style: AppTextStyles.caption
                                  .copyWith(
                                      color: AppColors
                                          .textSecondary)),
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
    return _PageLayout(
      icon: '◈',
      iconData: Icons.radio_button_checked_rounded,
      iconColor: AppColors.neonGreen,
      title: 'Know your\nrunway.',
      subtitle:
          'One number tells you everything.\nHow long can you survive financially?',
      cta: 'GET STARTED',
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
    return _PageLayout(
      icon: '🔒',
      iconData: Icons.lock_rounded,
      iconColor: AppColors.neonGreen,
      title: 'Your data,\nyour device.',
      subtitle:
          'Everything is encrypted on your device.\nWe cannot read your financial data.\nEven we don\'t know your numbers.',
      extras: const _PrivacyPoints(),
      cta: 'I UNDERSTAND',
      onNext: onNext,
    );
  }
}

class _PrivacyPoints extends StatelessWidget {
  const _PrivacyPoints();

  @override
  Widget build(BuildContext context) {
    final points = [
      ('🔐', 'Encrypted on device'),
      ('📱', 'Numbers stay on your device'),
      ('👁️', 'No one can read your data'),
      ('🗑️', 'Delete anytime, instantly'),
    ];

    return Column(
      children: points.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(children: [
          Text(p.$1,
              style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.sm),
          Text(p.$2,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
        ]),
      )).toList(),
    );
  }
}

// ── Page 3: How it works ──────────────────────────────────────
class _PageHowItWorks extends StatelessWidget {
  final VoidCallback onNext;
  const _PageHowItWorks({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _PageLayout(
      icon: '📊',
      iconData: Icons.bar_chart_rounded,
      iconColor: AppColors.turkishBlue,
      title: 'Three steps\nto clarity.',
      subtitle: 'No complexity. Just your runway.',
      extras: const _HowItWorksSteps(),
      cta: 'GOT IT',
      onNext: onNext,
    );
  }
}

class _HowItWorksSteps extends StatelessWidget {
  const _HowItWorksSteps();

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('1', 'Add your cash balance',
          'How much money do you have right now?'),
      ('2', 'Log your expenses',
          'Track what goes out each month.'),
      ('3', 'Know your runway',
          'See exactly how long you can survive.'),
    ];

    return Column(
      children: steps.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.neonGreen.withAlpha(50)),
              ),
              child: Center(
                child: Text(s.$1,
                    style: TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$2,
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600)),
                  Text(s.$3,
                      style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ── Page 4: Protect ───────────────────────────────────────────
class _PageProtect extends StatelessWidget {
  final VoidCallback onNext;
  const _PageProtect({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _PageLayout(
      icon: '🛡️',
      iconData: Icons.shield_rounded,
      iconColor: AppColors.hotPink,
      title: 'Lock it\ndown.',
      subtitle:
          'Your financial data is sensitive.\nWe blur the app when you switch away,\nso no one else can see your numbers.',
      extras: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.hotPink.withAlpha(10),
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
                color: AppColors.hotPink.withAlpha(40)),
          ),
          child: Row(children: [
            const Text('👁️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'App automatically blurs when you leave, '
                'like a banking app.',
                style: AppTextStyles.caption,
              ),
            ),
          ]),
        ),
      ),
      cta: 'UNDERSTOOD',
      onNext: onNext,
    );
  }
}

// ── Page 5: First Action ──────────────────────────────────────
class _PageFirstAction extends StatelessWidget {
  final VoidCallback onFinish;
  const _PageFirstAction({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return _PageLayout(
      icon: '🚀',
      iconData: Icons.rocket_launch_rounded,
      iconColor: AppColors.neonGreen,
      title: 'Ready to find\nyour runway?',
      subtitle:
          'Start by adding your current cash balance.\nThat\'s all you need to see your number.',
      cta: 'ADD MY BALANCE',
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 80, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Text(icon,
                style: TextStyle(
                    fontSize: icon.length == 1 &&
                            icon.codeUnitAt(0) < 256
                        ? 48
                        : 48)),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(title,
                style: AppTextStyles.heroLarge.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.15)),
            const SizedBox(height: AppSpacing.md),

            // Subtitle
            Text(subtitle,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6)),

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
    );
  }
}


