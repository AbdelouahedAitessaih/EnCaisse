import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/ad_service.dart';
import '../services/app_update_service.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';
import '../services/exchange_rate_service.dart';
import '../services/export_service.dart';
import '../services/group_service.dart';
import '../services/home_widget_service.dart';
import '../services/movement_service.dart';
import '../services/notification_service.dart';
import '../services/review_service.dart';
import '../services/settlement_service.dart';
import '../services/storage_service.dart';
import '../core/utils/settle.dart';

final firebaseReadyProvider = Provider<bool>((ref) => false);

final appUpdateServiceProvider = Provider<AppUpdateService>(
  (ref) => AppUpdateService(),
);

final backendServiceProvider = Provider<BackendService>(
  (ref) => BackendService(),
);

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final groupServiceProvider = Provider<GroupService>((ref) => GroupService());

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

final movementServiceProvider = Provider<MovementService>(
  (ref) => MovementService(),
);

final settlementServiceProvider = Provider<SettlementService>(
  (ref) => SettlementService(),
);

final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  ref.onDispose(service.dispose);
  return service;
});

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final reviewServiceProvider = Provider<ReviewService>((ref) => ReviewService());

final authStateProvider = StreamProvider<User?>((ref) {
  // userChanges emits after User.reload() (emailVerified flip); authStateChanges does not.
  return ref.watch(authServiceProvider).userChanges;
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value(null);
  final authService = ref.watch(authServiceProvider);
  // Repair incomplete profiles (e.g. FCM wrote token before signup finished).
  unawaited(authService.repairCurrentProfile());
  return authService.watchUserProfile(auth.uid);
});

final userGroupsProvider = StreamProvider<List<Group>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(groupServiceProvider).watchMemberships(user.uid);
});

/// Groups whose deletion was confirmed but is still running on the server.
/// Home hides them at once instead of making the user wait on the group
/// screen; a failed delete removes the id again so the group reappears.
class PendingGroupDeletions extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  void add(String groupId) => state = {...state, groupId};

  void remove(String groupId) => state = {...state}..remove(groupId);
}

final pendingGroupDeletionsProvider =
    NotifierProvider<PendingGroupDeletions, Set<String>>(
      PendingGroupDeletions.new,
    );

final groupProvider = StreamProvider.family<Group?, String>((ref, groupId) {
  return ref.watch(groupServiceProvider).watchGroup(groupId);
});

final groupMembersProvider = StreamProvider.family<List<GroupMember>, String>((
  ref,
  groupId,
) {
  return ref.watch(groupServiceProvider).watchMembers(groupId);
});

final movementsProvider = StreamProvider.family<List<Movement>, String>((
  ref,
  groupId,
) {
  return ref.watch(movementServiceProvider).watchMovements(groupId);
});

/// Balance is ALWAYS derived client-side — never stored in Firestore.
final balanceProvider = Provider.family<BalanceSummary, String>((ref, groupId) {
  final movements = ref.watch(movementsProvider(groupId)).value ?? const [];
  return BalanceSummary.fromMovements(movements);
});

final movementAuditProvider =
    StreamProvider.family<
      List<AuditEntry>,
      ({String groupId, String movementId})
    >((ref, args) {
      return ref
          .watch(movementServiceProvider)
          .watchAuditForMovement(args.groupId, args.movementId);
    });

/// autoDispose matters here: a long-lived instance kept the very first read
/// alive, so a settlement recorded during the session never reached the
/// settlement history until the app was restarted.
final settlementsProvider = StreamProvider.autoDispose
    .family<List<Settlement>, String>((ref, groupId) {
      return ref.watch(settlementServiceProvider).watchSettlements(groupId);
    });

final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

final exchangeRateServiceProvider = Provider<ExchangeRateService>(
  (ref) => ExchangeRateService(),
);

final homeWidgetServiceProvider = Provider<HomeWidgetService>(
  (ref) => HomeWidgetService(),
);

final recurringProvider = StreamProvider.autoDispose
    .family<List<RecurringMovement>, String>((ref, groupId) {
      return ref.watch(movementServiceProvider).watchRecurring(groupId);
    });

final settleProvider = Provider.autoDispose.family<SettleSummary, String>((
  ref,
  groupId,
) {
  final movements = ref.watch(movementsProvider(groupId)).value ?? const [];
  final members = ref.watch(groupMembersProvider(groupId)).value ?? const [];
  final settlements = ref.watch(settlementsProvider(groupId)).value ?? const [];
  return computeSettle(
    members: members,
    movements: movements,
    settlements: settlements,
  );
});

final inboxNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(notificationServiceProvider).watchInbox(user.uid);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final items = ref.watch(inboxNotificationsProvider).value ?? const [];
  return items.where((n) => !n.read).length;
});
