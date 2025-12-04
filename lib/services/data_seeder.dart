import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proj/models/restaurant_model.dart';
import 'package:proj/models/food_item_model.dart';
import 'package:proj/models/charity_model.dart';

class DataSeeder {
  static Future<void> seed() async {
    final firestore = FirebaseFirestore.instance;

    print('🌱 Seeding database...');

    // 1. Seed Restaurants
    final restaurants = [
      Restaurant(
        id: 'r1',
        name: 'Artisan Bakery',
        rating: 4.8,
        reviews: 234,
        imageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
        address: '123 Baker St, San Francisco, CA',
        tags: ['Bakery', 'Pastries', 'Bread'],
        latitude: 37.7749,
        longitude: -122.4194,
        hasPickup: true,
        hasDelivery: false,
      ),
      Restaurant(
        id: 'r2',
        name: 'Green Leaf Salad',
        rating: 4.6,
        reviews: 156,
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
        address: '456 Green Way, San Francisco, CA',
        tags: ['Healthy', 'Salad', 'Vegan'],
        latitude: 37.7849,
        longitude: -122.4094,
        hasPickup: true,
        hasDelivery: true,
      ),
      Restaurant(
        id: 'r3',
        name: 'Sushi Master',
        rating: 4.9,
        reviews: 512,
        imageUrl:
            'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800',
        address: '789 Ocean Dr, San Francisco, CA',
        tags: ['Japanese', 'Sushi', 'Seafood'],
        latitude: 37.7649,
        longitude: -122.4294,
        hasPickup: true,
        hasDelivery: true,
      ),
    ];

    for (var r in restaurants) {
      await firestore
          .collection('restaurants')
          .doc(r.id)
          .set(r.toFirestore())
          .timeout(const Duration(seconds: 5));
      print('Added restaurant: ${r.name}');
    }

    // 2. Seed Food Items
    final foodItems = [
      FoodItem(
        id: 'f1',
        restaurantId: 'r1',
        restaurantName: 'Artisan Bakery',
        name: 'Surprise Bakery Bag',
        price: 4.99,
        originalPrice: 15.00,
        quantity: 5,
        pickupTime: '7:00 PM - 9:00 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=800',
        allergens: ['Gluten', 'Eggs', 'Dairy'],
      ),
      FoodItem(
        id: 'f2',
        restaurantId: 'r2',
        restaurantName: 'Green Leaf Salad',
        name: 'Fresh Salad Box',
        price: 6.99,
        originalPrice: 14.00,
        quantity: 3,
        pickupTime: '8:00 PM - 9:00 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
        allergens: ['Nuts'],
      ),
      FoodItem(
        id: 'f3',
        restaurantId: 'r3',
        restaurantName: 'Sushi Master',
        name: 'Sushi Platter',
        price: 9.99,
        originalPrice: 25.00,
        quantity: 2,
        pickupTime: '9:00 PM - 10:00 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800',
        allergens: ['Fish', 'Soy'],
      ),
    ];

    for (var f in foodItems) {
      await firestore
          .collection('food_items')
          .doc(f.id)
          .set(f.toFirestore())
          .timeout(const Duration(seconds: 5));
      print('Added food item: ${f.name}');
    }

    // 3. Seed Charities
    final charities = [
      Charity(
        id: 'c1',
        name: 'SF Food Bank',
        description:
            'Fighting hunger in San Francisco by providing meals to those in need.',
        imageUrl:
            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800',
        impactGoal: 10000,
        currentImpact: 5432,
      ),
      Charity(
        id: 'c2',
        name: 'Homeless Shelter',
        description: 'Providing shelter and hot meals to homeless individuals.',
        imageUrl:
            'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=800',
        impactGoal: 5000,
        currentImpact: 2100,
      ),
    ];

    for (var c in charities) {
      await firestore
          .collection('charities')
          .doc(c.id)
          .set(c.toFirestore())
          .timeout(const Duration(seconds: 5));
      print('Added charity: ${c.name}');
    }

    print('✅ Database seeded successfully!');
  }
}
