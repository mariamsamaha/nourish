import 'package:flutter/material.dart';
import 'package:proj/routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0), 
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF81C784), 
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              _buildImpactCard(),
              const SizedBox(height: 24),
              
              
              const Text(
                "General",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildListTile(
                context,
                title: "Notifications",
                icon: Icons.notifications_outlined,
                onTap: () {
                  _navigateToScreen(context, "Notifications");
                },
              ),
              _buildListTile(
                context,
                title: "Location Settings",
                icon: Icons.location_on_outlined,
                onTap: () {
                  _navigateToScreen(context, "Location Settings");
                },
              ),
              _buildListTile(
                context,
                title: "Dietary Preferences",
                icon: Icons.restaurant_menu,
                onTap: () {
                  _navigateToScreen(context, "Dietary Preferences");
                },
              ),
              _buildListTile(
                context,
                title: "Scan Food",
                icon: Icons.camera_alt,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.camera);
                },
              ),
              _buildListTile(
                context,
                title: "Language",
                icon: Icons.language,
                onTap: () {
                  _navigateToScreen(context, "Language");
                },
              ),
              
              const SizedBox(height: 24),
              
              
              const Text(
                "Account",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildListTile(
                context,
                title: "Profile",
                icon: Icons.person_outline,
                onTap: () {
                  _navigateToScreen(context, "Profile");
                },
              ),
              _buildListTile(
                context,
                title: "Reservation History",
                icon: Icons.history,
                onTap: () {
                  _navigateToScreen(context, "Reservation History");
                },
              ),
              _buildListTile(
                context,
                title: "Saved Restaurants",
                icon: Icons.bookmark_outline,
                onTap: () {
                  _navigateToScreen(context, "Saved Restaurants");
                },
              ),
              _buildListTile(
                context,
                title: "Impact Statistics",
                icon: Icons.eco_outlined,
                onTap: () {
                  _navigateToScreen(context, "Impact Statistics");
                },
              ),
              
              const SizedBox(height: 24),
              
              
              const Text(
                "Help & Support",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildListTile(
                context,
                title: "About Nourish",
                icon: Icons.info_outline_rounded,
                onTap: () {
                  _navigateToScreen(context, "About Nourish");
                },
              ),
              _buildListTile(
                context,
                title: "Help Center",
                icon: Icons.help_outline,
                onTap: () {
                  _navigateToScreen(context, "Help Center");
                },
              ),
              _buildListTile(
                context,
                title: "Contact Us",
                icon: Icons.mail_outline,
                onTap: () {
                  _navigateToScreen(context, "Contact Us");
                },
              ),
              
              const SizedBox(height: 24),
              
            
              const Text(
                "Privacy & Legal",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildListTile(
                context,
                title: "Terms of Service",
                icon: Icons.description_outlined,
                onTap: () {
                  _navigateToScreen(context, "Terms of Service");
                },
              ),
              _buildListTile(
                context,
                title: "Privacy Policy",
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  _navigateToScreen(context, "Privacy Policy");
                },
              ),
              _buildListTile(
                context,
                title: "Security",
                icon: Icons.security_outlined,
                onTap: () {
                  _navigateToScreen(context, "Security");
                },
              ),
              
              const SizedBox(height: 24),
              
              
              _buildSignOutButton(context),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF66BB6A).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.eco,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Impact",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "24 meals saved from waste!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFA5D6A7).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF66BB6A),
          size: 18,
        ),
        leading: Icon(
          icon,
          color: const Color(0xFF4CAF50),
          size: 28,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        title: const Text(
          "Sign Out",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
          size: 28,
        ),
        onTap: () {
          _showSignOutDialog(context);
        },
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF66BB6A)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signed out successfully'),
                    backgroundColor: Color(0xFF66BB6A),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToScreen(BuildContext context, String screenName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to $screenName'),
        backgroundColor: const Color(0xFF66BB6A),
        duration: const Duration(seconds: 1),
      ),
    );
    
  }
}