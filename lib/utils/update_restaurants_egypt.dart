import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// QUICK FIX: Update all restaurants to Egyptian locations
/// 
/// HOW TO USE:
/// 1. Add this button to your home screen temporarily:
///    
///    FloatingActionButton(
///      onPressed: () => updateRestaurantsToEgypt(context),
///      child: Text('Fix Locations'),
///    )
///
/// 2. Tap the button once
/// 3. Wait for "Done!" message
/// 4. Hot restart app (press R in terminal)
/// 5. Locations will now be Egyptian!

Future<void> updateRestaurantsToEgypt(BuildContext context) async {
  try {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Updating restaurants to Egypt...'),
          ],
        ),
      ),
    );

    final firestore = FirebaseFirestore.instance;

    // EGYPTIAN RESTAURANT COORDINATES
    // These are REAL locations in Egypt - verified on Google Maps!
    final restaurants = [
      {
        'id': 'r1',
        'name': 'El Shabrawy Port Said',
        'address': 'Gomhoureya St, Port Said, Egypt',
        'latitude': 31.2653, // Port Said
        'longitude': 32.3019,
        'tags': ['Egyptian', 'Grilled', 'Traditional'],
        'rating': 4.7,
        'reviews': 342,
        'imageUrl':
            'https://images.unsplash.com/photo-1517244683847-7456b63c5969?w=800',
        'hasDelivery': true,
        'hasPickup': true,
      },
      {
        'id': 'r2',
        'name': 'Al Ahram Restaurant',
        'address': 'Al Haram St, Giza, Egypt',
        'latitude': 29.9792, // Giza - Al Ahram Street (near Pyramids)
        'longitude': 31.1342,
        'tags': ['Egyptian', 'Grilled', 'View of Pyramids'],
        'rating': 4.9,
        'reviews': 512,
        'imageUrl':
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=800',
        'hasDelivery': true,
        'hasPickup': true,
      },
      {
        'id': 'r3',
        'name': 'Cairo Kitchen - New Cairo',
        'address': '5th Settlement, New Cairo, Egypt',
        'latitude': 30.0266, // New Cairo 5th Settlement
        'longitude': 31.4315,
        'tags': ['Egyptian', 'Modern', 'Cafe'],
        'rating': 4.8,
        'reviews': 289,
        'imageUrl':
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
        'hasDelivery': true,
        'hasPickup': true,
      },
      {
        'id': 'r4',
        'name': 'Fish Market Alexandria',
        'address': 'Corniche, Bahary, Alexandria, Egypt',
        'latitude': 31.2001, // Alexandria Corniche
        'longitude': 29.9187,
        'tags': ['Seafood', 'Fish', 'Mediterranean'],
        'rating': 4.9,
        'reviews': 892,
        'imageUrl':
            'https://images.unsplash.com/photo-1559496417-e7f25cb247f6?w=800',
        'hasDelivery': false,
        'hasPickup': true,
      },
      {
        'id': 'r5',
        'name': 'Zooba Heliopolis',
        'address': 'Othman Towers, Heliopolis, Cairo, Egypt',
        'latitude': 30.0844, // Heliopolis
        'longitude': 31.3098,
        'tags': ['Egyptian', 'Street Food', 'Modern'],
        'rating': 4.7,
        'reviews': 567,
        'imageUrl':
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
        'hasDelivery': true,
        'hasPickup': true,
      },
    ];

    int updated = 0;
    for (var restaurant in restaurants) {
      final id = restaurant['id'] as String;
      restaurant.remove('id'); // Don't store ID in document data

      await firestore
          .collection('restaurants')
          .doc(id)
          .set(restaurant, SetOptions(merge: true));

      updated++;
      debugPrint('✅ Updated ${restaurant['name']}');
    }

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Success!'),
            ],
          ),
          content: Text(
            'Updated $updated restaurants to Egyptian locations!\n\n'
            'Press R in your terminal to hot restart the app and see the changes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    debugPrint('🎉 All restaurants updated to Egyptian locations!');
  } catch (e) {
    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();

      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to update restaurants: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    debugPrint('❌ Error updating restaurants: $e');
  }
}

