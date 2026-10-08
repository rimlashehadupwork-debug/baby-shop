import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Registers a new user with [FirebaseAuth] and saves their profile in Firestore with a default role of 'user'.
  Future<UserCredential?> registerUser({
    required String email,
    required String password,
    String name = '',
    String role = 'user',
  }) async {
    final UserCredential credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? user = credential.user;
    if (user != null) {
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email.trim(),
        role: role,
        deliveryAddresses: const [],
        paymentMethods: const [],
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());
    }

    return credential;
  }

  /// Authenticates the user with [FirebaseAuth], checks their document in the 'users' collection in Firestore,
  /// and returns their role string ('admin' or 'user').
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? user = credential.user;
    if (user == null) return null;

    final DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      final role = data['role'] as String? ?? 'user';
      return role;
    }

    return 'user';
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
