import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/models.dart';
import 'device_region.dart';

/// Push + local notifications for movement alerts, joins, and weekly digest.
///
/// Delivery path:
/// 1. Writers create docs under `users/{uid}/notifications` (inbox + audit).
/// 2. Cloud Function `sendPushOnNotificationCreated` sends FCM to the user's
///    token(s) so alerts appear even when the app is killed / backgrounded.
/// 3. Foreground: [FirebaseMessaging.onMessage] shows a local notification.
class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? local,
  }) : _messagingField = messaging,
       _firestoreField = firestore,
       _local = local ?? FlutterLocalNotificationsPlugin();

  FirebaseMessaging get _messaging =>
      _messagingField ??= FirebaseMessaging.instance;
  FirebaseFirestore get _db => _firestoreField ??= FirebaseFirestore.instance;
  FirebaseMessaging? _messagingField;
  FirebaseFirestore? _firestoreField;
  final FlutterLocalNotificationsPlugin _local;

  static const eventChannelId = 'encaisse_events';

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  DateTime? _lastActivityWriteAt;
  String? _lastActivityWriteUid;

  Future<void> initialize({required String? uid}) async {
    if (!_initialized) {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _local.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );
      // Remove the old generic weekly nag that prior app versions scheduled.
      await _local.cancel(1001);
      await _createChannels();
      _initialized = true;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (uid != null) await recordAppActivity(uid);

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // Android 13+: also request via local notifications plugin.
    if (!kIsWeb && Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    await _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen(_showForegroundMessage);
    await _openedSub?.cancel();
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageOpen,
    );

    if (uid != null) {
      await _saveToken(uid);
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen(
        (token) => _persistToken(uid, token),
      );
    }

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _pendingGroupId = initial.data['groupId'] as String?;
    }
  }

  String? _pendingGroupId;
  void Function(String groupId)? onOpenGroup;

  /// Consumed once by the app shell to deep-link into a group.
  String? takePendingGroupId() {
    final id = _pendingGroupId;
    _pendingGroupId = null;
    return id;
  }

  void _handleMessageOpen(RemoteMessage message) {
    final groupId = message.data['groupId'] as String?;
    if (groupId != null && groupId.isNotEmpty) {
      _pendingGroupId = groupId;
      onOpenGroup?.call(groupId);
    }
  }

  /// Kept for API compatibility — inbox delivery is via FCM (Cloud Function).
  Future<void> listenForUserNotifications(String uid) async {
    await _saveToken(uid);
  }

  Future<void> stopListening() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    await _foregroundSub?.cancel();
    _foregroundSub = null;
    await _openedSub?.cancel();
    _openedSub = null;
  }

  Future<void> _createChannels() async {
    if (kIsWeb || !Platform.isAndroid) return;
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        eventChannelId,
        'Caisse activity',
        description: 'New movements and member joins',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _saveToken(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _persistToken(uid, token);
      }
    } on FirebaseException catch (e) {
      debugPrint('FCM getToken failed: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('FCM getToken error: $e');
    }
  }

  Future<void> _persistToken(String uid, String token) async {
    try {
      final ref = _db.collection('users').doc(uid);
      final snap = await ref.get();
      // Do not create a stub user doc — that races profile creation.
      if (!snap.exists) return;
      await ref.set({
        'fcmToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debugPrint('FCM persistToken failed: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('FCM persistToken error: $e');
    }
  }

  Future<void> setNotificationPreferences({
    required String uid,
    required bool activityEnabled,
    required bool remindersEnabled,
  }) async {
    await _db.collection('users').doc(uid).set({
      'activityNotificationsEnabled': activityEnabled,
      'remindersEnabled': remindersEnabled,
    }, SetOptions(merge: true));
  }

  Future<void> recordAppActivity(String uid) async {
    final now = DateTime.now();
    if (_lastActivityWriteUid == uid &&
        _lastActivityWriteAt != null &&
        now.difference(_lastActivityWriteAt!) < const Duration(minutes: 30)) {
      return;
    }
    final zoneId = await DeviceRegion.timeZoneId();
    // Best-effort engagement telemetry. It must never surface as an unhandled
    // async error or block the action the user actually took.
    try {
      await _db.collection('users').doc(uid).set({
        'lastActiveAt': FieldValue.serverTimestamp(),
        if (zoneId != null && zoneId.isNotEmpty) 'timeZone': zoneId,
      }, SetOptions(merge: true));
      _lastActivityWriteUid = uid;
      _lastActivityWriteAt = now;
    } on FirebaseException catch (e) {
      debugPrint('recordAppActivity(${e.code}) skipped');
    }
  }

  Future<void> recordGroupViewed({
    required String uid,
    required String groupId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('memberships')
        .doc(groupId)
        .set({
          'lastViewedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title'] as String? ?? 'EnCaisse';
    final body = notification?.body ?? message.data['body'] as String? ?? '';
    if (body.isEmpty && notification == null) return;
    await _showLocalEvent(
      title: title,
      body: body,
      id:
          message.messageId?.hashCode ??
          Object.hash(title, body, DateTime.now().millisecondsSinceEpoch),
    );
  }

  Future<void> _showLocalEvent({
    required String title,
    required String body,
    required int id,
  }) {
    return _local.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          eventChannelId,
          'Caisse activity',
          channelDescription: 'New movements and member joins',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Stream<List<AppNotification>> watchInbox(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => AppNotification.fromDoc(d))
              .toList(growable: false),
        );
  }

  Future<void> markRead({
    required String uid,
    required String notificationId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .set({'read': true}, SetOptions(merge: true));
  }

  Future<void> markAllRead(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .limit(200)
        .get();
    if (snap.docs.isEmpty) return;
    WriteBatch batch = _db.batch();
    var ops = 0;
    for (final doc in snap.docs) {
      batch.set(doc.reference, {'read': true}, SetOptions(merge: true));
      ops++;
      if (ops >= 450) {
        await batch.commit();
        batch = _db.batch();
        ops = 0;
      }
    }
    if (ops > 0) await batch.commit();
  }

  Future<void> clearTokenOnSignOut(String uid) async {
    try {
      final token = await _messaging.getToken();
      final ref = _db.collection('users').doc(uid);
      final snap = await ref.get();
      if (!snap.exists) return;
      final updates = <String, dynamic>{
        'fcmToken': null,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      };
      if (token != null) {
        updates['fcmTokens'] = FieldValue.arrayRemove([token]);
      }
      await ref.set(updates, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debugPrint('clearTokenOnSignOut failed: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('clearTokenOnSignOut error: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Notification payloads are shown by the OS when the app is backgrounded
  // or killed. Data-only messages can be handled here if needed later.
}
