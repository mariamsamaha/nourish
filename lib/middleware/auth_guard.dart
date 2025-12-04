import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj/services/auth_service.dart';
import 'package:proj/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Authentication guard that protects routes requiring user authentication.
/// Redirects to welcome screen if user is not logged in.
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user is authenticated
        final user = snapshot.data;

        if (user == null) {
          // Not authenticated - redirect to welcome screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
            } else {
              Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
            }
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Authenticated - show the protected screen
        return child;
      },
    );
  }
}
