import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj/routes/app_routes.dart';
import 'package:proj/widgets/custom_bottom_nav_bar.dart';
import 'package:proj/services/firestore_service.dart';
import 'package:proj/models/restaurant_model.dart';

class BrowseRestaurantsScreen extends StatefulWidget {
  const BrowseRestaurantsScreen({super.key});
  @override
  State<BrowseRestaurantsScreen> createState() => _BrowseRestaurantsScreenState();
}

class _BrowseRestaurantsScreenState extends State<BrowseRestaurantsScreen> {
  int _selectedTab = 0;
  int _currentIndex = 1; // Browse is index 1
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return; // Already on this screen
    
    setState(() {
      _currentIndex = index;
    });

    // Navigate to other screens
    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.home);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.charity);
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Match home screen
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Browse',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search restaurants...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
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
              ],
            ),
          ),
          
          // Real Data from Firestore
          Expanded(
            child: StreamBuilder<List<Restaurant>>(
              stream: _selectedTab == 0
                  ? Provider.of<FirestoreService>(context).getRestaurants()
                  : _selectedTab == 1
                      ? Provider.of<FirestoreService>(context).getRestaurantsFiltered(hasPickup: true)
                      : Provider.of<FirestoreService>(context).getRestaurantsFiltered(hasDelivery: true),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final restaurants = snapshot.data ?? [];

                // Filter restaurants based on search query
                final filteredRestaurants = _searchQuery.isEmpty
                    ? restaurants
                    : restaurants.where((restaurant) {
                        return restaurant.name.toLowerCase().contains(_searchQuery) ||
                               restaurant.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
                      }).toList();

                if (filteredRestaurants.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No restaurants found.'),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = filteredRestaurants[index];
                    return Column(
                      children: [
                        _buildRestaurantCard(
                          restaurant.id,
                          'Available',
                          restaurant.name,
                          restaurant.rating,
                          restaurant.reviews,
                          0.5,
                          restaurant.tags,
                          'Pick up today',
                          restaurant.imageUrl,
                          restaurant.hasDelivery,
                          restaurant.hasPickup,
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
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
    String id,
    String availability,
    String name,
    double rating,
    int reviews,
    double distance,
    List<String> tags,
    String pickupTime,
    String imageUrl,
    bool hasDelivery,
    bool hasPickup,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.restaurantDetail,
          arguments: {
            'id': id,
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
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.vertical(
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
                  // Delivery/Pickup Badges
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        if (hasPickup)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.shopping_bag, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Pickup',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        if (hasPickup && hasDelivery) const SizedBox(width: 8),
                        if (hasDelivery)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.delivery_dining, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Delivery',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
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
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${distance.toStringAsFixed(1)} mi',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: Color(0xFF4CAF50), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        pickupTime,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
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
