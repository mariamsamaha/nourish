import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj/widgets/custom_bottom_nav_bar.dart';
import 'package:proj/widgets/home_app_bar.dart';
import 'package:proj/widgets/offer_card.dart';
import 'package:proj/routes/app_routes.dart';
import 'package:proj/services/firestore_service.dart';
import 'package:proj/models/food_item_model.dart';
import 'package:proj/utils/update_restaurants_egypt.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation for Browse tab
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.browseRestaurants);
    }
    if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.charity);
    }
    if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top Bar
            const HomeAppBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
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
                            hintText: "Search for food or restaurants...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // "Available Now" Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Best Offers",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "See all",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Offer Cards List (Best Offers - Highest Discounts)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: StreamBuilder<List<FoodItem>>(
                        stream: Provider.of<FirestoreService>(
                          context,
                        ).getBestOffers(limit: 5),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final foodItems = snapshot.data ?? [];

                          // Filter food items based on search query
                          final filteredItems = _searchQuery.isEmpty
                              ? foodItems
                              : foodItems.where((item) {
                                  return item.name.toLowerCase().contains(
                                        _searchQuery,
                                      ) ||
                                      (item.restaurantName
                                              ?.toLowerCase()
                                              .contains(_searchQuery) ??
                                          false);
                                }).toList();

                          if (filteredItems.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'No surprise bags available right now.',
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: filteredItems.map((item) {
                              // Calculate discount percent
                              final discount =
                                  ((item.originalPrice - item.price) /
                                          item.originalPrice *
                                          100)
                                      .round();

                              return OfferCard(
                                title: item.name,
                                storeName: item.restaurantName ?? "Restaurant",
                                distance: "0.5 mi", // TODO: Calculate distance
                                originalPrice:
                                    "\$${item.originalPrice.toStringAsFixed(2)}",
                                discountedPrice:
                                    "\$${item.price.toStringAsFixed(2)}",
                                pickupTime: item.pickupTime,
                                quantityLeft: "${item.quantity} left",
                                imageColor:
                                    Colors.orange.shade400, // Placeholder
                                icon: Icons.bakery_dining, // Placeholder
                                discountPercent: "$discount% OFF",
                                restaurantId: item.restaurantId,
                                restaurantName: item.restaurantName,
                                foodItemData: {
                                  'id': item.id,
                                  'name': item.name,
                                  'price': item.price,
                                  'originalPrice': item.originalPrice,
                                  'quantity': item.quantity,
                                  'pickupTime': item.pickupTime,
                                  'imageUrl': item.imageUrl,
                                  'allergens': item.allergens,
                                  'restaurantId': item.restaurantId,
                                  'restaurantName': item.restaurantName,
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      // TEMPORARY: Fix button to update restaurants to Egypt
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => updateRestaurantsToEgypt(context),
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.location_city),
        label: const Text('Fix Egypt Locations'),
      ),
    );
  }
}
