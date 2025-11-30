import 'package:cloud_firestore/cloud_firestore.dart';

class Charity {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double impactGoal;
  final double currentImpact;

  Charity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.impactGoal,
    required this.currentImpact,
  });

  factory Charity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Charity(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      impactGoal: (data['impactGoal'] ?? 0.0).toDouble(),
      currentImpact: (data['currentImpact'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'impactGoal': impactGoal,
      'currentImpact': currentImpact,
    };
  }
}
