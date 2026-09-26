import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.fcmToken,
    this.movementSuccessCount = 0,
    this.groupsCreatedCount = 0,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final String? fcmToken;
  final int movementSuccessCount;
  final int groupsCreatedCount;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
      fcmToken: data['fcmToken'] as String?,
      movementSuccessCount: (data['movementSuccessCount'] as num?)?.toInt() ?? 0,
      groupsCreatedCount: (data['groupsCreatedCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'fcmToken': fcmToken,
        'movementSuccessCount': movementSuccessCount,
        'groupsCreatedCount': groupsCreatedCount,
      };

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? fcmToken,
    int? movementSuccessCount,
    int? groupsCreatedCount,
    bool clearPhotoUrl = false,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      createdAt: createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      movementSuccessCount:
          movementSuccessCount ?? this.movementSuccessCount,
      groupsCreatedCount: groupsCreatedCount ?? this.groupsCreatedCount,
    );
  }
}

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.inviteCode,
    required this.currency,
    this.photoUrl,
    this.isPersonal = false,
  });

  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final String inviteCode;
  final String currency;
  final String? photoUrl;
  /// Solo caisse for personal tracking (no invite / shared settle needed).
  final bool isPersonal;

  factory Group.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return Group(
      id: doc.id,
      name: data['name'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
      inviteCode: data['inviteCode'] as String? ?? '',
      currency: data['currency'] as String? ?? 'MAD',
      photoUrl: data['photoUrl'] as String?,
      isPersonal: data['isPersonal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
        'inviteCode': inviteCode,
        'currency': currency,
        'isPersonal': isPersonal,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };
}

class GroupMember {
  const GroupMember({
    required this.uid,
    required this.displayName,
    required this.joinedAt,
    this.photoUrl,
    this.notificationsMuted = false,
  });

  final String uid;
  final String displayName;
  final DateTime joinedAt;
  final String? photoUrl;
  final bool notificationsMuted;

  factory GroupMember.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return GroupMember(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      joinedAt: _toDate(data['joinedAt']) ?? DateTime.now(),
      photoUrl: data['photoUrl'] as String?,
      notificationsMuted: data['notificationsMuted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'joinedAt': Timestamp.fromDate(joinedAt),
        'photoUrl': photoUrl,
        'notificationsMuted': notificationsMuted,
      };
}

enum MovementType { deposit, expense }

extension MovementTypeX on MovementType {
  String get value => name;

  static MovementType fromString(String? raw) {
    return raw == 'expense' ? MovementType.expense : MovementType.deposit;
  }
}

class Movement {
  const Movement({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.category,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedBy,
    this.receiptUrl,
    this.deleted = false,
    this.deletedAt,
    this.isStartingBalance = false,
  });

  final String id;
  final MovementType type;
  final double amount;
  final String title;
  final String category;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedBy;
  final String? receiptUrl;
  final bool deleted;
  final DateTime? deletedAt;
  /// Starting caisse balance — only the group creator may edit or delete.
  final bool isStartingBalance;

  bool get hasReceipt =>
      receiptUrl != null && receiptUrl!.trim().isNotEmpty;

  double get signedAmount =>
      type == MovementType.expense ? -amount.abs() : amount.abs();

  bool get canUndo {
    if (!deleted || deletedAt == null) return false;
    return DateTime.now().difference(deletedAt!) < const Duration(hours: 24);
  }

  factory Movement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Movement(
      id: doc.id,
      type: MovementTypeX.fromString(data['type'] as String?),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      createdBy: data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String? ?? '',
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _toDate(data['updatedAt']) ?? DateTime.now(),
      updatedBy: data['updatedBy'] as String? ?? '',
      receiptUrl: _nonEmpty(data['receiptUrl'] as String?),
      deleted: data['deleted'] as bool? ?? false,
      deletedAt: _toDate(data['deletedAt']),
      isStartingBalance: data['isStartingBalance'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.value,
        'amount': amount,
        'title': title,
        'category': category,
        'createdBy': createdBy,
        'createdByName': createdByName,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'updatedBy': updatedBy,
        'receiptUrl': receiptUrl,
        'deleted': deleted,
        'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
        'isStartingBalance': isStartingBalance,
      };

  Map<String, dynamic> toAuditSnapshot() => {
        'type': type.value,
        'amount': amount,
        'title': title,
        'category': category,
        'createdBy': createdBy,
        'createdByName': createdByName,
        'receiptUrl': receiptUrl,
        'deleted': deleted,
        'isStartingBalance': isStartingBalance,
      };
}

enum AuditAction { create, update, delete }

extension AuditActionX on AuditAction {
  String get value => name;

  static AuditAction fromString(String? raw) {
    switch (raw) {
      case 'update':
        return AuditAction.update;
      case 'delete':
        return AuditAction.delete;
      default:
        return AuditAction.create;
    }
  }
}

class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.movementId,
    required this.action,
    required this.performedBy,
    required this.performedByName,
    required this.timestamp,
    this.before,
    this.after,
  });

  final String id;
  final String movementId;
  final AuditAction action;
  final String performedBy;
  final String performedByName;
  final DateTime timestamp;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;

  factory AuditEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AuditEntry(
      id: doc.id,
      movementId: data['movementId'] as String? ?? '',
      action: AuditActionX.fromString(data['action'] as String?),
      performedBy: data['performedBy'] as String? ?? '',
      performedByName: data['performedByName'] as String? ?? '',
      timestamp: _toDate(data['timestamp']) ?? DateTime.now(),
      before: data['before'] as Map<String, dynamic>?,
      after: data['after'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() => {
        'movementId': movementId,
        'action': action.value,
        'performedBy': performedBy,
        'performedByName': performedByName,
        'timestamp': Timestamp.fromDate(timestamp),
        'before': before,
        'after': after,
      };
}

class BalanceSummary {
  const BalanceSummary({
    required this.total,
    required this.deposits,
    required this.expenses,
    required this.byCategory,
  });

  final double total;
  final double deposits;
  final double expenses;
  final Map<String, double> byCategory;

  static BalanceSummary fromMovements(List<Movement> movements) {
    var deposits = 0.0;
    var expenses = 0.0;
    final byCategory = <String, double>{};

    for (final m in movements) {
      if (m.deleted) continue;
      if (m.type == MovementType.deposit) {
        deposits += m.amount.abs();
        byCategory[m.category] =
            (byCategory[m.category] ?? 0) + m.amount.abs();
      } else {
        expenses += m.amount.abs();
        byCategory[m.category] =
            (byCategory[m.category] ?? 0) - m.amount.abs();
      }
    }

    return BalanceSummary(
      total: deposits - expenses,
      deposits: deposits,
      expenses: expenses,
      byCategory: byCategory,
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.groupId,
    required this.title,
    required this.body,
    required this.type,
    required this.actorUid,
    required this.createdAt,
    required this.read,
    this.actorName,
  });

  final String id;
  final String groupId;
  final String title;
  final String body;
  final String type;
  final String actorUid;
  final String? actorName;
  final DateTime createdAt;
  final bool read;

  factory AppNotification.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AppNotification(
      id: doc.id,
      groupId: data['groupId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? '',
      actorUid: data['actorUid'] as String? ?? '',
      actorName: data['actorName'] as String?,
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
