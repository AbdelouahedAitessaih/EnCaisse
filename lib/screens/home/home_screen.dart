import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../widgets/branded_lottie.dart';
import '../../widgets/encaisse_refresh.dart';
import '../../widgets/home_banner_ad.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groupsAsync = ref.watch(userGroupsProvider);
    final profile = ref.watch(currentUserProfileProvider).value;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: l10n.signOut,
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/welcome');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          const HomeBannerAd(),
          Expanded(
            child: EncaisseRefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userGroupsProvider);
                await ref.read(userGroupsProvider.future);
              },
              child: groupsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '${l10n.couldNotLoadGroups}\n$e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
                data: (groups) {
                  if (groups.isEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 88),
                          children: [
                            SizedBox(
                              height: constraints.maxHeight,
                              child: EmptyState(
                                title: l10n.noGroupsYet,
                                subtitle: l10n.noGroupsSubtitle,
                                asset: 'assets/lottie/empty_group.json',
                                action: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          context.push('/groups/create'),
                                      child: Text(l10n.createAGroup),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: () =>
                                          context.push('/groups/join'),
                                      child: Text(l10n.joinWithCode),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: groups.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final hello = profile != null
                            ? l10n.helloName(
                                profile.displayName.split(' ').first,
                              )
                            : l10n.hello;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            hello,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        );
                      }
                      final group = groups[index - 1];
                      return Material(
                        color: scheme.surface,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.push('/groups/${group.id}');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: scheme.outline),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withValues(
                                      alpha: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 0.2
                                          : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    image: group.photoUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(group.photoUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: group.photoUrl == null
                                      ? Text(
                                          group.name.isNotEmpty
                                              ? group.name[0].toUpperCase()
                                              : 'E',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${l10n.inviteCode} ${group.inviteCode} · ${group.currency}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActions(context, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showActions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.group_add, color: AppColors.primary),
                  title: Text(l10n.createAGroup),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/groups/create');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.vpn_key, color: AppColors.accent),
                  title: Text(l10n.joinWithInviteCode),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/groups/join');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
