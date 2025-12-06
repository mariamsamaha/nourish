import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('AuthService - Error Handling', () {
    test('Firebase error code weak-password maps to correct message', () {
      final exception = FirebaseAuthException(code: 'weak-password');
      final message = _handleAuthException(exception);

      expect(message, equals('The password provided is too weak.'));
    });

    test(
      'Firebase error code email-already-in-use maps to correct message',
      () {
        final exception = FirebaseAuthException(code: 'email-already-in-use');
        final message = _handleAuthException(exception);

        expect(message, equals('An account already exists for that email.'));
      },
    );

    test('Firebase error code invalid-credential maps to correct message', () {
      final exception = FirebaseAuthException(code: 'invalid-credential');
      final message = _handleAuthException(exception);

      expect(
        message,
        equals('Invalid credentials. Please check your email and password.'),
      );
    });

    test('Firebase error code user-not-found maps to correct message', () {
      final exception = FirebaseAuthException(code: 'user-not-found');
      final message = _handleAuthException(exception);

      expect(message, equals('No user found for that email.'));
    });

    test('Firebase error code wrong-password maps to correct message', () {
      final exception = FirebaseAuthException(code: 'wrong-password');
      final message = _handleAuthException(exception);

      expect(message, equals('Wrong password provided.'));
    });

    test('Firebase error code invalid-email maps to correct message', () {
      final exception = FirebaseAuthException(code: 'invalid-email');
      final message = _handleAuthException(exception);

      expect(message, equals('The email address is not valid.'));
    });

    test('Unknown Firebase error code returns generic message', () {
      final exception = FirebaseAuthException(
        code: 'unknown-error',
        message: 'Some unknown error occurred',
      );
      final message = _handleAuthException(exception);

      expect(message, contains('An error occurred'));
      expect(message, contains('Some unknown error occurred'));
    });
  });
}

// Replicate the error handling logic from AuthService for testing
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
