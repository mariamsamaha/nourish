import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj/routes/app_routes.dart';
import 'package:proj/widgets/custom_bottom_nav_bar.dart';
import 'package:proj/services/firestore_service.dart';
import 'package:proj/models/restaurant_model.dart';
import 'package:proj/services/database_service.dart';
import 'package:proj/services/auth_service.dart';

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
  final DatabaseService _dbService = DatabaseService();
  Set<String> _favoritedRestaurantIds = {};
  String? _userId;
  bool _isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadUserFavorites();
  }

  Future<void> _loadUserFavorites() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    _userId = await authService.getStoredUserId();
    
    if (_userId != null) {
      final favorites = await _dbService.getFavoriteRestaurants(_userId!);
      setState(() {
        _favoritedRestaurantIds = favorites.map((f) => f['restaurant_id'] as String).toSet();
        _isLoadingFavorites = false;
      });
    } else {
      setState(() {
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> _toggleFavorite(Restaurant restaurant) async {
    if (_userId == null) return;

    setState(() {
      if (_favoritedRestaurantIds.contains(restaurant.id)) {
        _favoritedRestaurantIds.remove(restaurant.id);
      } else {
        _favoritedRestaurantIds.add(restaurant.id);
      }
    });

    if (_favoritedRestaurantIds.contains(restaurant.id)) {
      await _dbService.addFavoriteRestaurant(
        userId: _userId!,
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
        restaurantImage: restaurant.imageUrl,
        restaurantRating: restaurant.rating,
        restaurantReviews: restaurant.reviews,
        restaurantTags: restaurant.tags,
      );
    } else {
      await _dbService.removeFavoriteRestaurant(
        userId: _userId!,
        restaurantId: restaurant.id,
      );
    }
  }

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
              ]
              
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
                    final isFavorited = _favoritedRestaurantIds.contains(restaurant.id);
                    
                    return Column(
                      children: [
                        _buildRestaurantCard(
                          restaurant,
                          isFavorited,
                          0.5, // distance
                          'Pick up today',
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
    Restaurant restaurant,
    bool isFavorited,
    double distance,
    String pickupTime,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.restaurantDetail,
          arguments: {
            'id': restaurant.id,
            'name': restaurant.name,
            'rating': restaurant.rating,
            'reviews': restaurant.reviews,
            'tags': restaurant.tags,
            'image': restaurant.imageUrl,
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
                      restaurant.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.restaurant, size: 80, color: Color(0xFF4CAF50)),
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(restaurant),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.red : Colors.grey[700],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // Delivery/Pickup Badges
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        if (restaurant.hasPickup)
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
                        if (restaurant.hasPickup && restaurant.hasDelivery) const SizedBox(width: 8),
                        if (restaurant.hasDelivery)
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
                    restaurant.name,
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
                        '${restaurant.rating} (${restaurant.reviews})',
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
                    children: restaurant.tags.map((tag) {
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
