import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/currencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/user_error.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/device_region.dart';
import '../../widgets/app_components.dart';
import '../../widgets/authorized_image.dart';
import '../../widgets/branded_lottie.dart';
import '../../widgets/encaisse_refresh.dart';
import '../../widgets/feature_tour.dart';
import '../../widgets/group_balance_preview.dart';
import '../../widgets/home_banner_ad.dart';
import '../../providers/settings_provider.dart';

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
    final pendingDeletes = ref.watch(pendingGroupDeletionsProvider);
    final groupsAsync = ref
        .watch(userGroupsProvider)
        .whenData(
          (groups) => pendingDeletes.isEmpty
              ? groups
              : groups.where((g) => !pendingDeletes.contains(g.id)).toList(),
        );
    final profile = ref.watch(currentUserProfileProvider).value;
    final scheme = Theme.of(context).colorScheme;
    final unread = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        // A brand wordmark, not a localized title: it reads the same in every
        // language and direction.
        title: Text(
          AppConstants.appName,
          textDirection: TextDirection.ltr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        actions: [
          AppIconButton(
            icon: Icons.help_outline,
            tooltip: l10n.howToUse,
            onPressed: () async {
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.setBool(kTourHomeDoneKey, false);
              if (!context.mounted) return;
              await FeatureTour.showHomeTourIfNeeded(context, prefs);
            },
          ),
          AppIconButton(
            icon: unread > 0
                ? Icons.notifications
                : Icons.notifications_outlined,
            tooltip: l10n.notifications,
            color: unread > 0 ? scheme.primary : scheme.onSurfaceVariant,
            onPressed: () => context.push('/notifications'),
          ),
          AppIconButton(
            icon: Icons.settings_outlined,
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          if (_openingPersonal) const LinearProgressIndicator(minHeight: 2),
          if (groupsAsync.hasValue)
            _HomeWidgetSync(groups: groupsAsync.requireValue),
          Expanded(
            child: EncaisseRefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userGroupsProvider);
                await ref.read(userGroupsProvider.future);
              },
              child: groupsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        l10n.couldNotLoadGroups,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  ],
                ),
                data: (groups) {
                  final personalGroups = groups
                      .where((g) => g.isPersonal)
                      .toList();
                  final shared = groups.where((g) => !g.isPersonal).toList();
                  final personal = personalGroups.isEmpty
                      ? null
                      : personalGroups.first;

                  if (groups.isEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: constraints.maxHeight,
                            child: EmptyState(
                              title: l10n.noGroupsYet,
                              subtitle: l10n.noGroupsSubtitle,
                              asset: 'assets/lottie/empty_group.json',
                              action: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _openingPersonal
                                        ? null
                                        : _openPersonalCaisse,
                                    icon: const Icon(Icons.person_outline),
                                    label: Text(l10n.personalCaisse),
                                  ),
                                  const SizedBox(height: AppSpacing.smd),
                                  OutlinedButton(
                                    onPressed: () =>
                                        context.push('/groups/create'),
                                    child: Text(l10n.createAGroup),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  TextButton(
                                    onPressed: () =>
                                        context.push('/groups/join'),
                                    child: Text(l10n.joinWithCode),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    children: [
                      const SizedBox(height: AppSpacing.xs),
                      AppPage(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile != null
                                  ? l10n.helloName(
                                      profile.displayName.split(' ').first,
                                    )
                                  : l10n.hello,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/groups/create'),
                              icon: const Icon(Icons.group_add_outlined),
                              label: Text(l10n.createAGroup),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.spaceEvenly,
                                children: [
                                  if (personal == null)
                                    TextButton.icon(
                                      onPressed: _openingPersonal
                                          ? null
                                          : _openPersonalCaisse,
                                      icon: const Icon(
                                        Icons.person_outline,
                                        size: 18,
                                      ),
                                      label: Text(l10n.personalCaisse),
                                    ),
                                  TextButton.icon(
                                    onPressed: () =>
                                        context.push('/groups/join'),
                                    icon: const Icon(
                                      Icons.vpn_key_outlined,
                                      size: 18,
                                    ),
                                    label: Text(l10n.joinWithCode),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (shared.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppPage(
                          child: AppSectionHeader(
                            title: l10n.yourCaisses,
                            trailing: AppPill(label: '${shared.length}'),
                          ),
                        ),
                        if (shared.length > 1) _BalanceSummary(groups: shared),
                        AppPage(
                          child: Column(
                            children: [
                              for (final group in shared) ...[
                                _GroupCard(group: group),
                                const SizedBox(height: AppSpacing.smd),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (personal != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppPage(
                          child: AppSectionHeader(title: l10n.personalCaisse),
                        ),
                        AppPage(
                          child: Column(
                            children: [
                              _GroupCard(group: personal),
                              const SizedBox(height: AppSpacing.smd),
                            ],
                          ),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.gutter,
                        ),
                        child: HomeBannerAd(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary of the shared caisses, deliberately subordinate to the per-caisse
/// balance printed on every card below it.
///
/// Balances held in different currencies are never added together: when the
/// caisses do not share one currency there is no total at all, only a note
/// saying why.
class _BalanceSummary extends ConsumerWidget {
  const _BalanceSummary({required this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tones = context.semantic;

    final codes = groups.map((g) => g.currency).toSet();
    final currency = codes.length == 1 ? codes.first : null;

    if (currency == null) {
      return AppPage(
        child: Text(
          l10n.balancePerCaisse,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    var deposits = 0.0;
    var expenses = 0.0;
    for (final group in groups) {
      final balance = ref.watch(balanceProvider(group.id));
      deposits += balance.deposits;
      expenses += balance.expenses;
    }
    final net = deposits - expenses;

    return AppPage(
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.balanceAcrossCaisses(groups.length),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            formatMoney(net, currency: currency),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleMedium?.asMoneyInline(
              color: net < 0 ? tones.negativeInk : tones.positiveInk,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mirrors the caisse list onto the home-screen widget. Renders nothing.
class _HomeWidgetSync extends ConsumerWidget {
  const _HomeWidgetSync({required this.groups});

  static const _maxLines = 4;

  final List<Group> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ordered = [
      ...groups.where((g) => !g.isPersonal),
      ...groups.where((g) => g.isPersonal),
    ];
    final lines = <String>[
      for (final group in ordered.take(_maxLines))
        '${group.name}  ${formatMoney(ref.watch(balanceProvider(group.id)).total, currency: group.currency)}',
    ];
    if (ordered.length > _maxLines) {
      lines.add(l10n.homeWidgetMore(ordered.length - _maxLines));
    }
    final body = lines.isEmpty ? l10n.noGroupsYet : lines.join('\n');
    final updated = l10n.homeWidgetUpdated(
      MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.now()),
    );
    final service = ref.read(homeWidgetServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      service.publish(
        title: AppConstants.appName,
        body: body,
        updated: updated,
      );
    });
    return const SizedBox.shrink();
  }
}

class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tones = context.semantic;
    final members = group.isPersonal
        ? null
        : ref.watch(groupMembersProvider(group.id)).value?.length;
    final balance = ref.watch(balanceProvider(group.id)).total;

    return AppSurface(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/groups/${group.id}');
      },
      padding: const EdgeInsets.all(AppSpacing.smd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tones.positiveSurface,
              borderRadius: BorderRadius.circular(AppRadii.field),
            ),
            child: group.photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.field),
                    child: AuthorizedImage(
                      url: group.photoUrl!,
                      width: AppSizes.avatarMd,
                      height: AppSizes.avatarMd,
                    ),
                  )
                : Text(
                    group.name.isNotEmpty ? group.name[0].toUpperCase() : 'E',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: tones.positiveInk,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (group.isPersonal) ...[
                      const SizedBox(width: AppSpacing.sm),
                      AppPill(
                        label: AppLocalizations.of(context).personalBadge,
                        color: tones.positiveInk,
                        background: tones.positiveSurface,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                GroupBalancePreview(group: group),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatMoney(balance, currency: group.currency),
                maxLines: 1,
                style: theme.textTheme.titleSmall?.asMoneyInline(
                  color: balance < 0 ? tones.negativeInk : null,
                ),
              ),
              if (members != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xxs + 1),
                    Text('$members', style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
