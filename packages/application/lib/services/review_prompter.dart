/// Shows the platform's native App Store rating prompt.
abstract class ReviewPrompter {
  Future<void> requestReview();
}
