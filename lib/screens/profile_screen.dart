import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj/widgets/custom_bottom_nav_bar.dart';
import 'package:proj/routes/app_routes.dart';
import 'package:proj/services/data_seeder.dart';
import 'package:proj/services/auth_service.dart';
import 'package:proj/services/database_service.dart';
import 'package:proj/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3; // Profile is index 3

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
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.charity);
    }
  }

  Future<void> _seedDatabase(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🌱 Seeding database... Please wait.')),
      );
      
      await DataSeeder.seed();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Database seeded successfully! Restart app to see changes.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error seeding database: $e')),
        );
      }
    }
  }

  Future<void> _showFavoritesModal(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = await authService.getStoredUserId();

    if (userId == null) return;

    final dbService = DatabaseService();
    final favorites = await dbService.getFavoriteRestaurants(userId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Favorite Restaurants',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: favorites.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No favorite restaurants yet',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.all(16),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final fav = favorites[index];
                          final tags = fav['restaurant_tags'] as List<dynamic>? ?? [];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.restaurantDetail,
                                  arguments: {
                                    'id': fav['restaurant_id'],
                                    'name': fav['restaurant_name'],
                                    'rating': fav['restaurant_rating'] ?? 0.0,
                                    'reviews': fav['restaurant_reviews'] ?? 0,
                                    'tags': tags,
                                    'image': fav['restaurant_image'] ?? '',
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        fav['restaurant_image'] ?? '',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.restaurant),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fav['restaurant_name'] ?? 'Restaurant',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 16, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${fav['restaurant_rating'] ?? 0.0} (${fav['restaurant_reviews'] ?? 0})',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          if (tags.isNotEmpty)
                                            const SizedBox(height: 8),
                                          if (tags.isNotEmpty)
                                            Wrap(
                                              spacing: 4,
                                              children: tags.take(2).map((tag) => Chip(
                                                label: Text(
                                                  tag.toString(),
                                                  style: const TextStyle(fontSize: 11),
                                                ),
                                                padding: EdgeInsets.zero,
                                                visualDensity: VisualDensity.compact,
                                              )).toList(),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _showPersonalInfoModal(BuildContext context) async {
  final authService = Provider.of<AuthService>(context, listen: false);

  final userEmail = await authService.getStoredUserEmail();

  String? userName;
  if (userEmail != null) {
    userName = userEmail.split('@')[0].replaceAll('.', ' ').split(' ').map((word) =>
      word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  if (!mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: Column(
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                controller: controller,
                padding: EdgeInsets.zero,
                children: [
                  _buildInfoCard(
                    context,
                    icon: Icons.person,
                    iconColor: Colors.teal,
                    title: userName ?? 'No name available',
                    subtitle: 'Name',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    icon: Icons.email,
                    iconColor: Colors.deepPurple,
                    title: userEmail ?? 'No email available',
                    subtitle: 'Email',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper widget to build an info card
Widget _buildInfoCard(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
}) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
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


Future<void> _showAboutNourichModal(BuildContext context) async {
  if (!mounted) return;

  showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.6,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    builder: (_, controller) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        controller: controller,
        child: const AboutNourichSection(),
      ),
    ),
  ),
);

}

Future<void> _showTermsPrivacyModal(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TermsPrivacySection(),
            ),
          ),
        );
      },
    ),
  );
}


