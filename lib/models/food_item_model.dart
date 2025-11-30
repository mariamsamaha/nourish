import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String restaurantId;
  final String name;
  final double price;
  final double originalPrice;
  final int quantity;
  final String pickupTime;
  final String imageUrl;
  final List<String> allergens;
  final String? restaurantName;

  FoodItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    required this.pickupTime,
    required this.imageUrl,
    required this.allergens,
    this.restaurantName,
  });

  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodItem(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
      pickupTime: data['pickupTime'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      allergens: List<String>.from(data['allergens'] ?? []),
      restaurantName: data['restaurantName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'pickupTime': pickupTime,
      'imageUrl': imageUrl,
      'allergens': allergens,
      if (restaurantName != null) 'restaurantName': restaurantName,
    };
  }
}
