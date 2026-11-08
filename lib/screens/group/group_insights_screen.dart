import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/settle.dart';
import '../../core/utils/user_error.dart';
import '../../l10n/engagement_copy.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/group_insights_section.dart';

class GroupInsightsScreen extends ConsumerStatefulWidget {
  const GroupInsightsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupInsightsScreen> createState() =>
      _GroupInsightsScreenState();
}

class _GroupInsightsScreenState extends ConsumerState<GroupInsightsScreen> {
  /// Mirrors the _confirmingDelete / _deleting authority on GroupScreen. The
  /// backend mints a fresh settlement id for every call, so a second tap is a
  /// second payment rather than a retry, and the server answers it with "A
  /// payment is already waiting for confirmation." That turned a successful
  /// tap into an error snackbar seconds later.
  String? _recordingTransferKey;

  /// Settlement ids with a confirm or cancel write in flight. Without it a
  /// double tap on confirm shows the confirmation twice, and on cancel shows a
  /// success immediately followed by "Only a pending payment can be cancelled".
  final Set<String> _busySettlementIds = <String>{};

  String get groupId => widget.groupId;

  @override
  void dispose() {
    _recordingTransferKey = null;
    _busySettlementIds.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupAsync = ref.watch(groupProvider(groupId));
    final group = groupAsync.value;
    final balance = ref.watch(balanceProvider(groupId));
    final settle = ref.watch(settleProvider(groupId));
    final settlementsAsync = ref.watch(settlementsProvider(groupId));
    final settlements = settlementsAsync.value ?? const [];
    // A failed read must not masquerade as "nothing to settle".
    final settlementsError = settlementsAsync.hasError
        ? userFacingError(settlementsAsync.error!)
        : null;
    final user = ref.watch(authStateProvider).value;
    final currency = group?.currency ?? 'MAD';
    final copy = EngagementCopy.of(context);
    final tones = context.semantic;

    Future<void> recordPayment(SettleTransfer transfer) async {
      final key = '${transfer.fromUid}>${transfer.toUid}:${transfer.amount}';
      if (_recordingTransferKey != null) return;
      final user = ref.read(authStateProvider).value;
      if (user == null || user.uid != transfer.fromUid) return;

      setState(() => _recordingTransferKey = key);
      try {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(copy.recordPayment),
            content: Text(copy.settlementExplanation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(copy.recordPayment),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
        await ref
            .read(settlementServiceProvider)
            .recordPayment(
              groupId: groupId,
              fromUid: user.uid,
              toUid: transfer.toUid,
              amount: transfer.amount,
            );
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(copy.paymentRecordedMessage)));
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetails(userFacingError(error))),
          ),
        );
      } finally {
        if (mounted) setState(() => _recordingTransferKey = null);
      }
    }

    Future<void> markReceived(SettleTransfer transfer) async {
      final key = '${transfer.fromUid}>${transfer.toUid}:${transfer.amount}';
      if (_recordingTransferKey != null) return;
      final user = ref.read(authStateProvider).value;
      if (user == null || user.uid != transfer.toUid) return;

      setState(() => _recordingTransferKey = key);
      try {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.markReceived),
            content: Text(
              l10n.markReceivedConfirm(
                transfer.fromName,
                formatMoney(transfer.amount, currency: currency),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.markReceived),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
        await ref
            .read(settlementServiceProvider)
            .recordPayment(
              groupId: groupId,
              fromUid: transfer.fromUid,
              toUid: user.uid,
              amount: transfer.amount,
              asRecipient: true,
            );
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(copy.paymentConfirmedMessage)));
        await ref.read(reviewServiceProvider).recordSettledPayment();
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetails(userFacingError(error))),
          ),
        );
      } finally {
        if (mounted) setState(() => _recordingTransferKey = null);
      }
    }

    void requestPayment(SettleTransfer transfer) {
      SharePlus.instance.share(
        ShareParams(
          text: l10n.paymentRequestText(
            transfer.fromName,
            formatMoney(transfer.amount, currency: currency),
            group?.name ?? '',
          ),
        ),
      );
    }

    Future<void> confirmPayment(Settlement payment) async {
      if (!_busySettlementIds.add(payment.id)) return;
      setState(() {});
      try {
        await ref
            .read(settlementServiceProvider)
            .confirmReceived(groupId: groupId, settlementId: payment.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(copy.paymentConfirmedMessage)));
        await ref.read(reviewServiceProvider).recordSettledPayment();
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetails(userFacingError(error))),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _busySettlementIds.remove(payment.id));
        }
      }
    }

    Future<void> cancelPayment(Settlement payment) async {
      if (!_busySettlementIds.add(payment.id)) return;
      setState(() {});
      try {
        await ref
            .read(settlementServiceProvider)
            .cancelPayment(groupId: groupId, settlementId: payment.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(copy.paymentCancelled)));
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetails(userFacingError(error))),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _busySettlementIds.remove(payment.id));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.insightsTitle)),
      body: groupAsync.isLoading && group == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (groupAsync.hasError && group == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            userFacingError(groupAsync.error!),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(groupProvider(groupId)),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                if (group != null) ...[
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.balance}: ${formatMoney(balance.total, currency: currency)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tones.positiveInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                GroupInsightsSection(
                  balance: balance,
                  settle: settle,
                  currency: currency,
                  showSettle:
                      group?.isPersonal != true &&
                      (settle.memberNets.length > 1 || settlements.isNotEmpty),
                  currentUid: user?.uid,
                  settlements: settlements,
                  settlementsError: settlementsError,
                  onRetrySettlements: settlementsError == null
                      ? null
                      : () => ref.invalidate(settlementsProvider(groupId)),
                  settlingTransferKey: _recordingTransferKey,
                  busySettlementIds: _busySettlementIds,
                  onRecordPayment: recordPayment,
                  onMarkReceived: markReceived,
                  onRequestPayment: requestPayment,
                  onConfirmSettlement: confirmPayment,
                  onCancelSettlement: cancelPayment,
                ),
              ],
            ),
    );
  }
}
