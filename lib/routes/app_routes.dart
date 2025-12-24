import 'package:flutter/material.dart';
import 'package:proj/screens/welcome_screen.dart';
import 'package:proj/screens/create_account_screen.dart';
import 'package:proj/screens/signin_screen.dart';
import 'package:proj/screens/food_details_screen.dart';
import 'package:proj/screens/cart_screen.dart';
import 'package:proj/screens/home_screen.dart';
import 'package:proj/screens/browse_restaurants_screen.dart';
import 'package:proj/screens/restaurant_detail_screen.dart';
import 'package:proj/screens/charity_screen.dart';
import 'package:proj/screens/profile_screen.dart';
import 'package:proj/screens/welcome_screen.dart';
import 'package:proj/screens/subscription_screen.dart';
import 'package:proj/screens/camera_screen.dart';
import 'package:proj/screens/food_detection_results_screen.dart';
import 'package:proj/middleware/auth_guard.dart';
import 'package:proj/screens/paymob_success_screen.dart';
import 'package:proj/screens/chat_support_screen.dart';
import 'package:proj/screens/splash_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String foodDetails = '/food_details';
  static const String cart = '/cart';
  static const String home = '/home';
  static const String browseRestaurants = '/browse_restaurants';
  static const String restaurantDetail = '/restaurant_detail';
  static const String charity = '/charity';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static const String camera = '/camera';
  static const String foodDetectionResults = '/food_detection_results';
  static const String paymobSuccess = '/paymob-success';
  static const String chatSupport = '/chat-support';
  static const String splash = '/splash';

  static Map<String, WidgetBuilder> routes = {
    // Public routes (no auth required)
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),
    signup: (context) => const CreateAccountScreen(),
    signin: (context) => const SignInScreen(),

    // Protected routes (auth required)
    foodDetails: (context) => const AuthGuard(child: FoodDetailsScreen()),
    cart: (context) => const AuthGuard(child: CartScreen()),
    home: (context) => const AuthGuard(child: HomeScreen()),
    browseRestaurants: (context) =>
        const AuthGuard(child: BrowseRestaurantsScreen()),
    restaurantDetail: (context) =>
        const AuthGuard(child: RestaurantDetailScreen()),
    charity: (context) => const AuthGuard(child: CharityScreen()),
    profile: (context) => const AuthGuard(child: ProfileScreen()),
    subscription: (context) => const AuthGuard(child: SubscriptionScreen()),
    paymobSuccess: (context) => const PaymobSuccessScreen(),
    chatSupport: (context) => const AuthGuard(child: ChatSupportScreen()),
  };
}
