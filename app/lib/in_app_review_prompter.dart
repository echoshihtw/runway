import 'package:application/application.dart';
import 'package:in_app_review/in_app_review.dart';

/// Apple's native rating prompt. There's no custom "rate us" dialog or
/// incentive, per App Review guideline 5.6.1. iOS decides whether to show it,
/// and it never appears in TestFlight builds.
class InAppReviewPrompter implements ReviewPrompter {
  const InAppReviewPrompter();

  @override
  Future<void> requestReview() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) await review.requestReview();
  }
}
