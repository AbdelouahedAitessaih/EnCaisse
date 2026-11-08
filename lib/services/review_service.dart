import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

class ReviewService {
  static const _keyCount = 'movement_success_count';
  static const _keyAsked = 'review_asked';

  /// Increments the local success counter and, once the threshold is reached,
  /// asks for a store review.
  ///
  /// This runs *after* the movement is already committed, so it must never
  /// throw: `in_app_review` goes through a platform channel that can fail or
  /// stall on devices with an unhealthy Play Store, and a propagated error
  /// would report a successful save as failed and invite a duplicate entry.
  Future<void> recordSuccessfulMovement() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_keyCount) ?? 0) + 1;
      await prefs.setInt(_keyCount, count);

      if (count < AppConstants.movementsBeforeReview ||
          (prefs.getBool(_keyAsked) ?? false)) {
        return;
      }

      await _ask(prefs);
    } catch (e) {
      debugPrint('Review prompt skipped: $e');
    }
  }

  /// A settled debt is the moment the app has just been most useful, so the
  /// prompt is offered there without waiting for the movement threshold.
  /// Same never-throw contract as [recordSuccessfulMovement].
  Future<void> recordSettledPayment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyAsked) ?? false) return;
      await _ask(prefs);
    } catch (e) {
      debugPrint('Review prompt skipped: $e');
    }
  }

  Future<void> _ask(SharedPreferences prefs) async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
      await prefs.setBool(_keyAsked, true);
    }
  }
}
