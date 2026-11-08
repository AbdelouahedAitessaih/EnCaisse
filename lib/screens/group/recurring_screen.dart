import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/user_error.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/app_components.dart';
import '../../widgets/branded_lottie.dart';
import '../../widgets/compact_dialog.dart';

/// Recurring movements of one caisse, with who set each up, when it runs next
/// and why the last run was skipped.
class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen> {
  final Set<String> _stopping = <String>{};

  Future<void> _stop(RecurringMovement rule) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showCompactDialog<bool>(
      context: context,
      builder: (ctx) => CompactAlertDialog(
        title: Text(l10n.recurringStop),
        content: Text(l10n.recurringStopConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.recurringStop,
              style: TextStyle(color: context.semantic.negativeInk),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted || !_stopping.add(rule.id)) return;
    setState(() {});
    try {
      await ref
          .read(movementServiceProvider)
          .deleteRecurring(groupId: widget.groupId, recurringId: rule.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails(userFacingError(e)))),
        );
      }
    } finally {
      if (mounted) setState(() => _stopping.remove(rule.id));
    }
  }

  String? _problem(RecurringMovement rule, AppLocalizations l10n) {
    return switch (rule.lastError) {
      'insufficient_balance' => l10n.recurringSkippedBalance,
      'split_invalid' => l10n.recurringSkippedSplit,
      'creator_left' => l10n.recurringCreatorLeft,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tones = context.semantic;
    final locale = Localizations.localeOf(context).toString();
    final group = ref.watch(groupProvider(widget.groupId)).value;
    final user = ref.watch(authStateProvider).value;
    final rulesAsync = ref.watch(recurringProvider(widget.groupId));
    final currency = group?.currency ?? 'MAD';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTitle)),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.errorWithDetails(userFacingError(e)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.invalidate(recurringProvider(widget.groupId)),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (rules) {
          if (rules.isEmpty) {
            return EmptyState(
              title: l10n.recurringTitle,
              subtitle: l10n.recurringEmpty,
              asset: 'assets/lottie/empty_movements.json',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            itemCount: rules.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.smd),
            itemBuilder: (context, index) {
              final rule = rules[index];
              final isDeposit = rule.type == MovementType.deposit;
              final ink = isDeposit ? tones.positiveInk : tones.negativeInk;
              final canStop =
                  user != null &&
                  (rule.createdBy == user.uid || group?.createdBy == user.uid);
              final problem = _problem(rule, l10n);
              return Container(
                padding: const EdgeInsets.all(AppSpacing.smd),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.field),
                  border: Border.all(color: scheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            rule.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppAmount(
                          amount: isDeposit ? rule.amount : -rule.amount,
                          currency: currency,
                          semantic: tones,
                          style: theme.textTheme.titleMedium?.asMoneyInline(
                            color: ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      [
                        rule.frequency == RecurrenceFrequency.weekly
                            ? l10n.repeatWeekly
                            : l10n.repeatMonthly,
                        l10n.categoryLabel(rule.category),
                        rule.createdByName,
                        if (rule.hasSplit) l10n.splitCount(rule.split!.length),
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      rule.active
                          ? l10n.recurringNext(
                              formatMovementDate(
                                rule.nextRunAt,
                                locale: locale,
                              ),
                            )
                          : l10n.recurringCreatorLeft,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (problem != null && rule.active) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: tones.warningInk,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              problem,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: tones.warningInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (canStop)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton.icon(
                          onPressed: _stopping.contains(rule.id)
                              ? null
                              : () => _stop(rule),
                          icon: _stopping.contains(rule.id)
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.stop_circle_outlined),
                          label: Text(l10n.recurringStop),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
