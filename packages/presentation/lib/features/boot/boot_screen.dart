import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How long a first launch holds the wordmark before onboarding. A returning
/// user never waits: nothing is loading, so nothing should stand between
/// launch and the number.
const kFirstLaunchBrandMoment = Duration(milliseconds: 1000);

/// The first screen. It decides where to go and gets out of the way.
///
/// It used to play seven lines of faux-terminal narration at 400 ms each,
/// then a cursor, then wait again — 4.3 seconds before reading the one
/// preference that decided the route (#117). The core loop is "open the app,
/// read one number", plausibly daily; a fixed delay was the largest friction
/// in the product and entirely self-inflicted. The narration was also the
/// drama the tone disowns.
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  bool _firstLaunch = false;

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;
    if (onboardingDone) {
      context.go('/dashboard');
      return;
    }
    setState(() => _firstLaunch = true);
    await Future.delayed(kFirstLaunchBrandMoment);
    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        // Blank until the route is known — a few milliseconds — and the
        // wordmark alone on a first launch. Nothing that reads as loading.
        child: _firstLaunch
            ? Text(context.l10n.runwayBrand, style: AppTextStyles.metric)
            : const SizedBox.shrink(),
      ),
    );
  }
}
