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
    this.activityNotificationsEnabled = true,
    this.remindersEnabled = true,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final String? fcmToken;
  final int movementSuccessCount;
  final int groupsCreatedCount;
  final bool activityNotificationsEnabled;
  final bool remindersEnabled;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
      fcmToken: data['fcmToken'] as String?,
      movementSuccessCount:
          (data['movementSuccessCount'] as num?)?.toInt() ?? 0,
      groupsCreatedCount: (data['groupsCreatedCount'] as num?)?.toInt() ?? 0,
      activityNotificationsEnabled:
          data['activityNotificationsEnabled'] as bool? ?? true,
      remindersEnabled: data['remindersEnabled'] as bool? ?? true,
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
    'activityNotificationsEnabled': activityNotificationsEnabled,
    'remindersEnabled': remindersEnabled,
  };

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? fcmToken,
    int? movementSuccessCount,
    int? groupsCreatedCount,
    bool? activityNotificationsEnabled,
    bool? remindersEnabled,
    bool clearPhotoUrl = false,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      createdAt: createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      movementSuccessCount: movementSuccessCount ?? this.movementSuccessCount,
      groupsCreatedCount: groupsCreatedCount ?? this.groupsCreatedCount,
      activityNotificationsEnabled:
          activityNotificationsEnabled ?? this.activityNotificationsEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
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
    this.split,
    this.originalCurrency,
    this.originalAmount,
    this.exchangeRate,
    this.recurringId,
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

  /// Member uid → share of [amount] in the group currency. Null means the
  /// whole amount belongs to [createdBy], which is how every movement recorded
  /// before splits existed is read.
  final Map<String, double>? split;

  /// Set when the movement was entered in another currency; [amount] is then
  /// the converted value in the group currency.
  final String? originalCurrency;
  final double? originalAmount;
  final double? exchangeRate;

  /// Recurring rule that generated this movement, if any.
  final String? recurringId;

  bool get hasReceipt => receiptUrl != null && receiptUrl!.trim().isNotEmpty;

  bool get hasSplit => split != null && split!.isNotEmpty;

  bool get isForeignCurrency =>
      originalCurrency != null && originalAmount != null;

  /// Share of [amount] owned by each member, falling back to [createdBy].
  Map<String, double> get allocation =>
      hasSplit ? split! : {createdBy: amount.abs()};

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
      split: _toSplit(data['split']),
      originalCurrency: _nonEmpty(data['originalCurrency'] as String?),
      originalAmount: (data['originalAmount'] as num?)?.toDouble(),
      exchangeRate: (data['exchangeRate'] as num?)?.toDouble(),
      recurringId: _nonEmpty(data['recurringId'] as String?),
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
    'split': split,
    'originalCurrency': originalCurrency,
    'originalAmount': originalAmount,
    'exchangeRate': exchangeRate,
    'recurringId': recurringId,
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
    'split': split,
    'originalCurrency': originalCurrency,
    'originalAmount': originalAmount,
  };
}

enum RecurrenceFrequency { weekly, monthly }

extension RecurrenceFrequencyX on RecurrenceFrequency {
  String get value => name;

  static RecurrenceFrequency fromString(String? raw) => raw == 'weekly'
      ? RecurrenceFrequency.weekly
      : RecurrenceFrequency.monthly;
}

/// Template the backend replays on schedule to create a movement.
class RecurringMovement {
  const RecurringMovement({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.category,
    required this.frequency,
    required this.nextRunAt,
    required this.createdBy,
    required this.createdByName,
    this.split,
    this.active = true,
    this.lastError,
  });

  final String id;
  final MovementType type;
  final double amount;
  final String title;
  final String category;
  final RecurrenceFrequency frequency;
  final DateTime nextRunAt;
  final String createdBy;
  final String createdByName;
  final Map<String, double>? split;
  final bool active;

  /// Why the last scheduled run did not create a movement (e.g. the caisse
  /// did not hold enough money). Cleared on the next successful run.
  final String? lastError;

  bool get hasSplit => split != null && split!.isNotEmpty;

  factory RecurringMovement.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return RecurringMovement(
      id: doc.id,
      type: MovementTypeX.fromString(data['type'] as String?),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      frequency: RecurrenceFrequencyX.fromString(data['frequency'] as String?),
      nextRunAt: _toDate(data['nextRunAt']) ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String? ?? '',
      split: _toSplit(data['split']),
      active: data['active'] as bool? ?? true,
      lastError: _nonEmpty(data['lastError'] as String?),
    );
  }
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

enum SettlementStatus { pending, confirmed, cancelled }

class Settlement {
  const Settlement({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.toName,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
  });

  final String id;
  final String fromUid;
  final String fromName;
  final String toUid;
  final String toName;
  final double amount;
  final SettlementStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  factory Settlement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Settlement(
      id: doc.id,
      fromUid: data['fromUid'] as String? ?? '',
      fromName: data['fromName'] as String? ?? 'Member',
      toUid: data['toUid'] as String? ?? '',
      toName: data['toName'] as String? ?? 'Member',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      status: switch (data['status']) {
        'confirmed' => SettlementStatus.confirmed,
        'cancelled' => SettlementStatus.cancelled,
        _ => SettlementStatus.pending,
      },
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
      confirmedAt: _toDate(data['confirmedAt']),
    );
  }
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

  /// Money spent per category. Deposits are left out so a category that has
  /// both never nets itself to zero.
  final Map<String, double> byCategory;

  static BalanceSummary fromMovements(List<Movement> movements) {
    var deposits = 0.0;
    var expenses = 0.0;
    final byCategory = <String, double>{};

    for (final m in movements) {
      if (m.deleted) continue;
      if (m.type == MovementType.deposit) {
        deposits += m.amount.abs();
      } else {
        expenses += m.amount.abs();
        byCategory[m.category] = (byCategory[m.category] ?? 0) + m.amount.abs();
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

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
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

Map<String, double>? _toSplit(dynamic value) {
  if (value is! Map) return null;
  final result = <String, double>{};
  for (final entry in value.entries) {
    final key = entry.key;
    final share = entry.value;
    if (key is String && key.isNotEmpty && share is num && share > 0) {
      result[key] = share.toDouble();
    }
  }
  return result.isEmpty ? null : result;
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
