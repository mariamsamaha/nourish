import 'package:proj/models/restaurant_model.dart';
import 'package:proj/models/food_item_model.dart';
import 'package:proj/models/charity_model.dart';

/// Mock data service that provides hardcoded data for development
/// This allows developers to work without Firebase access
class MockDataService {
  // Mock Restaurants
  static final List<Restaurant> mockRestaurants = [
    Restaurant(
      id: 'r1',
      name: 'Artisan Bakery',
      rating: 4.8,
      reviews: 234,
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff',
      address: '123 Baker Street, Downtown',
      tags: ['Bakery', 'Pastries', 'Bread'],
      latitude: 37.7749,
      longitude: -122.4194,
      hasDelivery: false,
      hasPickup: true,
    ),
    Restaurant(
      id: 'r2',
      name: 'Green Leaf Salad Bar',
      rating: 4.5,
      reviews: 189,
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
      address: '456 Health Avenue, Midtown',
      tags: ['Healthy', 'Vegan', 'Salads'],
      latitude: 37.7849,
      longitude: -122.4094,
      hasDelivery: true,
      hasPickup: true,
    ),
    Restaurant(
      id: 'r3',
      name: 'Sushi Master',
      rating: 4.9,
      reviews: 567,
      imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351',
      address: '789 Ocean Drive, Waterfront',
      tags: ['Japanese', 'Sushi', 'Seafood'],
      latitude: 37.7649,
      longitude: -122.4294,
      hasDelivery: true,
      hasPickup: false,
    ),
  ];

  // Mock Food Items
  static final List<FoodItem> mockFoodItems = [
    FoodItem(
      id: 'f1',
      restaurantId: 'r1',
      restaurantName: 'Artisan Bakery',
      name: 'Surprise Bakery Bag',
      price: 4.99,
      originalPrice: 15.00,
      quantity: 5,
      pickupTime: '7:00 PM - 9:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff',
      allergens: ['Gluten', 'Eggs', 'Dairy'],
    ),
    FoodItem(
      id: 'f2',
      restaurantId: 'r2',
      restaurantName: 'Green Leaf Salad Bar',
      name: 'Fresh Salad Mix',
      price: 3.99,
      originalPrice: 12.00,
      quantity: 8,
      pickupTime: '6:00 PM - 8:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
      allergens: ['None'],
    ),
    FoodItem(
      id: 'f3',
      restaurantId: 'r3',
      restaurantName: 'Sushi Master',
      name: 'Sushi Surprise Box',
      price: 8.99,
      originalPrice: 25.00,
      quantity: 3,
      pickupTime: '8:00 PM - 10:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351',
      allergens: ['Fish', 'Soy', 'Sesame'],
    ),
    FoodItem(
      id: 'f4',
      restaurantId: 'r1',
      restaurantName: 'Artisan Bakery',
      name: 'Pastry Assortment',
      price: 5.99,
      originalPrice: 18.00,
      quantity: 4,
      pickupTime: '7:00 PM - 9:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff',
      allergens: ['Gluten', 'Eggs', 'Nuts'],
    ),
    FoodItem(
      id: 'f5',
      restaurantId: 'r2',
      restaurantName: 'Green Leaf Salad Bar',
      name: 'Vegan Buddha Bowl',
      price: 6.99,
      originalPrice: 16.00,
      quantity: 6,
      pickupTime: '6:00 PM - 8:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
      allergens: ['None'],
    ),
  ];

  // Mock Charities
  static final List<Charity> mockCharities = [
    Charity(
      id: 'c1',
      name: 'Feed the Children',
      description: 'Providing nutritious meals to children in need across the community.',
      imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c',
      impactGoal: 250000,
      currentImpact: 150000,
    ),
    Charity(
      id: 'c2',
      name: 'Ocean Cleanup Initiative',
      description: 'Reducing food waste and protecting our oceans through sustainable practices.',
      imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
      impactGoal: 120000,
      currentImpact: 75000,
    ),
  ];

  // Get all restaurants
  static Stream<List<Restaurant>> getRestaurants() {
    return Stream.value(mockRestaurants);
  }

  // Get restaurants filtered by delivery/pickup
  static Stream<List<Restaurant>> getRestaurantsFiltered({
    bool? hasDelivery,
    bool? hasPickup,
  }) {
    var filtered = mockRestaurants.where((restaurant) {
      bool matchesDelivery = hasDelivery == null || restaurant.hasDelivery == hasDelivery;
      bool matchesPickup = hasPickup == null || restaurant.hasPickup == hasPickup;
      return matchesDelivery && matchesPickup;
    }).toList();
    
    return Stream.value(filtered);
  }

  // Get restaurant by ID
  static Future<Restaurant?> getRestaurantById(String id) async {
    try {
      return mockRestaurants.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get available food items
  static Stream<List<FoodItem>> getAvailableFoodItems() {
    var available = mockFoodItems.where((item) => item.quantity > 0).toList();
    return Stream.value(available);
  }

  // Get best offers (sorted by discount percentage)
  static Stream<List<FoodItem>> getBestOffers({int limit = 10}) {
    var available = mockFoodItems.where((item) => item.quantity > 0).toList();
    
    // Sort by discount percentage (highest first)
    available.sort((a, b) {
      double discountA = ((a.originalPrice - a.price) / a.originalPrice) * 100;
      double discountB = ((b.originalPrice - b.price) / b.originalPrice) * 100;
      return discountB.compareTo(discountA);
    });
    
    return Stream.value(available.take(limit).toList());
  }

  // Get food items by restaurant
  static Stream<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId) {
    var items = mockFoodItems.where((item) => item.restaurantId == restaurantId).toList();
    return Stream.value(items);
  }

  // Get all charities
  static Stream<List<Charity>> getCharities() {
    return Stream.value(mockCharities);
  }
}
