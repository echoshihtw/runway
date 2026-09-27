import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
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

/// One screen: the promise, its price, and the ask.
///
/// It was three. The first said the app tells you how long your money lasts
/// and the third said it needs one number to do it, which is one thought. The
/// second argued for privacy in four bullets before the owner had typed
/// anything to be private about, and its strongest line was already the first
/// screen's subtitle. The app's own copy is "one number and you are set up",
/// so three screens to reach the field contradicted it.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

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

  /// The screen fading itself in is motion nobody asked for, so under Reduce
  /// Motion it arrives already here. MediaQuery is not safe in initState,
  /// which is why this is not decided there.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.isReduced(context)) _fadeCtrl.value = 1;
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await markOnboardingDone();
    if (!mounted) return;
    // Go to the dashboard; the Getting Started card guides them from there.
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: SC.pageGround,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.gradientBackground,
              ),
            ),
            // Cropped by the Stack, which is the point: cut paper, not a
            // centred illustration.
            // Kept clear of the text: the violet sat at 0.30 with its cut edge
            // running through the headline, and the spark sat on a word.
            Positioned(
              top: -150,
              right: -130,
              child: _CutPaper(
                points: _CutPaper.field,
                size: 300,
                color: SC.decor.withValues(alpha: 0.16),
                turns: -0.3,
              ),
            ),
            Positioned(
              bottom: -60,
              left: -150,
              child: _CutPaper(
                points: _CutPaper.field,
                size: 400,
                color: SC.decor.withValues(alpha: 0.10),
                turns: 0.55,
              ),
            ),
            Positioned(
              bottom: 210,
              right: 34,
              child: _CutPaper(
                points: _CutPaper.spark,
                size: 26,
                color: SC.decor.withValues(alpha: 0.55),
                turns: 0.3,
              ),
            ),
            _Page(onStart: _finish),
            // Skip stays: the balance can be added later, and a first screen
            // with no way past it is a wall.
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: GestureDetector(
                    onTap: _finish,
                    behavior: HitTestBehavior.opaque,
                    child: Semantics(
                      button: true,
                      child: Text(
                        l10n.onboardingSkip,
                        style: AppTextStyles.caption.copyWith(
                          color: SC.labelColor,
                        ),
                      ),
                    ),
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

/// The marketing shape language, as paths. `assets/brand/shapes` holds these
/// as SVG, and there is no SVG renderer in the app; they are polygons, so they
/// draw like StarMark does. Rotated and cropped rather than centred, which is
/// what the shapes README asks for.
class _CutPaper extends StatelessWidget {
  const _CutPaper({
    required this.points,
    required this.size,
    required this.color,
    this.turns = 0,
  });

  static const field = <Offset>[
    Offset(7, 8), Offset(88, 0), Offset(100, 77), Offset(18, 100),
  ];
  static const spark = <Offset>[
    Offset(50, 0), Offset(59, 39), Offset(100, 50), Offset(59, 60),
    Offset(50, 100), Offset(40, 60), Offset(0, 50), Offset(40, 39),
  ];

  final List<Offset> points;
  final double size;
  final Color color;
  final double turns;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Transform.rotate(
      angle: turns,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _PolygonPainter(points, color)),
      ),
    ),
  );
}

class _PolygonPainter extends CustomPainter {
  const _PolygonPainter(this.points, this.color);

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.shortestSide / 100;
    canvas.drawPath(
      Path()..addPolygon([for (final p in points) Offset(p.dx * k, p.dy * k)], true),
      Paint()..color = color..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_PolygonPainter old) =>
      old.color != color || old.points != points;
}

class _Page extends StatelessWidget {
  const _Page({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                    const Spacer(flex: 2),
                    Transform.rotate(angle: -0.14, child: const StarMark()),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.onboardingWelcomeTitle,
                      style: AppTextStyles.heroLarge.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: SC.numberPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _Mechanic(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.onboardingPreviewCaption,
                      style: AppTextStyles.caption.copyWith(
                        color: SC.labelColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Two claims, not four. These are the ones that decide
                    // whether it is safe to type a balance; the rest were
                    // answering a worry nobody has before they have typed one.
                    _Point(l10n.onboardingWelcomeBody),
                    _Point(l10n.onboardingPrivacyEncrypted),
                    const Spacer(flex: 3),
                    NeoButton(
                      label: l10n.onboardingAddMyBalance,
                      variant: NeoButtonVariant.primary,
                      fullWidth: true,
                      color: SC.btnPrimary,
                      onPressed: onStart,
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

/// What goes in and what comes out. No example cash figure: the app ships six
/// currencies, so a number here would be wrong in five of them, and cash is
/// the one figure a new owner could mistake for their own.
class _Mechanic extends ConsumerWidget {
  const _Mechanic();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '';
    return Row(
      children: [
        Expanded(
          child: _Box(
            label: l10n.cash,
            // Not iconDim: that meets 3:1, the bar for icons, and this is
            // text. SC.unknown is also what the runway card uses for a cash
            // figure it does not have, which is exactly what this is.
            value: symbol.isEmpty ? '—' : '$symbol —',
            color: SC.unknown,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: StarMark(size: 13, color: SC.iconDim),
        ),
        Expanded(
          child: _Box(
            label: l10n.runway,
            value: '12',
            color: SC.btnPrimary,
            big: true,
          ),
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.label,
    required this.value,
    required this.color,
    this.big = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool big;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: SC.cardSurface,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      border: Border.all(color: SC.dividerColor),
    ),
    padding: const EdgeInsets.symmetric(
      vertical: AppSpacing.md,
      horizontal: AppSpacing.sm,
    ),
    child: Column(
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: (big ? AppTextStyles.hero : AppTextStyles.metric).copyWith(
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _Point extends StatelessWidget {
  const _Point(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: StarMark(size: 7, color: SC.iconDim),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: SC.labelColor,
            ),
          ),
        ),
      ],
    ),
  );
}
