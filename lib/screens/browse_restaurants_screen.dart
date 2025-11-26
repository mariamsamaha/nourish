import 'package:flutter/material.dart';
import 'package:proj/routes/app_routes.dart';

class BrowseRestaurantsScreen extends StatefulWidget {
  const BrowseRestaurantsScreen({super.key});
  @override
  State<BrowseRestaurantsScreen> createState() => _BrowseRestaurantsScreenState();
}

class _BrowseRestaurantsScreenState extends State<BrowseRestaurantsScreen> {
  int _selectedTab = 0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Browse',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filters coming soon!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            icon: const Icon(Icons.tune, color: Color(0xFF1B5E20)),
            label: const Text(
              'Filters',
              style: TextStyle(
                color: Color(0xFF1B5E20),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tab selector
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTab('Nearby', 0),
                _buildTab('Pick-up', 1),
                _buildTab('Delivery', 2),
              ],
            ),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Map view coming soon!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            icon: const Icon(Icons.location_on_outlined, color: Color(0xFF1B5E20)),
            label: const Text(
              'View on Map',
              style: TextStyle(
                color: Color(0xFF1B5E20),
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(height: 16),

          _buildRestaurantCard(
            '3 items available',
            'Bascota Bakery',
            4.9,
            234,
            0.3,
            ['Bakery', 'Pastries'],
            'Pick up today 7-9 PM',
            'https://images.unsplash.com/photo-1523983309556-cff6b2c2de27?w=800',
          ),
          const SizedBox(height: 16),

          _buildRestaurantCard(
            '5 items available',
            'Koffe Kulture',
            4.7,
            189,
            0.5,
            ['Drinks', 'Coffee'],
            'Pick up today 6-10 PM',
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
          ),
          const SizedBox(height: 16),

          _buildRestaurantCard(
            '8 items available',
            'Sushimi By K',
            4.8,
            512,
            0.7,
            ['Japanese', 'Sushi'],
            'Pick up today 5-11 PM',
            'https://images.unsplash.com/photo-1553621042-f6e147245754?w=800',
          ),
          const SizedBox(height: 16),

          _buildRestaurantCard(
            '2 items available',
            'Pizza House',
            4.9,
            378,
            1.2,
            ['Italian', 'Pizza'],
            'Pick up today 6-9 PM',
            'https://images.unsplash.com/photo-1601924582975-7aa6d1b43c33?w=800',
          ),
          const SizedBox(height: 16),

          _buildRestaurantCard(
            '6 items available',
            'Crave',
            4.6,
            421,
            0.4,
            ['American', 'Burgers'],
            'Pick up today 11 AM-10 PM',
            'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800',
          ),
          const SizedBox(height: 16),

          _buildRestaurantCard(
            '4 items available',
            'Thai Spice',
            4.8,
            267,
            0.9,
            ['Thai', 'Asian'],
            'Pick up today 5-9 PM',
            'https://images.unsplash.com/photo-1604909052714-29db4a1d2cb5?w=800',
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1B5E20) : Colors.black,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
    String availability,
    String name,
    double rating,
    int reviews,
    double distance,
    List<String> tags,
    String pickupTime,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.restaurantDetail,
          arguments: {
            'name': name,
            'rating': rating,
            'reviews': reviews,
            'tags': tags,
            'image': imageUrl,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFA5D6A7).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.restaurant, size: 80, color: Color(0xFF4CAF50)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        availability,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($reviews)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Text(
                        '  •  $distance mi',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFA5D6A7).withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFFE8F5E9).withOpacity(0.5),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 4),
                      Text(
                        pickupTime,
                        style: const TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
