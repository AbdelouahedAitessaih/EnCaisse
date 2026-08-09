import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

class ReviewService {
  static const _keyCount = 'movement_success_count';
  static const _keyAsked = 'review_asked';

  Future<void> recordSuccessfulMovement() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_keyCount) ?? 0) + 1;
    await prefs.setInt(_keyCount, count);

    if (count >= AppConstants.movementsBeforeReview &&
        !(prefs.getBool(_keyAsked) ?? false)) {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
        await prefs.setBool(_keyAsked, true);
      }
    }
  }
}
