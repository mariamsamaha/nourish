import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proj/models/restaurant_model.dart';
import 'package:proj/models/food_item_model.dart';
import 'package:proj/models/charity_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
}
