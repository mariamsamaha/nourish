import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proj/models/restaurant_model.dart';
import 'package:proj/models/food_item_model.dart';
import 'package:proj/models/charity_model.dart';
import 'package:proj/services/mock_data_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Restaurants
  Stream<List<Restaurant>> getRestaurants() {
    try {
      return _db.collection('restaurants').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Firebase error, using mock data: $e');
      return MockDataService.getRestaurants();
    }
  }

  // Get restaurants filtered by delivery/pickup
  Stream<List<Restaurant>> getRestaurantsFiltered({bool? hasDelivery, bool? hasPickup}) {
    try {
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
    } catch (e) {
      print('Firebase error, using mock data: $e');
      return MockDataService.getRestaurantsFiltered(
        hasDelivery: hasDelivery,
        hasPickup: hasPickup,
      );
    }
  }

  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final doc = await _db.collection('restaurants').doc(id).get();
      if (doc.exists) {
        return Restaurant.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Firebase error, using mock data: $e');
      return await MockDataService.getRestaurantById(id);
    }
  }

  // Food Items
  Stream<List<FoodItem>> getAvailableFoodItems() {
    try {
      return _db.collection('food_items')
          .where('quantity', isGreaterThan: 0)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Firebase error, using mock data: $e');
      return MockDataService.getAvailableFoodItems();
    }
  }

  // Get best offers (highest discount percentage)
  Stream<List<FoodItem>> getBestOffers({int limit = 10}) {
    try {
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
    } catch (e) {
      print('Firebase error, using mock data: $e');
      return MockDataService.getBestOffers(limit: limit);
    }
  }

  Stream<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId) {
    try {
      return _db.collection('food_items')
          .where('restaurantId', isEqualTo: restaurantId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Firebase error, using mock data: $e');
      return MockDataService.getFoodItemsByRestaurant(restaurantId);
    }
  }

  // Charities
  Stream<List<Charity>> getCharities() {
    try {
      return _db.collection('charities').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Charity.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Firebase error, using mock data: $e');
      return MockDataService.getCharities();
    }
  }
}
