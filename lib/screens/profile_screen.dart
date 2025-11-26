import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                    SubscriptionCard(),
                    SizedBox(height: 16),
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
                    SectionItem(icon: Icons.location_on, label: 'Saved Addresses', background: Colors.green.shade50, iconColor: Colors.green.shade600),
                    SectionItem(icon: Icons.credit_card, label: 'Payment Methods', background: Colors.purple.shade50, iconColor: Colors.purple.shade600),
                  ],
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
                    SectionItem(icon: Icons.notifications, label: 'Notifications', background: Colors.orange.shade50, iconColor: Colors.orange.shade600),
                    SectionItem(icon: Icons.settings, label: 'App Settings', background: Colors.grey.shade50, iconColor: Colors.grey.shade600),
                  ],
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
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 20)),

            // Logout
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LogoutButton(onPressed: () {
                  
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
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({super.key});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Text('👤', style: TextStyle(fontSize: 28)),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.green.shade500,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12, offset: Offset(0,2))],
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
                        const Text('Ahmed Ali', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('ahmedali@email.com', style: TextStyle(color: Colors.green.shade100, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatTile(value: '127', label: 'Meals'),
                StatTile(value: '\$892', label: 'Saved'),
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

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accent = Colors.purple.shade500;

    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [accent, Colors.pink.shade500, Colors.orange.shade400]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Nourish Plus', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          Text('Monthly Plan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Active', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Remaining this month', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 6),
                    Text('18 meals', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.14)),
                    backgroundColor: Colors.white.withOpacity(0.04),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Manage Subscription', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final List<SectionItem> items;
  const SectionCard({super.key, required this.items});

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
            onTap: () {},
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
