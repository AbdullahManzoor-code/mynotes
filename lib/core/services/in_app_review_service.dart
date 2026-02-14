import 'package:in_app_review/in_app_review.dart';

/// Service for handling in-app reviews
class InAppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;

  /// Check if review is available and show it
  Future<void> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    } catch (e) {
      print('Error requesting in-app review: $e');
    }
  }

  /// Open store for review
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing();
    } catch (e) {
      print('Error opening store listing: $e');
    }
  }
}
