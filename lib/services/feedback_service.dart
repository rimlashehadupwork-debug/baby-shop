import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

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
        'status': 'open',
        'timestamp': now,
        'createdAt': now,
      });
      return true;
    } catch (e) {
      debugPrint('SUPPORT TICKET SUBMISSION ERROR: $e');
      return false;
    }
  }
}
