import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/ad_service.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../services/movement_service.dart';
import '../services/notification_service.dart';
import '../services/review_service.dart';
import '../services/storage_service.dart';

final firebaseReadyProvider = Provider<bool>((ref) => false);

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final groupServiceProvider = Provider<GroupService>((ref) => GroupService());

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

final movementServiceProvider =
    Provider<MovementService>((ref) => MovementService());

final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  ref.onDispose(service.dispose);
  return service;
});

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final reviewServiceProvider = Provider<ReviewService>((ref) => ReviewService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
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

final groupProvider =
    StreamProvider.family<Group?, String>((ref, groupId) {
  return ref.watch(groupServiceProvider).watchGroup(groupId);
});

final groupMembersProvider =
    StreamProvider.family<List<GroupMember>, String>((ref, groupId) {
  return ref.watch(groupServiceProvider).watchMembers(groupId);
});

final movementsProvider =
    StreamProvider.family<List<Movement>, String>((ref, groupId) {
  return ref.watch(movementServiceProvider).watchMovements(groupId);
});

/// Balance is ALWAYS derived client-side — never stored in Firestore.
final balanceProvider =
    Provider.family<BalanceSummary, String>((ref, groupId) {
  final movements =
      ref.watch(movementsProvider(groupId)).value ?? const [];
  return BalanceSummary.fromMovements(movements);
});

final movementAuditProvider = StreamProvider.family<List<AuditEntry>,
    ({String groupId, String movementId})>((ref, args) {
  return ref
      .watch(movementServiceProvider)
      .watchAuditForMovement(args.groupId, args.movementId);
});
