import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String targetType;
  final String targetUserId;
  final String timestamp;
  final Map<String, bool> readBy;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.targetType,
    required this.targetUserId,
    required this.timestamp,
    this.readBy = const {},
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    final readMap = <String, bool>{};
    if (map['readBy'] is Map) {
      (map['readBy'] as Map).forEach((k, v) {
        if (v == true) {
          readMap[k.toString()] = true;
        }
      });
    }

    return NotificationModel(
      id: id,
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      targetType: (map['targetType'] ?? 'all').toString(),
      targetUserId: (map['targetUserId'] ?? '').toString(),
      timestamp: (map['timestamp'] ?? map['createdAt'] ?? '').toString(),
      readBy: readMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'targetType': targetType,
      'targetUserId': targetUserId,
      'timestamp': timestamp,
      'createdAt': timestamp,
      'readBy': readBy,
    };
  }

  bool isReadBy(String uid) {
    if (uid.isEmpty) return false;
    return readBy[uid] == true;
  }
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String table = 'notifications';

  /// Watch all notifications for Admin
  Stream<List<NotificationModel>> watchAllNotifications() {
    return FirebaseDatabase.instance
        .ref(table)
        .onValue
        .map((event) {
          final list = <NotificationModel>[];
          final val = event.snapshot.value;
          if (val is Map) {
            val.forEach((key, value) {
              if (value is Map) {
                final map = Map<String, dynamic>.from(value);
                list.add(NotificationModel.fromMap(key.toString(), map));
              }
            });
          }
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  /// Watch filtered notifications for current User
  Stream<List<NotificationModel>> watchUserNotifications() {
    return watchAllNotifications().map((allNotifications) {
      final user = FirebaseAuth.instance.currentUser;
      final currentUid = user?.uid ?? '';

      return allNotifications.where((n) {
        if (n.targetType == 'all') {
          return true;
        }
        if (n.targetType == 'specific' && n.targetUserId.trim() == currentUid.trim()) {
          return true;
        }
        return false;
      }).toList();
    });
  }

  /// Create notification (Admin)
  Future<bool> createNotification({
    required String title,
    required String body,
    required String targetType, // 'all' or 'specific'
    String targetUserId = '',
  }) async {
    try {
      final ref = FirebaseDatabase.instance.ref(table).push();
      final now = DateTime.now().toIso8601String();
      final notification = NotificationModel(
        id: ref.key!,
        title: title.trim(),
        body: body.trim(),
        targetType: targetType,
        targetUserId: targetUserId.trim(),
        timestamp: now,
      );
      await ref.set(notification.toMap());
      return true;
    } catch (e) {
      debugPrint('CREATE NOTIFICATION ERROR: $e');
      return false;
    }
  }

  /// Update/Edit notification (Admin)
  Future<bool> updateNotification({
    required String id,
    required String title,
    required String body,
    required String targetType,
    String targetUserId = '',
  }) async {
    try {
      final ref = FirebaseDatabase.instance.ref('$table/$id');
      await ref.update({
        'title': title.trim(),
        'body': body.trim(),
        'targetType': targetType,
        'targetUserId': targetUserId.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('UPDATE NOTIFICATION ERROR: $e');
      return false;
    }
  }

  /// Delete notification (Admin)
  Future<bool> deleteNotification(String id) async {
    try {
      await FirebaseDatabase.instance.ref('$table/$id').remove();
      return true;
    } catch (e) {
      debugPrint('DELETE NOTIFICATION ERROR: $e');
      return false;
    }
  }

  /// Mark notification as read for current user
  Future<void> markAsRead(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseDatabase.instance
          .ref('$table/$notificationId/readBy/${user.uid}')
          .set(true);
    } catch (e) {
      debugPrint('MARK AS READ ERROR: $e');
    }
  }
}
