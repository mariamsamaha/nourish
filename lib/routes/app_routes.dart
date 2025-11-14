import 'package:flutter/material.dart';
import 'package:proj/screens/settings_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/create_account_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String signup = '/signup';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
    signup: (context) => const CreateAccountScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
