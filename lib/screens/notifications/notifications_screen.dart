import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../widgets/branded_lottie.dart';
import '../../widgets/encaisse_refresh.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(inboxNotificationsProvider);
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          TextButton(
            onPressed: () async {
              final uid = ref.read(authStateProvider).value?.uid;
              if (uid == null) return;
              await ref
                  .read(notificationServiceProvider)
                  .markAllRead(uid);
            },
            child: Text(l10n.markAllRead),
          ),
        ],
      ),
      body: EncaisseRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inboxNotificationsProvider);
          await ref.read(inboxNotificationsProvider.future);
        },
        child: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.errorWithDetails('$e'),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: EmptyState(
                      title: l10n.noNotifications,
                      subtitle: l10n.noNotificationsSubtitle,
                      asset: 'assets/lottie/empty.json',
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = items[index];
                return ListTile(
                  leading: Icon(
                    n.read
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                    color: n.read ? AppColors.textSecondary : AppColors.primary,
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.read ? FontWeight.w400 : FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${n.body}\n${formatMovementDateTime(n.createdAt, locale: locale)}',
                  ),
                  isThreeLine: true,
                  onTap: () async {
                    final uid = ref.read(authStateProvider).value?.uid;
                    if (uid != null && !n.read) {
                      await ref
                          .read(notificationServiceProvider)
                          .markRead(uid: uid, notificationId: n.id);
                    }
                    if (n.groupId.isNotEmpty && context.mounted) {
                      context.push('/groups/${n.groupId}');
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
