import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserDbService {
  UserDbService._();

  static final UserDbService instance = UserDbService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed mock prototype accounts into Firestore and Realtime Database if they don't exist
  Future<void> seedPrototypeAccounts() async {
    final mockUsers = [
      UserModel(
        uid: 'user_john_doe',
        name: 'John Doe',
        email: 'john.doe@example.com',
        role: 'user',
        accountStatus: 'active',
        isCustomVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        activityLog: [
          {'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(), 'action': 'Placed order #ORD-1092'},
          {'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(), 'action': 'Browsed Baby Care Products'},
        ],
      ),
      UserModel(
        uid: 'user_jane_smith',
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        role: 'user',
        accountStatus: 'active',
        isCustomVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        activityLog: [
          {'timestamp': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(), 'action': 'Registered Account'},
        ],
      ),
      UserModel(
        uid: 'user_bad_actor',
        name: 'Bad Actor',
        email: 'bad.actor@example.com',
        role: 'user',
        accountStatus: 'suspended',
        isCustomVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        activityLog: [
          {'timestamp': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(), 'action': 'Violated Terms of Service'},
          {'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(), 'action': 'Suspended by Admin'},
        ],
      ),
    ];

    for (final user in mockUsers) {
      try {
        final docRef = _firestore.collection('users').doc(user.uid);
        final snap = await docRef.get();
        if (!snap.exists) {
          await docRef.set(user.toMap());
        }

        // Also sync to Realtime Database
        final rtdbRef = FirebaseDatabase.instance.ref('users/${user.uid}');
        final rtdbSnap = await rtdbRef.get();
        if (!rtdbSnap.exists) {
          await rtdbRef.set(user.toMap());
        }
      } catch (e) {
        debugPrint('SEED MOCK ACCOUNT ERROR for ${user.email}: $e');
      }
    }
  }

  /// Ensures user document exists in Firestore and Realtime Database under `users/{uid}`
  /// and syncing `email` and `name` fields.
  Future<void> ensureUserDocument(User user, {String name = ''}) async {
    final uid = user.uid;
    final email = (user.email ?? '').toLowerCase();

    try {
      final bool isAdminEmail = email == 'admin@gmail.com';
      final docRef = _firestore.collection('users').doc(uid);
      final docSnap = await docRef.get();

      final userName = name.trim().isNotEmpty
          ? name.trim()
          : (user.displayName ?? (email.isNotEmpty ? email.split('@').first : 'User'));

      if (!docSnap.exists) {
        final newUser = UserModel(
          uid: uid,
          name: userName,
          email: email,
          role: isAdminEmail ? 'admin' : 'user',
          accountStatus: 'active',
          isCustomVerified: isAdminEmail || user.emailVerified,
          createdAt: DateTime.now().toIso8601String(),
          activityLog: [
            {'timestamp': DateTime.now().toIso8601String(), 'action': 'Account Created'},
          ],
        );

        await docRef.set(newUser.toMap());
        await FirebaseDatabase.instance.ref('users/$uid').set(newUser.toMap());
      } else {
        final data = docSnap.data();
        final Map<String, dynamic> updates = {};

        if (email.isNotEmpty && (data == null || (data['email'] ?? '').toString().isEmpty)) {
          updates['email'] = email;
        }
        if (userName.isNotEmpty && (data == null || (data['name'] ?? '').toString().isEmpty)) {
          updates['name'] = userName;
        }
        if (isAdminEmail || user.emailVerified) {
          updates['isCustomVerified'] = true;
        }

        if (updates.isNotEmpty) {
          await docRef.set(updates, SetOptions(merge: true));
          await FirebaseDatabase.instance.ref('users/$uid').update(updates);
        }
      }
    } catch (e) {
      debugPrint('USER DB SERVICE ENSURE ERROR: $e');
    }
  }

  /// Sets `accountStatus` ('active' | 'suspended') for specified user UID in both Firestore & Realtime Database
  Future<void> setUserAccountStatus(String uid, String status) async {
    final cleanStatus = status.toLowerCase() == 'suspended' ? 'suspended' : 'active';
    final actionText = cleanStatus == 'suspended' ? 'Account Suspended by Admin' : 'Account Unsuspended by Admin';

    try {
      final now = DateTime.now().toIso8601String();

      // 1. Update Firestore
      final docRef = _firestore.collection('users').doc(uid);
      await docRef.set({
        'accountStatus': cleanStatus,
        'updatedAt': now,
        'activityLog': FieldValue.arrayUnion([
          {'timestamp': now, 'action': actionText}
        ]),
      }, SetOptions(merge: true));

      // 2. Update Realtime Database
      final rtdbRef = FirebaseDatabase.instance.ref('users/$uid');
      await rtdbRef.update({
        'accountStatus': cleanStatus,
        'updatedAt': now,
      });
    } catch (e) {
      debugPrint('SET ACCOUNT STATUS ERROR: $e');
      rethrow;
    }
  }

  /// Sets `isCustomVerified: true` for specified user UID
  Future<void> markUserCustomVerified(String uid) async {
    try {
      final now = DateTime.now().toIso8601String();
      await _firestore.collection('users').doc(uid).set({
        'isCustomVerified': true,
        'verifiedAt': now,
      }, SetOptions(merge: true));

      await FirebaseDatabase.instance.ref('users/$uid').update({
        'isCustomVerified': true,
        'verifiedAt': now,
      });
    } catch (e) {
      debugPrint('MARK CUSTOM VERIFIED ERROR: $e');
      rethrow;
    }
  }

  /// Deletes a user account record from both Cloud Firestore and Realtime Database
  Future<void> deleteUserAccount(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      await FirebaseDatabase.instance.ref('users/$uid').remove();
    } catch (e) {
      debugPrint('DELETE USER ACCOUNT ERROR: $e');
      rethrow;
    }
  }

  /// Stream of all users merged from both Firebase Realtime Database and Cloud Firestore
  Stream<List<UserModel>> watchAllUsers() {
    final rtdbStream = FirebaseDatabase.instance.ref('users').onValue;

    return rtdbStream.asyncMap((rtdbEvent) async {
      final userMap = <String, UserModel>{};

      // 1. Parse Realtime Database users
      final rtdbValue = rtdbEvent.snapshot.value;
      if (rtdbValue is Map) {
        rtdbValue.forEach((key, value) {
          if (value is Map) {
            final m = Map<String, dynamic>.from(value);
            final user = UserModel.fromMap(m, uid: key.toString());
            if (user.uid.isNotEmpty) {
              userMap[user.uid] = user;
            }
          }
        });
      }

      // 2. Fetch and merge Cloud Firestore users
      try {
        final firestoreSnap = await _firestore.collection('users').get();
        for (final doc in firestoreSnap.docs) {
          final data = doc.data();
          final user = UserModel.fromMap(data, uid: doc.id);
          if (user.uid.isNotEmpty) {
            if (!userMap.containsKey(user.uid)) {
              userMap[user.uid] = user;
            } else {
              final existing = userMap[user.uid]!;
              userMap[user.uid] = existing.copyWith(
                email: existing.email.isNotEmpty ? existing.email : user.email,
                name: existing.name.isNotEmpty ? existing.name : user.name,
                accountStatus: user.accountStatus.isNotEmpty ? user.accountStatus : existing.accountStatus,
                isCustomVerified: existing.isCustomVerified || user.isCustomVerified,
                activityLog: existing.activityLog.isNotEmpty ? existing.activityLog : user.activityLog,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('FIRESTORE FETCH USERS ERROR: $e');
      }

      final list = userMap.values.toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
