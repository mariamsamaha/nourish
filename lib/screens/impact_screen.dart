
import 'package:flutter/material.dart';
import 'package:proj/widgets/custom_bottom_nav_bar.dart';
class ImpactScreen extends StatefulWidget {
  const ImpactScreen({super.key});
  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}
class _ImpactScreenState extends State<ImpactScreen> {
  final int _currentIndex = 2; // Impact is index 2
  void _onNavTap(int index) {
    if (index == 0) {
      // Navigate back to Home
      Navigator.pop(context);
    } else if (index == 2) {
      // Already on Impact screen, do nothing
      return;
    }
    // Handle other navigation items (Browse, Profile) if needed
    // For now, they won't do anything
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F4), // Light mint background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1B5E3B),
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Expanded(
                      child: Text(
                        'Your Impact',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E3B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance the back button
                  ],
                ),
              ),
              // 2. Main Impact Card
              _buildMainImpactCard(),
              const SizedBox(height: 20),
              // 3. Streak Card 
              _buildStreakCard(),
              const SizedBox(height: 20),
              // 4. November Goals Section
              _buildNovemberGoals(),
              const SizedBox(height: 20),
              // 5. Impact Breakdown Section
              _buildImpactBreakdown(),
              const SizedBox(height: 20),
              // 6. Achievements Section
              _buildAchievements(),
              const SizedBox(height: 20),
              // 7. Community Leaders Section
              _buildCommunityLeaders(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
  // Main Impact Card with green gradient
  Widget _buildMainImpactCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E3B), // Dark forest green
              Color(0xFF2E8B57), // Medium green
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative leaf icon
            Positioned(
              top: 20,
              right: 20,
              child: Icon(
                Icons.eco,
                size: 80,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  // Celebratory text
                  const Text(
                    "You're doing amazing! 🎉",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Large metric
                  const Text(
                    '127',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Meals Saved',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24), 
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CO₂ Prevented',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '89.2kg',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                                children: const [
                                                   Icon(
                                                      Icons.trending_up,
                                                      color: Colors.white,
                                                      size: 14,
                                                   ),
                                                   SizedBox(width: 4),
                                                   Text(
                                                      '+12% this month',
                                                      style: TextStyle(
                                                         color: Colors.white,
                                                         fontSize: 11,
                                                      ),
                                                   ),
                                                ],
                                             ),
                                          ],
                                       ),
                                    ),
                                 ),
                                 const SizedBox(width: 12),
                                 Expanded(
                                    child: Container(
                                       padding: const EdgeInsets.all(16),
                                       decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(16),
                                       ),
                                       child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                             const Text(
                                                'Money Saved',
                                                style: TextStyle(
                                                   color: Colors.white70,
                                                   fontSize: 12,
                                                ),
                                             ),
                                             const SizedBox(height: 8),
                                             const Text(
                                                '\$892',
                                                style: TextStyle(
                                                   color: Colors.white,
                                                   fontSize: 24,
                                                   fontWeight: FontWeight.bold,
                                                ),
                                             ),
                                             const SizedBox(height: 4),
                                             Row(
                                                children: const [
                                                   Icon(
                                                      Icons.trending_up,
                                                      color: Colors.white,
                                                      size: 14,
                                                   ),
                                                   SizedBox(width: 4),
                                                   Text(
                                                      '+18% this month',
                                                      style: TextStyle(
                                                         color: Colors.white,
                                                         fontSize: 11,
                                                      ),
                                                   ),
                                                ],
                                             ),
                                          ],
                                       ),
                                    ),
                                 ),
                              ],
                           ),
                           const SizedBox(height: 20),
                           // Share button
                           SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                 onPressed: () {},
                                 icon: const Icon(Icons.share, size: 20),
                                 label: const Text(
                                    'Share Your Impact',
                                    style: TextStyle(
                                       fontSize: 16,
                                       fontWeight: FontWeight.w600,
                                    ),
                                 ),
                                 style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1B5E3B),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                 ),
                              ),
                           ),
                        ],
                     ),
                  ),
               ],
            ),
         ),
      );
   }
   // Streak Card with orange gradient
   Widget _buildStreakCard() {
      return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0),
         child: Container(
            decoration: BoxDecoration(
               gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                     Color(0xFFFF6B35), // Orange
                     Color(0xFFFF8C42), // Coral
                  ],
               ),
               borderRadius: BorderRadius.circular(20),
               boxShadow: [
                  BoxShadow(
                     color: Colors.black.withOpacity(0.1),
                     blurRadius: 10,
                     offset: const Offset(0, 4),
                  ),
               ],
            ),
            child: Stack(
               children: [
                  // Fire icon decoration
                  Positioned(
                     top: 20,
                     right: 20,
                     child: Text(
                        '🔥',
                        style: TextStyle(
                           fontSize: 60,
                           color: Colors.white.withOpacity(0.3),
                        ),
                     ),
                  ),
                  Padding(
                     padding: const EdgeInsets.all(24.0),
                     child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           const Text(
                              'Current Streak',
                              style: TextStyle(
                                 color: Colors.white,
                                 fontSize: 16,
                                 fontWeight: FontWeight.w500,
                              ),
                           ),
                           const SizedBox(height: 8),
                           Row(
                              children: const [
                                 Text(
                                    '5',
                                    style: TextStyle(
                                       color: Colors.white,
                                       fontSize: 48,
                                       fontWeight: FontWeight.bold,
                                    ),
                                 ),
                                 SizedBox(width: 8),
                                 Text(
                                    'days',
                                    style: TextStyle(
                                       color: Colors.white,
                                       fontSize: 20,
                                       fontWeight: FontWeight.w500,
                                    ),
                                 ),
                              ],
                           ),
                           const SizedBox(height: 16),
                           // Progress bar
                           Container(
                              height: 8,
                              decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.3),
                                 borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                 alignment: Alignment.centerLeft,
                                 widthFactor: 5 / 7, // 5 out of 7 days
                                 child: Container(
                                    decoration: BoxDecoration(
                                       color: Colors.white,
                                       borderRadius: BorderRadius.circular(4),
                                    ),
                                 ),
                              ),
                           ),
                           const SizedBox(height: 12),
                           // Motivational text
                           const Text(
                              '2 more days to reach 7-day streak! 🎯',
                              style: TextStyle(
                                 color: Colors.white,
                                 fontSize: 14,
                                 fontWeight: FontWeight.w500,
                              ),
                           ),
                        ],
                     ),
                  ),
               ],
            ),
         ),
      );
   }
   // November Goals Section
   Widget _buildNovemberGoals() {
      return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0),
         child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(20),
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
                  // Header
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                        const Text(
                           'November Goals',
                           style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E3B),
                           ),
                        ),
                        Container(
                           padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                           ),
                           decoration: BoxDecoration(
                              color: const Color(0xFF2E8B57).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                           ),
                           child: const Text(
                              'On Track 🎯',
                              style: TextStyle(
                                 fontSize: 12,
                                 fontWeight: FontWeight.w600,
                                 color: Color(0xFF1B5E3B),
                              ),
                           ),
                        ),
                     ],
                  ),
                  const SizedBox(height: 20),
                  // Meals saved goal
                  Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: const [
                              Text(
                                 'Meals saved',
                                 style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                 ),
                              ),
                              Text(
                                 '12 / 20',
                                 style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E3B),
                                 ),
                              ),
                           ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                           borderRadius: BorderRadius.circular(4),
                           child: LinearProgressIndicator(
                              value: 12 / 20,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                 Color(0xFF2E8B57),
                              ),
                              minHeight: 8,
                           ),
                        ),
                     ],
                  ),
                  const SizedBox(height: 20),
                  // CO ‚‚ reduction goal
                  Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: const [
                              Text(
                                 'CO₂ reduction',
                                 style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                 ),
                              ),
                              Text(
                                 '8.4 / 15 kg',
                                 style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E3B),
                                 ),
                              ),
                           ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                           borderRadius: BorderRadius.circular(4),
                           child: LinearProgressIndicator(
                              value: 8.4 / 15,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                 Color(0xFF2E8B57),
                              ),
                              minHeight: 8,
                           ),
                        ),
                     ],
                  ),
               ],
            ),
         ),
      );
   }
   // Impact Breakdown Section
   Widget _buildImpactBreakdown() {
      return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
                  child: Text(
                     'Impact Breakdown',
                     style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E3B),
                     ),
                  ),
               ),
               _buildImpactCard(
                  icon: Icons.eco,
                  iconBgColor: const Color(0xFFD4F1E8),
                  iconColor: const Color(0xFF2E8B57),
                  label: 'Food Waste Prevented',
                  value: '152.4 kg',
               ),
               const SizedBox(height: 12),
               _buildImpactCard(
                  icon: Icons.water_drop,
                  iconBgColor: const Color(0xFFD6EAF8),
                  iconColor: const Color(0xFF3498DB),
                  label: 'Water Saved',
                  value: '3,048 L',
               ),
               const SizedBox(height: 12),
               _buildImpactCard(
                  icon: Icons.park,
                  iconBgColor: const Color(0xFFE8DAEF),
                  iconColor: const Color(0xFF9B59B6),
                  label: 'Equivalent Trees',
                  value: '4.2 trees',
               ),
            ],
         ),
      );
   }
   Widget _buildImpactCard({
      required IconData icon,
      required Color iconBgColor,
      required Color iconColor,
      required String label,
      required String value,
   }) {
      return Container(
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
               BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
               ),
            ],
         ),
         child: Row(
            children: [
               Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                     color: iconBgColor,
                     borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
               ),
               const SizedBox(width: 16),
               Expanded(
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text(
                           label,
                           style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                           ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                           value,
                           style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                           ),
                        ),
                     ],
                  ),
               ),
            ],
         ),
      );
   }
   // Achievements Section
   Widget _buildAchievements() {
      return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0),
         child: Column(
            children: [
               // Header
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     const Text(
                        'Achievements',
                        style: TextStyle(
                           fontSize: 20,
                           fontWeight: FontWeight.bold,
                           color: Color(0xFF1B5E3B),
                        ),
                     ),
                     GestureDetector(
                        onTap: () {},
                        child: const Text(
                           'View all',
                           style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E8B57),
                           ),
                        ),
                     ),
                  ],
               ),
               const SizedBox(height: 12),
               // Achievement badges
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                     _buildAchievementBadge(
                        emoji: '🏆',
                        label: 'First Saver',
                        bgColor: const Color(0xFFE8F5E9),
                     ),
                     _buildAchievementBadge(
                        emoji: '🌱',
                        label: 'Eco Warrior',
                        bgColor: const Color(0xFFD4F1E8),
                     ),
                     _buildAchievementBadge(
                        emoji: '💚',
                        label: 'Community Hero',
                        bgColor: const Color(0xFFD6EAF8),
                     ),
                  ],
               ),
            ],
         ),
      );
   }
   Widget _buildAchievementBadge({
      required String emoji,
      required String label,
      required Color bgColor,
   }) {
      return Container(
         width: 100,
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
               BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
               ),
            ],
         ),
         child: Column(
            children: [
               Text(emoji, style: const TextStyle(fontSize: 40)),
               const SizedBox(height: 8),
               Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                     fontSize: 12,
                     fontWeight: FontWeight.w600,
                     color: Colors.black87,
                  ),
               ),
            ],
         ),
      );
   }
   // Community Leaders Section
   Widget _buildCommunityLeaders() {
      return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0),
         child: Column(
            children: [
               // Header
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     const Text(
                        'Community Leaders',
                        style: TextStyle(
                           fontSize: 20,
                           fontWeight: FontWeight.bold,
                           color: Color(0xFF1B5E3B),
                        ),
                     ),
                     GestureDetector(
                        onTap: () {},
                        child: const Text(
                           'Full board',
                           style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E8B57),
                           ),
                        ),
                     ),
                  ],
               ),
               const SizedBox(height: 12),
               // Leaderboard entries
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
                  child: Column(
                     children: [
                        _buildLeaderboardEntry(
                           rank: '🥇',
                           name: 'Sarah M.',
                           meals: '234 meals',
                           isCurrentUser: false,
                           badge: null,
                        ),
                        const Divider(height: 1),
                        _buildLeaderboardEntry(
                           rank: '🥈',
                           name: 'Michael T.',
                           meals: '189 meals',
                           isCurrentUser: false,
                           badge: null,
                        ),
                        const Divider(height: 1),
                        _buildLeaderboardEntry(
                           rank: '🥉',
                           name: 'Jessica L.',
                           meals: '156 meals',
                           isCurrentUser: false,
                           badge: null,
                        ),
                        const Divider(height: 1),
                        _buildLeaderboardEntry(
                           rank: '15',
                           name: 'You',
                           meals: '127 meals',
                           isCurrentUser: true,
                           badge: 'Top 15%',
                        ),
                     ],
                  ),
               ),
            ],
         ),
      );
   }
   Widget _buildLeaderboardEntry({
      required String rank,
      required String name,
      required String meals,
      required bool isCurrentUser,
      required String? badge,
   }) {
      return Container(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
         decoration: BoxDecoration(
            color: isCurrentUser ? const Color(0xFFF0F9F4) : Colors.transparent,
         ),
         child: Row(
            children: [
               // Rank badge
               SizedBox(
                  width: 40,
                  child: rank.contains(RegExp(r'\d'))
                        ? Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                 color: const Color(0xFF2E8B57).withOpacity(0.2),
                                 shape: BoxShape.circle,
                              ),
                              child: Center(
                                 child: Text(
                                    rank,
                                    style: const TextStyle(
                                       fontSize: 14,
                                       fontWeight: FontWeight.bold,
                                       color: Color(0xFF1B5E3B),
                                    ),
                                 ),
                              ),
                           )
                        : Text(rank, style: const TextStyle(fontSize: 24)),
               ),
               const SizedBox(width: 12),
               // Avatar
               CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF2E8B57).withOpacity(0.3),
                  child: Text(
                     name[0],
                     style: const TextStyle(
                        color: Color(0xFF1B5E3B),
                        fontWeight: FontWeight.bold,
                     ),
                  ),
               ),
               const SizedBox(width: 12),
               // Name
               Expanded(
                  child: Text(
                     name,
                     style: TextStyle(
                        fontSize: 16,
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                        color: isCurrentUser ? const Color(0xFF1B5E3B) : Colors.black87,
                     ),
                  ),
               ),
               // Meals
               Text(
                  meals,
                  style: const TextStyle(
                     fontSize: 14,
                     color: Colors.black54,
                     fontWeight: FontWeight.w500,
                  ),
               ),
               const SizedBox(width: 12),
               // Badge
               if (badge != null)
                  Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                     decoration: BoxDecoration(
                        color: const Color(0xFF2E8B57),
                        borderRadius: BorderRadius.circular(12),
                     ),
                     child: Text(
                        badge,
                        style: const TextStyle(
                           fontSize: 11,
                           fontWeight: FontWeight.bold,
                           color: Colors.white,
                        ),
                     ),
                  )
               else
                  const SizedBox(width: 60),
            ],
         ),
      );
   }
}
