import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/currencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/user_error.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../widgets/authorized_image.dart';
import '../../providers/settings_provider.dart';
import '../../services/device_region.dart';
import '../../widgets/branded_lottie.dart';
import '../../widgets/encaisse_refresh.dart';
import '../../widgets/feature_tour.dart';
import '../../widgets/home_banner_ad.dart';
import '../../widgets/group_balance_preview.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _tourScheduled = false;
  bool _openingPersonal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _tourScheduled) return;
      _tourScheduled = true;
      FeatureTour.showHomeTourIfNeeded(
        context,
        ref.read(sharedPreferencesProvider),
      );
    });
  }

  Future<void> _openPersonalCaisse() async {
    final l10n = AppLocalizations.of(context);
    final user = ref.read(authStateProvider).value;
    final profile = ref.read(currentUserProfileProvider).value;
    if (user == null || _openingPersonal) return;

    setState(() => _openingPersonal = true);
    try {
      final country = await DeviceRegion.countryCode();
      final currency = AppCurrencies.codeForCountry(country) ?? 'MAD';
      final group = await ref
          .read(groupServiceProvider)
          .ensurePersonalGroup(
            uid: user.uid,
            displayName:
                profile?.displayName ?? user.displayName ?? l10n.member,
            personalName: l10n.personalCaisseName,
            photoUrl: profile?.photoUrl ?? user.photoURL,
            currency: currency,
          );
      if (!mounted) return;
      context.go('/home');
      context.push('/groups/${group.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails(userFacingError(e)))),
        );
      }
    } finally {
      if (mounted) setState(() => _openingPersonal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupsAsync = ref.watch(userGroupsProvider);
    final profile = ref.watch(currentUserProfileProvider).value;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            tooltip: l10n.howToUse,
            onPressed: () async {
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.setBool(kTourHomeDoneKey, false);
              if (!context.mounted) return;
              await FeatureTour.showHomeTourIfNeeded(context, prefs);
            },
            icon: const Icon(Icons.help_outline),
          ),
          IconButton(
            tooltip: l10n.notifications,
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: (ref.watch(unreadNotificationsCountProvider)) > 0,
              label: Text('${ref.watch(unreadNotificationsCountProvider)}'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: l10n.signOut,
            onPressed: () async {
              final uid = ref.read(authStateProvider).value?.uid;
              if (uid != null) {
                await ref
                    .read(notificationServiceProvider)
                    .clearTokenOnSignOut(uid);
              }
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/welcome');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_openingPersonal) const LinearProgressIndicator(minHeight: 2),
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
                                    ElevatedButton.icon(
                                      onPressed: _openingPersonal
                                          ? null
                                          : _openPersonalCaisse,
                                      icon: const Icon(Icons.person_outline),
                                      label: Text(l10n.personalCaisse),
                                    ),
                                    const SizedBox(height: 12),
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
                    itemCount: groups.length + 2,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final hello = profile != null
                            ? l10n.helloName(
                                profile.displayName.split(' ').first,
                              )
                            : l10n.hello;
                        final largeText =
                            MediaQuery.textScalerOf(context).scale(16) >= 20;
                        final homeActionWidth = largeText
                            ? MediaQuery.sizeOf(context).width - 32
                            : (MediaQuery.sizeOf(context).width - 40) / 2;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hello,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    Color(0xFF0B5948),
                                  ],
                                  begin: AlignmentDirectional.topStart,
                                  end: AlignmentDirectional.bottomEnd,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.yourCaisses,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          l10n.homeOverview,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white.withValues(
                                                  alpha: 0.86,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.16,
                                    ),
                                    child: Text(
                                      '${groups.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  SizedBox(
                                    width: homeActionWidth,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          context.push('/groups/create'),
                                      icon: const Icon(
                                        Icons.group_add_outlined,
                                      ),
                                      label: Text(l10n.createAGroup),
                                    ),
                                  ),
                                  SizedBox(
                                    width: homeActionWidth,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          context.push('/groups/join'),
                                      icon: const Icon(Icons.vpn_key_outlined),
                                      label: Text(l10n.joinGroup),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      if (index == groups.length + 1) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: HomeBannerAd(),
                        );
                      }
                      final group = groups[index - 1];
                      final largeText =
                          MediaQuery.textScalerOf(context).scale(16) >= 20;
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
                                      alpha:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 0.2
                                          : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: group.photoUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: AuthorizedImage(
                                            url: group.photoUrl!,
                                            width: 48,
                                            height: 48,
                                          ),
                                        )
                                      : Text(
                                          group.name.isNotEmpty
                                              ? group.name[0].toUpperCase()
                                              : 'E',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (largeText) ...[
                                        Text(
                                          group.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                        if (group.isPersonal)
                                          Align(
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            child: Chip(
                                              label: Text(l10n.personalBadge),
                                            ),
                                          ),
                                      ] else
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                group.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleLarge,
                                              ),
                                            ),
                                            if (group.isPersonal)
                                              Chip(
                                                label: Text(l10n.personalBadge),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                              ),
                                          ],
                                        ),
                                      const SizedBox(height: 2),
                                      Text(
                                        group.isPersonal
                                            ? '${l10n.personalCaisse} · ${group.currency}'
                                            : '${l10n.inviteCode} ${group.inviteCode} · ${group.currency}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      GroupBalancePreview(group: group),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
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
                  leading: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.personalCaisse),
                  subtitle: Text(l10n.personalCaisseSubtitle),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openPersonalCaisse();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.group_add,
                    color: AppColors.primary,
                  ),
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
