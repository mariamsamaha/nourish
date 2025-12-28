import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      version: 4, // Updated version
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

        await db.execute('''
          CREATE TABLE profile_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL UNIQUE,
            email TEXT NOT NULL,
            image_base64 TEXT NOT NULL,
            updated_at TEXT NOT NULL
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
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE profile_images (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT NOT NULL UNIQUE,
              email TEXT NOT NULL,
              image_base64 TEXT NOT NULL,
              updated_at TEXT NOT NULL
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

  Future<void> _saveCartToPrefs(
    Map<String, List<Map<String, dynamic>>> cartData,
  ) async {
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
      final existingIndex = userCart.indexWhere(
        (item) => item['food_id'] == foodId,
      );

      if (existingIndex != -1) {
        // Update quantity
        userCart[existingIndex]['quantity'] =
            (userCart[existingIndex]['quantity'] as int) + quantity;
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
        await db.insert(_tableName, {
          'user_id': userId,
          'food_id': foodId,
          'food_name': foodName,
          'food_price': foodPrice,
          'food_image': foodImage,
          'quantity': quantity,
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
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

      final itemIndex = userCart.indexWhere(
        (item) => item['food_id'] == foodId,
      );
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
      await db.delete(_tableName, where: 'user_id = ?', whereArgs: [userId]);
    }
  }

  /// Get the total number of items in cart for a user
  Future<int> getCartItemCount(String userId) async {
    if (kIsWeb) {
      // Web implementation
      final cartData = await _loadCartFromPrefs();
      final userCart = cartData[userId] ?? [];
      return userCart.fold<int>(
        0,
        (sum, item) => sum + (item['quantity'] as int),
      );
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
      return userCart.fold<double>(
        0.0,
        (sum, item) =>
            sum + ((item['food_price'] as double) * (item['quantity'] as int)),
      );
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
  Future<void> _saveCharityPrefsToPrefs(
    Map<String, List<String>> prefsData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = json.encode(prefsData);
    await prefs.setString(_charityPrefsKey, prefsJson);
  }

  /// Add a charity to user's supported charities (SQLite first)
  Future<void> addSupportedCharity({
    required String userId,
    required String charityId,
  }) async {
    // 1. Local Cache
    if (!kIsWeb) {
      try {
        final db = await database;
        await db.insert('user_charity_preferences', {
          'user_id': userId,
          'charity_id': charityId,
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (e) {}
    }

    // 2. Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('userCharities')
          .doc(userId)
          .collection('charities')
          .doc(charityId)
          .set({
            'charity_id': charityId,
            'created_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('⚠️ Firestore charity sync failed: $e');
    }
  }

  /// Remove a charity from user's supported charities (Always Firestore)
  Future<void> removeSupportedCharity({
    required String userId,
    required String charityId,
  }) async {
    // 1. Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('userCharities')
          .doc(userId)
          .collection('charities')
          .doc(charityId)
          .delete();
    } catch (e) {
      print('⚠️ Firestore charity remove failed: $e');
    }

    // 2. Local Cache
    if (!kIsWeb) {
      final db = await database;
      await db.delete(
        'user_charity_preferences',
        where: 'user_id = ? AND charity_id = ?',
        whereArgs: [userId, charityId],
      );
    }
  }

  /// Get all charities supported by a user (Firestore primary, SQLite sync)
  Future<List<String>> getSupportedCharities(String userId) async {
    try {
      // 1. Try Firestore First
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('userCharities')
          .doc(userId)
          .collection('charities')
          .get()
          .timeout(const Duration(seconds: 5));

      final charityIds = snapshot.docs.map((doc) => doc.id).toList();

      // 2. Sync to local on Mobile
      if (!kIsWeb && charityIds.isNotEmpty) {
        final db = await database;
        for (var id in charityIds) {
          await db.insert(
            'user_charity_preferences',
            {
              'user_id': userId,
              'charity_id': id,
              'created_at': DateTime.now().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }

      if (charityIds.isNotEmpty) return charityIds;
    } catch (e) {
      print('⚠️ Firestore charity fetch failed: $e');
    }

    // 3. Fallback to Local
    if (kIsWeb) {
      return [];
    } else {
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

  /// Check if a user supports a specific charity (Local first, then Firestore)
  Future<bool> isCharitySupported({
    required String userId,
    required String charityId,
  }) async {
    // 1. Try local cache first on mobile
    if (!kIsWeb) {
      final db = await database;
      final results = await db.query(
        'user_charity_preferences',
        where: 'user_id = ? AND charity_id = ?',
        whereArgs: [userId, charityId],
      );
      if (results.isNotEmpty) return true;
    }

    // 2. Check Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore
          .collection('userCharities')
          .doc(userId)
          .collection('charities')
          .doc(charityId)
          .get()
          .timeout(const Duration(seconds: 3));

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ===== FAVORITE RESTAURANTS METHODS =====

  /// Add a restaurant to user's favorites (SQLite cache first, then Firestore)
  Future<void> addFavoriteRestaurant({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    String? restaurantImage,
    double? restaurantRating,
    int? restaurantReviews,
    List<String>? restaurantTags,
  }) async {
    // 1. Save to Local Cache FIRST (Mobile/Desktop) - Instant persistence
    if (!kIsWeb) {
      try {
        final db = await database;
        await db.insert('favorite_restaurants', {
          'user_id': userId,
          'restaurant_id': restaurantId,
          'restaurant_name': restaurantName,
          'restaurant_image': restaurantImage,
          'restaurant_rating': restaurantRating,
          'restaurant_reviews': restaurantReviews,
          'restaurant_tags': restaurantTags?.join(','),
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        print('✅ Favorite saved to SQLite cache');
      } catch (e) {
        print('❌ SQLite error: $e');
      }
    }

    // 2. Sync to Firestore (Primary/Backup) - Don't let this block or fail local save
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('userFavorites')
          .doc(userId)
          .collection('restaurants')
          .doc(restaurantId)
          .set({
            'restaurant_id': restaurantId,
            'restaurant_name': restaurantName,
            'restaurant_image': restaurantImage,
            'restaurant_rating': restaurantRating,
            'restaurant_reviews': restaurantReviews,
            'restaurant_tags': restaurantTags,
            'created_at': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 5));
      print('✅ Favorite synced to Firestore');
    } catch (e) {
      print('⚠️ Firestore sync failed (will retry next time): $e');
    }
  }

  /// Remove a restaurant from user's favorites (SQLite remove first, then Firestore)
  Future<void> removeFavoriteRestaurant({
    required String userId,
    required String restaurantId,
  }) async {
    // 1. Remove from Local Cache FIRST
    if (!kIsWeb) {
      try {
        final db = await database;
        await db.delete(
          'favorite_restaurants',
          where: 'user_id = ? AND restaurant_id = ?',
          whereArgs: [userId, restaurantId],
        );
        print('✅ Favorite removed from SQLite cache');
      } catch (e) {
        print('❌ SQLite error: $e');
      }
    }

    // 2. Remove from Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('userFavorites')
          .doc(userId)
          .collection('restaurants')
          .doc(restaurantId)
          .delete()
          .timeout(const Duration(seconds: 5));
      print('✅ Favorite removed from Firestore');
    } catch (e) {
      print('⚠️ Firestore remove failed: $e');
    }
  }

  /// Get all favorite restaurants for a user (Firestore primary, SQLite fallback/sync)
  Future<List<Map<String, dynamic>>> getFavoriteRestaurants(
    String userId,
  ) async {
    try {
      // 1. Try Firestore First
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('userFavorites')
          .doc(userId)
          .collection('restaurants')
          .orderBy('created_at', descending: true)
          .get()
          .timeout(const Duration(seconds: 5));

      final favorites = snapshot.docs.map((doc) {
        final data = doc.data();
        return {...data, 'restaurant_id': doc.id};
      }).toList();

      // 2. Sync to Local Cache on Mobile
      if (!kIsWeb && favorites.isNotEmpty) {
        final db = await database;
        for (var fav in favorites) {
          final tags = fav['restaurant_tags'] as List<dynamic>?;
          await db.insert('favorite_restaurants', {
            'user_id': userId,
            'restaurant_id': fav['restaurant_id'],
            'restaurant_name': fav['restaurant_name'] ?? 'Restaurant',
            'restaurant_image': fav['restaurant_image'],
            'restaurant_rating': (fav['restaurant_rating'] as num?)?.toDouble(),
            'restaurant_reviews': fav['restaurant_reviews'] as int?,
            'restaurant_tags': tags?.join(','),
            'created_at': DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      if (favorites.isNotEmpty) return favorites;
    } catch (e) {
      print('⚠️ Firestore fetch failed: $e');
    }

    // 3. Fallback to Local Storage
    if (kIsWeb) {
      return []; // No SQLite on web
    } else {
      final db = await database;
      final results = await db.query(
        'favorite_restaurants',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return results.map((row) {
        final tags = row['restaurant_tags'] as String?;
        return {
          ...row,
          'restaurant_tags': tags != null && tags.isNotEmpty
              ? tags.split(',')
              : <String>[],
        };
      }).toList();
    }
  }

  /// Check if a restaurant is favorited by user (Firestore primary, SQLite fallback)
  Future<bool> isRestaurantFavorited({
    required String userId,
    required String restaurantId,
  }) async {
    // 1. Try local cache first on mobile (faster)
    if (!kIsWeb) {
      final db = await database;
      final results = await db.query(
        'favorite_restaurants',
        where: 'user_id = ? AND restaurant_id = ?',
        whereArgs: [userId, restaurantId],
      );
      if (results.isNotEmpty) return true;
    }

    // 2. Check Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore
          .collection('userFavorites')
          .doc(userId)
          .collection('restaurants')
          .doc(restaurantId)
          .get()
          .timeout(const Duration(seconds: 3));

      return doc.exists;
    } catch (e) {
      print('⚠️ Firestore check failed: $e');
      return false;
    }
  }

  // ===== PROFILE IMAGE METHODS =====

  /// Save profile image (Always Firestore, SQLite/Prefs cache)
  Future<void> saveProfileImage({
    required String userId,
    required String userEmail,
    required String imageBase64,
  }) async {
    // 1. Save to Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('userImages').doc(userId).set({
        'userId': userId,
        'email': userEmail,
        'imageBase64': imageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Profile image synced to Firestore');
    } catch (e) {
      print('⚠️ Firestore image sync failed: $e');
    }

    // 2. Save to Local Cache
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_$userId', imageBase64);
    } else {
      final db = await database;
      await db.insert('profile_images', {
        'user_id': userId,
        'email': userEmail,
        'image_base64': imageBase64,
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Get profile image (Firestore primary, cache fallback)
  Future<String?> getProfileImage(String userId) async {
    try {
      // 1. Try Firestore first
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore
          .collection('userImages')
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 5));

      if (doc.exists) {
        final base64 = doc.data()?['imageBase64'] as String?;
        if (base64 != null) {
          // Sync to local cache
          if (kIsWeb) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('profile_image_$userId', base64);
          } else {
            final db = await database;
            await db.insert('profile_images', {
              'user_id': userId,
              'email': doc.data()?['email'] ?? '',
              'image_base64': base64,
              'updated_at': DateTime.now().toIso8601String(),
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
          return base64;
        }
      }
    } catch (e) {
      print('⚠️ Firestore image fetch failed: $e');
    }

    // 2. Fallback to local
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('profile_image_$userId');
    } else {
      final db = await database;
      final results = await db.query(
        'profile_images',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (results.isNotEmpty) {
        return results.first['image_base64'] as String?;
      }
      return null;
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
