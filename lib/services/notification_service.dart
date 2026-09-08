import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _local = local ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _db;
  final FlutterLocalNotificationsPlugin _local;

  static const eventChannelId = 'encaisse_events';
  static const _weeklyChannelId = 'encaisse_weekly';

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  Future<void> initialize({required String? uid}) async {
    tz.initializeTimeZones();

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
      await _createChannels();
      _initialized = true;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // Android 13+: also request via local notifications plugin.
    if (!kIsWeb && Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await _foregroundSub?.cancel();
    _foregroundSub =
        FirebaseMessaging.onMessage.listen(_showForegroundMessage);

    if (uid != null) {
      await _saveToken(uid);
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub =
          _messaging.onTokenRefresh.listen((token) => _persistToken(uid, token));
    }

    await scheduleWeeklyDigest();
  }

  /// Kept for API compatibility — inbox delivery is via FCM (Cloud Function).
  Future<void> listenForUserNotifications(String uid) async {
    await _saveToken(uid);
  }

  Future<void> stopListening() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }

  Future<void> _createChannels() async {
    if (kIsWeb || !Platform.isAndroid) return;
    final android = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        eventChannelId,
        'Caisse activity',
        description: 'New movements and member joins',
        importance: Importance.high,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _weeklyChannelId,
        'Weekly digest',
        description: 'Your caisse summary for the week',
        importance: Importance.defaultImportance,
      ),
    );
  }

  Future<void> _saveToken(String uid) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _persistToken(uid, token);
    }
  }

  Future<void> _persistToken(String uid, String token) async {
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();
    // Do not create a stub user doc — that races profile creation.
    if (!snap.exists) return;
    await ref.set({
      'fcmToken': token,
      'fcmTokens': FieldValue.arrayUnion([token]),
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ??
        message.data['title'] as String? ??
        'EnCaisse';
    final body =
        notification?.body ?? message.data['body'] as String? ?? '';
    if (body.isEmpty && notification == null) return;
    await _showLocalEvent(
      title: title,
      body: body,
      id: message.messageId?.hashCode ??
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

  Future<void> scheduleWeeklyDigest({
    String body = 'Open EnCaisse to see your caisse this week.',
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    while (next.weekday != DateTime.sunday || next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }

    await _local.zonedSchedule(
      1001,
      'Your caisse this week',
      body,
      next,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _weeklyChannelId,
          'Weekly digest',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Fan-out to every non-muted member except [actorUid].
  /// Docs in `users/{uid}/notifications` trigger Cloud Function → FCM push.
  Future<void> notifyGroupEvent({
    required String groupId,
    required String title,
    required String body,
    required String actorUid,
    required String type,
    String? actorName,
  }) async {
    final members = await _db
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .get();

    WriteBatch batch = _db.batch();
    var ops = 0;
    for (final member in members.docs) {
      if (member.id == actorUid) continue;
      final muted = member.data()['notificationsMuted'] as bool? ?? false;
      if (muted) continue;

      final notifRef = _db
          .collection('users')
          .doc(member.id)
          .collection('notifications')
          .doc();
      batch.set(notifRef, {
        'groupId': groupId,
        'title': title,
        'body': body,
        'type': type,
        'actorUid': actorUid,
        if (actorName != null) 'actorName': actorName,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      ops++;
      if (ops >= 450) {
        await batch.commit();
        batch = _db.batch();
        ops = 0;
      }
    }
    if (ops > 0) {
      await batch.commit();
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Notification payloads are shown by the OS when the app is backgrounded
  // or killed. Data-only messages can be handled here if needed later.
}
