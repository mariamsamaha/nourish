import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proj/services/database_service.dart';
import 'package:proj/services/firestore_service.dart';

/// Service to fetch all data needed for AI chat support.
/// Provides methods to retrieve restaurants, meals, charities, user cart,
/// user favorites, and user preferences for comprehensive AI context.
class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();
  final FirestoreService _firestoreService = FirestoreService();

  // ========== RESTAURANT METHODS ==========

  /// Get all restaurants from Firestore
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    try {
      final snap = await _db.collection('restaurants').get();
      return snap.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  /// Get a specific restaurant by ID
  Future<Map<String, dynamic>?> getRestaurant(String restaurantId) async {
    try {
      final doc = await _db.collection('restaurants').doc(restaurantId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('Error fetching restaurant: $e');
      return null;
    }
  }

  // ========== MEAL/FOOD ITEM METHODS ==========

  /// Get all meals (food items) from Firestore
  Future<List<Map<String, dynamic>>> getMeals() async {
    try {
      final snap = await _db.collection('food_items').get();
      return snap.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      print('Error fetching meals: $e');
      return [];
    }
  }

  /// Get all meals for a specific restaurant
  Future<List<Map<String, dynamic>>> getMealsByRestaurant(
    String restaurantId,
  ) async {
    try {
      final snap = await _db
          .collection('food_items')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      return snap.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      print('Error fetching meals by restaurant: $e');
      return [];
    }
  }

  /// Get available meals (quantity > 0)
  Future<List<Map<String, dynamic>>> getAvailableMeals() async {
    try {
      final snap = await _db
          .collection('food_items')
          .where('quantity', isGreaterThan: 0)
          .get();
      return snap.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      print('Error fetching available meals: $e');
      return [];
    }
  }

  // ========== CHARITY METHODS ==========

  /// Get all charities from Firestore
  Future<List<Map<String, dynamic>>> getCharities() async {
    try {
      final snap = await _db.collection('charities').get();
      return snap.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      print('Error fetching charities: $e');
      return [];
    }
  }

  // ========== USER-SPECIFIC METHODS ==========

  /// Get user's cart items (works on both web and mobile)
  Future<List<Map<String, dynamic>>> getUserCart(String userId) async {
    try {
      return await _databaseService.getCartItems(userId);
    } catch (e) {
      print('Error fetching user cart: $e');
      return [];
    }
  }

  /// Get user's cart total price
  Future<double> getUserCartTotal(String userId) async {
    try {
      return await _databaseService.getCartTotal(userId);
    } catch (e) {
      print('Error fetching user cart total: $e');
      return 0.0;
    }
  }

  /// Get user's supported charities (works on both web and mobile)
  Future<List<String>> getUserSupportedCharities(String userId) async {
    try {
      return await _databaseService.getSupportedCharities(userId);
    } catch (e) {
      print('Error fetching user supported charities: $e');
      return [];
    }
  }

  /// Get detailed info about user's supported charities
  Future<List<Map<String, dynamic>>> getUserSupportedCharitiesDetails(
    String userId,
  ) async {
    try {
      final charityIds = await getUserSupportedCharities(userId);
      if (charityIds.isEmpty) return [];

      final allCharities = await getCharities();
      return allCharities
          .where((charity) => charityIds.contains(charity['id']))
          .toList();
    } catch (e) {
      print('Error fetching user supported charities details: $e');
      return [];
    }
  }

  /// Get user's favorite restaurants (works on both web and mobile)
  Future<List<Map<String, dynamic>>> getUserFavoriteRestaurants(
    String userId,
  ) async {
    try {
      return await _databaseService.getFavoriteRestaurants(userId);
    } catch (e) {
      print('Error fetching user favorite restaurants: $e');
      return [];
    }
  }

  /// Get user's favorite meals
  Future<List<Map<String, dynamic>>> getUserFavoriteMeals(String userId) async {
    try {
      final snap = await _db
          .collection('userFavorites')
          .doc(userId)
          .collection('meals')
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching user favorite meals: $e');
      return [];
    }
  }

  /// Get user profile data from Firestore (if exists)
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Get user's order history (if exists in Firestore)
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final snap = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  /// Get user's payment history (if exists in Firestore)
  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    try {
      final snap = await _db
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      print('Error fetching user payments: $e');
      return [];
    }
  }

  // ========== COMPREHENSIVE USER CONTEXT METHOD ==========

  /// Get all user-related data in one go for AI context
  /// This method fetches everything the AI might need to know about the user
  Future<Map<String, dynamic>> getUserContext(String userId) async {
    try {
      final results = await Future.wait([
        getUserProfile(userId),
        getUserCart(userId),
        getUserCartTotal(userId),
        getUserSupportedCharitiesDetails(userId),
        getUserFavoriteRestaurants(userId),
        getUserFavoriteMeals(userId),
        getUserOrders(userId),
        getUserPayments(userId),
      ]);

      return {
        'profile': results[0],
        'cart': results[1],
        'cartTotal': results[2],
        'supportedCharities': results[3],
        'favoriteRestaurants': results[4],
        'favoriteMeals': results[5],
        'orders': results[6],
        'payments': results[7],
      };
    } catch (e) {
      print('Error fetching user context: $e');
      return {
        'profile': null,
        'cart': [],
        'cartTotal': 0.0,
        'supportedCharities': [],
        'favoriteRestaurants': [],
        'favoriteMeals': [],
        'orders': [],
        'payments': [],
      };
    }
  }

  /// Get complete app context (restaurants, meals, charities, and user data)
  /// This is the ultimate method for AI chat support
  Future<Map<String, dynamic>> getCompleteContext({
    required String userId,
    bool includeAllRestaurants = true,
    bool includeAllMeals = false, // Can be heavy, default to false
    bool includeAllCharities = true,
  }) async {
    try {
      final futures = <Future>[];

      // Always get user context
      futures.add(getUserContext(userId));

      // Optionally add global data
      if (includeAllRestaurants) {
        futures.add(getRestaurants());
      }
      if (includeAllMeals) {
        futures.add(getMeals());
      } else {
        futures.add(getAvailableMeals()); // Get only available meals by default
      }
      if (includeAllCharities) {
        futures.add(getCharities());
      }

      final results = await Future.wait(futures);

      return {
        'user': results[0],
        'restaurants': includeAllRestaurants ? results[1] : [],
        'meals': results[2],
        'charities': includeAllCharities ? results[3] : [],
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error fetching complete context: $e');
      return {
        'user': {},
        'restaurants': [],
        'meals': [],
        'charities': [],
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }
}
