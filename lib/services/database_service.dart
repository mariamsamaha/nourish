import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage local cart storage.
/// Uses SharedPreferences (localStorage) on web, SQLite on mobile/desktop.
/// Each cart item is associated with a specific user ID to ensure data isolation.
class DatabaseService {
  static Database? _database;
  static const String _tableName = 'cart_items';
  static const String _cartPrefsKey = 'cart_data';

  /// Get the database instance (only for non-web platforms)
  Future<Database> get database async {
    if (kIsWeb) {
      throw Exception('SQLite not used on web platform');
    }
    
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the SQLite database (mobile/desktop only)
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nourish.db');
    
    return await openDatabase(
      path,
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            food_id TEXT NOT NULL,
            food_name TEXT NOT NULL,
            food_price REAL NOT NULL,
            food_image TEXT,
            quantity INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            UNIQUE(user_id, food_id)
          )
        ''');
        
        await db.execute('''
          CREATE TABLE user_charity_preferences (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            charity_id TEXT NOT NULL,
            created_at TEXT NOT NULL,
            UNIQUE(user_id, charity_id)
          )
        ''');
        
        await db.execute('''
          CREATE TABLE favorite_restaurants (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            restaurant_id TEXT NOT NULL,
            restaurant_name TEXT NOT NULL,
            restaurant_image TEXT,
            restaurant_rating REAL,
            restaurant_reviews INTEGER,
            restaurant_tags TEXT,
            created_at TEXT NOT NULL,
            UNIQUE(user_id, restaurant_id)
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE user_charity_preferences (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT NOT NULL,
              charity_id TEXT NOT NULL,
              created_at TEXT NOT NULL,
              UNIQUE(user_id, charity_id)
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE favorite_restaurants (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT NOT NULL,
              restaurant_id TEXT NOT NULL,
              restaurant_name TEXT NOT NULL,
              restaurant_image TEXT,
              restaurant_rating REAL,
              restaurant_reviews INTEGER,
              restaurant_tags TEXT,
              created_at TEXT NOT NULL,
              UNIQUE(user_id, restaurant_id)
            )
          ''');
        }
      },
    );
  }

  // ===== WEB STORAGE METHODS (SharedPreferences) =====

  Future<Map<String, List<Map<String, dynamic>>>> _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartPrefsKey);
    
    if (cartJson == null) {
      return {};
    }
    
    try {
      final Map<String, dynamic> decoded = json.decode(cartJson);
      final Map<String, List<Map<String, dynamic>>> result = {};
      
      decoded.forEach((userId, items) {
        result[userId] = List<Map<String, dynamic>>.from(items);
      });
      
      return result;
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveCartToPrefs(Map<String, List<Map<String, dynamic>>> cartData) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(cartData);
    await prefs.setString(_cartPrefsKey, cartJson);
  }

  // ===== UNIFIED METHODS (work on both web and mobile) =====

  /// Add an item to the cart for a specific user
  Future<void> addToCart({
    required String userId,
    required String foodId,
    required String foodName,
    required double foodPrice,
    String? foodImage,
    int quantity = 1,
  }) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
      final cartData = await _loadCartFromPrefs();
      final userCart = cartData[userId] ?? [];
      
      // Check if item already exists
      final existingIndex = userCart.indexWhere((item) => item['food_id'] == foodId);
      
      if (existingIndex != -1) {
        // Update quantity
        userCart[existingIndex]['quantity'] = (userCart[existingIndex]['quantity'] as int) + quantity;
      } else {
        // Add new item
        userCart.add({
          'food_id': foodId,
          'food_name': foodName,
          'food_price': foodPrice,
          'food_image': foodImage,
          'quantity': quantity,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      
      cartData[userId] = userCart;
      await _saveCartToPrefs(cartData);
    } else {
      // Mobile/Desktop implementation using SQLite
      final db = await database;
      
      final existingItem = await db.query(
        _tableName,
        where: 'user_id = ? AND food_id = ?',
        whereArgs: [userId, foodId],
      );

      if (existingItem.isNotEmpty) {
        final currentQuantity = existingItem.first['quantity'] as int;
        await db.update(
          _tableName,
          {'quantity': currentQuantity + quantity},
          where: 'user_id = ? AND food_id = ?',
          whereArgs: [userId, foodId],
        );
      } else {
        await db.insert(
          _tableName,
          {
            'user_id': userId,
            'food_id': foodId,
            'food_name': foodName,
            'food_price': foodPrice,
            'food_image': foodImage,
            'quantity': quantity,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  /// Get all cart items for a specific user
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    if (kIsWeb) {
      // Web implementation
      final cartData = await _loadCartFromPrefs();
      return cartData[userId] ?? [];
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      return await db.query(
        _tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
    }
  }

  /// Update the quantity of a cart item
  Future<void> updateQuantity({
    required String userId,
    required String foodId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeFromCart(userId: userId, foodId: foodId);
      return;
    }

    if (kIsWeb) {
      // Web implementation
      final cartData = await _loadCartFromPrefs();
      final userCart = cartData[userId] ?? [];
      
      final itemIndex = userCart.indexWhere((item) => item['food_id'] == foodId);
      if (itemIndex != -1) {
        userCart[itemIndex]['quantity'] = quantity;
        cartData[userId] = userCart;
        await _saveCartToPrefs(cartData);
      }
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      await db.update(
        _tableName,
        {'quantity': quantity},
        where: 'user_id = ? AND food_id = ?',
        whereArgs: [userId, foodId],
      );
    }
  }

  /// Remove a specific item from the cart
  Future<void> removeFromCart({
    required String userId,
    required String foodId,
  }) async {
    if (kIsWeb) {
      // Web implementation
      final cartData = await _loadCartFromPrefs();
      final userCart = cartData[userId] ?? [];
      
      userCart.removeWhere((item) => item['food_id'] == foodId);
      cartData[userId] = userCart;
      await _saveCartToPrefs(cartData);
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      await db.delete(
        _tableName,
        where: 'user_id = ? AND food_id = ?',
        whereArgs: [userId, foodId],
      );
    }
  }

  /// Clear all cart items for a specific user
  Future<void> clearCart(String userId) async {
    if (kIsWeb) {
      // Web implementation
      final cartData = await _loadCartFromPrefs();
      cartData[userId] = [];
      await _saveCartToPrefs(cartData);
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      await db.delete(
        _tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }

  /// Get the total number of items in cart for a user
  Future<int> getCartItemCount(String userId) async {
    if (kIsWeb) {
      // Web implementation
      final cartData = await _loadCartFromPrefs();
      final userCart = cartData[userId] ?? [];
      return userCart.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      final result = await db.rawQuery(
        'SELECT SUM(quantity) as total FROM $_tableName WHERE user_id = ?',
        [userId],
      );
      
      return result.first['total'] as int? ?? 0;
    }
  }

  /// Get the total price of all items in cart for a user
  Future<double> getCartTotal(String userId) async {
    if (kIsWeb) {
      // Web implementation
      final cartData = await _loadCartFromPrefs();
      final userCart = cartData[userId] ?? [];
      return userCart.fold<double>(0.0, (sum, item) => 
        sum + ((item['food_price'] as double) * (item['quantity'] as int)));
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      final result = await db.rawQuery(
        'SELECT SUM(food_price * quantity) as total FROM $_tableName WHERE user_id = ?',
        [userId],
      );
      
      return result.first['total'] as double? ?? 0.0;
    }
  }

  // ===== CHARITY PREFERENCES METHODS =====

  static const String _charityPrefsKey = 'charity_preferences';

  /// Load charity preferences from SharedPreferences (web only)
  Future<Map<String, List<String>>> _loadCharityPrefsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString(_charityPrefsKey);
    
    if (prefsJson == null) {
      return {};
    }
    
    try {
      final Map<String, dynamic> decoded = json.decode(prefsJson);
      final Map<String, List<String>> result = {};
      
      decoded.forEach((userId, charityIds) {
        result[userId] = List<String>.from(charityIds);
      });
      
      return result;
    } catch (e) {
      return {};
    }
  }

  /// Save charity preferences to SharedPreferences (web only)
  Future<void> _saveCharityPrefsToPrefs(Map<String, List<String>> prefsData) async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = json.encode(prefsData);
    await prefs.setString(_charityPrefsKey, prefsJson);
  }

  /// Add a charity to user's supported charities
  Future<void> addSupportedCharity({
    required String userId,
    required String charityId,
  }) async {
    if (kIsWeb) {
      // Web implementation
      final prefsData = await _loadCharityPrefsFromPrefs();
      final userCharities = prefsData[userId] ?? [];
      
      if (!userCharities.contains(charityId)) {
        userCharities.add(charityId);
        prefsData[userId] = userCharities;
        await _saveCharityPrefsToPrefs(prefsData);
      }
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      
      try {
        await db.insert(
          'user_charity_preferences',
          {
            'user_id': userId,
            'charity_id': charityId,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      } catch (e) {
        // Ignore if already exists
      }
    }
  }

  /// Remove a charity from user's supported charities
  Future<void> removeSupportedCharity({
    required String userId,
    required String charityId,
  }) async {
    if (kIsWeb) {
      // Web implementation
      final prefsData = await _loadCharityPrefsFromPrefs();
      final userCharities = prefsData[userId] ?? [];
      
      userCharities.remove(charityId);
      prefsData[userId] = userCharities;
      await _saveCharityPrefsToPrefs(prefsData);
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      await db.delete(
        'user_charity_preferences',
        where: 'user_id = ? AND charity_id = ?',
        whereArgs: [userId, charityId],
      );
    }
  }

  /// Get all charities supported by a user
  Future<List<String>> getSupportedCharities(String userId) async {
    if (kIsWeb) {
      // Web implementation
      final prefsData = await _loadCharityPrefsFromPrefs();
      return prefsData[userId] ?? [];
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      final results = await db.query(
        'user_charity_preferences',
        columns: ['charity_id'],
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      return results.map((row) => row['charity_id'] as String).toList();
    }
  }

  /// Check if a user supports a specific charity
  Future<bool> isCharitySupported({
    required String userId,
    required String charityId,
  }) async {
    if (kIsWeb) {
      // Web implementation
      final prefsData = await _loadCharityPrefsFromPrefs();
      final userCharities = prefsData[userId] ?? [];
      return userCharities.contains(charityId);
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      final results = await db.query(
        'user_charity_preferences',
        where: 'user_id = ? AND charity_id = ?',
        whereArgs: [userId, charityId],
      );
      
      return results.isNotEmpty;
    }
  }

  // ===== FAVORITE RESTAURANTS METHODS =====

  static const String _favoriteRestaurantsKey = 'favorite_restaurants';

  /// Load favorite restaurants from SharedPreferences (web only)
  Future<Map<String, List<Map<String, dynamic>>>> _loadFavoriteRestaurantsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString(_favoriteRestaurantsKey);
    
    if (prefsJson == null) {
      return {};
    }
    
    try {
      final Map<String, dynamic> decoded = json.decode(prefsJson);
      final Map<String, List<Map<String, dynamic>>> result = {};
      
      decoded.forEach((userId, restaurants) {
        result[userId] = List<Map<String, dynamic>>.from(restaurants);
      });
      
      return result;
    } catch (e) {
      return {};
    }
  }

  /// Save favorite restaurants to SharedPreferences (web only)
  Future<void> _saveFavoriteRestaurantsToPrefs(Map<String, List<Map<String, dynamic>>> prefsData) async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = json.encode(prefsData);
    await prefs.setString(_favoriteRestaurantsKey, prefsJson);
  }

  /// Add a restaurant to user's favorites
  Future<void> addFavoriteRestaurant({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    String? restaurantImage,
    double? restaurantRating,
    int? restaurantReviews,
    List<String>? restaurantTags,
  }) async {
    if (kIsWeb) {
      // Web implementation
      final prefsData = await _loadFavoriteRestaurantsFromPrefs();
      final userFavorites = prefsData[userId] ?? [];
      
      // Check if already exists
      if (!userFavorites.any((r) => r['restaurant_id'] == restaurantId)) {
        userFavorites.add({
          'restaurant_id': restaurantId,
          'restaurant_name': restaurantName,
          'restaurant_image': restaurantImage,
          'restaurant_rating': restaurantRating,
          'restaurant_reviews': restaurantReviews,
          'restaurant_tags': restaurantTags?.join(','),
          'created_at': DateTime.now().toIso8601String(),
        });
        prefsData[userId] = userFavorites;
        await _saveFavoriteRestaurantsToPrefs(prefsData);
      }
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      
      try {
        await db.insert(
          'favorite_restaurants',
          {
            'user_id': userId,
            'restaurant_id': restaurantId,
            'restaurant_name': restaurantName,
            'restaurant_image': restaurantImage,
            'restaurant_rating': restaurantRating,
            'restaurant_reviews': restaurantReviews,
            'restaurant_tags': restaurantTags?.join(','),
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      } catch (e) {
        // Ignore if already exists
      }
    }
  }

  /// Remove a restaurant from user's favorites
  Future<void> removeFavoriteRestaurant({
    required String userId,
    required String restaurantId,
  }) async {
    if (kIsWeb) {
      // Web implementation
      final prefsData = await _loadFavoriteRestaurantsFromPrefs();
      final userFavorites = prefsData[userId] ?? [];
      
      userFavorites.removeWhere((r) => r['restaurant_id'] == restaurantId);
      prefsData[userId] = userFavorites;
      await _saveFavoriteRestaurantsToPrefs(prefsData);
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      await db.delete(
        'favorite_restaurants',
        where: 'user_id = ? AND restaurant_id = ?',
        whereArgs: [userId, restaurantId],
      );
    }
  }

  /// Get all favorite restaurants for a user
  Future<List<Map<String, dynamic>>> getFavoriteRestaurants(String userId) async {
    if (kIsWeb) {
      // Web implementation
      final prefsData = await _loadFavoriteRestaurantsFromPrefs();
      final favorites = prefsData[userId] ?? [];
      
      // Parse tags back to list
      return favorites.map((r) {
        final tags = r['restaurant_tags'] as String?;
        return {
          ...r,
          'restaurant_tags': tags != null && tags.isNotEmpty ? tags.split(',') : <String>[],
        };
      }).toList();
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      final results = await db.query(
        'favorite_restaurants',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      
      // Parse tags back to list
      return results.map((row) {
        final tags = row['restaurant_tags'] as String?;
        return {
          ...row,
          'restaurant_tags': tags != null && tags.isNotEmpty ? tags.split(',') : <String>[],
        };
      }).toList();
    }
  }

  /// Check if a restaurant is favorited by user
  Future<bool> isRestaurantFavorited({
    required String userId,
    required String restaurantId,
  }) async {
    if (kIsWeb) {
      // Web implementation
      final prefsData = await _loadFavoriteRestaurantsFromPrefs();
      final userFavorites = prefsData[userId] ?? [];
      return userFavorites.any((r) => r['restaurant_id'] == restaurantId);
    } else {
      // Mobile/Desktop implementation
      final db = await database;
      final results = await db.query(
        'favorite_restaurants',
        where: 'user_id = ? AND restaurant_id = ?',
        whereArgs: [userId, restaurantId],
      );
      
      return results.isNotEmpty;
    }
  }

  /// Close the database connection (mobile/desktop only)
  Future<void> close() async {
    if (!kIsWeb && _database != null) {
      final db = await database;
      await db.close();
      _database = null;
    }
  }
}