Future<void> _showHelpCenterModal(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: HelpCenterSection(),
            ),
          ),
        );
      },
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Match home screen
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            
            SliverToBoxAdapter(
              child: _ProfileHeader(),
            ),

            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    SizedBox(height: 8),
                    _SectionTitle(title: 'Account'),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionCard(
                  items: [
                    SectionItem(icon: Icons.person, label: 'Personal Information', background: Colors.blue.shade50, iconColor: Colors.blue.shade600),
                     ],
                  onTap: (index) {
                   if (index == 0) {
                    _showPersonalInfoModal(context);
                  }
                },
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 16)),

            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const _SectionTitle(title: 'Preferences'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionCard(
                  items: [
                    SectionItem(icon: Icons.favorite, label: 'Favorite Restaurants', background: Colors.red.shade50, iconColor: Colors.red.shade600),
                    SectionItem(icon: Icons.camera_alt, label: 'Scan Food', background: Colors.green.shade50, iconColor: Colors.green.shade600),
                  ],
                  onTap: (index) {
                    if (index == 0) {
                      _showFavoritesModal(context);
                    } else if (index == 1) {
                      Navigator.pushNamed(context, AppRoutes.camera);
                    }
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 16)),

            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const _SectionTitle(title: 'Support'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionCard(
                  items: [
                    SectionItem(icon: Icons.help_outline, label: 'Help Center', background: Colors.cyan.shade50, iconColor: Colors.cyan.shade600),
                    SectionItem(icon: null, label: 'About Nourish', background: null, iconColor: null),
                    SectionItem(icon: null, label: 'Terms & Privacy', background: null, iconColor: null),
                  ],
                  onTap: (index) {
                    if (index == 1) {
                      _showAboutNourichModal(context);
                    } else if (index==2){
                      _showTermsPrivacyModal(context);
                    } else {
                      _showHelpCenterModal(context);
                    }
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 20)),

            // Developer Tools
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionTitle(title: 'Developer Tools'),
                    const SizedBox(height: 8),
                    SectionCard(
                      items: [
                        SectionItem(
                          icon: Icons.cloud_upload,
                          label: 'Seed Database',
                          background: Colors.orange.shade50,
                          iconColor: Colors.orange.shade600,
                        ),
                      ],
                      onTap: (index) => _seedDatabase(context),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 20)),

            // Logout
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LogoutButton(onPressed: () async {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  await authService.signOut();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.welcome,
                      (route) => false,
                    );
                  }
                }),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 12)),

            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Version 1.0.0 • Made with 💚 for the planet',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 24)),
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


class _ProfileHeader extends StatefulWidget {
  const _ProfileHeader({super.key});

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  String _userEmail = 'Loading...';
  String _userName = 'User';
  File? _profileImageFile;  // Temporary during selection
  String? _profileImageBase64;  // Stored in database
  bool _isUploading = false;

  final _picker = ImagePicker();
  final _storageService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final storedEmail = await authService.getStoredUserEmail();
      final userId = await authService.getStoredUserId();
      
      final storedName = storedEmail != null
          ? storedEmail.split('@')[0].replaceAll('.', ' ').split(' ').map((word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)).join(' ')
          : 'User';

      // Load profile image from database (SQLite on mobile, Firestore on web)
      String? imageBase64;
      if (userId != null) {
        imageBase64 = await _storageService.getProfileImageDual(userId);
      }

