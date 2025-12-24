import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proj/models/restaurant_model.dart';
import 'package:proj/models/food_item_model.dart';
import 'package:proj/models/charity_model.dart';
import 'package:proj/services/database_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Restaurants
  Stream<List<Restaurant>> getRestaurants() {
    return _db.collection('restaurants').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
    });
  }

  // Get restaurants filtered by delivery/pickup
  Stream<List<Restaurant>> getRestaurantsFiltered({
    bool? hasDelivery,
    bool? hasPickup,
  }) {
    var query = _db.collection('restaurants') as Query;

    if (hasDelivery != null) {
      query = query.where('hasDelivery', isEqualTo: hasDelivery);
    }
    if (hasPickup != null) {
      query = query.where('hasPickup', isEqualTo: hasPickup);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Restaurant.fromFirestore(doc as DocumentSnapshot))
          .toList();
    });
  }

  Future<Restaurant?> getRestaurantById(String id) async {
    final doc = await _db.collection('restaurants').doc(id).get();
    if (doc.exists) {
      return Restaurant.fromFirestore(doc);
    }
    return null;
  }

  // Food Items
  Stream<List<FoodItem>> getAvailableFoodItems() {
    return _db
        .collection('food_items')
        .where('quantity', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FoodItem.fromFirestore(doc))
              .toList();
        });
  }

  // Get best offers (highest discount percentage)
  Stream<List<FoodItem>> getBestOffers({int limit = 10}) {
    return _db
        .collection('food_items')
        .where('quantity', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) {
          var items = snapshot.docs
              .map((doc) => FoodItem.fromFirestore(doc))
              .toList();

          // Sort by discount percentage (highest first)
          items.sort((a, b) {
            double discountA =
                ((a.originalPrice - a.price) / a.originalPrice) * 100;
            double discountB =
                ((b.originalPrice - b.price) / b.originalPrice) * 100;
            return discountB.compareTo(discountA);
          });

          // Return top items
          return items.take(limit).toList();
        });
  }

  Stream<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId) {
    return _db
        .collection('food_items')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FoodItem.fromFirestore(doc))
              .toList();
        });
  }

  // Charities
  Stream<List<Charity>> getCharities() {
    return _db.collection('charities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Charity.fromFirestore(doc)).toList();
    });
  }

  // ========== PROFILE IMAGE METHODS (SQLITE + FIRESTORE) ==========

  /// Save profile image (SQLite on mobile, Firestore on web)
  Future<void> saveProfileImageDual({
    required String userId,
    required String userEmail,
    required List<int> imageBytes,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      print('💾 Saving image: ${base64Image.length} chars');

      // Always save to Firestore (if online)
      print('🌐 Saving to Firestore for backup');
      try {
        await _db
            .collection('userImages')
            .doc(userId)
            .set({
              'userId': userId,
              'email': userEmail,
              'imageBase64': base64Image,
              'updatedAt': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(seconds: 5));
        print('✅ Saved to Firestore');
      } catch (e) {
        print('⚠️ Firestore backup failed (probably offline): $e');
      }

      if (!kIsWeb) {
        // MOBILE: Also save to SQLite for instant local access
        print('📱 Mobile: Saving to SQLite');
        final dbService = DatabaseService();
        await dbService.saveProfileImage(
          userId: userId,
          userEmail: userEmail,
          imageBase64: base64Image,
        );
        print('✅ Saved to SQLite');
      }
    } catch (e) {
      print('❌ Save ERROR: $e');
      throw Exception('Failed to save image: $e');
    }
  }

  /// Get profile image (SQLite on mobile, Firestore on web)
  Future<String?> getProfileImageDual(String userId) async {
    try {
      print('🔍 Loading image for user: $userId');

      // 1. Try Firestore First (if online)
      try {
        print('🌐 Attempting to load from Firestore');
        final doc = await _db
            .collection('userImages')
            .doc(userId)
            .get()
            .timeout(const Duration(seconds: 3));
        if (doc.exists) {
          final base64 = doc.data()?['imageBase64'] as String?;
          if (base64 != null) {
            print('✅ Found in Firestore');
            // Cache it locally on mobile
            if (!kIsWeb) {
              final dbService = DatabaseService();
              final email = doc.data()?['email'] as String? ?? '';
              await dbService.saveProfileImage(
                userId: userId,
                userEmail: email,
                imageBase64: base64,
              );
              print('💾 Cached Firestore image locally to SQLite');
            }
            return base64;
          }
        }
      } catch (e) {
        print('⚠️ Firestore load failed (probably offline): $e');
      }

      // 2. Fallback to Local Storage
      if (kIsWeb) {
        // Web SharedPreferences fallback
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('profile_image_$userId');
      } else {
        // Mobile SQLite fallback
        print('📱 Mobile: Falling back to SQLite');
        final dbService = DatabaseService();
        final base64 = await dbService.getProfileImage(userId);
        if (base64 != null) {
          print('✅ Found in SQLite');
        } else {
          print('⚠️ Not found in SQLite either');
        }
        return base64;
      }
    } catch (e) {
      print('❌ Load ERROR: $e');
      return null;
    }
  }

  // ========== FAVORITE RESTAURANTS METHODS (SQLITE + FIRESTORE) ==========

  /// Sync a favorite restaurant to Cloud + Local
  Future<void> toggleFavoriteDual({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required bool isAdding,
    String? restaurantImage,
    double? restaurantRating,
    int? restaurantReviews,
    List<String>? restaurantTags,
  }) async {
    final dbService = DatabaseService();

    if (isAdding) {
      // ADDING
      // Save locally first for instant feedback (Mobile)
      if (!kIsWeb) {
        await dbService.addFavoriteRestaurant(
          userId: userId,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          restaurantImage: restaurantImage,
          restaurantRating: restaurantRating,
          restaurantReviews: restaurantReviews,
          restaurantTags: restaurantTags,
        );
      }

      // Sync to Firestore
      try {
        await _db
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
        print('⚠️ Cloud sync failed (offline): $e');
      }
    } else {
      // REMOVING
      if (!kIsWeb) {
        await dbService.removeFavoriteRestaurant(
          userId: userId,
          restaurantId: restaurantId,
        );
      }
      try {
        await _db
            .collection('userFavorites')
            .doc(userId)
            .collection('restaurants')
            .doc(restaurantId)
            .delete()
            .timeout(const Duration(seconds: 5));
        print('✅ Favorite removed from Firestore');
      } catch (e) {
        print('⚠️ Cloud sync failed (offline): $e');
      }
    }
  }

  /// Get favorites with cloud-first logic
  Future<List<Map<String, dynamic>>> getFavoritesDual(String userId) async {
    final dbService = DatabaseService();

    try {
      // Try cloud first
      final snapshot = await _db
          .collection('userFavorites')
          .doc(userId)
          .collection('restaurants')
          .get()
          .timeout(const Duration(seconds: 5));

      if (snapshot.docs.isNotEmpty) {
        final favorites = snapshot.docs.map((doc) {
          final data = doc.data();
          return {...data, 'restaurant_id': doc.id};
        }).toList();

        // Sync local storage with what we found in cloud (Mobile)
        if (!kIsWeb) {
          for (var fav in favorites) {
            final tags = fav['restaurant_tags'] as List<dynamic>?;
            await dbService.addFavoriteRestaurant(
              userId: userId,
              restaurantId: fav['restaurant_id'],
              restaurantName: fav['restaurant_name'] ?? '',
              restaurantImage: fav['restaurant_image'],
              restaurantRating: (fav['restaurant_rating'] as num?)?.toDouble(),
              restaurantReviews: fav['restaurant_reviews'] as int?,
              restaurantTags: tags?.map((e) => e.toString()).toList(),
            );
          }
        }
        return favorites;
      }
    } catch (e) {
      print('⚠️ Cloud favorites fetch failed: $e');
    }

    // Fallback to local
    return await dbService.getFavoriteRestaurants(userId);
  }
}
