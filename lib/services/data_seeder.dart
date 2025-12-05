import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proj/models/restaurant_model.dart';
import 'package:proj/models/food_item_model.dart';
import 'package:proj/models/charity_model.dart';

class DataSeeder {
  static bool _hasSeeded = false;

  static Future<void> seed() async {
    if (_hasSeeded) {
      print('⏭️  Database already seeded, skipping...');
      return;
    }

    final firestore = FirebaseFirestore.instance;

    print('🌱 Seeding database with Egyptian data...');

    // 1. Seed Egyptian Restaurants
    final restaurants = [
      Restaurant(
        id: 'r1',
        name: 'El Shabrawy Port Said',
        rating: 4.7,
        reviews: 342,
        imageUrl:
            'https://images.unsplash.com/photo-1517244683847-7456b63c5969?w=800',
        address: 'Gomhoureya St, Port Said, Egypt',
        tags: ['Egyptian', 'Grilled', 'Traditional'],
        latitude: 31.2653,
        longitude: 32.3019,
        hasPickup: true,
        hasDelivery: true,
      ),
      Restaurant(
        id: 'r2',
        name: 'Fish Market Port Fouad',
        rating: 4.8,
        reviews: 289,
        imageUrl:
            'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=800',
        address: 'Port Fouad, Port Said, Egypt',
        tags: ['Seafood', 'Fish', 'Mediterranean'],
        latitude: 31.2447,
        longitude: 32.3186,
        hasPickup: true,
        hasDelivery: false,
      ),
      Restaurant(
        id: 'r3',
        name: 'Al Ahram Restaurant',
        rating: 4.9,
        reviews: 512,
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=800',
        address: 'Al Haram St, Giza, Egypt',
        tags: ['Egyptian', 'Grilled', 'Traditional'],
        latitude: 29.9792,
        longitude: 31.1342,
        hasPickup: true,
        hasDelivery: true,
      ),
      Restaurant(
        id: 'r4',
        name: 'Sequoia Cairo',
        rating: 4.6,
        reviews: 678,
        imageUrl:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
        address: 'Nile Corniche, Zamalek, Cairo, Egypt',
        tags: ['Mediterranean', 'Upscale', 'View'],
        latitude: 30.0626,
        longitude: 31.2204,
        hasPickup: false,
        hasDelivery: false,
      ),
      Restaurant(
        id: 'r5',
        name: 'Makani Nasr City',
        rating: 4.5,
        reviews: 423,
        imageUrl:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
        address: 'Abbas El Akkad St, Nasr City, Cairo, Egypt',
        tags: ['Cafe', 'Pizza', 'Burgers'],
        latitude: 30.0566,
        longitude: 31.3457,
        hasPickup: true,
        hasDelivery: true,
      ),
      Restaurant(
        id: 'r6',
        name: 'Zooba Heliopolis',
        rating: 4.7,
        reviews: 567,
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
        address: 'Othman Towers, Heliopolis, Cairo, Egypt',
        tags: ['Egyptian', 'Street Food', 'Modern'],
        latitude: 30.0844,
        longitude: 31.3098,
        hasPickup: true,
        hasDelivery: true,
      ),
      Restaurant(
        id: 'r7',
        name: 'Lucille\'s Maadi',
        rating: 4.8,
        reviews: 445,
        imageUrl:
            'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
        address: 'Road 9, Maadi, Cairo, Egypt',
        tags: ['American', 'Burgers', 'Breakfast'],
        latitude: 29.9606,
        longitude: 31.2497,
        hasPickup: true,
        hasDelivery: true,
      ),
      Restaurant(
        id: 'r8',
        name: 'Fish Market Alexandria',
        rating: 4.9,
        reviews: 892,
        imageUrl:
            'https://images.unsplash.com/photo-1559496417-e7f25cb247f6?w=800',
        address: 'Corniche, Bahary, Alexandria, Egypt',
        tags: ['Seafood', 'Fish', 'Mediterranean'],
        latitude: 31.2001,
        longitude: 29.9187,
        hasPickup: true,
        hasDelivery: false,
      ),
      Restaurant(
        id: 'r9',
        name: 'Mori Sushi Mall of Arabia',
        rating: 4.6,
        reviews: 334,
        imageUrl:
            'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800',
        address: 'Mall of Arabia, 6th of October, Giza, Egypt',
        tags: ['Japanese', 'Sushi', 'Asian'],
        latitude: 29.9778,
        longitude: 30.9293,
        hasPickup: true,
        hasDelivery: true,
      ),
      Restaurant(
        id: 'r10',
        name: 'Felfela Downtown',
        rating: 4.4,
        reviews: 1203,
        imageUrl:
            'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=800',
        address: 'Hoda Sharawy St, Downtown Cairo, Egypt',
        tags: ['Egyptian', 'Traditional', 'Falafel'],
        latitude: 30.0444,
        longitude: 31.2357,
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
      print('✅ Added restaurant: ${r.name}');
    }

    // 2. Seed Egyptian Food Items
    final foodItems = [
      FoodItem(
        id: 'f1',
        restaurantId: 'r1',
        restaurantName: 'El Shabrawy Port Said',
        name: 'Grilled Kebab Box',
        price: 45.00,
        originalPrice: 90.00,
        quantity: 5,
        pickupTime: '8:00 PM - 10:00 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=800',
        allergens: ['Gluten'],
      ),
      FoodItem(
        id: 'f2',
        restaurantId: 'r2',
        restaurantName: 'Fish Market Port Fouad',
        name: 'Fresh Seafood Platter',
        price: 65.00,
        originalPrice: 130.00,
        quantity: 3,
        pickupTime: '9:00 PM - 10:30 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=800',
        allergens: ['Fish', 'Shellfish'],
      ),
      FoodItem(
        id: 'f3',
        restaurantId: 'r3',
        restaurantName: 'Al Ahram Restaurant',
        name: 'Mixed Grill Surprise',
        price: 55.00,
        originalPrice: 110.00,
        quantity: 4,
        pickupTime: '7:30 PM - 9:30 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=800',
        allergens: [],
      ),
      FoodItem(
        id: 'f4',
        restaurantId: 'r6',
        restaurantName: 'Zooba Heliopolis',
        name: 'Street Food Box',
        price: 35.00,
        originalPrice: 70.00,
        quantity: 6,
        pickupTime: '8:00 PM - 11:00 PM',
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
        allergens: ['Gluten', 'Sesame'],
      ),
      FoodItem(
        id: 'f5',
        restaurantId: 'r9',
        restaurantName: 'Mori Sushi Mall of Arabia',
        name: 'Sushi Platter',
        price: 80.00,
        originalPrice: 200.00,
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
      print('✅ Added food item: ${f.name}');
    }

    // 3. Seed Egyptian Charities
    final charities = [
      Charity(
        id: 'c1',
        name: 'Egyptian Food Bank',
        description:
            'Fighting hunger across Egypt by providing meals to families in need.',
        imageUrl:
            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800',
        impactGoal: 50000,
        currentImpact: 23450,
      ),
      Charity(
        id: 'c2',
        name: 'Resala Charity',
        description:
            'Providing food, shelter, and support to underprivileged communities in Egypt.',
        imageUrl:
            'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=800',
        impactGoal: 30000,
        currentImpact: 15600,
      ),
      Charity(
        id: 'c3',
        name: 'Misr El Kheir Foundation',
        description:
            'Comprehensive development programs including food security for Egyptian families.',
        imageUrl:
            'https://images.unsplash.com/photo-1509099836639-18ba1795216d?w=800',
        impactGoal: 100000,
        currentImpact: 67800,
      ),
    ];

    for (var c in charities) {
      await firestore
          .collection('charities')
          .doc(c.id)
          .set(c.toFirestore())
          .timeout(const Duration(seconds: 5));
      print('✅ Added charity: ${c.name}');
    }

    _hasSeeded = true;
    print('🇪🇬 Database seeded successfully with Egyptian data!');
  }
}
