import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj/widgets/custom_bottom_nav_bar.dart';
import 'package:proj/routes/app_routes.dart';
import 'package:proj/services/firestore_service.dart';
import 'package:proj/models/charity_model.dart';

class CharityScreen extends StatefulWidget {
  const CharityScreen({super.key});

  @override
  State<CharityScreen> createState() => _CharityScreenState();
}

class _CharityScreenState extends State<CharityScreen> {
  int _currentIndex = 2; // Charity is index 2

  void _onNavTap(int index) {
    if (index == _currentIndex) return; // Already on this screen
    
    setState(() {
      _currentIndex = index;
    });

    // Navigate to other screens
    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.home);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.browseRestaurants);
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Match home screen
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
        
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    bottom: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Text(
                      'Support a Charity',
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.shade500,
                      Colors.orange.shade600,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Give Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Help feed those in need',
                              style: TextStyle(
                                color: Colors.orange.shade100,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Restaurants can donate surplus food directly to local charities. You can also round up your orders to support these organizations.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Charities',
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View all',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Real Data from Firestore
            StreamBuilder<List<Charity>>(
              stream: Provider.of<FirestoreService>(context).getCharities(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final charities = snapshot.data ?? [];

                if (charities.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No charities found.'),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final charity = charities[index];
                      // TODO: Check if this is the user's supported charity
                      final bool isSupported = index == 0; 
                      
                      return Column(
                        children: [
                          CharityCard(
                            name: charity.name,
                            location: 'Location', // TODO: Add location to model
                            tag: 'Charity', // TODO: Add tag to model
                            description: charity.description,
                            meals: charity.currentImpact.toInt().toString(),
                            highlight: isSupported,
                            highlightedColor: Colors.orange.shade600,
                            buttonLabel: isSupported ? 'Currently Supporting' : 'Select & Support',
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    childCount: charities.length,
                  ),
                );
              },
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
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

class CharityCard extends StatelessWidget {
  final String name;
  final String location;
  final String tag;
  final String description;
  final String meals;
  final bool highlight;
  final Color highlightedColor;
  final String buttonLabel;

  const CharityCard({
    super.key,
    required this.name,
    required this.location,
    required this.tag,
    required this.description,
    required this.meals,
    required this.highlight,
    required this.highlightedColor,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight ? highlightedColor.withOpacity(0.12) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: highlight
            ? BorderSide(color: highlightedColor, width: 2)
            : BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // TODO: Add Image.network(imageUrl) here
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (highlight)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: highlightedColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: Colors.grey),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),

            const Divider(),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meals donated this month',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  meals,
                  style: TextStyle(color: Colors.grey[900], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),

            highlight
                ? OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: highlightedColor),
                      foregroundColor: highlightedColor,
                    ),
                    child: Text(buttonLabel),
                  )
                : ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: highlightedColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(buttonLabel),
                  ),
          ],
        ),
      ),
    );
  }
}
