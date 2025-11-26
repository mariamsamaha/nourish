import 'package:flutter/material.dart';
import 'package:proj/screens/welcome_screen.dart';
import 'package:proj/screens/create_account_screen.dart';
import 'package:proj/screens/signin_screen.dart';
import 'package:proj/screens/settings_screen.dart';
import 'package:proj/screens/food_details_screen.dart';
import 'package:proj/screens/cart_screen.dart';
import 'package:proj/screens/impact_screen.dart';
import 'package:proj/screens/home_screen.dart';
import 'package:proj/screens/browse_restaurants_screen.dart';
import 'package:proj/screens/restaurant_detail_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String settings = '/settings';
  static const String foodDetails = '/food_details';
  static const String cart = '/cart';
  static const String impact = '/impact';
  static const String home = '/home';
  static const String browseRestaurants = '/browse_restaurants';
  static const String restaurantDetail = '/restaurant_detail';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
    signup: (context) => const CreateAccountScreen(),
    signin: (context) => const SignInScreen(),
    settings: (context) => const SettingsScreen(),
    foodDetails: (context) => const FoodDetailsScreen(),
    cart: (context) => const CartScreen(),
    impact: (context) => const ImpactScreen(),
    home: (context) => const HomeScreen(),
    browseRestaurants: (context) => const BrowseRestaurantsScreen(),
    restaurantDetail: (context) => const RestaurantDetailScreen(),
  };
}
