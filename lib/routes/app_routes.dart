import 'package:flutter/material.dart';
import 'package:proj/screens/settings_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/create_account_screen.dart';
import '../screens/food_details_screen.dart';
import '../screens/cart_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String signup = '/signup';
  static const String settings = '/settings';
  static const String foodDetails = '/food-details';
  static const String cart = '/cart';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
    signup: (context) => const CreateAccountScreen(),
    settings: (context) => const SettingsScreen(),
    foodDetails: (context) => const FoodDetailsScreen(),
    cart: (context) => const CartScreen(),
  };
}
