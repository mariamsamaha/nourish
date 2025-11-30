import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String name;
  final double rating;
  final int reviews;
  final String imageUrl;
  final String address;
  final List<String> tags;
  final double latitude;
  final double longitude;
  final bool hasDelivery;
  final bool hasPickup;

  Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.address,
    required this.tags,
    required this.latitude,
    required this.longitude,
    this.hasDelivery = false,
    this.hasPickup = true,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      address: data['address'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      hasDelivery: data['hasDelivery'] ?? false,
      hasPickup: data['hasPickup'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'rating': rating,
      'reviews': reviews,
      'imageUrl': imageUrl,
      'address': address,
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
      'hasDelivery': hasDelivery,
      'hasPickup': hasPickup,
    };
  }
}
