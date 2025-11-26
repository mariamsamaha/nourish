import 'package:flutter/material.dart';

class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
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

            SliverList(
              delegate: SliverChildListDelegate([
                CharityCard(
                  name: 'Egyptian Food Bank',
                  location: 'Cairo',
                  tag: 'Food Security',
                  description:
                      'Fighting hunger in Egypta by providing meals to those in need.',
                  meals: '1,234',
                  highlight: true,
                  highlightedColor: Colors.orange.shade600,
                  buttonLabel: 'Currently Supporting',
                ),
                const SizedBox(height: 16),

                CharityCard(
                  name: 'Community Kitchen',
                  location: 'Giza',
                  tag: 'Homeless Support',
                  description:
                      'Providing hot meals and support services to homeless individuals in Giza.',
                  meals: '892',
                  highlight: false,
                  highlightedColor: Colors.orange.shade600,
                  buttonLabel: 'Select & Support',
                ),
                const SizedBox(height: 16),

                CharityCard(
                  name: 'Feeding Families',
                  location: 'Cairo',
                  tag: 'Family Support',
                  description:
                      'Supporting low-income families with nutritious meals and food education programs.',
                  meals: '756',
                  highlight: false,
                  highlightedColor: Colors.orange.shade600,
                  buttonLabel: 'Select & Support',
                ),
                const SizedBox(height: 16),

                CharityCard(
                  name: 'Senior Meals Program',
                  location: 'Giza',
                  tag: 'Senior Care',
                  description:
                      'Delivering nutritious meals to homebound seniors and elderly community members.',
                  meals: '623',
                  highlight: false,
                  highlightedColor: Colors.orange.shade600,
                  buttonLabel: 'Select & Support',
                ),
                const SizedBox(height: 24),

                
                ImpactCard(),
                const SizedBox(height: 48),
              ]),
            ),
          ],
        ),
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

class ImpactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade50],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.people, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Charity Impact',
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _impactBox(
                  label: 'Donations',
                  value: '\$24.50',
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 12),
                _impactBox(
                  label: 'Meals Funded',
                  value: '18',
                  color: Colors.green.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _impactBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
