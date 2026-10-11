// firebase_supabase_service.dart
//
// Generic CRUD service for Firebase Realtime Database + file upload
// via Supabase Storage (link gets saved into the DB).
// Works on Web + Android + iOS (bytes based, no dart:io).
//
// pubspec deps:
//   firebase_core, firebase_database: ^11.0.0
//   supabase_flutter: ^2.0.0
//   uuid: ^4.0.0
//   image_picker: ^1.1.2   (sirf image chunne ke liye)

import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class FirebaseSupabaseService {
  // Singleton: har screen par FirebaseSupabaseService() same object deta hai
  FirebaseSupabaseService._();
  static final FirebaseSupabaseService _instance = FirebaseSupabaseService._();
  factory FirebaseSupabaseService() => _instance;

  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final SupabaseClient _supabase = Supabase.instance.client;

  // ---------------- FILE UPLOAD (Supabase Storage) ----------------

  /// Uploads [bytes] to Supabase Storage bucket [bucketName].
  /// [extension] example: '.jpg'. Returns the public URL.
  Future<String> uploadFile({
    required Uint8List bytes,
    required String bucketName,
    String extension = '',
    String? contentType,
    String? fileName,
  }) async {
    try {
      final name = fileName ?? const Uuid().v4();
      final path = '$name$extension';

      await _supabase.storage.from(bucketName).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: false,
          contentType: contentType,
        ),
      );

      return _supabase.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  /// Uploads [bytes] to Supabase, merges the resulting link into [data]
  /// under [linkKey], then creates a new record in [tableName].
  /// Returns the new Firebase key.
  Future<String> uploadFileAndSave({
    required Uint8List bytes,
    required String bucketName,
    required String tableName,
    required Map<String, dynamic> data,
    String extension = '',
    String? contentType,
    String linkKey = 'fileUrl',
  }) async {
    final url = await uploadFile(
      bytes: bytes,
      bucketName: bucketName,
      extension: extension,
      contentType: contentType,
    );
    final payload = {...data, linkKey: url};
    return create(tableName: tableName, data: payload);
  }

  // ---------------- CREATE ----------------

  /// Creates a new record under [tableName]. Returns the generated key.
  Future<String> create({
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final newRef = _db.child(tableName).push();
      await newRef.set(data);
      return newRef.key!;
    } catch (e) {
      throw Exception('Create failed: $e');
    }
  }

  // ---------------- READ ----------------

  /// Table name only -> all records. Table name + id -> single record.
  Future<dynamic> read({
    required String tableName,
    String? id,
  }) async {
    try {
      final ref =
      id == null ? _db.child(tableName) : _db.child(tableName).child(id);
      final snapshot = await ref.get();
      if (!snapshot.exists) return null;
      return snapshot.value;
    } catch (e) {
      throw Exception('Read failed: $e');
    }
  }

  // ---------------- UPDATE ----------------

  /// Updates the record [id] under [tableName] with [data].
  Future<void> update({
    required String tableName,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.child(tableName).child(id).update(data);
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  // ---------------- DELETE ----------------

  /// Deletes a single record by [id] under [tableName].
  Future<void> deleteById({
    required String tableName,
    required String id,
  }) async {
    try {
      await _db.child(tableName).child(id).remove();
    } catch (e) {
      throw Exception('Delete by id failed: $e');
    }
  }

  /// Deletes ALL records under [tableName].
  Future<void> deleteAll({
    required String tableName,
  }) async {
    try {
      await _db.child(tableName).remove();
    } catch (e) {
      throw Exception('Delete all failed: $e');
    }
  }
}