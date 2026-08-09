import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// FCM + local notifications for movement alerts, joins, and weekly digest.
///
/// Real-time delivery without Cloud Functions:
/// 1. Writers create docs under `users/{uid}/notifications`.
/// 2. Each device listens to that collection and shows a local notification.
/// Live caisse balances/lists still come from Firestore `.snapshots()`.
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

  static const _weeklyChannelId = 'encaisse_weekly';
  static const _eventChannelId = 'encaisse_events';

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _inboxSub;
  DateTime? _listenStartedAt;
  final Set<String> _seenNotifIds = {};

  Future<void> initialize({required String? uid}) async {
    tz.initializeTimeZones();

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

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    if (uid != null) {
      await _saveToken(uid);
      _messaging.onTokenRefresh.listen((token) => _persistToken(uid, token));
      await listenForUserNotifications(uid);
    }

    FirebaseMessaging.onMessage.listen(_showForegroundMessage);
    await scheduleWeeklyDigest();
  }

  /// Start (or restart) the real-time inbox listener for [uid].
  Future<void> listenForUserNotifications(String uid) async {
    await _inboxSub?.cancel();
    _seenNotifIds.clear();
    _listenStartedAt = DateTime.now().toUtc();

    _inboxSub = _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(25)
        .snapshots()
        .listen((snap) async {
      for (final change in snap.docChanges) {
        if (change.type != DocumentChangeType.added) continue;
        final doc = change.doc;
        if (_seenNotifIds.contains(doc.id)) continue;

        final data = doc.data();
        if (data == null) continue;

        final createdAt = (data['createdAt'] as Timestamp?)?.toDate().toUtc();
        // Skip backlog from before this session (first snapshot).
        if (createdAt == null ||
            _listenStartedAt == null ||
            createdAt.isBefore(
              _listenStartedAt!.subtract(const Duration(seconds: 2)),
            )) {
          _seenNotifIds.add(doc.id);
          continue;
        }

        _seenNotifIds.add(doc.id);
        final title = data['title'] as String? ?? 'EnCaisse';
        final body = data['body'] as String? ?? '';
        await _showLocalEvent(title: title, body: body, id: doc.id.hashCode);
      }
    });
  }

  Future<void> stopListening() async {
    await _inboxSub?.cancel();
    _inboxSub = null;
    _seenNotifIds.clear();
  }

  Future<void> _createChannels() async {
    if (kIsWeb || !Platform.isAndroid) return;
    final android = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _eventChannelId,
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
    // Do not create a stub user doc — that races profile creation and
    // leaves displayName/email empty.
    if (!snap.exists) return;
    await ref.set({'fcmToken': token}, SetOptions(merge: true));
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _showLocalEvent(
      title: notification.title ?? 'EnCaisse',
      body: notification.body ?? '',
      id: notification.hashCode,
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
          _eventChannelId,
          'Caisse activity',
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
  /// Recipients get a real-time local notification via [listenForUserNotifications].
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
  // System tray handles display when a remote FCM message arrives.
}
