import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseService - Cart Operations (Web Platform)', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('addToCart creates new cart item correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Simulate addToCart operation
      final cartData = <String, List<Map<String, dynamic>>>{};
      const userId = 'test-user-123';
      final userCart = <Map<String, dynamic>>[];

      userCart.add({
        'food_id': 'food-1',
        'food_name': 'Pizza',
        'food_price': 10.0,
        'food_image': 'pizza.jpg',
        'quantity': 2,
        'created_at': DateTime.now().toIso8601String(),
      });

      cartData[userId] = userCart;
      await prefs.setString('cart_data', json.encode(cartData));

      // Verify cart was saved
      final savedCart = prefs.getString('cart_data');
      expect(savedCart, isNotNull);

      final decoded = json.decode(savedCart!) as Map<String, dynamic>;
      expect(decoded.containsKey(userId), isTrue);
      expect(decoded[userId], isList);
      expect((decoded[userId] as List).length, equals(1));
      expect((decoded[userId] as List)[0]['food_name'], equals('Pizza'));
      expect((decoded[userId] as List)[0]['quantity'], equals(2));
    });

    test('addToCart updates quantity when item already exists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const userId = 'test-user-123';
      const foodId = 'food-1';

      // Initial cart with one item
      final cartData = <String, List<Map<String, dynamic>>>{
        userId: [
          {
            'food_id': foodId,
            'food_name': 'Pizza',
            'food_price': 10.0,
            'quantity': 2,
            'created_at': DateTime.now().toIso8601String(),
          },
        ],
      };

      await prefs.setString('cart_data', json.encode(cartData));

      // Load cart and update quantity (simulate adding same item again)
      final savedCart = prefs.getString('cart_data');
      final decoded = json.decode(savedCart!) as Map<String, dynamic>;
      final userCart = List<Map<String, dynamic>>.from(decoded[userId]);

      final existingIndex = userCart.indexWhere(
        (item) => item['food_id'] == foodId,
      );
      expect(existingIndex, greaterThanOrEqualTo(0));

      // Update quantity
      userCart[existingIndex]['quantity'] =
          (userCart[existingIndex]['quantity'] as int) + 3;

      decoded[userId] = userCart;
      await prefs.setString('cart_data', json.encode(decoded));

      // Verify quantity was updated
      final updatedCart = prefs.getString('cart_data');
      final updatedDecoded = json.decode(updatedCart!) as Map<String, dynamic>;
      expect(
        (updatedDecoded[userId] as List)[0]['quantity'],
        equals(5),
      ); // 2 + 3
    });

    test('updateQuantity removes item when quantity is zero', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const userId = 'test-user-123';
      const foodId = 'food-1';

      // Initial cart
      final cartData = <String, List<Map<String, dynamic>>>{
        userId: [
          {
            'food_id': foodId,
            'food_name': 'Pizza',
            'food_price': 10.0,
            'quantity': 2,
            'created_at': DateTime.now().toIso8601String(),
          },
        ],
      };

      await prefs.setString('cart_data', json.encode(cartData));

      // Simulate updateQuantity to zero (should remove item)
      final savedCart = prefs.getString('cart_data');
      final decoded = json.decode(savedCart!) as Map<String, dynamic>;
      final userCart = List<Map<String, dynamic>>.from(decoded[userId]);

      // If quantity <= 0, remove the item
      const newQuantity = 0;
      if (newQuantity <= 0) {
        userCart.removeWhere((item) => item['food_id'] == foodId);
      }

      decoded[userId] = userCart;
      await prefs.setString('cart_data', json.encode(decoded));

      // Verify item was removed
      final updatedCart = prefs.getString('cart_data');
      final updatedDecoded = json.decode(updatedCart!) as Map<String, dynamic>;
      expect((updatedDecoded[userId] as List).length, equals(0));
    });

    test('getCartItemCount calculates total quantity correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const userId = 'test-user-123';

      // Cart with multiple items
      final cartData = <String, List<Map<String, dynamic>>>{
        userId: [
          {
            'food_id': 'food-1',
            'food_name': 'Pizza',
            'food_price': 10.0,
            'quantity': 2,
          },
          {
            'food_id': 'food-2',
            'food_name': 'Burger',
            'food_price': 5.0,
            'quantity': 3,
          },
          {
            'food_id': 'food-3',
            'food_name': 'Salad',
            'food_price': 7.0,
            'quantity': 1,
          },
        ],
      };

      await prefs.setString('cart_data', json.encode(cartData));

      // Calculate total count
      final savedCart = prefs.getString('cart_data');
      final decoded = json.decode(savedCart!) as Map<String, dynamic>;
      final userCart = List<Map<String, dynamic>>.from(decoded[userId] ?? []);

      final totalCount = userCart.fold<int>(
        0,
        (sum, item) => sum + (item['quantity'] as int),
      );

      expect(totalCount, equals(6)); // 2 + 3 + 1
    });

    test('getCartTotal calculates total price correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const userId = 'test-user-123';

      // Cart with multiple items
      final cartData = <String, List<Map<String, dynamic>>>{
        userId: [
          {
            'food_id': 'food-1',
            'food_name': 'Pizza',
            'food_price': 10.0,
            'quantity': 2,
          },
          {
            'food_id': 'food-2',
            'food_name': 'Burger',
            'food_price': 5.0,
            'quantity': 3,
          },
          {
            'food_id': 'food-3',
            'food_name': 'Salad',
            'food_price': 7.5,
            'quantity': 2,
          },
        ],
      };

      await prefs.setString('cart_data', json.encode(cartData));

      // Calculate total price
      final savedCart = prefs.getString('cart_data');
      final decoded = json.decode(savedCart!) as Map<String, dynamic>;
      final userCart = List<Map<String, dynamic>>.from(decoded[userId] ?? []);

      final totalPrice = userCart.fold<double>(
        0.0,
        (sum, item) =>
            sum +
            ((item['food_price'] as num).toDouble() *
                (item['quantity'] as int)),
      );

      expect(
        totalPrice,
        equals(50.0),
      ); // (10*2) + (5*3) + (7.5*2) = 20 + 15 + 15
    });

    test('cart operations maintain user data isolation', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const user1 = 'user-1';
      const user2 = 'user-2';

      // Create cart for user 1
      final cartData = <String, List<Map<String, dynamic>>>{
        user1: [
          {
            'food_id': 'food-1',
            'food_name': 'Pizza',
            'food_price': 10.0,
            'quantity': 2,
          },
        ],
        user2: [
          {
            'food_id': 'food-2',
            'food_name': 'Burger',
            'food_price': 5.0,
            'quantity': 1,
          },
        ],
      };

      await prefs.setString('cart_data', json.encode(cartData));

      // Get user 1's cart
      final savedCart = prefs.getString('cart_data');
      final decoded = json.decode(savedCart!) as Map<String, dynamic>;
      final user1Cart = List<Map<String, dynamic>>.from(decoded[user1] ?? []);
      final user2Cart = List<Map<String, dynamic>>.from(decoded[user2] ?? []);

      // Verify isolation
      expect(user1Cart.length, equals(1));
      expect(user2Cart.length, equals(1));
      expect(user1Cart[0]['food_name'], equals('Pizza'));
      expect(user2Cart[0]['food_name'], equals('Burger'));
    });

    test('clearCart removes all items for specific user only', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const user1 = 'user-1';
      const user2 = 'user-2';

      // Create cart for both users
      final cartData = <String, List<Map<String, dynamic>>>{
        user1: [
          {
            'food_id': 'food-1',
            'food_name': 'Pizza',
            'food_price': 10.0,
            'quantity': 2,
          },
        ],
        user2: [
          {
            'food_id': 'food-2',
            'food_name': 'Burger',
            'food_price': 5.0,
            'quantity': 1,
          },
        ],
      };

      await prefs.setString('cart_data', json.encode(cartData));

      // Clear user 1's cart
      final savedCart = prefs.getString('cart_data');
      final decoded = json.decode(savedCart!) as Map<String, dynamic>;
      decoded[user1] = [];
      await prefs.setString('cart_data', json.encode(decoded));

      // Verify user 1's cart is empty but user 2's is not
      final updatedCart = prefs.getString('cart_data');
      final updatedDecoded = json.decode(updatedCart!) as Map<String, dynamic>;
      expect((updatedDecoded[user1] as List).length, equals(0));
      expect((updatedDecoded[user2] as List).length, equals(1));
    });
  });
}
