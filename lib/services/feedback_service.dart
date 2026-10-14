import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class SupportInquiryModel {
  final String id;
  final String node; // 'feedback' or 'support_tickets'
  final String userId;
  final String userName;
  final String userEmail;
  final String category;
  final String message;
  final double? rating;
  final String status; // 'new', 'in_progress', 'resolved'
  final String timestamp;
  final String adminReply;
  final String internalNotes;

  SupportInquiryModel({
    required this.id,
    required this.node,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.category,
    required this.message,
    this.rating,
    required this.status,
    required this.timestamp,
    this.adminReply = '',
    this.internalNotes = '',
  });

  factory SupportInquiryModel.fromMap(String id, String node, Map<String, dynamic> map) {
    String rawStatus = (map['status'] ?? 'new').toString().toLowerCase();
    if (rawStatus == 'open' || rawStatus == 'unassigned') {
      rawStatus = 'new';
    }

    return SupportInquiryModel(
      id: id,
      node: node,
      userId: (map['userId'] ?? 'guest').toString(),
      userName: (map['name'] ?? map['userName'] ?? map['email'] ?? 'User').toString(),
      userEmail: (map['email'] ?? map['userEmail'] ?? '').toString(),
      category: (map['category'] ?? 'General').toString(),
      message: (map['message'] ?? map['description'] ?? '').toString(),
      rating: double.tryParse('${map['rating']}'),
      status: rawStatus,
      timestamp: (map['timestamp'] ?? map['createdAt'] ?? '').toString(),
      adminReply: (map['adminReply'] ?? '').toString(),
      internalNotes: (map['internalNotes'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'email': userEmail,
      'category': category,
      'message': message,
      if (rating != null) 'rating': rating,
      'status': status,
      'timestamp': timestamp,
      'createdAt': timestamp,
      'adminReply': adminReply,
      'internalNotes': internalNotes,
    };
  }
}

class FeedbackService {
  FeedbackService._();

  static final FeedbackService instance = FeedbackService._();

  /// Saves a feedback submission to Firebase Realtime Database under path `feedback/{submissionId}`
  Future<bool> submitFeedback({
    required String category,
    required String message,
    double rating = 5.0,
    String? email,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    final userEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim()
        : (user?.email ?? 'anonymous');

    try {
      final ref = FirebaseDatabase.instance.ref('feedback').push();
      final submissionId = ref.key;
      final now = DateTime.now().toIso8601String();

      await ref.set({
        'submissionId': submissionId,
        'userId': userId,
        'email': userEmail,
        'category': category,
        'message': message.trim(),
        'rating': rating,
        'status': 'new',
        'timestamp': now,
        'createdAt': now,
      });
      return true;
    } catch (e) {
      debugPrint('FEEDBACK SUBMISSION ERROR: $e');
      return false;
    }
  }

  /// Saves a support request/issue report under path `support_tickets/{ticketId}`
  Future<bool> submitSupportTicket({
    required String name,
    required String email,
    required String category,
    required String message,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';

    try {
      final ref = FirebaseDatabase.instance.ref('support_tickets').push();
      final now = DateTime.now().toIso8601String();

      await ref.set({
        'ticketId': ref.key,
        'userId': userId,
        'name': name.trim(),
        'email': email.trim(),
        'category': category,
        'message': message.trim(),
        'status': 'new',
        'timestamp': now,
        'createdAt': now,
      });
      return true;
    } catch (e) {
      debugPrint('SUPPORT TICKET SUBMISSION ERROR: $e');
      return false;
    }
  }

  /// Streams combined live support inquiries from both `feedback` and `support_tickets`
  Stream<List<SupportInquiryModel>> watchAllInquiries() {
    final feedbackStream = FirebaseDatabase.instance.ref('feedback').onValue;



    return feedbackStream.asyncMap((fbEvent) async {
      final list = <SupportInquiryModel>[];

      // 1. Parse feedback items
      final fbVal = fbEvent.snapshot.value;
      if (fbVal is Map) {
        fbVal.forEach((key, value) {
          if (value is Map) {
            final map = Map<String, dynamic>.from(value);
            list.add(SupportInquiryModel.fromMap(key.toString(), 'feedback', map));
          }
        });
      }

      // 2. Fetch support tickets
      try {
        final ticketSnap = await FirebaseDatabase.instance.ref('support_tickets').get();
        final tVal = ticketSnap.value;
        if (tVal is Map) {
          tVal.forEach((key, value) {
            if (value is Map) {
              final map = Map<String, dynamic>.from(value);
              list.add(SupportInquiryModel.fromMap(key.toString(), 'support_tickets', map));
            }
          });
        }
      } catch (e) {
        debugPrint('TICKETS FETCH ERROR: $e');
      }

      // Sort by timestamp descending
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  /// Resolution workflow: Updates inquiry status, admin reply, internal staff notes in Realtime Database,
  /// and sends an in-app targeted notification to the user.
  Future<bool> updateInquiryResolution({
    required String node,
    required String id,
    required String userId,
    required String userEmail,
    required String status,
    required String adminReply,
    required String internalNotes,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final ref = FirebaseDatabase.instance.ref('$node/$id');

      await ref.update({
        'status': status,
        'adminReply': adminReply.trim(),
        'internalNotes': internalNotes.trim(),
        'updatedAt': now,
        'resolvedAt': status == 'resolved' ? now : null,
      });

      // Send targeted notification to user if userId is provided
      if (userId.isNotEmpty && userId != 'guest') {
        await NotificationService.instance.createNotification(
          title: status == 'resolved'
              ? 'Support Ticket Resolved'
              : 'Support Ticket Update: ${status.replaceAll('_', ' ').toUpperCase()}',
          body: adminReply.trim().isNotEmpty
              ? adminReply.trim()
              : 'Your support ticket status has been updated to ${status.replaceAll('_', ' ')}.',
          targetType: 'specific',
          targetUserId: userId,
        );
      }

      return true;
    } catch (e) {
      debugPrint('UPDATE INQUIRY RESOLUTION ERROR: $e');
      return false;
    }
  }
}
