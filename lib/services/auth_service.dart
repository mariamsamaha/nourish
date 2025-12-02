import 'package:firebase_auth/firebase_auth.dart';
import 'auth_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthStorageService _storage = AuthStorageService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get stored user ID from shared preferences
  Future<String?> getStoredUserId() async {
    return await _storage.getUserId();
  }
  
  // Get stored user email from shared preferences
  Future<String?> getStoredUserEmail() async {
    return await _storage.getUserEmail();
  }
  
  // Check if user has a valid session stored
  Future<bool> hasStoredSession() async {
    return await _storage.isUserLoggedIn();
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save user data to shared preferences
      if (credential.user != null) {
        await _storage.saveUserData(
          userId: credential.user!.uid,
          email: credential.user!.email ?? email,
        );
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save user data to shared preferences
      if (credential.user != null) {
        await _storage.saveUserData(
          userId: credential.user!.uid,
          email: credential.user!.email ?? email,
        );
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // Clear stored user data from shared preferences
    await _storage.clearUserData();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
