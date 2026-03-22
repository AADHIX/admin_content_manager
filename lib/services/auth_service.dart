// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────────────────────
  // ADMIN CONFIGURATION
  // Replace these UIDs with the actual Firebase UIDs of your admin users.
  // You can find a user's UID in Firebase Console → Authentication → Users.
  // ─────────────────────────────────────────────────────────────
  static const List<String> _adminUIDs = [
    'XUNrXGBTcndZf0SpGGD5N1FccYj2',
    // Add more admin UIDs here as needed
  ];

  // ─────────────────────────────────────────────────────────────
  // Auth State Stream
  // ─────────────────────────────────────────────────────────────

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get the currently signed-in user
  User? get currentUser => _auth.currentUser;

  // ─────────────────────────────────────────────────────────────
  // Role Checking
  // ─────────────────────────────────────────────────────────────

  /// Returns true if the given UID belongs to an admin user
  bool isAdmin(String uid) {
    return _adminUIDs.contains(uid);
  }

  /// Returns true if the currently signed-in user is an admin
  bool get isCurrentUserAdmin {
    final user = currentUser;
    if (user == null) return false;
    return isAdmin(user.uid);
  }

  // ─────────────────────────────────────────────────────────────
  // Authentication Methods
  // ─────────────────────────────────────────────────────────────

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create a new account with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────────────────────
  // Error Handling Helper
  // ─────────────────────────────────────────────────────────────

  /// Convert Firebase auth error codes to human-readable messages
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters long.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
