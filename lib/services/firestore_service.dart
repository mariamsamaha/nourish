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
  Stream<List<Restaurant>> getRestaurantsFiltered({bool? hasDelivery, bool? hasPickup}) {
    var query = _db.collection('restaurants') as Query;
    
    if (hasDelivery != null) {
      query = query.where('hasDelivery', isEqualTo: hasDelivery);
    }
    if (hasPickup != null) {
      query = query.where('hasPickup', isEqualTo: hasPickup);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc as DocumentSnapshot)).toList();
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
    return _db.collection('food_items')
        .where('quantity', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    });
  }

  // Get best offers (highest discount percentage)
  Stream<List<FoodItem>> getBestOffers({int limit = 10}) {
    return _db.collection('food_items')
        .where('quantity', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) {
      var items = snapshot.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
      
      // Sort by discount percentage (highest first)
      items.sort((a, b) {
        double discountA = ((a.originalPrice - a.price) / a.originalPrice) * 100;
        double discountB = ((b.originalPrice - b.price) / b.originalPrice) * 100;
        return discountB.compareTo(discountA);
      });
      
      // Return top items
      return items.take(limit).toList();
    });
  }

  Stream<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId) {
    return _db.collection('food_items')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    });
  }

  // Charities
  Stream<List<Charity>> getCharities() {
    return _db.collection('charities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Charity.fromFirestore(doc)).toList();
    });
  }

  // ========== PROFILE IMAGE METHODS (SQLLITE + FIRESTORE) ==========

  /// Save profile image (SQLite on mobile, Firestore on web)
  Future<void> saveProfileImageDual({
    required String userId,
    required String userEmail,
    required List<int> imageBytes,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      print('💾 Saving image: ${base64Image.length} chars');
      
      if (kIsWeb) {
        // WEB: Save to Firestore (persists across browsers)
        print('🌐 Web: Saving to Firestore');
        await _db.collection('userImages').doc(userId).set({
          'userId': userId,
          'email': userEmail,
          'imageBase64': base64Image,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Saved to Firestore');
      } else {
        // MOBILE: Save to SQLite
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
      
      if (kIsWeb) {
        // WEB: Load from Firestore
        print('🌐 Web: Loading from Firestore');
        final doc = await _db.collection('userImages').doc(userId).get();
        if (doc.exists) {
          final base64 = doc.data()?['imageBase64'] as String?;
          print('✅ Found in Firestore');
          return base64;
        }
        print('⚠️ Not found in Firestore');
        return null;
      } else {
        // MOBILE: Load from SQLite
        print('📱 Mobile: Loading from SQLite');
        final dbService = DatabaseService();
        final base64 = await dbService.getProfileImage(userId);
        if (base64 != null) {
          print('✅ Found in SQLite');
        } else {
          print('⚠️ Not found in SQLite');
        }
        return base64;
      }
    } catch (e) {
      print('❌ Load ERROR: $e');
      return null;
    }
  }
}
