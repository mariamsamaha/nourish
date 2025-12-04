import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj/screens/signin_screen.dart';

void main() {
  group('SignIn Screen Tests', () {
    testWidgets('shows error when email is invalid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

      // Find email and password fields
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.enterText(passwordField, 'password123');

      // Find and tap sign in button
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Expect error message (this assumes validation shows an error)
      // Adjust based on actual implementation
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Expect password error
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('accepts valid credentials', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');

      // Should not show validation errors
      await tester.tap(signInButton);
      await tester.pump();

      // Note: This test may need mocking of AuthService to fully validate
      // For now, we're just checking that validation passes
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Password is required'), findsNothing);
    });
  });
}
