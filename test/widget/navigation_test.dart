import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proj/main.dart';
import 'package:proj/services/auth_service.dart';
import 'package:proj/services/database_service.dart';
import 'package:proj/services/firestore_service.dart';
import 'package:proj/routes/app_routes.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('navigates from welcome to sign in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<FirestoreService>(create: (_) => FirestoreService()),
            Provider<AuthService>(create: (_) => AuthService()),
            Provider<DatabaseService>(create: (_) => DatabaseService()),
          ],
          child: MaterialApp(
            initialRoute: AppRoutes.welcome,
            routes: AppRoutes.routes,
          ),
        ),
      );

      // Wait for initial route
      await tester.pumpAndSettle();

      // Find and tap "I have an account" or similar button
      final signInButton = find.text('I have an account');
      expect(signInButton, findsOneWidget);

      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Verify we're on sign in screen
      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('navigates from welcome to sign up', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<FirestoreService>(create: (_) => FirestoreService()),
            Provider<AuthService>(create: (_) => AuthService()),
            Provider<DatabaseService>(create: (_) => DatabaseService()),
          ],
          child: MaterialApp(
            initialRoute: AppRoutes.welcome,
            routes: AppRoutes.routes,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap "Get Started" or similar button
      final signUpButton = find.text('Get Started');
      expect(signUpButton, findsOneWidget);

      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify we're on sign up screen
      expect(find.text('Create Account'), findsWidgets);
    });
  });
}