      setState(() {
        _userEmail = storedEmail ?? 'No email found';
        _userName = storedName;
        _profileImageBase64 = imageBase64;
      });
    } catch (e) {
      setState(() {
        _userEmail = 'Error loading email';
        _userName = 'User';
      });
    }
  }

  Future<void> _showEditProfileModal() async {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Profile Image with edit button
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _profileImageBase64 != null
                          ? MemoryImage(base64Decode(_profileImageBase64!))
                          : _profileImageFile != null 
                              ? FileImage(_profileImageFile!) as ImageProvider
                              : null,
                      child: _isUploading
                          ? const CircularProgressIndicator()
                          : (_profileImageBase64 == null && _profileImageFile == null)
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _showImageSourceOptions,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Name input
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email input
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  final newName = nameController.text.trim();
                  final newEmail = emailController.text.trim();

                  // TODO: Implementing the saving logic 

                  setState(() {
                    _userName = newName;
                    _userEmail = newEmail;
                  });

                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a selfie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);

      if (pickedFile != null) {
        print('🖼️ Image picked');
        
        setState(() {
          _profileImageFile = File(pickedFile.path);
          _isUploading = true;
        });

        final authService = Provider.of<AuthService>(context, listen: false);
        final userId = await authService.getStoredUserId();
        final userEmail = await authService.getStoredUserEmail();
        
        print('👤 UserId: $userId, Email: $userEmail');
        
        if (userId != null && userEmail != null) {
          try {
            print('📤 Reading image...');
            final imageBytes = await pickedFile.readAsBytes();
            print('📦 Read ${imageBytes.length} bytes');
            
            print('💾 Saving to database...');
            await _storageService.saveProfileImageDual(
              userId: userId,
              userEmail: userEmail,
              imageBytes: imageBytes,
            );
            
            // Convert to base64 for display
            final base64Image = base64Encode(imageBytes);
            
            print('✅ Save complete!');
            
            setState(() {
              _profileImageBase64 = base64Image;
              _isUploading = false;
              _profileImageFile = null;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile image saved!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('❌ Save FAILED: $e');
            setState(() {
              _isUploading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Save failed: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          print('❌ Missing userId or email!');
          setState(() {
            _isUploading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade500, Colors.green.shade700],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImageBase64 != null
                          ? MemoryImage(base64Decode(_profileImageBase64!))
                          : _profileImageFile != null
                              ? FileImage(_profileImageFile!) as ImageProvider
                              : null,
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : (_profileImageBase64 == null && _profileImageFile == null)
                              ? const Text('👤', style: TextStyle(fontSize: 28))
                              : null,
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: InkWell(
                        onTap: _showEditProfileModal,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.green.shade500,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12, offset: Offset(0, 2))],
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(_userEmail, style: TextStyle(color: Colors.green.shade100, fontSize: 13)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatTile(value: '127', label: 'Meals'),
                StatTile(value: '89kg', label: 'CO₂'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class StatTile extends StatelessWidget {
  final String value;
  final String label;
  const StatTile({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.greenAccent.shade100, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}


class SectionCard extends StatelessWidget {
  final List<SectionItem> items;
  final Function(int index)? onTap; 

  const SectionCard({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: List.generate(items.length * 2 - 1, (index) {
          final rowIndex = index ~/ 2;
          if (index.isOdd) return const Divider(height: 1);

          final item = items[rowIndex];
          return InkWell(
            onTap: () {
              if (onTap != null) {
                onTap!(rowIndex);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (item.icon != null)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: item.background ?? Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: item.iconColor ?? Colors.black54),
                        )
                      else
                        const SizedBox(width: 8),

                      const SizedBox(width: 12),

                      Text(item.label, style: TextStyle(color: Colors.grey[900])),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class SectionItem {
  final IconData? icon;
  final String label;
  final Color? background;
  final Color? iconColor;

  SectionItem({this.icon, required this.label, this.background, this.iconColor});
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const LogoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade200, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(color: Colors.grey[900], fontSize: 16, fontWeight: FontWeight.w600));
  }
}

class AboutNourichSection extends StatelessWidget {
  const AboutNourichSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.greenAccent.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.recycling_rounded, color: Colors.green.shade700, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'About Nourich',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Our Mission ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ' Nourich is dedicated to manage food waste by connecting users with restaurants offering surplus food at reduced prices. Instead of letting perfectly good food go to waste, we provide an eco-friendly and cost-effective way to enjoy delicious meals.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontSize: 15,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Our Vision ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ' We envision a world where food waste is minimized, and every meal has a purpose. Through our platform, users can also donate excess food to charities and food banks, fostering a community of generosity and sustainability.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontSize: 15,
                  color: Colors.grey[800],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
class HelpCenterSection extends StatefulWidget {
  const HelpCenterSection({super.key});

  @override
  State<HelpCenterSection> createState() => _HelpCenterSectionState();
}

class _HelpCenterSectionState extends State<HelpCenterSection> {
  final List<_FaqItem> _faqItems = [
    _FaqItem(
      question: 'How do I place an order?',
      answer: 'Browse restaurants, select your favorite meals, and follow the checkout process to place an order.',
    ),
    _FaqItem(
      question: 'How do I add favorite restaurants?',
      answer: 'Tap the heart icon on any restaurant’s page to add it to your favorites.',
    ),
    _FaqItem(
      question: 'Can I donate food through Nourich?',
      answer: 'Yes! You can donate leftover food to local charities and food banks using our donation feature.',
    ),
    _FaqItem(
      question: 'How do I view my account details?',
      answer: 'Go to Personal Information in your profile to view your name and email.',
    ),
    _FaqItem(
      question: 'What payment methods are accepted?',
      answer: 'We accept credit cards, debit cards, and some mobile payment options.',
    ),
  ];

  final Set<int> _expandedIndices = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqItems.length,
            itemBuilder: (context, index) {
              final isExpanded = _expandedIndices.contains(index);
              final faq = _faqItems[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedIndices.remove(index);
                        } else {
                          _expandedIndices.add(index);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq.question,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.green.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8, bottom: 12),
                      child: Text(
                        faq.answer,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  Divider(color: Colors.grey.shade300),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  _FaqItem({required this.question, required this.answer});
}

class TermsPrivacySection extends StatelessWidget {
  const TermsPrivacySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms & Privacy',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Terms of Use',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By using Nourich, you agree to our terms and conditions. We provide the platform to connect users with restaurants to reduce food waste. Users must be responsible and respectful while using the app.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Privacy Policy',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nourich respects your privacy. We collect only necessary information to improve your experience and never share your personal data with third parties without your consent.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
