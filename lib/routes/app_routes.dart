import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/create_account_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String signup = '/signup';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
    signup: (context) => const CreateAccountScreen(),
  };
}
