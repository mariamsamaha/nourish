import 'package:flutter/material.dart';
import 'package:proj/screens/welcome_screen.dart';
import 'package:proj/screens/create_account_screen.dart';
import 'package:proj/screens/signin_screen.dart';
import 'package:proj/screens/settings_screen.dart';
import 'package:proj/screens/food_details_screen.dart';
import 'package:proj/screens/cart_screen.dart';
import 'package:proj/screens/home_screen.dart';
import 'package:proj/screens/browse_restaurants_screen.dart';
import 'package:proj/screens/restaurant_detail_screen.dart';
import 'package:proj/screens/charity_screen.dart';
import 'package:proj/screens/profile_screen.dart';
import 'package:proj/screens/welcome_screen.dart';
import 'package:proj/screens/subscription_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String settings = '/settings';
  static const String foodDetails = '/food_details';
  static const String cart = '/cart';
  static const String home = '/home';
  static const String browseRestaurants = '/browse_restaurants';
  static const String restaurantDetail = '/restaurant_detail';
  static const String charity = '/charity';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
    signup: (context) => const CreateAccountScreen(),
    signin: (context) => const SignInScreen(),
    settings: (context) => const SettingsScreen(),
    foodDetails: (context) => const FoodDetailsScreen(),
    cart: (context) => const CartScreen(),
    home: (context) => const HomeScreen(),
    browseRestaurants: (context) => const BrowseRestaurantsScreen(),
    restaurantDetail: (context) => const RestaurantDetailScreen(),
    charity: (context) => const CharityScreen(),
    profile: (context) => const ProfileScreen(),
    subscription: (context) => const SubscriptionScreen(),
  };
}
