import 'package:flutter/material.dart';

class FoodDetailsScreen extends StatelessWidget {
  const FoodDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Extract arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final String name = args?['name'] ?? 'Surprise Bag';
    final double price = (args?['price'] ?? 4.99).toDouble();
    final double originalPrice = (args?['originalPrice'] ?? 15.00).toDouble();
    final int quantity = args?['quantity'] ?? 0;
    final String pickupTime = args?['pickupTime'] ?? 'Today';
    final String imageUrl = args?['imageUrl'] ?? '';
    
    final int discountPercent = ((originalPrice - price) / originalPrice * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Match home screen
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.02),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // Food Image/Icon
              Center(
                child: Container(
                  width: width * 0.3,
                  height: width * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? const Center(
                          child: Text(
                            '🥐',
                            style: TextStyle(fontSize: 80),
                          ),
                        )
                      : null,
                ),
              ),

              SizedBox(height: height * 0.02),

              // Content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Save badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Save $discountPercent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.015),

                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Text(
                          '\$${originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.015),

                    // Title
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),

                    SizedBox(height: height * 0.01),

                    // Restaurant name (Placeholder for now, could be passed in args)
                    Row(
                      children: [
                        const Text(
                          'Restaurant', 
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            const Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.02),

                    // Hot Deal badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🔥',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Hot Deal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.015),

                    // Stock info
                    Text(
                      '$quantity Left',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // Pick-up Time
                    _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Pick-up Time',
                      subtitle: pickupTime,
                      trailing: 'Today',
                    ),

                    SizedBox(height: height * 0.015),

                    // Distance
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Distance',
                      subtitle: '0.3 miles',
                      trailing: '3 min walk',
                    ),

                    SizedBox(height: height * 0.03),

                    // What's Inside
                    const Text(
                      "What's Inside",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    const Text(
                      "A delightful surprise selection of our artisan baked goods! May include fresh croissants, muffins, cookies, sourdough bread, and seasonal pastries. Everything is baked fresh today with organic ingredients.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2E7D32),
                        height: 1.5,
                      ),
                    ),


                    SizedBox(height: height * 0.03),

                    // Allergen Info
                    const Text(
                      'Allergen Info',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFA5D6A7).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildAllergenItem('🌾', 'Contains Gluten'),
                          const SizedBox(height: 12),
                          _buildAllergenItem('🥜', 'May contain Nuts'),
                          const SizedBox(height: 12),
                          _buildAllergenItem('🥛', 'Contains Dairy'),
                          const SizedBox(height: 12),
                          _buildAllergenItem('🥚', 'May contain Eggs'),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.065,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to cart or show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to cart!'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.03),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFA5D6A7).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergenItem(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }
}
