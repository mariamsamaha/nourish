import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj/routes/app_routes.dart';
import 'package:proj/services/firestore_service.dart';
import 'package:proj/models/food_item_model.dart';
import 'package:proj/services/database_service.dart';
import 'package:proj/services/auth_service.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  static const _green = Color(0xFF1B5E20);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _mediumGreen = Color(0xFF4CAF50);

  final DatabaseService _dbService = DatabaseService();
  bool _isFavorited = false;
  String? _userId;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadFavoriteStatus();
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final String restaurantId = args?['id'] ?? 'r1';

    final authService = Provider.of<AuthService>(context, listen: false);
    _userId = await authService.getStoredUserId();

    if (_userId != null) {
      final isFav = await _dbService.isRestaurantFavorited(
        userId: _userId!,
        restaurantId: restaurantId,
      );
      setState(() {
        _isFavorited = isFav;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null) return;

    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final String restaurantId = args?['id'] ?? 'r1';
    final String name = args?['name'] ?? 'Restaurant';
    final double rating = (args?['rating'] ?? 0.0).toDouble();
    final int reviews = args?['reviews'] ?? 0;
    final List tags = args?['tags'] ?? [];
    final String image = args?['image'] ?? '';

    setState(() {
      _isFavorited = !_isFavorited;
    });

    if (_isFavorited) {
      await _dbService.addFavoriteRestaurant(
        userId: _userId!,
        restaurantId: restaurantId,
        restaurantName: name,
        restaurantImage: image,
        restaurantRating: rating,
        restaurantReviews: reviews,
        restaurantTags: tags.map((t) => t.toString()).toList(),
      );
      if (mounted) {
        _showSnack(context, 'Added to favorites!');
      }
    } else {
      await _dbService.removeFavoriteRestaurant(
        userId: _userId!,
        restaurantId: restaurantId,
      );
      if (mounted) {
        _showSnack(context, 'Removed from favorites');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;

    final String restaurantId = args?['id'] ?? 'r1';
    final String name = args?['name'] ?? 'Restaurant';
    final double rating = (args?['rating'] ?? 0.0).toDouble();
    final int reviews = args?['reviews'] ?? 0;
    final List tags = args?['tags'] ?? [];
    final String image =
        args?['image'] ??
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context, image),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRestaurantInfo(
                  name: name,
                  rating: rating,
                  reviews: reviews,
                  tags: tags,
                ),
                const SizedBox(height: 32),
                _buildSection(
                  'About',
                  'Family-owned artisan bakery serving fresh bread, pastries, and cakes since 1995. We believe in quality ingredients and traditional baking methods.',
                ),
                const SizedBox(height: 32),
                const Text(
                  'Available Items',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _green,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          StreamBuilder<List<FoodItem>>(
            stream: Provider.of<FirestoreService>(
              context,
            ).getFoodItemsByRestaurant(restaurantId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading menu: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No items available right now.'),
                );
              }

              return Column(
                children: items.map((item) {
                  final discount =
                      ((item.originalPrice - item.price) /
                              item.originalPrice *
                              100)
                          .round();
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                      left: 24,
                      right: 24,
                    ),
                    child: _itemCard(item, discount, context),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String image) {
    return Stack(
      children: [
        Image.network(
          image,
          height: 400,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 400,
            color: _lightGreen,
            child: const Icon(Icons.restaurant, size: 100, color: _mediumGreen),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconButton(
                  Icons.arrow_back,
                  () => Navigator.pop(context),
                  false,
                ),
                _iconButton(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  _toggleFavorite,
                  _isFavorited,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo({
    required String name,
    required double rating,
    required int reviews,
    required List tags,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _green,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              '$rating ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _green,
              ),
            ),
            Text(
              '($reviews reviews)',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _infoRow(
          Icons.location_on_outlined,
          '123 Main Street, San Francisco, CA',
        ),
        const SizedBox(height: 12),
        _infoRow(Icons.access_time, 'Open today: 7:00 AM - 9:00 PM'),
        const SizedBox(height: 12),
        _infoRow(Icons.phone_outlined, '(415) 555-0123'),
        const SizedBox(height: 20),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((t) => _tag(t.toString())).toList(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _green,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _itemCard(FoodItem item, int discount, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _mediumGreen.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.bakery_dining,
                  size: 50,
                  color: _mediumGreen,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delicious surprise bag',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: _mediumGreen,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${item.originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _mediumGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$discount% off',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pick up: ${item.pickupTime}',
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.foodDetails,
                arguments: {
                  'name': item.name,
                  'price': item.price,
                  'originalPrice': item.originalPrice,
                  'quantity': item.quantity,
                  'pickupTime': item.pickupTime,
                  'imageUrl': item.imageUrl,
                  'allergens': item.allergens,
                },
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: item.quantity > 0
                    ? _mediumGreen
                    : Colors.white,
                foregroundColor: item.quantity > 0
                    ? Colors.white
                    : _mediumGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: item.quantity > 0
                      ? BorderSide.none
                      : const BorderSide(color: _mediumGreen, width: 2),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, bool isFavorite) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 24, color: isFavorite ? Colors.red : _green),
        ),
      );

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[700], fontSize: 15),
        ),
      ),
    ],
  );

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFA5D6A7).withOpacity(0.5)),
      borderRadius: BorderRadius.circular(20),
      color: _lightGreen.withOpacity(0.5),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
    ),
  );

  void _showSnack(BuildContext context, String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _mediumGreen));
}
