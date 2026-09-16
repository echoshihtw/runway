import 'package:application/application.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _checkedThisLaunch = false;

@visibleForTesting
void resetReviewPromptForTest() => _checkedThisLaunch = false;

/// Asks for an App Store rating at most once per install.
///
/// The request is only considered once per launch, as the dashboard first
/// shows with data, and only on a launch after the one where the user first
/// saw a real runway number. It can't fire during onboarding, on the paywall,
/// or right after a purchase attempt, because those only happen later.
class ReviewPromptTrigger extends ConsumerStatefulWidget {
  const ReviewPromptTrigger({super.key});

  @override
  ConsumerState<ReviewPromptTrigger> createState() =>
      _ReviewPromptTriggerState();
}

class _ReviewPromptTriggerState extends ConsumerState<ReviewPromptTrigger> {
  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final model = ref.watch(modelProvider);
    if (transactions.hasValue) {
      final eligible = isEligibleForReviewPrompt(
        transactions: transactions.value!,
        model: model,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _check(eligible));
    }
    return const SizedBox.shrink();
  }

  Future<void> _check(bool eligible) async {
    final prefs = await SharedPreferences.getInstance();
    if (eligible) await recordReviewEligibility(prefs);
    if (_checkedThisLaunch) return;
    _checkedThisLaunch = true;
    if (!shouldRequestReview(prefs, eligible: eligible)) {
      debugPrint('[Review] not requested this launch');
      return;
    }
    if (!mounted) return;
    debugPrint('[Review] requesting App Store rating');
    await ref.read(reviewPrompterProvider).requestReview();
    await markReviewRequested(prefs);
  }
}
