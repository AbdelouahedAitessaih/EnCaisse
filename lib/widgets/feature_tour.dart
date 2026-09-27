import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';

const kTourHomeDoneKey = 'tour_home_done';
const kTourGroupDoneKey = 'tour_group_done';

/// Simple step-by-step walkthrough dialogs for first-time use.
class FeatureTour {
  static Future<void> showHomeTourIfNeeded(
    BuildContext context,
    SharedPreferences prefs,
  ) async {
    if (prefs.getBool(kTourHomeDoneKey) ?? false) return;
    if (!context.mounted) return;
    await showTour(
      context,
      steps: _homeSteps(AppLocalizations.of(context)),
    );
    await prefs.setBool(kTourHomeDoneKey, true);
  }

  static Future<void> showGroupTourIfNeeded(
    BuildContext context,
    SharedPreferences prefs, {
    required bool isPersonal,
  }) async {
    if (prefs.getBool(kTourGroupDoneKey) ?? false) return;
    if (!context.mounted) return;
    await showTour(
      context,
      steps: _groupSteps(AppLocalizations.of(context), isPersonal: isPersonal),
    );
    await prefs.setBool(kTourGroupDoneKey, true);
  }

  static Future<void> showTour(
    BuildContext context, {
    required List<({String title, String body, IconData icon})> steps,
  }) async {
    final l10n = AppLocalizations.of(context);
    var index = 0;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            final theme = Theme.of(ctx);
            return AlertDialog(
              icon: Icon(step.icon, color: AppColors.primary, size: 40),
              title: Text(
                step.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              content: Text(
                step.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              actions: [
                if (index > 0)
                  TextButton(
                    onPressed: () => setState(() => index--),
                    child: Text(l10n.tourBack),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.tourSkip),
                ),
                FilledButton(
                  onPressed: () {
                    if (isLast) {
                      Navigator.pop(ctx);
                    } else {
                      setState(() => index++);
                    }
                  },
                  child: Text(isLast ? l10n.tourDone : l10n.tourNext),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static List<({String title, String body, IconData icon})> _homeSteps(
    AppLocalizations l10n,
  ) {
    return [
      (
        title: l10n.tourHome1Title,
        body: l10n.tourHome1Body,
        icon: Icons.home_outlined,
      ),
      (
        title: l10n.tourHome2Title,
        body: l10n.tourHome2Body,
        icon: Icons.person_outline,
      ),
      (
        title: l10n.tourHome3Title,
        body: l10n.tourHome3Body,
        icon: Icons.group_add_outlined,
      ),
    ];
  }

  static List<({String title, String body, IconData icon})> _groupSteps(
    AppLocalizations l10n, {
    required bool isPersonal,
  }) {
    return [
      (
        title: l10n.tourGroup1Title,
        body: l10n.tourGroup1Body,
        icon: Icons.account_balance_wallet_outlined,
      ),
      (
        title: l10n.tourGroup2Title,
        body: l10n.tourGroup2Body,
        icon: Icons.add_circle_outline,
      ),
      (
        title: l10n.tourGroup3Title,
        body: isPersonal ? l10n.tourGroup3BodyPersonal : l10n.tourGroup3Body,
        icon: isPersonal ? Icons.insights_outlined : Icons.people_outline,
      ),
    ];
  }
}
