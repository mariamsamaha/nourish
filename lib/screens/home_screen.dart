import 'package:flutter/material.dart';
import 'package:proj/widgets/custom_bottom_nav_bar.dart';
import 'package:proj/widgets/home_app_bar.dart';
import 'package:proj/widgets/impact_card.dart';
import 'package:proj/widgets/offer_card.dart';
import 'package:proj/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Handle navigation for Browse tab
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.browseRestaurants);
    }
    if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.charity);
    }
    if (index == 4) {
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
                          decoration: InputDecoration(
                            hintText: "Search for food or restaurants...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Impact Card
                    const ImpactCard(),

                    const SizedBox(height: 24),

                    // "Available Now" Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Available Now",
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

                    // Offer Cards List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          OfferCard(
                            title: "Bakery Surprise Bag",
                            storeName: "Artisan Bakery",
                            distance: "0.3 mi",
                            originalPrice: "\$15.00",
                            discountedPrice: "\$4.99",
                            pickupTime: "7-9 PM",
                            quantityLeft: "3 left",
                            imageColor: Colors.orange.shade400,
                            icon: Icons.bakery_dining,
                            discountPercent: "67% OFF",
                          ),
                          OfferCard(
                            title: "Gourmet Pizza Box",
                            storeName: "Bella Italia",
                            distance: "0.5 mi",
                            originalPrice: "\$25.00",
                            discountedPrice: "\$8.99",
                            pickupTime: "8-10 PM",
                            quantityLeft: "5 left",
                            imageColor: Colors.red.shade400,
                            icon: Icons.local_pizza,
                            discountPercent: "64% OFF",
                          ),
                          OfferCard(
                            title: "Sushi Combo Pack",
                            storeName: "Tokyo Express",
                            distance: "1.2 mi",
                            originalPrice: "\$35.00",
                            discountedPrice: "\$12.99",
                            pickupTime: "9-10 PM",
                            quantityLeft: "2 left",
                            imageColor: Colors.blue.shade400,
                            icon: Icons.set_meal,
                            discountPercent: "63% OFF",
                          ),
                        ],
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
    );
  }
}
